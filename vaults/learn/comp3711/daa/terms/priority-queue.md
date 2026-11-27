# Priority queue

**What it is.** A container supporting `Insert` and `Extract-Min` (or Max) in $O(\log n)$, and
optionally `Decrease-Key` in $O(\log n)$. Usually a binary heap.

**Why it exists.** Both "repeatedly take the cheapest thing available" algorithms in this course
are priority-queue algorithms: Prim's (key = cheapest edge into the tree) and Dijkstra's. The
`Decrease-Key` operation is what makes Prim's $O(\lvert E\rvert\log\lvert V\rvert)$; libraries that
omit it are handled by inserting duplicates and skipping stale entries on extraction.

**Example.** Prim on the 9-node graph: after adding $a$–$b$, $b$'s key is 4, $h$'s becomes 8 via
$a$ and 11 via $b$ (so 8 wins), and `Extract-Min` always returns the smallest current key.

**Where it appears:** [[lec_17_minimum_spanning_trees]] Section 2 · [[lec_8_heapsort]]

**Related:** [[terms/MST]] · [[terms/queue]] · [[terms/big-O]]
