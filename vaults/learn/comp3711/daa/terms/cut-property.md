# Cut lemma (and the exchange argument)

**What it is.** A **cut** $(S, V-S)$ partitions the vertices; an edge *crosses* it if exactly one
endpoint is in $S$. **Cut lemma:** with distinct weights, the unique minimum-weight crossing edge
belongs to **every** MST. The proof is an *exchange argument*: if an MST $T^*$ omits $e$, the
$u$–$v$ path in $T^*$ crosses the cut at some other edge $e'$ with $w(e') > w(e)$, and swapping
$e'$ for $e$ lowers the cost — contradiction.

**Why it exists.** It is the single certificate that makes both Prim and Kruskal correct: each
algorithm only ever adds a minimum crossing edge, so no choice is ever regretted. Without distinct
weights the conclusion weakens to "the edge is in **some** MST".

**Example.** $a$–$b$ (4), $b$–$c$ (8), $a$–$h$ (8), $h$–$g$ (1): with $S = \{h, g, f\}$ and the
rest outside, the minimum crossing edge is $h$–$i$ (7), and every MST must contain it.

**Where it appears:** [[lec_17_minimum_spanning_trees]] Sections 3–4, 6–7

**Related:** [[terms/MST]] · [[terms/greedy-algorithm]] · [[terms/union-find]]
