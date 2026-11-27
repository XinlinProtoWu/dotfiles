# Tree, back, forward and cross edges

**What it is.** The four classes of edge relative to a BFS/DFS tree: **tree** (parent to child),
**back** (node to an ancestor other than its parent), **forward** (node to a descendant other than
a child), **cross** (no ancestor/descendant relation). In DFS the type is read off the colour
when the edge is scanned: white ⇒ tree, gray ⇒ back, black ⇒ forward or cross.

**Why it exists.** Cycles, topological order and unique-path questions are all answered by
classifying edges, so a search that classifies is a search that solves several problems at once.
The two structural theorems make this cheap on undirected graphs: DFS has **no cross edges**, BFS
has **no forward or back edges**.

**Example.** Undirected DFS on the deck's graph starting at $a$ finds $(i,b)$ as a back edge ⇒
cycle $b \to e \to i \to b$. In a directed graph, an edge to a **black** node is not a cycle
(forward/cross), which is why "gray, not visited" is the correct cycle test there.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 10–12

**Related:** [[terms/DFS]] · [[terms/BFS]] · [[terms/DAG]]
