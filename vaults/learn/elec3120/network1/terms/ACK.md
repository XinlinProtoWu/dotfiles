# ACK — acknowledgement

**What it is.** A short control frame (or segment) confirming that something
arrived.

**Why it matters in these lectures.** Wireless cannot *detect* collisions, so it
**infers** them: if no ACK comes back, assume the frame was lost and retransmit
with exponential backoff. The ACK is the only feedback loop the link layer has.

**In Ethernet.** An ACK also appears at the end of the RTS/CTS exchange, and
tells every node that the reserved medium is free again.

**At the transport layer** (see [[terms/TCP]]) the ACK is cumulative: it names the
next byte expected.

**Where it appears:** [[13_LAN]] Section 3 · [[16_Wireless]] Section 3

**Related:** [[terms/CSMA]] · [[terms/RTS-CTS]] · [[terms/TCP]] · [[terms/ARQ]]
