# Dijkstra's algorithm

**What it is.** A single-source shortest-path algorithm for graphs with **nonnegative** edge
weights. It repeatedly extracts the unvisited vertex with minimum $d$ from a priority queue,
finalises it, and relaxes its outgoing edges. With a binary heap it runs in
$O(\lvert E\rvert\log\lvert V\rvert)$; with an array, $O(\lvert V\rvert^2)$.

**Why it exists.** When all weights are nonnegative, the closest unvisited vertex cannot be
improved by any route through a farther vertex, so it is safe to finalise. This gives a much better
bound than Bellman–Ford on sparse graphs.

**Example.** On the deck's graph, extraction order $s,y,t,z,x$ gives distances $s=0$, $y=5$,
$t=8$, $z=7$, $x=9$. On the negative example $s\to u\,2$, $u\to v\,3$, $v\to t\,-6$, $s\to t\,1$,
Dijkstra finalises $t$ at 1 although the true distance is $-1$.

**Where it appears:** [[lec_18_shortest_paths]] Sections 7, 8

**Related:** [[terms/shortest-path]] · [[terms/relaxation]] · [[terms/Bellman-Ford]] · [[terms/priority-queue]] · [[terms/greedy-algorithm]]
