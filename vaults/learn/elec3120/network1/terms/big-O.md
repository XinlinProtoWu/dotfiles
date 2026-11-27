# big-O notation — $O(\cdot)$

**What it is.** Notation for how a cost grows with input size, ignoring constant
factors: $O(n)$ = "grows linearly", $O(n \log n)$ = "slightly worse than linear".

**Why it appears in these notes.** Routing protocols are compared by the **state**
each node must store and by **convergence** cost:

| Protocol | State per node |
|---|---|
| Learning switch | $O(\#\text{nodes})$ |
| Spanning tree | $O(\#\text{nodes}) + O(1)$ path to root |
| Distance vector | $O(\#\text{switches} \times \max \deg) + O(\#\text{nodes})$ |
| Link state | $O(\#\text{edges})$ |
| Dijkstra | $O(\lvert E\rvert + \lvert V\rvert \log \lvert V\rvert)$ time |

**Reading it aloud.** "$O(\#\text{nodes})$" is "on the order of the number of
nodes" — it says nothing about the exact count, only how the count scales.

**Where it appears:** [[13_LAN]] Sections 8, 11 · [[14_Distance_Vector]] Section 10 · [[15_Link_Layer]] Sections 2, 3
