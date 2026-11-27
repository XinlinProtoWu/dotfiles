# BGP — Border Gateway Protocol (and AS)

**What it is.** The **interdomain** routing protocol of the Internet: a
**path-vector** protocol in which each network advertises the full list of
**Autonomous Systems (ASes)** a route traverses.

**Why it exists.** Inside one organisation, distance vector or link state works
because everyone shares the same goal (shortest path). *Between* organisations
the goal is **money**, not distance — so routers must be able to express policy.
BGP carries attributes (`AS PATH`, `LOCAL PREF`, `ORIGIN`, `NEXT HOP`) precisely
so operators can choose "cheap" over "short".

**Why it is in these notes.** It is the counter-example that motivates everything
else: it proves that a *connected* graph does not guarantee *reachability*, and
that carrying the path (not just a distance) is what makes loop detection
possible — the fix for [[terms/DV]]'s count-to-infinity.

**Where it appears:** [[11_BGP]] · referenced in [[13_LAN]] Section 7 · [[16_Wireless]] Section 7.3

**Related:** [[terms/DV]] · [[terms/IP]] · [[terms/NAT]]
