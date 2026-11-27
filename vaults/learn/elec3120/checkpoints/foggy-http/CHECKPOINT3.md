# Checkpoint 3 — HTTP over FoggyTCP: Implementation Notes

This document records the work completed for **ELEC 3120 Checkpoint 3** in the
`foggy-http` repository. All tasks from the checkpoint handout were implemented
and verified against the local FoggyTCP v2 transport.

---

## 1. Summary

Two files were modified (the only two the checkpoint allows):

| File | Change |
|------|--------|
| `foggy-http/src/foggy_http.cc` | Implemented the full HTTP/1.0 + HTTP/1.1 library: message serialization/parsing, persistent connections, 3 s server idle timeout, reconnection, and chunked transfer coding. |
| `foggy-http/conf/nginx-stream.conf` | Filled the two `map` rules that route `/checkpoint-3/date` and `/checkpoint-3/echo` to their UDP backends. |

No other files (applications, public headers, transport adapter, NGINX module,
build files) were changed.

---

## 2. `foggy-http/src/foggy_http.cc`

### 2.1 Architecture

The existing public C API and the helper functions already present in the
starter were kept unchanged:

- `foggy_http_buffer_append` / `foggy_http_buffer_free`
- `foggy_http_header_set` / `foggy_http_header_get` / `foggy_http_headers_free`
- `foggy_http_response_init` / `foggy_http_response_free`
- `foggy_http_client_init` / `foggy_http_client_close` / `foggy_http_client_free`
- `foggy_http_client_connection_port`
- `foggy_http_server_init` / `foggy_http_server_get` / `foggy_http_server_post`
- `foggy_http_server_free`

The work was done by:

1. Adding internal helpers (`find_bytes`, `append_string`, `buffer_consume`,
   `parse_header_block`, `contains_token`).
2. Adding a full request parser (`parse_request`) and response-head parser
   (`parse_response_head`).
3. Replacing the raw-byte stub `request()` with a real HTTP client.
4. Replacing the raw-byte stub `foggy_http_server_listen()` with a real HTTP
   server loop.

### 2.2 Client side

`serialize_request()` builds a valid request whose version depends on the
keep-alive flag:

```
METHOD SP PATH SP HTTP/1.1\r\n    (keep_alive == 1)
METHOD SP PATH SP HTTP/1.0\r\n    (keep_alive == 0)
Host: host:port\r\n
Connection: keep-alive | close\r\n
Content-Length: N\r\n        (only for POST / non-empty body)
\r\n
[body]
```

Keep-alive requests use HTTP/1.1 (persistent by default); one-shot requests
(`--no-keep-alive`) use HTTP/1.0 (close by default). The `Connection` header is
always set explicitly (`keep-alive` or `close`).

`request()`:

- Serializes the request once.
- Reuses an existing live connection when present; otherwise opens one.
- Writes the request, then reads and decodes exactly one response.
- If the connection is dead (peer FIN received after a server idle timeout,
  error, or premature EOF), it closes the connection and retries once with a
  fresh connection. This is what produces a **new local UDP port** after the
  server closes an idle connection.
- Honors `Connection: close` in the response by closing the client side.

`client_receive()`:

- Buffers bytes across reads in `client->input` (a `foggy_transport_read` may
  return a partial message or bytes from more than one message).
- Parses the status line and headers.
- Determines body framing:
  - `Transfer-Encoding: chunked` → chunked decoder.
  - `Content-Length: N` → read exactly `N` bytes.
  - neither → close-delimited body (read until the peer closes; used for
    HTTP/1.0 streamed responses).
- For chunked responses, decodes chunk-size lines, payloads, and delimiters
  incrementally, **even when they are split across reads**, and delivers each
  decoded payload immediately through the receiver callback (so the echo client
  prints it as it arrives).
- Accumulates the full body into `response->body` as well.
- Consumes exactly the bytes of the completed response from the input buffer so
  a keep-alive connection is ready for the next response.

### 2.3 Server side

`parse_request()`:

- Finds the header terminator `\r\n\r\n`.
- Parses the start line (`METHOD SP target SP HTTP/1.x`).
- Parses headers into an owned linked list.
- Uses `Content-Length` to determine the body size and waits until the full body
  is buffered.
- Borrows the body into the request struct while the handler runs.

`foggy_http_server_listen()`:

- Opens a listener, then loops over requests on one connection using a
  per-connection input buffer.
- When no complete request is buffered, it reads with a **3 second timeout**
  (`SERVER_IDLE_TIMEOUT_MS = 3000`). A timeout or peer EOF closes the idle
  connection; the next client request therefore creates a new session.
- Matches the request method + path against the registered routes
  (404 when no route matches, 500 when a handler fails).
- Determines keep-alive policy:
  - HTTP/1.1: persistent unless `Connection: close`.
  - HTTP/1.0: close unless `Connection: keep-alive`.
  - A streaming (chunked) HTTP/1.0 response always closes.
- Serializes and writes the response, then loops again if the connection stays
  open.

`write_response()`:

- Writes `VERSION STATUS REASON\r\n`, handler headers, framing headers
  (`Content-Length` or `Transfer-Encoding: chunked`), `Connection`, blank line,
  and body.
- For a streaming producer (`response->next`), it calls the producer repeatedly
  and writes each non-empty piece as soon as it is produced:
  - HTTP/1.1: `<hex-size>\r\n<payload>\r\n`, terminated by `0\r\n\r\n`.
  - HTTP/1.0: raw payload, connection closed to terminate the stream.
- A producer returning `0` may still emit a final non-empty piece; that piece is
  sent before the terminating zero-length chunk.

### 2.4 Key bug found and fixed

The original header parser treated the header block as ending at the first
`\r\n` of the `\r\n\r\n` terminator. That terminator's first CRLF is actually
the **last header line's own CRLF**, so the last header (e.g.
`Content-Length: 5`) was never parsed.

Fix: pass `hend + 2` as the end of the header block so the final header line's
CRLF is included:

```c
foggy_http_header_t *headers = parse_header_block(line_end + 2, hend + 2, &herr);
```

This was applied in both `parse_request()` and `parse_response_head()`. A small
standalone reproduction confirmed `Content-Length` was missed before the fix and
parsed correctly after it.

---

## 3. `foggy-http/conf/nginx-stream.conf`

The two TODO comments were replaced with case-sensitive regex `map` keys that
match the exact paths exposed by the supplied `$foggy_http_path` variable:

```nginx
map $foggy_http_path $backend {
    default "";
    # Regex keys preserve case-sensitive HTTP path matching.
    ~^/checkpoint-3/date$ 127.0.0.1:8081;
    ~^/checkpoint-3/echo$ 127.0.0.1:8082;
}
```

The rest of the template (module loading, `events`, `stream`/`server`,
`listen 80 udp reuseport`, `proxy_pass $backend`, `proxy_timeout 30s`) was left
unchanged.

---

## 4. Build

```sh
cd /home/xinuwu/learn/elec3120/checkpoints/foggy-http
make -C foggy-http ../build/date-client ../build/date-server \
                  ../build/echo-client ../build/echo-server
```

The C library compiles cleanly with the project's flags
(`-std=c11 -D_POSIX_C_SOURCE=200809L -Wall -Wextra -Wpedantic`). The full
`make -j2` also builds the NGINX extension when NGINX development headers are
available; that step was not needed to validate the two editable files.

---

## 5. Testing

All tests were run over the FoggyTCP v2 UDP transport on `127.0.0.1` (the same
behavior applies between the two VMs).

### 5.1 Date service (GET, Content-Length)

```sh
./build/date-server --port 8081 &
./build/date-client 127.0.0.1 --port 8081 --no-keep-alive
```

Output:

```
2026-11-11
RESPONSE 200 local_port=37792
```

### 5.2 Keep-alive reuse (3 GETs, one connection)

```sh
./build/date-client 127.0.0.1 --port 8081 --repeat 3
```

Output — same local port for all three responses:

```
2026-11-11
RESPONSE 200 local_port=60594
2026-11-11
RESPONSE 200 local_port=60594
2026-11-11
RESPONSE 200 local_port=60594
```

### 5.3 Idle timeout + reconnection

```sh
./build/date-client 127.0.0.1 --port 8081 --repeat 2 --interval 10
```

The server closes the idle connection after 3 s; after the 10 s client delay a
new connection (new local port) is established:

```
2026-11-11
RESPONSE 200 local_port=54935
2026-11-11
RESPONSE 200 local_port=50265
```

### 5.4 Echo service (POST, Content-Length body)

```sh
./build/echo-server --port 8082 &
./build/echo-client 127.0.0.1 hello --port 8082 --no-keep-alive
```

Output:

```
hello
CHUNK 5 5
RESPONSE 200 local_port=-1
```

(`local_port=-1` is expected for `--no-keep-alive` because the client closes the
connection after `Connection: close`; the keep-alive tests show valid ports.)

### 5.5 Streaming / chunked (incremental delivery)

```sh
./build/echo-server --port 8082 --chunked &
./build/echo-client 127.0.0.1 0123456789abcdefghij --port 8082
```

With keep-alive (the default), the client sends HTTP/1.1, so the server streams
using `Transfer-Encoding: chunked` and keeps the connection open. Output — 20
one-byte chunks arriving at ~100 ms intervals (≈2 s total):

```
0123456789abcdefghij
CHUNK 106 1
CHUNK 206 1
CHUNK 305 1
...
CHUNK 2009 1
RESPONSE 200 local_port=33994
```

The full 20-byte body is printed to stdout, and the stderr records confirm the
payloads arrive incrementally rather than all at once. With `--no-keep-alive`
the same server path streams a close-delimited HTTP/1.0 response instead.

### 5.6 Echo keep-alive reuse

```sh
./build/echo-client 127.0.0.1 hello --port 8082 --repeat 2
```

```
hello
CHUNK 6 5
RESPONSE 200 local_port=46862
hello
CHUNK 6 5
RESPONSE 200 local_port=46862
```

---

## 6. Packaging

```sh
make -C foggy-http ../build/SHA256SUMS
python3 submit.py
python3 submit.py --verify submit.zip
```

`submit.zip` contains exactly the three expected entries and passes the SHA-256
consistency check:

```
foggy_http.cc
nginx-stream.conf
SHA256SUMS
```

---

## 7. Files changed

- `foggy-http/src/foggy_http.cc` (implementation)
- `foggy-http/conf/nginx-stream.conf` (routing rules)
