# HTTP — Hypertext Transfer Protocol

**What it is.** The application protocol of the web: a client sends a request
(method, path, headers), a server sends a response (status, headers, body).

**Why it appears in these lectures.** It is the workload that exposes *why* link
and transport design matter: HTTP traffic is many small request/response
exchanges, so setup cost (TCP handshake, circuit establishment, ARP) dominates,
and lost packets hurt.

**Where it appears:** [[02_Web]] · [[15_Link_Layer]] Section 6 · [[16_Wireless]] Section 7.3

**Related:** [[terms/TCP]] · [[terms/DNS]]
