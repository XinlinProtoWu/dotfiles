# MAX_DIST — the "infinity" cap, and $\infty$

**What it is.** The finite number a distance vector protocol uses to mean
*unreachable*. In RIP, $\text{MAX\_DIST} = 16$.

**Why a finite infinity.** Real infinity never arrives, so count-to-infinity would
never terminate. A finite cap makes the bad news arrive in bounded time.

**Choosing it.** It must be at least the **longest legitimate simple path**:

$$\text{MAX\_DIST} = (N-1) \cdot w_{\max}$$

for $N$ nodes and maximum link weight $w_{\max}$. A simple path visits each node
at most once, so nothing real can be longer.

| Setting | Consequence |
|---|---|
| **Too high** | counting takes many exchanges → very slow recovery after a failure |
| **Too low** | a real (long) route looks infinite → the network wrongly appears partitioned. A **correctness** bug, not just slowness |

**$\infty$ in a table** means "no route known yet", not "distance is huge".

**Where it appears:** [[14_Distance_Vector]] Sections 3, 9 · [[15_Link_Layer]] Section 1

**Related:** [[terms/DV]] · [[terms/RIP]]
