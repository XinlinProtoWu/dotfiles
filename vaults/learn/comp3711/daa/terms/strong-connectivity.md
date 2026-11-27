# Strong connectivity and SCCs

**What it is.** In a digraph, $u,v$ are mutually reachable if each reaches the other; the graph is
strongly connected if every pair is. A strongly connected component (SCC) is a maximal set of
mutually reachable vertices. Test: pick any $s$, BFS in $G$, BFS in the reversed graph, all nodes
reached both times. SCCs: repeatedly intersect "reachable from $u$" with "reaches $u$", output,
delete — $O(\lvert V\rvert\lvert E\rvert)$.

**Why it exists.** Directed reachability is not symmetric, so "connected" splits into a weak
(ignoring direction) and a strong notion. SCCs are the "irreducible loops" of a digraph and
condensing them turns any digraph into a DAG.

**Example.** Edges $1\to2, 2\to3, 3\to1, 3\to4, 4\to5, 5\to4$: SCCs are $\{1,2,3\}$ and $\{4,5\}$.
Node 3 is the bridge between them but still belongs to the first component.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 5–6

**Related:** [[terms/BFS]] · [[terms/DAG]] · [[terms/graph]]
