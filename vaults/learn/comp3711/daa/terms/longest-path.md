# Longest path in a DAG

**What it is.** For a DAG with edge weights, the maximum-weight path from $s$ to $v$ satisfies
$ld[v]=\max_{(u,v)}\{ld[u]+w(u,v)\}$, computed in topological order in
$\Theta(\lvert V\rvert+\lvert E\rvert)$.

**Why it exists.** The topological order guarantees every predecessor of $v$ is final before $v$
is processed, so one pass suffices. With weights on vertices, put $w(v)$ on every incoming edge
(or split the vertex) to reuse the edge-weighted algorithm. This is the critical-path method.

**Example.** On the deck's DAG with edges $s\to a\,2$, $s\to b\,1$, $b\to a\,2$, $a\to d\,4$,
$b\to d\,1$, $a\to t\,2$, $d\to t\,3$, the longest $s$–$t$ path is $s\to b\to a\to d\to t$ with
weight $1+2+4+3=10$. On the job graph $a=5,b=7,c=3,d=4,f=6$, the critical path is
$a\to d\to f=15$.

**Where it appears:** [[lec_18_shortest_paths]] Sections 5–6

**Related:** [[terms/DAG]] · [[terms/topological-sort]] · [[terms/shortest-path]] · [[terms/P-vs-NP]]
