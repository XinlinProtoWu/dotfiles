# Fractional knapsack

**What it is.** Items with weight $w_i$ and value $v_i$, capacity $W$, and $0 \le x_i \le 1$: you
may take a *fraction* of an item. Greedy solution: sort by value per unit weight $v_i/w_i$
descending and take as much as fits; the last item taken may be partial. $\Theta(n\log n)$.

**Why it exists.** It marks the boundary of greedy. Relaxing the integrality constraint makes the
problem *fractional* — and only then is the ratio rule optimal. It is the cleanest illustration
that a greedy algorithm is optimal for one problem statement and wrong for a nearly identical one.

**Example.** Items $(v,w)$ = (60,10), (100,20), (120,30), $W = 50$; ratios 6, 5, 4. Greedy takes
all of items 1 and 2 and $\tfrac{2}{3}$ of item 3: value 240. The 0/1 optimum is 220 (items 2 and
3), and 0/1 greedy gets only 160.

**Why it is optimal.** At the first index where greedy and an optimal solution differ, greedy's
fraction is larger; raise the optimal one and remove the same weight from later (lower-ratio)
items — the value cannot decrease, so an optimal solution agreeing with greedy exists.

**Where it appears:** [[lec_10-11_greedy]] Section 6

**Related:** [[terms/0-1-knapsack]] · [[terms/exchange-argument]] · [[terms/greedy-algorithm]] · [[terms/dynamic-programming]]
