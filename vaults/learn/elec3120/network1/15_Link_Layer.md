# 15 — Link State Routing and Link Layer Challenges

> Source: `15-Link_Layer.pdf`. Two halves:
> 1. **Link State** routing, in practice **Open Shortest Path First ([[terms/link-state|OSPF]])** — the routing algorithm that fixes **Distance Vector ([[terms/DV|DV]])**'s count-to-infinity, plus the data-plane/control-plane split.
> 2. **Link layer challenges** — circuit versus packet switching, statistical multiplexing, and multiple-access protocols, chiefly **Carrier Sense Multiple Access with Collision Detection ([[terms/CSMA|CSMA/CD]])**.
>
> Preceded by [[14_Distance_Vector]]; the wireless half of multiple access continues in [[16_Wireless]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Routing algorithms:** [[terms/link-state]] · [[terms/DV]] · [[terms/RIP]] · [[terms/STP]]

**Packets and applications:** [[terms/HTTP]] · [[terms/DNS]]

**Sharing the medium:** [[terms/CSMA]] · [[terms/multiplexing]]

**Architecture, units and notation:** [[terms/SDN]] · [[terms/units]]

## 1. Warm-up: how should `MAX_DIST` be chosen?

> Florbela runs the **Routing Information Protocol ([[terms/RIP]])**. She can set `MAX_DIST` to bound count-to-infinity.
> (a) What if it is **too high**? (b) What if it is **too low**? (c) What should it be?

![[15-Link_Layer.pdf#page=2]]
*Figure: the warm-up question and its network. (`15-Link_Layer.pdf` p. 2)*

**(a) Too high:** counting takes longer. Count-to-infinity increments the distance a little at a time, so the time to reach `MAX_DIST` is (roughly) proportional to `MAX_DIST`. Huge cap = effectively "count forever" = minutes of black-holed traffic after one link failure.

**(b) Too low:** a *legitimate* long path is treated as unreachable. The router advertises $\infty$ for a destination that is actually fine, so the network fragments even though the topology is intact. That is a correctness bug, not just a performance issue.

**(c) The right value:** the **largest legitimate simple path** in the network:

$$\text{MAX\_DIST} = (N-1)\;\cdot\;w_{\max}$$

for $N$ nodes and maximum link weight $w_{\max}$. A simple path can visit each node at most once, so it has at most $N-1$ hops; no real route can be longer than that. Just big enough to admit every real path, just small enough to bound the counting.

**Sanity check with RIP:** hop-count metric, $w_{\max} = 1$, and the Internet's diameter is conventionally capped at 15 — so RIP uses $\infty = 16$. Clean and round.

---

## 2. Link State (LS) routing, in practice OSPF: everyone gets the whole map

### In a nutshell (p. 4)

1. Everyone knows **who they are directly connected to**.
2. Every node **broadcasts** its own neighbour list (with link weights) to **every other node** in the network. This message is a **Link State Advertisement ([[terms/link-state|LSA]])**.
3. Every node therefore can — locally — reconstruct the **entire network graph**.
4. Each node runs a shortest-path algorithm on that graph.
5. Each node builds its own routing table from the result.

![[15-Link_Layer.pdf#page=5]]
*Figure: the topology each node must reconstruct. (`15-Link_Layer.pdf` p. 5)*

![[15-Link_Layer.pdf#page=6]]
*Figure: each node announces only its **own** links; flooding distributes them all. (`15-Link_Layer.pdf` p. 6)*

![[15-Link_Layer.pdf#page=7]]
*Figure: after flooding, every node can draw the same picture. (`15-Link_Layer.pdf` p. 7)*

This is called a **global view** — and note the huge structural difference from [[terms/DV]]:

| | Distance Vector | Link State |
|---|---|---|
| What is exchanged | my **distances** to all destinations | my **links** to my neighbours |
| What is revealed | results | topology |
| What you know after | neighbour's verdict | the whole map |

**Analogy.** DV is asking your neighbours "how far is the airport?" and trusting their answers. **Link State ([[terms/link-state|LS]])** routing is every junction posting a sign listing its own roads, so *you* can draw the map yourself and compute the best route.

### Dijkstra's algorithm

Finds shortest paths from one source to **all** destinations. Greedy: repeatedly finalise the closest not-yet-finalised node.

- Complexity: $O(\lvert E\rvert + \lvert V\rvert \log \lvert V\rvert)$ with a binary heap.
- Run **independently at each node** — `N` nodes ⇒ `N` runs, but they need no agreement with each other.

![[15-Link_Layer.pdf#page=10]]
*Figure: Dijkstra. (`15-Link_Layer.pdf` p. 10)*

### From shortest paths to a routing table

The routing table only needs **next hops**, not full paths:

| Destination | Next hop |
|---|---|
| B | B |
| C | C |
| D | B (because the path to D starts by going to B) |
| E | C |

![[15-Link_Layer.pdf#page=11]]
*Figure: Dijkstra's tree is flattened into "to X, forward to Y". (`15-Link_Layer.pdf` p. 11)*

### The four questions on slide 12

| Question | Answer |
|---|---|
| Is a router's global view always accurate? | **No** — it is accurate only *after* flooding converges. During a change, views are stale. |
| Are two routers' views always identical? | **No** — transiently they disagree; the point is that they *converge* to the same map. |
| Can LS suffer count-to-infinity? | **No.** Distances are recomputed from scratch by Dijkstra; nothing can ratchet upward. |
| Can packets loop in LS? | **Transiently yes** (stale tables during convergence), but there is no *stable* forwarding loop as in DV. |

> [!important] Why LS kills count-to-infinity
> DV's bug is **trusting a number you cannot verify**. LS never trusts a distance — it trusts only *link* facts, which are local and verifiable, then computes distances itself. **Distances are derived, never believed.**

---

## 3. The comparison table (the lecture's centrepiece)

![[15-Link_Layer.pdf#page=15]]
*Figure: the full DV versus LS comparison. (`15-Link_Layer.pdf` p. 15)*

| Criterion | Distance Vector (RIP) | Link State (LS) |
|---|---|---|
| **Resilience** | very slow recovery — count to infinity | re-run Dijkstra, done |
| **Fully distributed** | yes | yes |
| **State per node** (+ routing table) | $O(\#\text{switches} \times \max \deg)$ | $O(\#\text{edges})$ |
| **Convergence** | run DV first; takes length of longest best path | flood updates, then run Dijkstra: $O(\lvert E\rvert + \lvert V\rvert \log \lvert V\rvert)$ |
| **Routing efficiency** | packets sent directly to destination | packets sent directly to destination |
| **Shortest path?** | yes | yes |

**Why the state difference matters.** DV stores a distance *per destination* — the state grows with the number of destinations. LS stores one entry *per link* — the state grows with the topology, which in a real network is much smaller and much more stable. That is why LS scales to large domains.

**The cost LS pays:** every topology change must be **flooded to everybody**. DV only tells neighbours. LS trades bandwidth on change events for correctness and fast convergence.

![[15-Link_Layer.pdf#page=13]]
*Figure: the three-column view: broadcast, broadcast+[[terms/STP]], DV. (`15-Link_Layer.pdf` p. 13)*

---

## 4. Data plane versus control plane

Every switch/router has two halves:

| Plane | What it does | Analogy |
|---|---|---|
| **Data plane** (fast path) | On each packet: **read** the routing table, pick the port, send | The postal worker sorting letters |
| **Control plane** ("the brains") | Exchange routing updates, **decide** routes, **write** the routing table | Head office deciding the delivery routes |

![[15-Link_Layer.pdf#page=18]]
*Figure: control plane writes the table; data plane reads it. (`15-Link_Layer.pdf` p. 18)*

The **routing table** is the interface between the two planes: the control plane only ever *writes* to it, and the data plane only ever *reads* from it. That narrow contract is what lets them be built separately and by different teams.

**Why split them?** They have wildly different time scales: a packet must be forwarded in **nanoseconds**, while routing decisions are made in **seconds or minutes**. Separating them lets the fast path be pure hardware.

**Control-plane complexity** (slide 19):

- **DV:** "just select the `min` of all the updates I have heard from." Dumb-ish switch.
- **LS:** "rebuild the network topology, then run Dijkstra over it." Real computation.

**Simple example.** A switch with 48 ports forwards millions of packets a second (data plane, a memory read). Its control plane runs OSPF, which may wake up once a day when a cable is moved.

---

## 5. The link layer's real job: sharing

> The link layer turns bits into messages in a **local** network.

![[15-Link_Layer.pdf#page=21]]
*Figure: nodes and links — the link layer's world. (`15-Link_Layer.pdf` p. 21)*

Once there is more than one pair of nodes, the link layer is fundamentally about **resource sharing**. Two families of challenges:

1. **Packetization versus circuits** — how do we divide the channel in time?
2. **Multiple access** — when several nodes want to talk *at once*, who goes?

### Media vocabulary

| Medium | Meaning |
|---|---|
| **Broadcast** | everyone listening hears every transmission |
| **Unicast** | exactly one recipient |
| **Multicast** | multiple, but not all, recipients |

Classic Ethernet was a **broadcast medium**: one shared cable, everyone taps in ("vampire tap").

![[15-Link_Layer.pdf#page=23]]
*Figure: classic Ethernet — one shared cable, a genuine broadcast medium. (`15-Link_Layer.pdf` p. 23)*

Modern Ethernet is **switched**: each link has exactly two endpoints (host ↔ switch).

![[15-Link_Layer.pdf#page=25]]
*Figure: modern switched Ethernet — point-to-point links. (`15-Link_Layer.pdf` p. 25)*

Wireless is the hard case, because the medium really is shared and nobody can fence it off — see [[16_Wireless]].

---

## 6. Circuit switching

Used by the telephone network. Four phases:

1. **Reservation request** — caller asks for a path.
2. **Circuit establishment** — interior switches reserve capacity and wire up a path.
3. **Data transfer** — sender transmits at a guaranteed rate.
4. **Teardown** — release the circuit.

![[15-Link_Layer.pdf#page=28]]
*Figure: setup → data → teardown. (`15-Link_Layer.pdf` p. 28)*

### Pros

- **Guaranteed performance** — the capacity is reserved, so no other traffic can steal it.
- **Fast transfer once established** — no per-packet decisions, no queueing.

**Example from the slides:** reserve $1\,\text{Mbps}$ from $A$ to $B$, then push $500\,\text{MB}$ — mind the bits-versus-bytes trap in [[terms/units]].

$$
\begin{aligned}
500\,\text{MB} &= 500 \times 8 = 4000\,\text{Mbit} \\
\frac{4000\,\text{Mbit}}{1\,\text{Mbps}} &= 4000\,\text{s} \approx 1.1\ \text{hours}
\end{aligned}
$$

There is not a single interruption: the whole 500 MB flows at a constant rate.

![[15-Link_Layer.pdf#page=33]]
*Figure: once the circuit exists, transfer is continuous. (`15-Link_Layer.pdf` p. 33)*

### Cons

**(1) It wastes bandwidth if traffic is "bursty."**

![[15-Link_Layer.pdf#page=36]]
*Figure: "Here's a little bit of data… oh, here's a little bit of data…" — the switches are idle most of the time. (`15-Link_Layer.pdf` p. 36)*

Real computer traffic is a trickle of bursts separated by long silences (you click, then read for 30 s). A reserved circuit holds the capacity **even while idle** — and nobody else may use it.

**(2) Connection setup time is overhead.**

![[15-Link_Layer.pdf#page=42]]
*Figure: setup cost is paid before a single bit of data moves. (`15-Link_Layer.pdf` p. 42)*

If your transfer is 2 kilobytes, and setup takes 200 milliseconds, you spent almost all your time on setup. Terrible for the short request/response pattern of **Hypertext Transfer Protocol ([[terms/HTTP]])** and the **Domain Name System ([[terms/DNS]])**.

**(3) Recovery from failure is slow.**

![[15-Link_Layer.pdf#page=44]]
*Figure: an alternate path exists, but a whole new circuit must be set up. (`15-Link_Layer.pdf` p. 44)*

Because the state lives in the switches (Section 7 — packet switching keeps no per-connection state at all), a link failure requires re-running the reservation all the way through.

| Circuit switching | |
|---|---|
| **Pros** | guaranteed performance; fast bulk transfer once established |
| **Cons** | wastes bandwidth on bursty traffic; setup time overhead; slow failure recovery |

---

## 7. Packet switching

The Internet's choice. Data is chopped into **packets**:

- **header** — instructions for the network (addresses, protocol, and so on)
- **payload** — the data being carried

Think of the header as an **envelope**: `To: Alice / From: Professor Meng`; the payload is the letter.

![[15-Link_Layer.pdf#page=46]]
*Figure: header + payload. (`15-Link_Layer.pdf` p. 46)*

### How a switch handles a packet: store-and-forward

1. **Wait for the whole packet to arrive.**
2. Read the header.
3. Look up the destination in the forwarding table.
4. Re-send it on the next hop.

![[15-Link_Layer.pdf#page=49]]
*Figure: store-and-forward at each hop. (`15-Link_Layer.pdf` p. 49)*

Each packet travels **independently** — there is no notion of packets belonging to a circuit, so two packets of the same file may take different routes.

### The key property: no reservations, statistical multiplexing

No link capacity is reserved in advance. Links are shared **on demand**: whoever has a packet sends it, and everyone's traffic is mixed statistically.

![[15-Link_Layer.pdf#page=52]]
*Figure: no reservations — links are shared on demand. (`15-Link_Layer.pdf` p. 52)*

![[15-Link_Layer.pdf#page=53]]
*Figure: statistical multiplexing — three flows sharing one link as they arrive. (`15-Link_Layer.pdf` p. 53)*

### Worked example: why multiplexing wins

> A 1 Mbps link. **35** users. Each user, when active, needs **100 kbps**. Each user is active only **10%** of the time.

**Circuit switching** — must reserve $100\,\text{kbps}$ per user for the whole session:

$$\frac{1\,\text{Mbps}}{100\,\text{kbps}} = 10 \text{ users}$$

so users $11 \dots 35$ are refused service.

**Packet switching** — everyone shares, and pays a small risk of congestion:

$$
\begin{aligned}
\mathbb{E}[\text{active}] &= 35 \times 0.1 = 3.5 \text{ users} \\
\text{capacity} &= 10 \text{ simultaneously active users} \\
P(X > 10) &\approx 0.0004, \qquad X \sim \text{Binomial}(35,\, 0.1)
\end{aligned}
$$

So **35 users** get service, the average load is only 35% of capacity, and the chance of momentary overload is about **1 in 2400**. Circuit switching supported **10** users with a guarantee; packet switching supports **35** with a 99.96% guarantee.

That is the entire economic argument for packet switching.

![[15-Link_Layer.pdf#page=55]]
*Figure: the same idea as a recurring theme in **computer science (CS)** — shared versus reserved resources. (`15-Link_Layer.pdf` p. 55)*

> **Statistical multiplexing is a recurrent theme:** reserved clouds versus shared **virtual machines (VMs)**; owning a car versus Uber. Sharing is more efficient *when demand is bursty and uncorrelated*.

### The trade-off you accept

Free sharing means **contention**, and contention produces **queueing delay and drops** — the subject of [[07_Congestion_Control]] and [[09_Queue_Management]]. Circuits had no queues; packets have queues. You are trading *guarantees* for *efficiency*.

> [!important] One-line summary (slide 56)
> **Packetization lets multiple senders share network links — via statistical multiplexing — at fine granularity and without reservations.**

---

## 8. Modern wired Ethernet: full duplex

![[15-Link_Layer.pdf#page=57]]
*Figure: a full-duplex link — A and B transmit simultaneously in opposite directions. (`15-Link_Layer.pdf` p. 57)*

A switched Ethernet link has only **two** endpoints, and modern links are **full duplex**: both directions at once on separate wire pairs. `A→B` and `B→A` never interfere, so there is no "who goes first" problem at all.

That is why modern switched Ethernet needs **no** [[terms/CSMA|CSMA/CD]] for the common case. CSMA/CD exists for the *shared* (half-duplex) medium.

**But** if the medium is genuinely shared — classic Ethernet's cable, or radio — then two simultaneous senders are **two people shouting at once**: signal interference, garbled data.

![[15-Link_Layer.pdf#page=58]]
*Figure: wireless is the hard case — simultaneous senders interfere. (`15-Link_Layer.pdf` p. 58)*

---

## 9. Multiple Access Protocols

**The problem:** given a shared broadcast channel, prevent multiple nodes from speaking at once (collisions ⇒ garbled data). We need an algorithm deciding **who transmits when**.

Three classes (p. 60):

| Class | Idea | Examples |
|---|---|---|
| **Channel partitioning** | divide the channel into pieces | **Frequency Division Multiple Access (FDMA)** (frequency), **Time Division Multiple Access (TDMA)** (time) |
| **Taking turns** | coordinate who goes next | polling, token passing |
| **Random access** | allow collisions, then recover | **Carrier Sense Multiple Access (CSMA)**, CSMA/CD, CSMA/CA (Collision Avoidance) |

![[15-Link_Layer.pdf#page=60]]
*Figure: the three families. (`15-Link_Layer.pdf` p. 60)*

### (a) Taking turns

| Polling                                                                   | Token passing                                                      |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| A **leader** invites workers to transmit in turn                          | A **token** is passed node→node; you may send only when holding it |
| Concerns: polling overhead, latency, **single point of failure** (leader) | Concerns: token overhead, latency, **any node can hog the token**  |

![[15-Link_Layer.pdf#page=61]]
*Figure: polling (leader-driven) versus token passing (ring-driven). (`15-Link_Layer.pdf` p. 61)*

**Why not use these today?** (slide 62)

- They are **inefficient at low load** — a node with nothing to send still consumes its turn (idle slots are pure waste).
- Polling has a **single point of failure**.
- Token passing breaks when the token is **lost** (the whole ring stalls until a recovery protocol runs).
- Neither scales across a whole building.

**Simple example (the slide's ice-cream activity).** 5 people each must say two favourite flavours, with no leader and no going around in a circle. If two talk at once, it does not count and they must retry. Very quickly you discover you need some *random* rule — which is exactly random access.

![[15-Link_Layer.pdf#page=63]]
*Figure: the ice-cream activity — coordination without a leader. (`15-Link_Layer.pdf` p. 63)*

### (b) Random access

Rules:

- A node with a packet to send transmits at the **full channel rate** `R`.
- **No** a priori coordination.
- Two or more transmitting = **collision**.
- The protocol must specify how collisions are **detected** and **recovered** from (usually delayed retransmission).

![[15-Link_Layer.pdf#page=64]]
*Figure: random access — transmit freely, deal with collisions afterwards. (`15-Link_Layer.pdf` p. 64)*

**Why not "just send whenever you want"?** Too many collisions. **Why not "always take turns"?** Too much idle time. The elegant middle ground: **listen before you talk.**

![[15-Link_Layer.pdf#page=65]]
*Figure: the shared wire, and the "yak yak…" problem. (`15-Link_Layer.pdf` p. 65)*

---

## 10. Carrier Sense Multiple Access with Collision Detection (CSMA/CD) — Ethernet's multiple access

**Carrier Sense Multiple Access / Collision Detection**

| Component | What it means | Why |
|---|---|---|
| **Carrier Sense** | **Listen before you talk** | Cheap coordination: do not start if someone is already transmitting |
| **Multiple Access** | Many nodes share one medium | No central controller |
| **Collision Detection** | **Listen while you talk** | If you hear interference, **abort immediately** — saves the rest of the wasted transmission |

![[15-Link_Layer.pdf#page=66]]
*Figure: the three features of CSMA/CD. (`15-Link_Layer.pdf` p. 66)*

### The state machine

![[15-Link_Layer.pdf#page=67]]
*Figure: CSMA/CD flow — sense, send, detect, jam, back off, retry (max 16 attempts). (`15-Link_Layer.pdf` p. 67)*

1. **Sense** the carrier. Busy → wait, then sense again. Idle → go on.
2. **Send**, and keep listening while sending.
3. No interference → done.
4. Interference → **jam** the channel, compute the backoff $b$, wait $b$, increment the attempt counter.
5. Attempts $=16$ → discard the frame. Otherwise back to step 1.

**Why jam?** A colliding station stops quickly; without a jam signal the others might not notice until much later, wasting the whole frame time.

### After a collision: binary exponential backoff

> The delay is $K \times 512$ bit times, where $K$ is random.

| Collision number | `K` chosen from |
|---|---|
| 1st | `{0, 1}` |
| 2nd | `{0, 1, 2, 3}` |
| 3rd | `{0 … 7}` |
| … | … |
| 10th and later | `{0 … 1023}` |

At 10 Mbps, one **slot = 512 bit times = 51.2 µs**, so the 10th-collision maximum wait is `1023 × 51.2 µs ≈ 52 ms`.

**Why random, and why exponential?**

- **Random** — otherwise all colliding stations would wait the *same* time and collide again, forever (a livelock).
- **Exponential** — the range grows with the *observed* number of collisions, which is a proxy for the number of competing stations. More contention ⇒ wait longer. This is **adapting to load** and can be viewed as a form of **congestion control**.

**Simple example.** Two stations collide. Both pick `K` from `{0,1}`. Station A picks 0, B picks 1 → A transmits immediately, B waits 51.2 µs. Collision resolved. With 20 stations colliding, `K` ranges over 1024 slots, so the chance that two pick the same value is small.

> [!warning] "Detect" is essential
> Aborting early means the wasted time is proportional to the **collision detection time**, not the full frame. Without collision detection (as in wireless) the whole frame is wasted — see [[16_Wireless]].

---

## 11. Highlights (p. 69)

- Sharing/multiplexing network resources is hard.
- Modern networks use **packetization**, not circuits, enabling efficient sharing via **statistical multiplexing**.
  - Circuits pay **setup** overhead; packets pay **header** overhead.
- Packetization introduces **queueing delay and drops**.
- On a broadcast medium, interference must be managed:
  - **Carrier sense** = listen before transmit.
  - **Collision detection** — wired Ethernet.
  - **Collision avoidance** — Wi-Fi (next lecture).

> [!tip] Exam traps
> - **Circuit switching reserves; packet switching shares.** All the pros/cons follow from that one line.
> - Statistical multiplexing does **not** guarantee anything — it just makes overload *unlikely*.
> - **Store-and-forward** means the whole packet arrives before it is forwarded — this is why per-hop delay includes a full transmission time.
> - `MAX_DIST` too **low** is a correctness bug (real routes look infinite); too **high** is a performance bug (slow counting).
> - **LS state is $O(\#\text{edges})$, DV state is $O(\#\text{nodes} \times \deg)$** — LS scales better in state, worse in flooding.
> - Backoff range doubles until collision **10**, then caps at 1023 slots.
> - Full-duplex switched Ethernet needs no CSMA/CD — there is only ever one sender per direction.
