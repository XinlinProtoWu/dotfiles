# Flow, value and maximum flow

**What it is.** A flow on a directed graph with capacities $c(e)$ is a function $f(e)$ with
$0\le f(e)\le c(e)$ (capacity) and equal inflow and outflow at every vertex except $s$ and $t$
(conservation). Its **value** is the net outflow at $s$, which equals the net inflow at $t$. The
maximum-flow problem asks for the flow of largest value.

**Why it exists.** It models water, traffic, packets and — through reductions — matching,
scheduling and elimination problems. The max-flow min-cut theorem turns an optimisation problem
into a combinatorial certificate: a flow and a cut of the same value prove optimality.

**Example.** In the deck's four-node network with capacities $s\to1\,20$, $s\to2\,10$,
$1\to2\,30$, $1\to t\,10$, $2\to t\,25$, the maximum value is 30 (send 20 through 1, split as
10 direct and 10 via 2; send 10 directly from $s$ to 2).

**Where it appears:** [[lec_19_max_flow]] Sections 1–7

**Related:** [[terms/s-t-cut]] · [[terms/residual-graph]] · [[terms/Ford-Fulkerson]] · [[terms/graph]]
