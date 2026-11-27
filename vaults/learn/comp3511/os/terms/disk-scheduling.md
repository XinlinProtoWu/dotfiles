# Disk scheduling — ordering the I/O request queue

**What it is.** A policy that decides *which* pending disk request the head
services next. The six algorithms in COMP 3511, all measured on the same queue
`98, 183, 37, 122, 14, 124, 65, 67` with the head parked at cylinder 53 on a
0–199 cylinder disk:

| Algorithm | Rule | Head movement |
| --- | --- | --- |
| **FCFS** | arrival order | 640 |
| **SSTF** | nearest pending request | 236 |
| **SCAN** | sweep to the wall, then reverse (elevator) | 236 |
| **LOOK** | sweep to the last request, then reverse | 208 |
| **C-SCAN** | sweep to the wall, snap back to 0, sweep again | 382 |
| **C-LOOK** | sweep to the last request, snap back to the first | 322 |

**Why it exists.** Seek time dominates access time, and seek time is proportional
to *distance travelled*. By reordering a queue you can cut total travel — and the
OS is free to reorder because the requests have no ordering requirement among
themselves.

**Example.** Head at 53, next three requests are 98, 183, 37. FCFS travels
$45 + 85 + 146 = 276$ cylinders. SSTF takes 37 first: $16 + 8 + 12 = 36$ — same
three requests, a seventh of the movement.

**Where it appears:** [[chap11_mass_storage]] Sections 8–15

**Related:** [[terms/seek-time]] · [[terms/logical-block]]
