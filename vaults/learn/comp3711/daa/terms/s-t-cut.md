# s-t cut, capacity, and the min-cut theorem

**What it is.** An s-t cut is a partition $(S,T)$ of the vertices with $s\in S$ and $t\in T$. Its
**capacity** is the total capacity of edges from $S$ to $T$:
$c(S,T)=\sum_{e:\,S\to T} c(e)$. Edges from $T$ to $S$ contribute 0.

**Why it exists.** Every flow satisfies $\lvert f\rvert\le c(S,T)$, so a cut is a ceiling. The
max-flow min-cut theorem says the maximum flow equals the minimum cut capacity; a flow and a cut
of equal value are a complete optimality certificate.

**Example.** In the deck's graph, the cut $S=\{s,3,4,7\}$ has forward edges $s\to2$ (10),
$4\to5$ (8) and $7\to t$ (10), so $c(S,T)=28$. The displayed flow also has value 28, hence is
maximum.

**Where it appears:** [[lec_19_max_flow]] Sections 2, 6

**Related:** [[terms/max-flow]] · [[terms/residual-graph]] · [[terms/Ford-Fulkerson]] · [[terms/cut-property]]
