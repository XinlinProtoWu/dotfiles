# Lecture 15 — Graph Theory (Review)

> Source: `15_GraphTheory.pdf` (20 pages). Goal: fix the vocabulary — vertices, edges,
> degrees, paths, connectivity, trees — and the two counting lemmas (degrees sum to
> $2\lvert E\rvert$; a tree has $\lvert V\rvert - 1$ edges) that every later algorithm relies
> on. This deck is the toolbox for [[lec_16_basic_graph_algorithms]] and [[lec_17_minimum_spanning_trees]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**Structure:** [[terms/graph]] · [[terms/adjacency-list|Adjacency list and adjacency matrix]] · [[terms/tree]] · [[terms/DAG]]

**Counting:** [[terms/handshaking-lemma|Handshaking lemma]]

**Algorithms that use this vocabulary:** [[terms/BFS]] · [[terms/DFS]] · [[terms/MST|Minimum spanning tree (MST)]]

**Open problems:** [[terms/P-vs-NP]]

---

## 1. Why graphs, and why abstract graphs

**Motivate.** The same algorithm should solve "route a delivery truck", "order these course
prerequisites", "crawl the web" and "call these functions in the right order". The trick is to
solve the problem once, on an abstract graph, and map each application onto it.

![[15_GraphTheory.pdf#page=2]]
*Figure: the applications table — what the nodes and edges mean in each domain.
(`15_GraphTheory.pdf` p. 2)*

| Graph | Nodes | Edges |
|---|---|---|
| transportation | street intersections | highways |
| communication | computers | fibre optic cables |
| World Wide Web | web pages | hyperlinks |
| social | people | relationships |
| food web | species | predator–prey |
| software systems | functions | function calls |
| scheduling | tasks | precedence constraints |
| circuits | gates | wires |

**In plain words.** A sales rep has to visit every city once and come home by the shortest route
possible. Any proposed route takes a second to check, yet nobody knows a fast way to *find* the
best one. That gap between easy-to-check and fast-to-find is one of the biggest open questions in
computing — and it shows that "it's just a graph" does not mean "it's easy".

**Example (the same deck, two famous problems).** Visiting every city and returning home
shortest is TSP; ordering courses so every prerequisite comes first is topological sort. One is
believed intractable, the other is solvable in linear time — yet both are "just graphs". The
difference is *not* the data structure; it is the problem.

![[15_GraphTheory.pdf#page=3]]
*Figure: the TSP statement, reformulated as "find a minimum-weight cycle through all vertices".
(`15_GraphTheory.pdf` p. 3)*

> [!warning] TSP is not "hard because graphs are hard"
> The deck is explicit: we have **no** polynomial-time algorithm for TSP, and the conjecture is
> that none exists — this is equivalent to the open $\mathbf{P} \ne \mathbf{NP}$ question. Do
> not answer "TSP is NP-complete" as if it were a theorem of this course; the deck says the
> polynomial algorithm is *not known*.

---

## 2. Undirected and directed graphs

**Define.** $G = (V, E)$: $V$ is a set of nodes (vertices), $E$ a set of edges between pairs of
nodes. We abuse notation and also write $V$ and $E$ for the *counts*, and often $n = \lvert V\rvert$,
$m = \lvert E\rvert$.

![[15_GraphTheory.pdf#page=7]]
*Figure: the deck's running example — an undirected graph on $\{1,2,3,4,5\}$ and a directed
graph on $\{1,\dots,6\}$. (`15_GraphTheory.pdf` p. 7)*

| | **Undirected** | **Directed** |
|---|---|---|
| Edge | no direction, $\{u,v\}$ | direction, $(u,v)$ or $u \to v$ |
| Degree | $\deg(v)$ = edges touching $v$ | $\deg_{out}(v)$ out, $\deg_{in}(v)$ in |
| Sum identity | $\sum_v \deg(v) = 2\lvert E\rvert$ | $\sum_v \deg_{out}(v) = \sum_v \deg_{in}(v) = \lvert E\rvert$ |
| Max edges | $\lvert V\rvert(\lvert V\rvert-1)/2$ | $\lvert V\rvert(\lvert V\rvert-1)$ |
| Both directions | one edge | **two** edges in opposite directions |

**Simple graphs.** We assume no self-loops and no duplicate edges, so between two nodes there
is at most 1 edge undirected and at most 2 directed. Multi-graphs are out of scope.

---

## 3. Counting: the exercises that actually appear on exams

**In plain words.** Six people and their friendships. Undirected: at most fifteen friendships,
because each person can know five others and each friendship is shared by two of them. Directed
("owes money to"): thirty, because A owing B and B owing A are two different facts.

**Example 1 (max edges).** With $\lvert V\rvert = 6$: undirected max $= 6 \cdot 5 / 2 = 15$;
directed max $= 6 \cdot 5 = 30$. The factor 2 is precisely "each undirected edge is two
directed edges".

**In plain words.** If every person has exactly three friends, the number of people must be even.
Count friendship-ends instead of friendships: each person contributes three, and every friendship
is counted twice, so the total is even — which is impossible if there is an odd number of people.

**Example 2 (all degrees 3).** If every node has degree 3 then
$3\lvert V\rvert = 2\lvert E\rvert$, so $3\lvert V\rvert$ is even, so $\lvert V\rvert$ is even.

**In plain words.** Now every person has an *odd* number of friends. Adding up odd numbers an odd
number of times would give an odd total, but the total is always twice the number of friendships,
which is even. So the number of people cannot be odd.

**Example 3 (all degrees odd).** Write $d(v_i) = 2k_i + 1$. Then

$$\sum_{i=1}^{\lvert V\rvert} d(v_i) = \lvert V\rvert + 2\sum_{i=1}^{\lvert V\rvert} k_i = 2\lvert E\rvert
\;\Longrightarrow\; \lvert V\rvert = 2\lvert E\rvert - 2\sum_i k_i$$

a difference of two even numbers, hence even.

![[15_GraphTheory.pdf#page=12]]
*Figure: the handshaking proof — split $V$ into $V_{odd}$ and $V_{even}$; the even part cannot
change the parity of the total. (`15_GraphTheory.pdf` p. 12)*

**The handshaking lemma.** In every graph, the number of nodes with **odd** degree is even.
This is the same computation as Example 3 with the sum split in two.

| The party version | The graph version |
|---|---|
| guests = nodes, handshakes = edges | $G = (V,E)$, edge iff the two guests shook hands |
| "an even number of guests shook an odd number of hands" | "$\lvert V_{odd}\rvert$ is even" |

**In plain words.** Eight people at a party, so each person shook between nought and seven hands.
Could all eight have shaken a different number? The one who shook seven shook *everyone's* hand —
including the hand of the one who shook nobody. Those two answers cannot both be true, so two
people always match.

**Example 4 (pigeonhole, deck p. 13).** In a group of 8 people, can everyone have shaken a
*different* number of hands? Degrees would have to be $0,1,\dots,7$. But the person with degree
7 shook hands with everyone, including the person with degree 0 — contradiction. So two people
always share a degree.

**In plain words.** Five of six people have 1, 2, 3, 4 and 5 friends; who is the sixth and how
many? The person with five knows everybody, so the person with one knows only them. The person
with four knows everyone except that loner, so the person with two knows exactly the five and the
four. Following that reasoning to the end leaves the sixth with exactly three.

**Example 5 (the 6-vertex puzzle, deck p. 13).** A simple connected graph on 6 vertices has five
vertices of degrees $1,2,3,4,5$. Find the sixth.

*Solution A (structural).* Let $\deg(v_i) = i$. $v_5$ is adjacent to all five others, so $v_1$'s
only neighbour is $v_5$. $v_4$ is adjacent to everything except $v_1$, so $v_2$'s neighbours are
exactly $v_4, v_5$. Now $v_6$ is adjacent to $v_4, v_5$ and not to $v_1, v_2$ — and $v_3$ has
degree 3 with neighbours $v_4, v_5$ plus one more, so $v_3$–$v_6$ must be an edge. Hence
$\deg(v_6) = 3$.

*Solution B (parity first).* $\sum \deg = 1+2+3+4+5+x = 15 + x$ must be even, so $x \in \{1,3,5\}$.
The structural argument rules out 1 and 5. Answer: **3**.

> [!tip] Parity is a free filter
> Before any structural argument, compute $\sum \deg = 2\lvert E\rvert$ and use parity. It
> cuts the candidate set for an unknown degree in half at zero cost.

---

## 4. Representations: adjacency list vs adjacency matrix

**Motivate.** Every later running time is quoted in terms of the representation, so pick the one
that matches the question. "Is $(u,v)$ an edge?" and "list my neighbours" pull in opposite
directions.

![[15_GraphTheory.pdf#page=15]]
*Figure: the two representations side by side. (`15_GraphTheory.pdf` p. 15)*

| Operation | Adjacency list | Adjacency matrix |
|---|---|---|
| Iterate neighbours of $u$ | $\Theta(\deg(u))$ | $\Theta(\lvert V\rvert)$ |
| Test $(u,v) \in E$ | $\Theta(\deg(u))$ | $O(1)$ |
| Space | $\Theta(\lvert V\rvert + \lvert E\rvert)$ | $\Theta(\lvert V\rvert^2)$ |
| Best when | sparse ($\lvert E\rvert \ll \lvert V\rvert^2$) | dense, or edge tests dominate |

**Convert** one to the other in $\Theta(\lvert V\rvert^2)$ time.

**In plain words.** Writing "who is friends with whom" as a giant table wastes a huge grid of
empty squares, because in real networks each person knows only a handful of others. A short list
per person holds the same information in a fraction of the space. The table only earns its keep if
you constantly ask "are these two friends?" and want an instant answer.

**Example.** $\lvert V\rvert = 10^4$ nodes. A sparse graph with $\lvert E\rvert = 3\cdot10^4$
edges: adjacency list stores $\approx 4 \cdot 10^4$ entries; adjacency matrix stores $10^8$ —
2500× more memory for the same information. But if an algorithm asks "is $(u,v)$ an edge?"
$O(\lvert E\rvert)$ times, the matrix's $O(1)$ lookup wins.

> [!important] Default to lists, and say so
> The deck's note is the examinable part: lists are used in practice because most graphs are
> sparse, and with $\lvert E\rvert \le \lvert V\rvert(\lvert V\rvert-1)/2$ an $O(\lvert V\rvert^2)$
> algorithm is only "linear" on dense graphs. Always state which representation your bound is
> for.

---

## 5. Paths, connectivity and cycles

**Define.**

- A **path** is a sequence $v_1, v_2, \dots, v_k$ with every $(v_i, v_{i+1}) \in E$; its
  **length** is $k-1$, the number of edges.
- A path is **simple** if all nodes are distinct.
- An undirected graph is **connected** if every pair has a path between them.
- A **cycle** is a path with $v_1 = v_k$ and $k > 2$; it is **simple** if $v_1,\dots,v_{k-1}$
  are distinct.

![[15_GraphTheory.pdf#page=16]]
*Figure: the deck's 13-node graph with worked examples — $2\,1\,3\,2$ is a simple cycle;
$2\,1\,3\,2\,5\,4\,2$ is a non-simple cycle. (`15_GraphTheory.pdf` p. 16)*

**Theorem.** A connected graph has $\lvert E\rvert \ge \lvert V\rvert - 1$.

**In plain words.** Six and one can reach each other; six and nine cannot. The quickest way from
six to eight is three roads — six, five, three, eight — even though slower ways exist. "Shortest"
is the best of the routes, not the only route.

**Example (distances, p. 18).** In the deck's graph, $6$ and $1$ are connected; $6$ and $9$ are
not; the shortest path $6 \to 5 \to 3 \to 8$ has length 3, and longer $6$–$8$ paths exist. Note
that "the shortest path" is a minimum over paths, not a unique object.

> [!warning] Undirected vs directed, one more time
> In an undirected graph $s$ reaches $t$ $\iff$ $t$ reaches $s$, and the shortest path is
> symmetric. In a directed graph **neither** holds: $u \to v$ does not give $v \to u$, and the
> shortest $u$-to-$v$ path tells you nothing about $v$-to-$u$. Every later algorithm
> ([[lec_16_basic_graph_algorithms]]) inherits this asymmetry.

---

## 6. The $\lvert V\rvert/2$ connectivity exercise

**Problem (deck p. 17).** In a wireless network of $n$ devices ($n$ even), each device is in
range of at least $n/2$ others. Show all devices are connected.

**Reformulate.** $G = (V,E)$ undirected with $\deg(v) \ge n/2$ for every $v$. Show $G$ is
connected.

**Proof.** Take any two nodes $u, v$. If $(u,v) \in E$ we are done. Otherwise $u$ and $v$ have
at least $n/2$ neighbours each, all inside the $n-2$ other nodes, so

$$\lvert N(u) \cup N(v)\rvert \ge \frac{n}{2} + \frac{n}{2} = n > n-2 = \lvert V \setminus \{u,v\}\rvert$$

so by pigeonhole $N(u) \cap N(v) \ne \emptyset$: a common neighbour $w$ gives the path
$u \to w \to v$. Since $u,v$ were arbitrary, $G$ is connected.

**In plain words.** If everyone in a room knows at least half the people there, the room is one
connected crowd: take two strangers, each of them knows half the room, and half plus half is more
than the people left over — so they must have an acquaintance in common. Drop "half" to "half
minus one" and it collapses: split the room into two separate cliques and nobody knows anybody
across.

**Example (the deck's follow-up, answered).** Does the claim survive if the threshold drops to
$n/2 - 1$? **No.** Take $n = 6$ and two disjoint triangles. Every vertex has degree $2 = n/2 - 1$,
and the graph is disconnected.

> [!important] The magic in the arithmetic
> The proof works because $n/2 + n/2 = n$ **exceeds** $n-2$. Any weaker threshold leaves a slack
> of at least 2, which is exactly enough room to place two disjoint components.

---

## 7. Trees

**Define.** A tree is an undirected graph that is **connected** and **acyclic**. A forest is an
undirected acyclic graph (a collection of trees).

![[15_GraphTheory.pdf#page=19]]
*Figure: the deck's tree with $\lvert E\rvert = 8$, $\lvert V\rvert = 9$ — one edge fewer than
nodes. (`15_GraphTheory.pdf` p. 19)*

**Theorem (any two imply the third).** For an undirected graph $G$, any two of

1. $G$ is connected,
2. $G$ contains no cycle,
3. $\lvert E\rvert = \lvert V\rvert - 1$

imply the third — i.e. any two of them already characterise a tree.

**In plain words.** Nine towns joined by eight roads, and you can get from any town to any other.
Eight is the smallest number of roads that can hold nine towns together, so not one of them is
wasted on a loop. Add a ninth road and it has nowhere to be useful except closing a circle.

**Example (using it).** A connected graph with 9 vertices has exactly 8 edges iff it is a tree.
So "connected and 8 edges" $\Rightarrow$ acyclic, and "acyclic and 8 edges" $\Rightarrow$
connected — no need to check the third property.

**Rooted trees.** Choose a root $r$ and orient every edge away from it. Then every node but $r$
has exactly one **parent** and may have many **children**; $r$ has neither. This is the object
underlying heaps ([[lec_8_heapsort]]), BFS/DFS trees ([[lec_16_basic_graph_algorithms]]), and
union-find forests ([[lec_17_minimum_spanning_trees]]).

![[15_GraphTheory.pdf#page=20]]
*Figure: the same tree drawn unrooted and rooted at node 1, with parent/child labels.
(`15_GraphTheory.pdf` p. 20)*

> [!warning] A tree is not "a graph with $\lvert V\rvert-1$ edges"
> The count alone is not enough: a triangle plus an isolated vertex has $3$ edges on $4$ nodes
> ($\lvert E\rvert = \lvert V\rvert - 1$) and is **not** a tree. The theorem needs *two* of the
> three properties, so you must also know connectedness (or acyclicity).

---

## 8. Highlights

*(The deck has no summary slide; this is its content compressed.)*

- Graphs abstract away the application; the same algorithm then serves routing, scheduling,
  software analysis — which is why we study abstract graphs rather than applications.
- Two counting identities do most of the work: $\sum_v \deg(v) = 2\lvert E\rvert$ and
  $\sum_v \deg_{out}(v) = \sum_v \deg_{in}(v) = \lvert E\rvert$. Parity consequences
  (odd-degree count is even) are the standard exam lever.
- Edge-count bounds: undirected $\le \lvert V\rvert(\lvert V\rvert-1)/2$; directed
  $\le \lvert V\rvert(\lvert V\rvert-1)$. A connected graph needs $\ge \lvert V\rvert-1$.
- Adjacency list: $\Theta(\lvert V\rvert+\lvert E\rvert)$ space, neighbour iteration
  $\Theta(\deg u)$, edge test $\Theta(\deg u)$. Matrix: $\Theta(\lvert V\rvert^2)$ space,
  $O(1)$ edge test. Convert in $\Theta(\lvert V\rvert^2)$.
- A tree is characterised by *any two* of {connected, acyclic, $\lvert E\rvert = \lvert V\rvert-1$}.
- TSP has no known polynomial algorithm; topological sort does. Both are graph problems.

## 9. Exam traps

- **$\lvert E\rvert$ vs $\deg$ mixing** $\to$ $\sum \deg = 2\lvert E\rvert$ for undirected,
  but $\sum \deg_{out} = \lvert E\rvert$ for directed. Using the factor 2 on a directed graph
  doubles your answer.
- **"Maximum edges in an undirected graph is $\lvert V\rvert^2$"** $\to$ no: self-loops are
  excluded and each pair is counted once, so $\lvert V\rvert(\lvert V\rvert-1)/2$.
- **Directed graph, $\lvert E\rvert \le \lvert V\rvert(\lvert V\rvert-1)/2$** $\to$ wrong; that
  is the undirected bound. Directed allows both directions, i.e. $\lvert V\rvert(\lvert V\rvert-1)$.
- **Assuming a connected graph with $\lvert V\rvert-1$ edges might have a cycle** $\to$ impossible;
  that is the theorem. Conversely, $\lvert V\rvert-1$ edges alone does **not** imply connected.
- **$\lvert V\rvert - 1$ edges $\Rightarrow$ tree** $\to$ false without connectivity (triangle +
  isolated vertex).
- **Path length counted as nodes** $\to$ length is the number of **edges**, so a $k$-node path
  has length $k-1$.
- **Cycle of length 2 in an undirected simple graph** $\to$ does not exist; the definition
  requires $k > 2$, and simple graphs forbid parallel edges.
- **Adjacency-matrix neighbour iteration assumed $O(\deg u)$** $\to$ it is $\Theta(\lvert V\rvert)$;
  that is the whole reason lists are preferred for sparse graphs.
- **"TSP is NP-complete, therefore …"** $\to$ the deck only claims no polynomial algorithm is
  known and that it is equivalent to $\mathbf{P} = \mathbf{NP}$ being open. Match the deck's
  claim, not the folklore.
- **Threshold exercises: proving connectivity from $\deg \ge n/2$ by counting edges** $\to$ the
  clean proof is the pigeonhole on two neighbourhoods ($n/2 + n/2 > n-2$). And the bound is
  tight: $n/2 - 1$ fails on two disjoint triangles with $n=6$.
