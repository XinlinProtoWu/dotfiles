# CSMA — Carrier Sense Multiple Access, /CD and /CA

**What it is.** A family of **random-access** medium-sharing protocols. All three
start the same way: *listen before you talk*.

| Variant | Full name | Extra ingredient | Where |
|---|---|---|---|
| **CSMA** | Carrier Sense Multiple Access | listen, then send | generic |
| **CSMA/CD** | …with **Collision Detection** | listen *while* sending, abort early | wired Ethernet |
| **CSMA/CA** | …with **Collision Avoidance** | reserve the medium with RTS/CTS before sending | Wi-Fi |

**Why carrier sense at all.** Without it, everyone sends whenever they like and
collisions are constant. Listening costs nothing and removes most collisions.

**Why wired needs detection.** On a wire, a sender can hear interference while
transmitting, so it aborts immediately — the wasted time is the collision
*detection* time, not the whole frame.

**Why wireless cannot detect.** A radio cannot listen on the frequency it is
transmitting on; its own signal drowns everything. So Wi-Fi must **avoid**
collisions instead ([[terms/RTS-CTS]]) and infer them from a missing ACK.

**After a collision: binary exponential backoff.** After the $n$-th collision,
pick $K \in \{0, \dots, 2^{n}-1\}$ and wait $K \times 512$ bit times (capped at
$K \le 1023$). Randomness breaks ties; the growing range adapts to the load.

**Where it appears:** [[15_Link_Layer]] Sections 9, 10 · [[16_Wireless]] Sections 1–3

**Related:** [[terms/Ethernet]] · [[terms/RTS-CTS]] · [[terms/ACK]]
