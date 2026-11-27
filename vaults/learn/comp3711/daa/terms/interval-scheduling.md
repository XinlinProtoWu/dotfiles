# Interval scheduling, covering and partitioning

**What it is.** Three problems on intervals $[s_j, f_j]$, which differ only in objective and
therefore in the correct greedy order:

- **Scheduling** (maximise the number of mutually compatible jobs): sort by **finish** time, take
  each job that starts after the last accepted one. $\Theta(n\log n)$.
- **Partitioning** (minimum rooms so no two lectures overlap): sort by **start** time, open a new
  room only when no existing room is free; $\Theta(n\log n)$ with a min-heap of finish times.
- **Covering** (minimum intervals covering $[0,1]$): repeatedly take the interval reaching
  furthest right from the current coverage point. $O(n\log n)$.

Two intervals are **compatible** iff $f_i \le s_j$ — touching at an endpoint is allowed.

**Why it exists.** These three are the standard test of whether you know *which quantity pulls the
sort*. Three other orders (earliest start, shortest interval, fewest conflicts) each fail on a
three-line instance, so the rules cannot be guessed; they must be remembered with their objective.
Partitioning additionally shows an argument that is *not* an exchange argument: greedy's room
count equals the **depth** (maximum simultaneous overlap), which is a lower bound.

**Example.** Lectures A=[1,3], B=[2,4], C=[4,5], D=[3,6]. Sorted by start: A → room 1, B → room 2,
D → room 1 (3 ≤ 3), C → room 2 (4 ≤ 4): 2 rooms, and depth is 2, so optimal. The same instance
sorted by *finish* time and given an arbitrary free room needs 3.

**Where it appears:** [[lec_10-11_greedy]] Sections 4, 5, 7, 8, 9

**Related:** [[terms/greedy-algorithm]] · [[terms/exchange-argument]] · [[terms/priority-queue]] · [[terms/weighted-interval-scheduling]]
