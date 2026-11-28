# Floyd–Warshall algorithm

**What it is.** An all-pairs shortest-path algorithm. Let $d^{(k)}_{ij}$ be the shortest $i$–$j$
path whose intermediate vertices lie in $\{1,\dots,k\}$. Then

$$d^{(k)}_{ij}=\min\bigl\{d^{(k-1)}_{ij},\ d^{(k-1)}_{ik}+d^{(k-1)}_{kj}\bigr\},$$

with $d^{(0)}_{ij}=w(i,j)$. Three nested loops with $k$ outermost give $O(n^3)$ time and
$O(n^2)$ space. It handles negative edges but not negative cycles.

**Why it exists.** Adding one allowed intermediate vertex at a time is a DP that never needs the
edge-count parameter. It is simpler than repeated Dijkstra and better on dense graphs; one array
suffices because $d_{ik}$ and $d_{kj}$ are unchanged during iteration $k$.

**Example.** On the deck's five-vertex graph, the entry $d_{5,6}$ goes from $\infty$ to 13
(allowing vertex 1), 9 (vertex 2), 8 (vertex 3) and 6 (vertex 4, route $5\to4\to1\to6$).

**Where it appears:** [[lec_18_shortest_paths]] Section 9

**Related:** [[terms/shortest-path]] · [[terms/transitive-closure]] · [[terms/big-O]]
