# Bipartite graph

**What it is.** A graph whose vertices split into two sets $U, W$ with every edge joining $U$ to
$W$ — equivalently, a 2-colourable graph, equivalently a graph with no odd cycle.

**Why it exists.** It is the simplest structural property testable by a single BFS: BFS assigns
distances, colour by distance parity, and check that no edge joins two vertices of the same
parity. Same-layer edges in BFS are exactly odd cycles.

**Example.** The 6-cycle is bipartite (parities $\{1,3,5\}$ vs $\{2,4,6\}$). Adding the edge
$1\to3$ makes $1,3$ both even and creates the triangle $1 \to 2 \to 3 \to 1$: not bipartite.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Section 8

**Related:** [[terms/BFS]] · [[terms/graph]]
