# TCP — Transmission Control Protocol

**What it is.** The reliable, connection-oriented transport protocol: it numbers
bytes, acknowledges them cumulatively, and adapts its sending rate.

**Why it appears in the wireless lecture.** TCP's congestion control assumes
**loss = congestion**, and cuts its window when it sees loss. Over radio, loss is
often just noise. TCP therefore slows down for no reason — the classic
cross-layer conflict in [[16_Wireless]] Section 8.

**Where it appears:** [[06_TCP_Basics]] · [[07_Congestion_Control]] · [[16_Wireless]] Sections 7.9, 8

**Related:** [[terms/UDP]] · [[terms/ACK]] · [[terms/IP]]
