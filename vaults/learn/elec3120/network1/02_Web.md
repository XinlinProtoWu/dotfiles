# 02 — The Web & HTTP

> Source: `02-Web.pdf`. Goal: how a page loads, and how HTTP evolved to avoid **head-of-line (HOL) blocking**.

## 1. Context: application layer and sockets

- The **application layer** is what users see: Web, video, email, games, messaging.
- A host runs many application **processes**; the transport layer must deliver to the right one.
- A **socket** is the software abstraction an application uses to exchange messages with the transport layer/OS.
  - UDP socket: `SOCK_DGRAM` → `sendto()` / `recvfrom()`
  - TCP socket: `SOCK_STREAM` → `send()` / `recv()`
- Transport layer provides **process-to-process** delivery (via ports), while the network layer only provides **host-to-host** delivery.

### URL and HTML (how hypertext is enabled)

- **URL** = Uniform Resource Locator: names a resource by
  - **scheme** (e.g. `https`),
  - **authority/host** (e.g. `www.example.com`),
  - **path** to the resource,
  - optional query/fragment.
- **HTML** is the language that displays text, images, and hyperlinks.
- One “single web page” actually loads **many files**: images, CSS, JavaScript, fonts, videos.
  - These often come from **many different domains**.
  - Example from the slides: 10% of website home pages use **more than 58 different domains**.

---

## 2. HTTP basics

### Client-server, synchronous, stateless

- **Client-server architecture**: the server is always-on and well-known; the client initiates contact.
- **Synchronous request/reply**: client sends a request, server sends a response.
- **Stateless**: each request-response pair is independent; the server is not required to remember previous requests.
  - **Good**: easier failure handling, higher request rate, order of requests doesn't matter, scales well.
  - **Bad**: applications that need state (shopping cart, profiles, authentication) must store it elsewhere.
- State is pushed **elsewhere**:
  - **Client side**: cookies — browser stores an identifier/token and sends it with each request.
  - **Server side**: a database keyed by the cookie.

### HTTP is plain-text and variable-length

- HTTP messages are readable plain text.
- There are no fixed byte offsets; messages are variable-length.
- Trade-off: more complex parsing, but easier for humans to reason about and very extensible.

### Request message

![[02-Web.pdf#page=35]]
*Figure: HTTP request message — request line, header lines, blank line (CRLF), optional body. (`02-Web.pdf` p. 35)*

```http
GET /somedir/page.html HTTP/1.1
Host: www.someschool.edu
User-Agent: Mozilla/4.0
Connection: close
Accept-language: fr

```

- **Request line**: method, resource, protocol version.
- **Headers**: provide information or modify the request.
- **Body**: optional data (e.g. POST data).

### Response message

![[02-Web.pdf#page=36]]
*Figure: HTTP response message — status line, headers, blank line, body. (`02-Web.pdf` p. 36)*

```http
HTTP/1.1 200 OK
Connection: close
Date: Thu, 06 Aug 2006 12:00:15 GMT
Server: Apache/1.3.0 (Unix)
Last-Modified: Mon, 22 Jun 2006 ...
Content-Length: 6821
Content-Type: text/html

data data data ...
```

- **Status line**: protocol version, status code, status phrase.
- **Response headers**: metadata about the response.
- **Body**: optional requested data (e.g. HTML file).

---

## 3. HTTP/1.0 performance

### Response time per object

![[02-Web.pdf#page=34]]
*Figure: HTTP/1.0 response time = 2 RTT + file transmission time. (`02-Web.pdf` p. 34)*

For **one object**:

```text
HTTP/1.0 response time = 2 RTT + file transmission time
```

- **1 RTT** to initiate the TCP connection (handshake).
- **1 RTT** for the HTTP request and the first few bytes of the response.
- Then the **file transmission time** (depends on file size and bandwidth).

### Why page load time matters

- ~100 ms is often cited as the limit of human perception: below that, it feels “instant.”
- An oft-cited Amazon statistic: every extra **100 ms** of page load time (PLT) cost ~**1%** in profit.

### Many objects → many connections

Most pages have multiple objects (HTML + embedded images, CSS, JS).

Naive HTTP/1.0 approach: **one TCP connection per object**.

![[02-Web.pdf#page=44]]
*Figure: HTTP performance problem — one GET per TCP connection, lots of handshakes. (`02-Web.pdf` p. 44)*

**RTT quick check** (from the slides): a page has `n` files, each fitting in one packet, one request per file.

| Setup | RTTs |
|---|---|
| No persistent connections | `3n` |
| Persistent connections | `n + 2` |

Interpretation: non-persistent counts connection setup + request/response + teardown per object; persistent counts one setup + `n` request/response rounds + one teardown. (The exact count depends on whether teardown is included, but these are the slide answers.)

---

## 4. Persistent connections and pipelining

### Persistent connections

![[02-Web.pdf#page=46]]
*Figure: HTTP with a persistent connection — multiple requests over one TCP connection. (`02-Web.pdf` p. 46)*

- Keep the TCP connection open across multiple requests (including subsequent transfers for the current page).
- Client or server can tear it down when done.
- **Benefits**:
  - Avoid connection setup/teardown overhead.
  - Reuse previously discovered network conditions (e.g. known bandwidth, cwnd).
- Still one request at a time unless we add **pipelining**.

### Pipelining

![[02-Web.pdf#page=50]]
*Figure: Pipelined requests — send the next request before the previous response returns. (`02-Web.pdf` p. 50)*

- Don't wait for the previous response before sending the next request.
- Send a series of requests; the server responds **in order**.
- Keeps the pipe full → better utilization.

**Problem**: pipelining only works well if objects are immediately available. If the **first** object is slow to produce, everything behind it waits.

---

## 5. Head-of-line (HOL) blocking

### Definition

> **HOL blocking**: when the task at the **head** of a queue cannot be served, all tasks behind it must wait — even though the system could be doing useful work.

- The system is **not work-conserving**: it is idle even though work is waiting.
- This is a general systems idea: it appears in networks, databases, OS scheduling, etc.

![[02-Web.pdf#page=52]]
*Figure: HOL blocking definition. (`02-Web.pdf` p. 52)*

![[02-Web.pdf#page=58]]
*Figure: HOL blocking example — the pipe sits empty while the server waits on a slow backend. (`02-Web.pdf` p. 58)*

---

## 6. Generation 1: parallel TCP connections

![[02-Web.pdf#page=67]]
*Figure: concurrent requests/responses over parallel TCP sessions. (`02-Web.pdf` p. 67)*

- Open **multiple TCP connections in parallel**.
- Speeds up retrieval by roughly `m` with `m` connections.
- Does **not** preserve response order.
- **Partially** deals with HOL blocking: a stalled object on one connection doesn't block objects on other connections.

**Why not a full fix?**

- Each connection still has its own HOL blocking.
- More connections = more handshakes and more competing flows.
- The client still cannot force a server to prioritize a slow object.
- Parallel connections can be unfair to other users and increase congestion.

---

## 7. Generation 2: HTTP/2 streams

![[02-Web.pdf#page=70]]
*Figure: HTTP/2 avoids application-layer HOL blocking by interleaving streams. (`02-Web.pdf` p. 70)*

- Still uses **one persistent connection** for multiple requests.
  - Fewer handshakes.
  - More traffic allowed in the pipe, letting the underlying congestion window grow.
- Each request/response pair becomes a **stream** with a **Stream ID**.
- The server may send responses for different streams **out of order**.
  - “Fast” objects can be sent immediately while a “slow” object is still being produced.
- HTTP headers are **compressed**, reducing header overhead.
- HTTP/2 **PUSH is deprecated** — it was not successful.

### The catch: HTTP/2 fixes Layer 7, not Layer 4

![[02-Web.pdf#page=86]]
*Figure: a missing TCP packet for Stream 1 prevents the client from reading Stream 2, even though HTTP/2 can reorder streams. (`02-Web.pdf` p. 86)*

TCP still delivers **one ordered byte stream**. If a TCP segment is lost, all later bytes — including bytes belonging to other HTTP/2 streams — are stuck in the receive buffer until the missing segment arrives.

So:

- HTTP/2 solves **application-layer HOL blocking**.
- HTTP/2 does **not** solve **transport-layer (TCP) HOL blocking**.

---

## 8. Generation 3: HTTP/3 over QUIC/UDP

![[02-Web.pdf#page=87]]
*Figure: HTTP/3 — persistent connections, pipelining, and reorderable streams over UDP/QUIC. (`02-Web.pdf` p. 87)*

- HTTP/3 = persistent connections + pipelining + **independent, reorderable streams** — all over **UDP**.
- QUIC (Quick UDP Internet Connections) provides reliability **per stream**, so a lost packet for one stream does not block other streams.
- Allows the application to pull data for a stream as soon as **that stream's** data is complete, even if another stream lost data.
- QUIC was standardized in **2021** (RFC 9000).

---

## 9. HTTP evolution summary

| Generation | Mechanism | What it fixes | What still hurts |
|---|---|---|---|
| HTTP/1.0 | one TCP connection per object | simplicity | many handshakes, slow |
| HTTP/1.1 persistent | keep TCP open | setup/teardown overhead | one request at a time |
| HTTP/1.1 pipelining | send requests back-to-back | pipe utilization | application-layer HOL |
| Parallel TCP | `m` connections | partial HOL bypass | handshakes, unfairness, competition |
| HTTP/2 | streams over one TCP connection | application-layer HOL | TCP-layer HOL |
| HTTP/3 | streams over QUIC/UDP | TCP-layer HOL | deployment, UDP blocking |

> [!important] The big lesson
> The same ideas — **pipelining, parallelism, out-of-order processing** — recur throughout computer systems. The winning design is often the simple, backward-compatible, easy-to-scale one (“worse is better”), not the tightly integrated, highly optimized one.

---

## 10. Key terms

| Term | Meaning |
|---|---|
| **RTT** | Round-trip time: client → server → client |
| **PLT** | Page load time |
| **HOL blocking** | Head task cannot be served → everything behind it waits |
| **Work-conserving** | Never idle while work is waiting |
| **Stream** | HTTP/2 request/response pair with an ID |
| **QUIC** | Reliable, multiplexed transport over UDP; basis of HTTP/3 |
| **Cookie** | Client-side state token sent with requests |
