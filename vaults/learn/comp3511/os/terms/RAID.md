# RAID — Redundant Array of Independent Disks

**What it is.** A collection of disks presented to the OS as one logical device,
combined for *redundancy* (survive a failure), *performance* (parallel arms), or
both. Historically "inexpensive" disks versus a SLED (single large expensive disk).

| Level | Mechanism | Redundant? | Notes |
| --- | --- | --- | --- |
| **0** | block striping only | no | best write speed, no protection |
| **1** | mirroring (every block on two disks) | yes, 50 % overhead | fastest reads, most expensive |
| **4** | block striping + one dedicated parity disk | yes | parity disk is a bottleneck |
| **5** | block striping + distributed parity | yes | one disk's worth of parity |
| **6** | as 5, with two independent parities | yes | survives two failures |
| **1+0** | mirror pairs, then stripe the pairs | yes | can survive multiple failures |
| **0+1** | stripe, then mirror the whole stripe | yes | a *stripe* loss takes the mirror |

**Why it exists.** The mean time to failure of an *array* is the MTTF of one disk
divided by the number of disks — an array is far *less* reliable than a single
disk. Redundancy buys that reliability back, at the cost of capacity.

**Example.** MTTF $100{,}000$ h per disk, 100 disks ⇒ one failure every
$1000\,\text{h} \approx 41.7$ days. With mirroring and a 10 h mean time to repair,
mean time to *data loss* is

$$\text{MTTDL} = \frac{\text{MTTF}^2}{2\,\text{MTTR}} = \frac{10^{10}}{20} = 5\times 10^{8}\,\text{h} \approx 57{,}000\ \text{years}$$

**Where it appears:** [[chap11_mass_storage]] Sections 16–18

**Related:** [[terms/striping]] · [[terms/seek-time]]
