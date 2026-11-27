# Depth first search (DFS)

**What it is.** Exploration that recurses into the first undiscovered neighbour and only returns
when that whole subtree is finished; implemented by recursion (an implicit LIFO stack). Nodes are
white/gray/black, where **gray = currently on the recursion stack**. Cost
$\Theta(\lvert V\rvert + \lvert E\rvert)$.

**Why it exists.** BFS gives distances; DFS gives *structure*: ancestor/descendant relations, the
finish order (reverse topological order), and certificates of cycles via back edges. Also uses
$\Theta(\lvert V\rvert)$ stack rather than a queue holding a whole layer.

**Example.** On the deck's undirected graph starting at $a$, the discovery order is
$a, b, f, c, d, e, i, k$; the edge $(i,b)$ is a back edge (to an ancestor, not the parent), and
the tree path $b \to e \to i$ plus $(i,b)$ is the cycle $b \to e \to i \to b$.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 9–13 · [[lec_15_graph_theory]] Section 5

**Related:** [[terms/BFS]] · [[terms/edge-classification]] · [[terms/DAG]] · [[terms/topological-sort]]
