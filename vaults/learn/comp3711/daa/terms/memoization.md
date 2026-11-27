# Memoization (top-down DP)

**What it is.** Keeping the ordinary recursive solution but adding a cache: before recursing on
a state, return the stored answer if it exists; after computing, store it. Reachable states are
computed once, lazily, in whatever order the recursion happens to visit them.

**Why it exists.** It is the cheapest way to turn a correct exponential recursion into a
polynomial one — you keep the code shape and the correctness argument, and add two lines. It also
solves *sparse* state spaces, where only a tiny fraction of the $O(\text{states})$ table is ever
needed (a hash table replaces the array).

**Example.** `TD-F(n)`: `if F[n] != 0 return F[n]; F[n] <- TD-F(n-1) + TD-F(n-2); return F[n]`.
For Fibonacci this makes $\Theta(n)$ calls instead of $\Theta(\varphi^n)$ — but costs $\Theta(n)$
recursion depth, which is why the bottom-up version (two variables, $\Theta(1)$ space) is the
default.

**Where it appears:** [[lec_12_dynamic_programming]] Section 2 · [[lec_13_2d_dynamic_programming]] Section 3

**Related:** [[terms/dynamic-programming]] · [[terms/0-1-knapsack]]
