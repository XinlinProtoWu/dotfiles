# 0/1 knapsack

**What it is.** $n$ items with weights $w_i$ and values $v_i$, capacity $W$; choose a subset with
total weight $\le W$ maximising total value. DP: $V[i,w] = \max(V[i-1,w],\, v_i + V[i-1,w-w_i])$,
$\Theta(nW)$ time and space.

**Why it exists.** It is the canonical example of a state that needs **two** variables. The
one-variable state $V[w]$ ("best value for capacity $w$") describes the *unbounded* knapsack and
allows an item to be reused; adding the item index is what forbids reuse.

**Example.** Items $(v,w)$ = 1:(10,5), 2:(40,4), 3:(30,6), 4:(50,3), $W = 10$: $V[4,10] = 90$
from items $\{4,2\}$ (weight 7). Note $\Theta(nW)$ is *pseudo-polynomial*: exponential in the bit
length of $W$.

**Where it appears:** [[lec_13_2d_dynamic_programming]] Sections 1–4

**Related:** [[terms/dynamic-programming]] · [[terms/memoization]] · [[terms/coin-change]]
