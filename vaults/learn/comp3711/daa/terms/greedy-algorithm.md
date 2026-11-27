# Greedy algorithm

**What it is.** Build a solution by repeatedly making the choice that looks best *now* — feasible,
locally optimal, and irrevocable. Correctness requires a proof, normally an **exchange argument**
showing that some optimal solution agrees with the greedy choice.

**Why it exists.** When it works it is the simplest and fastest option, usually dominated by a
sorting step ($\Theta(n\log n)$). Knowing *when* it fails is equally examinable: coins
$\{1,3,4\}$ at $n = 6$, max-sum of non-adjacent $(1,4,6,4)$, and weighted interval scheduling are
the three standard counterexamples.

**Example.** MSTs: both Prim and Kruskal are greedy and both are correct (cut lemma). Interval
scheduling: greedy is correct with unit weights, wrong with arbitrary weights.

**Where it appears:** [[lec_10-11_greedy]] Sections 1–9, 12–14 · [[lec_12_dynamic_programming]] Sections 6–8, 10 · [[lec_17_minimum_spanning_trees]] Sections 2–4

**Related:** [[terms/cut-property]] · [[terms/MST]] · [[terms/dynamic-programming]]
