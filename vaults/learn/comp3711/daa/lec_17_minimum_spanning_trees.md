# Lecture 17 — Minimum Spanning Trees

> Source: `17_MST.pdf` (30 pages). Goal: connect all vertices as cheaply as possible. Two
> greedy algorithms (Prim, Kruskal), one lemma that proves both correct (the cut lemma), and one
> data structure that makes Kruskal fast (union-find). Builds on [[lec_15_graph_theory]] and the
> priority queues of [[lec_8_heapsort]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The problem:** [[terms/MST|Minimum spanning tree (MST)]] · [[terms/cut-property|Cut lemma and exchange argument]] · [[terms/tree]] · [[terms/graph]]

**The algorithms:** [[terms/greedy-algorithm|Greedy algorithm]] · [[terms/union-find|Union-find (disjoint sets)]] · [[terms/priority-queue|Priority queue]]

**Proof technique:** [[terms/big-O]]

---

## 1. The problem, and the facts that bound it

**Motivate.** Laying cable to connect $n$ towns: you need connectivity (a spanning subgraph), you
want economy (minimum total length), and any extra edge is a cycle you paid for. This is
*the* canonical greedy-correctness problem in the course.

**Define.** Given a connected undirected graph $G = (V,E)$ with real weights $w(e)$, an MST is a
subset $T \subseteq E$ such that $T$ is a tree connecting all nodes and $\sum_{e \in T} w(e)$ is
minimised.

![[17_MST.pdf#page=2]]
*Figure: a weighted graph and its MST, total weight 50. (`17_MST.pdf` p. 2)*

**The useful facts.** For a connected undirected graph on $\lvert V\rvert$ nodes:

| Fact | Why it matters |
|---|---|
| $\lvert V\rvert - 1 \le \lvert E\rvert \le \lvert V\rvert(\lvert V\rvert-1)/2$ | so $\lvert E\rvert = O(\lvert V\rvert^2)$ |
| $\log\lvert E\rvert = O(\log\lvert V\rvert)$ | so $\log\lvert E\rvert$ and $\log\lvert V\rvert$ are interchangeable |
| fewer than $\lvert V\rvert-1$ edges $\Rightarrow$ not connected | no spanning tree exists |
| connected $+$ $\lvert V\rvert-1$ edges $\Rightarrow$ tree | a spanning tree has exactly $\lvert V\rvert-1$ edges |
| more than $\lvert V\rvert-1$ edges $\Rightarrow$ at least one cycle | every extra edge is redundant |

![[17_MST.pdf#page=1]]
*Figure: the fact list, including $O(\log\lvert E\rvert) = O(\log\lvert V\rvert^2) = O(\log\lvert V\rvert)$.
(`17_MST.pdf` p. 1)*

> [!important] Why every MST is a tree and not just a connected subgraph
> If $T$ spans and has a cycle, deleting any edge of that cycle keeps it spanning and lowers the
> cost (weights are positive in all the examples here). So an optimum is acyclic, hence a tree,
> hence exactly $\lvert V\rvert-1$ edges.

---

## 2. Prim's algorithm

**Idea.** Grow a single tree from one node. At each step add the cheapest edge with one endpoint
inside the tree and one outside.

![[17_MST.pdf#page=3]]
*Figure: the growth rule — blue = tree, red = the lightest edge crossing out of it.
(`17_MST.pdf` p. 3)*

**In plain words.** Start in one town and keep asking "what is the cheapest road out of the towns
I have already connected?". Add that road, add its town, and ask again — the network grows as one
blob. The single cheapest road in the whole map is used **late**, not first, because it only helps
once you have reached its far end.

**Example (the deck's graph, traced; I computed the numbers).** Nodes $a..i$, 9 nodes, 14 edges:
$ab\,4$, $ah\,8$, $bc\,8$, $bh\,11$, $cd\,7$, $cf\,4$, $ci\,2$, $de\,9$, $df\,14$, $ef\,10$,
$hi\,7$, $hg\,1$, $ig\,6$, $gf\,2$. Starting at $a$:

| step | cheapest crossing edge | weight | tree so far |
|---|---|---|---|
| 1 | a–b | 4 | $\{a,b\}$ |
| 2 | b–c (beats a–h, also 8 — here the tie is broken toward $c$) | 8 | $\{a,b,c\}$ |
| 3 | c–i | 2 | $\{a,b,c,i\}$ |
| 4 | c–f (beats i–g at 6 and a–h at 8) | 4 | $\{a,b,c,i,f\}$ |
| 5 | f–g | 2 | $\{a,b,c,i,f,g\}$ |
| 6 | g–h | 1 | $\{a,\dots,h\}$ |
| 7 | c–d | 7 | $\{a,\dots,d\}$ |
| 8 | d–e | 9 | all |

Total $4+8+2+4+2+1+7+9 = 37$. Two things to notice:

- **Step 5 pulls $g$ in through $f$**, so only at step 6 does the $1$-weight edge g–h become
  usable. The cheapest edge in the graph is *not* the first edge added: Prim may only take edges
  that cross the current cut.
- **Step 2 is a tie.** a–h also weighs 8; the deck (and the trace above) breaks it toward b–c.
  This graph has equal weights, so the MST is **not** unique — see the Kruskal trace in Section 4.

![[17_MST.pdf#page=9]]
*Figure: the first four steps on this graph. (`17_MST.pdf` p. 9)*

**Implementation.** Keep, for every node outside the tree, its cheapest known edge into the tree;
put all nodes in a min-priority queue keyed by that value.

![[17_MST.pdf#page=11]]
*Figure: `Prim(G,r)` with `Decrease-Key`; the parent pointers at the end *are* the MST.
(`17_MST.pdf` p. 11)*

```text
Prim(G, r):
    for each v in V
        v.key <- INFINITY;  v.p <- nil;  v.color <- white
    r.key <- 0
    insert all keys into a min-priority queue Q
    while Q not empty
        u <- Extract-Min(Q)
        u.color <- black
        for each v in Adj[u]
            if v.color = white and w(u,v) < v.key then
                v.p <- u
                v.key <- w(u,v)
                Decrease-Key(Q, v, w(u,v))
```

**Cost.** $\lvert V\rvert$ Extract-Min plus at most $\lvert E\rvert$ Decrease-Key, each
$O(\log\lvert V\rvert)$ with a binary heap: $O(\lvert E\rvert\log\lvert V\rvert)$.

**Variant without Decrease-Key** (the deck's second version, p. 12): relaxing an edge *inserts* a
duplicate entry, and duplicates are discarded on extraction (a node that is already black is
skipped).

```text
    while Q not empty
        u <- Extract-Min(Q)
        if u.color = black then continue      // stale duplicate
        output (u, u.p)
        u.color <- black
        for each v in Adj[u]
            if v.color = white and w(u,v) < v.key then
                v.p <- u;  v.key <- w(u,v);  Insert(Q, v)
```

**Cost.** $O(\lvert E\rvert\log\lvert E\rvert) = O(\lvert E\rvert\log\lvert V\rvert)$ by the
$\log\lvert E\rvert = O(\log\lvert V\rvert)$ fact. Worth knowing: this version is what you write
with `std::priority_queue`, which has no `decrease-key`.

---

## 3. The cut lemma (why greedy is safe here)

**Define.** A **cut** $(S, V-S)$ is a partition of the vertices. An edge **crosses** the cut if
exactly one endpoint is in $S$.

**Cut lemma.** Assume all edge weights are distinct. Let $e$ be the unique minimum-weight edge
crossing some cut. Then **every** MST contains $e$.

**Proof (exchange argument).** Let $T^*$ be any MST with $e = (u,v) \notin T^*$. Since $T^*$ is
spanning, it contains a path from $u$ to $v$; that path must cross the cut, so it uses some
other crossing edge $e'$. Because $e$ is the *strictly* cheapest crossing edge,
$w(e') > w(e)$. Then $T^* - e' + e$ is still a spanning tree (adding $e$ closes a cycle that $e'$
lies on, and removing $e'$ breaks it) with strictly smaller total weight — contradicting that
$T^*$ is an MST. So $e \in T^*$.

![[17_MST.pdf#page=13]]
*Figure: the exchange — $e'$ is the other cut edge on the $u$-to-$v$ path in $T^*$; swap it for
$e$ and the cost drops. (`17_MST.pdf` p. 13)*

![[17_MST.pdf#page=14]]
*Figure: without the distinct-weights assumption the conclusion weakens to "$e$ is in **some**
MST", with $w(e') \ge w(e)$ in the argument. (`17_MST.pdf` p. 14)*

**Consequence.** Prim is correct: at every step the tree $S$ defines a cut, and the edge Prim adds
is the minimum crossing edge, so it belongs to every MST. With distinct weights the MST is
**unique**, so Prim's output is *the* MST however ties are broken.

> [!important] The one-line reason greedy works for MSTs
> Greedy fails when a locally cheap choice can block a globally better future. The cut lemma says
> that cannot happen for spanning trees: a minimum crossing edge is compatible with *every* MST, so
> choosing it can never be regretted.

---

## 4. Kruskal's algorithm

**Idea.** Sort all edges by weight and scan them; keep an edge unless it closes a cycle.

![[17_MST.pdf#page=15]]
*Figure: the two cases — $e$ would close a cycle (discard) or it does not (take it).
(`17_MST.pdf` p. 15)*

```text
MST-Kruskal(G):
    for each vertex v in V
        Make-Set(v)
    sort the edges of G into increasing order by weight
    for each edge (u, v) in that order
        if Find-Set(u) != Find-Set(v) then     // no cycle
            output (u, v)
            Union(u, v)
```

**In plain words.** Line up every road from cheapest to dearest and take each one unless it would
close a loop — a loop means you already have another way between those two towns, so the road is
pure waste. Stop when all towns are connected. Here it reaches the same total as the other method
but picks a different road where two cost the same.

**Example (same graph, traced).** Scan in increasing weight:

| edge | weight | action | components merged |
|---|---|---|---|
| g–h | 1 | take | $\{g,h\}$ |
| c–i | 2 | take | $\{c,i\}$ |
| g–f | 2 | take | $\{g,h,f\}$ |
| a–b | 4 | take | $\{a,b\}$ |
| c–f | 4 | take | $\{c,i,f,g,h\}$ |
| i–g | 6 | **discard** — same set, would close $c \to i \to g \to f \to c$ | – |
| c–d | 7 | take | $\{c,d,i,f,g,h\}$ |
| h–i | 7 | **discard** — same set | – |
| a–h | 8 | take | $\{a,b,c,d,f,g,h,i\}$ |
| b–c | 8 | **discard** — same set | – |
| d–e | 9 | take | all 9 nodes |
| e–f | 10 | **discard** — would close a cycle | – |
| b–h | 11 | **discard** | – |
| d–f | 14 | **discard** | – |

8 edges taken, total $1+2+2+4+4+7+8+9 = 37$: the same **weight** as Prim's tree — but **not the
same tree**. Kruskal took a–h (8) where Prim took b–c (8); the two spanning trees share 7 edges
and differ in exactly that tied pair. An exhaustive enumeration of all 3003 8-edge subsets
confirms there are exactly **2** MSTs in this graph.

> [!important] Ties break the uniqueness, not the optimality
> With distinct weights the cut lemma gives "**every** MST contains $e$", and the MST is unique.
> With ties it only gives "**some** MST contains $e$" (p. 14 of the deck), so Prim and Kruskal may
> return genuinely different trees — both optimal. Never claim "the" MST without the distinct
> weights assumption.

![[17_MST.pdf#page=16]]
*Figure: the first steps of Kruskal on the deck's graph. (`17_MST.pdf` p. 16)*

**Correctness (sketch).** When Kruskal considers $e = (u,v)$ with $u,v$ in different components,
let $S$ be the component containing $u$ just before $e$ is considered. Every crossing edge
lighter than $e$ was already considered and either taken (so it would have merged $S$ with the
other side, contradiction) or discarded (so it did not cross this cut). Hence $e$ is the minimum
crossing edge of the cut $(S, V-S)$, and by the cut lemma it is in the MST.

---

## 5. Union-find: making the cycle test cheap

**Motivate.** The only question Kruskal asks is "are $u$ and $v$ in the same component of the
partial forest?". A DFS per edge costs $O(\lvert E\rvert\lvert V\rvert)$; we want
$O(\log\lvert V\rvert)$.

**Observation.** The *shape* of each partial tree is irrelevant — only the partition matters. So
maintain a family of **sets** with two operations:

| Operation | Meaning |
|---|---|
| `Make-Set(x)` | create the singleton $\{x\}$ |
| `Find-Set(x)` | which set does $x$ belong to (return its representative) |
| `Union(x,y)` | merge the two sets |

**Representation.** Each set is a tree of parent pointers; the root is the set's ID. These trees
are **not** the MST trees — they are an internal index of "who is with whom".

![[17_MST.pdf#page=21]]
*Figure: parent pointers only, no child pointers; the root points to itself. (`17_MST.pdf` p. 21)*

```text
Make-Set(x):  x.parent <- x;  x.height <- 0

Find-Set(x):  while x != x.parent do x <- x.parent
              return x

Union(x, y):  a <- Find-Set(x);  b <- Find-Set(y)
              if a.height <= b.height then
                  if a.height = b.height then b.height <- b.height + 1
                  a.parent <- b
              else
                  b.parent <- a
```

**Cost without any care.** Under the naive rule `x.parent <- y`, a chain of unions builds a path
of length $n$, so `Find-Set` is $\Theta(n)$ and Kruskal degrades to $\Theta(\lvert E\rvert\lvert V\rvert)$.

**Union by height.** Always hang the shorter tree under the taller root. Then:

**Theorem.** A tree of height $h$ has at least $2^h$ nodes. *Proof (induction).* A singleton has
$h=0$, size $1 \ge 2^0$. Merging trees of heights $h_x \le h_y$: the new height is $h_y$ unless
$h_x = h_y$, in which case it is $h_y + 1$; in both cases the new size
$\text{size}(x) + \text{size}(y) \ge 2^{h_x} + 2^{h_y}$ is at least $2^{h'}$ where $h'$ is the new
height. Hence $h \le \log_2 n$: every operation is $O(\log n)$.

![[17_MST.pdf#page=24]]
*Figure: the bad case (a long chain) and the union-by-height fix. (`17_MST.pdf` p. 24)*

**Path compression.** After `Find-Set(x)`, point every node on the walked path directly at the
root. Consecutive finds then cost near-constant time; the deck notes the running time is
"practically constant, but theoretically not" (the formal bound is the inverse Ackermann
function, in the textbook, not required).

![[17_MST.pdf#page=26]]
*Figure: path compression on the path just walked. (`17_MST.pdf` p. 26)*

**Kruskal's total cost.**

$$O\bigl(\lvert E\rvert\log\lvert E\rvert\bigr) + O\bigl(\lvert E\rvert\log\lvert V\rvert\bigr)
= O\bigl(\lvert E\rvert\log\lvert V\rvert\bigr)$$

(sorting, then $2\lvert E\rvert$ finds and up to $\lvert V\rvert-1$ unions). If the edges arrive
already sorted and path compression is used, the cost is close to $O(\lvert E\rvert)$.

> [!tip] Prim vs Kruskal: which to use
> Both are $O(\lvert E\rvert\log\lvert V\rvert)$ here. Prim is the one to use on **dense** graphs
> (it never sorts all $\lvert E\rvert$ edges; with an array-based priority queue it is
> $O(\lvert V\rvert^2)$), and it needs no union-find. Kruskal is the one to use when the edges are
> already sorted or the graph is sparse. Kruskal also answers "give me the MST edges in increasing
> order" for free.

---

## 6. The standard MST questions

**In plain words.** If a town has a road that is the cheapest thing touching it, no sensible network
can leave it out. Leaving it out means reaching that town some other, dearer way, and swapping the
dear road for the cheap one saves money without breaking anything.

**Q1: is the cheapest edge at a vertex always in every MST?** (deck p. 28) **Yes**, with distinct
weights. Proof: let $T$ be an MST not containing the cheapest edge $(u,v)$ at $v$. Adding $(u,v)$
to $T$ creates a cycle; that cycle has another edge $(w,v)$ incident to $v$, and
$w(w,v) > w(u,v)$ by assumption. Swapping strictly lowers the cost — contradiction.

**Q2: which statement is false?** $G$ connected, distinct weights, $e_{max}$ heaviest, $e_{min}$
lightest.

| Statement | Verdict |
|---|---|
| every MST contains $e_{min}$ | **true** (cut lemma on $\{u\}$) |
| no MST contains $e_{max}$ | **false** — a path graph's only spanning tree *is* all of it |
| if $e_{max}$ is in an MST, removing it disconnects $G$ | **true** — otherwise swap it for a lighter edge crossing the induced cut |
| $G$ has a unique MST | **true** — distinct weights $\Rightarrow$ unique MST |

**In plain words.** Three towns in a line, and the middle road is the dearest in the map. Can you
leave it out? No — without it the far town is cut off entirely. "Never take the most expensive
road" is only true when the expensive road lies on a loop, so something cheaper could replace it.

**Example (the counterexample to statement 2).** a–b (weight 1), b–c (weight 2). The MST
is both edges, and the heaviest edge b–c is in it. The heaviest edge is skippable only when
it lies on a cycle.

---

## 7. Two variations worth one line each

**Maximum spanning tree** (deck p. 29). Three equivalent routes: (i) Prim, always take the
*heaviest* crossing edge; (ii) Kruskal, sort edges *decreasing*; (iii) **negate all weights** and
run any MST algorithm. Route (iii) is the one to remember — it means you never need a second
implementation.

**Bottleneck weight** (deck p. 30). The bottleneck of a spanning tree is its *heaviest* edge.
**Claim: the MST minimises the bottleneck over all spanning trees.**

**In plain words.** The worst road in a network is what decides how bad the network is — one awful
road makes every trip across it awful. The cheapest network also has the least bad worst road: if
some other network had a gentler worst road, its cheaper roads could be swapped into the cheapest
network to make *it* cheaper still, which is impossible.

*Proof (contradiction).* Let $T$ be the MST with heaviest edge $(a,b)$; deleting it splits $T$
into $A$ and $B$. Any other spanning tree $T'$ must contain some edge $(a',b')$ crossing that cut
(its unique $a$–$b$ path must cross). If $T'$ had a smaller bottleneck, then
$w(a',b') < w(a,b)$, so $T - (a,b) + (a',b')$ would be a spanning tree of *smaller total weight*
than the MST — contradiction.

> [!important] Bottleneck vs total weight are different objectives
> The MST minimises both the total weight and the bottleneck weight, but the minimum-bottleneck
> spanning tree is not unique: any spanning tree whose heaviest edge equals the MST's heaviest
> edge qualifies. In the deck's example the MST's heaviest edge is d–e at 9, so any spanning
> tree avoiding e–f (10) and d–f (14) has bottleneck 9.

---

## 8. Highlights

*(The deck has no summary slide; this is its 30 pages distilled.)*

- MST = spanning tree of minimum total weight; it has exactly $\lvert V\rvert-1$ edges, and every
  extra edge is a cycle you paid for.
- Prim grows one tree by taking the lightest crossing edge; the parent pointers at the end are the
  MST. $O(\lvert E\rvert\log\lvert V\rvert)$ with a heap, $O(\lvert V\rvert^2)$ with an array.
- Kruskal scans edges in increasing weight and skips any edge whose endpoints are already
  connected. $O(\lvert E\rvert\log\lvert V\rvert)$, dominated by sorting.
- The cut lemma is the whole proof of correctness for both, and it is an **exchange argument**:
  the minimum crossing edge belongs to every MST (unique weights), so greedy choosing it is
  never regretted.
- Union-find turns Kruskal's cycle test into $O(\log n)$: union by height guarantees
  $\text{size} \ge 2^{\text{height}}$; path compression makes it practically constant.
- Distinct weights $\Rightarrow$ unique MST, so Prim and Kruskal agree. With ties they can return
  different trees of equal weight (Section 2's graph has exactly 2 MSTs).
- Variations are free: negate for maximum spanning tree; the MST also minimises the bottleneck.

## 9. Exam traps

- **Thinking the lightest edge overall must be in the MST** $\to$ it is in *some* MST (cut lemma
  applies to a cut it crosses), but with distinct weights, "the lightest edge of the graph" is
  indeed in the MST. What is *not* true is that Prim picks it first: the $1$-weight edge g–h
  in Section 2 is added at step 6, because it does not cross the current cut.
- **"Prim's algorithm only works if you start at the right vertex"** $\to$ any start vertex gives
  an MST (with distinct weights, the same one).
- **Believing `decrease-key` is required** $\to$ the insert-duplicates variant is equivalent;
  you just skip stale entries. Say which version your $O(\cdot)$ bound is for.
- **$O(\lvert E\rvert\log\lvert E\rvert)$ vs $O(\lvert E\rvert\log\lvert V\rvert)$** $\to$ these
  are equal for MST inputs ($\lvert E\rvert \le \lvert V\rvert^2$), and the reason is the fact
  list on p. 1. Neither is $O(\lvert E\rvert)$.
- **Kruskal: testing "does $e$ create a cycle" with a DFS** $\to$ correct but
  $O(\lvert E\rvert\lvert V\rvert)$; union-find is the intended answer.
- **Union without the height rule** $\to$ chains of length $n$, and $\Theta(n)$ finds. The
  $O(\log n)$ bound comes *only* from union by height (or by size).
- **Union-find trees confused with MST trees** $\to$ they are unrelated structures; the union-find
  forest only tracks components, and its shape is meaningless.
- **`Union(x,y)` called on non-roots** $\to$ must `Find-Set` first, otherwise you attach a whole
  subtree as a child of an internal node and disconnect a set.
- **Claiming the MST is unique in general** $\to$ only for distinct weights. With ties there can
  be exponentially many MSTs, and the cut lemma's conclusion weakens from "every MST" to "some
  MST". The deck's own example graph has two.
- **Assuming Prim and Kruskal must produce the same edges** $\to$ only with distinct weights. On
  the Section 2 graph they differ (a–h versus b–c), both with total 37, both optimal.
- **"$e_{max}$ is in no MST"** $\to$ false: on a bridge it must be (path graph). It is skippable
  exactly when it lies on a cycle.
- **Maximum spanning tree implemented by "reverse Prim's comparison" only** $\to$ also reverse the
  *Kruskal sort*; and the safest answer is "negate the weights and run MST".
- **Bottleneck claim confused with uniqueness** $\to$ the MST minimises the bottleneck, but many
  trees share the minimum bottleneck; the claim is about the value, not the tree.
- **MST on a disconnected graph** $\to$ does not exist as defined. You get a minimum spanning
  *forest*, one tree per component, which Kruskal produces silently and Prim does not.
