# 14 — Distance Vector Routing

> Source: `14-Distance_Vector.pdf`. Goal: the first *real* routing algorithm — every router keeps a **distance vector** (shortest distance to every destination), exchanges it with neighbours, and the network converges to shortest paths. Plus the famous **count-to-infinity** failure and its fixes.
>
> Preceded by [[13_LAN]] (broadcast + learning switches); succeeded by [[15_Link_Layer]] (link state). The **Routing Information Protocol ([[terms/RIP]])** is a real-world **Distance Vector ([[terms/DV]])** protocol.

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Routing algorithms:** [[terms/DV]] · [[terms/RIP]] · [[terms/link-state]] · [[terms/STP]]

**Link-layer prerequisites:** [[terms/MAC]] · [[terms/IP]] · [[terms/ARP]] · [[terms/DHCP]]

**Distance-vector mechanics:** [[terms/MAX_DIST]] · [[terms/big-O]]

**Routing and the wider Internet:** [[terms/BGP]]

## 1. Why leave broadcast behind?

[[13_LAN]] ended with a comparison. Broadcast + learning switches

- uses `O(#nodes)` state,
- needs no setup,
- but causes **broadcast storms** and does **not** give shortest paths.

| | Broadcast + learning | + Spanning tree | **Distance Vector** ([[terms/RIP]]) |
|---|---|---|---|
| Shortest path? | not necessarily | not necessarily | **yes** |
| Routing efficiency | broadcast storm | still floods unknown destinations | packets sent **directly** to the destination |
| Convergence | no setup | must run **Spanning Tree Protocol ([[terms/STP]])** first | must run [[terms/DV]] first |

![[14-Distance_Vector.pdf#page=6]]
*Figure: DV is the first column that says "Yes" to shortest paths. (`14-Distance_Vector.pdf` p. 6)*

**Key contrast with spanning tree.** STP computes shortest paths to **one** destination (the root). The Distance Vector algorithm computes shortest paths to **every** destination. That is the whole generalisation.

![[14-Distance_Vector.pdf#page=7]]
*Figure: recall STP — there is exactly one node everyone has a shortest path to. (`14-Distance_Vector.pdf` p. 7)*

### Warm-up recap of the link layer

Before DV can run, a host must already be able to send one frame to its neighbour. That machinery (from [[13_LAN]]) is:

| Piece | Question answered |
|---|---|
| Ethernet header | which **Media Access Control ([[terms/MAC]])** address on this wire? (per-hop) |
| **Internet Protocol (IP)** header | which **host in the world**? (end-to-end) |
| **Dynamic Host Configuration Protocol ([[terms/DHCP]])** | what is *my* IP address, gateway, netmask? |
| **Address Resolution Protocol ([[terms/ARP]])** | what is *your* MAC address? |
| Gateway | where to send anything outside my prefix |

![[14-Distance_Vector.pdf#page=2]]
*Figure: everything that must be reassembled/delivered in a frame — headers on headers. (`14-Distance_Vector.pdf` p. 2)*

---

## 2. The core idea: a table indexed by "via which neighbour"

Each router keeps, for **every destination**, the shortest distance **via each of its neighbours**.

![[14-Distance_Vector.pdf#page=8]]
*Figure: A's route table — rows are destinations, columns are neighbours ("via B", "via C"). (`14-Distance_Vector.pdf` p. 8)*

$$d_C(A,D) = \text{shortest distance from } A \text{ to } D \text{ going through neighbour } C$$

**Simple example.** Topology $A - B - D$ and $A - C - D$, with $w(A,B)=1$, $w(B,D)=3$, $w(A,C)=1$, $w(C,D)=2$:

| A's table | via B | via C |
|---|---|---|
| to B | **1** | 1 + 2 + 3 = 6 (never used) |
| to C | 1 + 3 + 2 = 6 | **1** |
| to D | 1 + 3 = **4** | **1 + 2 = 3** ← better |

Link weights need not be 1 — they can be latency, cost, or hop count.

![[14-Distance_Vector.pdf#page=11]]
*Figure: a link weight can be anything, for example 3 ms of latency. (`14-Distance_Vector.pdf` p. 11)*

### The distance vector = the minimum of each row

Compress the table by taking `min` across neighbours:

| Destination | min dist | via |
|---|---|---|
| A | 0 | — |
| B | 1 | B |
| C | 1 | C |
| D | 3 | C |

That minimum column **is A's distance vector** — the thing A sends to its neighbours.

![[14-Distance_Vector.pdf#page=13]]
*Figure: the distance vector is the per-row minimum of the table. (`14-Distance_Vector.pdf` p. 13)*

---

## 3. How the table gets filled: learning from scratch

At boot, a router knows **only its direct links**. Everything else is `∞`, read as *infinity* and meaning "no route known yet / unreachable".

**Step 0 — A's table has only one-hop knowledge:**

| A's table | via B | via C |
|---|---|---|
| to B | 1 | ∞ |
| to C | ∞ | 1 |
| to D | ∞ | ∞ |

![[14-Distance_Vector.pdf#page=17]]
*Figure: an empty table — we have to learn by receiving DVs from others. (`14-Distance_Vector.pdf` p. 17)*

**Step 1 — B sends its DV:** $d_B(A)=1$, $d_B(C)=3$, $d_B(D)=2$.

A adds the cost of the A–B link ($w=1$) to every entry:

- to C via B $= 3 + 1 = 4$ → now A knows C.
- to D via B $= 2 + 1 = 3$ → now A knows D.

![[14-Distance_Vector.pdf#page=19]]
*Figure: after one exchange A has filled in C and D. (`14-Distance_Vector.pdf` p. 19)*

**The rule, once and for all:**

```text
on receiving DV_N from neighbour N (link cost w):
    for every destination X in DV_N:
        candidate = DV_N[X] + w
        if candidate < table[X][via N]:   # or if the entry is new
            table[X][via N] = candidate
    table[X] = min over all neighbours      # then compress
    if min changed: send my new DV to all neighbours
```

Note the shape of this: **vector addition, then a min.** That is literally the **Bellman–Ford** equation

$$
d(x,y) = \min_{v \in N(x)} \bigl[\, w(x,v) + d(v,y) \,\bigr]
$$

where $N(x)$ is the set of neighbours of $x$ and $w(x,v)$ is the weight of the link to $v$.

---

## 4. Summary of the algorithm (p. 20)

- Each router knows the links to its **neighbours** only.
- Each router has a **provisional shortest path to every other router** — its DV.
- Routers exchange DVs with **neighbours**.
- Routers pick the **best option offered** by any neighbour.
- Iterating converges to the set of shortest paths.

Two properties worth naming:

| Property | Meaning |
|---|---|
| **Iterative** | no termination signal; it just stops changing |
| **Asynchronous** | each router updates on its own clock (except in the textbook's "rounds" fiction) |
| **Distributed** | no node sees the whole topology — each only sees neighbour DVs |

---

## 5. How fast does it converge?

Assume for analysis that everything runs in **lock-step rounds** (not true in reality — see Section 6):

- Initial state: best **one-hop** paths.
- After 1 round: best **two-hop** paths.
- After `k` rounds: best **`(k+1)`-hop** paths.
- Converges when `k` reaches the length of the **longest best path**.

![[14-Distance_Vector.pdf#page=22]]
*Figure: each round extends the reachable path by one hop. (`14-Distance_Vector.pdf` p. 22)*

**Simple example.** A chain of 5 routers `R1—R2—R3—R4—R5`. `R1` can only learn about `R5` at distance 4 hops, so it takes 4 rounds. Convergence time ∝ **network diameter**, not number of nodes.

> **"Good news travels fast."** A new *shorter* route propagates one hop per round and is adopted immediately.

---

## 6. The real world is not synchronous

Slide 23 shouts it: **THE REAL WORLD DOES NOT RUN IN SYNCHRONOUS ROUNDS.** Routers update at different times; a router may be acting on a DV that is already stale.

Consequence: the *order* of updates matters, and some orders are bad (Section 8). This is why DV's convergence is described as "takes the length of the longest best path time" — and why *bad news* takes far longer than good news.

---

## 7. Worked exercise (slide 24)

> Given A's table, C's table, and a DV from D, plus link weight $w(C,D)=3$.

**Part 1 — What does A announce?**

| A's table | via B | via C | min |
|---|---|---|---|
| to B | 1 | 2 | **1** |
| to C | 4 | 3 | **3** |
| to D | 2 | 6 | **2** |

So A's DV is $d_A(B)=1$, $d_A(C)=3$, $d_A(D)=2$. (A does not advertise a distance to itself, or advertises 0.)

**Part 2 — C receives D's DV**, namely $d_D(A)=4$, $d_D(B)=2$, $d_D(D)=0$, and recomputes its "via D" column by adding the link cost $w(C,D)=3$:

| C's table | via B | via D (old) | via D (new $= d_D(\cdot)+3$) | min |
|---|---|---|---|---|
| to A | 1 | 5 | $4+3=\mathbf{7}$ | **1** (via B) |
| to B | 1 | 7 | $2+3=\mathbf{5}$ | **1** (via B) |
| to D | 2 | 3 | $0+3=3$ | **2** (via B) |

C's **table changes** (the via-D column goes 5→7 and 7→5), but C's **distance vector does not change** — every best route is still via B. So C has nothing new to advertise this round.

> [!tip] The lesson
> Updating a column ≠ changing the answer. **A router only re-advertises when its minimum changes.** This is why DV traffic is modest in a steady network.

![[14-Distance_Vector.pdf#page=24]]
*Figure: the exercise — fill in A's DV and update C's table. (`14-Distance_Vector.pdf` p. 24)*

---

## 8. Count to infinity — the disaster

### The setup

The deck's graph has three routers with link weights $w(A,B)=4$, $w(B,C)=50$ and $w(A,C)=1$ — see the slide below.

Distance vector **converged** state (note `B` reaches `C` cheaply *via A*, and `C` reaches `B` via `A`):

| Router | to A | to B | to C |
|---|---|---|---|
| **A** | 0 | **4** (via B) | **1** (via C) |
| **B** | **4** (via A) | 0 | **5** (via A→C) |
| **C** | **1** (via A) | **5** (via A→B) | 0 |

Both `B` and `C` are routing to each other **through A**. That is fine while nothing changes — nobody ever uses a 5-cost route when the direct 50 is there... except it *is* cheaper, so it *is* used. That is the time bomb.

![[14-Distance_Vector.pdf#page=31]]
*Figure: the initial, converged tables. (`14-Distance_Vector.pdf` p. 31)*

### The failure

Now the link $A$–$B$ becomes more expensive: $w(A,B)$ rises from **4** to **60**. `B` correctly notices and recomputes:

- $B \to A$: via $A$ costs $60$; via $C$ costs $50 + 1 = \mathbf{51}$ → B now goes via C. **Correct.**

But `A` looks at its *stale* information and sees:

- $A \to B$: via $B$ costs $60$; via $C$ costs $1 + 5 = \mathbf{6}$ → A picks **6**!

**$A$ reaches $B$ in 6 via $C$.** But C's 5 is the path $C \to A \to B$, so A's 6 is $A \to C \to A \to B$. The route contains $A$ itself — a **loop**.

![[14-Distance_Vector.pdf#page=37]]
*Figure: "These routes have a loop in them." (`14-Distance_Vector.pdf` p. 37)*

> [!note] Why loops are invisible at rest
> Loopy entries are harmless while they are not the *best* entry, because nobody chooses them. They become fatal the moment a link gets more expensive or fails — then the loop becomes the **only** candidate. (Slide 38.)

### How the loopy entries got there (slides 34–37)

This is the part that looks like magic: A's `via` columns change although **not one
of A's own links has changed**. The reason is that a `via X` column is a derived
quantity, not a stored fact:

$$\text{via } X \text{ to } Y \;=\; \bigl(\text{X's advertised distance to } Y\bigr) + w(A,X)$$

So it changes whenever a *neighbour's* number changes. It happened in two steps.

**Step 1 — B and C discover the detour through A is cheaper.** By slide 34 both
prefer to reach each other through A, because $1 + 4 = 5 < 50$:

| Router | its table | its *best* route | what it advertises (slide 35) |
|---|---|---|---|
| B | to C: via A **5**, via C 50 | 5 (**via A**) | `To A: 4, To C: 5` |
| C | to B: via A **5**, via B 50 | 5 (**via A**) | `To A: 1, To B: 5` |

Note what this means: B's "distance to C = 5" is a path that **passes through A**.
B is advertising to A a route that goes through A.

**Step 2 — A plugs those adverts into its own columns.** Its own link weights are
still 4 and 1:

| Column | slide 34 | slide 36 | arithmetic |
|---|---|---|---|
| via C to B | 51 | **6** | $\underbrace{5}_{\text{C's advert}} + \underbrace{1}_{w(A,C)} = 6$ |
| via B to C | 54 | **9** | $\underbrace{5}_{\text{B's advert}} + \underbrace{4}_{w(A,B)} = 9$ |

The old values came from the old adverts: C said "to B: **50**" and B said "to C:
**50**", so the columns read $50+1=51$ and $50+4=54$. Once both abandoned the direct
link, the 50s became 5s and the columns became 6 and 9.

They really are loops, and the arithmetic proves it:

$$A \to C \to A \to B = 1 + 1 + 4 = 6 \qquad A \to B \to A \to C = 4 + 4 + 1 = 9$$

Both contain A itself. They *overwrite* the old values because 6 < 51 and 9 < 54 —
but they are still worse than A's genuine direct entries (4 and 1), so **A's
forwarding does not change yet**. That is slide 38's point: nothing is broken *at
rest*, the trap is simply armed.

### The counting

Now the two routers feed each other's mistake:

| Round | A's claim "to B" | B's claim "to A" |
|---|---|---|
| start | 4 (correct) | 4 (correct) |
| after $w(A,B)=60$ | **6** (via C — loopy) | **51** (via C — correct) |
| exchange | A hears $51+60$ via B — no help → keeps 6, then grows | B hears $6+60$ via A — no help → … |
| … | $8, 10, 12, \dots$ | … |

Each exchange inflates the number by the cost of the link, so the value **ratchets upward in steps** — $6, 8, 10, \dots$ — one exchange at a time. Nothing ever says "your route loops back through me", so nothing can stop the escalation.

![[14-Distance_Vector.pdf#page=44]]
*Figure: the value creeping up (now 8) while everyone is still "converging". (`14-Distance_Vector.pdf` p. 44)*

This is the **count-to-infinity** problem: distances creep toward infinity instead of jumping to it.

### When does it stop?

Two ways:

1. **When the value finally exceeds the true shortest path** — at that point the real alternative wins and the counter is discarded. In the deck's triangle this happens at **51** (the route $A \to C \to B$ costs $1 + 50 = 51$). Slide 50 says exactly this: *"Count until we equal the 'real' shortest path."*
2. **When it hits the configured maximum** (Section 9) — if there is no real path at all.

![[14-Distance_Vector.pdf#page=50]]
*Figure: it finally settled at 51 — the true shortest path. (`14-Distance_Vector.pdf` p. 50)*

**Canonical picture (a line).** $A - B - C$, cost 1 each, $C$ is the destination:

1. Initially $d_A(C) = 2$ — the path $A \to B \to C$.
2. The link $B$–$C$ **fails**.
3. $B$ announces $d_B(C) = 3$ — it reuses A's *old* 2 and adds its own link.
4. $A$ announces $d_A(C) = 4$ — it reuses B's 3 and adds its own link.
5. $B$ announces $5$, $A$ announces $6$, and so on: $3, 4, 5, 6, 7, \dots$ toward infinity.

The increment is **2 per round trip**: each side adds its own link cost.

> [!important] The root cause
> **A router accepts a neighbour's report without knowing whether that neighbour's route comes back through itself.** DV carries only a *distance*, not a *path*, so loops cannot be detected. (This is precisely what [[11_BGP]] fixes by carrying the full **Autonomous System (AS)** path — the list of networks the announcement has crossed.)

---

## 9. Mitigations

![[14-Distance_Vector.pdf#page=52]]
*Figure: the two headline techniques. (`14-Distance_Vector.pdf` p. 52)*

### (1) Split horizon / poison reverse

> **If my best route to $X$ goes through you, I advertise $\infty$ to you for $X$.**

You never tell a neighbour about a destination whose path runs through them — because that information is worthless to them (it would have to come back to you).

**Effect on the triangle above:**

- `A`'s route to B is via B → `A` tells B: $d_A(B) = \infty$.
- `B`'s route to A is via A → `B` tells A: $d_B(A) = \infty$.

So when $w(A,B)$ goes from 4 to 60, `A` has **no** "via C = 6" option to latch onto, because C never learned a $d(B)$ value that came from A. The loopy entry is never created.

![[14-Distance_Vector.pdf#page=54]]
*Figure: poison reverse in action — each router tells its neighbour `∞` for the route it learned from that neighbour. (`14-Distance_Vector.pdf` p. 54)*

![[14-Distance_Vector.pdf#page=57]]
*Figure: result — no bad loopy entries. (`14-Distance_Vector.pdf` p. 57)*

> **"for that graph."** — slide 58 adds this warning. Poison reverse only handles loops that fold back **immediately**.

### Why poison reverse is not enough: "a completely sad graph"

![[14-Distance_Vector.pdf#page=59]]
*Figure: Z—A, and a triangle A–B–C. Z is only reachable through A. (`14-Distance_Vector.pdf` p. 59)*

All link weights are 1. $A$ reaches $Z$ in 1, so $B$ and $C$ reach $Z$ in 2 (both **via A**).

![[14-Distance_Vector.pdf#page=60]]
*Figure: the topology before the failure — the $A$–$Z$ link is still there, weight 1. (`14-Distance_Vector.pdf` p. 60)*

Now the $A$–$Z$ link **is cut**. The next slide shows the same graph with that edge
gone — the sad face is the lecturer's commentary on what follows.

![[14-Distance_Vector.pdf#page=61]]
*Figure: the $A$–$Z$ edge has been removed. (`14-Distance_Vector.pdf` p. 61)*

### Why $A$'s route to $Z$ goes to $\infty$ (and why nothing rescues it)

$A$'s `to Z` row has three columns — **via B, via C, via Z** — and only the last one
was ever finite: $A$ reached $Z$ over its *own direct link*, cost 1. $A$ knows only
its own links, so when that link dies the *via Z* column becomes $\infty$
immediately.

![[14-Distance_Vector.pdf#page=62]]
*Figure: $A$'s `to Z` row is now $\infty\,\infty\,\infty$ (the last $\infty$ marked in red). (`14-Distance_Vector.pdf` p. 62)*

Why can't $A$ simply take $Z$ from $B$ or $C$? Because **their only route to $Z$ ran
through $A$**: $B \to A \to Z$ at cost 2. Their number is worthless to $A$ —
substituting it would build $A \to B \to A \to Z$, a path through the very link
that just died. Poison reverse makes this explicit by advertising $\infty$ to $A$;
even without poison reverse the same entry is a loop.

So $\infty$ is **correct**: $Z$'s only physical link was the $A$–$Z$ edge, so $Z$ is
genuinely isolated. Note the asymmetry on the same slide — $B$ and $C$ still claim
$Z$ is at distance **2 via A**, and that stale number is the whole problem.

### How the lie then spreads

Poison reverse does its job:

- `B` and `C` both route to Z via A → they tell **A**: $d(Z) = \infty$.
- But they still tell **each other**: $d_B(Z) = d_C(Z) = 2$.

Each decides the other is the better route, so both update to **3 via the other**
($2 + 1$) — and now their route to $Z$ no longer passes through $A$, so poison
reverse no longer silences them toward $A$, and the stale $3$ reaches $A$. $A$ adds
its own link and gets $4$, and the ratchet is running.

![[14-Distance_Vector.pdf#page=63]]
*Figure: "B and C won't advertise the route for Z to A — but they will advertise it to each other." (`14-Distance_Vector.pdf` p. 63)*

![[14-Distance_Vector.pdf#page=66]]
*Figure: the count restarts at 4, 4, ∞ — it will run all the way to `MAX_DIST` (maximum distance). (`14-Distance_Vector.pdf` p. 66)*

**Why it fails:** the loop is $A \to B \to C \to B \to A$, a cycle of **length 3**. Poison reverse only poisons the *immediate* neighbour you learned from; B and C happily teach each other the lie. Slide 68 asks *"In this case, we will count how high?"* — the answer is **all the way to the maximum**, because there is no real path to stop at.

**General rule:** poison reverse kills 2-node mutual deception; it cannot kill longer cycles. The bad news is that longer cycles are exactly what appears in larger networks.

### (2) Maximum path length

> Set a finite `MAX_DIST` (maximum distance) and treat it as infinity. Stop counting there.

- In **RIP** the metric is hop count and infinity is **16** — so any legitimate path is at most 15 hops.
- This bounds convergence time: instead of counting forever, you wait at most `MAX_DIST` exchanges.

### (3) Holddown timers (mentioned on p. 71)

After learning that a route got *worse*, refuse to accept any new information about that destination for a fixed period, so the bad news has time to spread to everyone before anyone can be tempted by a stale good number.

### Summary of the three

| Technique | Kills | Cost |
|---|---|---|
| **Poison reverse / split horizon** | 2-node loops | nodes must track *which neighbour* each route came from |
| **Maximum path length** | infinite counting | a too-low cap wrongly declares real (long) routes unreachable; a too-high cap converges slowly |
| **Holddown timers** | transient bad-news races | legitimate route changes are delayed |

> [!warning] Even with all three
> DV still exhibits **very slow recovery** when link weights increase or links fail (slides 30, 71). It is a protocol used in practice (RIP), but this weakness is exactly what motivates link-state routing in [[15_Link_Layer]].

### Choosing `MAX_DIST` (the [[15_Link_Layer]] warm-up)

- **Too high** → count-to-infinity takes many exchanges → very slow convergence after a failure.
- **Too low** → a legitimate but long route gets treated as unreachable → the network wrongly appears partitioned.
- **So:** set `MAX_DIST` to the **largest possible legitimate simple path**:

$$\text{MAX\_DIST} = (N-1)\;\cdot\;w_{\max}$$

for $N$ nodes and maximum link weight $w_{\max}$. Big enough that every real path fits, small enough to bound the counting. (This is why RIP with 15 hops caps the Internet's DV at diameter 15.)

---

## 10. Cost accounting

| Item | DV's cost |
|---|---|
| State per node | $O(\#\text{switches} \times \max \deg) + O(\#\text{nodes})$ |
| Convergence | proportional to the **longest best path**, and much worse on **bad news** |
| Message size | one distance per destination — you reveal your distances to **everyone**, but not your topology |

![[14-Distance_Vector.pdf#page=27]]
*Figure: the DV column of the trade-off table. (`14-Distance_Vector.pdf` p. 27)*

The full comparison against link state is in [[15_Link_Layer]] Section 3.

---

## 11. Highlights (p. 71)

- Broadcast routing wastes resources and does not guarantee shortest paths.
- **DV is STP generalised**: instead of one shortest path (to the root), keep shortest paths to **every** destination. Used by **RIP**.
- DV suffers **count to infinity** whenever a link weight increases or a link dies.
- Three mitigations: **poison reverse**, **maximum path length**, **holddown timers**.
- Even so, DV recovers slowly from failures.

> [!tip] Exam traps
> - **Count to infinity is caused by *bad news*, not dead nodes.** A route getting *more expensive* is as dangerous as a route dying.
> - Increments are **link costs**, not 1 — get the arithmetic from the actual weights.
> - `∞` entries in a table usually mean **poison reverse**, not "no route".
> - Convergence time is bounded by **diameter** (longest best path), not by the number of routers.
> - Poison reverse fixes 2-node loops only — a 3-cycle still counts to infinity.
> - DV is **distributed** (neighbours only) but a router still needs `O(#nodes)` memory: it must remember one distance per destination.
