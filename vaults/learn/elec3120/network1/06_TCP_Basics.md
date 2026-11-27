# 06 — TCP Basics

> Source: `06-TCP_Basics.pdf`. Goal: TCP's reliability mechanics, header, connection lifecycle, RTT/timeout estimation, and window sizing.

## 1. Reliability recap

TCP builds on the retransmission ideas from [[05_Transport_Model]]:

| Approach | Sender on loss | Receiver on out-of-order | Efficiency |
|---|---|---|---|
| **Stop-and-wait** | resend the one packet | ignore | very low (1 in flight) |
| **Go-Back-N** | resend timed-out packet + all later | discard | medium (wasteful) |
| **Selective Repeat** | resend only timed-out packet | buffer + ACK each | high |

> **TCP ≈ Selective Repeat + cumulative ACKs + per-byte sequence numbers + fast recovery.**

---

## 2. RTT estimation and timeout

TCP must choose a retransmission timeout. It should be **longer than the RTT**, but RTT varies.

- Too short → premature timeouts, unnecessary retransmissions.
- Too long → slow reaction to real loss.

### Measuring RTT

- `SampleRTT` = time from segment transmission until ACK receipt.
- **Ignore retransmissions** when measuring (the ACK may belong to the original or the retransmission — ambiguous).
- Smooth noisy samples with an **exponential weighted moving average (EWMA)**.

```text
EstimatedRTT = (1 − α)·EstimatedRTT + α·SampleRTT        α = 0.125
DevRTT       = (1 − β)·DevRTT + β·|SampleRTT − EstimatedRTT|   β = 0.25
TimeoutInterval = EstimatedRTT + 4·DevRTT
```

- Older samples decay exponentially.
- `4·DevRTT` is the **safety margin**: more RTT variance → larger margin.

> [!example] One update step
> Suppose `EstimatedRTT = 100 ms`, `DevRTT = 0`, and a new `SampleRTT = 120 ms`.
>
> ```text
> EstimatedRTT = 0.875(100) + 0.125(120) = 102.5 ms
> DevRTT       = 0.75(0) + 0.25|120 − 100| = 5 ms
> Timeout      = 102.5 + 4(5) = 122.5 ms
> ```

---

## 3. What TCP is: ACK styles

### Basic vs cumulative ACK

| Style | “ACK n” means | Strength |
|---|---|---|
| **Basic** | “I just received packet n” | precise per-packet feedback |
| **Cumulative** | “I received everything below n; I expect n” | survives ACK loss, less ACK traffic |

- TCP uses **cumulative ACKs**.
- Cumulative ACKs are robust to **ACK loss**: a later ACK implicitly covers earlier ones.
- But they are blind to out-of-order arrivals.

### SACK

**Selective ACK** adds selective reporting on top of cumulative ACKs (RFC 2018):

```text
ACK 2001, SACK 3001-4000
```

→ bytes below 2001 received, bytes 3001–4000 received, **2001–3000 missing** → retransmit only 2001–3000.

Later variants: **D-SACK** (RFC 3708), **RACK** (RFC 8985).

---

## 4. TCP header and segments

![[06-TCP_Basics.pdf#page=23]]
*Figure: TCP header layout. (`06-TCP_Basics.pdf` p. 23)*

```text
+----------------+----------------+
| Source port    | Destination port|   ← mux/demux
+----------------+----------------+
| Sequence number                  |   ← first byte of this segment
+----------------------------------+
| Acknowledgment                   |   ← next expected byte (cumulative)
+----+-------+---------------------+
|HdrLen| Flags | Advertised window |   ← receiver's free buffer
+----------------+----------------+
| Checksum       | Urgent pointer  |
+----------------+----------------+
| Options (variable)              |
+----------------------------------+
| Data                             |
+----------------------------------+
```

- Header ≥ **20 bytes**.
- `HdrLen` is in 32-bit words: `HdrLen = 5` → `5 × 4 = 20 bytes`.
- Data ≤ **MSS** (Maximum Segment Size), e.g. **1460 bytes**.
- Flags: `SYN ACK FIN RST PSH URG CWR ECE` (see table below).

### TCP flags

| Flag | Full name | Meaning |
|---|---|---|
| **SYN** | Synchronize | Start a connection; synchronize sequence numbers |
| **ACK** | Acknowledgment | The Acknowledgment field is valid |
| **FIN** | Finish | Gracefully close this side (no more data) |
| **RST** | Reset | Abruptly abort the connection |
| **PSH** | Push | Deliver data to the application immediately |
| **URG** | Urgent | The Urgent Pointer field is valid |
| **CWR** | Congestion Window Reduced | ECN: “I reduced my congestion window” |
| **ECE** | ECN-Echo | ECN: “I saw congestion” |

- **SYN** and **FIN** each occupy **one byte** in sequence space.
- **PSH** skips buffering for interactive apps (e.g. telnet).
- **URG** is rarely used today.
- **CWR/ECE** are for Explicit Congestion Notification.

### Stream of bytes → segments

![[06-TCP_Basics.pdf#page=25]]
*Figure: the application writes a byte stream; TCP chops it into segments. (`06-TCP_Basics.pdf` p. 25)*

- The application sees a **byte stream**, not messages.
- A segment is sent when:
  1. it is **full** (reaches MSS), or
  2. it is not full but a **timer fires**.

### Per-byte sequence numbers

![[06-TCP_Basics.pdf#page=27]]
*Figure: sequence number = ISN + byte offset of the first byte in the segment. (`06-TCP_Basics.pdf` p. 27)*

```text
sequence number = ISN + k        (k = byte offset of first byte in this segment)
ACK number      = seqno + length(data)   = next expected byte
```

Example: packet #1 carries 1000 bytes starting at `ISN`.
→ packet #2's sequence number is `ISN + 1000`.

If packet #1 starts at `ISN = 1`, it covers bytes 1–1000, and the receiver ACKs **1001**.

---

## 5. Connection establishment: 3-way handshake

### Initial Sequence Number (ISN)

- The sequence number of the very first byte.
- Why not always `ISN = 0`?
  - IP addresses + ports identify a connection, but ports get **reused**.
  - An old packet from a previous connection may still be in flight.
  - A fixed ISN could make that old packet look valid.
- So each side picks a **fresh ISN** and tells the other during the handshake.

### The handshake

![[06-TCP_Basics.pdf#page=33]]
*Figure: three-way handshake — SYN, SYN-ACK, ACK. (`06-TCP_Basics.pdf` p. 33)*

```text
A → B:  SYN,     seq = ISN_A
B → A:  SYN-ACK, seq = ISN_B, ACK = ISN_A + 1
A → B:  ACK,     seq = ISN_A + 1, ACK = ISN_B + 1
```

![[06-TCP_Basics.pdf#page=38]]
*Figure: timing diagram of the 3-way handshake. (`06-TCP_Basics.pdf` p. 38)*

> [!note] Reading the handshake
> - **SYN** means “I am able to send.”
> - **ACK** means “I am able to receive.”
> - **SYN-ACK** combines both.
> - `seq = ISN` means “I will start sending from here.”
> - `ACK = ISN + 1` means “I expect your next byte here.”
> - The `+1` exists because **SYN occupies one byte** of sequence space.

- After step 2 (SYN-ACK), **A may start sending data**.
- After step 3 (ACK), **B may start sending data**.

### If the SYN is lost

![[06-TCP_Basics.pdf#page=39]]
*Figure: SYN loss — retransmit after a timeout. (`06-TCP_Basics.pdf` p. 39)*

- No SYN-ACK arrives → timer fires → retransmit SYN.
- Default timeout: **3 seconds** (RFC 1122/2988); some implementations use **6 seconds**.
- A user clicking “reload” aborts the connect and starts a new one, effectively forcing a faster SYN.

---

## 6. Connection teardown

### Graceful close (FIN)

![[06-TCP_Basics.pdf#page=42]]
*Figure: normal termination, one side at a time. (`06-TCP_Basics.pdf` p. 42)*

- `FIN` means “I have no more data to send.”
- **FIN occupies one byte** in sequence space; the peer ACKs that byte.
- Each side closes independently → the connection is **half-closed** until both send FIN.
- After both FINs are ACKed, the connection is closed.

![[06-TCP_Basics.pdf#page=43]]
*Figure: both sides send FIN; TIME_WAIT handles lost final ACKs and old duplicate packets. (`06-TCP_Basics.pdf` p. 43)*

**TIME_WAIT** reasons:

1. **Avoid reincarnation**: an old delayed packet from this connection isn't mistaken for a new connection using the same ports.
2. **Retransmit the final FIN ACK** if it is lost.

(Standard TCP waits `2 × MSL`, the maximum segment lifetime.)

### Abrupt close (RST)

![[06-TCP_Basics.pdf#page=44]]
*Figure: abrupt termination with RST. (`06-TCP_Basics.pdf` p. 44)*

- `RST` aborts the connection (e.g. the application crashed).
- The peer does **not** ACK the RST → RST is **not reliable**.
- In-flight data is lost.
- If the peer sends anything later, it elicits another RST.

---

## 7. TCP state transitions

![[06-TCP_Basics.pdf#page=46]]
*Figure: TCP state transition diagram. (`06-TCP_Basics.pdf` p. 46)*

Key states:

| State | Meaning |
|---|---|
| `CLOSED` | No connection |
| `LISTEN` | Server waiting for a SYN |
| `SYN_SENT` | Client sent SYN, waiting for SYN-ACK |
| `SYN_RCVD` | Server received SYN, sent SYN-ACK |
| `ESTABLISHED` | Connection open; data can flow |
| `FIN_WAIT_1` | Sent FIN, waiting for ACK |
| `FIN_WAIT_2` | FIN ACKed, waiting for peer's FIN |
| `CLOSE_WAIT` | Peer sent FIN; local app hasn't closed yet |
| `LAST_ACK` | Sent own FIN after CLOSE_WAIT |
| `TIME_WAIT` | Both sides closed; waiting before reuse |
| `CLOSING` | Both sides sent FIN simultaneously |

> `ESTABLISHED` is the only state where normal data transfer happens.

---

## 8. How big should the window be?

Two independent limits:

### Limit 1 — Flow control (protect the receiver)

![[06-TCP_Basics.pdf#page=62]]
*Figure: advertised window prevents overflowing the receiver's buffer. (`06-TCP_Basics.pdf` p. 62)*

- The receiver has a finite **receive buffer**.
- If the application reads slowly, extra segments are dropped.
- The receiver advertises a window `W` in its ACKs.
- The sender keeps **bytes in flight ≤ W**.

```text
Window ≤ Advertised Window
```

Example: “I only have 10 KB left in my buffer” → advertise 10 KB.

### Limit 2 — Congestion control (protect the network)

- Even with a huge receiver window, a **bottleneck link** drops packets when arrival rate > departure rate.
- The network's capacity is captured by the **bandwidth-delay product (BDP)**.

```text
BDP = bandwidth × RTT
```

![[06-TCP_Basics.pdf#page=76]]
*Figure: pipe model — BDP is the “volume” of the link, the data that can be in flight. (`06-TCP_Basics.pdf` p. 76)*

Example: 50 Mbps × 200 ms = **1.25 MB**.

> Some slides define BDP with **one-way propagation delay**; for window sizing TCP uses the **round-trip** volume because ACKs must return.

### Putting it together

```text
Sending window = min(cwnd, advertised window)
Window ≤ Advertised Window   → Flow Control
Window ≤ BDP (+ small queue) → Congestion Control
```

### ACK clocking

![[06-TCP_Basics.pdf#page=77]]
*Figure: with window = BDP, returning ACKs pace new transmissions. (`06-TCP_Basics.pdf` p. 77)*

- Set the window to BDP and ACKs return at exactly the right rate to keep transmitting.
- This self-clocking loop is called **ACK clocking**.
- It keeps the pipe full without overflowing the network.

---

## 9. Summary

- **Reliability** = retransmission: stop-and-wait → GBN → selective repeat.
- **TCP** = SR + cumulative ACK + per-byte sequence numbers (+ SACK, fast recovery).
- **RTT estimate**: EWMA + deviation safety margin; `Timeout = EstimatedRTT + 4·DevRTT`.
- **Open**: SYN / SYN-ACK / ACK; random ISNs avoid old-packet confusion.
- **Close**: FIN (graceful, half-close, TIME_WAIT) or RST (abrupt, unreliable).
- **Window size** is limited by the receiver (`advertised window`) and the network (`BDP`/`cwnd`).
