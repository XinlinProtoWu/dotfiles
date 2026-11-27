# Breadth first search (BFS)

**What it is.** Exploration of a graph from a source $s$ using a FIFO **queue**, discovering nodes
one *layer* at a time: $L_0 = \{s\}$, $L_{i+1}$ = undiscovered nodes adjacent to $L_i$. Each node
stores `color` (white/gray/black), `d` (distance from $s$) and `p` (parent). Cost
$\Theta(\lvert V\rvert + \lvert E\rvert)$ with adjacency lists.

**Why it exists.** $L_i$ is exactly the set of nodes at distance $i$ from $s$, so BFS is *the*
algorithm for unweighted shortest paths, connectivity, components and reachability — and for
"minimum number of moves" problems (knights, mazes) whose graph is only implicit.

**Example.** 6-cycle $1 \to 2 \to 3 \to 4 \to 5 \to 6 \to 1$ from node 1: layers
$\{1\}, \{2,6\}, \{3,5\}, \{4\}$, so $d[4] = 3$ and following parents $4 \to 3 \to 2 \to 1$ gives a
shortest path.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 1–8, 11 · [[lec_15_graph_theory]] Section 5

**Related:** [[terms/DFS]] · [[terms/queue]] · [[terms/edge-classification]] · [[terms/bipartite]] · [[terms/strong-connectivity]]
