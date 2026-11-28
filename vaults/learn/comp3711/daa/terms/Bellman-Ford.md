# Bellman–Ford algorithm

**What it is.** A single-source shortest-path algorithm that allows negative edge weights. It
initialises $s.d=0$ and all other $d=\infty$, then relaxes **every** edge for $\lvert V\rvert-1$
rounds. One extra round detects a reachable negative cycle.

**Why it exists.** A shortest simple path has at most $\lvert V\rvert-1$ edges, so after $i$ rounds
every vertex reachable by a path of at most $i$ edges has its true distance. It is the standard
choice when negative edges are present, and its DP form is the basis of the all-pairs edge-count
solution.

**Example.** On the deck's graph with $s\to t\,6$, $s\to y\,7$, $t\to x\,5$, $t\to y\,8$,
$t\to z\,-4$, $x\to t\,-2$, $y\to x\,-3$, $y\to z\,9$, $z\to s\,2$, $z\to x\,7$, four passes with
order $t,x,y,z,s$ give $t=2$, $x=4$, $y=7$, $z=-2$. A fifth pass changes nothing, so the algorithm
terminates early.

**Where it appears:** [[lec_18_shortest_paths]] Sections 4, 8

**Related:** [[terms/shortest-path]] · [[terms/relaxation]] · [[terms/Dijkstra]] · [[terms/big-O]]
