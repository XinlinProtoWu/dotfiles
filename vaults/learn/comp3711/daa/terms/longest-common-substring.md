# Longest common substring

**What it is.** The longest run of characters occurring **contiguously** in both strings. DP:
$d[i,j] = d[i-1,j-1]+1$ if $x_i = y_j$, else $0$; the answer is $\max_{i,j} d[i,j]$, not $d[m,n]$.

**Why it exists.** It is the trap that separates "subsequence" from "substring". The state must be
redefined to "longest common substring **ending at** $x_i$ and $y_j$" — otherwise the optimum for
a prefix cannot be extended, and the recurrence is silently wrong.

**Example.** $X = $ `DEADBEEF`, $Y = $ `EATBEEF` gives `BEEF` (length 4) at $X[5..8]$, $Y[4..7]$.
Reconstruction needs only the position of the maximum (best length `lm`, end `pm`).

**Where it appears:** [[lec_13_2d_dynamic_programming]] Section 8

**Related:** [[terms/LCS]] · [[terms/dynamic-programming]]
