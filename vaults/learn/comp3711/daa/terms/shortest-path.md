# Shortest path and distance

**What it is.** For a weighted directed graph $G=(V,E)$ with edge weights $w(e)$ (possibly
negative), the **distance** $\delta(u,v)$ is the minimum total weight of a $u$–$v$ path. The
single-source problem computes $\delta(s,x)$ for every $x$; the all-pairs problem computes
$\delta(u,v)$ for every pair.

**Why it exists.** It is the abstraction behind routing, timetables and currency arbitrage. Its
key structural property is **subpath optimality**: every subpath of a shortest path is itself a
shortest path, which is what makes a dynamic-programming recurrence possible.

**Example.** In the deck's graph, $s\to2\to3\to5\to t$ has weight $9+23+2+16=50$, so
$\delta(s,t)=50$; the full single-source table also gives $\delta(s,4)=45$ via
$s\to2\to3\to5\to4$.

**Where it appears:** [[lec_18_shortest_paths]] Sections 1–9

**Related:** [[terms/relaxation]] · [[terms/Bellman-Ford]] · [[terms/Dijkstra]] · [[terms/Floyd-Warshall]] · [[terms/graph]]
