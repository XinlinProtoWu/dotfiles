# Directed acyclic graph (DAG)

**What it is.** A directed graph with no directed cycle. Equivalently, a digraph that admits a
topological order ([[terms/topological-sort]]), equivalently a digraph in which every non-empty
subgraph has a vertex of in-degree 0.

**Why it exists.** Acyclicity is what makes "process in dependency order" well defined: course
prerequisites, build systems, spreadsheet formula evaluation. It is also the test that separates
DP-from-exponential on a path (a DAG's longest path is easy; a general digraph's is not).

**Example.** A 10-node scheduling DAG with two valid topological orders
$0,6,1,4,3,2,5,7,8,9$ and $0,4,1,6,2,5,3,7,8,9$ — the order within "currently available" is free,
so the order is not unique.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 10, 13 · [[lec_13_2d_dynamic_programming]] Section 11

**Related:** [[terms/topological-sort]] · [[terms/DFS]] · [[terms/edge-classification]]
