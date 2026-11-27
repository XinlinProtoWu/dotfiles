# Longest common subsequence (LCS)

**What it is.** Given $X$ of length $m$ and $Y$ of length $n$, the longest sequence appearing in
both in order but not necessarily contiguously. DP: $c[i,j]$ = LCS length of the prefixes;
$c[i,j] = c[i-1,j-1]+1$ when $x_i = y_j$, else $\max(c[i-1,j], c[i,j-1])$; $\Theta(mn)$.

**Why it exists.** It is the archetypal two-string DP and the basis of `diff`. Its geometric
reading — a **maximum non-crossing matching** between the two strings — explains why the
recurrence has exactly three cases.

**Example.** $X = $ `ABACBDAB`, $Y = $ `BDCABA`: $c[8,6] = 4$, but the LCS is not unique —
`BCBA` and `BDAB` are both optimal. Reconstruction walks a direction table (`↖` match, `↑` drop
$x_i$, `←` drop $y_j$).

**Where it appears:** [[lec_13_2d_dynamic_programming]] Sections 5–7

**Related:** [[terms/longest-common-substring]] · [[terms/edit-distance]] · [[terms/dynamic-programming]]
