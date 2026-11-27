# STP — Spanning Tree Protocol

**What it is.** A **distributed** protocol that disables some switch ports so
that a looped physical topology behaves like a single loop-free **tree**.

**Why it exists.** Switches flood unknown destinations out of every port except
the ingress port. In a loop, the same frame circulates forever and every traversal
multiplies the copies — a **broadcast storm** that saturates the LAN in
milliseconds. Loops are unavoidable in practice because they are how you build
redundancy.

**How it works.**

- Every bridge stores `(Root, Path Length, Next Hop)` and starts by claiming
  *itself* as root.
- The root is the bridge with the **lowest ID** (MAC address).
- Bridges exchange their records and adopt any record with a lower root ID, or an
  equal root ID with a shorter path; ties go to the lower-ID neighbour.
- Once converged, keep the port toward your parent (**root port**), keep ports
  where a *child* reaches you, and **block** everything else.

**Cost.** A spanning tree guarantees reachability but **not** shortest paths, and
every blocked port is bandwidth you paid for and cannot use. That inefficiency is
exactly why real networks use routing algorithms instead — see
[[terms/DV]] and [[terms/link-state]].

**Where it appears:** [[13_LAN]] Sections 10, 11 · [[14_Distance_Vector]] Section 1

**Related:** [[terms/LAN]] · [[terms/Ethernet]] · [[terms/DV]]
