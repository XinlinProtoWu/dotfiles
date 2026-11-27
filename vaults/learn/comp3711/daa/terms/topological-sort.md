# Topological sort

**What it is.** A linear order of a DAG's vertices such that every edge $u \to v$ has $u$ before
$v$. Kahn's algorithm: repeatedly output a vertex of in-degree 0 and delete its out-edges, keeping
the sources in a queue. $\Theta(\lvert V\rvert + \lvert E\rvert)$.

**Why it exists.** It answers "in what order can these dependent tasks run?" and, for free, "does
this digraph have a cycle?" — if the queue empties before all vertices are output, the remainder
contains a cycle.

**Example.** Deck's 10-node DAG: only node 0 has in-degree 0, so the output starts $0$; nodes
6, 1, 4 then become available, giving one order $0,6,1,4,3,2,5,7,8,9$. Another valid order is
$0,4,1,6,2,5,3,7,8,9$.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 13

**Related:** [[terms/DAG]] · [[terms/DFS]] · [[terms/queue]]
