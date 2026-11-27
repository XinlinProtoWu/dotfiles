# 07 — Congestion Control

> Source: `07-Congestion_Control.pdf`. Goal: how TCP infers a safe window size from ACKs and losses; Reno's AIMD, slow start, fast recovery; Mathis; CUBIC.

## 1. The problem

The network does **not** tell a sender:

- the available bandwidth,
- the RTT,
- how many other users share the bottleneck.

So a TCP sender must **infer** its congestion window (`cwnd`) from what it observes: ACKs, duplicate ACKs, losses, and timeouts.

A **congestion control algorithm (CCA)** determines the appropriate window size under these constraints.

> [!example] Practice question
> Sender link 200 Mbps, receiver link 100 Mbps, one-way delays 30 ms and 70 ms.
>
> - RTT = `30 + 70 + 30 + 70 = 200 ms`
> - Bottleneck = **100 Mbps**
> - `BDP = 100 Mbps × 0.2 s = 20 Mb = 2.5 MB`
> - With 1500-byte packets: `2.5 MB / 1500 B ≈ 1666.7 packets`
>
> Ideal window ≈ **1667 packets**.

### Why not just send as fast as possible?

- Excess packets are not always dropped — they can sit in **bottleneck queues**.
- So it is okay to “overshoot” the window a little without loss.
- But too much overshoot fills queues (delay) and eventually causes drops.

---

## 2. Queues, delays, and loss

### The lifecycle of a packet

![[07-Congestion_Control.pdf#page=23]]
*Figure: packets arrive at a switch, wait in a buffer/queue, and are transmitted. (`07-Congestion_Control.pdf` p. 23)*

- “Buffer” and “queue” are used synonymously.
- Queues absorb **transient bursts** caused by **statistical multiplexing** — many senders' bursts arriving at once.
- If the queue is full, excess packets are **dropped**.

### Four network delays

| Delay | Definition | Formula |
|---|---|---|
| **Propagation** | Time to traverse the link | distance / propagation speed |
| **Transmission** | Time to push the packet onto the link | `packet size / link bandwidth` |
| **Queueing** | Time waiting behind other packets | `bits ahead in queue / link bandwidth` |
| **RTT** | Packet to destination + response back | sum of path delays and queueing |

![[07-Congestion_Control.pdf#page=24]]
*Figure: queueing delay and transmission delay at a switch. (`07-Congestion_Control.pdf` p. 24)*

### When does queueing delay appear?

![[07-Congestion_Control.pdf#page=27]]
*Figure: bursty/simultaneous arrivals create queueing delay even when the link is underutilized. (`07-Congestion_Control.pdf` p. 27)*

- Smooth arrivals → little or no queueing.
- Bursty arrivals, mixed packet sizes, or multiple input ports → queueing.
- Worse at high load: less idle time to absorb bursts.

> [!example] Queueing delay
> A 1500 B packet arrives behind 10 other 1500 B packets at a 10 Mbps link.
>
> ```text
> 10 × 1500 B × 8 / 10 Mbps = 120,000 bits / 10,000,000 bps = 12 ms
> ```

### Loss rate example

If packets arrive at 500 Mbps but the egress link can only serve 400 Mbps, the steady-state loss rate is `(500 − 400)/500 = 20%`.

### MTU trade-off

A smaller MTU (maximum transmission unit) makes each packet cheaper to transmit, but increases the **total** time to send a file:

- per-packet transmission delay goes **down** (smaller packet);
- total time goes **up**, because the file is split into more packets and each packet carries the same header overhead.

> Example: changing from `1400 B data + 100 B header` to `900 B data + 100 B header` reduces per-packet delay but adds ~55% more packets and header bytes for the same 10 MB file.

### BDP + queue

![[07-Congestion_Control.pdf#page=37]]
*Figure: a queue can absorb a window slightly larger than BDP without loss. (`07-Congestion_Control.pdf` p. 37)*

Using the slide's 1000 B payloads, `BDP = 2.5 MB = 2500 packets`. If the queue holds 100 more packets:

- window `2600 packets` → **no loss** (queue absorbs the extra 100 packets);
- window larger than `BDP + queue capacity` → drops.

This is why “window ≤ BDP” is a starting point, not a hard law.

> [!example] Fixed window, queue, and loss
> Link: 100 Mbps bottleneck, RTT = 200 ms, queue = 100 packets, 1500 B packets.
> `BDP = 2.5 MB ≈ 1667 packets`.
>
> | Window | Throughput | Per-packet latency | Loss |
> |---|---|---|---|
> | 1000 packets | 60 Mbps | ~100.18 ms | 0% |
> | 1700 packets | 100 Mbps | ~104.14 ms | 0% |
> | 2000 packets | 100 Mbps | ~112.06 ms | 11.4% |
>
> A window below BDP underutilizes the link; a window slightly above BDP is absorbed by the queue; a window far above `BDP + queue` overflows and loses packets.

---

## 3. Costs of congestion

![[07-Congestion_Control.pdf#page=41]]
*Figure: queueing delay grows sharply as arrival rate approaches capacity. (`07-Congestion_Control.pdf` p. 41)*

1. **Delay** — queueing delay explodes as offered load approaches capacity.
2. **Low goodput** — retransmissions are extra work for the same useful throughput; the link carries duplicate copies.
3. **Wasted resources** — if a packet is dropped downstream, all upstream transmission capacity spent on it is wasted.

![[07-Congestion_Control.pdf#page=42]]
*Figure: retransmissions consume capacity without increasing goodput. (`07-Congestion_Control.pdf` p. 42)*

---

## 4. History and the AIMD blueprint

### Congestion collapse

- Early TCP had no congestion control; sending rate was limited only by flow control.
- On a drop, senders retransmitted a full window's worth of packets → **congestion collapse**.
- October 1986: NSF network throughput fell from **32 Kbps to 40 bps**.
- **Van Jacobson** fixed it by adapting the window to congestion — no router or application changes required.

> The default taught in this course is **TCP Reno**, even though Jacobson's original was different and modern systems often use CUBIC/BBR.

### The blueprint

- **Packet lost** → slow down; loss is a signal you are sending too fast.
- **No loss for a while** → speed up; you are probably below capacity.

### Four increase/decrease policies

| Policy | On success (per RTT) | On loss |
|---|---|---|
| **AIAD** | `+1` | `−1` |
| **MIAD** | `×2` | `−1` |
| **AIMD** | `+1` | `×0.5` |
| **MIMD** | `×2` | `×0.5` |

**TCP uses AIMD**:

- Be **cautious** when consuming new bandwidth (additive increase).
- Be **aggressive** when backing off (multiplicative decrease).
- AIMD converges to a fair, efficient share between equal-RTT flows.

---

## 5. TCP Reno mechanics

### Sending window

```text
sending window = min(cwnd, advertised window)
```

- `cwnd` is the congestion window TCP is probing for.
- `advertised window` protects the receiver (flow control).

### Three stages

| Stage | Trigger | cwnd behavior |
|---|---|---|
| **Slow start** | connection start, or timeout | multiplicative increase: `+1 MSS per ACK` → **doubles per RTT** |
| **Congestion avoidance** | `cwnd ≥ ssthresh` | additive increase: `+1 MSS per RTT` |
| **Fast recovery** | 3 duplicate ACKs | retransmit missing packet, halve window, then return to CA |

- Initial `cwnd = 4 MSS` (in the slides).
- `ssthresh` (slow-start threshold) starts large.
- “Slow start” is **fast** — the name is historical; it was slower than starting with an enormous window.

> [!note] Congestion avoidance in practice
> `+1 MSS per RTT` is often implemented as `cwnd += MSS²/cwnd` per ACK, which accumulates to about one MSS per RTT.

### Duplicate ACKs

![[07-Congestion_Control.pdf#page=60]]
*Figure: duplicate ACKs signal a missing segment before the timer fires. (`07-Congestion_Control.pdf` p. 60)*

- TCP uses **cumulative ACKs**.
- If packets with sequence numbers `1000, 2000, 4000, 5000, 6000...` arrive, the receiver keeps ACKing **3000**.
- Three **duplicate ACKs** for the same sequence number strongly suggest one packet was lost.

> [!important] 3 duplicate ACKs → **fast retransmit** the missing segment immediately, without waiting for a timeout.

### Timeout vs duplicate ACKs

| Signal | Interpretation | Reaction |
|---|---|---|
| **3 duplicate ACKs** | Single “easy” loss; later packets arrived | Fast retransmit + **fast recovery**; halve window |
| **Timeout** | Possibly many packets lost; severe overshoot | Set `ssthresh = cwnd/2`, drop to slow start |

![[07-Congestion_Control.pdf#page=56]]
*Figure: TCP sawtooth — exponential slow start, then linear growth, then a loss. (`07-Congestion_Control.pdf` p. 56)*

![[07-Congestion_Control.pdf#page=61]]
*Figure: duplicate-ACK loss produces the classic sawtooth. (`07-Congestion_Control.pdf` p. 61)*

![[07-Congestion_Control.pdf#page=63]]
*Figure: timeout losses cut all the way back to slow start. (`07-Congestion_Control.pdf` p. 63)*

### Fast recovery (classic Reno)

On the 3rd duplicate ACK:

```text
ssthresh = max(cwnd / 2, 2·MSS)
retransmit the missing segment
cwnd = ssthresh + 3·MSS          # “inflate” for the 3 packets that left the network
```

For each additional duplicate ACK: `cwnd += MSS`.

When the retransmission is ACKed:

```text
cwnd = ssthresh                   # “deflate”
enter congestion avoidance
```

> CP3 note: the lecture state machine only requires the **state transitions**; the exact cwnd inflation/deflation above is standard Reno behavior.

### Reno state machine (for CP3)

![[07-Congestion_Control.pdf#page=64]]
*Figure: Reno state machine — slow start ↔ congestion avoidance ↔ fast recovery. (`07-Congestion_Control.pdf` p. 64)*

```text
slow start:
  new ACK        → cwnd doubles (stay in slow start)
  cwnd > ssthresh→ congestion avoidance
  dupACK = 3     → fast recovery
  timeout        → slow start

congestion avoidance:
  new ACK        → cwnd += 1 MSS per RTT
  dupACK = 3     → fast recovery
  timeout        → slow start

fast recovery:
  dupACK         → stay (inflate cwnd)
  new ACK        → congestion avoidance
  timeout        → slow start
```

---

## 6. Fairness and convergence (Chiu & Jain, 1989)

A good CCA should have four properties:

| Property | Meaning |
|---|---|
| **Efficiency** | Uses the available bandwidth |
| **Fairness** | Equal share among competing flows |
| **Convergence** | Settles to an equal, efficient allocation without oscillating |
| **Distributedness** | Works end-to-end without network cooperation |

![[07-Congestion_Control.pdf#page=69]]
*Figure: fairness line, efficiency line, and optimal point. (`07-Congestion_Control.pdf` p. 69)*

- **Fairness line**: `x₁ = x₂`.
- **Efficiency line**: `x₁ + x₂ = C`.
- **Optimal point**: intersection — fair and fully utilized.

| Policy | Converges? | Why |
|---|---|---|
| **MIMD** | No | Multiplicative up and down overshoots; oscillates |
| **AIAD** | No | Additive up and down moves along a line; never reaches fairness |
| **AIMD** | **Yes** | Additive up + multiplicative down converges to the fair share |

![[07-Congestion_Control.pdf#page=71]]
*Figure: MIMD oscillates and never converges. (`07-Congestion_Control.pdf` p. 71)*

![[07-Congestion_Control.pdf#page=72]]
*Figure: AIAD oscillates around a non-fair allocation. (`07-Congestion_Control.pdf` p. 72)*

![[07-Congestion_Control.pdf#page=74]]
*Figure: AIMD converges to the optimal point — Chiu & Jain's proof. (`07-Congestion_Control.pdf` p. 74)*

> AIMD fairness assumes flows have the **same RTT**. Different RTTs break fairness — see [[08_Advanced_Congestion_Control]].

---

## 7. Throughput: Mathis and the high-bandwidth problem

### Mathis equation (1998)

```text
BW < (MSS / RTT) × (1 / √p)
```

where `p` is the packet loss probability.

- More loss or longer RTT → lower throughput.
- This bound assumes Reno-like AIMD and steady-state losses.

> [!example] Plugging in numbers
> `MSS = 1500 B = 12,000 bits`, `RTT = 100 ms`, `p = 10⁻⁸`:
>
> ```text
> BW < (12,000 / 0.1) × 1/√(10⁻⁸)
>    = 120,000 × 10,000
>    = 1.2 Gbps
> ```

### Average TCP throughput

Ignoring slow start, if the window at loss is `W`, the average in-flight window is `3W/4`:

```text
average throughput ≈ (3W/4) / RTT
```

![[07-Congestion_Control.pdf#page=77]]
*Figure: window sawtooth between W and W/2; average is 3W/4. (`07-Congestion_Control.pdf` p. 77)*

### Reno's high-bandwidth problem

![[07-Congestion_Control.pdf#page=83]]
*Figure: after a loss, Reno's `+1 per RTT` takes ~1.4 hours to refill a 10 Gbps pipe. (`07-Congestion_Control.pdf` p. 83)*

Example: 1500 B segments, 100 ms RTT, target 10 Gbps.

```text
W = 10 Gbps × 0.1 s / (1500 × 8 bits) ≈ 83,333 packets
```

- The slides illustrate the drop as `100,000 → 50,000`; refilling at `+1 per RTT` needs `50,000 RTT × 0.1 s = 5,000 s ≈ 1.4 hours`. (Using `W ≈ 83,333` gives the same order of magnitude.)
- Required loss probability from Mathis:

```text
p < (MSS / (RTT × BW))²
  = (12,000 / (0.1 × 10¹⁰))²
  ≈ 1.44 × 10⁻¹⁰
```

That is an extremely low loss rate — impractical on real high-speed links.

---

## 8. CUBIC (modern default)

CUBIC keeps Reno's loss-based approach but replaces linear growth with a **cubic** function.

```text
W_cubic(t) = C·(t − K)³ + W_max
K = ∛(W_max·β / C)
```

- `W_max` = cwnd before the last loss.
- `t` = time since the last window reduction.
- `C` = scaling factor.
- `β` = multiplicative decrease factor (as written in the lecture).

### Behavior

![[07-Congestion_Control.pdf#page=85]]
*Figure: CUBIC growth — accelerate toward W_max, slow down near it, then probe beyond. (`07-Congestion_Control.pdf` p. 85)*

- After a loss, CUBIC quickly accelerates back toward `W_max`.
- It slows down as it approaches `W_max` (concave-down region).
- Then it probes gently beyond `W_max`.
- On loss, CUBIC reduces the window by **~20%** (not 50%).
- If its estimate of `W_max` shrinks, it reduces by **~40%** to protect fairness.

![[07-Congestion_Control.pdf#page=87]]
*Figure: CUBIC reduces cwnd by 20% on loss. (`07-Congestion_Control.pdf` p. 87)*

![[07-Congestion_Control.pdf#page=89]]
*Figure: after a loss, CUBIC's window growth is cubic. (`07-Congestion_Control.pdf` p. 89)*

### Reno vs CUBIC

| | **Reno** | **CUBIC** |
|---|---|---|
| Growth | linear `+1/RTT` | cubic |
| Loss reduction | 50% | ~20% (40% in fairness case) |
| Large BDP | too slow | much faster recovery |
| Default | classic teaching | Linux, macOS |

---

## 9. Exam traps

- **Slow start** = multiplicative increase (doubling per RTT), not `+1`.
- **Congestion avoidance** = `+1 MSS per RTT`, not per ACK unless scaled.
- **3 duplicate ACKs** → fast recovery; **timeout** → slow start.
- `cwnd` is **congestion** control; `advertised window` is **flow** control.
- `ssthresh` is halved on loss (timeout or dup ACK).
- BDP uses **RTT** for window sizing; don't plug in one-way delay by mistake.
- Mathis: `p` is loss probability, so `1/√p` grows as loss shrinks.
- CUBIC cuts less than Reno, so it recovers faster; the extra 40% cut when `W_max` shrinks is there to protect fairness against Reno flows.
