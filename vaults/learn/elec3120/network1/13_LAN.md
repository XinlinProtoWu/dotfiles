# 13 — Local Area Networks

> Source: `13-LAN.pdf`. Goal: how a **single** network works inside — how nodes are *identified* (**Media Access Control ([[terms/MAC]])** addresses) and how frames are *delivered* inside one **Local Area Network ([[terms/LAN]])** (broadcast, learning switches, spanning tree).
>
> Earlier lectures handled "the Internet"; this lecture zooms into the inside of one network. Continues into [[14_Distance_Vector]] and [[15_Link_Layer]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Addressing and the link layer:** [[terms/MAC]] · [[terms/Ethernet]] · [[terms/ARP]] · [[terms/DHCP]] · [[terms/IP]] · [[terms/LAN]] · [[terms/NIC]]

**Switching and spanning tree:** [[terms/STP]] · [[terms/ACK]] · [[terms/big-O]]

**Routing and the wider Internet:** [[terms/BGP]]

---

## 1. Two questions, one lecture

The previous lectures explained how packets travel *between* networks. Two
questions about what happens *inside* one network were left open:

1. **Who is who?** How do you identify a node on a LAN?
2. **How does data get there?** How does the network steer a frame to the right
   node?

![[13-LAN.pdf#page=2]]
*Figure: the two gaps this lecture fills. (`13-LAN.pdf` p. 2)*

Building a LAN therefore has exactly two steps, and everything else in this note
belongs to one of them:

![[13-LAN.pdf#page=8]]
*Figure: step 1 is an addressing scheme — here, MAC addresses. (`13-LAN.pdf` p. 8)*

![[13-LAN.pdf#page=32]]
*Figure: step 2 is a routing algorithm to deliver to the right place. (`13-LAN.pdf` p. 32)*

**Why not just hard-code every route?** Because a network must be **plug and
play**: it should self-update when a link fails, host new machines that arrive and
move, and **scale** without touching the old infrastructure.

![[13-LAN.pdf#page=33]]
*Figure: hard-coding is the "cheater solution"; the requirement is plug and play. (`13-LAN.pdf` p. 33)*

**Vocabulary.**

| Term | Meaning |
|---|---|
| **Host / end host / node / device** | anything with a network interface: laptop, phone, server, printer |
| **Switch / bridge** | connects links *inside* one LAN; forwards **frames** using MAC addresses. Same thing, two words. |
| **Router / gateway** | connects *different* LANs; forwards **packets** using IP addresses |

![[13-LAN.pdf#page=6]]
*Figure: switch, bridge and router are all boxes that forward — the difference is *what they look at*. (`13-LAN.pdf` p. 6)*

**Simple example.** A switch is the mail sorter inside one post office: it knows
every mailbox in the building. A router is the truck between post offices: it only
needs to know which city. Getting these two roles confused causes most of the
errors in this topic.

---

## 2. MAC addresses

**What.** A 48-bit identifier, written as six hexadecimal pairs: `34:f3:e4:ae:66:44`.

**Where it comes from.** Burned into the interface by the **manufacturer**
([[terms/NIC]]). Every Ethernet port, Wi-Fi adapter and Bluetooth radio you own has
its own.

![[13-LAN.pdf#page=9]]
*Figure: a 48-bit address in hex. (`13-LAN.pdf` p. 9)*

**How many are there?** $2^{48} = 281{,}474{,}976{,}710{,}656$ — about $2^{16} = 65{,}536$ times the entire IPv4 space. Running out is not a concern here.

**Why a third addressing scheme?** We already have domain names and
[[terms/IP]] addresses. The reason is a different *meaning*:

| Address | Scope | Assigned by | Changes when the device moves? |
|---|---|---|---|
| Domain name | global, human-friendly | registrar | no |
| IP address | global, **topological** | DHCP or admin | **yes** |
| MAC address | local to one LAN, **flat** | manufacturer | no |

**Simple example.** Move a laptop from the university to a café. Its IP address
changes (it must, or routing could not work); its MAC address does not. So **IP
says where you are, MAC says who you are.**

That is also the limitation: a MAC address is *flat*, encoding no location. Fine
inside one LAN, where switches learn where everyone is; hopeless globally, where
you would need one table entry per host — the flat-addressing failure from
`11-BGP.pdf` p. 3. The Internet needs both schemes, which is exactly Section 4.

---

## 3. The Ethernet frame, field by field

Data at the link layer is a **frame** (a datagram — never a "package").

![[13-LAN.pdf#page=10]]
*Figure: the Ethernet frame. (`13-LAN.pdf` p. 10)*

| Field | Size | Job | Why it exists |
|---|---|---|---|
| **Preamble** | 7 B | `10101010` repeated 56 times | wakes up and **synchronises** the receiver's clock |
| **SFD** (Start Frame Delimiter) | 1 B | `10101011` | "the real frame starts now" |
| **Destination MAC** | 6 B | who should receive it | the only field a switch needs |
| **Source MAC** | 6 B | who sent it | so the receiver can **reply** |
| **EtherType** | 2 B | what is inside (`0x0800` = IPv4) | demultiplex to the right upper-layer protocol |
| **Payload** | 46–1500 B | the IP packet | the cargo |
| **FCS** | 4 B | 32-bit CRC | **error detection** — drop corrupted frames |

See [[terms/Ethernet]] for the field-by-field explanation of the preamble, SFD and
FCS/CRC.

### Why a preamble?

The receiver's hardware must lock onto the sender's **bit timing** before it can
tell a `1` from a `0`. The alternating `1010…` pattern produces a clock edge on
every bit — the cheapest possible timing signal. Only once the clock is stable does
the unique `10101011` say "frame begins".

**Analogy.** It is the modem screech before a fax: pure overhead, but without it
the receiver cannot decode anything.

### Why a source address?

Purely so the receiver can answer. Without it the destination would know a frame
arrived but have no way to send anything back — no [[terms/ACK]], no reply, no
higher-layer protocol at all. Hence "reply-to".

![[13-LAN.pdf#page=17]]
*Figure: the source address exists so the receiver can reply. (`13-LAN.pdf` p. 17)*

### Minimum frame size — the 64-byte rule

The payload must be at least **46 bytes**, so the frame is at least
$6 + 6 + 2 + 46 + 4 = 64$ bytes. Short payloads are **padded**.

**Why 64?** Not arbitrary: a sender must still be transmitting when a collision
wave returns from the far end, otherwise it believes a corrupted frame succeeded.
That requires

$$\text{minimum transmission time} > 2 \times \text{maximum propagation delay}.$$

The factor 2 is the **round trip**: the frame must still be on the wire when the
far end's collision signal comes back. See [[15_Link_Layer]] Section 10 and
[[16_Wireless]] Section 2.

**Worked example — header overhead.** Including the 8 bytes of preamble + SFD, the
wire carries 26 bytes of non-payload per frame:

| Payload | Bytes on the wire | Overhead |
|---|---|---|
| 46 B (minimum) | $46 + 26 = 72$ | $26/72 \approx 36\%$ |
| 1500 B (maximum) | $1500 + 26 = 1526$ | $26/1526 \approx 1.7\%$ |

So packing small messages into one large frame is not a micro-optimisation: it is
a 20× reduction in per-byte overhead. (Compare the header-overhead argument in
[[15_Link_Layer]] Section 7.)

---

## 4. Two addresses, one packet: Ethernet plus IP

IP says *which host in the world*; Ethernet says *which port on this wire*. So
every packet carries two destinations, filled in differently:

| Case | IP destination | Ethernet destination |
|---|---|---|
| Destination **inside** my LAN | D's IP | **D's MAC** |
| Destination **outside** my LAN | D's IP (unchanged, end-to-end) | **my gateway's MAC** |

![[13-LAN.pdf#page=21]]
*Figure: the Ethernet destination changes hop by hop; the IP destination never does. (`13-LAN.pdf` p. 21)*

**Who reads what.**

- **Switches** read only the Ethernet header and **ignore IP entirely**.
- The **gateway** reads the Ethernet header, strips it, peeks at the IP header, and
  chooses the next hop.

**Simple example.** Laptop `10.79.241.55` (MAC `ab:…:f3`) sends to `8.8.8.8`:

```text
IP       dst = 8.8.8.8              ← never changes, all the way to Google
Ethernet dst = 10.79.255.254's MAC  ← the gateway, this hop only
```

One hop later the very same packet has a *different* Ethernet destination and an
identical IP destination.

> [!important] The two-layer trick
> **Ethernet addresses are per hop; IP addresses are end to end.** This is the most
> examinable idea in the lecture, and the reason [[12_Internetworking]] calls the
> link layer "local delivery" and IP "global delivery".

**How do I know whether D is local?** From the **netmask** handed out by
[[terms/DHCP]] (Section 7): if D matches my prefix, send directly; otherwise go to the
gateway. That is longest-prefix matching in miniature — see [[11_BGP]].

---

## 5. ARP — how do I find a MAC address?

I have the destination **IP**; Ethernet needs a **MAC**. [[terms/ARP]] bridges the
gap:

1. **Broadcast** to everyone: "who has `34.244.91.1`?" (Ethernet destination
   `FF:FF:FF:FF:FF:FF`).
2. The owner replies **unicast**: "I do — my MAC is `ab:cd:ef:12:34:56`."
3. The asker caches it for a while.

![[13-LAN.pdf#page=23]]
*Figure: ARP request is broadcast, ARP reply is unicast. (`13-LAN.pdf` p. 23)*

**Simple example.**

```text
BROADCAST  dst FF:FF:FF:FF:FF:FF  "Who has 34.244.91.1?"
UNICAST    dst ab:cd:ef:12:34:56  "I have 34.244.91.1"
```

**Analogy.** You know a classmate's student ID but not their face, so you shout
"who is 12345678?" and one person raises a hand. MAC addresses are like phone
numbers: you cannot derive them, you have to ask.

Notice the subtlety: ARP is *itself* a broadcast, so it needs no prior knowledge
of anyone's MAC — only the all-ones address.

---

## 6. The broadcast address

One MAC address is reserved: `FF:FF:FF:FF:FF:FF` — 48 bits, all ones — meaning
**everyone on this LAN**. It is how ARP and DHCP reach hosts they have never met,
and it is the mechanism behind every problem in Sections 8–9.

---

## 7. DHCP — how do I get an IP address?

A MAC address is burned in at the factory. An IP address is **rented** from a
server, using [[terms/DHCP]]:

1. **DHCP DISCOVER** — the client broadcasts "can I have an address, please?" to
   `FF:FF:FF:FF:FF:FF`. It must broadcast, because it has no address yet.
2. **DHCP OFFER** — a server answers "you can have `34.244.91.91`".
3. Request + ACK complete the lease.

![[13-LAN.pdf#page=26]]
*Figure: DHCP DISCOVER is a broadcast — the client has no address yet. (`13-LAN.pdf` p. 26)*

The server also tells the host how to *use* the address:

```text
your IP      = 34.244.91.91
your gateway = 34.244.91.1
your netmask = 255.255.255.0    →  "34.244.91.* is local; everything else goes to the gateway"
```

That netmask is what makes the decision in Section 4 answerable.

![[13-LAN.pdf#page=31]]
*Figure: DHCP hands over gateway and netmask, which is what makes "is D local?" answerable. (`13-LAN.pdf` p. 31)*

> [!warning] DHCP has no authentication
> Anyone on the LAN can answer. The deck's own response to "isn't that really
> insecure?" is "yes". (`13-LAN.pdf` p. 30)

> [!tip] DHCP versus ARP — do not mix them up
> **DHCP**: "what is *my* IP?" → broadcast, needs a **server**, returns address +
> gateway + netmask.
> **ARP**: "what is *your* MAC?" → broadcast, needs only the **peer host**, returns
> a MAC.
> At boot: DHCP first (you need an address), then ARP (you need a MAC to send).

---

## 8. Generation 1: flood everything, and learn while you flood

The dumbest delivery algorithm: **send the frame out of every port.** Every switch
re-sends it everywhere except the port it arrived on.

![[13-LAN.pdf#page=34]]
*Figure: one frame addressed to `aa:bb:cc:dd:ee:ff`. (`13-LAN.pdf` p. 34)*

![[13-LAN.pdf#page=39]]
*Figure: after flooding, everyone has received it… (`13-LAN.pdf` p. 39)*

![[13-LAN.pdf#page=40]]
*Figure: …and only the addressed host answers. (`13-LAN.pdf` p. 40)*

This **works**: if a path exists, the frame arrives. It needs no configuration and
converges instantly. Two costs: it wastes bandwidth, and everyone can eavesdrop —
a NIC in *promiscuous mode* reads all of it (`13-LAN.pdf` p. 41).

### The one smart addition: learning switches

A switch can do much better by noticing **who sent what, from where**:

> **Every switch maintains: "to reach this MAC, use this port."**

| MAC address | Port | Age |
|---|---|---|
| `A21032C9A591` | 1 | 36 |
| `99A323C90842` | 2 | 01 |
| `112233445566` | 2 | 15 |

![[13-LAN.pdf#page=44]]
*Figure: a learning switch's forwarding table. (`13-LAN.pdf` p. 44)*

```text
Receive_Packet(packet, ingress_port, time_now):
    if source MAC not in table:
        insert (source MAC, ingress_port, time_now)     # LEARN
    if destination MAC not in table:
        flood out all ports except ingress_port          # UNKNOWN -> flood
    else:
        send out only the recorded port                  # KNOWN   -> unicast

Clean_Up(time_now):
    delete any entry whose age is too old                 # AGE OUT
```

![[13-LAN.pdf#page=45]]
*Figure: learn from the source, decide from the destination. (`13-LAN.pdf` p. 45)*

**Worked example.** Host `A` on port 1 sends to `B`, whose location is unknown:

| Step | Table after | Frames sent |
|---|---|---|
| 1. `A` sends | `A → port 1` | flooded to ports 2, 3, 4 |
| 2. `B` (port 3) replies | `A → 1`, `B → 3` | only back to port 1 |
| 3. `A` → `B` again | unchanged | **only** out of port 3 |

One broadcast, then unicast forever. State is $O(\#\text{hosts})$ — one row per
host that has *spoken*, not one per host that exists.

### Why the age/timeout?

Because reality changes:

- A laptop **moves** from port 3 to port 4; the stale row would black-hole its traffic.
- A MAC address is **reused** by a replacement machine in the same slot.
- Otherwise the table grows forever.

Aging means stale knowledge **expires** and is re-learned from the next frame.
Combined with learning from the source, the switch re-converges with no human
involvement — the plug-and-play property from Section 1.

---

## 9. The big problem: broadcast storms

Now connect switches in a **loop**. Loops are not a mistake — they are how you buy
redundancy — so this is the normal case, not a contrived one.

![[13-LAN.pdf#page=50]]
*Figure: a frame enters a looped topology… (`13-LAN.pdf` p. 50)*

Each switch floods unknown destinations out of every port except the ingress. In a
loop the frame goes round and round, and **every traversal creates more copies**.

![[13-LAN.pdf#page=55]]
*Figure: …and circulates forever — a **broadcast storm**. (`13-LAN.pdf` p. 55)*

**Worked example.** Three switches A–B–C in a triangle. A sends one broadcast:

| Hop | Copies in flight |
|---|---|
| 1 | A→B, A→C = 2 |
| 2 | each of those is re-flooded ⇒ 4 |
| 3 | ⇒ 8 |
| $k$ | $2^{k}$ |

The copies never die, because nothing in the network knows the frame is a duplicate.
Within microseconds-to-milliseconds the LAN is saturated **by its own copies**:
no host gets useful service, and the network has effectively killed itself. This
is a real outage mode in campus and datacentre networks.

**Two "solutions" that are not solutions** (`13-LAN.pdf` pp. 56, 58): "just make
the topology a tree" throws away redundancy, and "just don't plug in loops" needs a
human and a diagram every time you add a switch.

---

## 10. Spanning Tree Protocol (STP)

**Idea.** Keep the loops in the *cabling* (redundancy) but make the *forwarding*
topology a **tree** by disabling ports.

![[13-LAN.pdf#page=62]]
*Figure: reduce the topology graph to a tree: no loops, every segment still connected. (`13-LAN.pdf` p. 62)*

![[13-LAN.pdf#page=59]]
*Figure: a topology **with** loops… (`13-LAN.pdf` p. 59)*

![[13-LAN.pdf#page=60]]
*Figure: …reduced to a spanning tree by disabling some ports. (`13-LAN.pdf` p. 60)*

Requirements: no loops, **all** segments still reachable (it must *span*), achieved
by bridges disabling **ports**, not by unplugging cables.

![[13-LAN.pdf#page=63]]
*Figure: the distributed overview — one unique default path to each destination. (`13-LAN.pdf` p. 63)*

### The data structure: `(Root, Path Length, Next Hop)`

| Field | Meaning |
|---|---|
| **Root** | identifier (ID) of the bridge I believe is the root |
| **Path Length** | how many hops from me to that root |
| **Next Hop** | which neighbour I send toward the root |

![[13-LAN.pdf#page=65]]
*Figure: the three numbers every bridge stores. (`13-LAN.pdf` p. 65)*

**Rule 0.** The root is the bridge with the **lowest ID** (lowest MAC address). Its
own record is `(me, 0, me)`.

![[13-LAN.pdf#page=64]]
*Figure: lowest ID becomes root; every bridge then finds its shortest path to it. (`13-LAN.pdf` p. 64)*

### The algorithm

```text
initially: my record = (Me, 0, Me)      # everyone optimistically claims to be root

loop forever:
    send my record to all neighbours
    for each record received from neighbour N:
        candidate = (their Root, their Path Length + 1, N)
        if candidate.Root < mine.Root:                    accept   # better root
        elif candidate.Root == mine.Root and
             candidate.PathLength < mine.PathLength:      accept   # shorter path
        elif exactly tied:                                pick lower-ID neighbour
    # if my record changed, tell the neighbours again
```

![[13-LAN.pdf#page=66]]
*Figure: the three comparison rules. (`13-LAN.pdf` p. 66)*

Two properties make this "weird" (`13-LAN.pdf` p. 69): it is **fully distributed**
and **asynchronous**, so the global order of events is unpredictable. The only
place you can reason reliably is **one node at a time** — which is why the next
section works the example out node by node.

![[13-LAN.pdf#page=73]]
*Figure: rejecting a higher-ID root — "I should keep my old route". (`13-LAN.pdf` p. 73)*

![[13-LAN.pdf#page=74]]
*Figure: accepting a lower-ID root — "I should update my route". (`13-LAN.pdf` p. 74)*

### Which ports survive?

Once the records stop changing the protocol has **converged**; then every bridge
blocks the ports that do not lead toward the root or to a child.

![[13-LAN.pdf#page=84]]
*Figure: convergence, then remove every link that does not connect someone to the root. (`13-LAN.pdf` p. 84)*

![[13-LAN.pdf#page=87]]
*Figure: the port-role decision. (`13-LAN.pdf` p. 87)*

| What my neighbour tells me | What they are to me | Port state |
|---|---|---|
| the best path to root (or equal cost with lower ID) | my **parent** | **root port** — keep active |
| equal cost, but not my parent, and I am not their parent | neither | **blocked / alternate** |
| a path *worse* than mine | my **child** | keep active (designated) |

**Blocked means:** do not forward *out* of it, and pretend you heard nothing *in*
on it. A link is blocked on **one side only** — that is enough to break the cycle.

---

## 11. A worked spanning-tree example

Bridge IDs $1 < 2 < 3 < 4 < 5$. The cabling is a square with a tail: five links,
namely 1–2, 1–3, 2–4, 3–4 and 4–5, numbered by bridge ID. So there is exactly one
loop (1–2–4–3–1) and one dangling bridge (5).

**Converged records:**

| Bridge | Record | Reasoning |
|---|---|---|
| 1 | `(1, 0, 1)` | lowest ID ⇒ **root** |
| 2 | `(1, 1, 1)` | directly attached to 1 |
| 3 | `(1, 1, 1)` | directly attached to 1 |
| 4 | `(1, 2, 2)` | via 2 costs 2; via 3 also costs 2 ⇒ tie ⇒ lower ID wins (2) |
| 5 | `(1, 3, 4)` | its only way out is through 4 |

**Port decisions on the `3 — 4` link:**

- **4** hears `(1,1,1)` from 3 ⇒ cost via 3 is 2, *equal* to its best via 2 ⇒ 3 is
  neither parent nor child ⇒ **block 4's port to 3**.
- **3** hears `(1,2,2)` from 4 ⇒ cost via 4 is 3, *worse* than its own 1 ⇒ 4 is a
  **child** ⇒ **keep 3's port** active.

**Result.** 5 bridges, 4 active links: a tree. The loop is gone, and every bridge
is still reachable.

> [!warning] A spanning tree is not a shortest-path tree
> After blocking, `3` reaches `5` by $3 \to 1 \to 2 \to 4 \to 5$ — **four hops** —
> even though $3 \to 4 \to 5$ physically exists at **two hops**. Reachability is
> preserved, optimality is not. That single defect is the reason for [[14_Distance_Vector]].

---

## 12. Trade-offs

![[13-LAN.pdf#page=89]]
*Figure: the comparison table starts with **resilience**. (`13-LAN.pdf` p. 89)*

| Criterion | Broadcast + learning switches | + Spanning Tree |
|---|---|---|
| **Resilience** | any existing route is used — very robust | must **recompute** the tree after a failure |
| **Fully distributed** | yes | yes |
| **State per node** | $O(\#\text{nodes})$ | $O(\#\text{nodes}) + O(1)$ path to root |
| **Convergence** | no setup at all | must run STP **before** any routing |
| **Routing efficiency** | broadcast storm | still floods unknown destinations everywhere |
| **Shortest path?** | not necessarily | not necessarily |

![[13-LAN.pdf#page=93]]
*Figure: even after spanning tree, unknown destinations are still flooded everywhere. (`13-LAN.pdf` p. 93)*

Two consequences that motivate the rest of the course:

1. **STP guarantees reachability, not optimality** — see the four-hop detour in Section 11.
2. **STP throws away capacity.** Every blocked port is bandwidth you paid for. A
   triangle of 1 Gbps links behaves like two links.

> [!note] Definitions the deck defines explicitly
> **Resilience:** the ability to provide and maintain an acceptable level of service
> in the face of faults. (p. 89)
> **Fully distributed:** does not assume a central coordinator. (p. 90)
> **State:** the amount of memory each node uses. (p. 91)
> **Convergence:** routers/switches agreeing on optimal routes, completing the
> update of their routing tables. (p. 92)

---

## 13. The real world

![[13-LAN.pdf#page=95]]
*Figure: broadcast routing is only used in very small networks. (`13-LAN.pdf` p. 95)*

Broadcast plus spanning tree is fine for **one rack in a machine room**. It is
hopeless across a campus, for the reasons in Section 12: no shortest paths, wasted
capacity, and one flooded frame per unknown destination. Bigger networks compute
shortest paths explicitly — [[14_Distance_Vector]], then [[15_Link_Layer]].

---

## 14. Highlights (p. 96)

- Routing in networks is hard.
- The laziest solution — **broadcast to everyone** — works, but wastes the network.
- Loops turn flooding into **broadcast storms**: copies multiply exponentially and
  the LAN kills itself.
- **Spanning Tree Protocol** breaks loops by disabling ports, producing exactly one
  path between every pair of nodes.
- A **routing table** is a data structure telling a switch where to steer frames,
  maintained by a routing algorithm; a **learning switch** is the simplest such
  algorithm.

> [!tip] Exam traps
> - MAC = **48 bits / 6 bytes**, hex; IP = 32 bits, dotted decimal.
> - **The Ethernet destination is rewritten at every hop; the IP destination never changes.**
> - Learn from the **source**, forward by the **destination**.
> - `FF:FF:FF:FF:FF:FF` is the **broadcast** address — all 48 bits set, not a special prefix.
> - **ARP resolves IP → MAC; DHCP assigns IP + gateway + netmask.** Both use broadcast, for different reasons.
> - The minimum frame is **64 bytes** including the 4-byte FCS (46-byte payload) — this is a *collision-detection* requirement, not an arbitrary size.
> - A switch's state is $O(\#\text{hosts that have spoken})$, not $O(\#\text{hosts})$.
> - Root = **lowest** bridge ID, not the highest and not the busiest; ties in path length are broken by **lower neighbour ID**.
> - A blocked port is blocked on **one side** of the link, yet that is enough to break the loop.
> - A spanning tree is **loop-free but not shortest-path** — reachability without optimality.
