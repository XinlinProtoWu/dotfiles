# 05 — Transport Model

> Source: `05-Transport Model.pdf`. Goal: why the transport layer exists, what UDP and TCP promise, and how retransmission/windowing provide reliability.

## 1. Where the transport layer sits

![[05-Transport Model.pdf#page=6]]
*Figure: transport layer in the Internet layering model. (`05-Transport Model.pdf` p. 6)*

```text
Application    Application
Transport      Transport
Network        Network        Network
Datalink       Datalink       Datalink
Physical       Physical       Physical
```

- The **network layer** provides **host-to-host** delivery.
- Applications need **process-to-process** delivery.
- The **transport layer** bridges that gap.

### Two jobs of the transport layer

1. **Multiplexing / demultiplexing** — decide which packets belong to which application process, using **ports**.
   - Ports are just numbers, not physical devices.
2. **Optional end-to-end services** over bare-bones IP:
   - reliable, in-order delivery;
   - well-paced delivery (too fast overwhelms the network, too slow is inefficient).

The network is **best-effort**: packets can be corrupted, delayed, dropped, reordered, or duplicated. Every application shouldn't have to reimplement recovery, so the transport layer provides it as a common service.

### Sockets

A **socket** is the software abstraction through which an application process exchanges messages with the transport layer in the OS.

```text
socketID = socket(..., SOCK_DGRAM)      # UDP
socketID.sendto(message, ...)
socketID.recvfrom(...)

socketID = socket(..., SOCK_STREAM)     # TCP
```

---

## 2. Service models: UDP vs TCP

| Property | **UDP** | **TCP** |
|---|---|---|
| Connection | Connectionless | Connection-oriented |
| Reliability | Unreliable | Reliable, in-order |
| Data abstraction | Datagrams / messages | **Byte stream** |
| Congestion control | No | Yes |
| Flow control | No | Yes |
| Header size | 8 bytes | ≥ 20 bytes |
| Checksum | Optional | Mandatory |
| Typical users | DNS, DHCP, VoIP, video chat, QUIC | HTTP, email, file transfer |

Neither guarantees a particular **delay** or **bandwidth**.

Other transport protocols exist (SCTP, DCCP, etc.), but TCP and UDP are the common ones.

---

## 3. UDP — the minimalist protocol

![[05-Transport Model.pdf#page=17]]
*Figure: UDP header — source port, destination port, checksum, length, then data. (`05-Transport Model.pdf` p. 17)*

```text
+-------------+-------------+
| SRC port    | DST port    |
+-------------+-------------+
| checksum    | length      |
+-------------+-------------+
|          DATA             |
+---------------------------+
```

- Provides **mux/demux only** (RFC 768, 1980).
- **Checksum**: a small datum derived from the data to detect errors.
  - Simplest form: XOR all 32-bit words; receiver recomputes and compares.
  - `checksum = 0` means “don't verify the checksum.”
- If a packet is lost, the **application** decides what to do. UDP does not retransmit.
- Good for:
  - DNS, DHCP;
  - real-time applications (VoIP, video chat): retransmission is pointless after the moment passes;
  - applications that want to build everything themselves (QUIC).

---

## 4. Reliability: retransmission

There are two ways to detect a lost packet:

1. **Timeout** — the packet was sent long ago but no ACK has arrived.
2. **Corruption** — the data doesn't match its checksum (treated as lost).

### Stop-and-wait (baseline)

![[05-Transport Model.pdf#page=25]]
*Figure: stop-and-wait — one packet in flight at a time. (`05-Transport Model.pdf` p. 25)*

**Sender**

- Transmit one packet, labeled with a **sequence number**.
- Set a timer.
- If ACK received → send the next packet.
- If timer fires → retransmit the previous packet.

**Receiver**

- On a correctly received packet → send ACK.
- If the packet is corrupted → ignore it; the sender will eventually retransmit.

![[05-Transport Model.pdf#page=30]]
*Figure: stop-and-wait timeout and retransmission. (`05-Transport Model.pdf` p. 30)*

**Problem:** slow — only **one packet in flight** at a time. The link sits idle while waiting for each ACK.

### Why sequence numbers?

- To **reassemble** the original data in order after packetization.
- To **distinguish** a retransmission from a new packet, and detect duplicates.
- Without sequence numbers, a delayed duplicate packet is ambiguous:

![[05-Transport Model.pdf#page=36]]
*Figure: without sequence numbers, the receiver cannot tell whether a packet is new, a duplicate, or an old retransmission. (`05-Transport Model.pdf` p. 36)*

> **Sequence numbers are required for reliability.**

---

## 5. Sliding windows

![[05-Transport Model.pdf#page=43]]
*Figure: sliding window — packets transmitted but not yet ACKed. (`05-Transport Model.pdf` p. 43)*

- A sender's **window** = the set of packets that have been transmitted but not yet ACKed.
- Pipelining multiple packets keeps the link busy and improves efficiency.
- The window **slides forward** as ACKs arrive.
- Two design questions:
  1. How do we handle loss with many packets in flight?
  2. How big should the window be?

### Go-Back-N (GBN)

![[05-Transport Model.pdf#page=51]]
*Figure: Go-Back-N sender and receiver behavior. (`05-Transport Model.pdf` p. 51)*

| Role | Behavior |
|---|---|
| **Sender** | Send up to `N` packets; set a timeout timer for every packet. On ACK, slide the window. On timeout, retransmit the timed-out packet **and every packet after it** in the window. |
| **Receiver** | Only accepts the **next expected** sequence number. Discards out-of-order or corrupted packets. |

- Simple, but wastes bandwidth: it retransmits packets that were already received correctly.

### Selective Repeat (SR)

![[05-Transport Model.pdf#page=56]]
*Figure: selective repeat — receiver buffers out-of-order packets and ACKs each one. (`05-Transport Model.pdf` p. 56)*

| Role | Behavior |
|---|---|
| **Sender** | Send packets in the window; set a timeout per packet. On ACKs for the left edge, slide forward and send newly entered packets. On timeout, retransmit **only** the timed-out packet. |
| **Receiver** | Keep a buffer of size = window. ACK **every** packet. Out-of-order packets are stored in the buffer and ACKed anyway. |

- More efficient than GBN: only the missing packet is retransmitted.

### Receive buffer and in-order delivery

![[05-Transport Model.pdf#page=79]]
*Figure: out-of-order data sits in the receive buffer, but the application cannot read past the missing packet. (`05-Transport Model.pdf` p. 79)*

- Out-of-order packets are stored in the **receive buffer**.
- The application **cannot read past a missing packet** until it arrives — the transport still provides **in-order** delivery.
- This is why a single lost TCP packet can stall all later data at the application, even if that later data is already buffered.

### GBN vs SR summary

| | **Go-Back-N** | **Selective Repeat** |
|---|---|---|
| Receiver out-of-order | discard | buffer + ACK |
| Sender timeout | resend packet + all later | resend only that packet |
| Efficiency | lower | higher |
| Complexity | simpler | more state at receiver/sender |

---

## 6. What TCP actually does

> **TCP = Selective Repeat + cumulative ACKs + per-byte sequence numbers + fast recovery.**

### Cumulative ACKs

| ACK style | Meaning |
|---|---|
| **Basic ACK** | “ACK n” = “I just received packet n.” Precise, but an ACK loss is not automatically recovered. |
| **Cumulative ACK** | “ACK n” = “I have received everything up to n−1; I am expecting n.” A later ACK implicitly covers earlier ones. |

![[05-Transport Model.pdf#page=83]]
*Figure: cumulative ACK — receiver keeps ACKing the next expected byte when later packets arrive out of order. (`05-Transport Model.pdf` p. 83)*

![[05-Transport Model.pdf#page=84]]
*Figure: cumulative ACKs recover easily from a lost ACK. (`05-Transport Model.pdf` p. 84)*

- Cumulative ACKs are robust to **ACK loss**: if “ACK 3” is lost but “ACK 4” arrives, the sender knows everything up to 4 was received.
- But cumulative ACKs are **blind to out-of-order arrivals**: they cannot tell the sender what arrived past a hole.
- TCP uses **per-byte** sequence numbers (not per-packet). See [[06_TCP_Basics]].

### SACK — selective ACK

**Selective ACK (SACK)** = Selective Repeat + cumulative ACK (RFC 2018, 1996).

- The receiver reports **which blocks** it has received.
- The sender retransmits **only the missing segments**.

```text
ACK 2001, SACK 3001-4000
```

This means:

- everything below byte **2001** has been received;
- bytes **3001–4000** have also been received;
- bytes **2001–3000** are missing → retransmit that block only.

Later variants: **D-SACK** (RFC 3708), **RACK** (RFC 8985).

---

## 7. Summary

- Transport provides **mux/demux** (ports) and optional **end-to-end services** over best-effort IP.
- **UDP** = mux/demux + optional checksum; no reliability, no ordering, no congestion control.
- **TCP** = reliable, in-order byte stream + flow control + congestion control.
- Reliability comes from **retransmission**:
  - stop-and-wait → simple but slow;
  - Go-Back-N → windowed but wasteful;
  - Selective Repeat → windowed + buffered, retransmits only the hole.
- TCP's twist: **cumulative ACKs**, **per-byte sequence numbers**, and **SACK** for selective recovery.

> [!warning] Common exam traps
> - TCP does **not** guarantee latency or bandwidth.
> - UDP is **not** “unreliable by accident” — it deliberately omits recovery.
> - The receive buffer may hold out-of-order data, but the **application** still cannot read past a missing byte.
> - Cumulative ACK “ACK n” means **expecting n**, not “received n.”
