# DNS — Domain Name System

**What it is.** The Internet's naming system: it maps human-readable names to IP
addresses, using a hierarchy of servers (root → top-level domain → authoritative).

**Why it appears in these lectures.** It is the canonical example of a tiny
request/response transaction — one that is dominated by **round trips**, so
connection setup cost matters enormously (circuit setup, TCP handshake, ARP).

**Where it appears:** [[10_IP]] · [[15_Link_Layer]] Section 6 · [[16_Wireless]] Section 7.9

**Related:** [[terms/IP]] · [[terms/UDP]] · [[terms/HTTP]]
