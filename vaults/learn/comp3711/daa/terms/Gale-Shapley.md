# Gale–Shapley propose-and-reject

**What it is.** An $O(n^2)$ algorithm for stable matching: each free man proposes to the next woman
on his list; a free woman accepts, an engaged woman keeps whichever of her fiancé and the new
proposer she prefers, and the rejected man becomes free. It stops after at most $n^2$ proposals.

**Why it exists.** It constructively proves that a stable matching exists for every bipartite
instance, and it gives the **proposing side's optimal** stable matching. The proof rests on two
invariants: men walk down their lists, and women only trade up.

**Example.** On the deck's lists, proposals $X\to A$, $Y\to B$, $Z\to A$ (rejected), $Z\to B$
(rejected), $Z\to C$ produce $X\text{–}A$, $Y\text{–}B$, $Z\text{–}C$. All men proposing the same
list makes the algorithm take $n+(n-1)+\cdots+1=\Omega(n^2)$ proposals; distinct first choices
take $O(n)$.

**Where it appears:** [[lec_20_stable_matching]] Sections 3–9, 11

**Related:** [[terms/stable-matching]] · [[terms/queue]] · [[terms/greedy-algorithm]] · [[terms/big-O]]
