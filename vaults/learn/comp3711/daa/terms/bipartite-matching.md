# Bipartite matching

**What it is.** In a bipartite graph $V=X\cup Y$ with every edge crossing from $X$ to $Y$, a
matching is a set of edges no two of which share a vertex. A maximum matching has the largest
possible size. A perfect matching touches every vertex.

**Why it exists.** It models assigning people to jobs, tasks to machines, residents to hospitals.
It reduces to maximum flow: direct every $X\to Y$ edge with capacity 1, add $s\to x$ and $y\to t$
with capacity 1, and read the matching off the edges carrying flow 1. Integrality of flow makes
the correspondence exact.

**Example.** On the deck's five-person/five-job graph, $1\text{–}2'$, $3\text{–}1'$,
$4\text{–}5'$ is a matching of size 3, while $1\text{–}1'$, $2\text{–}2'$, $3\text{–}3'$,
$4\text{–}4'$ is maximum with size 4.

**Where it appears:** [[lec_19_max_flow]] Sections 8.3–8.4

**Related:** [[terms/bipartite]] · [[terms/max-flow]] · [[terms/Ford-Fulkerson]] · [[terms/stable-matching]]
