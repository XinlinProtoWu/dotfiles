# Multiplexing — FDM, TDM, FDMA, TDMA

**What they are.** Two pairs of words for "how several users share one channel".

| Term | Full name | Shares by | Setting |
|---|---|---|---|
| **FDM** | Frequency Division Multiplexing | splitting the band into sub-bands | feeds several *flows* onto one link |
| **TDM** | Time Division Multiplexing | giving each flow fixed time slots | same |
| **FDMA** | Frequency Division **Multiple Access** | giving each *node* a sub-band | several nodes sharing one medium |
| **TDMA** | Time Division **Multiple Access** | giving each node time slots | same |

**Multiplexing** is about combining many flows; **multiple access** is about
arbitrating many competing senders. Same mathematics, different problem.

**Examples.** Bluetooth uses both: TDM in 625 µs slots, and FDM over 79
frequencies hopped pseudo-randomly (spread spectrum). Classic cellular voice used
FDMA/TDMA.

**Why they lose to random access.** Fixed partitions waste capacity when traffic
is bursty: a node with nothing to send still owns its slot or sub-band. That is
why Ethernet and Wi-Fi use random access with [[terms/CSMA]] instead.

**Where it appears:** [[15_Link_Layer]] Section 9 · [[16_Wireless]] Section 5

**Related:** [[terms/CSMA]] · [[terms/ISM-band]]
