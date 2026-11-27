# Lecture 16 — Basic Graph Algorithms

> Source: `16_GraphBasic.pdf` (58 pages). Goal: the two ways to explore a graph — breadth first
> and depth first — and the half-dozen problems that are *nothing but* an exploration with a
> twist: components, reachability, SCCs, bipartiteness, cycles, topological order. Vocabulary
> comes from [[lec_15_graph_theory]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**Exploration:** [[terms/BFS|Breadth first search (BFS)]] · [[terms/DFS|Depth first search (DFS)]] · [[terms/edge-classification|Tree, back, forward and cross edges]]

**Structure:** [[terms/graph]] · [[terms/strong-connectivity|Strong connectivity and SCCs]] · [[terms/bipartite|Bipartite graph]] · [[terms/DAG]] · [[terms/topological-sort|Topological sort]]

**Data structures:** [[terms/queue|Queue (FIFO)]] · [[terms/adjacency-list]]

---

## 1. Exploration is the primitive

**Motivate.** Almost every graph question — *is $t$ reachable from $s$? how far? which nodes are
in the same component? can the tasks be ordered?* — is answered by walking the graph from a
starting point and recording something. BFS and DFS are the two canonical walk orders, and they
differ only in **which frontier node is expanded next**.

**Define.** The input is an adjacency list or matrix ([[terms/adjacency-list|adjacency list]] is
the default). Both searches colour nodes:

| Colour | Meaning | In BFS queue? | On DFS stack? |
|---|---|---|---|
| white | undiscovered | – | – |
| gray | discovered, neighbours not all processed | yes | yes |
| black | discovered and fully processed | no | no |

![[16_GraphBasic.pdf#page=2]]
*Figure: why explore — many problems are graph problems, input arrives as a list/matrix, and
exploration is the first step of most algorithms. (`16_GraphBasic.pdf` p. 2)*

---

## 2. BFS: layers, distances, shortest paths

**Define.** From $s$, grow outward one layer at a time:

$$L_0 = \{s\}, \qquad L_{i+1} = \{v \notin L_0 \cup \dots \cup L_i : (u,v) \in E \text{ for some } u \in L_i\}$$

![[16_GraphBasic.pdf#page=3]]
*Figure: the layer construction $s \mid L_1 \mid L_2 \mid \dots \mid L_k$. (`16_GraphBasic.pdf` p. 3)*

**Theorem.** $L_i$ is exactly the set of nodes at distance $i$ from $s$ (distance = number of
edges on a shortest path). Therefore $t$ is reachable from $s$ iff $t$ appears in some layer.

**In plain words.** Six friends sitting in a ring, and a rumour starts at one of them. In one
breath it reaches the two neighbours, in two breaths the next two along, and in three it reaches
the opposite seat. The first time a person hears it is the shortest possible number of breaths —
no one could have got it there faster.

**Example (my instance, traced).** Undirected graph on $\{1,\dots,6\}$ with the 6-cycle
$1 \to 2 \to 3 \to 4 \to 5 \to 6 \to 1$, BFS from 1:

| layer | nodes | distance from 1 |
|---|---|---|
| $L_0$ | 1 | 0 |
| $L_1$ | 2, 6 | 1 |
| $L_2$ | 3, 5 | 2 |
| $L_3$ | 4 | 3 |

Node 4 is at distance 3 even though there are two distinct shortest routes
($1 \to 2 \to 3 \to 4$ and $1 \to 6 \to 5 \to 4$) — BFS discovers it once, through whichever
neighbour it dequeues first, and that choice is invisible in $d[4] = 3$.

> [!important] Why BFS distances are correct
> Nodes enter the queue in non-decreasing distance order (a FIFO queue preserves the layer
> order), and a node is first discovered from a node one layer closer. So the first discovery is
> the shortest path. **This is the only property BFS has that DFS does not.**

---

## 3. The BFS algorithm

![[16_GraphBasic.pdf#page=6]]
*Figure: the complete algorithm with colour, distance and parent bookkeeping, and the running
time. (`16_GraphBasic.pdf` p. 6)*

```text
BFS(G, s):
    for each vertex u in V - {s}
        u.color <- white;  u.d <- INFINITY;  u.p <- nil
    s.color <- gray;  s.d <- 0
    Q <- empty queue;  Enqueue(Q, s)
    while Q is not empty
        u <- Dequeue(Q)
        for each v in Adj[u]
            if v.color = white then
                v.color <- gray
                v.d <- u.d + 1        // distance grows by exactly 1
                v.p <- u              // remember the tree edge
                Enqueue(Q, v)
        u.color <- black
```

**Cost.** Every node is dequeued once and its adjacency list scanned once:

$$\sum_{u \in V}\bigl(1 + \deg(u)\bigr) = \Theta\bigl(\lvert V\rvert + \lvert E\rvert\bigr)$$

which is $\Theta(\lvert E\rvert)$ when the graph is connected (since then
$\lvert E\rvert \ge \lvert V\rvert - 1$).

**In plain words.** Each person remembers who told them the rumour. To find a route back to the
source you just keep asking "who told you?" and reverse the answers. Those answers also show the
shape of the whole spread: everyone's teller forms a tree rooted at the source.

**Example (parent pointers).** On the 6-cycle above, BFS from 1 gives
$p[2]=1, p[6]=1, p[3]=2, p[5]=6, p[4]=3$. Following parents from 4 gives
$4 \to 3 \to 2 \to 1$ — the shortest path, read backwards. The parent pointers form the **BFS
tree** rooted at $s$.

![[16_GraphBasic.pdf#page=7]]
*Figure: the BFS tree — a spanning tree of the reachable part, whose root-to-node paths are
shortest paths. (`16_GraphBasic.pdf` p. 7)*

> [!tip] Reading a shortest path out of BFS
> BFS computes one shortest path per node: follow `p` from $t$ back to $s$ and reverse. It does
> **not** enumerate all shortest paths, and it does not compute shortest paths by *weight* —
> for weighted graphs you need Dijkstra.

---

## 4. Connected components

**Define.** The connected component of $s$ = all nodes reachable from $s$. BFS from $s$ finds
exactly that set.

**Algorithm.** Rename the BFS above `BFS-Visit(G,s)`, and wrap it: run it once from every still-white
node.

```text
BFS(G):
    for each vertex u in V
        u.color <- white;  u.d <- INF;  u.p <- nil
    for each vertex u in V
        if u.color = white then
            BFS-Visit(G, u)          // paints u's whole component black
```

![[16_GraphBasic.pdf#page=9]]
*Figure: the wrapper — `BFS(G)` initialises once, then calls `BFS-Visit` on each undiscovered
node. (`16_GraphBasic.pdf` p. 9)*

**In plain words.** The deck's graph is really three separate islands. Start a search on one
island and it colours the whole island; then look for anyone still unvisited, start again, and
colour the next island. How many times you had to start is the number of components.

**Example (13-node graph, deck pp. 10–14).** `BFS-Visit(1)` paints $\{1,2,3,4,5,6,7,8\}$ black;
`BFS-Visit(2)` does nothing (2 is already black); `BFS-Visit(10)` then paints
$\{9,10,11,12,13\}$. Two components, so the checks 3–9 are all skipped.

**Cost.** Still $\Theta(\lvert V\rvert + \lvert E\rvert)$ in total: each node is initialised once
and each adjacency entry scanned once, across *all* the calls.

> [!warning] Calling `BFS-Visit` on a black node
> If you forget the test "is this node still white?" you still get correct components, but you
> re-scan edges and lose the linear bound. The test is what makes the total cost a sum over
> components rather than a product.

---

## 5. Directed graphs: reachability is not symmetric

**Motivate.** Undirected reachability is an equivalence relation, so "connected" is one word.
Directed reachability is not, and that single fact creates two new problems.

![[16_GraphBasic.pdf#page=15]]
*Figure: in a directed graph, $u$ reaching $t$ says nothing about $t$ reaching $u$.
(`16_GraphBasic.pdf` p. 15)*

| Question | Undirected | Directed |
|---|---|---|
| $s \rightsquigarrow t$ implies $t \rightsquigarrow s$? | yes | **no** |
| Shortest $s$–$t$ path = shortest $t$–$s$ path? | yes | **no** |
| BFS works unchanged? | yes | yes (list only out-edges) |

**In plain words.** Start on a web page and follow links. You find every page you can reach *from*
it, and never the pages that merely link *to* it — one-way streets mean "reachable" is not a
two-way word.

**Example (web crawler).** Start at page $s$ and BFS the directed web graph: you find everything
reachable *from* $s$ — pages that link to you are invisible.

**Strong connectivity.** $u,v$ are mutually reachable if each reaches the other; $G$ is strongly
connected if every pair is. Equivalently: $G$ has a vertex $s$ that reaches and is reached by
every node ("strong" vertex), and then every vertex is strong.

![[16_GraphBasic.pdf#page=17]]
*Figure: strongly connected versus not, plus the two-BFS test. (`16_GraphBasic.pdf` p. 17)*

```text
isStronglyConnected(G):
    s <- any node
    R1 <- BFS(G, s)                    // nodes reachable from s
    Grev <- G with every edge reversed
    R2 <- BFS(Grev, s)                 // nodes that can reach s
    return (R1 = V and R2 = V)
```

**Cost.** Two BFS runs, $\Theta(\lvert V\rvert + \lvert E\rvert)$ plus the same to build $G^{rev}$.

---

## 6. Strongly connected components

**Define.** A strongly connected component (SCC) is a maximal set of mutually reachable nodes.

**Algorithm (the deck's $O(\lvert V\rvert\lvert E\rvert)$ version).** Repeatedly take any node
$u$, intersect "reachable from $u$" with "reaches $u$", output that set as a component, then
delete it.

![[16_GraphBasic.pdf#page=18]]
*Figure: the SCC algorithm — intersection of a forward and a backward BFS, then removal.
(`16_GraphBasic.pdf` p. 18)*

```text
SCC(G):
    Grev <- G with all edges reversed
    while nodes remain
        u <- any remaining node
        C <- BFS(G, u) ∩ BFS(Grev, u)   // nodes mutually reachable with u
        output C as a strongly connected component
        remove C and its incident edges from G and Grev
```

**In plain words.** Two pages belong to the same club if you can get from each to the other by
following links. So walk forwards and note what you can reach, walk backwards and note what can
reach you; the pages in both lists are the club. Delete them and start again for the next club.

**Example (my instance, traced).** Directed edges: $1 \to 2$, $2 \to 3$, $3 \to 1$, $3 \to 4$,
$4 \to 5$, $5 \to 4$.

| start $u$ | forward reach | backward reach | $C$ |
|---|---|---|---|
| 1 | $\{1,2,3,4,5\}$ | $\{1,2,3\}$ | $\{1,2,3\}$ |
| 4 | $\{4,5\}$ | $\{4,5\}$ (plus nothing else, after 1–3 removed) | $\{4,5\}$ |

Two SCCs: $\{1,2,3\}$ (a 3-cycle) and $\{4,5\}$ (a 2-cycle). Node 3 is the only bridge, and
notice that 3 ∈ the first component — the components are not "the cycle and the tail".

**Cost.** Each iteration costs one BFS pair $O(\lvert V\rvert+\lvert E\rvert)$, and there can be
$\Theta(\lvert V\rvert)$ iterations, giving $O(\lvert V\rvert\lvert E\rvert)$. A
$\Theta(\lvert V\rvert+\lvert E\rvert)$ algorithm exists (Kosaraju / Tarjan, in the textbook) and
is explicitly **not required**.

---

## 7. BFS on an implicit graph

**Motivate.** You do not need an explicit adjacency list. If the "neighbours" of a state are
generated by a rule, BFS works unchanged — the graph is implicit, the queue is explicit.

**In plain words.** A chess knight jumps in an L. Every square is a place and every jump a road,
so "fewest jumps from here to there" is answered by ringing outwards from the starting square —
nearer squares are always reached first, so the first arrival is the shortest.

**Example 1 (knight moves, deck p. 28).** States = squares; a move is a jump. Ask for the
minimum number of moves from $(x,y)$ to $(x',y')$: BFS from $(x,y)$ with a *generated* neighbour
set.

The 8 legal offsets are $(\pm 2, \pm 1)$ and $(\pm 1, \pm 2)$, and each must be bounds-checked
against the board. Verified distances on an $8\times8$ board: $(0,0) \to (0,1)$ takes **3**
moves, $(0,0) \to (1,1)$ takes **4**, and the *diameter* of the knight graph on $8\times8$ is
**6** — a nice demo that BFS depth is not the same as graph size.

**In plain words.** A grid where only the 1s are floor and the 0s are walls. Step outwards one
ring at a time from the start; the first moment you are standing on the exit, the number of rings
you crossed is the shortest walk possible through that maze.

**Example 2 (binary maze, deck p. 29).** Cells with value 1 are nodes; moves are up/left/down/right
onto another 1. BFS from the start; the first time the target is dequeued, its `d` is the
shortest path length.

> [!important] The pattern: BFS = shortest path in an unweighted graph
> "Minimum number of moves/steps/operations" $\Rightarrow$ BFS on a graph whose edges are single
> moves. If the moves have different costs, BFS is wrong (Dijkstra or a 0-1 BFS is needed).

---

## 8. Bipartiteness

**Define.** $G$ is bipartite if $V$ splits into $U \cup W$ with every edge joining $U$ to $W$ —
i.e. the graph is 2-colourable.

**Theorem.** $G$ is bipartite $\iff$ $G$ has no odd cycle. And BFS gives the test for free: colour
by the parity of the BFS distance.

![[16_GraphBasic.pdf#page=30]]
*Figure: BFS parity as a 2-colouring; an edge inside a layer is exactly an odd cycle.
(`16_GraphBasic.pdf` p. 30)*

**Algorithm.**

```text
Bipartite(G):
    pick any node s;  run BFS from s recording d[v] for all v
    S <- {v : d[v] even}
    for each edge (u, v) in E
        if d[u] and d[v] have the same parity then return FALSE   // odd cycle
    return TRUE
```

**In plain words.** Can these people be split into two teams so that every friendship goes across
the divide and none stays inside a team? Colour the ripple rings alternately — red, blue, red —
and then check nobody is friends with someone of their own colour. A friendship inside a colour is
the proof that no split exists, and that friendship always sits on an odd-length loop.

**Example (traced).** The 6-cycle $1 \to 2 \to 3 \to 4 \to 5 \to 6 \to 1$ from Section 2: distances
$0,1,2,3,2,1$. Parities: $\{1,3,5\}$ even, $\{2,4,6\}$ odd, and every edge joins the two sets →
**bipartite**. Now add the edge $1 \to 3$ (undirected): both endpoints have even distance, the parity test
fails, and indeed $1 \to 2 \to 3 \to 1$ is a triangle — an odd cycle.

**Cost.** One BFS plus one edge scan: $\Theta(\lvert V\rvert + \lvert E\rvert)$.

> [!warning] Which non-tree edges kill bipartiteness
> In an undirected BFS every non-tree edge joins nodes whose distances differ by **0 or 1**
> (never by 2 or more). A difference of 1 gives a cycle of even length — harmless. A difference
> of **0** (both endpoints in the same layer) gives a cycle of odd length — exactly what makes
> the graph non-bipartite. So the parity test is not a heuristic: it is the odd-cycle test.

---

## 9. DFS: go deep instead of wide

**Motivate.** BFS expands a node's *entire* neighbourhood before moving on. DFS commits to the
first unexplored neighbour and recurses, which is what you want when the *structure* (an
ancestor/descendant relation, a cycle, a reverse topological order) matters rather than
distances.

![[16_GraphBasic.pdf#page=35]]
*Figure: the deck's worked DFS — adjacency lists, discovery order, the DFS tree (bold) and the
back edges (red). (`16_GraphBasic.pdf` p. 35)*

```text
DFS(G):
    for each vertex u in V
        u.color <- white;  u.p <- nil
    for each vertex u in V
        if u.color = white then DFS-Visit(u)

DFS-Visit(u):
    u.color <- gray                       // on the recursion stack
    for each v in Adj[u]
        if v.color = white then
            v.p <- u
            DFS-Visit(v)                  // recurse NOW, before other neighbours
    u.color <- black                      // done with u
```

**Cost.** Same accounting as BFS: each node once, each adjacency entry once, so
$\Theta(\lvert V\rvert + \lvert E\rvert)$.

**In plain words.** Instead of spreading out evenly, take the first corridor you find and keep
going through the first unvisited door until you hit a dead end; then back up one door and try the
next. The path you walked is the tree. Every later door that leads back to a room already on your
own path home is a shortcut that closes a loop.

**Example (deck p. 35, traced against its adjacency lists).** $a$ is discovered first, so $b$ is
the first child. From $b$ (list: $a,f,d,e,i$): $a$ is the parent, so the search descends to $f$,
then $c$ (dead end), back up to $d$ (dead end), then $e$, then $i$, then $k$. The first
non-tree edge met is $(i,b)$: $b$ is gray but is **not** $i$'s parent, so it is a back edge — and
indeed the tree path $b \to e \to i$ plus $(i,b)$ is the cycle $b \to e \to i \to b$.
Every non-tree edge in the deck's figure points to an ancestor, never sideways: for an
undirected graph that is a theorem, not luck (Section 10).

> [!tip] BFS vs DFS, one line each
> BFS: FIFO queue, wide tree, gives distances and shortest paths. DFS: LIFO stack (recursion),
> deep tree, gives ancestor structure, finish order, and cycle certificates. Same complexity,
> different information.

---

## 10. Classifying edges

**Define.** After a BFS/DFS on a graph, every edge is one of:

| Type | Connects | Directed DFS | Undirected DFS | Undirected BFS |
|---|---|---|---|---|
| tree edge | parent to child in the search tree | yes | yes | yes |
| back edge | node to an **ancestor** (not its parent) | yes | yes | **no** |
| forward edge | node to a **descendant** (not a child) | yes | no | **no** |
| cross edge | no ancestor/descendant relation | yes | **no** | yes |

Directed BFS has tree and cross edges, and *can* have back edges (e.g. `1->2->3->1` from node 1:
the edge `3->1` points at an ancestor) but never forward edges — an edge $u \to v$ forces
$d[v] \le d[u]+1$, so no gap of two layers exists. That ambiguity ("black" = cross *or* back) is
exactly why BFS cannot classify directed edges well enough for Section 12.

![[16_GraphBasic.pdf#page=37]]
*Figure: the four edge types and the two theorems about undirected graphs.
(`16_GraphBasic.pdf` p. 37)*

**Theorem (undirected DFS).** There are no cross edges. *Proof:* take an edge $(u,v)$ with $u$
discovered first. When $u$ is processed, $v$ is still white (it is not yet discovered) or
already gray, and in both cases the recursion puts $v$ inside $u$'s DFS subtree — so $(u,v)$ is
a tree edge or a back edge.

**Theorem (undirected BFS).** There are no forward or back edges. Every non-tree edge joins two
nodes in the same layer or in adjacent layers — never an ancestor and a distant descendant,
because BFS distances differ by at most 1 across an edge.

**Directed graphs keep all four types**, and telling them apart is how you test for cycles and
for unique paths.

---

## 11. Cycle detection

**Method 1 (count edges, undirected).** A tree has $\lvert V\rvert-1$ edges. Run BFS/DFS to find
each component, count its nodes $V_c$ and edges $E_c$; if $E_c \ge V_c$ there is a cycle.

![[16_GraphBasic.pdf#page=36]]
*Figure: the count-based test, $\Theta(\lvert V\rvert+\lvert E\rvert)$. (`16_GraphBasic.pdf` p. 36)*

**Method 2 (back edge, undirected DFS).** A cycle exists iff DFS finds a back edge, and the cycle
is *readable*: the tree path from $v$ to $u$ plus the edge $(u,v)$.

![[16_GraphBasic.pdf#page=39]]
*Figure: the DFS cycle detector — when a gray, non-parent neighbour $v$ is seen, walk parents
from $u$ up to $v$ to output the cycle. (`16_GraphBasic.pdf` p. 39)*

```text
DFS-Visit(u):
    u.color <- gray
    for each v in Adj[u]
        if v.color = white then
            v.p <- u;  DFS-Visit(v)
        else if v != u.p then           // back edge (u, v)
            output "cycle:"; walk u up to v via parents; return
    u.color <- black
```

**In plain words.** While exploring, suppose you find a corridor leading to a room that is already
on your own path back to the entrance. Then that corridor plus the path you walked is a loop —
you have walked a circle without meaning to. If you explore the whole building and never find such
a corridor, there was no loop.

**Example (deck p. 38).** In the DFS starting at $a$, the first back edge found is $(i,b)$: $b$
is an ancestor (not the parent) of $i$, the tree contains the path $b \to e \to i$, so the cycle
is $b \to e \to i \to b$.

**Method 3 (cross edge, undirected BFS).** A cycle exists iff BFS finds a non-tree edge; the
cycle is the two tree paths from $\mathrm{lca}(u,v)$ down to $u$ and $v$, plus the edge. Compute
the LCA by levelling up the deeper node by $\lvert d_u - d_v\rvert$ steps first, then moving both
up together.

![[16_GraphBasic.pdf#page=41]]
*Figure: the BFS cycle detector and the LCA walk. (`16_GraphBasic.pdf` p. 41)*

> [!warning] Directed cycle detection needs the gray/black distinction
> In a **directed** graph, an edge to an already-black node may be a cross edge (no cycle) — it
> is only an edge to a **gray** node that closes a cycle. Testing "already visited" instead of
> "gray" is the classic wrong answer. That is also the difference between a DAG and a general
> digraph (Section 13).

---

## 12. Exercise: unique simple paths

**Problem (deck p. 42).** Given a directed graph and a node $s$, does $s$ have a **unique** simple
path to every other node?

**Idea.** BFS/DFS from $s$; first check every node is reachable. Then classify edges:

| Edge type | Effect |
|---|---|
| tree | required, no extra path |
| back | safe: reaching an ancestor does not create a new simple path |
| forward | creates a second path to a descendant → **fail** |
| cross | creates a second path → **fail** |

**How to classify while searching.** In DFS: white ⇒ tree, gray ⇒ back, black ⇒ forward **or**
cross (both are fatal, so no need to distinguish). In BFS: white ⇒ tree, gray ⇒ back, black ⇒
ambiguous (cross or back) — which is why DFS is the right tool here and BFS's classification is
not enough.

---

## 13. Topological sort

**Define.** A **DAG** is a directed graph with no cycle. A **topological order** of a DAG is a
linear order of the vertices in which every edge $u \to v$ has $u$ before $v$. The order is
generally **not unique**.

![[16_GraphBasic.pdf#page=43]]
*Figure: a 10-node DAG with two of its topological orders — $0,6,1,4,3,2,5,7,8,9$ and
$0,4,1,6,2,5,3,7,8,9$. (`16_GraphBasic.pdf` p. 43)*

**Key observation.** Every non-empty DAG has at least one vertex with in-degree 0 (otherwise
following in-edges backwards must eventually repeat a vertex, giving a cycle).

**Algorithm (Kahn).** Repeatedly output an in-degree-0 vertex and delete its out-edges.

![[16_GraphBasic.pdf#page=45]]
*Figure: the queue-based implementation. (`16_GraphBasic.pdf` p. 45)*

```text
TopologicalSort(G):
    Q <- empty queue
    for each u in V
        if indegree[u] = 0 then Enqueue(Q, u)
    while Q not empty
        u <- Dequeue(Q);  output u
        for each v in Adj[u]
            indegree[v] <- indegree[v] - 1        // delete edge (u, v)
            if indegree[v] = 0 then Enqueue(Q, v)
```

**Cost.** $\Theta(\lvert V\rvert+\lvert E\rvert)$ with an adjacency list: each node is enqueued
once, each edge decrements one counter once.

**In plain words.** Courses where some need others first. Repeatedly take any course nobody is
still waiting on, put it on the list, and cross it off everyone's prerequisite sheet. If you ever
run out of takable courses while courses remain, the requirements contradict each other —
somewhere there is a loop.

**Example (deck pp. 46–58, traced).** The queue starts empty; the only in-degree-0 node is 0, so
$Q = \{0\}$. Output 0 → nodes 6, 1, 4 become available, $Q = \{6,1,4\}$. Then
0, 6, 1, 4, 3, 2, 5, 7, 8, 9 — with the order inside the queue chosen arbitrarily at each step,
which is exactly why the order is not unique.

**Correctness.** The current graph stays a DAG (deleting a vertex cannot create a cycle), so a
source always exists and the loop outputs everything. And no edge $u \to v$ can be output with
$v$ before $u$: $v$ cannot enter the queue until the edge $u \to v$ has been deleted, which
happens only when $u$ is output.

> [!important] Topological sort as a cycle test
> If the loop ends with fewer than $\lvert V\rvert$ vertices output, the remaining subgraph has
> no source, hence contains a cycle. So the same $\Theta(\lvert V\rvert+\lvert E\rvert)$ work
> answers "is this digraph acyclic, and if so give an order".

---

## 14. Highlights

*(The deck has no summary slide; this is the distilled version of its 58 pages.)*

- Two explorations, both $\Theta(\lvert V\rvert+\lvert E\rvert)$: BFS (queue, layers, distances,
  shortest paths in unweighted graphs) and DFS (recursion, depth, ancestor structure, finish
  order).
- Components: wrap the search in a loop over still-white nodes. SCCs: intersect a forward and a
  backward search from the same node (deck's $O(\lvert V\rvert\lvert E\rvert)$ algorithm).
- Many "graph" problems are BFS on an *implicit* graph: knight moves, mazes, minimum number of
  moves anything.
- Parity of BFS distance = 2-colouring $\Rightarrow$ bipartite test, and an edge inside a layer
  is an odd cycle.
- Edge classification is the reusable tool: undirected DFS has only tree and back edges;
  undirected BFS has only tree and cross edges; directed searches have all four. Back edge ⇒
  cycle (undirected DFS), gray target ⇒ cycle (directed DFS).
- Topological sort = repeatedly remove an in-degree-0 vertex; $\Theta(\lvert V\rvert+\lvert E\rvert)$
  and simultaneously an acyclicity test.

## 15. Exam traps

- **Using DFS for shortest paths** $\to$ wrong. DFS has no distance guarantee; only BFS does, and
  only for unweighted graphs.
- **Assuming BFS/DFS cost is $\Theta(\lvert V\rvert\lvert E\rvert)$** $\to$ it is
  $\Theta(\lvert V\rvert+\lvert E\rvert)$ with adjacency lists; with a matrix it becomes
  $\Theta(\lvert V\rvert^2)$ because each neighbour scan costs $\Theta(\lvert V\rvert)$.
- **Forgetting the outer loop in `BFS(G)`/`DFS(G)`** $\to$ you explore one component and silently
  report a disconnected graph as connected.
- **Directed reachability assumed symmetric** $\to$ in a digraph, "reachable from $s$" needs a
  *reverse* graph to answer "can reach $s$". That is exactly why the strong-connectivity test
  runs BFS twice.
- **SCC = "nodes on a cycle"** $\to$ no: SCCs are the maximal mutually reachable sets, found by
  intersecting forward and backward reachability. In the Section 6 example node 3 is a bridge
  yet belongs to the first SCC.
- **Testing "visited" instead of "gray" for directed cycles** $\to$ an edge to a black node is a
  cross edge, not a cycle. Only gray closes a cycle in a directed DFS.
- **Undirected DFS assumed to have cross edges** $\to$ it has none; the theorem is what makes
  "back edge = cycle" valid for undirected graphs.
- **Undirected BFS assumed to have back edges** $\to$ it does not (distances across an edge
  differ by at most 1), which is why undirected cycle detection with BFS uses cross edges + LCA.
- **Bipartite test on a disconnected graph with one BFS** $\to$ run the parity check per
  component (or after a full `BFS(G)`).
- **"No odd cycle" checked by looking for cycles** $\to$ use parity inherent in BFS distances;
  enumerating cycles is exponential.
- **Topological sort on a graph with a cycle** $\to$ the queue empties early and you output fewer
  than $\lvert V\rvert$ nodes. Do not force an order; report the cycle.
- **Claiming the topological order is unique** $\to$ it is not; any queue discipline gives a valid
  order, and the deck shows two for the same DAG.
- **DFS recursion depth** $\to$ $\Theta(\lvert V\rvert)$ in the worst case (a path graph); on large
  graphs an explicit stack is required in practice.
