# Lecture 19 — Maximum Flow

> Source: `19_MaxFlow.pdf` (59 pages). Goal: send as much as possible from a source to a sink
> through capacity-limited pipes, prove that no more can be sent, and recognise unrelated problems
> (matching, scheduling, baseball elimination) that are secretly the same problem. Uses the BFS
> of [[lec_16_basic_graph_algorithms]] and the cuts of [[lec_17_minimum_spanning_trees]] — but a
> cut here has a direction and a capacity, not a weight.

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The flow problem:** [[terms/max-flow|Flow, value and maximum flow]] · [[terms/s-t-cut|s-t cut, capacity and the min-cut theorem]] · [[terms/residual-graph|Residual graph]] · [[terms/Ford-Fulkerson|Ford–Fulkerson and Edmonds–Karp]]

**Applications:** [[terms/bipartite-matching|Bipartite matching]] · [[terms/max-flow-applications|Circulation, disjoint paths and baseball elimination]] · [[terms/bipartite|Bipartite graph]] · [[terms/queue|Queue (FIFO)]]

**Graphs:** [[terms/graph]] · [[terms/adjacency-list]] · [[terms/big-O]]

---

## 1. What a flow is

**Motivate.** Water in pipes, packets in a network, cars on roads, current in wires — all move
through a network with limited capacity. The question is always the same: *what is the largest
rate at which material can be pushed from the source to the sink without exceeding any pipe and
without leaking or piling up at intermediate junctions?*

**Define.** Input: a directed connected graph $G=(V,E)$, a capacity $c(e)>0$ on every edge, a
source $s$ and a target $t$. A flow is a function $f:E\to\mathbb{R}$ satisfying

$$0\le f(e)\le c(e) \quad\text{(capacity)}, \qquad
\sum_{e\text{ out of }v} f(e)=\sum_{e\text{ into }v} f(e) \quad\text{(conservation)}$$

for every $v\notin\{s,t\}$. The **value** of the flow is the net amount leaving $s$:

$$\lvert f\rvert = \sum_{v} f(s,v) = \sum_{v} f(v,t).$$

![[19_MaxFlow.pdf#page=2]]
*Figure: a graph with capacities and a feasible flow of value 4; each edge shows capacity over flow. (`19_MaxFlow.pdf` p. 2)*

**In plain words.** A water network has pipes of different widths. At every junction, the water
arriving must equal the water leaving — nothing is created or stored. The value is the total
outflow at the source, which by conservation is also the total inflow at the sink. You want the
largest possible value.

**Example (traced).** The deck's graph has value 4. Check conservation at one junction: if 4 units
enter and 4 leave, the junction is balanced. The value is the sum of the flows on the edges out of
$s$, and also the sum on the edges into $t$; both equal 4.

**Applications.** Direct: water, electricity, traffic, communication. Indirect: bipartite
matching, circulation with demands, baseball elimination, airline scheduling, fair car sharing.

![[19_MaxFlow.pdf#page=3]]
*Figure: direct and indirect applications of maximum flow. (`19_MaxFlow.pdf` p. 3)*

> [!important] Integrality is not assumed, but it comes for free
> Capacities in the examples are integers. Ford–Fulkerson then produces an integer flow on every
> edge, because every augmentation adds or subtracts an integer. That is what makes the
> combinatorial applications (matching, paths, baseball) exact.

---

## 2. Cuts: the upper bound

**Define.** An **s-t cut** is a partition $(S,T)$ of $V$ with $s\in S$ and $t\in T$. Its capacity
is the total capacity of edges going from $S$ to $T$:

$$c(S,T)=\sum_{e\text{ from }S\text{ to }T} c(e).$$

Edges going from $T$ back to $S$ do **not** count toward the capacity.

**Claim.** For every flow $f$ and every s-t cut $(S,T)$,

$$\lvert f\rvert \le c(S,T).$$

![[19_MaxFlow.pdf#page=5]]
*Figure: a cut with capacity $10+8+10=28$, which upper-bounds every flow. (`19_MaxFlow.pdf` p. 5)*

**In plain words.** Draw a line around the source side of the network. All the water that reaches
the sink must at some point cross that line from the source side to the sink side. The pipes
crossing forward can carry at most their total capacity, and pipes pointing backward do not help.
So the cut's capacity is a ceiling on the flow. If you find a flow that hits the ceiling, you have
proved it is optimal.

**Example (traced).** For the cut in the deck's graph with $S=\{s,3,4,7\}$, the forward edges are
$s\to 2$ (capacity 10), $4\to 5$ (8) and $7\to t$ (10), so $c(S,T)=28$. The deck exhibits a flow of
value 28, which meets the ceiling and is therefore maximum.

**Assumptions.** No antiparallel edges (if both $u\to v$ and $v\to u$ exist, split one with an
auxiliary vertex), no edges into $s$, no edges out of $t$. These simplify the residual construction
and can always be arranged.

![[19_MaxFlow.pdf#page=6]]
*Figure: removing antiparallel edges with an auxiliary vertex; the other two assumptions. (`19_MaxFlow.pdf` p. 6)*

---

## 3. Why greedy augmentation fails

**Greedy idea.** Start with $f=0$. Find any $s$–$t$ path whose edges all have spare capacity, push
the bottleneck amount along it, and repeat until no such path exists.

**What goes wrong.** On the deck's four-node graph the greedy path $s\to 1\to 2\to t$ pushes 20.
Then $s\to 2\to t$ can still push 5, for a total of 25. Now no path with spare capacity remains,
yet the maximum is 30. Greedy got stuck at a local optimum because it committed 20 units to the
middle edge $1\to 2$, which was a bad routing decision.

![[19_MaxFlow.pdf#page=12]]
*Figure: greedy reaches 25; the optimum is 30. (`19_MaxFlow.pdf` p. 12)*

**In plain words.** A dispatcher sends the first big convoy along the only route that looks open,
and that convoy fills a narrow middle bridge. Later convoys find the bridge full even though a
different split of the same traffic would have used the wide direct roads. The dispatcher needs a
way to *change their mind* about earlier convoys, not just to add new ones.

**Example (traced).** Capacities: $s\to1\,20$, $s\to2\,10$, $1\to2\,30$, $1\to t\,10$, $2\to t\,25$.

| step | path | bottleneck | flow value |
|---|---|---|---|
| 1 | $s\to1\to2\to t$ | $\min(20,30,25)=20$ | 20 |
| 2 | $s\to2\to t$ | $\min(10,5)=5$ | 25 |
| 3 | no path with spare forward capacity | — | 25 (stuck) |

The optimal routing is $s\to1\to t$ (10), $s\to1\to2\to t$ (10) and $s\to2\to t$ (10), total 30.
Greedy put 20 through $1\to2$ instead of 10, consuming capacity that the direct edge $1\to t$
could have used.

![[19_MaxFlow.pdf#page=7]]
*Figure: the four-node network before any flow. (`19_MaxFlow.pdf` p. 7)*

> [!important] Local optimality is not global optimality
> Filling an edge is not the same as filling the cut. The residual graph in Section 4 is what lets
> the algorithm undo a bad early decision.

---

## 4. The residual graph: how to undo a decision

**Define.** Given a flow $f$, the **residual capacity** of an edge is what is left in the forward
direction plus what can be cancelled in the backward direction:

$$c_f(u,v)=c(u,v)-f(u,v), \qquad c_f(v,u)=f(u,v).$$

The residual graph $G_f$ has the same vertices and, for each original edge, up to two residual
edges: a forward edge with the remaining capacity and a backward edge with the amount currently
flowing.

| Original state | Residual edges |
|---|---|
| $f(u,v)=0$ | $(u,v)$ with capacity $c(u,v)$ |
| $f(u,v)=c(u,v)$ | $(v,u)$ with capacity $c(u,v)$ |
| $0<f(u,v)<c(u,v)$ | $(u,v)$ with $c-f$ and $(v,u)$ with $f$ |

![[19_MaxFlow.pdf#page=13]]
*Figure: the three cases for building residual edges. (`19_MaxFlow.pdf` p. 13)*

**In plain words.** A residual backward edge is a refund voucher. If you already sent 6 units down
a pipe, a later courier may "send" up to 6 units backward along that pipe, which in the real
network means cancelling 6 units of the earlier shipment and freeing that capacity for a better
route. The voucher does not create water; it reallocates the water you already committed.

**Example (traced, deck's graph).** With the flow of value 16 shown on p. 14:

| original edge | capacity | flow | residual forward | residual backward |
|---|---|---|---|---|
| $s\to2$ | 10 | 10 | 0 | 10 |
| $s\to3$ | 10 | 6 | 4 | 6 |
| $2\to3$ | 2 | 2 | 0 | 2 |
| $2\to4$ | 4 | 0 | 4 | 0 |
| $2\to5$ | 8 | 8 | 0 | 8 |
| $3\to5$ | 9 | 8 | 1 | 8 |
| $4\to5$ | 6 | 6 | 0 | 6 |
| $4\to t$ | 10 | 6 | 4 | 6 |
| $5\to t$ | 10 | 10 | 0 | 10 |

For instance, $2\to5$ is full (8/8), so the residual graph has only $5\to2$ with capacity 8.
That backward edge lets a later augmentation reroute some of those 8 units through a different
exit from 2.

![[19_MaxFlow.pdf#page=14]]
*Figure: a flow $f$ of value 16 and its residual graph $G_f$. (`19_MaxFlow.pdf` p. 14)*

---

## 5. Ford–Fulkerson

**Algorithm.** Keep augmenting along any path in the residual graph until no $s$–$t$ path remains.
Each augmentation pushes the path's bottleneck residual capacity; forward edges increase their
flow, backward edges decrease it.

```text
Ford-Fulkerson(G, s, t):
    for each edge (u, v) in E
        f(u, v) <- 0
        cf(u, v) <- c(u, v);  cf(v, u) <- 0
    while there is an s-t path p in the residual graph Gf
        cf(p) <- min{ cf(e) : e in p }
        for each edge (u, v) in p
            if (u, v) is a forward edge then
                f(u, v) <- f(u, v) + cf(p)
                cf(u, v) <- cf(u, v) - cf(p)
                cf(v, u) <- cf(v, u) + cf(p)
            else                                  // (u, v) is a backward edge
                f(v, u) <- f(v, u) - cf(p)
                cf(v, u) <- cf(v, u) + cf(p)
                cf(u, v) <- cf(u, v) - cf(p)
```

![[19_MaxFlow.pdf#page=15]]
*Figure: Ford–Fulkerson with explicit forward/backward updates. (`19_MaxFlow.pdf` p. 15)*

**In plain words.** The dispatcher keeps looking for any route with spare room in the *residual*
network. A residual route may use a refund voucher, which cancels part of an earlier shipment and
frees the bridge for a better route. When no route remains, every crossing of every cut is either
full or empty in the right direction, and the flow cannot be improved.

**Example (traced, repairing greedy).** Use the four-node graph above. After greedy reaches 25,
build the residual graph. The path $s\to2\to1\to t$ exists:

| residual edge | capacity | meaning |
|---|---|---|
| $s\to2$ | 5 | spare forward capacity |
| $2\to1$ | 20 | cancel part of the 20 units on $1\to2$ |
| $1\to t$ | 10 | spare forward capacity |

The bottleneck is $\min(5,20,10)=5$. Augmenting this path adds 5 to the value (from 25 to 30),
sends 5 more from $s$ to 2, cancels 5 of the $1\to2$ flow, and sends 5 more from 1 to $t$. The new
flow is

$$f(s,1)=20,\quad f(s,2)=10,\quad f(1,2)=15,\quad f(1,t)=5,\quad f(2,t)=25,$$

with value $5+25=30$. No residual $s$–$t$ path remains. The cut $S=\{s\}$ has capacity
$c(s,1)+c(s,2)=20+10=30$, so this flow meets the cut's ceiling and is certified maximum. (The cut
$S=\{s,1\}$ has capacity $c(1,t)+c(1,2)=10+30=40$; it is a valid but non-tight upper bound.)

![[19_MaxFlow.pdf#page=20]]
*Figure: a later Ford–Fulkerson augmentation on the deck's animation graph. (`19_MaxFlow.pdf` p. 20)*

> [!important] Ford–Fulkerson does not specify which path
> Any residual path works for correctness. The choice affects only how many iterations are needed
> (Section 7). This is exactly the freedom that Edmonds–Karp narrows to shortest paths.

---

## 6. Net flow, cuts, and the max-flow min-cut theorem

**Net flow across a cut.** For any flow $f$ and cut $(S,T)$,

$$f(S,T)=\sum_{e\text{ from }S\text{ to }T} f(e)-\sum_{e\text{ from }T\text{ to }S} f(e).$$

**Net flow lemma.** For every s-t cut, $f(S,T)=\lvert f\rvert$. The proof sums conservation over
all vertices in $S-\{s\}$ and adds the source's outflow; internal edges cancel in pairs, forward
crossing edges appear once, and backward crossing edges appear once with a minus sign.

![[19_MaxFlow.pdf#page=28]]
*Figure: summing conservation inside $S$ leaves only the cut terms. (`19_MaxFlow.pdf` p. 28)*

**In plain words.** Put a fence around the source side. The net water crossing the fence is the
same no matter where you put the fence, because no water is created or destroyed inside. Water
sloshing back and forth across the fence cancels out; only the net crossing counts, and that net
is the flow's value.

**Example (traced).** On the deck's value-24 flow, the cut drawn across the middle has forward
flows $6,0,8,10$ and a backward flow $1$, so

$$f(S,T)=6+0+8+10-1=24=\lvert f\rvert.$$

A different cut through the same flow gives $6+8+10=24$, the same net value. The deck shows both
arithmetic lines.

![[19_MaxFlow.pdf#page=26]]
*Figure: the same flow across a different cut still nets 24. (`19_MaxFlow.pdf` p. 26)*

**Claim (upper bound).** For every flow and every cut, $\lvert f\rvert\le c(S,T)$:

$$\lvert f\rvert=f(S,T)\le\sum_{S\to T} f(e)\le\sum_{S\to T} c(e)=c(S,T).$$

**Max-flow min-cut theorem.** The following are equivalent:

1. $f$ is a maximum flow.
2. The residual graph $G_f$ has no $s$–$t$ path.
3. $\lvert f\rvert=c(S,T)$ for some s-t cut $(S,T)$.

**Proof sketch.** $(1)\Rightarrow(2)$: a residual path would allow an improvement.
$(2)\Rightarrow(3)$: take $S$ = vertices reachable from $s$ in $G_f$. Since $t\notin S$, this is a
valid cut; every forward edge is full and every backward edge is empty, so $c(S,T)=\lvert f\rvert$.
$(3)\Rightarrow(1)$: the upper-bound claim.

![[19_MaxFlow.pdf#page=32]]
*Figure: the three equivalent statements. (`19_MaxFlow.pdf` p. 32)*

**In plain words.** If any route remains in the refund network, the flow is not maximal. If none
remains, collect all towns you can still reach from the source using refunds; the pipes leaving
that set are exactly the full ones, so their total capacity equals the flow you already have.
That is the certificate of optimality: a flow and a cut of the same size.

**Example (traced).** The value-28 flow in Section 2 and the cut $S=\{s,3,4,7\}$ both equal 28, so
the flow is optimal. No search for a better flow is needed; the matching numbers prove it.

![[19_MaxFlow.pdf#page=31]]
*Figure: a flow and a cut of equal value 28 certify optimality. (`19_MaxFlow.pdf` p. 31)*

---

## 7. Running time and the bad example

**Cost.** One augmentation takes $O(\lvert E\rvert)$ time (find a path with BFS or DFS and update
its edges). If all capacities are integers, each augmentation increases the value by at least 1,
so there are at most $\lvert f^*\rvert$ augmentations and the total is
$O(\lvert f^*\rvert\lvert E\rvert)$.

![[19_MaxFlow.pdf#page=34]]
*Figure: the iteration bound and the integrality property. (`19_MaxFlow.pdf` p. 34)*

**The bad example.** Two middle vertices $U,V$ with a single unit-capacity edge between them, and
large capacities elsewhere. Choosing the augmenting paths $s\to U\to V\to t$, then
$s\to V\to U\to t$, then the first again, and so on, adds only **one unit per augmentation** and
keeps cancelling the previous unit. With capacities of $1{,}000{,}000$ this takes a million
augmentations. Choosing $s\to U\to t$ and $s\to V\to t$ instead finishes in two.

![[19_MaxFlow.pdf#page=35]]
*Figure: the up/down oscillation that makes Ford–Fulkerson slow. (`19_MaxFlow.pdf` p. 35)*

**In plain words.** Two couriers keep using the same narrow footbridge in opposite directions.
Each trip carries one parcel and forces the previous courier to turn around, so a million parcels
take a million trips even though the wide roads on either side could each carry a million at once.
The algorithm is correct but has no sense of direction.

**Edmonds–Karp.** Always choose the **shortest** residual path (fewest edges), found by BFS. Then
Ford–Fulkerson terminates in $O(\lvert V\rvert\lvert E\rvert)$ augmentations, for a total of
$O(\lvert V\rvert\lvert E\rvert^2)$ time. Push–relabel is $O(\lvert V\rvert^2\lvert E\rvert)$ and
usually fast in practice.

![[19_MaxFlow.pdf#page=36]]
*Figure: shortest augmenting paths give the $O(VE^2)$ bound. (`19_MaxFlow.pdf` p. 36)*

> [!warning] Irrational capacities can prevent termination
> With arbitrary real capacities and an unlucky choice of paths, Ford–Fulkerson may never stop.
> Edmonds–Karp's shortest-path rule also fixes this; the $O(VE^2)$ bound is independent of the
> values.

---

## 8. Applications: the same problem in disguise

All the examples below are **integral** flow problems, so the integrality property gives a
combinatorial answer: a set of paths, a matching, a schedule, or a "no".

### 8.1 Circulation with demands

Each source $s_i$ has a supply $\operatorname{sup}(s_i)$; each target $t_i$ has a demand
$\operatorname{dem}(t_i)$. Find a flow that respects capacities and conservation, with each source
sending at most its supply and each target receiving exactly its demand.

**Reduction.** Add a super-source $s$ with an edge of capacity $\operatorname{sup}(s_i)$ to each
$s_i$, and a super-sink $t$ with an edge of capacity $\operatorname{dem}(t_i)$ from each $t_i$.
Compute a maximum flow. A feasible circulation exists iff the max flow equals
$\sum_i\operatorname{dem}(t_i)$.

![[19_MaxFlow.pdf#page=39]]
*Figure: the super-source/super-sink reduction for circulation with demands. (`19_MaxFlow.pdf` p. 39)*

**In plain words.** Imagine a water board with several reservoirs that can each release a limited
amount and several towns that each need an exact amount. Add one giant intake pipe feeding every
reservoir and one giant drain pipe collecting from every town. If the giant drain can be filled
completely, every town got its water; if not, some town is short and no routing can fix it.

**Example (traced).** The deck's network has supplies at the top and demands at the bottom. The
super-source edges carry at most each supply, the super-sink edges require exactly each demand.
The maximum flow value is compared with the sum of demands; equality means feasible.

### 8.2 Edge-disjoint paths

Given $s,t$, find the maximum number of $s$–$t$ paths that share no edge. Assign capacity 1 to
every edge and compute a max flow. An integral flow of value $k$ decomposes into $k$ edge-disjoint
paths, and $k$ edge-disjoint paths give an integral flow of value $k$.

![[19_MaxFlow.pdf#page=40]]
*Figure: unit capacities on every edge; the max flow counts edge-disjoint paths. (`19_MaxFlow.pdf` p. 40)*

**In plain words.** Each road can be used by only one convoy. Send convoys one at a time; if two
convoys would need the same road, the capacity of 1 forbids it. The largest number of convoys that
can reach the destination is exactly the number of edge-disjoint routes.

**Example (traced).** The deck's layered graph has three visibly disjoint routes: top, middle and
bottom, each using a different sequence of edges. The max flow is therefore 3. For **vertex**-
disjoint paths, split each vertex $v$ into $v_{\text{in}}\to v_{\text{out}}$ with capacity 1.

### 8.3 Maximum bipartite matching

A bipartite graph has $V=X\cup Y$ and every edge joins $X$ to $Y$. A matching pairs vertices so
that no vertex is used twice. Build a flow network: direct every $X\to Y$ edge with capacity 1,
add $s\to x$ for every $x\in X$ and $y\to t$ for every $y\in Y$, all capacity 1. The max flow
equals the maximum matching size.

![[19_MaxFlow.pdf#page=44]]
*Figure: a size-3 matching and a size-4 maximum matching on the same bipartite graph. (`19_MaxFlow.pdf` p. 44)*

**In plain words.** Each person can take at most one job, each job can go to at most one person,
and a unit of water is a job assignment. The source gives each person one unit to offer; the sink
accepts one unit per job. The largest number of units that can flow through is the largest number
of people who can be employed at once.

**Example (traced).** The deck's graph has five people and five jobs. The matching
$1\text{–}2'$, $3\text{–}1'$, $4\text{–}5'$ has size 3. A larger matching
$1\text{–}1'$, $2\text{–}2'$, $3\text{–}3'$, $4\text{–}4'$ has size 4; the fifth job is unmatched.
The flow network sends 4 units.

**Correctness.** A matching of size $k$ gives a flow of value $k$ (send 1 along each
$s\to x\to y\to t$). Conversely, an integral flow of value $k$ selects exactly the $X\to Y$ edges
with flow 1; conservation at $x$ and $y$ guarantees no shared vertex, so those edges form a
matching of size $k$.

![[19_MaxFlow.pdf#page=46]]
*Figure: a matching becomes a flow, and a flow becomes a matching. (`19_MaxFlow.pdf` p. 46)*

**Cost.** Ford–Fulkerson on this network is $O(\lvert V\rvert\lvert E\rvert)$: each augmentation
adds 1 to the matching, and the matching size is at most $\lvert V\rvert/2$.

### 8.4 Feasible schedules and balanced assignments

- **Roommate cooking schedule.** Left side = roommates, right side = days; edge $r_i\to d_j$ iff
  $r_i$ can cook on $d_j$. A perfect matching (every vertex matched) is exactly a feasible
  schedule with each person cooking once.
- **Balanced assignment.** Customers on the left, facilities on the right; all edges capacity 1
  except the facility-to-sink edges, which have capacity $n/k$. A balanced assignment exists iff
  the max flow is $n$.
- **Constrained assignment.** Same construction with facility-to-sink capacity $n_i$; a feasible
  assignment exists iff the max flow is $n$.

![[19_MaxFlow.pdf#page=52]]
*Figure: capacities $n_i$ on the facility-to-sink edges encode per-facility limits. (`19_MaxFlow.pdf` p. 52)*

**In plain words.** A perfect matching is a seating plan where nobody is left standing. For
balanced assignment, each facility's pipe to the sink is widened to exactly its quota; if all $n$
customers can still reach the sink, every quota is met.

### 8.5 Baseball elimination

Team $n$ is not eliminated if there is an outcome of the remaining games in which it finishes with
at least as many wins as every other team (ties allowed). Assume team $n$ wins all its remaining
games, so it finishes with $w_n+r_n$ wins. Every other team $i$ may win at most
$w_n+r_n-w_i$ more games.

**Reduction.** Source $s$ to each remaining game node $(i,j)$ with capacity 1; each game node to
team nodes $i$ and $j$ with capacity 1; each team $i$ to $t$ with capacity
$w_n+r_n-w_i$. Team $n$ has a chance iff the max flow saturates all game edges, i.e. equals the
number of remaining games $r=\sum_{i,j} r_{ij}$.

![[19_MaxFlow.pdf#page=58]]
*Figure: game nodes, team nodes, and the win allowance $w_n+r_n-w_i$ on each team-to-sink edge. (`19_MaxFlow.pdf` p. 58)*

**In plain words.** Every remaining game must produce exactly one winner, so each game node sends
its single unit to the team that wins it. A team's pipe to the sink is as wide as the number of
extra wins it is allowed. If all games can be assigned without overflowing any team's allowance,
there is a finishing order with team $n$ on top; if some game's unit cannot be placed, every
outcome eliminates team $n$.

**Example (traced, deck's first table).** Wins: team 1 has 3, teams 2 and 3 have 2, team 4 has 0.
Team 4 can reach at most $0+2=2$ wins, while team 1 already has 3, so team 4 is eliminated before
any flow is needed. In the second table team 4 has 1 win, so it can reach $1+2=3$; teams 1, 2, 3
have 3, 2, 2 wins. Their allowances are $3-3=0$, $3-2=1$, $3-2=1$, total 2. But the three
remaining games among them (1–2, 1–3, 2–3) require 3 wins to be assigned, and only 2 can be
absorbed. Max flow $=2<3$, so team 4 is still eliminated. The reason: team 1 must lose both its
games, which forces teams 2 and 3 to beat team 1, and then their own game gives one of them a
fourth win.

![[19_MaxFlow.pdf#page=55]]
*Figure: the first baseball table, where team 4 is obviously eliminated. (`19_MaxFlow.pdf` p. 55)*

> [!important] Why the reduction is exact
> Each game contributes one unit and must choose one winner; each team can absorb only its
> allowance. An integral max flow is a valid set of game outcomes, and any valid outcome is a flow.
> The equivalence is bijective, not just an implication.

---

## 9. Highlights

- A flow obeys capacity and conservation; its value is the net outflow at $s$.
- An s-t cut upper-bounds every flow; a flow equal to a cut's capacity is optimal.
- **Max-flow min-cut theorem:** maximum flow = minimum cut, and both are certified by the absence
  of an augmenting path in the residual graph.
- The residual graph's backward edges are refunds that let Ford–Fulkerson undo earlier routing.
- Ford–Fulkerson is correct for any augmenting path, but the path choice controls the running time.
  Integer capacities give $O(\lvert f^*\rvert\lvert E\rvert)$; shortest paths (Edmonds–Karp) give
  $O(\lvert V\rvert\lvert E\rvert^2)$.
- Integral capacities produce integral flows, which is why matching, disjoint paths and baseball
  elimination can be read off a max flow.
- Standard reductions: super-source/sink for demands; unit capacities for disjoint paths and
  matching; game nodes with capacity 1 for baseball elimination.

## 10. Exam traps

- **"The capacity of a cut counts edges in both directions."** $\to$ only edges from $S$ to $T$
  count. Backward edges reduce the net flow in the lemma but contribute zero capacity.
- **"Any flow that cannot be increased by a forward path is maximum."** $\to$ it must be unable to
  increase in the **residual** graph, including backward edges. The greedy example of Section 3 has
  no forward path left but is not maximum.
- **"Ford–Fulkerson always terminates quickly."** $\to$ with integer capacities it terminates in
  at most $\lvert f^*\rvert$ augmentations, which can be a million; with irrational capacities a
  bad path choice can fail to terminate. Say "Edmonds–Karp" if you need a polynomial bound.
- **"The max-flow min-cut theorem needs integer capacities."** $\to$ no; it holds for real
  capacities. Integrality is needed only for the combinatorial corollaries.
- **"A maximum flow is unique."** $\to$ generally not; many flows can have the same value. The
  *value* is unique, and the minimum cut value is unique, but the cut itself need not be.
- **"Min cut = minimum number of edges to delete."** $\to$ that is the unweighted special case.
  In general it is the minimum total capacity, and a single high-capacity edge can outweigh many
  low-capacity ones.
- **"Bipartite matching needs a special algorithm."** $\to$ max flow works, with unit capacities.
  The $O(\lvert V\rvert\lvert E\rvert)$ bound comes from the matching size, not from a generic
  flow bound.
- **"A matching of size $k$ always corresponds to $k$ vertex-disjoint paths."** $\to$ that is the
  edge-disjoint path statement with unit capacities; for vertex-disjoint paths you must split
  vertices.
- **"Circulation with demands is feasible iff total supply is at least total demand."** $\to$
  necessary but not sufficient; the capacities between sources and targets must also allow the
  routing. The max-flow value against total demand is the test.
- **"Baseball elimination only needs the win counts."** $\to$ the remaining-game graph matters.
  A team can be eliminated because the teams above it must play each other and one of them must
  win, even if its own win total looks sufficient.
- **"Adding a super-source changes the answer."** $\to$ it is only a modelling device; the max flow
  in the augmented network equals the feasible circulation value, and the original flow is read
  off the original edges.
- **"Edmonds–Karp changes the flow values."** $\to$ it changes only which augmenting path is chosen;
  the maximum value is the same. The bound improves, not the answer.
