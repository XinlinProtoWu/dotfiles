# COMP 3711 — Written Assignment 4 — Solutions

**Name:** ____________________________  
**Student ID:** ______________________  
**Email:** ___________________________

---

## 1. Iterative DFS

### (a) Does the simple stack version visit vertices in the same order?

**No.** Take

$$
V=\{s,a,b\},\qquad E=\{(s,a),(s,b)\},\qquad \operatorname{Adj}[s]=(a,b).
$$

Recursive DFS from $s$ visits

$$
s,\ a,\ b.
$$

The stack version pushes $s$, pops and visits $s$, then pushes $a$ and $b$. Since the stack is LIFO, it pops $b$ first:

$$
s,\ b,\ a.
$$

So the orders differ: pushing all neighbours at once reverses the sibling order.

> If neighbours were pushed in reverse order, the visit order would match the recursive version. The algorithm as written does not do this.

### (b) Completed stack DFS that reports back edges

```text
Algorithm 2  Stack DFS starting from vertex s
for all vertex u ∈ V do
    u.color ← WHITE
    u.index ← 1
end for
S ← EmptyStack()
s.color ← GRAY
S.push(s)
while S is not empty do
    u ← S.top()
    found_white ← false
    while u.index ≤ |Adj[u]| do
        v ← Adj[u][u.index]
        u.index ← u.index + 1

        if v.color = WHITE then
            v.color ← GRAY
            S.push(v)
            found_white ← true
            break
        else if v.color = GRAY then
            output (u, v)              ▷ back edge
        end if
    end while

    if not found_white then
        u.color ← BLACK
        S.pop()
    end if
end while
```

**Why it works.** A vertex is GRAY exactly while it is on the current DFS stack, i.e. while it is an ancestor of the vertex currently being explored. Thus an edge $u\to v$ with $v$ GRAY is precisely a back edge. A WHITE neighbour is coloured GRAY and pushed immediately, so the search descends into it exactly as the recursive version does. When no WHITE neighbour remains, $u$ is finished and coloured BLACK.

> The skeleton starts the search from $s$ only. For a full DFS over all components, wrap the initialization and the outer `while` in a loop over all vertices, resetting each new root's index and colour.

---

## 2. Semi-connected directed graphs

### (a) $G$ is semi-connected iff the SCCs form a single directed path

**($\Rightarrow$)** Let $A,B$ be two SCCs of $G$, and pick $a\in A$, $b\in B$. Since $G$ is semi-connected, there is a path $a\to b$ or $b\to a$. Contracting each SCC to one vertex gives a path $A\to B$ or $B\to A$ in $G_{\mathrm{SCC}}$. Hence every pair of SCCs is comparable by reachability.

Take a topological order $A_1,\dots,A_k$ of the DAG $G_{\mathrm{SCC}}$. For $i<j$, there is no path $A_j\to A_i$ (topological order), so semi-connectivity forces a path $A_i\to A_j$. In particular, for consecutive SCCs $A_i,A_{i+1}$, a path of length $\ge 2$ would pass through an SCC whose topological index lies strictly between $i$ and $i+1$, impossible. Therefore $A_i\to A_{i+1}$ is an edge. Thus $G_{\mathrm{SCC}}$ contains the directed path

$$
A_1\to A_2\to\cdots\to A_k
$$

through all SCCs (any additional edges point forward and are harmless).

> **Wording note.** Read "$G_{\mathrm{SCC}}$ is a single directed path" as "$G_{\mathrm{SCC}}$ contains a directed path through all SCCs" (a Hamiltonian path). If $G_{\mathrm{SCC}}$ also has extra forward edges such as $A_1\to A_3$, it is still semi-connected. Equivalently, $G_{\mathrm{SCC}}$ has a unique topological order.

**($\Leftarrow$)** Suppose $G_{\mathrm{SCC}}$ contains a path $A_1\to A_2\to\cdots\to A_k$ through all SCCs. Let $u\in A_i$ and $v\in A_j$. If $i\le j$, concatenate a path inside $A_i$ from $u$ to the tail of the edge $A_i\to A_{i+1}$, the condensation path edges, and paths inside each SCC, ending at $v$. This gives a directed path $u\to v$. If $i>j$, the same construction gives $v\to u$. Hence $G$ is semi-connected.

### (b) $O(V+E)$ check

```text
SEMI-CONNECTED(G):
1. Compute the SCCs of G and comp[v] for every vertex v.      // O(V+E)
2. Build G_SCC:
       for each (u,v) ∈ E with comp[u] ≠ comp[v]:
           add edge comp[u] → comp[v]
       compute indegrees in G_SCC.                            // O(V+E)
3. Q ← all SCC-nodes with indegree 0.
4. while Q is not empty:
       if |Q| > 1 then return NO        // two incomparable SCCs
       x ← Q.dequeue()
       for each edge x → y in G_SCC:
           indeg[y] ← indeg[y] − 1
           if indeg[y] = 0 then Q.enqueue(y)
5. return YES
```

**Correctness.** $G_{\mathrm{SCC}}$ is a DAG. A DAG has a unique topological order iff it contains a directed path through all its vertices: if at some point there are two zero-indegree vertices, they are incomparable and can be ordered either way; if the order is unique, consecutive vertices must have an edge, otherwise they could be swapped. Therefore the loop accepts exactly when $G_{\mathrm{SCC}}$ is a single directed path, which by (a) is equivalent to $G$ being semi-connected.

**Time.** SCC computation and condensation construction are $O(V+E)$; Kahn's loop is $O(V+E)$. Total $O(V+E)$.

---

## 3. Reverse Kruskal

### (a) Heaviest edge of a cycle is avoidable

Let $e$ be a heaviest edge of a cycle $C$. If no MST contains $e$ we are done; otherwise let $T$ be an MST containing $e$. Removing $e$ from $T$ splits it into two components; the path $C-e$ joins the endpoints of $e$, so it contains an edge $f\neq e$ crossing the cut between them. Then $T-e+f$ is a spanning tree. Since $e$ is heaviest on $C$, $w(f)\le w(e)$, so $w(T-e+f)\le w(T)$; hence $T-e+f$ is an MST of $G$ avoiding $e$.

### (b) Correctness of reverse Kruskal

Assume $G$ is connected. Let $G_i$ be the current graph. **Invariant:** $G_i$ contains some MST $T$ of $G$. True initially since $G_0=G$.

When edge $e$ is processed, suppose it lies on a cycle $C$ of $G_i$. No other edge of $C$ was processed earlier: an earlier edge that survived was then not on a cycle, and later deletions can't create one, contradicting it lying on $C$. So $e$ is a heaviest edge of $C$.

If $e\notin T$, then $T\subseteq G_i-e$. If $e\in T$, removing $e$ splits $T$ into two components; the path $C-e$ contains an edge $f$ crossing between them. Then $T-e+f$ is a spanning tree, and $w(f)\le w(e)$, so $w(T-e+f)\le w(T)$; it is again an MST of $G$, lying in $G_i-e$. The invariant is preserved.

Finally the graph is connected (we delete only cycle edges, never bridges) and acyclic (a surviving cycle's last edge would have been deleted). So the result is a spanning tree that contains an MST of $G$, hence is that MST.

### (c) $O(V+E)$ cycle test for an edge $e=(u,v)$

In the current graph $G_i$, delete $e$ temporarily and run BFS or DFS from $u$. The edge $e$ lies on a cycle iff $v$ is reachable from $u$ in $G_i-e$. BFS/DFS takes $O(V+E)$ time.

### (d) Running time

- Sorting the edges: $O(E\log E)$.
- One cycle test per edge: $E\cdot O(V+E)=O(E(V+E))$.

Hence the total running time is

$$
O(E\log E+E(V+E))=O(E(V+E)).
$$

For a connected graph $E\ge V-1$, so this is $O(E^2)$. Space is $O(V+E)$.

---

## 4. Shortest beautiful path

Run Dijkstra from $s$ on $G$ (giving $d_s(x)=\operatorname{dist}(s,x)$) and from $t$ on the reversed graph $G^R$ (giving $d_t(x)=\operatorname{dist}(x,t)$). If $d_s(t)=\infty$, report that no path exists. By the hint, an edge $(u,v)$ lies on some shortest $s$–$t$ path iff

$$
d_s(u)+w(u,v)+d_t(v)=d_s(t),
$$

so mark every such edge as **bad**, delete all bad edges, and run Dijkstra from $s$ to $t$ on the remaining graph $G'$. Return the shortest path found, or report that none exists if $t$ is unreachable.

**Correctness.** By the condition, the bad edges are exactly those on some shortest path, so a path is beautiful iff it avoids all bad edges, i.e. iff it lies in $G'$. Dijkstra returns the shortest such path (all weights are non-negative).

**Time.** Three Dijkstra runs plus one edge scan: $O(E\log V)$.

---

## 5. Tasks and machines via max flow

Let $A$ be the set of completed tasks and $B$ the set of bought machines.

### (a) From a finite cut to a selection

Given an $s$–$t$ cut $(S,T)$ with finite capacity, select

$$
A=\{i:T_i\in S\},\qquad B=\{j:M_j\in S\}.
$$

Finiteness means no infinite dependency edge crosses from $S$ to $T$. Hence if $T_i\in S$ and task $i$ requires machine $j$, then $M_j\in S$. So every selected task has all its required machines selected, and the selection is valid.

The cut capacity is

$$
\operatorname{Capacity}(S,T)
=\sum_{i:T_i\in T}p_i+\sum_{j:M_j\in S}q_j,
$$

because dependency edges do not cross the cut and infinite edges are absent. Therefore

$$
\sum_{i=1}^n p_i-\operatorname{Capacity}(S,T)
=\sum_{i:T_i\in S}p_i-\sum_{j:M_j\in S}q_j
=\text{profit}.
$$

### (b) From a valid selection to a cut

Given a valid selection $(A,B)$, define

$$
S=\{s\}\cup\{T_i:i\in A\}\cup\{M_j:j\in B\},\qquad T=V\setminus S.
$$

Validity ensures that whenever $T_i\in S$, all machines required by task $i$ are in $B\subseteq S$. Hence no infinite dependency edge goes from $S$ to $T$, so the cut is finite. Its capacity is

$$
\operatorname{Capacity}(S,T)
=\sum_{i\notin A}p_i+\sum_{j\in B}q_j.
$$

Thus

$$
\sum_{i=1}^n p_i-\operatorname{Capacity}(S,T)
=\sum_{i\in A}p_i-\sum_{j\in B}q_j
=\text{profit}.
$$

### (c) Algorithm

Choose

$$
\mathrm{INF}=1+\sum_{i=1}^n p_i+\sum_{j=1}^m q_j
$$

and replace every $\infty$ capacity by $\mathrm{INF}$. Build the network as described, compute a maximum flow $f^*$, and find a minimum $s$–$t$ cut $(S,T)$ (e.g. $S$ is the set of vertices reachable from $s$ in the residual graph).

Return the selection

$$
A=\{i:T_i\in S\},\qquad B=\{j:M_j\in S\}.
$$

Its profit is

$$
\sum_{i=1}^n p_i-|f^*|,
$$

which is maximal: every finite cut corresponds to a valid selection with profit $\sum_i p_i-\operatorname{Capacity}(S,T)$, and the minimum cut capacity is $|f^*|$. The choice of $\mathrm{INF}$ guarantees that a minimum cut never uses an infinite edge.

**Time.** With Edmonds–Karp on $V=n+m+2$ vertices and $E=O(nm+n+m)$ edges, the running time is $O(VE^2)$.

---

*End of solutions.*
