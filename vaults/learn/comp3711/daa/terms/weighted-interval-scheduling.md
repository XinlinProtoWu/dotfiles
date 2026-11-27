# Weighted interval scheduling

**What it is.** Jobs with start $s_j$, finish $f_j$ and weight $v_j$; find a maximum-weight subset
of pairwise non-overlapping jobs. Sort by finish time, let $p(j)$ be the last job finishing by
$s_j$, then $V(j) = \max(v_j + V(p(j)),\, V(j-1))$ in $\Theta(n\log n)$.

**Why it exists.** It is the sharpest demonstration of the boundary between greedy and DP: with
unit weights, earliest-finish-first greedy is optimal; with arbitrary weights it can be
arbitrarily bad, so the ordering argument dies and the table is needed.

**Example.** Jobs $1..4$ = 0–2 (3), 1–3 (5), 2–5 (6), 4–6 (5): $p = 0,0,1,2$, so
$V = 3,5,9,10$ and the optimum is jobs $\{2,4\}$.

**Where it appears:** [[lec_12_dynamic_programming]] Section 7 · [[lec_12_dynamic_programming]] Section 8 (highway billboards)

**Related:** [[terms/dynamic-programming]] · [[terms/greedy-algorithm]]
