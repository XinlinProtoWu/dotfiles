# Homework 3 — Complete Answers

## Q1

### Q1.1 — Which statement is true?

**Answer: “Classless inter-domain routing (CIDR) adds complexity to the router forwarding.”**

- CIDR requires **longest prefix match**, so a router may have to compare several matching prefixes; that is more complex than fixed classful lookup.
- The `10.9.125.1` option is false: `10.9.122.0/23` covers only `10.9.122.0 – 10.9.123.255`, so `10.9.125.1` does **not** match it at all.
- “All IP addresses are reachable on the public Internet” is false: private addresses, policy, and failures break global reachability.

### Q1.2 — Matches `154.35.128.0/22`?

**Answer: `154.35.130.92`**

`/22` covers:

```text
154.35.128.0 – 154.35.131.255
```

Only `154.35.130.92` lies in that range.

### Q1.3 — Invalid Gao–Rexford route?

**Answer: “A network A sends a packet to its peer B, B then sends the packet to its peer C.”**

This asks B to carry traffic between two peers, A and C. Peers do not provide transit for other peers, so this is a valley. The other three are valid:
- peer → customer: valid (export peer route to a customer);
- provider → provider: valid (uphill, uphill);
- provider → customer: valid (uphill then downhill).

### Q1.4 — Not one of Cerf–Kahn’s original concerns?

**Answer: “Each network may use different routing algorithms.”**

The lecture’s four Cerf–Kahn challenges are:
1. different addressing;
2. different maximum data size;
4. unrecoverable mutation/missing data;
5. different status, routing, fault detection, and isolation.

The original paper’s third concern was about **different time delays/performance** in each network; it was not a separate concern about different routing algorithms. Concern 5 says that status/routing information, fault detection, and isolation differ between networks, but it does not list “different routing algorithms” as its own concern.

### Q1.5 — DNS alias record?

**Answer: `CNAME`**

A `CNAME` makes `www.foobar.com` an alias for the canonical name `web.foobar.com`.

### Q1.6 — Anycast delivery?

**Answer: “Routing delivers it to one of the servers, typically the closest according to the routing system.”**

Anycast does **not** broadcast to every server, and it is not necessarily the geographically closest server; it is the closest according to routing.

### Q1.7 — Distinguishes the destination process/application?

**Answer: The port identifier.**

The IP address identifies the host; the port identifies the process/application on that host.

---

## Q2 — BGP 1

**Answer:** BGP would not force HKUSTNet to carry traffic between HKUNet and CUHKNet.

**Evidence:** BGP supports **selective route advertisement**. Each AS chooses which routes to export to each neighbour. HKUSTNet can refuse to advertise routes learned from HKUNet to CUHKNet, and can refuse to advertise routes learned from CUHKNet to HKUNet. Under the Gao–Rexford export rules, routes learned from a peer are exported only to customers, not to other peers or providers.

**Warrant:** Therefore CUHKNet never learns a route to HKUNet’s customers through HKUSTNet. Without such an advertisement, CUHKNet cannot select HKUSTNet as transit. BGP gives HKUSTNet policy control, so it does not have to carry peer-to-peer transit traffic.

**Key term to include: selective route advertisement** (equivalently, BGP route export policy / Gao–Rexford export rules).

---

## Q3 — BGP 2

The arrows are provider → customer; the double arrow is a peering link.

### Q3.1 — Is Route A valid?

**Answer: No.**

Route A is:

```text
MilkDudNet → HersheyNet → NestleNet → M&MNet ↔ KitKatNet → SmartieNet
```

Edge types:

```text
MilkDud → Hershey    customer → provider   (up)
Hershey → Nestle     customer → provider   (up)
Nestle → M&M         provider → customer   (down)
M&M ↔ KitKat         peer
KitKat → Smartie     provider → customer   (down)
```

It goes **downhill** from NestleNet to its customer M&MNet and only then crosses the M&MNet–KitKatNet peering link. That is not valley-free: the peer link must occur before the downhill segment. Equivalently, M&MNet would have to export a **peer-learned** route to its **provider** NestleNet, which Gao–Rexford forbids (peer routes may be exported only to customers).

**Valid route from MilkDudNet to SmartieNet: none exists.**

The only possible path uses the M&MNet–KitKatNet peer link after already going downhill to M&MNet; every alternative would require a down-then-up transition (for example, going from M&MNet up to MarsNet and back down), which is also a valley.

### Q3.2 — Is Route B valid?

**Answer: Yes.**

Route B is:

```text
RoloNet → M&MNet ↔ KitKatNet → SmartieNet
```

Edge types:

```text
Rolo → M&M       customer → provider   (up)
M&M ↔ KitKat     peer
KitKat → Smartie provider → customer   (down)
```

This is **uphill, then peer, then downhill** — valley-free. M&MNet can export the peer route learned from KitKatNet to its customer RoloNet, which Gao–Rexford allows.

No alternate route is needed.

---

## Q4 — BGP 3 (Tricky)

The ranking functions are:

```text
Domain 1: [1,3,d] > [1,d]
Domain 2: [2,1,d] > [2,d]
Domain 3: [3,2,d] > [3,d]
```

Assume that when a domain’s exact preferred path is unavailable, it falls back to the lower-ranked route listed for it (as the λ notation suggests).

### Q4.1 — All three domains are peers

**Answer: The advertisements oscillate; BGP never converges to a stable assignment.**

Assume each domain initially advertises its direct route. Each round, a domain selects its favourite route from the previous round’s advertisements, prepends itself, and advertises it.

| Round | Domain 1 advertises | Domain 2 advertises | Domain 3 advertises |
|---|---|---|---|
| 0 | `[1,d]` | `[2,d]` | `[3,d]` |
| 1 | `[1,3,d]` | `[2,1,d]` | `[3,2,d]` |
| 2 | `[1,d]` | `[2,d]` | `[3,d]` |
| 3 | `[1,3,d]` | `[2,1,d]` | `[3,2,d]` |

At round 1:
- 1 sees 3’s `[3,d]` and prefers `[1,3,d]`.
- 2 sees 1’s `[1,d]` and prefers `[2,1,d]`.
- 3 sees 2’s `[2,d]` and prefers `[3,2,d]`.

At round 2, each domain now sees the next domain advertising the longer path, so the exact route it preferred is no longer available:
- 1 sees `[3,2,d]`, not `[3,d]`; it falls back to `[1,d]`.
- 2 sees `[1,3,d]`, not `[1,d]`; it falls back to `[2,d]`.
- 3 sees `[2,1,d]`, not `[2,d]`; it falls back to `[3,d]`.

The cycle then repeats. This is **policy-induced BGP oscillation**: each domain is behaving according to its own preference, but there is no stable global routing assignment. Path-vector loop detection prevents loops in a single path, but it does not prevent this oscillation.

### Q4.2 — Customer/provider arrows; pick favourite, export only if it makes money

**Answer: BGP still oscillates; it does not converge.**

The customer/provider relationships are:

```text
2 is provider of 1
1 is provider of 3
2 is provider of 3
1, 2, 3 are providers of d   (d is their customer)
```

“Makes money” means the selected route is a **customer route** (first hop is a customer). Then:

- Domain 1: both `[1,d]` and `[1,3,d]` are customer routes → always exports its selection.
- Domain 2: both `[2,d]` and `[2,1,d]` are customer routes → always exports its selection.
- Domain 3: `[3,d]` is a customer route, but `[3,2,d]` goes through **provider 2**, so it does not make money → if 3 selects `[3,2,d]`, it exports nothing.

Trace:

| Round | Domain 1 | Domain 2 | Domain 3 |
|---|---|---|---|
| 0 | `[1,d]` (export) | `[2,d]` (export) | `[3,d]` (export) |
| 1 | `[1,3,d]` (export) | `[2,1,d]` (export) | `[3,2,d]` (**no export**) |
| 2 | `[1,d]` (export) | `[2,d]` (export) | `[3,d]` (export) |
| 3 | `[1,3,d]` (export) | `[2,1,d]` (export) | `[3,2,d]` (no export) |

At round 1, 3 chooses its favourite `[3,2,d]`, but that route is via its provider, so it is not profitable and 3 exports nothing. Its withdrawal of `[3,d]` means 1 can no longer use `[1,3,d]`, so 1 falls back to `[1,d]`. That removes 2’s `[1,d]`, so 2 falls back to `[2,d]`. That removes 3’s `[2,d]`, so 3 falls back to `[3,d]` and exports again. The cycle then repeats.

Thus the naive rule “pick favourite first, then export only if profitable” is **not enough** to guarantee convergence.

### Q4.3 — Select only money-making routes, then export the favourite

**Answer: BGP converges.**

Now domain 3 may select only routes that make money. Its only money-making route is `[3,d]`; `[3,2,d]` is via provider 2 and is excluded. So 3 always selects and exports `[3,d]`.

One stable outcome is:

| Domain | Selected / advertised route |
|---|---|
| 1 | `[1,3,d]` |
| 2 | `[2,d]` |
| 3 | `[3,d]` |

Reasoning:
- 3 exports `[3,d]` (its only profitable route).
- 1 sees `[3,d]`, prefers `[1,3,d]`, and exports it.
- 2 no longer sees `[1,d]` because 1 is advertising `[1,3,d]`, so 2 falls back to its direct customer route `[2,d]`.
- 3 sees `[2,d]` but cannot use `[3,2,d]` because it is not money-making; it stays on `[3,d]`.
- No domain has an incentive to change, so the system stabilizes.

(If domain 2 also ranks the customer route via 1 above direct, it may instead settle on `[2,1,3,d]`; the important point is that the oscillation is gone.)

The key difference from Q4.2 is that **selection is restricted to profitable (customer) routes**, preventing 3 from repeatedly switching to the provider route `[3,2,d]` and withdrawing its customer route. This is the behaviour the Gao–Rexford conditions are designed to guarantee.

---

## Q5 — DNS Resolution, Caching, and Indirection

### Q5.1 — Initial lookup at `t = 0`

The client sends a **recursive** query to its local resolver:

```text
Client → local resolver: “What is the A record for www.foobar.com?”
```

The resolver then performs **iterative** queries:

1. **Root server**
   - Query: where is `.com`?
   - Returns: a referral to the `.com` TLD name servers (NS records for `.com`).

2. **`.com` TLD server**
   - Query: where is `foobar.com`?
   - Returns: a referral to the authoritative name servers for `foobar.com` (e.g. `ns1.foobar.com`).

3. **Authoritative `foobar.com` server**
   - Query: what is the A record for `www.foobar.com`?
   - Returns: `www.foobar.com → 192.0.2.10`, with `TTL = 60`.

The resolver caches the A record and returns `192.0.2.10` to the client.

**Recursive query:** client → local resolver.

**Iterative queries:** local resolver → root, local resolver → `.com`, local resolver → authoritative `foobar.com`.

### Q5.2 — Lookups at `t = 30` and `t = 65`

The cache entry was created at `t = 0` with `TTL = 60`, so it expires at:

```text
0 + 60 = 60 seconds
```

- **At `t = 30`:** the entry is only 30 seconds old, so it is still valid. The resolver returns **`192.0.2.10`**. This is a cache hit; the TTL is not restarted, so the entry still expires at `t = 60`.
- **At `t = 65`:** the entry expired at `t = 60`. The resolver must resolve again. In the lecture model it contacts the root, the `.com` TLD, and then the authoritative `foobar.com` server. The authoritative server now returns the updated record, so the resolver returns **`192.0.2.20`**.

Answer:

```text
t = 30 s  → 192.0.2.10
t = 65 s  → 192.0.2.20
Original cache entry expires at t = 60 s
```

### Q5.3 — DNS indirection and migration

DNS gives a stable **name** that is separate from the current **IP address**. The service can move to a new machine or a new IP address by changing the DNS record (for example, the A record for `www.foobar.com`). Users keep using the same hostname; they do not need to learn or store the new IP address. The resolver learns the new address the next time its cached record expires or is refreshed.

**One benefit of a shorter TTL for a future migration:**

- Caches expire sooner, so clients and resolvers pick up the new IP address more quickly. This reduces the window in which users are sent to the old server and makes the migration or failover faster.

**One cost of a shorter TTL:**

- Resolvers must query more often, increasing DNS traffic and load on the authoritative servers, and increasing the chance that clients experience lookup latency. Cache hit rates fall.

A shorter TTL is therefore a trade-off: faster migration and failover versus more DNS load and more frequent lookups.
