# Adjacency list and adjacency matrix

**What it is.** Two representations of $G = (V,E)$. **Adjacency list:** an array of lists, one
per vertex, holding its neighbours; space $\Theta(\lvert V\rvert + \lvert E\rvert)$. **Adjacency
matrix:** a $\lvert V\rvert \times \lvert V\rvert$ boolean array; space $\Theta(\lvert V\rvert^2)$.

**Why it exists.** Every running time in this course is stated *for a representation*. Listing
neighbours costs $\Theta(\deg u)$ on a list but $\Theta(\lvert V\rvert)$ on a matrix; testing one
edge is $O(1)$ on a matrix but $\Theta(\deg u)$ on a list. Pick the one the algorithm is shaped
for.

**Example.** $10^4$ vertices and $3\cdot10^4$ edges: the list stores about $4\cdot10^4$ entries,
the matrix $10^8$ — a factor of 2500 for the same graph. Converting either way costs
$\Theta(\lvert V\rvert^2)$.

**Where it appears:** [[lec_15_graph_theory]] Section 4 · [[lec_16_basic_graph_algorithms]] Section 1 · [[lec_17_minimum_spanning_trees]] Section 2

**Related:** [[terms/graph]] · [[terms/BFS]] · [[terms/DFS]]
