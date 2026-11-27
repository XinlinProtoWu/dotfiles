# Dynamic programming (DP)

**What it is.** A design technique for optimisation problems that have *optimal substructure*
and *overlapping subproblems*: define a state that captures "how much of the problem is left",
write a recurrence expressing a state's answer in terms of smaller states, then compute every
state exactly once, in an order where each state's dependencies are already available.

**Why it exists.** The naive recursive solution to such a problem is exponentially slow not
because the problem is hard but because the *same* subproblem is recomputed along many branches.
Fibonacci by plain recursion takes $204{,}668{,}309$ calls for $n = 40$; storing the $n = 40$
distinct values takes 40 additions.

**Example.** Rod cutting with prices $(1,5,8,9,10,17,17,20,24,30)$ for lengths $1..10$:
$r_j = \max_{1 \le i \le j}(p_i + r_{j-i})$ gives $r_{10} = 30$, computed in
$\Theta(n^2) = 100$ steps instead of checking $2^{9} = 512$ cutting plans.

**The three artefacts of every DP answer.** (1) the recurrence, (2) the value table, (3) the
decision table that reconstructs the plan (`s` in rod cutting, `keep` in knapsack, `b` in
non-adjacent max-sum, `S` in coin change).

**Where it appears:** [[lec_12_dynamic_programming]] Sections 1–10 · [[lec_13_2d_dynamic_programming]] Sections 1–10 · [[lec_14_dp_over_intervals]] Sections 1–10

**Related:** [[terms/memoization]] · [[terms/0-1-knapsack]] · [[terms/LCS]] · [[terms/edit-distance]]
