# 11 — IP Addressing and BGP

> Source: `11-BGP.pdf`. Goal: how IP addresses are structured, how they are used inside a large organization, and how routing works **between** organizations with BGP.
>
> Continues from [[10_IP]]; queueing and congestion control are in [[09_Queue_Management]] and [[07_Congestion_Control]].

## 1. Why hierarchical addressing?

Two naive options for forwarding:

| Option | Idea | Problem |
|---|---|---|
| **Flat addresses** | One table entry per destination host | 100,000 hosts → 100,000 entries; today's Internet has billions of users |
| **Source routing** | Put the entire path in the packet | Hosts must know the whole topology; variable header size; operators lose control |

![[11-BGP.pdf#page=3]]
*Figure: flat forwarding needs one entry per host. (`11-BGP.pdf` p. 3)*

The Internet instead uses **hierarchical addressing**:

- Routers keep only broad **prefixes**, not every host.
- An **IP prefix** is a set of addresses sharing the same initial bits.
- The host does not need to know the network topology.

![[11-BGP.pdf#page=8]]
*Figure: 32 bits split into a network prefix and a host suffix. (`11-BGP.pdf` p. 8)*

IPv4 is a 32-bit number, written as four dotted octets:

```text
00001001 01001111 11110001 00110111
    9        79      241       55
```

---

## 2. Address history: classful addressing

Originally, the first 8 bits were the network and the last 24 bits were the host. That allowed only 256 networks — not enough.

The classful scheme (1981) split addresses into fixed sizes:

| Class | Leading bits | Network bits | Host bits | Purpose |
|---|---|---|---|---|
| **A** | `0` | 8 | 24 | Very large networks |
| **B** | `10` | 16 | 16 | Medium networks |
| **C** | `110` | 24 | 8 | Small networks |
| **D** | `1110` | — | — | Multicast |
| **E** | `1111` | — | — | Reserved for experiments |

![[11-BGP.pdf#page=12]]
*Figure: class A–E address formats. (`11-BGP.pdf` p. 12)*

By 1991 the problems were clear:

- **Address space depletion:** `2^32` is only about 4.2 billion addresses.
- **Class A** is too large for almost everyone.
- **Class C** is too small for many organizations, but they do not need a whole class B.
- Many allocated blocks are sparsely used.

Three responses:

1. **CIDR** — classless addressing.
2. **NAT** — share one public address among many hosts.
3. **IPv6** — 128-bit addresses (long-term, requires everyone to upgrade).

---

## 3. CIDR — Classless Interdomain Routing

**CIDR** allows the network/host boundary to be anywhere, not just at 8, 16, or 24 bits.

A prefix is written as `address/length`, e.g. `128.23.9.0/26`. Formally, the prefix has a 32-bit mask:

```text
/26  →  255.255.255.192
        11111111.11111111.11111111.11000000
        └──────── network ────────┘└host┘
```

> [!example] Fifty computers
>
> Need 6 host bits because `2^5 < 50 < 2^6` (`32 < 50 < 64`).
> So the prefix is `32 − 6 = 26` bits.
>
> ```text
> Network: 128.23.9.0/26
> Mask:    255.255.255.192
> Addresses: .0 – .63  (64 total, enough for 50 computers)
> ```
>
> The boundary must be written explicitly because it is no longer implied by the class.

### Classful vs. classless

> [!example] An organization needs 500 addresses
>
> - A class C gives only 254 hosts — not enough.
> - A class B gives about 65,534 hosts — a huge waste.
> - CIDR gives a **/23** = 512 addresses, equivalent to two class Cs.
>
> Maximum waste: **50%**. This is much better than allocating a class B for 500 hosts.

### Route aggregation

CIDR addresses are allocated in **contiguous prefix chunks**. A provider can therefore combine many customer prefixes into one **aggregate** announcement.

![[11-BGP.pdf#page=18]]
*Figure: recursively break a large prefix into smaller chunks as you get closer to hosts. (`11-BGP.pdf` p. 18)*

![[11-BGP.pdf#page=20]]
*Figure: China Mobile needs one entry for all of HKUST if HKUST owns `a.0.0.0/8`. (`11-BGP.pdf` p. 20)*

> [!example] Aggregation saves table entries
>
> HKUST has `a.b.0.0/16` (UG Hall 1) and `a.c.0.0/16` (UG Hall 2).
>
> - Without aggregation: China Mobile needs **two** entries.
> - If HKUST owns `a.0.0.0/8` and advertises that one prefix: China Mobile needs **one** entry.
>
> New HKUST subnets can then be added without changing China Mobile's routing table.

Aggregation is crucial for:

- **small forwarding tables** at routers,
- **limited churn** — fewer routing changes when customers add networks.

---

## 4. Longest Prefix Match (LPM)

A packet may match several prefixes. The router chooses the **longest matching prefix** — the most specific route.

![[11-BGP.pdf#page=24]]
*Figure: packet `192.1.0.1` matches both `/16` and `/23`; the `/23` is more specific. (`11-BGP.pdf` p. 24)*

> [!example] Routing table
>
> | Destination | Next hop |
> |---|---|
> | `192.1.0.0/16` | `1.2.3.4` |
> | `192.1.0.0/23` | `1.2.3.5` |
> | `192.1.4.0/24` | `1.2.3.6` |
> | `192.1.1.0/24` | `1.2.3.7` |
>
> Packet: `192.1.0.1`.
>
> - Matches `/16` and `/23`.
> - Does **not** match `192.1.4.0/24` or `192.1.1.0/24`.
> - Longest match is `/23` → next hop **`1.2.3.5`**.

### Host routing table

A real host has a small table with a **default route**:

| Destination | Netmask | Gateway | Meaning |
|---|---|---|---|
| `0.0.0.0` | `0.0.0.0` | `10.79.255.254` | Default route to the rest of the Internet |
| `10.79.0.0` | `255.255.0.0` | On-link | Other hosts on the same Ethernet |
| `10.79.241.55` | `255.255.255.255` | On-link | The host itself |
| `10.79.255.255` | `255.255.255.255` | On-link | Broadcast address |

![[11-BGP.pdf#page=25]]
*Figure: a host routing table from `netstat -rn`. (`11-BGP.pdf` p. 25)*

`0.0.0.0/0` is the least specific prefix, so it is used only when nothing else matches.

---

## 5. Subnetting inside an organization

Subnetting adds **another layer of hierarchy** inside a network:

```text
Network | Subnet | Host
```

- The organization splits its block into smaller IP networks.
- Subnetting is **internal** and not visible outside.
- Inside a subnet, communication uses Ethernet (link layer).
- Across subnets, packets are routed using IP addresses.

![[11-BGP.pdf#page=43]]
*Figure: adding a subnet field between the network and host fields. (`11-BGP.pdf` p. 43)*

![[11-BGP.pdf#page=47]]
*Figure: across subnets, routing uses IP addresses. (`11-BGP.pdf` p. 47)*

> [!example] Splitting a `/16` into `/24`s
>
> Start with `128.23.0.0/16` (65,536 addresses).
>
> - Use 8 more bits for subnets → `128.23.0.0/24`, `128.23.1.0/24`, …, `128.23.255.0/24`.
> - 256 subnets, each with 254 usable host addresses.
>
> From outside, the whole organization can still be advertised as `128.23.0.0/16`.

---

## 6. NAT — Network Address Translation

**Idea:** one public IP address has up to `2^16` TCP/UDP ports. Let many internal hosts share that public address, distinguished by **port number**.

Private address blocks used in the deck:

```text
10.0.0.0/8
192.168.0.0/16
```

Internal hosts use private addresses. The NAT translates between private and public addresses as packets enter/leave the organization.

![[11-BGP.pdf#page=32]]
*Figure: internal hosts use private addresses; the NAT has one public address. (`11-BGP.pdf` p. 32)*

### Opening a connection

Client `10.2.2.2` wants to reach server `198.2.4.5:80`.

- The OS picks an ephemeral internal port, e.g. `1000`.
- The NAT maps it to an external port, e.g. `5000`.
- NAT table entry:

| Internal address | Internal port | NAT port |
|---|---|---|
| `10.2.2.2` | `1000` | `5000` |

### Rewriting

Outgoing packet:

```text
before:  src 10.2.2.2:1000    dst 198.2.4.5:80
after:   src 243.4.4.4:5000   dst 198.2.4.5:80
```

The server replies to `243.4.4.4:5000`. The NAT looks up the mapping and rewrites the destination back to `10.2.2.2:1000`.

![[11-BGP.pdf#page=34]]
*Figure: the NAT rewrites the server's reply back to the internal client. (`11-BGP.pdf` p. 34)*

The NAT manages a mapping between two **four-tuples**:

```text
(private source IP, source port, destination IP, destination port)
↔
(public source IP, NAT port, destination IP, destination port)
```

Rules:

- The mapping must be **unique** — one-to-one.
- It must be **consistent** for every packet in the session.
- It cannot change the server's IP or port.
- The NAT may have only one public IP, so **client port mapping** is essential.

### Enabling servers: port forwarding

To let outsiders reach an internal server, statically configure a well-known port:

```text
external 243.4.4.4:80  →  internal 10.3.3.3:80
```

![[11-BGP.pdf#page=36]]
*Figure: static port mapping makes an internal server reachable. (`11-BGP.pdf` p. 36)*

### NAT benefits and downside

Benefits:

- Greatly reduces the need for public IPv4 addresses.
- Basic security: outside hosts cannot initiate connections to internal hosts.
- Makes home networking and coffee-shop Wi-Fi simple.

Downside: **fate sharing**. The principle says:

> You can lose state relevant to an entity's connection **if and only if the entity itself is lost**.

Losing TCP state when an endpoint crashes is fine. Losing it when an unrelated middlebox reboots is not. A NAT holds state for every connection, so if the NAT dies, all sessions die.

![[11-BGP.pdf#page=38]]
*Figure: NAT violates fate sharing; its state is not at the endpoint. (`11-BGP.pdf` p. 38)*

> [!example] NAT practice problem
>
> Home router public IP: `55.44.33.22`. NAT table:
>
> | Public port | Private IP | Private port |
> |---|---|---|
> | `32432` | `192.168.1.4` | `789` |
> | `61223` | `192.168.1.5` | `8454` |
> | `45329` | `192.168.1.4` | `3333` |
> | `61532` | `192.168.1.2` | `44444` |
>
> Incoming packet: source `45.45.45.45:443`, destination `55.44.33.22:45329`.
>
> The public port `45329` maps to `192.168.1.4:3333`, so the forwarded packet is:
>
> | Src IP | Dst IP | Src port | Dst port |
> |---|---|---|---|
> | `45.45.45.45` | `192.168.1.4` | `443` | `3333` |

![[11-BGP.pdf#page=39]]
*Figure: NAT exercise topology and table. (`11-BGP.pdf` p. 39)*

---

## 7. Autonomous Systems and routing policy

An **Autonomous System (AS)** — or **domain** — is a region of the network under a single administrative entity.

- Routers inside an AS use an **interior gateway protocol (IGP)** and common metrics.
- Routers between ASes use an **exterior gateway protocol (EGP)** — BGP.
- **Border routers** connect to other ASes; **interior routers** stay inside.

![[11-BGP.pdf#page=50]]
*Figure: an AS with border routers and interior routers; an end-to-end route crosses ASes. (`11-BGP.pdf` p. 50)*

Each AS has a unique **AS number (ASN)**. In this deck ASNs are 16-bit values; `64512`–`65535` are private.

Examples:

```text
MIT: 3      HKUST: 3363     CUHK: 3661
HKU: 4528   UC San Diego: 7377
AT&T: 7018, 6341, 5074, …
```

### Business relationships

Routing policy follows business relationships, not just topology.

| Relationship | Business meaning |
|---|---|
| **Provider → customer** | Customer pays provider |
| **Peer ↔ peer** | Peers do not pay each other; they exchange roughly equal traffic |

![[11-BGP.pdf#page=58]]
*Figure: provider/customer and peer/peer relationships. (`11-BGP.pdf` p. 58)*

Why peer? If two ASes exchange a lot of traffic, directly peering can save both money compared with sending that traffic through providers.

### “Routing follows the money”

An AS provides **transit** between its customers. Peers do **not** provide transit between other peers.

![[11-BGP.pdf#page=60]]
*Figure: traffic allowed on customer/provider links; peer links do not carry transit for others. (`11-BGP.pdf` p. 60)*

This produces **valley-free** routes:

- go **up** from customer to provider (or across a peer),
- then **down** to the destination customer,
- never go **down and then up again** — a “valley,” e.g. provider → peer → provider.

![[11-BGP.pdf#page=62]]
*Figure: a valley-free route goes up and then down, never up-down-up. (`11-BGP.pdf` p. 62)*

### Gao–Rexford export rules

| Destination prefix advertised by… | Export route to… |
|---|---|
| **Customer** | Everyone: providers, peers, other customers |
| **Peer** | Customers only |
| **Provider** | Customers only |

![[11-BGP.pdf#page=79]]
*Figure: the Gao–Rexford export policy table. (`11-BGP.pdf` p. 79)*

If all ASes follow these rules, the customer-provider graph is a DAG and routes are valley-free.

> [!example] Activity: A to B
>
> - X is a university with providers A and B.
> - A’s provider is C; C’s provider is Z.
> - B’s provider is D; D’s provider is Z.
>
> There is no direct A–B link and no peering. Traffic must go up to the common provider:
>
> ```text
> A → C → Z → D → B
> ```
>
> A sends to its provider C, C to its provider Z; Z sends down to its customer D, then D to its customer B. This is valley-free: up, up, down, down.

---

## 8. BGP basics

**BGP (Border Gateway Protocol)** is the interdomain routing protocol. It is implemented by AS **border routers**.

- **Destinations** are IP prefixes, e.g. `12.0.0.0/8`.
- **Nodes** are ASes; the internals of each AS are hidden.
- **Links** represent physical links and business relationships.
- An AS advertises (“exports”) its best routes to one or more prefixes.

![[11-BGP.pdf#page=66]]
*Figure: an AS exports its best routes to neighbours. (`11-BGP.pdf` p. 66)*

### Four crucial features

1. **Not shortest-path routing.** BGP selects the best route by **policy**, not least cost.
2. **Path-vector routing.** It advertises the **entire AS path**, not just the next hop.
3. **Selective route advertisement.** An AS may refuse to advertise a route.
4. **Route aggregation.** One announcement can cover many prefixes.

#### (1) Policy over shortest path

![[11-BGP.pdf#page=68]]
*Figure: node 2 may prefer path `2,3,1` over the shorter `2,1` for policy reasons. (`11-BGP.pdf` p. 68)*

#### (2) Path vector and loop detection

Each announcement carries the full path:

```text
“d: path (A)”        from A
“d: path (B,A)”      from B, after B receives A's path
```

![[11-BGP.pdf#page=69]]
*Figure: path-vector advertisements carry the entire path. (`11-BGP.pdf` p. 69)*

A node that sees its own ASN in the path discards the route — loop avoided.

![[11-BGP.pdf#page=71]]
*Figure: node 1 sees `3,2,1`, which contains itself, and discards it. (`11-BGP.pdf` p. 71)*

#### (3) Selective advertisement

An AS may choose not to advertise a route. Therefore, **reachability is not guaranteed even if the graph is connected**.

![[11-BGP.pdf#page=73]]
*Figure: AS 2 refuses to carry traffic between AS 1 and AS 3. (`11-BGP.pdf` p. 73)*

#### (4) Aggregation

BGP can aggregate prefixes for scalability, e.g. advertise `a.0.0.0/8` instead of separate `a.b.0.0/16` and `a.c.0.0/16`.

![[11-BGP.pdf#page=74]]
*Figure: BGP route aggregation hides internal prefixes. (`11-BGP.pdf` p. 74)*

### Selection vs. export

Policy is applied in two places:

| Decision | Controls |
|---|---|
| **Route selection** | Which path do I use? → controls traffic **leaving** my network |
| **Route export** | Which path do I advertise? → controls traffic **entering** my network |

![[11-BGP.pdf#page=75]]
*Figure: route export and route selection are the two policy levers. (`11-BGP.pdf` p. 75)*

Typical selection priority:

1. **Make/save money:** prefer customer > peer > provider.
2. **Maximize performance:** smallest AS-path length.
3. **Minimize my bandwidth:** “hot potato” — hand traffic off quickly.

### Typical export policies

Peer-to-peer:

- Export only **customer** routes to a peer.
- Export a peer’s routes only to your customers.

![[11-BGP.pdf#page=77]]
*Figure: peer-peer export: customer routes to peers, peer routes only to customers. (`11-BGP.pdf` p. 77)*

Customer-provider:

- **Provider** exports its customer routes to everybody.
- **Customer** exports provider routes only to its own customers.

![[11-BGP.pdf#page=78]]
*Figure: customer-provider export policies. (`11-BGP.pdf` p. 78)*

### BGP messages

BGP runs over **TCP**. The basic messages are:

| Message | Purpose |
|---|---|
| **Open** | Establish the BGP session |
| **Notification** | Report unusual conditions |
| **Update** | Announce new routes or withdraw old ones |
| **Keepalive** | Tell the neighbour the connection is still alive |

A route update is:

```text
<IP prefix : route attributes>
```

Announcements add/change routes; withdrawals remove routes.

---

## 9. BGP attributes

Attributes describe a route and drive selection/export decisions. Some are **local** to an AS; others are **propagated** in announcements.

| Attribute | Scope | Meaning |
|---|---|---|
| **AS PATH** | Propagated | ASes traversed, e.g. `7018 88` |
| **NEXT HOP** | Propagated | IP address of the next-hop router |
| **LOCAL PREF** | Local | Higher value = more preferred; consistent inside the AS |
| **ORIGIN** | Local | How the route was learned: `e` > `i` > `?` |
| **IGP cost** | Local | Cost to the egress point; used for hot-potato routing |
| **MED** | Propagated | A hint to neighbouring ASes (mentioned, not detailed here) |

![[11-BGP.pdf#page=92]]
*Figure: AS PATH: AS 88 originates `128.112/16`; AS 7018 announces `7018 88`. (`11-BGP.pdf` p. 92)*

![[11-BGP.pdf#page=94]]
*Figure: LOCAL PREF chooses between `AS3 AS1` (300) and `AS2 AS1` (100). (`11-BGP.pdf` p. 94)*

`NEXT HOP` changes as the announcement leaves each AS:

```text
AS 88 → 7018:  prefix 128.112/16, path 88,          next hop 192.0.2.1
7018 → 12654:  prefix 128.112/16, path 7018 88,     next hop 12.127.0.121
```

`ORIGIN` values:

```text
e  = learned from an external protocol
i  = learned from an internal protocol
?  = incomplete, often a static route
Preference: e > i > ?
```

### Hot-potato routing

Each router chooses the **closest egress point** based on intra-domain IGP cost, even if that makes the inter-domain path longer. This minimizes use of its own network bandwidth.

![[11-BGP.pdf#page=97]]
*Figure: hot-potato routing sends traffic out the nearest exit. (`11-BGP.pdf` p. 97)*

IGP cost can also make routing **asymmetric**: A reaches B via one exit, while B reaches A via another.

---

## 10. BGP issues

### Reachability

Normal routing assumes: if the graph is connected, every node is reachable. With policy routing, that is false. An AS may refuse to carry transit traffic, leaving two networks connected physically but unreachable through BGP.

![[11-BGP.pdf#page=100]]
*Figure: AS 2 refuses transit, so AS 1 and AS 3 cannot reach each other through it. (`11-BGP.pdf` p. 100)*

### Security

- An AS can advertise a prefix it cannot actually reach → traffic is **blackholed**.
- An AS can advertise a short path but forward traffic differently.
- Fixing the first is possible if ASes must “prove” they have a path; the second is much harder.

### Convergence

- Under **Gao–Rexford** policies, BGP is guaranteed to converge.
- With arbitrary policies, BGP may **fail to converge**.

### Performance

BGP is designed for **profit**, not performance:

- Hot-potato routing is economically expedient, not globally optimal.
- Fewest AS hops has little to do with actual delay; an AS may contain many router-level hops.

![[11-BGP.pdf#page=104]]
*Figure: BGP says path `4 1` is better than `3 2 1`, but AS 3 may contain many hops. (`11-BGP.pdf` p. 104)*

### Case study: Facebook outage (October 2021)

![[11-BGP.pdf#page=111]]
*Figure: a peak of BGP withdrawals as Facebook's DNS prefixes disappeared. (`11-BGP.pdf` p. 111)*

What happened:

1. Facebook stopped announcing the BGP routes to its **DNS prefixes**.
2. Its DNS servers became unreachable, so resolvers worldwide could not resolve `facebook.com`.
3. Other Facebook IPs were still routed, but without DNS they were effectively useless.
4. Apps retried aggressively, creating a **tsunami of DNS traffic** and 10+ second query delays.
5. Recovery was slow because engineers could not SSH in normally and had to go on-site through strict physical security.

This shows how much of the Internet depends on **BGP reachability + DNS** working together.

---

## 11. Takeaways

- IP addresses are **hierarchical**: prefix + host. Routers forward on prefixes, not individual hosts.
- **CIDR** makes the prefix length flexible; **route aggregation** keeps forwarding tables small.
- Routers use **longest prefix match**; `0.0.0.0/0` is the default route.
- **Subnetting** adds hierarchy inside an organization and is invisible outside.
- **NAT** lets many hosts share one public IP by rewriting ports; it saves addresses but breaks fate sharing.
- An **AS** is an administrative domain; routing between ASes is driven by **business policy**.
- BGP is a **path-vector** protocol: it advertises full AS paths, detects loops, supports selective export, and aggregates routes.
- BGP prefers **customer > peer > provider**, then shorter AS paths, then hot-potato exits.

> [!warning] Exam traps
> - Longest prefix match means **most specific**, not “largest number.”
> - NAT rewrites **both** address and port; it must keep a consistent mapping for the whole session.
> - Without a static port-forwarding entry, a NAT blocks **inbound** connections.
> - AS path length is not latency; BGP optimizes policy, not performance.
> - BGP does **not** share a global topology; each AS sees only advertised routes.
> - A connected graph does **not** guarantee reachability under policy routing.
> - `LOCAL PREF` is local to one AS; `AS PATH` is propagated.
> - BGP withdrawal can make a service unreachable even when its servers and links are still physically up.
