# ELEC 3120 — Computer Networks I

Restructured notes for lectures 02–16. Each lecture note embeds the relevant PDF page for diagrams.

> [!info] PDF page links
> `![[02-Web.pdf#page=34]]` means **PDF page 34**, which may differ from the printed slide number.

> [!info] Term definitions
> Each note opens with a `## 0. Terms` block of links into `terms/`. Definitions live there, once per term, and backlink the lectures that use them — so `[[terms/STP]]` is the single explanation of a spanning tree, not four slightly different ones.

## Lectures

| # | Note | Main ideas |
|---|------|------------|
| 02 | [[02_Web]] | HTTP, persistent connections, pipelining, HOL blocking, HTTP/2 streams, HTTP/3/QUIC |
| 03 | [[03_Video]] | progressive download, buffering, MBR/ABR, DASH, BBA-0 |
| 05 | [[05_Transport_Model]] | mux/demux, UDP, stop-and-wait, sliding windows, GBN, selective repeat |
| 06 | [[06_TCP_Basics]] | RTT estimation, TCP header, handshake/teardown, flow control, BDP |
| 07 | [[07_Congestion_Control]] | queues, AIMD, Reno, slow start, fast recovery, Mathis, CUBIC |
| 08 | [[08_Advanced_Congestion_Control]] | Reno's limits, RTT unfairness, Jain's index, alternatives |
| 09 | [[09_Queue_Management]] | max-min fairness, fair queueing, WFQ, token buckets, network calculus |
| 10 | [[10_IP]] | Cerf–Kahn challenges, host/port, DNS hierarchy, zones, root/anycast, resolution, RRs, caching |
| 11 | [[11_BGP]] | classful/CIDR, longest prefix match, subnetting, NAT, AS policy, BGP path vector and attributes |
| 12 | [[12_Internetworking]] | five-layer model, encapsulation, narrow waist, OSI, end-to-end argument, firewalls |
| 13 | [[13_LAN]] | MAC addresses, Ethernet frame, ARP/DHCP, broadcast, learning switches, broadcast storms, spanning tree |
| 14 | [[14_Distance_Vector]] | distance vectors, Bellman–Ford, convergence, count to infinity, poison reverse, max path length |
| 15 | [[15_Link_Layer]] | link state/OSPF, Dijkstra, data vs control plane, circuit vs packet switching, statistical multiplexing, CSMA/CD |
| 16 | [[16_Wireless]] | collision detection limits, hidden/exposed terminals, CSMA/CA, RTS/CTS, 802.11, Bluetooth, 4G/5G, mobility |
| — | [[99_Cheat_Sheet]] | compact formula/definition sheet for revision |
| — | `terms/` | one file per term; every note links its terms here (36 files) |

## Concept dependency

```text
HTTP (02) ──► why transport matters
Video (03) ──► buffering + ABR
        │
        ▼
Transport (05) ──► UDP vs TCP, reliability, windows
        │
        ▼
TCP basics (06) ──► header, handshake, flow control, BDP
        │
        ▼
Congestion control (07) ──► AIMD, Reno, CUBIC
        │
        ▼
Advanced CC (08) ──► fairness, RTT unfairness, alternatives
        │
        ▼
Queue management (09) ──► in-network fairness, token buckets, network calculus
        │
        ▼
IP + DNS (10) ──► naming, addressing, DNS hierarchy
        │
        ▼
IP addressing + BGP (11) ──► CIDR, NAT, AS policy, interdomain routing
        │
        ▼
Internetworking (12) ──► layering, encapsulation, end-to-end argument
        │
        ▼
LAN (13) ──► MAC, frames, ARP/DHCP, learning switch, spanning tree
        │
        ▼
Distance Vector (14) ──► shortest paths to every destination, count to infinity
        │
        ▼
Link State (15) ──► global view + Dijkstra; circuit vs packet; CSMA/CD
        │
        ▼
Wireless + Mobility (16) ──► CSMA/CA, RTS/CTS, 802.11, home/visited networks
```

## Formula sheet

| Concept | Formula |
|---|---|
| Transmission delay | `data size / link bandwidth` |
| Queueing delay | `bits ahead in queue / link bandwidth` |
| Bandwidth-delay product | `BDP = bandwidth × RTT` |
| HTTP/1.0 per-object time | `2 RTT + file transmission time` |
| TCP RTT estimate | `EstimatedRTT = (1−α)·EstimatedRTT + α·SampleRTT`, `α = 0.125` |
| TCP deviation | `DevRTT = (1−β)·DevRTT + β·|SampleRTT − EstimatedRTT|`, `β = 0.25` |
| TCP timeout | `TimeoutInterval = EstimatedRTT + 4·DevRTT` |
| TCP average throughput | `≈ 3W / (4·RTT)` |
| Mathis bound | `BW < (MSS/RTT)·(1/√p)` |
| CUBIC window | `W(t) = C(t−K)³ + W_max`, `K = ∛(W_max·β/C)` |
| Jain fairness index | `F = (Σxᵢ)² / (n·Σxᵢ²)` |
| Max-min allocation | `aᵢ = min(f, rᵢ)` with `Σaᵢ = C` |
| Token-bucket envelope | `A(t) = b + r·t` |
| WFQ finish time | `F = S + p·(Σwᵢ)/w_q` |
| CIDR host bits | `2^h ≥ needed hosts`; prefix length `= 32 − h` |
| Usable hosts in an IPv4 prefix | `2^(32−p) − 2` |
| NAT mapping | rewrite `(private IP, private port)` ↔ `(public IP, NAT port)` |
| MAC address space | `2^48` |
| Min Ethernet frame | `64 bytes` (46-byte payload + headers), `512` bit slot time at 10 Mbps |
| CSMA/CD backoff | `K ∈ {0 … 2^n − 1}` capped at `{0 … 1023}`; delay `= K × 512` bit times |
| Collision detection condition | `min packet time > 2 × max propagation delay` |
| Distance vector update | `d(x,y) = min over neighbours v of [ w(x,v) + d(v,y) ]` |
| DV convergence (sync rounds) | round `k` ⇒ best `(k+1)`-hop paths |
| RIP infinity | `MAX_DIST = 16` (max useful path = 15 hops) |
| Safe `MAX_DIST` | `(N − 1) × w_max` |
| Dijkstra complexity | `O(|E| + |V| log |V|)` |
| Circuit-switched transfer time | `data × 8 / reserved rate` (e.g. 500 MB at 1 Mbps ≈ 1.1 h) |
| Stat. multiplexing overload risk | `P(X > capacity)` with `X ~ Binomial(N users, activity prob.)` |

## High-yield exam traps

- **Bits vs bytes** in BDP, Mathis, and throughput calculations.
- **RTT is round-trip**, not one-way delay.
- **Slow start is fast** (doubling per RTT); congestion avoidance is the slow `+1` phase.
- **Duplicate ACKs** = single loss → fast retransmit/fast recovery. **Timeout** = severe loss → slow start.
- **Flow control** protects the receiver (`advertised window`). **Congestion control** protects the network (`cwnd`).
- **Cumulative ACK** is robust to ACK loss; **SACK** tells the sender exactly what arrived.
- **Max-min fairness** is not equal shares; it maximizes the minimum allocation.
- **Token bucket** limits the average rate to `r` but allows bursts up to `b`.
- **Longest prefix match** picks the most specific matching route, not the largest prefix value.
- **NAT** rewrites both address and port, and must keep state consistent for the session.
- **BGP** is a path-vector, policy-based protocol; it does not optimize for shortest latency.
- **End-to-end argument**: put complete correctness at the endpoints; lower-layer versions are only performance optimizations.
- **Ethernet destination is per-hop; IP destination is end-to-end.**
- **MAC = 48 bits (hex); IP = 32 bits (dotted decimal).** ARP resolves IP→MAC; DHCP assigns IP + gateway + netmask.
- Learn from the **source**, forward by the **destination** in a learning switch.
- A spanning tree is loop-free but **not** shortest-path; root = **lowest** bridge ID.
- **DV counts to infinity on bad news** (a link getting *more expensive* is as bad as a failure).
- **Poison reverse only fixes 2-node loops**; longer cycles still count to infinity.
- **LS state is `O(#edges)`, DV state is `O(#nodes × degree)`.**
- **Circuit = reserved, packet = shared.** Statistical multiplexing makes overload *unlikely*, not impossible.
- **Collision detection is impossible in radio** (own signal drowns the channel) — hence CA not CD.
- **Collisions happen at the receiver.** RTS covers nodes near the sender, CTS covers nodes near the receiver — **CTS** is what fixes the *hidden* terminal. The *exposed* terminal (needless deferral) stays unfixed.
- The `2` in `min packet time > 2 × prop delay` is the **round trip**.
- **IMSI = identity, IP = location.** Indirect routing is transparent but triangular; direct is efficient but non-transparent.
- **Wireless loss ≠ congestion**, so TCP cuts `cwnd` unnecessarily over wireless.
