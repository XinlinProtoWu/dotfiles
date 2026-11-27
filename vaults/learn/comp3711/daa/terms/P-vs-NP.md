# P versus NP (as used in this course)

**What it is.** The open question of whether every problem whose solution can be *checked* in
polynomial time can also be *solved* in polynomial time. In this course it appears only as a
statement about TSP: no polynomial-time algorithm is known, and the conjecture is that none
exists.

**Why it exists.** It is the reason two visually identical graph problems (minimum spanning tree
vs travelling salesman) sit on opposite sides of a complexity cliff: one is $O(\lvert E\rvert\log\lvert V\rvert)$,
the other has no known polynomial algorithm.

**Example.** MST: greedy, polynomial, correct. TSP (minimum-weight cycle through all vertices): no
known polynomial algorithm; the deck states the question is equivalent to $\mathbf{P} = \mathbf{NP}$,
which is open.

**Where it appears:** [[lec_15_graph_theory]] Sections 1

**Related:** [[terms/graph]] · [[terms/MST]] · [[terms/big-O]]
