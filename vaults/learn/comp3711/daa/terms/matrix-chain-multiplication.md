# Matrix-chain multiplication

**What it is.** Given $A_1 \cdots A_n$ with $A_i$ of size $p_{i-1} \times p_i$, choose the
parenthesisation minimising scalar multiplications. Multiplying $p\times q$ by $q\times r$ costs
$pqr$. DP: $m[i,j] = \min_{i \le k < j}\{m[i,k] + m[k+1,j] + p_{i-1}p_k p_j\}$, $m[i,i] = 0$,
$O(n^3)$ time and $O(n^2)$ space; Hu–Shing give $O(n\log n)$.

**Why it exists.** It is the canonical "the association order is free, so it is part of the input
of the optimisation" problem: the same product can cost 7,500 or 75,000 depending only on
parentheses, and there are Catalan-many orders, so enumeration dies immediately.

**Example.** $A_{10\times100}B_{100\times5}C_{5\times50}$: $(AB)C = 5{,}000 + 2{,}500 = 7{,}500$
beats $A(BC) = 25{,}000 + 50{,}000 = 75{,}000$. For $p = (5,5,4,8,2)$ the best of the five orders
is `(A(B(CD)))` at 154.

**Where it appears:** [[lec_14_dp_over_intervals]] Sections 6–7

**Related:** [[terms/interval-dp]] · [[terms/optimal-bst]] · [[terms/dynamic-programming]]
