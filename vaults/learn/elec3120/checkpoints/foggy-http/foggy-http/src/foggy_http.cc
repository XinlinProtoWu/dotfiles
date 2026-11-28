#include "foggy_http.h"
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#ifdef FOGGY_HTTP_READ_MS
#define CLIENT_READ_TIMEOUT_MS FOGGY_HTTP_READ_MS
#else
#define CLIENT_READ_TIMEOUT_MS 5000
#endif
#define SERVER_IDLE_TIMEOUT_MS 3000

int foggy_http_buffer_append(foggy_http_buffer_t *buffer, const void *data, size_t size) {
    if (size == 0) return 0;
    if (!data || size > SIZE_MAX - buffer->size - 1) { errno = EINVAL; return -1; }
    size_t needed = buffer->size + size + 1;
    if (needed > buffer->capacity) {
        size_t capacity = buffer->capacity ? buffer->capacity : 256;
        while (capacity < needed) {
            if (capacity > SIZE_MAX / 2) { capacity = needed; break; }
            capacity *= 2;
        }
        char *grown = realloc(buffer->data, capacity);
        if (!grown) return -1;
        buffer->data = grown;
        buffer->capacity = capacity;
    }
    memcpy(buffer->data + buffer->size, data, size);
    buffer->size += size;
    buffer->data[buffer->size] = '\0';
    return 0;
}

void foggy_http_buffer_free(foggy_http_buffer_t *buffer) {
    free(buffer->data);
    memset(buffer, 0, sizeof(*buffer));
}

int foggy_http_header_set(foggy_http_header_t **headers, const char *name, const char *value) {
    char *copy = strdup(value);
    if (!copy) return -1;
    for (foggy_http_header_t *item = *headers; item; item = item->next) {
        if (strcasecmp(item->name, name) == 0) {
            free(item->value);
            item->value = copy;
            return 0;
        }
    }
    foggy_http_header_t *item = calloc(1, sizeof(*item));
    if (!item) { free(copy); return -1; }
    item->name = strdup(name);
    if (!item->name) { free(copy); free(item); return -1; }
    item->value = copy;
    item->next = *headers;
    *headers = item;
    return 0;
}

const char *foggy_http_header_get(const foggy_http_header_t *headers, const char *name) {
    for (; headers; headers = headers->next)
        if (strcasecmp(headers->name, name) == 0) return headers->value;
    return NULL;
}

void foggy_http_headers_free(foggy_http_header_t *headers) {
    while (headers) {
        foggy_http_header_t *next = headers->next;
        free(headers->name);
        free(headers->value);
        free(headers);
        headers = next;
    }
}

void foggy_http_response_init(foggy_http_response_t *response) {
    memset(response, 0, sizeof(*response));
    response->status = 200;
}

void foggy_http_response_free(foggy_http_response_t *response) {
    foggy_http_buffer_free(&response->body);
    foggy_http_headers_free(response->headers);
    if (response->free_context) response->free_context(response->next_context);
    memset(response, 0, sizeof(*response));
}

int foggy_http_client_init(foggy_http_client_t *client, const char *host, int port, int keep_alive) {
    memset(client, 0, sizeof(*client));
    if (!host || port < 1 || port > 65535) { errno = EINVAL; return -1; }
    client->host = strdup(host);
    if (!client->host) return -1;
    client->port = port;
    client->keep_alive = keep_alive;
    return 0;
}

void foggy_http_client_close(foggy_http_client_t *client) {
    foggy_transport_close(&client->connection);
    foggy_http_buffer_free(&client->input);
}

void foggy_http_client_free(foggy_http_client_t *client) {
    foggy_http_client_close(client);
    free(client->host);
    memset(client, 0, sizeof(*client));
}

int foggy_http_client_connection_port(const foggy_http_client_t *client) {
    return foggy_transport_local_port(client->connection);
}

/* ------------------------------------------------------------------ */
/* Internal helpers                                                    */
/* ------------------------------------------------------------------ */

static const char *find_bytes(const char *hay, size_t n, const char *needle, size_t m) {
    if (m == 0) return hay;
    if (m > n) return NULL;
    for (size_t i = 0; i + m <= n; ++i)
        if (memcmp(hay + i, needle, m) == 0) return hay + i;
    return NULL;
}

static int append_string(foggy_http_buffer_t *buffer, const char *s) {
    return foggy_http_buffer_append(buffer, s, strlen(s));
}

static void buffer_consume(foggy_http_buffer_t *buffer, size_t n) {
    if (n == 0) return;
    if (n >= buffer->size) {
        buffer->size = 0;
        if (buffer->data) buffer->data[0] = '\0';
        return;
    }
    memmove(buffer->data, buffer->data + n, buffer->size - n);
    buffer->size -= n;
    buffer->data[buffer->size] = '\0';
}

/* Parse the block between the start line and the blank line. The result is a
 * linked list owned by the caller (free with foggy_http_headers_free). On
 * allocation failure *err is set and NULL is returned. */
static foggy_http_header_t *parse_header_block(const char *begin, const char *end, int *err) {
    *err = 0;
    foggy_http_header_t *list = NULL;
    const char *line = begin;
    while (line < end) {
        const char *le = line;
        while (le + 1 < end && !(le[0] == '\r' && le[1] == '\n')) ++le;
        if (le + 1 >= end) break;
        const char *colon = memchr(line, ':', (size_t)(le - line));
        if (colon) {
            const char *ns = line, *ne = colon;
            while (ne > ns && (ne[-1] == ' ' || ne[-1] == '\t')) --ne;
            const char *vs = colon + 1, *ve = le;
            while (vs < ve && (*vs == ' ' || *vs == '\t')) ++vs;
            while (ve > vs && (ve[-1] == ' ' || ve[-1] == '\t')) --ve;
            if (ns < ne) {
                foggy_http_header_t *h = calloc(1, sizeof(*h));
                if (!h) { *err = -1; break; }
                h->name = strndup(ns, (size_t)(ne - ns));
                h->value = strndup(vs, (size_t)(ve - vs));
                if (!h->name || !h->value) {
                    free(h->name);
                    free(h->value);
                    free(h);
                    *err = -1;
                    break;
                }
                h->next = list;
                list = h;
            }
        }
        line = le + 2;
    }
    if (*err) {
        foggy_http_headers_free(list);
        return NULL;
    }
    return list;
}

/* Case-insensitive token membership, e.g. "gzip, chunked". */
static int contains_token(const char *value, const char *token) {
    size_t tl = strlen(token);
    const char *p = value;
    while (*p) {
        while (*p == ' ' || *p == '\t' || *p == ',') ++p;
        const char *end = p;
        while (*end && *end != ',' && *end != ' ' && *end != '\t') ++end;
        if ((size_t)(end - p) == tl && strncasecmp(p, token, tl) == 0) return 1;
        p = end;
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* Request parsing (server side)                                       */
/* ------------------------------------------------------------------ */

typedef struct {
    int valid; /* 1 = complete, 0 = need more bytes, -1 = malformed */
    size_t total; /* bytes consumed: headers + body */
    char *method, *target, *version;
    foggy_http_header_t *headers;
    const void *body;
    size_t body_size;
} parsed_request_t;

static void parsed_request_free(parsed_request_t *p) {
    free(p->method);
    free(p->target);
    free(p->version);
    foggy_http_headers_free(p->headers);
    memset(p, 0, sizeof(*p));
}

static int parse_request(const char *data, size_t size, parsed_request_t *out) {
    memset(out, 0, sizeof(*out));
    const char *hend = find_bytes(data, size, "\r\n\r\n", 4);
    if (!hend) return 0;
    const char *line_end = find_bytes(data, (size_t)(hend - data), "\r\n", 2);
    if (!line_end || line_end == data) return -1;

    const char *sp1 = memchr(data, ' ', (size_t)(line_end - data));
    if (!sp1 || sp1 == data) return -1;
    const char *target = sp1 + 1;
    const char *sp2 = memchr(target, ' ', (size_t)(line_end - target));
    if (!sp2 || sp2 == target) return -1;
    const char *version = sp2 + 1;
    size_t version_len = (size_t)(line_end - version);
    if (!(version_len == 8 &&
          (memcmp(version, "HTTP/1.1", 8) == 0 || memcmp(version, "HTTP/1.0", 8) == 0)))
        return -1;

    int herr;
    foggy_http_header_t *headers = parse_header_block(line_end + 2, hend + 2, &herr);
    if (herr) return -1;

    size_t body_size = 0;
    const char *cl = foggy_http_header_get(headers, "Content-Length");
    if (cl) {
        char *endp = NULL;
        errno = 0;
        unsigned long value = strtoul(cl, &endp, 10);
        if (errno || endp == cl || *endp != '\0') {
            foggy_http_headers_free(headers);
            return -1;
        }
        body_size = (size_t)value;
        if ((unsigned long)body_size != value) {
            foggy_http_headers_free(headers);
            return -1;
        }
    }

    size_t header_end = (size_t)(hend - data) + 4;
    if (body_size > size - header_end) {
        foggy_http_headers_free(headers);
        return 0;
    }

    out->method = strndup(data, (size_t)(sp1 - data));
    out->target = strndup(target, (size_t)(sp2 - target));
    out->version = strndup(version, version_len);
    if (!out->method || !out->target || !out->version) {
        parsed_request_free(out);
        foggy_http_headers_free(headers);
        return -1;
    }
    out->headers = headers;
    out->body = data + header_end;
    out->body_size = body_size;
    out->total = header_end + body_size;
    out->valid = 1;
    return 1;
}

/* ------------------------------------------------------------------ */
/* Response parsing (client side)                                      */
/* ------------------------------------------------------------------ */

typedef struct {
    int valid;
    int status;
    char *version;
    foggy_http_header_t *headers;
    int chunked;
    int has_content_length;
    size_t content_length;
    size_t header_end;
} parsed_response_t;

static void parsed_response_free(parsed_response_t *p) {
    free(p->version);
    foggy_http_headers_free(p->headers);
    memset(p, 0, sizeof(*p));
}

static int parse_response_head(const char *data, size_t size, parsed_response_t *out) {
    memset(out, 0, sizeof(*out));
    const char *hend = find_bytes(data, size, "\r\n\r\n", 4);
    if (!hend) return 0;
    const char *line_end = find_bytes(data, (size_t)(hend - data), "\r\n", 2);
    if (!line_end) return -1;

    const char *sp = memchr(data, ' ', (size_t)(line_end - data));
    if (!sp) return -1;
    size_t version_len = (size_t)(sp - data);
    if (!(version_len == 8 &&
          (memcmp(data, "HTTP/1.1", 8) == 0 || memcmp(data, "HTTP/1.0", 8) == 0)))
        return -1;

    const char *code = sp + 1;
    while (code < line_end && (*code == ' ' || *code == '\t')) ++code;
    if (code + 3 > line_end) return -1;
    int status = 0;
    for (int i = 0; i < 3; ++i) {
        if (code[i] < '0' || code[i] > '9') return -1;
        status = status * 10 + (code[i] - '0');
    }

    int herr;
    foggy_http_header_t *headers = parse_header_block(line_end + 2, hend + 2, &herr);
    if (herr) return -1;

    out->version = strndup(data, version_len);
    if (!out->version) {
        foggy_http_headers_free(headers);
        return -1;
    }
    out->status = status;
    out->headers = headers;
    out->header_end = (size_t)(hend - data) + 4;

    const char *te = foggy_http_header_get(headers, "Transfer-Encoding");
    out->chunked = te && contains_token(te, "chunked");
    if (!out->chunked) {
        out->has_content_length = 0;
        out->content_length = 0;
        const char *cl = foggy_http_header_get(headers, "Content-Length");
        if (cl) {
            char *endp = NULL;
            errno = 0;
            unsigned long value = strtoul(cl, &endp, 10);
            if (errno || endp == cl || *endp != '\0') {
                parsed_response_free(out);
                return -1;
            }
            out->content_length = (size_t)value;
            if ((unsigned long)out->content_length != value) {
                parsed_response_free(out);
                return -1;
            }
            out->has_content_length = 1;
        }
    }
    out->valid = 1;
    return 1;
}

/* ------------------------------------------------------------------ */
/* Client request/response                                             */
/* ------------------------------------------------------------------ */

static int serialize_request(foggy_http_buffer_t *out, const char *method, const char *path,
                             const void *body, size_t body_size,
                             const char *host, int port, int keep_alive) {
    char line[256];
    const char *version = keep_alive ? "HTTP/1.1" : "HTTP/1.0";
    if (append_string(out, method) < 0) return -1;
    if (foggy_http_buffer_append(out, " ", 1) < 0) return -1;
    if (append_string(out, path) < 0) return -1;
    if (foggy_http_buffer_append(out, " ", 1) < 0) return -1;
    if (append_string(out, version) < 0) return -1;
    if (append_string(out, "\r\n") < 0) return -1;

    int n = snprintf(line, sizeof(line), "Host: %s:%d\r\n", host, port);
    if (n < 0 || (size_t)n >= sizeof(line)) { errno = EOVERFLOW; return -1; }
    if (foggy_http_buffer_append(out, line, (size_t)n) < 0) return -1;

    if (append_string(out, keep_alive ? "Connection: keep-alive\r\n" : "Connection: close\r\n") < 0)
        return -1;

    if (body_size > 0 || strcmp(method, "POST") == 0) {
        n = snprintf(line, sizeof(line), "Content-Length: %zu\r\n", body_size);
        if (n < 0 || (size_t)n >= sizeof(line)) { errno = EOVERFLOW; return -1; }
        if (foggy_http_buffer_append(out, line, (size_t)n) < 0) return -1;
    }

    if (append_string(out, "\r\n") < 0) return -1;
    if (body_size > 0 && foggy_http_buffer_append(out, body, body_size) < 0) return -1;
    return 0;
}

/* Read one full HTTP response from client->connection into the parsed
 * response. Incremental payloads are delivered through `receiver` when it is
 * supplied; the full body is always accumulated into response->body. */
static int client_receive(foggy_http_client_t *client, foggy_http_receiver_t receiver,
                          void *context, foggy_http_response_t *response) {
    parsed_response_t pr;
    memset(&pr, 0, sizeof(pr));

    /* Head */
    for (;;) {
        int st = parse_response_head(client->input.data ? client->input.data : "",
                                     client->input.size, &pr);
        if (st < 0) { errno = EPROTO; return -1; }
        if (st == 1) break;
        char data[4096];
        int n = foggy_transport_read(client->connection, data, sizeof(data), CLIENT_READ_TIMEOUT_MS);
        if (n <= 0) { if (n == 0) errno = ECONNRESET; return -1; }
        if (foggy_http_buffer_append(&client->input, data, (size_t)n) < 0) return -1;
    }

    response->status = pr.status;
    response->headers = pr.headers;
    pr.headers = NULL;

    int should_close = 0;
    const char *conn = foggy_http_header_get(response->headers, "Connection");
    if (conn && strcasecmp(conn, "close") == 0) should_close = 1;
    else if (!(conn && strcasecmp(conn, "keep-alive") == 0) && strcmp(pr.version, "HTTP/1.1") != 0)
        should_close = 1;

    size_t consumed;
    if (pr.chunked) {
        size_t pos = pr.header_end;
        for (;;) {
            const char *line_end = find_bytes(client->input.data + pos,
                                              client->input.size - pos, "\r\n", 2);
            while (!line_end) {
                char data[4096];
                int n = foggy_transport_read(client->connection, data, sizeof(data), CLIENT_READ_TIMEOUT_MS);
                if (n <= 0) { if (n == 0) errno = ECONNRESET; parsed_response_free(&pr); return -1; }
                if (foggy_http_buffer_append(&client->input, data, (size_t)n) < 0) {
                    parsed_response_free(&pr);
                    return -1;
                }
                line_end = find_bytes(client->input.data + pos, client->input.size - pos, "\r\n", 2);
            }

            size_t chunk_size = 0;
            {
                const char *p = client->input.data + pos;
                const char *q = line_end;
                for (; p < q; ++p) {
                    if (*p == ';') break; /* chunk extensions are ignored */
                    int d = -1;
                    if (*p >= '0' && *p <= '9') d = *p - '0';
                    else if (*p >= 'a' && *p <= 'f') d = *p - 'a' + 10;
                    else if (*p >= 'A' && *p <= 'F') d = *p - 'A' + 10;
                    if (d < 0) { errno = EPROTO; parsed_response_free(&pr); return -1; }
                    chunk_size = chunk_size * 16 + (size_t)d;
                }
            }
            pos = (size_t)(line_end - client->input.data) + 2;

            if (chunk_size == 0) {
                while (client->input.size < pos + 2) {
                    char data[4096];
                    int n = foggy_transport_read(client->connection, data, sizeof(data), CLIENT_READ_TIMEOUT_MS);
                    if (n <= 0) { if (n == 0) errno = ECONNRESET; parsed_response_free(&pr); return -1; }
                    if (foggy_http_buffer_append(&client->input, data, (size_t)n) < 0) {
                        parsed_response_free(&pr);
                        return -1;
                    }
                }
                pos += 2; /* trailing CRLF of 0\r\n\r\n */
                break;
            }

            while (client->input.size < pos + chunk_size + 2) {
                char data[4096];
                int n = foggy_transport_read(client->connection, data, sizeof(data), CLIENT_READ_TIMEOUT_MS);
                if (n <= 0) { if (n == 0) errno = ECONNRESET; parsed_response_free(&pr); return -1; }
                if (foggy_http_buffer_append(&client->input, data, (size_t)n) < 0) {
                    parsed_response_free(&pr);
                    return -1;
                }
            }

            if (receiver) receiver(client->input.data + pos, chunk_size, context);
            if (foggy_http_buffer_append(&response->body, client->input.data + pos, chunk_size) < 0) {
                parsed_response_free(&pr);
                return -1;
            }
            pos += chunk_size + 2;
        }
        consumed = pos;
    } else if (pr.has_content_length) {
        size_t need = pr.header_end + pr.content_length;
        while (client->input.size < need) {
            char data[4096];
            int n = foggy_transport_read(client->connection, data, sizeof(data), CLIENT_READ_TIMEOUT_MS);
            if (n <= 0) { if (n == 0) errno = ECONNRESET; parsed_response_free(&pr); return -1; }
            if (foggy_http_buffer_append(&client->input, data, (size_t)n) < 0) {
                parsed_response_free(&pr);
                return -1;
            }
        }
        if (pr.content_length > 0) {
            if (receiver) receiver(client->input.data + pr.header_end, pr.content_length, context);
            if (foggy_http_buffer_append(&response->body, client->input.data + pr.header_end,
                                         pr.content_length) < 0) {
                parsed_response_free(&pr);
                return -1;
            }
        }
        consumed = need;
    } else {
        /* No Content-Length and not chunked: close-delimited body (HTTP/1.0). */
        size_t buffered = client->input.size - pr.header_end;
        if (buffered > 0) {
            if (receiver) receiver(client->input.data + pr.header_end, buffered, context);
            if (foggy_http_buffer_append(&response->body, client->input.data + pr.header_end,
                                         buffered) < 0) {
                parsed_response_free(&pr);
                return -1;
            }
        }
        for (;;) {
            char data[4096];
            int n = foggy_transport_read(client->connection, data, sizeof(data), CLIENT_READ_TIMEOUT_MS);
            if (n < 0) { parsed_response_free(&pr); return -1; }
            if (n == 0) break;
            if (receiver) receiver(data, (size_t)n, context);
            if (foggy_http_buffer_append(&response->body, data, (size_t)n) < 0) {
                parsed_response_free(&pr);
                return -1;
            }
        }
        consumed = client->input.size;
        should_close = 1; /* close-delimited body ends at peer EOF */
    }

    buffer_consume(&client->input, consumed);
    free(pr.version);
    pr.version = NULL;
    if (should_close) foggy_http_client_close(client);
    return 0;
}

static int request(foggy_http_client_t *client, const char *method, const char *path,
                   const void *body, size_t body_size, foggy_http_receiver_t receiver,
                   void *context, foggy_http_response_t *response) {
    foggy_http_buffer_t req = {0};
    if (serialize_request(&req, method, path, body, body_size,
                          client->host, client->port, client->keep_alive) < 0)
        return -1;

    for (int attempt = 0; attempt < 2; ++attempt) {
        foggy_http_response_free(response);
        foggy_http_response_init(response);

        if (!client->connection) {
            client->connection = foggy_transport_open(client->host, client->port, 0);
            if (!client->connection) {
                foggy_http_buffer_free(&req);
                return -1;
            }
        }

        if (foggy_transport_write(client->connection, req.data, req.size) < 0) {
            int saved = errno;
            foggy_http_client_close(client);
            errno = saved;
            if (attempt == 0) continue;
            foggy_http_buffer_free(&req);
            return -1;
        }

        if (client_receive(client, receiver, context, response) == 0) {
            foggy_http_buffer_free(&req);
            return 0;
        }

        int saved = errno;
        foggy_http_client_close(client);
        errno = saved;
        if (attempt == 0) continue;
        foggy_http_buffer_free(&req);
        return -1;
    }

    foggy_http_buffer_free(&req);
    return -1;
}

int foggy_http_client_get(foggy_http_client_t *client, const char *path, foggy_http_response_t *response) {
    return request(client, "GET", path, NULL, 0, NULL, NULL, response);
}

int foggy_http_client_post(foggy_http_client_t *client, const char *path,
                           const void *body, size_t body_size,
                           foggy_http_receiver_t receiver, void *context,
                           foggy_http_response_t *response) {
    return request(client, "POST", path, body, body_size, receiver, context, response);
}

/* ------------------------------------------------------------------ */
/* Server                                                              */
/* ------------------------------------------------------------------ */

void foggy_http_server_init(foggy_http_server_t *server) { server->routes = NULL; }

static int route(foggy_http_server_t *server, const char *method, const char *path,
                 foggy_http_handler_t handler, void *context) {
    for (foggy_http_route_t *item = server->routes; item; item = item->next) {
        if (strcmp(item->method, method) == 0 && strcmp(item->path, path) == 0) {
            item->handler = handler;
            item->context = context;
            return 0;
        }
    }
    foggy_http_route_t *item = calloc(1, sizeof(*item));
    if (!item) return -1;
    item->path = strdup(path);
    if (!item->path) { free(item); return -1; }
    item->method = method;
    item->handler = handler;
    item->context = context;
    item->next = server->routes;
    server->routes = item;
    return 0;
}

int foggy_http_server_get(foggy_http_server_t *server, const char *path,
                          foggy_http_handler_t handler, void *context) {
    return route(server, "GET", path, handler, context);
}

int foggy_http_server_post(foggy_http_server_t *server, const char *path,
                           foggy_http_handler_t handler, void *context) {
    return route(server, "POST", path, handler, context);
}

void foggy_http_server_free(foggy_http_server_t *server) {
    while (server->routes) {
        foggy_http_route_t *next = server->routes->next;
        free(server->routes->path);
        free(server->routes);
        server->routes = next;
    }
}

static const char *reason_phrase(int status) {
    switch (status) {
        case 200: return "OK";
        case 400: return "Bad Request";
        case 404: return "Not Found";
        case 405: return "Method Not Allowed";
        case 500: return "Internal Server Error";
        case 501: return "Not Implemented";
        default: return "OK";
    }
}

/* Build a routing response for a miss: 200 for OPTIONS on a registered path,
 * 404 for an unknown path, or 405 for an unsupported method on a known path.
 * has_get/has_post describe which handlers are registered for the target. */
static int routing_response(foggy_http_response_t *response, int status,
                            int has_get, int has_post) {
    response->status = status;
    if (status != 200) {
        const char *message = status == 404 ? "Not Found" : "Method Not Allowed";
        char body[64];
        int n = snprintf(body, sizeof(body), "{\"error\":\"%s\"}", message);
        if (n < 0 || (size_t)n >= sizeof(body)) { errno = EOVERFLOW; return -1; }
        if (foggy_http_header_set(&response->headers, "Content-Type", "application/json") < 0)
            return -1;
        if (foggy_http_buffer_append(&response->body, body, (size_t)n) < 0) return -1;
    }
    if (status != 404) {
        const char *allow = NULL;
        if (has_get && has_post) allow = "GET, POST, OPTIONS";
        else if (has_get) allow = "GET, OPTIONS";
        else if (has_post) allow = "POST, OPTIONS";
        if (!allow) { errno = EINVAL; return -1; }
        if (foggy_http_header_set(&response->headers, "Allow", allow) < 0) return -1;
    }
    return 0;
}

static int write_response(foggy_transport_t io, const char *version,
                          const foggy_http_response_t *response, int chunked, int close_after) {
    foggy_http_buffer_t out = {0};
    char line[128];
    int n = snprintf(line, sizeof(line), "%s %d %s\r\n", version,
                     response->status, reason_phrase(response->status));
    if (n < 0 || (size_t)n >= sizeof(line)) { errno = EOVERFLOW; return -1; }
    if (foggy_http_buffer_append(&out, line, (size_t)n) < 0) goto fail;

    for (const foggy_http_header_t *h = response->headers; h; h = h->next) {
        if (foggy_http_buffer_append(&out, h->name, strlen(h->name)) < 0) goto fail;
        if (append_string(&out, ": ") < 0) goto fail;
        if (foggy_http_buffer_append(&out, h->value, strlen(h->value)) < 0) goto fail;
        if (append_string(&out, "\r\n") < 0) goto fail;
    }

    if (chunked) {
        if (append_string(&out, "Transfer-Encoding: chunked\r\n") < 0) goto fail;
    } else if (!response->next) {
        n = snprintf(line, sizeof(line), "Content-Length: %zu\r\n", response->body.size);
        if (n < 0 || (size_t)n >= sizeof(line)) { errno = EOVERFLOW; goto fail; }
        if (foggy_http_buffer_append(&out, line, (size_t)n) < 0) goto fail;
    }

    if (append_string(&out, close_after ? "Connection: close\r\n" : "Connection: keep-alive\r\n") < 0)
        goto fail;
    if (append_string(&out, "\r\n") < 0) goto fail;

    if (foggy_transport_write(io, out.data, out.size) < 0) goto fail;
    foggy_http_buffer_free(&out);

    if (response->next) {
        for (;;) {
            foggy_http_buffer_t part = {0};
            int more = response->next(response->next_context, &part);
            if (more < 0) { foggy_http_buffer_free(&part); return -1; }
            if (part.size > 0) {
                if (chunked) {
                    foggy_http_buffer_t frame = {0};
                    char hex[32];
                    int hn = snprintf(hex, sizeof(hex), "%zx\r\n", part.size);
                    if (hn < 0 || (size_t)hn >= sizeof(hex)) {
                        foggy_http_buffer_free(&part);
                        errno = EOVERFLOW;
                        return -1;
                    }
                    if (foggy_http_buffer_append(&frame, hex, (size_t)hn) < 0 ||
                        foggy_http_buffer_append(&frame, part.data, part.size) < 0 ||
                        append_string(&frame, "\r\n") < 0) {
                        foggy_http_buffer_free(&frame);
                        foggy_http_buffer_free(&part);
                        return -1;
                    }
                    int w = foggy_transport_write(io, frame.data, frame.size);
                    foggy_http_buffer_free(&frame);
                    if (w < 0) { foggy_http_buffer_free(&part); return -1; }
                } else {
                    if (foggy_transport_write(io, part.data, part.size) < 0) {
                        foggy_http_buffer_free(&part);
                        return -1;
                    }
                }
            }
            foggy_http_buffer_free(&part);
            if (more == 0) break;
        }
        if (chunked && foggy_transport_write(io, "0\r\n\r\n", 5) < 0) return -1;
    } else if (response->body.size > 0) {
        if (foggy_transport_write(io, response->body.data, response->body.size) < 0) return -1;
    }
    return 0;
fail:
    foggy_http_buffer_free(&out);
    return -1;
}

int foggy_http_server_listen(foggy_http_server_t *server, int port, int session_limit) {
    for (int session = 0; session_limit == 0 || session < session_limit; ++session) {
        foggy_transport_t io = foggy_transport_open("0.0.0.0", port, 1);
        if (!io) return -1;

        foggy_http_buffer_t input = {0};
        int keep = 1;
        int session_error = 0;
        int saved_errno = 0;

        while (keep) {
            parsed_request_t pr;
            int st = parse_request(input.data ? input.data : "", input.size, &pr);

            while (st == 0) {
                char data[4096];
                int n = foggy_transport_read(io, data, sizeof(data), SERVER_IDLE_TIMEOUT_MS);
                if (n < 0 || n == 0) { keep = 0; break; } /* idle timeout, error, or EOF */
                if (foggy_http_buffer_append(&input, data, (size_t)n) < 0) {
                    session_error = -1;
                    saved_errno = errno;
                    keep = 0;
                    break;
                }
                st = parse_request(input.data, input.size, &pr);
            }
            if (!keep) break;
            if (st < 0) { keep = 0; break; } /* malformed request: close connection */

            foggy_http_request_t request = {0};
            request.method = pr.method;
            request.target = pr.target;
            request.version = pr.version;
            request.headers = pr.headers;
            request.body = pr.body;
            request.body_size = pr.body_size;

            foggy_http_response_t response;
            foggy_http_response_init(&response);

            foggy_http_route_t *handler = NULL;
            int has_get = 0, has_post = 0;
            for (foggy_http_route_t *r = server->routes; r; r = r->next) {
                if (strcmp(r->path, pr.target) == 0) {
                    if (strcmp(r->method, "GET") == 0) has_get = 1;
                    else if (strcmp(r->method, "POST") == 0) has_post = 1;
                    if (strcmp(r->method, pr.method) == 0) handler = r;
                }
            }

            if (handler) {
                int result = handler->handler(&request, &response, handler->context);
                if (result != 0) {
                    foggy_http_response_free(&response);
                    foggy_http_response_init(&response);
                    response.status = 500;
                }
            } else if (has_get || has_post) {
                if (strcmp(pr.method, "OPTIONS") == 0) {
                    if (routing_response(&response, 200, has_get, has_post) < 0) {
                        session_error = -1;
                        saved_errno = errno;
                    }
                } else {
                    if (routing_response(&response, 405, has_get, has_post) < 0) {
                        session_error = -1;
                        saved_errno = errno;
                    }
                }
            } else {
                if (routing_response(&response, 404, 0, 0) < 0) {
                    session_error = -1;
                    saved_errno = errno;
                }
            }

            int is_http11 = strcmp(pr.version, "HTTP/1.1") == 0;
            int close_after = !is_http11;
            const char *conn = foggy_http_header_get(request.headers, "Connection");
            if (conn && strcasecmp(conn, "close") == 0) close_after = 1;
            else if (conn && strcasecmp(conn, "keep-alive") == 0) close_after = 0;

            int chunked = (response.next != NULL) && is_http11;
            if (response.next && !is_http11) close_after = 1;

            int w = write_response(io, pr.version, &response, chunked, close_after);
            if (w < 0) {
                saved_errno = errno;
                session_error = -1;
            }

            foggy_http_response_free(&response);
            buffer_consume(&input, pr.total);
            parsed_request_free(&pr);

            if (session_error < 0) { keep = 0; break; }
            if (close_after) keep = 0;
        }

        foggy_http_buffer_free(&input);
        foggy_transport_close(&io);
        if (session_error < 0) {
            errno = saved_errno;
            return -1;
        }
    }
    return 0;
}
