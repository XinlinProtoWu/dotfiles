# Residual graph

**What it is.** Given a flow $f$, the residual graph $G_f$ has the same vertices and, for each
original edge $(u,v)$, a forward residual edge $(u,v)$ with capacity $c(u,v)-f(u,v)$ and a
backward residual edge $(v,u)$ with capacity $f(u,v)$. Zero-capacity edges are omitted.

**Why it exists.** It records both the spare capacity in the original direction and the ability to
**cancel** flow already sent. Without backward edges, a greedy augmentation can get stuck at a
non-maximum flow; with them, Ford–Fulkerson can reroute earlier decisions.

**Example.** If $2\to5$ has capacity 8 and flow 8, the residual graph contains only $5\to2$ with
capacity 8. In the four-node greedy example, after greedy reaches 25, the residual path
$s\to2\to1\to t$ with bottleneck 5 cancels 5 units of $1\to2$ and raises the value to 30.

**Where it appears:** [[lec_19_max_flow]] Sections 4–7

**Related:** [[terms/max-flow]] · [[terms/Ford-Fulkerson]] · [[terms/s-t-cut]] · [[terms/BFS]]
