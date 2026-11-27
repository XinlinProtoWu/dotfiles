# Graph

**What it is.** A pair $G = (V,E)$: a set of vertices (nodes) and a set of edges between pairs of
them. Undirected edges have no direction; directed edges are ordered pairs. By convention the
course assumes **simple** graphs (no self-loops, no parallel edges), and abuses notation by
writing $V$ and $E$ for the *counts* as well, often $n = \lvert V\rvert$, $m = \lvert E\rvert$.

**Why it exists.** Graphs model *relationships*, so one abstract algorithm serves routing,
scheduling, program analysis and network design at once. Almost every problem in the second half
of this course is a graph problem in disguise.

**Example.** Undirected: 6 vertices allow at most $6\cdot5/2 = 15$ edges. Directed: at most
$6\cdot5 = 30$, because an undirected edge is two directed ones. A connected graph needs at least
$n-1$ edges.

**Where it appears:** [[lec_15_graph_theory]] Sections 1–7 · [[lec_16_basic_graph_algorithms]] throughout · [[lec_17_minimum_spanning_trees]] Section 1

**Related:** [[terms/adjacency-list]] · [[terms/tree]] · [[terms/DAG]] · [[terms/handshaking-lemma]]
