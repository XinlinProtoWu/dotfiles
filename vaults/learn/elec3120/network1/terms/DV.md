# Distance Vector (DV)

**What it is.** A routing algorithm in which every router keeps a **distance to
every destination** — its *distance vector* — learned only from its neighbours'
distance vectors.

**The rule.** Vector addition, then a minimum (the Bellman–Ford equation):

$$d(x,y) = \min_{v \in N(x)} \bigl[\, w(x,v) + d(v,y) \,\bigr]$$

**Why it exists.** It needs no global topology: each router knows only its own
links and its neighbours' claims. Perfect for small, simple networks.

**The fatal flaw: count to infinity.** A router accepts a neighbour's number
without knowing whether that route comes back through itself, so a route whose
cost *increases* can be rebuilt through a loop.

**Example.** $A - B - C$ with unit costs. The link $B$–$C$ fails. $B$ reuses A's
*stale* distance (2) and announces 3; $A$ reuses 3 and announces 4; and the two
ratchet upward $3, 4, 5, \dots$ toward infinity.

**Fixes.** Poison reverse (advertise $\infty$ back to the neighbour you learned a
route from) kills 2-node loops only; a maximum path length caps the counting; hold
down timers slow down re-adoption.

**Where it appears:** [[14_Distance_Vector]] throughout · [[15_Link_Layer]] Section 3

**Related:** [[terms/RIP]] · [[terms/link-state]] · [[terms/STP]] · [[terms/MAX_DIST]] · [[terms/BGP]]
