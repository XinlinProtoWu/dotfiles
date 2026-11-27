# 08 — Advanced Congestion Control

> Source: `08-AdvancedCC.pdf`. Goal: why Reno is not enough in modern networks, how to measure fairness, and what alternatives exist.

## 1. Quick recap (see [[07_Congestion_Control]])

Reno = **AIMD** + three stages:

1. **Slow start** — double `cwnd` per RTT until `ssthresh`.
2. **Congestion avoidance** — `+1 MSS per RTT`.
3. **Fast recovery** — after 3 duplicate ACKs; halve `cwnd`.

Reno assumes:

- loss is the only congestion signal,
- the BDP is “small enough,”
- all flows have similar RTTs.

Each assumption breaks in modern networks.

---

## 2. Why Reno struggles

![[08-AdvancedCC.pdf#page=36]]
*Figure: Reno's implicit assumptions hurt performance in modern networks. (`08-AdvancedCC.pdf` p. 36)*

| Assumption | Why it hurts |
|---|---|
| **Loss = congestion** | Wi-Fi and high-speed links have random loss; Reno backs off unnecessarily |
| **Additive growth is fast enough** | On large-BDP links, `+1 MSS/RTT` takes far too long to refill the pipe |
| **RTT is similar across flows** | Reno's update speed is proportional to RTT → low-RTT flows dominate |
| **Filling queues is fine** | Persistent queues create large delay (bufferbloat), bad for gaming, Web, calls |

### RTT unfairness

![[08-AdvancedCC.pdf#page=46]]
*Figure: two Reno flows with different RTTs sharing a link. (`08-AdvancedCC.pdf` p. 46)*

Mathis says throughput is proportional to `1/RTT`:

```text
throughput ≈ (1/√p) × (MSS/RTT)
```

For two flows with the same MSS and loss rate:

```text
Flow A (50 ms): throughput ∝ 1/50
Flow B (10 ms): throughput ∝ 1/10
```

Flow B's share:

```text
(1/10) / (1/50 + 1/10)
= (5/50) / (6/50)
= 5/6
```

![[08-AdvancedCC.pdf#page=49]]
*Figure: the 50 ms flow gets only 1/6 of the link; the 10 ms flow gets 5/6. (`08-AdvancedCC.pdf` p. 49)*

- The unfairness is purely from RTT, not from bad behavior.
- With a 100:1 RTT ratio, the long-RTT flow can be **starved**.

---

## 3. Jain's fairness index

![[08-AdvancedCC.pdf#page=41]]
*Figure: Jain's fairness index definition. (`08-AdvancedCC.pdf` p. 41)*

```text
F(x) = (Σ xᵢ)² / (n · Σ xᵢ²)
```

- `F = 1` → perfectly fair (all equal).
- `F → 0` → very unfair.
- `n` = number of flows, `xᵢ` = allocation to flow `i`.

> [!example] Two flows
> - Equal: `x = (50, 50)` → `F = (100)² / (2·(50² + 50²)) = 1`.
> - Unequal: `x = (80, 20)` → `F = (100)² / (2·(80² + 20²)) = 10,000/13,600 ≈ 0.74`.

Jain's index is a **measurement**, not a guarantee. Reno does **not** guarantee fairness:

- different RTTs → RTT unfairness;
- different algorithms → mixed behavior;
- some applications need **priority**, not equality.

---

## 4. Alternatives to Reno

![[08-AdvancedCC.pdf#page=38]]
*Figure: the “alphabet soup” of congestion control alternatives. (`08-AdvancedCC.pdf` p. 38)*

| Problem | Algorithms / mechanisms |
|---|---|
| High-speed / large BDP | **CUBIC**, CompoundTCP, HighSpeed TCP |
| Queue filling / latency | **BBR**, Copa |
| Network-assisted / AQM (datacenters) | RED, RCP, XCP, DCTCP, TIMELY |
| ML-based (research) | PCC, Remy |

- **CUBIC** (Linux/macOS default): cubic window growth; recovers quickly after loss; cuts ~20% instead of 50%. See [[07_Congestion_Control]].
- **BBR** (Google): models the bottleneck bandwidth and minimum RTT directly instead of treating loss as the only signal. Tries to avoid filling queues.
- **AQM** (Active Queue Management): routers signal congestion **before** the queue is completely full, e.g. by marking or dropping packets early.

> [!note] Why not just use one algorithm?
> No single end-host algorithm solves bandwidth allocation, fairness, latency, and priorities simultaneously. Different networks and applications need different trade-offs.

---

## 5. Fairness is not always the goal

![[08-AdvancedCC.pdf#page=52]]
*Figure: a robotic-surgery flow should not get the same share as a game download. (`08-AdvancedCC.pdf` p. 52)*

- “Fair” means equal shares, but equal is not always **right**.
- Real systems may want:
  - **priority** for latency-sensitive traffic (surgery, calls, gaming);
  - **weighted** shares for different customers/plans;
  - **caps** per user.
- End-host congestion control alone cannot enforce these; we need **in-network** mechanisms.

---

## 6. Bottom line

- Reno is simple and was crucial historically, but its assumptions fail on:
  - high-bandwidth links,
  - wireless/random-loss links,
  - mixed-RTT paths,
  - latency-sensitive applications.
- **Fairness** needs to be measured (Jain) and sometimes enforced (fair queueing, token buckets).
- Don't rely on end-host CC alone for bandwidth allocation — the next lecture covers in-network mechanisms.
