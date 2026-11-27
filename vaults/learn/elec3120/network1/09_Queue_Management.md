# 09 — Queue Management

> Source: `09-Queue.pdf`. Goal: in-network resource allocation — max-min fairness, fair queueing, weighted fair queueing, token buckets, and network calculus.

## 1. Why in-network mechanisms?

End-host congestion control alone cannot guarantee fairness, priority, or per-user caps. Routers and switches must decide **which packet to send next** and **whose traffic to limit**.

This lecture covers:

1. **Max-min fairness** — what a fair allocation means.
2. **Fair queueing / WFQ** — how to approximate it in a router.
3. **Token buckets** — how to enforce per-user rates/caps.
4. **Network calculus** — how to bound backlog, delay, and drain time.

---

## 2. Max-min fairness

### The pizza story

Four roommates share a pizza:

- one **mouse** can eat at most `1/16`;
- three **elephants** can each eat at most `1/2`.

What is fair?

- Equal shares (1/4 each) waste food: the mouse cannot eat 1/4.
- **Max-min fairness**:
  - mouse gets `1/16` (its full demand);
  - remaining `15/16` is split among the three elephants → `5/16` each.

> **Idea:** maximize the minimum share, then give leftover capacity to the next smallest demand.

### Network version

- **Mice**: flows with small demand (e.g. Netflix at 40 Mbps on a 1 Gbps link).
- **Elephants**: flows that would take everything (e.g. a large download).

Max-min gives each flow its full demand if possible; otherwise it gives equal shares to the unsatisfied flows.

### Formal definition

Given demands `rᵢ` and total capacity `C`:

```text
aᵢ = min(f, rᵢ)
```

where `f` is the unique value such that:

```text
Σ aᵢ = C
```

- Flows with `rᵢ < f` get their full demand.
- Flows with `rᵢ ≥ f` get `f`.

![[09-Queue.pdf#page=22]]
*Figure: max-min allocation — each flow's demand is a bucket; fill equally until a bucket fills. (`09-Queue.pdf` p. 22)*

### Work-conserving

A scheduler is **work-conserving** if it never leaves the resource idle while work is waiting.

- “A pizza slice never goes uneaten when someone wants to eat it.”
- “The link never goes idle when there is at least one packet queued.”
- Max-min fairness is work-conserving: no bandwidth is wasted.

### Water-filling algorithm

![[09-Queue.pdf#page=28]]
*Figure: water-filling for C = 10, demands (8, 6, 2) → allocation (4, 4, 2). (`09-Queue.pdf` p. 28)*

Algorithm:

1. Pour capacity into all buckets equally.
2. When a bucket fills, stop pouring into it.
3. Continue pouring equally into the remaining buckets.
4. Stop when all buckets are full or capacity runs out.

> [!example] C = 10, demands (8, 6, 2)
> 1. Pour equally: `(2, 2, 2)`. Bucket 3 is full. Remaining capacity = 4.
> 2. Split 4 between the first two: `(4, 4, 2)`. Capacity exhausted.
> 3. `f = 4`: `min(4,8)=4`, `min(4,6)=4`, `min(4,2)=2`.

---

## 3. Normal switches: FCFS + drop-tail

![[09-Queue.pdf#page=31]]
*Figure: first-come-first-served scheduling with drop-tail. (`09-Queue.pdf` p. 31)*

Default router behavior:

- One queue for all traffic.
- **First-come-first-served (FCFS)** scheduling.
- **Drop-tail**: when the queue is full, drop newly arriving packets.

Result:

- Senders who send more packets get proportionally more throughput.
- No fairness guarantee.

---

## 4. Fair queueing (FQ)

### Per-flow queues + round-robin

![[09-Queue.pdf#page=33]]
*Figure: each flow gets its own queue; the scheduler serves queues round-robin. (`09-Queue.pdf` p. 33)*

Idea: give each flow its own queue and serve the queues **round-robin**.

This approximates max-min fairness — but there is a problem.

### Problem: packet sizes differ

![[09-Queue.pdf#page=35]]
*Figure: round-robin by packet is unfair when packet sizes differ. (`09-Queue.pdf` p. 35)*

- Flow A sends huge 1500 B packets.
- Flow B sends tiny 40 B packets.
- Packet-by-packet round-robin gives A far more bandwidth, because each “turn” sends a much larger packet.

### Ideal: bit-by-bit round-robin

![[09-Queue.pdf#page=36]]
*Figure: bit-by-bit round-robin — transmit one bit from each queue in turn. (`09-Queue.pdf` p. 36)*

- Serve one **bit** from each queue per turn.
- Both flows get equal bandwidth regardless of packet size.
- Unrealistic: routers cannot preempt a packet mid-transmission to send a single bit from another queue.

### Virtual time and finish times

FQ **simulates** bit-by-bit round-robin using **virtual time**.

For packet `i` in queue `q`:

```text
p(q,i) = size of packet i in bits
S(q,i) = virtual time when the first bit starts transmission
F(q,i) = virtual time when the last bit finishes
F(q,i) = S(q,i) + p(q,i)
```

How to get `S`:

```text
if the flow's queue was empty:
    S(q,i) = now()
else:
    S(q,i) = F(q,i−1) + ε
```

- `ε` is a tiny increment so packets from the same flow don't tie.
- The scheduler always transmits the packet with the **smallest finish time `F`**.

![[09-Queue.pdf#page=40]]
*Figure: FQ — calculate F for every arriving packet; scheduler picks the lowest F. (`09-Queue.pdf` p. 40)*

> [!example] Why the 100-bit packet goes first
> - Flow 1 packet of **1000 bits** arrives to an empty queue:
>   `S = now`, `F = now + 1000`.
> - Flow 2 packet of **100 bits** arrives to an empty queue:
>   `S = now`, `F = now + 100`.
> - The scheduler picks Flow 2's packet first, mimicking bit-by-bit round-robin.

### Non-preemptive caveat

![[09-Queue.pdf#page=42]]
*Figure: FQ approximates bit-by-bit RR but is non-preemptive. (`09-Queue.pdf` p. 42)*

- If a packet is already being transmitted, a newly arrived packet with a smaller `F` cannot preempt it.
- So FQ only **approximates** the ideal.
- FQ is **work-conserving**.

---

## 5. Weighted fair queueing (WFQ)

![[09-Queue.pdf#page=45]]
*Figure: WFQ assigns weights; higher-weight queues are served more often. (`09-Queue.pdf` p. 45)*

Assign each queue a weight `w_q`. Higher weights are served more frequently.

```text
F(q,i) = S(q,i) + p(q,i) × (Σ_j w_j) / w_q
```

where `Σ_j w_j` is the sum of weights over all queues.

> [!example] Weights 4 and 2
> - Flow 1 weight 4 → share `4/6 = 2/3`.
> - Flow 2 weight 2 → share `2/6 = 1/3`.
> - The weight-4 flow is served twice as often.

Use cases: giving business customers a larger share than residential customers, or prioritizing latency-sensitive traffic.

---

## 6. Token bucket shaping

### Traffic shaping

**Traffic shaping** delays packets to bring traffic into compliance with a desired profile. Unlike policing (which may drop), shaping **holds** packets and sends them later.

### Basic packet pacing

![[09-Queue.pdf#page=51]]
*Figure: basic pacing — release packets at a fixed rate r. (`09-Queue.pdf` p. 51)*

- One input queue; scheduler releases packets at rate `r`.
- This enforces a constant rate but does **not** allow bursts.
- Users who are idle cannot “save up” capacity.

### Token bucket

![[09-Queue.pdf#page=56]]
*Figure: token bucket — tokens arrive at rate r; bucket holds at most b tokens; each bit costs one token. (`09-Queue.pdf` p. 56)*

Two parameters:

- **Rate `r`**: tokens are added at `r` tokens/sec.
- **Burst `b`**: the bucket can hold at most `b` tokens.

Rules:

- The shaper spends **one token per bit transmitted**.
- If there are not enough tokens, it cannot send.
- Tokens accumulate when idle, up to `b`.

Consequences:

- **Average rate ≤ r**.
- You can send a **burst of up to b bits** instantly if the bucket is full.
- You cannot sustain faster than `r` over time.

![[09-Queue.pdf#page=62]]
*Figure: token bucket lets bursty traffic use saved tokens, while the long-term average stays ≤ r. (`09-Queue.pdf` p. 62)*

### Traffic envelope

A token bucket defines an upper bound on cumulative data sent:

```text
A(t) = b + r·t
```

- slope = rate `r`;
- y-intercept = burst `b` (worst case: bucket starts **full**).

![[09-Queue.pdf#page=53]]
*Figure: a traffic envelope bounds the total data a sender can transmit over time. (`09-Queue.pdf` p. 53)*

> [!example]
> `r = 10 Mbps`, `b = 5 Mb`:
> - can burst 5 Mb instantly;
> - average over time ≤ 10 Mbps;
> - envelope: `A(t) = 5 Mb + 10 Mbps·t`.

### Why not make `b` infinite?

![[09-Queue.pdf#page=80]]
*Figure: larger bursts create larger backlog and longer latency for other flows. (`09-Queue.pdf` p. 80)*

- A huge `b` lets one user dump a massive burst, monopolizing the link.
- Other users' packets queue behind it → high latency.
- So `b` must be bounded.

---

## 7. Network calculus

### Arrival and service curves

![[09-Queue.pdf#page=70]]
*Figure: arrival curve A(t) is an upper bound; service curve S(t) is the router's service rate. (`09-Queue.pdf` p. 70)*

- **Arrival curve `A(t)`**: upper bound on traffic entering the queue.
  - Token bucket: `A(t) = b + r·t`.
- **Service curve `S(t)`**: exact amount of data the router can serve.
  - Constant-rate link: `S(t) = R·t`.

### Reading the graph

Overlay `A(t)` and `S(t)`:

![[09-Queue.pdf#page=72]]
*Figure: vertical gap = backlog. (`09-Queue.pdf` p. 72)*

1. **Vertical gap** `A(t) − S(t)` = data sitting in the queue (worst-case backlog).

![[09-Queue.pdf#page=73]]
*Figure: horizontal gap = queueing delay. (`09-Queue.pdf` p. 73)*

2. **Horizontal gap** = how long a packet waits in the queue.

![[09-Queue.pdf#page=74]]
*Figure: intersection of A(t) and S(t) = time when the queue drains. (`09-Queue.pdf` p. 74)*

3. **Intersection** `A(t) = S(t)` = time when the queue finally drains after a burst.

### Multiple flows

To analyze several flows sharing a router, **add their arrival curves**:

![[09-Queue.pdf#page=77]]
*Figure: adding two identical envelopes: slope 2r, intercept 2b. (`09-Queue.pdf` p. 77)*

```text
A_total(t) = 2b + 2r·t
```

Then overlay `A_total(t)` on the router's `S(t)`.

> [!example] Two flows, one router
> Each flow: `r = 10 bps`, `b = 2 bits` → `A_total(t) = 4 + 20t`.
> Router: `S(t) = 30t`.
> Drain time:
>
> ```text
> 30t = 20t + 4  →  10t = 4  →  t = 0.4 s
> ```
>
> Worst-case backlog at `t = 0`: `4 bits`. Delay is the horizontal gap between the curves.

> [!example] Practice from the slides
> Flow 1: `r₁ = 10 bps`, `b₁ = 2 bits`.
> Flow 2: `r₂ = 10 bps`, `b₂ = 10 bits`.
>
> ```text
> A(t) = 20t + 12
> S(t) = 30t
> 30t = 20t + 12  →  t = 1.2 s
> ```
>
> The queue fully drains at **t = 1.2 s**.

---

## 8. Takeaways

- Most routers/switches still use plain **FCFS + drop-tail**.
- ISPs and enterprises commonly enable:
  - **WFQ** to allocate bandwidth by weight;
  - **token buckets** to enforce per-user rate plans.
- **Fair queueing** approximates **max-min fairness** via virtual finish times.
- **Token buckets** enforce an average rate `r` while allowing bursts up to `b`.
- **Network calculus** (arrival/service curves) lets you bound:
  - worst-case backlog (vertical gap),
  - worst-case delay (horizontal gap),
  - drain time (intersection).
- Latency-sensitive traffic may need **priority**, not equal shares.

> [!warning] Exam traps
> - Max-min fairness is **not** equal sharing; small-demand flows may get less.
> - Round-robin by packet is unfair when packet sizes differ.
> - `F = S + p`, not `S + p/w`.
> - In WFQ, higher weight → **smaller** normalized finish time → served more often.
> - Token bucket allows bursts; basic pacing does not.
> - For multiple flows, **add the arrival curves**, not the service curves.
