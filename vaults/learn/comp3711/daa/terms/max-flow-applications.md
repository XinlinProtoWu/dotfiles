# Max-flow applications (circulation, disjoint paths, baseball)

**What it is.** A collection of reductions that turn combinatorial problems into maximum flow:

| Problem | Construction |
|---|---|
| Circulation with demands | super-source to each supply, each demand to super-sink; feasible iff max flow = total demand |
| Edge-disjoint paths | capacity 1 on every edge; max flow = max number of paths |
| Bipartite matching | unit capacities from $s$ through $X\to Y$ to $t$ |
| Feasible/balanced assignment | capacities on facility-to-sink edges encode quotas |
| Baseball elimination | game nodes capacity 1, team-to-sink capacity = allowed extra wins |

**Why it exists.** A single max-flow solver then answers many unrelated-looking questions. The
integrality property is what makes the flow correspond to whole paths, whole matches and whole
game outcomes.

**Example.** In the deck's second baseball table, team 4 can reach 3 wins; teams 1, 2, 3 have
allowances 0, 1, 1 (total 2) but three remaining games among them must be assigned, so max flow is
2, not 3, and team 4 is eliminated.

**Where it appears:** [[lec_19_max_flow]] Section 8

**Related:** [[terms/max-flow]] · [[terms/bipartite-matching]] · [[terms/Ford-Fulkerson]] · [[terms/s-t-cut]]
