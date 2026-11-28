# Lecture 18 — Shortest Paths

> Source: `18_ShortestPath.pdf` (55 pages). Goal: find cheapest routes through a weighted graph —
> from one source (Bellman–Ford, DAG order, Dijkstra) and between every pair (Floyd–Warshall) —
> and know exactly which structural property makes each one correct. Builds on the graph
> vocabulary of [[lec_15_graph_theory]], the traversal orders of [[lec_16_basic_graph_algorithms]],
> and the priority queue of [[lec_8_heapsort]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The problem:** [[terms/shortest-path|Shortest path and distance]] · [[terms/relaxation|Relaxation]] · [[terms/DAG]] · [[terms/topological-sort|Topological sort]]

**Single source:** [[terms/Bellman-Ford|Bellman–Ford]] · [[terms/Dijkstra|Dijkstra's algorithm]] · [[terms/longest-path|Longest path in a DAG]] · [[terms/priority-queue|Priority queue]]

**All pairs:** [[terms/Floyd-Warshall|Floyd–Warshall]] · [[terms/transitive-closure|Transitive closure]] · [[terms/adjacency-list]]

**Graphs:** [[terms/graph]] · [[terms/big-O]]

---

## 1. The problem, and why negative cycles ruin it

**Motivate.** A road network, a flight timetable and a currency market all ask the same question:
*what is the cheapest way to get from here to there?* The answer is not simply the route with the
fewest hops, because edges carry different costs (distance, time, price, delay). The whole lecture
is about exploiting one fact: a cheapest route is made of cheapest sub-routes.

**Define.** Input: a directed graph $G = (V,E)$, a weight $w(e)$ for each edge (possibly negative),
a source $s$ and a destination $t$. An undirected edge is modelled as two directed edges.

$$\delta(u,v) = \text{length of the shortest } u\text{–}v \text{ path}$$

The **single-source** version asks for $\delta(s,x)$ for every vertex $x$, not just $t$.

![[18_ShortestPath.pdf#page=2]]
*Figure: a weighted digraph with source $s$ and target $t$. (`18_ShortestPath.pdf` p. 2)*

**In plain words.** You are booking a trip across five towns. The number on a road is the fare,
not the driving time, so the cheapest trip may take more roads than the shortest-looking one. You
want the total fare, and you also want to know the fare to every town along the way, because one
of them may become useful if a road is closed.

**Example (traced).** The deck's graph has the path
$s \to 2 \to 3 \to 5 \to t$ with fares $9$, $23$, $2$ and $16$:

$$9 + 23 + 2 + 16 = 50, \qquad \delta(s,t) = 50.$$

The deck's full single-source table is:

| node $x$ | shortest path from $s$ | $\delta(s,x)$ |
|---|---|---|
| 2 | $s,2$ | 9 |
| 3 | $s,2,3$ | 32 |
| 4 | $s,2,3,5,4$ | 45 |
| 5 | $s,2,3,5$ | 34 |
| 6 | $s,6$ | 14 |
| 7 | $s,6,7$ | 19 |
| $t$ | $s,2,3,5,t$ | 50 |

Every entry is the sum of its listed edges: $9+23+2+11=45$ to node 4, $9+23+2=34$ to node 5,
$14+5=19$ to node 7. The parent pointers of these routes form a **shortest-path tree** rooted at
$s$.

![[18_ShortestPath.pdf#page=4]]
*Figure: the single-source version — one shortest path and one distance per node. (`18_ShortestPath.pdf` p. 4)*

**Negative cycles.** Repeating a cycle of negative total weight makes an $s$–$t$ path arbitrarily
negative, so "the shortest path" is not defined. The course therefore assumes **no negative-weight
cycle reachable from $s$** unless the exercise is specifically about detecting one.

![[18_ShortestPath.pdf#page=5]]
*Figure: a negative cycle $C$ with $w(C)<0$ can be repeated to drive the path length down forever. (`18_ShortestPath.pdf` p. 5)*

**In plain words.** Imagine a toll loop that pays you more than it costs every time you drive it.
You could drive around it all day and arrive with an ever-growing profit, so there is no "cheapest"
trip. A shortest route is therefore only meaningful when every useful loop costs something.

> [!important] Negative edges are allowed; negative cycles are not
> Bellman–Ford and Floyd–Warshall handle negative edges. Dijkstra does not. All three refuse to
> give a finite answer when a negative cycle can be reached.

---

## 2. Subpath optimality: the cut-and-paste argument

**Motivate.** Every algorithm in this lecture computes a long path out of shorter ones. That is
only legitimate if every piece of an optimal path is itself optimal.

**Lemma (subpath optimality).** Let $P = (s,\dots,u,\dots,t)$ be a shortest $s$–$t$ path. Then the
prefix $P_1 = (s,\dots,u)$ is a shortest $s$–$u$ path and the suffix $P_2 = (u,\dots,t)$ is a
shortest $u$–$t$ path.

**Proof.** Suppose not: let $P_1'$ be a cheaper $s$–$u$ path. Replace $P_1$ by $P_1'$ inside $P$.
The result is still an $s$–$t$ path and is shorter than $P$, contradicting the choice of $P$.
The same argument applies to $P_2$. $\blacksquare$

![[18_ShortestPath.pdf#page=6]]
*Figure: splicing a cheaper prefix $P_1'$ into $P$ produces a shorter $s$–$t$ path. (`18_ShortestPath.pdf` p. 6)*

**In plain words.** If the first leg of your journey is not the cheapest way to reach that
midpoint, then swapping in the cheaper leg gives a cheaper whole journey. A trip that is cheapest
overall therefore cannot contain a leg that someone else could beat.

**Example (traced on the deck's path).** The route $s \to 2 \to 3 \to 5 \to t$ costs $50$. If some
other $s$–$3$ route cost only $30$, the whole trip could be rerouted as $s \to 3 \to 5 \to t$ for
$30 + 2 + 16 = 48 < 50$, so the original route was not optimal. Since it *is* optimal, every
prefix is optimal too.

> [!important] Why this lemma is the engine of dynamic programming
> The recurrence for $v.d$ only has to look at the last edge $(u,v)$ and a *known* optimal value
> for $u$. Without subpath optimality, knowing the best route to $u$ would say nothing about the
> best route to $v$.

---

## 3. Relaxation: the only primitive we need

**Define.** Maintain two fields per vertex:

| Field | Meaning |
|---|---|
| $v.d$ | length of the shortest $s$–$v$ path found *so far* |
| $v.p$ | predecessor of $v$ on that current path |

**Relaxing** edge $(u,v)$ tests whether going optimally to $u$ and then taking $(u,v)$ beats the
current best route to $v$. If it does, update both fields.

```text
Relax(u, v):
    if u.d + w(u, v) < v.d then
        v.d <- u.d + w(u, v)
        v.p <- u
```

![[18_ShortestPath.pdf#page=7]]
*Figure: relaxation replaces the old candidate route to $v$ by a route through $u$. (`18_ShortestPath.pdf` p. 7)*

**In plain words.** A courier keeps a noticeboard of the cheapest known fare to every town. When a
cheaper fare to $u$ is discovered, the courier checks each road out of $u$: if the new fare plus
that road beats the fare written for the next town, the noticeboard is corrected and the town
records $u$ as "come through here". Nothing is ever made worse — only improved.

**Example (traced).** Initially $s.d=0$ and every other $d=\infty$. Relaxing the deck's edges in
the order $s \to 2$, $2 \to 3$, $3 \to 5$, $5 \to 4$:

| edge relaxed | candidate | new $d$ |
|---|---|---|
| $(s,2)$ | $0+9=9$ | $2.d=9$ |
| $(2,3)$ | $9+23=32$ | $3.d=32$ |
| $(3,5)$ | $32+2=34$ | $5.d=34$ |
| $(5,4)$ | $34+11=45$ | $4.d=45$ |

After those four relaxations the route to node 4 is already 45, the optimal value in Section 1's
table.

> [!tip] Relaxation alone does not certify anything
> A vertex's $d$ is only a *candidate* until the algorithm proves no cheaper route remains.
> Bellman–Ford proves it by exhaustive rounds; Dijkstra proves it by extracting the minimum;
> Floyd–Warshall proves it by considering every allowed intermediate vertex.

---

## 4. Bellman–Ford: relax everything, enough times

**Idea.** A shortest path in a graph without negative cycles can be taken to be simple, so it has
at most $\lvert V\rvert-1$ edges. Relax **every** edge, $\lvert V\rvert-1$ times. After $i$ rounds,
every vertex whose shortest path uses at most $i$ edges has its true distance.

```text
Bellman-Ford(G, s):
    for each v in V
        v.d <- INFINITY;  v.p <- nil
    s.d <- 0
    for i <- 1 to |V| - 1
        for each u in V (any order)
            for each v in Adj[u]
                Relax(u, v)
        if no v.d changed in this iteration then terminate
```

![[18_ShortestPath.pdf#page=8]]
*Figure: the pseudocode, with the early-termination test and the $O(VE)$ / $O(V)$ bounds. (`18_ShortestPath.pdf` p. 8)*

**Cost.** $O(\lvert V\rvert\lvert E\rvert)$ time worst case, $O(\lvert V\rvert)$ extra space. The
early exit often makes it much faster in practice.

**The DP view.** Define $v.d^{(i)}$ = length of the shortest $s$–$v$ path using at most $i$ edges.
Then

$$v.d^{(i)} = \min_{(u,v)\in E}\bigl\{u.d^{(i-1)} + w(u,v)\bigr\}, \qquad v.d^{(0)} = \infty,\ s.d^{(0)}=0.$$

The answer is $v.d^{(\lvert V\rvert-1)}$. Bellman–Ford keeps only one array and relaxes in *no
particular* order, maintaining the invariant $v.d \le v.d^{(i)}$ after round $i$.

![[18_ShortestPath.pdf#page=10]]
*Figure: the DP recurrence over incoming edges, and the two differences from a table-filling DP. (`18_ShortestPath.pdf` p. 10)*

**In plain words.** Think of a rumour that can travel at most one road per day. On day one only the
source's neighbours can hear it; on day two their neighbours can hear it, and so on. After
$n-1$ days every town reachable by a simple route has heard the best possible version of the
rumour, because no simple route needs more than $n-1$ roads. Re-checking all roads every day is
wasteful but safe.

**Example (traced, deck's graph).** Edges:
$s\to t\,6$, $s\to y\,7$, $t\to x\,5$, $t\to y\,8$, $t\to z\,-4$, $x\to t\,-2$,
$y\to x\,-3$, $y\to z\,9$, $z\to s\,2$, $z\to x\,7$.
The deck relaxes each pass in the order $t,x,y,z,s$:

| after pass | $t$ | $x$ | $y$ | $z$ | what changed |
|---|---|---|---|---|---|
| 0 | $\infty$ | $\infty$ | $\infty$ | $\infty$ | initial |
| 1 | 6 | 11 | 7 | 2 | via $s$, then $t\to x$, then $t\to z$ |
| 2 | 6 | 4 | 7 | 2 | $y\to x$: $7-3=4$ |
| 3 | 2 | 4 | 7 | 2 | $x\to t$: $4-2=2$ |
| 4 | 2 | 4 | 7 | $-2$ | $t\to z$: $2-4=-2$ |

Pass 4 changes $z$ to $-2$, so pass 5 is needed only to discover that nothing changes; the
algorithm then stops. The final distances are $\delta(s,t)=2$, $\delta(s,x)=4$,
$\delta(s,y)=7$, $\delta(s,z)=-2$. The deck's frames (d) and (e) are the end of pass 3 and pass 4.

![[18_ShortestPath.pdf#page=9]]
*Figure: Bellman–Ford pass by pass on the five-node example. (`18_ShortestPath.pdf` p. 9)*

**Order does not affect the answer.** Relaxing in the order $s,t,y,x,z$ instead of $t,x,y,z,s$
produces different intermediate values but the same final table. The order only changes how many
passes are needed before the values settle.

![[18_ShortestPath.pdf#page=11]]
*Figure: the same graph with a different relaxation order inside each pass. (`18_ShortestPath.pdf` p. 11)*

**In plain words for the two orders.** Two postmen deliver the same corrections to the same
noticeboard, one walking the streets clockwise and the other anticlockwise. One may finish the
round with a more up-to-date board, but after enough rounds both boards say the same thing.

### 4.1 Detecting a negative cycle

After $\lvert V\rvert-1$ rounds, run **one more** round. If any edge can still be relaxed, a
negative cycle exists: no simple shortest path has more than $\lvert V\rvert-1$ edges, so an
improvement on round $\lvert V\rvert$ can only come from going around a negative cycle.

```text
for each edge (u, v) in E
    if u.d + w(u, v) < v.d then return "Negative Cycle"
```

If $s$ cannot reach every vertex, add a **super-source** $s^*$ with a zero-weight edge to every
vertex and run Bellman–Ford from $s^*$; alternatively run it separately on each strongly connected
component.

![[18_ShortestPath.pdf#page=12]]
*Figure: the extra relaxation round, plus the two fixes for vertices not reachable from $s$. (`18_ShortestPath.pdf` p. 12)*

**In plain words.** A negative cycle is a loop that pays you to walk it. After the algorithm has
had enough rounds to settle every honest route, one more round that still lowers a fare proves
some route has more than $n-1$ roads — which can only happen by looping. The super-source is a
fake "start everywhere" town so that no pocket of the graph escapes the test.

> [!important] Why $\lvert V\rvert-1$ and not $\lvert V\rvert$ rounds
> A shortest path without repeated vertices has at most $\lvert V\rvert-1$ edges. Round
> $\lvert V\rvert$ is therefore pure diagnosis: a change there is proof of a negative cycle, not a
> better ordinary path.

---

## 5. DAGs: one pass is enough

**Idea.** Drop the edge-count parameter from the DP and use the recurrence
$v.d = \min_{(u,v)} \{u.d+w(u,v)\}$. The only obstacle is the order: $u.d$ must be final before
$(u,v)$ is relaxed. In a DAG, **topological order** supplies exactly that.

```text
DAG-Shortest-Path(G, s):
    topologically sort the vertices of G
    for each v in V: v.d <- INFINITY; v.p <- nil
    s.d <- 0
    for each u in topological order
        for each v in Adj[u]
            Relax(u, v)
```

**Cost.** $\Theta(\lvert V\rvert+\lvert E\rvert)$ — each edge is relaxed exactly once.

![[18_ShortestPath.pdf#page=14]]
*Figure: the one-pass DAG algorithm and its linear running time. (`18_ShortestPath.pdf` p. 14)*

**In plain words.** If every road is one-way and the towns can be lined up so that all roads point
forward, walk the line once. By the time you reach a town, every road that can enter it comes from
a town you have already finished, so its fare is final. No repeated rounds are needed.

**Example (traced).** On the DAG with edges $s\to a\,2$, $s\to b\,1$, $b\to a\,2$, $a\to d\,4$,
$b\to d\,1$, $a\to t\,2$, $d\to t\,3$, topological order $s,b,a,d,t$ gives:

| vertex | candidate relaxations | final $d$ |
|---|---|---|
| $s$ | start | 0 |
| $b$ | $s\to b$: 1 | 1 |
| $a$ | $s\to a$: 2; $b\to a$: $1+2=3$ | 2 |
| $d$ | $a\to d$: $2+4=6$; $b\to d$: $1+1=2$ | 2 |
| $t$ | $a\to t$: $2+2=4$; $d\to t$: $2+3=5$ | 4 |

Every vertex is final the first time it is read, because all its predecessors were processed
earlier.

### 5.1 Longest path in a DAG

The same one-pass DP finds the **longest** path if the recurrence flips from $\min$ to $\max$:

$$ld[s]=0, \qquad ld[v]=\max_{(u,v)\in E}\bigl\{ld[u]+w(u,v)\bigr\}.$$

![[18_ShortestPath.pdf#page=16]]
*Figure: the longest-path exercise, with the optimal path $s,b,a,d,t$ of weight $1+2+4+3=10$. (`18_ShortestPath.pdf` p. 16)*

**In plain words.** On a one-way street map, the most scenic route from the start is found by
asking, for each town in order, "which incoming road gives the best trip so far?" No route can
sneak up from behind because every road points forward.

**Example (traced).** Using the graph above, topological order $s,b,a,d,t$:

| vertex | $ld$ | reason |
|---|---|---|
| $s$ | 0 | source |
| $b$ | 1 | $s\to b$ |
| $a$ | 3 | $b\to a$: $1+2$ beats $s\to a$: 2 |
| $d$ | 7 | $a\to d$: $3+4$ beats $b\to d$: $1+1$ |
| $t$ | 10 | $d\to t$: $7+3$ beats $a\to t$: $3+2$ |

![[18_ShortestPath.pdf#page=17]]
*Figure: the longest-path DP filling $ld$ in topological order. (`18_ShortestPath.pdf` p. 17)*

### 5.2 Critical paths: longest path with weights on vertices

Jobs are vertices, an edge $u\to v$ means job $u$ must finish before $v$ starts, and each vertex
has a duration. The minimum makespan is the longest **vertex-weighted** path. Convert it to an
edge-weighted problem by splitting each vertex or by putting $w(u,v)=w(v)$ on every edge and
adding a super-source.

![[18_ShortestPath.pdf#page=18]]
*Figure: five jobs; the critical path is $a\to d\to f$ with duration $5+4+6=15$. (`18_ShortestPath.pdf` p. 18)*

**In plain words.** Five chores have to be done in a fixed order, and some can run in parallel.
The whole day is only as short as the longest chain of chores that must wait for one another; any
chore not on that chain has slack and can be done while the chain waits.

**Example (traced).** Vertices $a=5$, $b=7$, $c=3$, $d=4$, $f=6$; edges $a\to b$, $a\to d$,
$c\to d$, $d\to f$. With edge weight equal to the *target's* duration:

| chain | sum |
|---|---|
| $a\to b$ | $5+7=12$ |
| $a\to d\to f$ | $5+4+6=15$ |
| $c\to d\to f$ | $3+4+6=13$ |

The longest is $a\to d\to f=15$, which is the deck's answer.

![[18_ShortestPath.pdf#page=19]]
*Figure: the vertex-weight recurrence $ld[v]=\max\{ld[u]\}+w(v)$ and its $O(V+E)$ algorithm. (`18_ShortestPath.pdf` p. 19)*

> [!warning] Longest path is easy only because the graph is a DAG
> In a general graph, finding a longest simple path is NP-hard. A cycle lets you loop and inflate
> the value, and even without cycles the number of simple paths is exponential. Topological order
> is the entire reason this problem is linear here.

---

## 6. Two more DAG exercises: LIS and path counting

### 6.1 Longest increasing subsequence

Given $a_1,\dots,a_n$, build a DAG with a vertex per element and an edge $a_i\to a_j$ whenever
$i<j$ and $a_i<a_j$. Add a super-source connected to every vertex. An increasing subsequence is
exactly a path, so the LIS length is the longest path from the super-source.

![[18_ShortestPath.pdf#page=20]]
*Figure: the sequence $5,2,8,6,3,6,9,7$ turned into a DAG; the LIS has length 4. (`18_ShortestPath.pdf` p. 20)*

**In plain words.** Lay the numbers out in their original order and draw an arrow from every
number to every later, larger number. A chain of arrows is an increasing subsequence, and the
longest chain is the answer. On the deck's list, $2\to 3\to 6\to 9$ and $2\to 3\to 6\to 7$ are both
chains of four; no chain of five exists.

**Example (traced).** For $5,2,8,6,3,6,9,7$, one optimal chain is
$2 \to 3 \to 6 \to 9$: indices $2<5<6<7$ and values $2<3<6<9$. Its length is 4. The DAG has
$O(n^2)$ edges, so the one-pass longest-path DP takes $O(n^2)$ time; the $O(n\log n)$ LIS
algorithm uses a different idea.

### 6.2 Counting distinct paths

Let $d[u]$ be the number of distinct $s$–$u$ paths. Set $d[s]=1$ and $d[u]=0$ otherwise. In
topological order, push each vertex's count forward:

$$d[v] \mathrel{+}= d[u] \qquad \text{for every } v \in \operatorname{Adj}(u).$$

![[18_ShortestPath.pdf#page=21]]
*Figure: the six distinct $s$–$t$ paths in the example DAG. (`18_ShortestPath.pdf` p. 21)*

**In plain words.** Count the ways to reach each junction. Every route that reaches $u$ can be
extended along each road out of $u$, so the count at the next junction is the sum of the counts of
all its incoming junctions. Doing this in order avoids counting the same route twice.

**Example (traced).** Edges $s\to a$, $s\to b$, $a\to c$, $a\to b$, $a\to d$, $b\to c$, $b\to d$,
$c\to t$, $d\to t$. Processing $s,a,b,c,d,t$:

| vertex | incoming contributions | $d$ |
|---|---|---|
| $s$ | start | 1 |
| $a$ | from $s$ | 1 |
| $b$ | from $s$: 1, from $a$: 1 | 2 |
| $c$ | from $a$: 1, from $b$: 2 | 3 |
| $d$ | from $a$: 1, from $b$: 2 | 3 |
| $t$ | from $c$: 3, from $d$: 3 | 6 |

![[18_ShortestPath.pdf#page=22]]
*Figure: the counts propagating in topological order, ending at $d[t]=6$. (`18_ShortestPath.pdf` p. 22)*

> [!tip] Counts, not paths
> The number of paths can be exponential in $n$, so never enumerate them. The DP stores only the
> counts, and the arithmetic is exact integer addition.

---

## 7. Dijkstra: always settle the closest vertex

**Idea.** Maintain a set $S$ of vertices whose distance is final. Repeatedly extract from
$V-S$ the vertex $v$ with minimum $v.d$, add it to $S$, and relax its outgoing edges.

**Key lemma.** If all edges leaving $S$ have been relaxed and $v$ is the minimum-$d$ vertex outside
$S$, then $v.d=\delta(s,v)$ (assuming nonnegative weights).

![[18_ShortestPath.pdf#page=23]]
*Figure: the explored set $S$ and the closest vertex $v$ outside it. (`18_ShortestPath.pdf` p. 23)*

**Algorithm (decrease-key version).**

```text
Dijkstra(G, s):
    for each v: v.d <- INFINITY; v.p <- nil; v.color <- white
    s.d <- 0
    insert all vertices into min-heap Q keyed by d
    while Q is not empty
        u <- Extract-Min(Q)
        u.color <- black
        for each v in Adj[u]
            if v.color = white and u.d + w(u,v) < v.d then
                v.p <- u
                v.d <- u.d + w(u,v)
                Decrease-Key(Q, v, v.d)
```

![[18_ShortestPath.pdf#page=24]]
*Figure: Dijkstra with a decrease-key heap, $O(E\log V)$. (`18_ShortestPath.pdf` p. 24)*

**Cost.** $O(\lvert E\rvert\log\lvert V\rvert)$ with a binary heap; $O(\lvert V\rvert^2)$ with an
array, which is better for dense graphs. The insert-duplicates variant (p. 26) skips stale
black entries and has the same bound.

**In plain words.** You drop a stone into a pond but the ripples travel at different speeds on
different channels. The nearest unvisited place is always safe to declare finished: every other
route to it would have to pass through somewhere at least as far away, and because no channel has
a negative cost, that detour cannot arrive cheaper. This is why a negative edge breaks the
argument — a "detour" can arrive *cheaper* than the place you already declared finished.

**Example (traced, deck's p. 25 graph).** Edges: $s\to t\,10$, $s\to y\,5$, $y\to t\,3$,
$y\to x\,9$, $y\to z\,2$, $z\to x\,6$, $z\to s\,7$, $t\to x\,1$, $x\to z\,4$.

| extracted | $t$ | $x$ | $y$ | $z$ | relaxations |
|---|---|---|---|---|---|
| $s$ | 10 | $\infty$ | 5 | $\infty$ | $s\to t$, $s\to y$ |
| $y$ | 8 | 14 | 5 | 7 | $y\to t$: $5+3$; $y\to x$: $5+9$; $y\to z$: $5+2$ |
| $t$ | 8 | 9 | 5 | 7 | $t\to x$: $8+1$ beats 14 |
| $z$ | 8 | 9 | 5 | 7 | $z\to x$: $7+6=13$ no |
| $x$ | 8 | 9 | 5 | 7 | $x\to z$: $9+4=13$ no |

Final: $\delta(s,t)=8$, $\delta(s,x)=9$, $\delta(s,y)=5$, $\delta(s,z)=7$. The parent pointers
$p[t]=y$, $p[y]=s$, $p[z]=y$, $p[x]=t$ form the shortest-path tree.

![[18_ShortestPath.pdf#page=25]]
*Figure: Dijkstra growing the shortest-path tree one extracted vertex at a time. (`18_ShortestPath.pdf` p. 25)*

**Correctness (proof sketch).** Suppose the extracted $v$ has $v.d>\delta(s,v)$. Take a shortest
$s$–$v$ path and let $x\to y$ be its first edge leaving $S$. Because $x\in S$, $x.d=\delta(s,x)$;
the edge was relaxed, so $y.d\le \delta(s,y)$. Nonnegative weights give
$\delta(s,y)\le\delta(s,v)$, hence $y.d\le\delta(s,v)<v.d$, contradicting that $v$ has the
smallest $d$ outside $S$.

![[18_ShortestPath.pdf#page=27]]
*Figure: the first edge $x\to y$ leaving $S$ on a shortest path to $v$. (`18_ShortestPath.pdf` p. 27)*

> [!important] Where nonnegative weights are used
> The inequality $\delta(s,y)\le\delta(s,v)$ is false if a later edge can have negative weight.
> That single step is the whole reason Dijkstra cannot handle negative edges.

### 7.1 The negative-weight failure, and why reweighting fails

On the graph $s\to u\,2$, $u\to v\,3$, $v\to t\,-6$, $s\to t\,1$, Dijkstra extracts $t$ with
$d=1$ and finalises it. But the route $s\to u\to v\to t$ costs $2+3-6=-1$, so the true
$\delta(s,t)=-1$.

![[18_ShortestPath.pdf#page=28]]
*Figure: Dijkstra finalises $t$ too early when a later negative edge can undercut it. (`18_ShortestPath.pdf` p. 28)*

**In plain words.** Dijkstra is a traveller who refuses to reopen a town once visited. Here the
direct road reaches the destination for 1, so the traveller stamps "done". Only afterwards does the
long way round through two towns and a rebate turn out to cost $-1$; the stamp cannot be undone.

**Why adding a constant to every edge does not repair it.** Adding $c$ to every edge adds
$c\cdot(\text{number of edges})$ to a path, not the same $c$ to every path. A route with more edges
is penalised more, so the relative order of two routes can flip. Concretely (my own instance):
route $A$ has 2 edges of weight 0 (total 0), route $B$ has 1 edge of weight 1 (total 1). Before
reweighting $A$ wins; after adding 2 to every edge, $A=4$ and $B=3$, so $B$ wins. The deck's second
graph makes the same point with a two-edge versus a three-edge route.

### 7.2 LeetCode 1368: 0–1 weights

Each grid cell points to a neighbour. Model cells as vertices; an edge costs 0 if it follows the
arrow and 1 if it requires changing the sign. Find the cheapest path from $(0,0)$ to
$(m-1,n-1)$.

![[18_ShortestPath.pdf#page=29]]
*Figure: the grid of arrows and the fewest sign changes needed. (`18_ShortestPath.pdf` p. 29)*

**In plain words.** Every step you take in the direction of the printed arrow is free; every step
against it costs one erasure. You want the route that needs the fewest erasures. There are only
two prices, free and one, so you can keep two buckets of frontier cells instead of a full
priority queue.

**Example (traced).** The deck's first example needs **0** changes because the arrows already
lead from the top-left to the bottom-right. The second needs **1**: the path must make one turn
against an arrow. With only 0/1 weights, the heap's keys are always `min` or `min+1`, so two FIFO
lists replace the heap and the bound improves from $O(mn\log(mn))$ to $O(mn)$.

![[18_ShortestPath.pdf#page=30]]
*Figure: the 0/1 graph model and the two-list optimisation. (`18_ShortestPath.pdf` p. 30)*

---

## 8. All-pairs shortest paths

**Input/output.** For every ordered pair $(u,v)$, compute $\delta(u,v)$, plus enough information
to reconstruct each path. Storing every path explicitly would take $O(\lvert V\rvert^3)$ space, so
we store only distances and a predecessor/intermediate table.

**The obvious solutions.**

| Method | Time | Works with negative edges? |
|---|---|---|
| Dijkstra from every vertex | $O(\lvert V\rvert\lvert E\rvert\log\lvert V\rvert)$ | no |
| Bellman–Ford from every vertex | $O(\lvert V\rvert^2\lvert E\rvert)$ | yes |

For dense graphs the second is $O(n^4)$, which motivates the DP solutions below.

![[18_ShortestPath.pdf#page=32]]
*Figure: running the single-source algorithms once per source, and their costs. (`18_ShortestPath.pdf` p. 32)*

### 8.1 DP by number of edges (solution 1)

Let $d_{ij}^{(m)}$ be the length of the shortest $i$–$j$ path using at most $m$ edges. Then

$$d_{ij}^{(m)} = \min_{1\le k\le n}\bigl\{d_{ik}^{(m-1)} + w(k,j)\bigr\}, \qquad d_{ij}^{(1)}=w(i,j).$$

Compute $D^{(1)},D^{(2)},\dots,D^{(n-1)}$; the last is the answer. Each matrix costs $O(n^3)$, so
the total is $O(n^4)$ time and $O(n^3)$ space (reducible to $O(n^2)$ by keeping two matrices).

![[18_ShortestPath.pdf#page=33]]
*Figure: the recurrence "last stop before $j$ is $k$", for at most $m$ edges. (`18_ShortestPath.pdf` p. 33)*

**In plain words.** Imagine a courier allowed at most one flight on day one, at most two flights on
day two, and so on. The best trip with at most $m$ flights is found by trying every possible last
stop $k$: take the best trip to $k$ with at most $m-1$ flights and add the flight $k\to j$. After
$n-1$ days every simple route has been considered.

**Example (traced, deck's matrices).** The five-node graph has

$$D^{(1)}=\begin{pmatrix}
0 & 3 & 8 & \infty & -4\\
\infty & 0 & \infty & 1 & 7\\
\infty & 4 & 0 & \infty & \infty\\
2 & \infty & -5 & 0 & \infty\\
\infty & \infty & \infty & 6 & 0
\end{pmatrix}.$$

For the entry $(3,5)$, the deck shows the sequence

$$d^{(1)}_{3,5}=\infty,\quad d^{(2)}_{3,5}=11,\quad d^{(3)}_{3,5}=11,\quad d^{(4)}_{3,5}=3.$$

The value 11 at $m=2$ comes from $k=2$: $d^{(1)}_{3,2}+w(2,5)=4+7=11$. The value 3 at $m=4$
comes from $k=4$: $d^{(3)}_{3,4}+w(4,5)=5+(-2)=3$.

![[18_ShortestPath.pdf#page=35]]
*Figure: the four matrices $D^{(1)},\dots,D^{(4)}$ for the five-node example. (`18_ShortestPath.pdf` p. 35)*

### 8.2 Repeated squaring (solution 2)

Instead of extending by one edge at a time, combine two $s$-edge solutions:

$$d_{ij}^{(2s)} = \min_{1\le k\le n}\bigl\{d_{ik}^{(s)} + d_{kj}^{(s)}\bigr\}.$$

Compute $D^{(1)},D^{(2)},D^{(4)},D^{(8)},\dots$; after $O(\log n)$ matrix products the result is
$D^{(n')}$ with $n'>n-1$. Overshooting is harmless: a shortest simple path never needs more than
$n-1$ edges, and $D^{(n')}=D^{(n-1)}$ for every $n'>n-1$.

**Cost.** $O(n^3\log n)$ time, $O(n^2)$ space.

![[18_ShortestPath.pdf#page=40]]
*Figure: doubling the allowed edge count and why overshooting is still correct. (`18_ShortestPath.pdf` p. 40)*

**In plain words.** Rather than adding one flight at a time, double the ticket's allowance: the
best trip with at most $2s$ flights is the best trip with at most $s$ flights joined to another
such trip. After a handful of doublings the allowance exceeds any simple route, so the answer is
already exact.

---

## 9. Floyd–Warshall: allow one intermediate vertex at a time

**Definition.** $d_{ij}^{(k)}$ is the length of the shortest $i$–$j$ path whose **intermediate**
vertices all lie in $\{1,\dots,k\}$. The endpoints $i$ and $j$ may be anything. Initially
$d_{ij}^{(0)}=w(i,j)$, with $w(i,i)=0$ and $w(i,j)=\infty$ when there is no edge.

**Recurrence.** Either vertex $k$ is not used as an intermediate vertex, or it is:

$$d_{ij}^{(k)} = \min\bigl\{d_{ij}^{(k-1)},\ d_{ik}^{(k-1)}+d_{kj}^{(k-1)}\bigr\}.$$

The answer is $D^{(n)}$.

![[18_ShortestPath.pdf#page=46]]
*Figure: the two cases — $k$ unused, or $k$ splitting the path into $i\to k$ and $k\to j$. (`18_ShortestPath.pdf` p. 46)*

**Algorithm (in-place).**

```text
Floyd-Warshall(G):
    d[i][j] <- w(i,j);  intermedi[i][j] <- 0
    for k <- 1 to n
        for i <- 1 to n
            for j <- 1 to n
                if d[i][k] + d[k][j] < d[i][j] then
                    d[i][j] <- d[i][k] + d[k][j]
                    intermedi[i][j] <- k
    return D
```

**Cost.** $O(n^3)$ time, $O(n^2)$ space.

![[18_ShortestPath.pdf#page=47]]
*Figure: the triple loop and the observation that the superscripts can be dropped. (`18_ShortestPath.pdf` p. 47)*

**In plain words.** Imagine a map where you are only allowed to change trains in the first $k$
cities. Adding city $k+1$ to the allowed set gives one new option: go from $i$ to $k+1$ using only
old cities, then from $k+1$ to $j$ using only old cities. Try that against the old best route and
keep the cheaper. After every city has been added, all routes are allowed.

**Example (traced, deck's $d_{5,6}$).** The deck tracks one entry as the allowed intermediate set
grows:

| allowed set | $d_{5,6}$ | route |
|---|---|---|
| $\varnothing$ | $\infty$ | no path |
| $\{1\}$ | 13 | $5\to 1\to 6$ |
| $\{1,2\}$ | 9 | $5\to 2\to 6$ |
| $\{1,2,3\}$ | 8 | $5\to 3\to 2\to 6$ |
| $\{1,2,3,4\}$ | 6 | $5\to 4\to 1\to 6$ |

Each improvement uses the newly allowed vertex as the split point. The final value 6 is the true
shortest-path distance.

![[18_ShortestPath.pdf#page=44]]
*Figure: the entry $d_{5,6}$ improving as vertices 1, 2, 3 enter the allowed set. (`18_ShortestPath.pdf` p. 44)*

**Why one array suffices.** At the start of iteration $k$, $d_{ik}$ and $d_{kj}$ have not yet been
overwritten by anything that uses $k$ as an intermediate vertex, because that would require a path
through $k$ to itself. With $w(k,k)=0$ and no negative cycles, using $k$ twice never helps, so
$d_{ik}^{(k)}=d_{ik}^{(k-1)}$ and $d_{kj}^{(k)}=d_{kj}^{(k-1)}$. The in-place update therefore
computes the same recurrence as the two-matrix version.

### 9.1 Reconstructing a path

`intermedi[i][j]` records one vertex on the shortest $i$–$j$ path, or `nil` if the path is a single
edge.

```text
Path(i, j):
    if intermedi[i][j] = nil then output (i, j)
    else
        Path(i, intermedi[i][j])
        Path(intermedi[i][j], j)
```

The recursion takes time proportional to the number of edges on the path.

![[18_ShortestPath.pdf#page=49]]
*Figure: recursively splitting at `intermedi[i][j]` reconstructs the path. (`18_ShortestPath.pdf` p. 49)*

### 9.2 Negative-cycle detection with Floyd–Warshall

Run Floyd–Warshall normally. If after the run any $d_{ii}<0$, vertex $i$ lies on a negative cycle.
The proof uses the highest-numbered vertex $k$ on the smallest negative cycle: when $k$ is added
to the allowed set, $d_{ii}^{(k)}$ becomes negative.

![[18_ShortestPath.pdf#page=51]]
*Figure: a negative cycle $4\to 3\to 2\to 4$ of total weight $-1$. (`18_ShortestPath.pdf` p. 51)*

**In plain words.** A town that can reach itself for a negative fare is a money pump. Floyd–
Warshall tests every town against itself; the first negative diagonal entry exposes the pump.
On the deck's graph, $4\to 3\to 2\to 4$ costs $1+(-3)+1=-1$, so $d_{4,4}$ ends up negative.

**Cost comparison.** Floyd–Warshall is $O(\lvert V\rvert^3)$, the same as Bellman–Ford on a dense
graph ($O(\lvert V\rvert\lvert E\rvert)=O(\lvert V\rvert^3)$), but Bellman–Ford is better on sparse
graphs.

### 9.3 Transitive closure

Given an unweighted directed graph, $G^*$ has an edge $i\to j$ whenever $G$ has **any** path
$i\rightsquigarrow j$. Two solutions:

| Solution | Idea | Cost |
|---|---|---|
| Via shortest paths | set $w(i,j)=1$ if an edge exists, $\infty$ otherwise; run Floyd–Warshall; set $a^*_{ij}=1$ iff $d_{ij}<\infty$ | $O(n^3)$ |
| Boolean Floyd–Warshall | $T^{(k)}_{ij}=T^{(k-1)}_{ij}\lor\bigl(T^{(k-1)}_{ik}\land T^{(k-1)}_{kj}\bigr)$ | $O(n^3)$ |

The boolean version is faster in practice (bit operations, smaller matrix) and uses the same
recurrence shape.

![[18_ShortestPath.pdf#page=54]]
*Figure: the boolean recurrence for transitive closure. (`18_ShortestPath.pdf` p. 54)*

**In plain words.** Instead of asking "how far", ask "can I get there at all". The same
intermediate-city loop works, with "or" replacing "min" and "and" replacing "+", so a route exists
if it existed before or if both halves exist through the newly allowed city.

---

## 10. Highlights

*(The deck's summary table, reworded.)*

| Algorithm | Problem | Representation | Time | Space |
|---|---|---|---|---|
| Bellman–Ford | single source, negative edges | adjacency list | $O(\lvert V\rvert\lvert E\rvert)$ | $O(\lvert V\rvert)$ |
| DAG shortest path | single source, DAG | adjacency list | $O(\lvert V\rvert+\lvert E\rvert)$ | $O(\lvert V\rvert)$ |
| Dijkstra | single source, nonnegative weights | adjacency list | $O(\lvert E\rvert\log\lvert V\rvert)$ | $O(\lvert V\rvert)$ |
| All-pairs 1 (edge-count DP) | all pairs | adjacency matrix | $O(\lvert V\rvert^4)$ | $O(\lvert V\rvert^2)$ |
| All-pairs 2 (repeated squaring) | all pairs | adjacency matrix | $O(\lvert V\rvert^3\log\lvert V\rvert)$ | $O(\lvert V\rvert^2)$ |
| Floyd–Warshall | all pairs, negative edges | adjacency matrix | $O(\lvert V\rvert^3)$ | $O(\lvert V\rvert^2)$ |

- **Subpath optimality** is the structural fact behind every recurrence: an optimal path is made
  of optimal subpaths.
- **Relaxation** is the common primitive; the algorithms differ only in *which edges* they relax
  and *in what order*.
- **Bellman–Ford** is correct because every shortest simple path has at most $\lvert V\rvert-1$
  edges; the extra round detects negative cycles.
- **DAG order** removes the need for repeated rounds: one pass, because every predecessor is final
  before its outgoing edges are relaxed.
- **Dijkstra** finalises the closest unvisited vertex; nonnegative weights make that safe.
- **Floyd–Warshall** adds one allowed intermediate vertex per outer iteration, so it handles
  negative edges but not negative cycles.
- **All-pairs** by repeated Dijkstra is $O(\lvert V\rvert\lvert E\rvert\log\lvert V\rvert)$;
  Floyd–Warshall is simpler and better on dense graphs.
- **Transitive closure** is Floyd–Warshall with boolean arithmetic.

## 11. Exam traps

- **"Dijkstra works with negative edges if the graph has no negative cycle."** $\to$ false. The
  counterexample in Section 7.1 has no cycle at all; Dijkstra still finalises $t$ at 1 instead of
  $-1$. Nonnegative weights are required, not merely no negative cycles.
- **"Bellman–Ford needs exactly $\lvert V\rvert$ passes."** $\to$ $\lvert V\rvert-1$ passes compute
  all distances; pass $\lvert V\rvert$ is only the negative-cycle test. Early termination is
  allowed and does not change correctness.
- **"A negative edge somewhere means a negative cycle."** $\to$ no. A negative edge is fine; only a
  *cycle* of negative total weight breaks the problem.
- **"The longest path in a DAG is NP-hard."** $\to$ no; it is $\Theta(\lvert V\rvert+\lvert E\rvert)$
  by the same topological DP. The NP-hard version is on general graphs, where cycles and
  exponentially many simple paths appear.
- **"LIS is solved by the longest-path algorithm in the original array order."** $\to$ you must
  build the DAG with an edge for every increasing pair $i<j$, $a_i<a_j$; otherwise a path can skip
  a non-increasing pair and still look valid.
- **"Count distinct paths by multiplying degrees."** $\to$ that counts walks or assumes a layered
  graph. The correct recurrence is $d[v]=\sum_{u\to v} d[u]$ in topological order, with $d[s]=1$.
- **"Floyd–Warshall's outer loop can be the $i$ or $j$ loop."** $\to$ no. $k$ must be outermost so
  that $d_{ik}$ and $d_{kj}$ already allow exactly the vertices smaller than $k$.
- **"Floyd–Warshall needs three matrices."** $\to$ one $n\times n$ matrix suffices; the in-place
  argument is in Section 9.
- **"If $d_{ii}<0$ the graph has a negative edge."** $\to$ a negative diagonal means a negative
  **cycle through $i$**, not merely an edge.
- **"Reweighting by adding a constant preserves shortest paths."** $\to$ false; it adds a different
  amount to paths with different numbers of edges. Johnson's algorithm instead uses vertex
  potentials chosen so that every edge becomes nonnegative.
- **"All-pairs shortest paths need $O(\lvert V\rvert^3)$ space to store the paths."** $\to$ distances
  plus predecessors/intermediates take $O(\lvert V\rvert^2)$; reconstruct on demand.
- **"Bellman–Ford's extra pass works even if $s$ cannot reach all vertices."** $\to$ only for
  cycles reachable from $s$. Use a super-source or test each strongly connected component.
- **"A shorter path always has fewer edges."** $\to$ only when all weights are positive and equal.
  With arbitrary weights, the cheapest route may use more edges; that is why the edge-count DP
  needs the full $\lvert V\rvert-1$ layers.
