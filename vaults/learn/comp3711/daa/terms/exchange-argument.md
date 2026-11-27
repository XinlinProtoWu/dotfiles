# Exchange argument

**What it is.** The standard proof that a greedy algorithm is optimal. Take an optimal solution
$O$ that disagrees with the greedy solution $G$ at the first index $r+1$. Show that the greedy
choice is at least as good on the resource that matters (finish time, value per weight, right
endpoint, edge weight), swap it into $O$ to get $O^*$, and check that (i) $O^*$ is still valid,
(ii) $O^*$ has the same size or value, hence is still optimal, and (iii) $O^*$ agrees with $G$ on
one more index. Repeat.

**Why it exists.** Greedy is *irrevocable*: it never reconsiders, so a single locally cheap choice
must never destroy global optimality. The exchange argument is precisely the statement "the greedy
choice can be part of some optimal solution", which is what makes irrevocability safe.

**Example.** Interval scheduling: greedy takes $i_{r+1}$ with $f(i_{r+1}) \le f(j_{r+1})$;
replacing $j_{r+1}$ by $i_{r+1}$ keeps every later job compatible
($f(i_{r+1}) \le f(j_{r+1}) \le s(j_{r+2})$), so the size is unchanged. Fractional knapsack: at the
first differing item, greedy has $x_i \ge y_i$; raising $y_i$ and removing the same weight from
later items cannot lose value because all later ratios are smaller.

**The four templates it belongs to.** Stays ahead (invariant version: after $t$ steps greedy has
consumed no more of the resource than any feasible solution) · exchange (mutation version, above) ·
lower bound + attain it (interval partitioning: greedy's room count equals the depth) · structural
lemma + induction (Huffman).

**The step the swap alone does not give you.** "Eventually $O$ becomes $G$" presupposes
$\lvert O\rvert = \lvert G\rvert$ — that is the claim being proved. The iteration legitimately
stalls at $r = k$ if the optimal solution were larger, so a complete proof adds the *closing count*:
if $m > k$, the optimal solution's next job is compatible with greedy's last one, so greedy would
have taken it. Both halves are needed: the swap gives local legality, the count gives optimality.

**Where it appears:** [[lec_10-11_greedy]] Sections 1.4, 5, 6, 7, 8 · [[lec_17_minimum_spanning_trees]] Section 3 (cut lemma)

**Related:** [[terms/greedy-algorithm]] · [[terms/interval-scheduling]] · [[terms/fractional-knapsack]] · [[terms/cut-property]]
