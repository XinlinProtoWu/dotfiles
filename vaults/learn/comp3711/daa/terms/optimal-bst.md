# Optimal binary search tree (optimal BST)

**What it is.** Given ordered keys $a_1 < \cdots < a_n$ with access weights $f(a_i)$, build the BST
minimising $B(T) = \sum_i f(a_i)(d(a_i)+1)$. DP over ranges:
$e[i,j] = \min_{i \le k \le j}\{e[i,k-1] + e[k+1,j] + w[i,j]\}$ where $w[i,j] = \sum_{t=i}^{j} f(a_t)$;
$e[i,i] = f(a_i)$, $e[i,j] = 0$ for $i > j$. $O(n^3)$, or $O(n^2)$ with Knuth–Yao.

**Why it exists.** It looks like Huffman but is not: the keys are **ordered** (so a subtree cannot
be moved anywhere) and keys sit at **internal** nodes (so every key of a subtree drops one level
when attached, which is what the $+w[i,j]$ term pays for). It is the standard example of "same
shape, one extra term" in interval DP.

**Example.** Weights $A{:}0.1, B{:}0.2, C{:}0.3, D{:}0.4$: greedy "heaviest at the root" builds a
chain costing $2.0$, the optimum roots at $C$ (with $B$ left, $D$ right) and costs $1.8$.

**Where it appears:** [[lec_14_dp_over_intervals]] Sections 8–9

**Related:** [[terms/interval-dp]] · [[terms/huffman-coding]] · [[terms/matrix-chain-multiplication]]
