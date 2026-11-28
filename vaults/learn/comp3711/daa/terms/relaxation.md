# Relaxation

**What it is.** For each vertex $v$, maintain a current distance estimate $v.d$ and a predecessor
$v.p$. Relaxing edge $(u,v)$ tests whether $u.d+w(u,v)<v.d$; if so, it replaces $v.d$ by
$u.d+w(u,v)$ and sets $v.p=u$.

**Why it exists.** It is the single update primitive shared by Bellman–Ford, DAG shortest path,
Dijkstra and (in matrix form) Floyd–Warshall. The algorithms differ only in which edges they relax
and in what order they guarantee that an estimate is final.

**Example.** Starting from $s.d=0$, relaxing $(s,2)$ with $w=9$ gives $2.d=9$; later relaxing
$(2,3)$ with $w=23$ gives $3.d=32$. In Bellman–Ford's four passes on the five-node graph,
relaxation lowers $z.d$ from $\infty$ to 2 to $-2$.

**Where it appears:** [[lec_18_shortest_paths]] Sections 3–7

**Related:** [[terms/shortest-path]] · [[terms/Bellman-Ford]] · [[terms/Dijkstra]] · [[terms/priority-queue]]
