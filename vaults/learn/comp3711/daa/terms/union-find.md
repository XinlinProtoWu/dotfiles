# Union-find (disjoint sets)

**What it is.** A data structure over a partition of $\{1..n\}$ supporting `Make-Set(x)`,
`Find-Set(x)` (which set contains $x$, returned as a representative) and `Union(x,y)` (merge two
sets). Implemented as a forest of parent pointers; **union by height** (hang the shorter tree under
the taller root) gives $O(\log n)$ operations, and **path compression** makes them practically
constant.

**Why it exists.** Kruskal's algorithm asks one question per edge — "are $u$ and $v$ already
connected?" — and a DFS per query would cost $O(\lvert E\rvert\lvert V\rvert)$. Union-find makes
each query $O(\log n)$ (near $O(1)$ with path compression), so sorting dominates.

**Example.** Unioning 1–2, then 3–4, then 2–3: after the third union all four
nodes share a root. Unioning 1–4 afterwards would be rejected by Kruskal, because
`Find-Set(1) = Find-Set(4)`.

**Why size $\ge 2^{height}$.** A height-$h$ tree has at least $2^h$ nodes (induction on unions),
so $h \le \log_2 n$.

**Where it appears:** [[lec_17_minimum_spanning_trees]] Section 5

**Related:** [[terms/MST]] · [[terms/tree]]
