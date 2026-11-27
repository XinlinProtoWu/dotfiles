# Interval DP (DP over intervals)

**What it is.** A DP whose state is a **contiguous range** $[i,j]$ rather than a prefix. Base cases
are the length-1 (and often length-2) ranges on the main diagonal; the table is filled by
increasing range length, so every cell's dependencies (one diagonal in) are ready; the answer for
the whole problem is the **top-right** cell $T[1,n]$.

**Why it exists.** A prefix state cannot describe a range whose *left* end moves. Whenever the
recurrence needs "what happens between these two positions" — a palindrome's inside, a
parenthesisation's left and right runs, a BST's left and right subtrees, an RNA stem — the extra
dimension is unavoidable. The cost is $O(n^2)$ states; the split point $k$ adds a factor $n$ when
the recurrence tries all splits.

**Example.** Matrix-chain multiplication on $p = (5,5,4,8,2)$: $m[1,4] = 154$ (the parenthesisation
`(A(B(CD)))`), read from the top-right cell of a $4\times4$ triangle.

**The five parts.** State $T[i,j]$ · base cases (diagonal) · split index $k$ · recurrence combining
$T[i,k]$ and $T[k+1,j]$ (or $T[i,k-1]$, $T[k+1,j]$) plus a join cost · answer at $T[1,n]$.

**Where it appears:** [[lec_14_dp_over_intervals]] Sections 1–10

**Related:** [[terms/dynamic-programming]] · [[terms/palindrome]] · [[terms/matrix-chain-multiplication]] · [[terms/optimal-bst]] · [[terms/rna-secondary-structure]]
