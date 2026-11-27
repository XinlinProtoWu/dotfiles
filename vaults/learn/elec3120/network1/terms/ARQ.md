# ARQ — Automatic Repeat reQuest

**What it is.** Any scheme that detects a missing unit and asks for it again:
send, wait for an [[terms/ACK]], retransmit on timeout or on a duplicate ACK.

**Why it appears in the wireless lecture.** Wireless loses frames to noise, not
to congestion. A link-layer ARQ recovers them quickly and locally, which avoids
making [[terms/TCP]] believe the network is congested and cut its window.

**Where it appears:** [[05_Transport_Model]] · [[16_Wireless]] Section 8

**Related:** [[terms/ACK]] · [[terms/TCP]] · [[terms/CSMA]]
