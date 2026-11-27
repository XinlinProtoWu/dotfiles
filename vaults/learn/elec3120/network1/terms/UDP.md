# UDP — User Datagram Protocol

**What it is.** The minimal transport protocol: it adds *ports* (so several
programs can share one host) and a checksum, and nothing else. No handshake, no
retransmission, no ordering.

**Why it exists.** For traffic that prefers speed over reliability — DNS queries,
VoIP, video — a lost packet is better than a late one.

**Where it appears:** [[05_Transport_Model]] · [[16_Wireless]] Sections 7.9, 8

**Related:** [[terms/TCP]] · [[terms/IP]] · [[terms/DNS]] · [[terms/VoIP]]
