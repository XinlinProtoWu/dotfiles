# Tree, forest, rooted tree

**What it is.** A **tree** is an undirected graph that is connected and acyclic. A **forest** is
an acyclic undirected graph (a collection of trees). A **rooted tree** is a tree plus a chosen
root, with every edge oriented away from it, giving each non-root vertex exactly one *parent* and
any number of *children*.

**Why it exists.** "Connected" and "acyclic" are expensive to check directly; the equivalence
"any two of {connected, acyclic, $\lvert E\rvert = \lvert V\rvert-1$}" turns tree questions into
counting. Spanning trees are the minimum-cost way to connect everything (see MST), and search
trees (BFS/DFS/union-find) are rooted trees.

**Example.** 9 vertices and 8 edges that are connected form a tree — no need to search for cycles.
But 4 vertices and 3 edges can be a triangle plus an isolated vertex: the count alone does **not**
imply a tree.

**Where it appears:** [[lec_15_graph_theory]] Section 7 · [[lec_17_minimum_spanning_trees]] Section 1 · [[lec_16_basic_graph_algorithms]] Sections 3, 9

**Related:** [[terms/graph]] · [[terms/MST]] · [[terms/DFS]] · [[terms/union-find]]
