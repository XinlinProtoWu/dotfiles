# COMP 3711 — Design and Analysis of Algorithms: Index

Hub for the course notes in this vault. Each lecture note carries its own `## 0. Terms` block;
definitions themselves live once in `terms/` and are linked from first use.

## Lecture map

| Lecture | Topic | Note |
|---|---|---|
| 3 | Mergesort and divide & conquer | `LEC3_MergeSort.md` |
| 4 | Maximum subarray, integer and matrix multiplication | `Lec_4_maximum_subarray&integer_and_matrix_multiplication.md` |
| 5 | Multiplication (contd.) and randomisation | `lec_5_multiplication(contd)&random.md` |
| 6 | Randomised algorithms (contd.) | `Lec_6_random_cont'd.md` |
| 7 | Quicksort (contd.) | `lec_7_quicksort_cont'd.md` |
| 8 | Heapsort and priority queues | [[lec_8_heapsort]] |
| 9 | Linear-time sorting | [[lec_9_linearsort]] |
| 10–11 | Greedy algorithms and Huffman coding | [[lec_10-11_greedy]] |
| 12 | Dynamic programming | [[lec_12_dynamic_programming]] |
| 13 | 2-D dynamic programming | [[lec_13_2d_dynamic_programming]] |
| 14 | DP over intervals | [[lec_14_dp_over_intervals]] |
| 15 | Graph theory | [[lec_15_graph_theory]] |
| 16 | Basic graph algorithms (BFS, DFS, SCC, topological sort) | [[lec_16_basic_graph_algorithms]] |
| 17 | Minimum spanning trees (Prim, Kruskal, cut lemma) | [[lec_17_minimum_spanning_trees]] |
| 18 | Shortest paths (Bellman–Ford, DAG, Dijkstra, Floyd–Warshall) | [[lec_18_shortest_paths]] |
| 19 | Maximum flow and its applications | [[lec_19_max_flow]] |
| 20 | Stable matching (Gale–Shapley) | [[lec_20_stable_matching]] |

Companion sheets: [[algorithms_template_sheet]] (lectures 3–9 templates),
[[cheat_sheet_lec1-9]], [[midterm_solutions_explained]].

## Dependency chain (second half)

$$\begin{aligned}
&\text{greedy (10–11)} \to \text{DP (12–14)} \to \text{graphs (15–17)}\\
&\to \text{shortest paths (18)} \to \text{max flow (19)} \to \text{stable matching (20)}
\end{aligned}$$

- **18** uses the traversals and topological sort of **16**, the priority queue of **8**, and the
  cut language of **17** (but an s-t cut measures capacity, not MST weight).
- **19** uses BFS (Edmonds–Karp) from **16** and bipartite graphs from **15**; its correctness is a
  min-cut argument, not the MST cut lemma.
- **20** is independent of 18–19; it needs only preference lists and the idea of an exchange
  argument from **10–11**.

## Formula and algorithm sheet (lectures 18–20)

### Shortest paths

| Algorithm | Graph / weights | Time | Space |
|---|---|---|---|
| Bellman–Ford | any, no negative cycle | $O(\lvert V\rvert\lvert E\rvert)$ | $O(\lvert V\rvert)$ |
| DAG one-pass | DAG | $\Theta(\lvert V\rvert+\lvert E\rvert)$ | $O(\lvert V\rvert)$ |
| Dijkstra (heap) | nonnegative | $O(\lvert E\rvert\log\lvert V\rvert)$ | $O(\lvert V\rvert)$ |
| Dijkstra (array) | nonnegative, dense | $O(\lvert V\rvert^2)$ | $O(\lvert V\rvert)$ |
| Edge-count all-pairs | any | $O(\lvert V\rvert^4)$ | $O(\lvert V\rvert^2)$ |
| Repeated squaring | any | $O(\lvert V\rvert^3\log\lvert V\rvert)$ | $O(\lvert V\rvert^2)$ |
| Floyd–Warshall | any, no negative cycle | $O(\lvert V\rvert^3)$ | $O(\lvert V\rvert^2)$ |

Key recurrences:

$$v.d^{(i)}=\min_{(u,v)\in E}\bigl\{u.d^{(i-1)}+w(u,v)\bigr\}$$

$$d^{(k)}_{ij}=\min\bigl\{d^{(k-1)}_{ij},\ d^{(k-1)}_{ik}+d^{(k-1)}_{kj}\bigr\}$$

### Maximum flow

- Capacity $0\le f(e)\le c(e)$; conservation at every $v\notin\{s,t\}$;
  $\lvert f\rvert=\sum_v f(s,v)=\sum_v f(v,t)$.
- Cut capacity $c(S,T)=\sum_{e:S\to T}c(e)$; always $\lvert f\rvert\le c(S,T)$.
- **Max-flow min-cut:** max flow $=$ min cut; no augmenting path in $G_f$ is equivalent.
- Ford–Fulkerson: $O(\lvert f^*\rvert\lvert E\rvert)$ for integer capacities;
  Edmonds–Karp: $O(\lvert V\rvert\lvert E\rvert^2)$.
- Matching: unit-capacity flow; disjoint paths: unit-capacity flow; baseball: game nodes capacity 1.

### Stable matching

- At most $n^2$ proposals; $O(n^2)$ time with inverse preference lists.
- Gale–Shapley yields the **proposing side's optimal** stable matching.
- Stable matchings need not be unique; the roommates (non-bipartite) instance may have none.

## Exam-trap index

- Dijkstra needs **nonnegative** weights, not merely "no negative cycle".
- Bellman–Ford needs $\lvert V\rvert-1$ passes; pass $\lvert V\rvert$ only detects negative cycles.
- Floyd–Warshall's $k$ loop must be outermost; one $n\times n$ array is enough.
- Longest path is linear in a DAG but NP-hard in a general graph.
- Greedy augmentation is not max flow until **residual** paths are exhausted.
- Cut capacity counts only $S\to T$ edges.
- Gale–Shapley is men-optimal (proposer-optimal), not everyone-optimal; it does not solve the
  non-bipartite roommates problem.

## Terms

All definitions: `terms/` (one file per term). Start from
[[terms/shortest-path]], [[terms/max-flow]], [[terms/stable-matching]], or the course-wide
[[terms/big-O]] and [[terms/graph]].
