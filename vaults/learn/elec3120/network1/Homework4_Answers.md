# Homework 4 - Complete Answers

> Matching the lecture notes on the Internet model (lecture 12), IP/BGP (lectures 10-11), and the end-to-end / fate-sharing ideas.

---

## Q1 - Multiple choice

### Q1.1 - The following is *not* true about wireless networks

**Answer: "A sender can always detect a collision by using Carrier Sense."**

The other three are true: wireless links have higher loss than wired; RTS/CTS reduces but does not eliminate collisions; same-frequency radios interfere. Carrier sense cannot detect every collision because of the hidden-terminal problem, so this statement is false.

### Q1.2 - Routing algorithm relying on a "global view" of connectivity

**Answer: Link State.**

Each link-state router floods its advertisements so every router builds a complete topology map (the global view), then runs Dijkstra.

### Q1.3 - Turning "bits into packets" is the job of which layer

**Answer: The Link Layer (Data Link layer).**

The data link layer turns bits into frames, labels senders/receivers, and handles medium access and error detection.

### Q1.4 - Network-layer router receiving an IP packet over Ethernet

**Answer: "The router strips off the Ethernet header, reads the IP address to determine the next hop, and then adds a new Ethernet header."**

Routers forward on the destination IP address, not the MAC. The IP header is preserved; only the Ethernet header is rewritten at each hop.

---

## Q2 - SCLSP / SCDVP routing on prefix 173.0.0.0/8

First, the topology read from the link-state table (every link has cost 1):

```
routers (nodes):
  173.192.0.1   (self, the router we log into in Q2.1/Q2.3/Q2.4)
  173.192.2.1
  173.0.0.1     (the router we log into in Q2.2)
  173.4.0.1
  173.5.0.1

router-router links:
  173.192.0.1 -- 173.0.0.1        (173.192.0.1 uses port 1)
  173.192.0.1 -- 173.192.2.1      (173.192.0.1 uses port 4)
  173.0.0.1   -- 173.4.0.1
  173.0.0.1   -- 173.5.0.1

end hosts (attached to exactly one router, never listed as "nodes"):
  on 173.192.0.1 : 173.192.3.5 (port 2), 173.192.3.4 (port 3)
  on 173.192.2.1 : 173.192.2.16, 173.192.2.15
  on 173.0.0.1   : 173.3.2.196
  on 173.4.0.1   : 173.4.63.12, 173.4.63.13, 173.4.63.14
  on 173.5.0.1   : 173.5.19.73, 173.5.21.12, 173.5.21.18
```

So there are 16 distinct destinations (5 routers + 11 hosts).

### Q2.1 - Link State routing table at 173.192.0.1

Run Dijkstra from 173.192.0.1 (all costs 1):

| Destination | Next Hop | Port |
|---|---|---|
| 173.0.0.1 | 173.0.0.1 | 1 |
| 173.3.2.196 | 173.0.0.1 | 1 |
| 173.4.0.1 | 173.0.0.1 | 1 |
| 173.4.63.12 | 173.0.0.1 | 1 |
| 173.4.63.13 | 173.0.0.1 | 1 |
| 173.4.63.14 | 173.0.0.1 | 1 |
| 173.5.0.1 | 173.0.0.1 | 1 |
| 173.5.19.73 | 173.0.0.1 | 1 |
| 173.5.21.12 | 173.0.0.1 | 1 |
| 173.5.21.18 | 173.0.0.1 | 1 |
| 173.192.0.1 | local | - |
| 173.192.2.1 | 173.192.2.1 | 4 |
| 173.192.2.15 | 173.192.2.1 | 4 |
| 173.192.2.16 | 173.192.2.1 | 4 |
| 173.192.3.4 | 173.192.3.4 | 3 |
| 173.192.3.5 | 173.192.3.5 | 2 |

Everything behind 173.0.0.1 (173.0.0.1, 173.3.2.196, and all 173.4.x/173.5.x) goes out port 1. The 173.192.2.x addresses go via 173.192.2.1 on port 4. 173.192.3.4 and 173.192.3.5 are directly attached on ports 3 and 2.

### Q2.2 - Distance Vector control-plane state at 173.0.0.1

The DV control plane holds 173.0.0.1's distance vector (cost from 173.0.0.1 to each destination):

| Destination | Via 173.0.0.1 (distance) |
|---|---|
| 173.0.0.1 | 0 |
| 173.3.2.196 | 1 |
| 173.4.0.1 | 1 |
| 173.4.63.12 | 2 |
| 173.4.63.13 | 2 |
| 173.4.63.14 | 2 |
| 173.5.0.1 | 1 |
| 173.5.19.73 | 2 |
| 173.5.21.12 | 2 |
| 173.5.21.18 | 2 |
| 173.192.0.1 | 1 |
| 173.192.2.1 | 2 |
| 173.192.2.15 | 3 |
| 173.192.2.16 | 3 |
| 173.192.3.4 | 2 |
| 173.192.3.5 | 2 |

(Only 173.192.2.15 and .16 are distance 3: 173.0.0.1 -> 173.192.0.1 -> 173.192.2.1 -> host.)

### Q2.3 - Distance Vector routing table at 173.192.0.1

After DV converges, shortest paths match Dijkstra (all costs 1), so the table is the same as Q2.1:

| Destination | Next Hop | Port |
|---|---|---|
| 173.0.0.1 | 173.0.0.1 | 1 |
| 173.3.2.196 | 173.0.0.1 | 1 |
| 173.4.0.1 | 173.0.0.1 | 1 |
| 173.4.63.12 | 173.0.0.1 | 1 |
| 173.4.63.13 | 173.0.0.1 | 1 |
| 173.4.63.14 | 173.0.0.1 | 1 |
| 173.5.0.1 | 173.0.0.1 | 1 |
| 173.5.19.73 | 173.0.0.1 | 1 |
| 173.5.21.12 | 173.0.0.1 | 1 |
| 173.5.21.18 | 173.0.0.1 | 1 |
| 173.192.0.1 | local | - |
| 173.192.2.1 | 173.192.2.1 | 4 |
| 173.192.2.15 | 173.192.2.1 | 4 |
| 173.192.2.16 | 173.192.2.1 | 4 |
| 173.192.3.4 | 173.192.3.4 | 3 |
| 173.192.3.5 | 173.192.3.5 | 2 |

### Q2.4 - Route aggregation

You own 173.0.0.0/8. All remote destinations go through the single next hop 173.0.0.1, so those 10 host routes collapse into one aggregate 173.0.0.0/8. Local subnets keep their smallest covering prefix:

| Destination | Next Hop | Port |
|---|---|---|
| 173.0.0.0/8 | 173.0.0.1 | 1 |
| 173.192.0.0/24 | local | - |
| 173.192.2.0/24 | 173.192.2.1 | 4 |
| 173.192.3.4/32 | 173.192.3.4 | 3 |
| 173.192.3.5/32 | 173.192.3.5 | 2 |

- 173.192.2.0/24 covers 173.192.2.1, .15, and .16 (same next hop, port 4).
- 173.192.3.4 and 173.192.3.5 stay as /32s because they use different ports (3 and 2), so they cannot merge into 173.192.3.0/24.
- Longest-prefix match: a packet for 173.192.2.15 matches both 173.0.0.0/8 and 173.192.2.0/24; the /24 wins.

**How much smaller:** 16 entries before, 5 after (11 fewer, about 69% reduction).

(A less aggressive grouping into 173.0.0.0/16, 173.3.0.0/16, 173.4.0.0/16, and 173.5.0.0/16 gives 8 entries, still half of 16.)

---

## Q3 - Soft versus hard state

Definitions:
- Soft state: when the device dies and its state disappears, the system keeps working.
- Hard state: when the state disappears, the system's functionality is drastically affected.

### Q3.1 - Ethernet switch S fails (STP, no partition, 10,000 TCP connections)

**Soft state lost:** the switch's MAC learning table (MAC address to port). It is soft because it is rebuilt automatically by learning source addresses; STP also recomputes the tree around S, so traffic just takes another path.

**Hard state lost:** none. A layer-2 switch holds no per-flow hard state; it forwards statelessly.

**Connections that fail: 0.** TCP state lives at the endpoints (end-to-end/fate sharing), not in the switch. In-flight packets through S are dropped but TCP retransmits them on the new STP path; no connection is lost.

### Q3.2 - Stateless randomized-hash load balancer, server A fails

**Soft state lost:** none in the LB. It is stateless: randomized hashing computes server = hash(flow) modulo N on the fly, so it stores no per-flow table.

**Hard state lost:** server A's TCP connection state (the ~1,000 connections whose server endpoint was A). When A powers off, that state is destroyed and those connections cannot continue.

**Scenario 1 - A fails and the LB re-hashes onto 9 servers: ~9,000 connections fail.**

- ~1,000 were on A and all fail.
- The other ~9,000 are re-mapped by the new hash function. With randomized (non-consistent) hashing, only ~1,000 (1/9) land back on the same server and survive; ~8,000 go to a server without their state and fail.
- Total: ~9,000.

**Scenario 2 - A is down for t ms and comes back, hash never changes: ~1,000 connections fail.**

- Only the ~1,000 flows hashed to A fail (A's TCP state is gone after the power cycle).
- The ~9,000 flows on other servers are untouched and survive.
- Total: ~1,000.
