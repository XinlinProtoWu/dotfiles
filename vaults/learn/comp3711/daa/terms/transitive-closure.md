# Transitive closure

**What it is.** For a directed graph $G=(V,E)$, the graph $G^*=(V,E^*)$ with
$E^*=\{(i,j): \text{there is a path } i\rightsquigarrow j\}$. It answers reachability for every
ordered pair.

**Why it exists.** Many questions are purely qualitative — "can $i$ reach $j$?" — and a boolean
matrix is smaller and faster than a distance matrix. It is Floyd–Warshall with $\lor$ in place of
$\min$ and $\land$ in place of $+$.

**Example.** If $G$ has edges $1\to2$, $2\to3$, then $G^*$ also has $1\to3$ and every diagonal
entry $i\to i$. The recurrence
$T^{(k)}_{ij}=T^{(k-1)}_{ij}\lor(T^{(k-1)}_{ik}\land T^{(k-1)}_{kj})$ adds paths whose
intermediate vertices are in $\{1,\dots,k\}$.

**Where it appears:** [[lec_18_shortest_paths]] Section 9.3

**Related:** [[terms/Floyd-Warshall]] · [[terms/graph]] · [[terms/DAG]]
