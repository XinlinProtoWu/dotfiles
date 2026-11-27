# Link State (LS) — and OSPF, LSA

**What it is.** A routing algorithm in which every node learns the **entire
network graph**, then computes shortest paths locally.

**LS vs. DV in one line.** A distance vector router is told *results* ("B is 3
away"); a link state router is told *facts* ("I am connected to C with weight 4")
and computes the results itself. **Distances are derived, never believed.**

**How it works.**

1. Every node knows its own direct links.
2. It floods a **Link State Advertisement (LSA)** — its neighbour list with
   weights — to *every* node, not just its neighbours.
3. Every node therefore reconstructs the full topology (a **global view**).
4. Every node runs **Dijkstra** on it: $O(\lvert E\rvert + \lvert V\rvert \log \lvert V\rvert)$.
5. It keeps only the next hop per destination, as a routing table.

**Why it fixes count to infinity.** Nothing can ratchet: the topology is
re-flooded and the distances are recomputed from scratch.

**The price.** Every topology change is flooded network-wide, and each node
stores $O(\lvert E\rvert)$ state plus does real computation in the control plane.

**OSPF** (*Open Shortest Path First*) is the standard link state protocol for
intradomain routing.

**Where it appears:** [[15_Link_Layer]] Sections 2, 3 · compared in [[14_Distance_Vector]] Section 10

**Related:** [[terms/DV]] · [[terms/RIP]] · [[terms/big-O]]
