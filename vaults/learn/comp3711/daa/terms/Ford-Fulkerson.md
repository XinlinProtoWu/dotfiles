# Ford–Fulkerson and Edmonds–Karp

**What it is.** Ford–Fulkerson starts with zero flow and repeatedly finds an $s$–$t$ path in the
residual graph, augmenting by the path's bottleneck capacity, until no path remains. Edmonds–Karp
is the variant that always chooses a **shortest** residual path (by edge count), found with BFS.

**Why it exists.** The residual graph lets the algorithm undo bad routing decisions, and the
max-flow min-cut theorem guarantees that "no augmenting path" means "maximum flow". Edmonds–Karp
adds a polynomial bound independent of the capacities: $O(\lvert V\rvert\lvert E\rvert)$
augmentations, $O(\lvert V\rvert\lvert E\rvert^2)$ time.

**Example.** On the four-node network, Ford–Fulkerson first sends 20 along $s\to1\to2\to t$, then
5 along $s\to2\to t$, then uses the residual path $s\to2\to1\to t$ to cancel 5 units of
$1\to2$ and reach the maximum 30. The deck's bad example adds only one unit per augmentation and
needs a million rounds when the capacities are a million; choosing the two short paths finishes in
two.

**Where it appears:** [[lec_19_max_flow]] Sections 5, 7–8

**Related:** [[terms/max-flow]] · [[terms/residual-graph]] · [[terms/s-t-cut]] · [[terms/BFS]] · [[terms/big-O]]
