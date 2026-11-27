# Queue (FIFO) and stack (LIFO)

**What it is.** A queue removes the item that was inserted earliest (FIFO); a stack removes the
most recent (LIFO). BFS is a queue; DFS is a stack (usually the call stack).

**Why it exists.** The *only* difference between BFS and DFS — apart from bookkeeping — is which
frontier node is expanded next. That single choice decides whether you get distances and layers
(BFS) or ancestor structure and finish order (DFS).

**Example.** On the 6-cycle from node 1: the queue holds $\{2,6\}$ after expanding 1, so both are
distance 1; in DFS the second neighbour is not even looked at until the first subtree is finished.

**Where it appears:** [[lec_16_basic_graph_algorithms]] Sections 2–3, 9, 13

**Related:** [[terms/BFS]] · [[terms/DFS]] · [[terms/priority-queue]]
