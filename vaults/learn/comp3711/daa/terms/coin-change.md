# Coin change (minimum number of coins)

**What it is.** Given an amount $n$ and denominations $d_1,\dots,d_k$, find the fewest coins
summing to $n$. DP form: $C(n) = 1 + \min_{i:\,d_i \le n} C(n-d_i)$ with $C(0) = 0$, cost
$\Theta(nk)$.

**Why it exists.** It is the standard counterexample to "greedy is obvious": repeatedly taking
the largest coin is optimal for some currency systems and wrong for others, so the problem has to
be tabulated.

**Example.** Denominations $\{1,3,4\}$, $n = 6$: greedy gives $4+1+1$ (3 coins); the optimum is
$3+3$ (2 coins). With HK coins $\{1,2,5,10\}$ greedy is optimal, which is a property of the
denomination set, not of greedy.

**Where it appears:** [[lec_12_dynamic_programming]] Section 10

**Related:** [[terms/dynamic-programming]] · [[terms/greedy-algorithm]] · [[terms/0-1-knapsack]]
