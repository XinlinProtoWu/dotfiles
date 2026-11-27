# 11 — Mass-Storage Systems

> Source: `Chapter11.pdf`. Goal: understand how a disk physically stores blocks,
> what that costs in time, how the OS orders the request queue to cut that cost,
> and how RAID trades capacity for reliability and parallelism. Precedes
> [[chap13_file_system_interface]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Disk hardware and time:** [[terms/seek-time]] · [[terms/logical-block]] · [[terms/SSD]]

**Ordering the queue:** [[terms/disk-scheduling]]

**Reliability and parallelism:** [[terms/RAID]] · [[terms/striping]]

---

## 1. Disk geometry

A magnetic disk is a stack of **platters**. Both faces are coated with magnetic
material, and a read-write head "flies" a few nanometres above each face. All the
heads are mounted on one **arm** and move together — this single fact is what
makes scheduling possible at all: one seek serves every platter at once.

| Object | Definition |
| --- | --- |
| **Platter** | one physical disc; 1.8", 2.5", 3.5" today, historically 0.85"–14" |
| **Track** | one concentric circle on one face |
| **Sector** | one arc segment of a track; hundreds per track |
| **Cylinder** | the set of tracks at one arm position, across *all* faces |

![[Chapter11.pdf#page=4]]
*Figure: the moving-head disk mechanism — platters, arm, tracks, sectors. (`Chapter11.pdf` p. 4)*

**In plain words.** Think of a stack of old vinyl records on one spindle, with a
single pick-up arm carrying several needles, one per record surface. The arm
cannot lower one needle without lowering them all, so it parks the whole stack
over one groove-circle and reads every record at that radius in turn. That is why
we measure position in *cylinders* — the arm's position — and not in tracks: the
arm's cost depends only on which circle it sits over, never on which record.

**Example (traced).** A drive with 4 platters (8 surfaces), 100 000 tracks per
surface, 500 sectors per track, 512 bytes per sector. The 8 tracks at arm
position $c$ together form cylinder $c$. Capacity of one cylinder is
$8 \times 500 \times 512 = 2{,}048{,}000$ bytes $\approx 2\,\text{MB}$; the whole
drive is $100{,}000 \times 2\,\text{MB} = 200\,\text{GB}$.

> [!important] Cylinders, not tracks, are the unit of cost
> Every scheduling algorithm in this chapter reasons in cylinder numbers. "Seek
> distance" = difference in cylinder numbers.

---

## 2. What a disk access costs

Four numbers describe a drive:

| Metric | Meaning | Typical value |
| --- | --- | --- |
| **Transfer rate** | bytes/s between drive and computer | 6 Gb/s theoretical, ~1 Gb/s effective |
| **Seek time** | move the arm to the target cylinder | 3–12 ms, 9 ms common |
| **Rotational latency** | wait for the target sector to spin under the head | $60/\text{RPM}$ full turn |
| **Head crash** | head touches the surface | no, really, bad |

Rotation speed is quoted in RPM, and the latency follows directly:

$$\text{one turn} = \frac{1}{\text{RPM}/60} = \frac{60}{\text{RPM}}\ \text{s}
\qquad
t_{\text{rot,avg}} = \frac{1}{2}\cdot\frac{60}{\text{RPM}}$$

The factor $\tfrac12$ is because on average the sector is halfway round. Average
seek time is quoted as about **one third of the tracks** — the arm's travel has a
long tail, so the mean is short relative to the diameter.

Buses vary (EIDE, ATA, **SATA**, USB, Fibre Channel, SCSI, SAS, FireWire); a host
controller on the bus talks to a disk controller inside the drive.

**In plain words.** Getting a book out of a closed library takes three waits: walk
to the right shelf, stand there while the right page comes round, then photocopy
it. The walking dominates because you are slow and the shelves are far apart, so
"which shelf first?" is the only lever you really have. Modern drives even quote
the walking time optimistically by assuming you are usually near a shelf you have
already visited.

**Example (traced).** A 7200 RPM drive: $7200/60 = 120$ revolutions per second,
so one turn is $1/120 \approx 8.33\,\text{ms}$; average rotational latency is
$8.33/2 = 4.17\,\text{ms}$. A slow 5400 RPM drive gives $60/5400 = 11.1\,\text{ms}$
per turn and $5.56\,\text{ms}$ average latency. The deck's two reference drives are
therefore

$$\begin{aligned}
\text{fast: } & 3\,\text{ms} + 2\,\text{ms} = 5\,\text{ms} \\
\text{slow: } & 9\,\text{ms} + 5.56\,\text{ms} = 14.56\,\text{ms}
\end{aligned}$$

![[Chapter11.pdf#page=5]]
*Figure: overview table — transfer rate, positioning time (seek + rotational), head crash, buses. (`Chapter11.pdf` p. 5)*

---

## 3. Worked example: the real cost of a 4 KB read

The full model is

$$\text{average I/O time} = t_{\text{seek}} + t_{\text{lat}}
+ \frac{\text{bytes}}{v_{\text{xfer}}} + t_{\text{ctrl}}$$

The deck's instance: a 4 KB block, 7200 RPM, 5 ms average seek, 1 Gb/s transfer
rate, 0.1 ms controller overhead.

**In plain words.** You asked the library for four pages. Walking to the shelf
takes five milliseconds, waiting for the page to come round takes another four,
and the photocopier then needs thirty *millionths* of a second. The photocopier's
speed makes no difference at all — you are paying almost entirely for being a
mechanical arm in a big room. So a drive advertised at "one gigabit per second"
actually hands you about three and a half megabits per second.

**Example (traced).**

$$\begin{aligned}
t_{\text{rot}} &= \tfrac{1}{2}\cdot\tfrac{60}{7200}\,\text{s}
                 = \tfrac{1}{240}\,\text{s} = 4.17\,\text{ms} \\
\text{bytes}   &= 4\,\text{KB} = 4 \times 2^{10} \times 8 = 32{,}768\ \text{bits} \\
t_{\text{xfer}}&= \frac{32{,}768}{2^{30}}\,\text{s}
                 = 0.0305\,\text{ms} \\
t_{\text{total}}&= 5 + 4.17 + 0.0305 + 0.1 = 9.30\,\text{ms}
\end{aligned}$$

Effective bandwidth: $4\,\text{KB} / 9.30\,\text{ms} = 440{,}430\,\text{B/s}$, or
in bits $32{,}768 / 9.30\,\text{ms} \approx 3.5\,\text{Mb/s}$ — a factor of
$\approx 285$ below the quoted 1 Gb/s.

> [!important] The advertised transfer rate is not the bandwidth you get
> $9.3\,\text{ms}$ to move $4\,\text{KB}$ is $3.5\,\text{Mb/s}$, not
> $1\,\text{Gb/s}$. On a random workload the *mechanics*, not the interface, set
> the speed.

---

## 4. The random-versus-sequential gap

This is the single most important performance fact in the chapter.

**In plain words.** Reading a whole book from one shelf is fast — you pull it out
and copy it in one go. Reading the same amount of text by fetching one page from
each of a hundred scattered shelves is catastrophically slow, and it is slow for
the same reason every time: you must walk between the shelves. The pages are the
same, the copier is the same; only the walking changed.

**Example (traced).** 300 GB disk, 4 ms average seek, 15 000 RPM, 125 MB/s,
controller overhead ignored.

*Rotation:* $15{,}000/60 = 250$ revolutions per second, so one turn is
$1/250 = 4\,\text{ms}$ and average latency is $2\,\text{ms}$.

*Random 4 KB read:*

$$\begin{aligned}
t_{\text{access}} &= 4 + 2 = 6\,\text{ms} \\
t_{\text{xfer}}   &= \frac{4096}{125 \times 10^{6}}\,\text{s} = 32.8\,\mu\text{s}
                     \approx 0.033\,\text{ms} \\
t_{\text{total}}  &\approx 6.03\,\text{ms} \\
\text{bandwidth}  &= \frac{4\,\text{KB}}{6.03\,\text{ms}} \approx 0.68\,\text{MB/s}
\end{aligned}$$

*Sequential 100 MB file, one seek and one rotation:*

$$\begin{aligned}
t &= 4\,\text{ms} + \frac{100\,\text{MB}}{125\,\text{MB/s}} + 0.033\,\text{ms} \\
  &= 0.004 + 0.8 + 0.000033 \approx 0.80\,\text{s} \\
\text{bandwidth} &\approx 125\,\text{MB/s}
\end{aligned}$$

The gap is $125 / 0.68 \approx 184\times$.

> [!warning] This is why file layout matters
> Section 15 of this note, and all of [[chap14_file_system_implementation]],
> exist because of this $184\times$ gap. A contiguous file is sequential; a badly
> scattered one degrades to random.

---

## 5. SSD and magnetic tape

### SSD

An SSD is non-volatile memory used *as a block device*: variants run from
battery-backed DRAM through SLC and MLC flash.

**In plain words.** Flash is a filing cabinet with no aisles, no shelves and no
walking — every drawer is the same distance away. That kills the seek entirely,
so the whole scheduling chapter stops applying. The price is that the drawers wear
out after enough rewrites, and that each drawer is more expensive than shelf space.

| | HDD | SSD |
| --- | --- | --- |
| Moving parts | yes | no |
| Seek / rotational latency | ms | **none** |
| Random vs sequential | 184× gap (above) | small gap |
| Power | higher | lower |
| Cost per MB | low | higher |
| Capacity | larger | smaller |
| Lifespan | mechanical wear | limited write/erase cycles |
| Bus | disk-bound | **interface can be the bottleneck** |

Because an SSD can outrun a disk-oriented bus, high-end SSDs attach directly to
the system bus (PCIe) or are used as a **new cache tier** between memory and
magnetic disk.

![[Chapter11.pdf#page=9]]
*Figure: SSD characteristics and the bus-bottleneck problem. (`Chapter11.pdf` p. 9)*

### Magnetic tape

Relatively permanent, enormous capacity (200 GB – 1.5 TB, several TB at the high
end), and *random access roughly 1000× slower* than a disk because reaching a spot
can take minutes of winding.

**In plain words.** A tape is a cassette: to hear track 40 you have to play
through tracks 1 to 39. It is therefore useless as a working disk and perfect as a
locked archive — you write it once, put it on a shelf, and only ever read it
forwards.

Use: backup, cold data, and physically shipping data between sites.

![[Chapter11.pdf#page=10]]
*Figure: magnetic tape — permanence, capacity, and why access is slow. (`Chapter11.pdf` p. 10)*

---

## 6. Addressing: the disk as one big array

The OS never sees geometry. It sees a **one-dimensional array of logical blocks**,
each with a unique block number (the disk address). Logical block size is
classically 512 bytes; low-level formatting creates the block boundaries on the
media.

Mapping is sequential and starts at the outside:

1. block 0 = first sector of the first track of the **outermost** cylinder;
2. proceed along that track, then the other tracks in the same cylinder;
3. then cylinder by cylinder, outermost to innermost.

Two complications:

| Complication | Why | Fix |
| --- | --- | --- |
| **Defective sectors** | manufacturing defects | logical → physical map substitutes a spare sector from elsewhere; the logical number never changes |
| **Non-constant sectors per track** | constant angular velocity means the outer tracks are longer | the mapping is no longer a simple arithmetic formula |

**In plain words.** The disk tells the OS "give me block 12345" and the drive
figures out where that is — like a hotel switchboard knowing which room is 12345
without you knowing the floor plan. Occasionally a room is unusable, so the
switchboard silently re-routes the number to a spare room; you keep dialling the
same number and never find out.

**Example (traced).** With $H$ surfaces (tracks per cylinder), $S$ sectors per
track and $c_{i}$ constant: the physical address of logical block $b$ is

$$\begin{aligned}
c &= \left\lfloor \frac{b}{S \cdot H} \right\rfloor,\quad
h = \left\lfloor \frac{b}{S} \right\rfloor \bmod H,\quad
s = b \bmod S
\end{aligned}$$

For $H = 8$, $S = 500$, $b = 12345$: $c = \lfloor 12345/4000 \rfloor = 3$,
$h = \lfloor 12345/500 \rfloor \bmod 8 = 24 \bmod 8 = 0$, $s = 12345 \bmod 500 = 245$.
Check: $3 \times 4000 + 0 \times 500 + 245 = 12245$. That is short by 100, because
the block is 0-indexed inside its cylinder — the correct block is
$(3,0,345)$: $3 \times 4000 + 345 = 12345$. ✓

![[Chapter11.pdf#page=11]]
*Figure: logical block → sector mapping, and the two things that break the simple formula. (`Chapter11.pdf` p. 11)*

---

## 7. Why schedule at all

The OS owns the request queue per device. Each request records I/O mode, disk
address, memory address, and sector count. On a busy multiprogrammed system the
queue is often deep, and *that* is the only situation where reordering helps —
with one request, every algorithm behaves identically (Section 15).

Three quantities to remember:

| Quantity | Definition |
| --- | --- |
| **Seek time** | arm travel to the target cylinder, measured as a *cylinder distance* |
| **Rotational latency** | extra wait for the sector to arrive |
| **Disk bandwidth** | total bytes transferred ÷ (time from first request to completion of last transfer) |

**In plain words.** A lift that stops at every floor on the way up is faster than
one that goes to floor 40, back to 2, up to 31, down to 7 — even though it visits
the same floors. The requests do not care about their order, so the driver is free
to sort them.

**Example (traced).** The deck's running instance, used by every algorithm below:

$$\text{queue} = 98,\ 183,\ 37,\ 122,\ 14,\ 124,\ 65,\ 67
\qquad \text{head at } 53 \qquad \text{cylinders } 0\text{–}199$$

Sorted: $14,\ 37,\ 65,\ 67,\ 98,\ 122,\ 124,\ 183$.

![[Chapter11.pdf#page=13]]
*Figure: the request queue and head position used throughout the chapter. (`Chapter11.pdf` p. 13)*

---

## 8. FCFS

Service in arrival order. Intrinsically **fair**, generally **not fast**.

**In plain words.** Deal with requests in the order they arrived, like a shop with
no queue-jumping. Nobody starves, but the head dashes from one end of the disk to
the other and back because the customers asked in a random order. The travel is
almost all wasted motion between distant shelves.

**Example (traced).**

| Step | Move | Distance |
| --- | --- | --- |
| 53 → 98 | | 45 |
| 98 → 183 | | 85 |
| 183 → 37 | | 146 |
| 37 → 122 | | 85 |
| 122 → 14 | | 108 |
| 14 → 124 | | 110 |
| 124 → 65 | | 59 |
| 65 → 67 | | 2 |
| **total** | | **640** |

Average movement per request $= 640/8 = 80$ cylinders.

![[Chapter11.pdf#page=14]]
*Figure: FCFS on the running queue — total head movement 640. (`Chapter11.pdf` p. 14)*

---

## 9. SSTF — Shortest Seek Time First

Always pick the pending request **nearest the current head position**, in either
direction. This is SJF applied to seeks — greedy, and it has SJF's disease.

**In plain words.** Always grab the closest request, like a taxi that takes the
nearest fare. It is much better than arrival order, but the far-away customers can
wait forever because a stream of near customers keeps arriving, and the taxi keeps
reversing direction to serve whichever is closest right now.

**Example (traced).**

| Step | Move | Distance |
| --- | --- | --- |
| 53 → 65 | nearest of 65, 37 | 12 |
| 65 → 67 | | 2 |
| 67 → 37 | | 30 |
| 37 → 14 | | 23 |
| 14 → 98 | everything left is far | 84 |
| 98 → 122 | | 24 |
| 122 → 124 | | 2 |
| 124 → 183 | | 59 |
| **total** | | **236** |

$236 / 640 = 37\%$ of FCFS. But note the request at 183 waited until the very end
while the head fussed around 65–67; a steady supply of low-cylinder requests would
have starved it.

> [!warning] SSTF = starvation
> Greedy nearest-first is *unbounded* waiting for requests far from the head's
> current neighbourhood. SCAN exists precisely to bound it.

![[Chapter11.pdf#page=15]]
*Figure: SSTF on the running queue — total head movement 236. (`Chapter11.pdf` p. 15)*

---

## 10. SCAN — the elevator

Start at one end, sweep to the other, servicing every request passed, then
reverse and sweep back. **Direction of travel is part of the state.**

**In plain words.** A lift that goes all the way to the top, stopping on the way
up, then all the way down, stopping on the way down. Nobody can starve, because
after at most one full sweep the lift reaches your floor. The cost is that a
request just behind the lift's starting point waits almost a whole round trip —
you missed it by seconds and now must ride to the end of the building and back.

**Example (traced).** Here the head is assumed to move **toward 0 first** (the
direction must be known; the slide shows this direction).

| Step | Move | Distance |
| --- | --- | --- |
| 53 → 37 | | 16 |
| 37 → 14 | | 23 |
| 14 → 0 | hit the wall, no request | 14 |
| 0 → 65 | sweeping up, 65 is first request | 65 |
| 65 → 67 | | 2 |
| 67 → 98 | | 31 |
| 98 → 122 | | 24 |
| 122 → 124 | | 2 |
| 124 → 183 | | 59 |
| **total** | | **236** |

Starting *upward* instead gives $331$ — same requests, 40 % more travel. Hence the
slide's warning that you must know the direction.

![[Chapter11.pdf#page=16]]
*Figure: SCAN — total head movement 236 (assuming downward-first). (`Chapter11.pdf` p. 16)*

---

## 11. LOOK

SCAN, but the arm only goes as far as the **last request** in each direction
instead of all the way to the physical end. Everything else is identical.

**In plain words.** The lift checks whether anyone is above the 40th floor before
riding to the roof. If not, it turns round at 40 — no point travelling through
empty floors nobody asked for. Same fairness guarantee, less wasted motion.

**Example (traced).**

| Step | Move | Distance |
| --- | --- | --- |
| 53 → 37 | | 16 |
| 37 → 14 | last request downward, turn round here | 23 |
| 14 → 65 | | 51 |
| 65 → 67 | | 2 |
| 67 → 98 | | 31 |
| 98 → 122 | | 24 |
| 122 → 124 | | 2 |
| 124 → 183 | last request upward | 59 |
| **total** | | **208** |

SCAN cost 236 for the same queue; the 28 saved is exactly the two empty runs
$14 \to 0$ (14) and nothing else counted, plus the $0 \to 14$ return (14): LOOK
reverses at 14 instead of riding to 0 and back, saving $2 \times 14 = 28$.

![[Chapter11.pdf#page=17]]
*Figure: LOOK — total head movement 208. (`Chapter11.pdf` p. 17)*

---

## 12. C-SCAN — circular SCAN

Sweep one way, servicing as you go. At the far end, **snap back to the beginning
without servicing anything**, then sweep again. Cylinders are treated as a
circular list.

**In plain words.** A one-way lift that only ever goes up. You wait for it, ride
to your floor, and when it reaches the top it teleports empty to the basement and
starts up again. It feels unfair that it never serves you on the way down — but
that is the point: *everybody* waits roughly the same amount, instead of the
people just below the top waiting ages (as they do in SCAN).

The trade: total movement is larger, but the *spread* of waiting times is much
tighter.

**Example (traced).** Sweeping **upward** first (this is the direction that
reproduces the slide's number):

| Step | Move | Distance |
| --- | --- | --- |
| 53 → 65 | | 12 |
| 65 → 67 | | 2 |
| 67 → 98 | | 31 |
| 98 → 122 | | 24 |
| 122 → 124 | | 2 |
| 124 → 183 | | 59 |
| 183 → 199 | wall | 16 |
| 199 → 0 | **empty return, counted** | 199 |
| 0 → 14 | | 14 |
| 14 → 37 | | 23 |
| **total** | | **382** |

Sweeping downward first would give 386. Note the 199-cylinder jump is more than
half the total — C-SCAN buys uniformity by spending movement.

![[Chapter11.pdf#page=18]]
*Figure: C-SCAN — total head movement 382. (`Chapter11.pdf` p. 18)*

---

## 13. C-LOOK

C-SCAN, but reverse at the last request instead of the wall — and jump back to the
**lowest** pending request rather than to cylinder 0.

**In plain words.** The one-way lift, but it does not bother climbing to the roof
or descending to the basement; it turns at the highest floor anyone pressed and
returns to the lowest floor anyone pressed. Same uniform waiting as the circular
lift, with the empty top and bottom stretches removed.

**Example (traced).** Upward first:

| Step | Move | Distance |
| --- | --- | --- |
| 53 → 65 → 67 → 98 → 122 → 124 → 183 | servicing upward | $12{+}2{+}31{+}24{+}2{+}59 = 130$ |
| 183 → 14 | jump to the lowest request | 169 |
| 14 → 37 | servicing upward again | 23 |
| **total** | | **322** |

Downward first would give 326.

![[Chapter11.pdf#page=19]]
*Figure: C-LOOK — total head movement 322; the slide also prints "308 for LOOK". (`Chapter11.pdf` p. 19)*

> [!warning] The slide's "308 for LOOK" is a typo
> LOOK on this queue is **208** (Section 11, and the slide on p. 17 itself says
> 208). Use 208 in an exam.

---

## 14. All six side by side

| Algorithm | Head movement | Starvation | Uniformity | Direction matters? |
| --- | --- | --- | --- | --- |
| FCFS | 640 | none | n/a | no |
| SSTF | 236 | **yes** | poor | no |
| SCAN | 236 | none | poor at the far end | **yes** |
| LOOK | **208** | none | poor at the far end | **yes** |
| C-SCAN | 382 | none | **best** | yes |
| C-LOOK | 322 | none | good | yes |

> [!warning] These six numbers are not comparable without their directions
> SSTF needs no direction; SCAN and LOOK above assumed *downward first*;
> C-SCAN and C-LOOK assumed *upward first*. Change the direction and SCAN becomes
> 331, LOOK 299, C-SCAN 386, C-LOOK 326. Always state the assumption.

---

## 15. Choosing an algorithm

The deck's own comparison, reworded:

| Algorithm | Strengths | Weaknesses |
| --- | --- | --- |
| SSTF | beats FCFS, better throughput, small average seek | starvation; frequent direction changes; high *variance* in seek time |
| SCAN (elevator) | no starvation; less total movement than FCFS | complex; long seeks for the ends; cylinders just visited wait almost a full sweep (worse than C-SCAN) |
| C-SCAN (circular elevator) | good at moderate–heavy load; most uniform wait | more total seek than SCAN; the extremes still suffer |
| LOOK / C-LOOK | never worse than SCAN / C-SCAN | must find the last request in each direction (overhead) |

What else the choice depends on:

- **Queue depth.** One request ⇒ every algorithm is FCFS.
- **File allocation method.** A *contiguous* file generates requests close
  together (little movement); a *linked* or *indexed* file scatters them.
- **Placement of directories and index blocks.** A directory entry and its data on
  different cylinders cause huge movement; caching them in memory fixes it.
- **Pluggability.** Scheduling must be a separate OS module, swappable at run time.
  **Default recommendation: SSTF or LOOK.**

**In plain words.** There is no best algorithm, because the best answer depends on
how deep the queue is and where the files physically live. A shallow queue makes
all of them equal; a disk full of scattered files makes all of them bad. So the
practical advice is: pick something reasonable and make it replaceable, because
the workload will change.

![[Chapter11.pdf#page=20]]
*Figure: comparison of SSTF, SCAN, C-SCAN, LOOK, C-LOOK. (`Chapter11.pdf` p. 20)*

---

## 16. RAID part 1 — reliability through redundancy

**RAID** = Redundant Array of Independent Disks. Originally "inexpensive", the
answer to the single large expensive disk (**SLED**). Today the point is
reliability plus parallel access.

Two facts drive everything:

**Fact 1 — an array is more fragile than a disk.** With $N$ disks each of MTTF
$100{,}000$ h, *some* disk in the array fails every

$$\text{MTTF}_{\text{array}} = \frac{\text{MTTF}_{\text{disk}}}{N}
= \frac{100{,}000}{100} = 1000\,\text{h} = 41.7\ \text{days}$$

**Fact 2 — mirroring fixes it.** Duplicate every disk; every write goes to two
places. Data is lost only if the *second* disk dies while the first is still
unreplaced — i.e. during the **mean time to repair** window.

$$\text{MTTDL} = \frac{\text{MTTF}^2}{2 \cdot \text{MTTR}}
= \frac{100{,}000^2}{2 \times 10} = 5 \times 10^{8}\ \text{h}
\approx 57{,}000\ \text{years}$$

**In plain words.** If you keep a hundred light bulbs on, one of them pops every
few weeks — that is just arithmetic, not bad luck. So you hang two bulbs on every
circuit: a circuit only goes dark if the second bulb dies before you have
replaced the first. Since you replace the first within hours and bulbs last a
decade, the room goes dark essentially never.

**Example (traced).** 100 disks, MTTF $100{,}000$ h, MTTR 10 h, no redundancy.
Expect a failure every 1000 h. With a single copy of the data on striping (RAID 0),
each of those failures loses data ⇒ one data loss every 41.7 days. With mirroring,
each failure must be *followed* by another within 10 h: probability
$\approx (10/100{,}000)$ per failure, so one data loss per
$1000 / 10^{-4} = 10^{7}$ failures-worth of time — the deck's $5\times10^8$ h is
the full $\text{MTTF}^2/(2\text{MTTR})$ form.

![[Chapter11.pdf#page=22]]
*Figure: RAID redundancy — array MTTF, mirroring, mean time to repair, MTTDL. (`Chapter11.pdf` p. 22)*

---

## 17. RAID part 2 — performance through parallelism

**Data striping** across disks has two distinct goals:

| Goal | Mechanism |
| --- | --- |
| Throughput of *many small* accesses | load balancing — requests land on different arms |
| Response time of *one large* access | fan out — all arms fetch a piece at once |

**Bit-level striping.** With 8 disks, write bit $i$ of every byte to disk $i$. The
array then looks like one disk whose sectors are $8 \times$ normal size
($8 \times 512 = 4096$ bytes) and whose access rate is 8×.

**Block-level striping.** Blocks are dealt round-robin: with $n$ disks, block $i$
goes to disk $i \bmod n$.

**In plain words.** Bit-level striping is like eight people each memorising one
letter of every word you say — asking one of them for a letter is instant, but
asking for a word means asking all eight. Block-level striping is like dealing a
pack of cards face down across eight players: any single card is quick to fetch,
and a long run of cards is fetched by everybody in parallel.

**Example (traced).** 8 disks, 512-byte physical sectors. Logical sector 0
(= bytes 0..4095) has byte 0 bit 0 on disk 0, bit 1 on disk 1, … bit 7 on disk 7;
byte 1 bit 0 back on disk 0. One 4 KB read pulls 512 bytes from each arm
simultaneously ⇒ 8× the rate of one arm.

With $n = 4$ disks, block 0 → disk $0$, block 1 → disk $1$, block 2 → disk $2$,
block 3 → disk $3$, block 4 → disk $0$, and so on: a 16-block file occupies 4
blocks on each disk.

![[Chapter11.pdf#page=23]]
*Figure: bit-level and block-level striping. (`Chapter11.pdf` p. 23)*

---

## 18. RAID levels

Mirroring gives reliability at 50 % capacity cost; striping gives speed with zero
reliability. The levels combine them, adding **parity** ($P$, error-correcting
bits) instead of a second copy ($C$) to cut the cost.

| Level | Name | Mechanism | Capacity overhead | Tolerates |
| --- | --- | --- | --- | --- |
| **0** | striping | block striping, no redundancy | 0 % | nothing |
| **1** | mirroring / shadowing | every block on two disks | 50 % | any one disk per pair |
| **4** | block-interleaved parity | striping + one dedicated parity disk | $1/n$ | any one disk |
| **5** | distributed parity | striping + parity spread over all disks | $1/n$ | any one disk |
| **6** | double parity | as 5 with two independent parities | $2/n$ | any two disks |
| **1+0** | striped mirrors | mirror in pairs, then stripe the pairs | 50 % | one per pair, many total |
| **0+1** | mirrored stripes | stripe a set, then mirror the whole stripe | 50 % | one **whole stripe** loss kills it |

**1+0 versus 0+1** — the order of the operations is the whole story:

- **1+0**: drives → mirrored pairs → pairs striped. Losing one disk of one pair
  loses nothing.
- **0+1**: drives → one stripe → stripe mirrored. Losing *any one* disk destroys a
  whole stripe, and the mirror of that stripe must carry everything — a second
  failure anywhere in the other stripe loses the data.

**In plain words.** Parity is a magic trick: write seven numbers, and you can
reconstruct the eighth from the seventh plus a checksum. So instead of buying a
second copy of everything you buy one extra disk per group and can still lose any
one disk. The catch is that a checksum costs work on every write, and it only
tolerates *one* loss — which is why RAID 6 keeps two.

**Example (traced).** Four disks' worth of data, so $n = 4$ data disks plus parity.

- RAID 0: 4 data blocks, 4 disks used, 0 redundancy.
- RAID 1: 4 data blocks, 8 disks used (4 mirrored), survives loss of one per pair.
- RAID 4/5: 4 data blocks + 1 parity block, 5 disks used ⇒ 20 % overhead, survives
  one loss.
- RAID 6: 4 data + 2 parity ⇒ 33 % overhead, survives two.

For 1+0 with 8 disks: four mirror pairs, striped ⇒ 4 disks of usable capacity out
of 8, and it survives one failure in *each* pair (up to 4 failures).

![[Chapter11.pdf#page=24]]
*Figure: the RAID levels — P is parity, C is a second copy of the data. (`Chapter11.pdf` p. 24)*

![[Chapter11.pdf#page=25]]
*Figure: RAID 0+1 (stripe, then mirror) versus RAID 1+0 (mirror, then stripe). (`Chapter11.pdf` p. 25)*

---

## 19. Features above any RAID level

| Feature | What it does | Why |
| --- | --- | --- |
| **Snapshot** | a view of the file system as it was before the last update | cheap recovery: metadata-only logical copy at a point in time, not a full copy |
| **Replication** | automatic duplication of writes to a *separate site* | disaster recovery |
| — synchronous | block must be written locally **and** remotely before the write completes | consistent, slower |
| — asynchronous | writes grouped and flushed periodically | faster, may lose the tail |
| **Hot spare** | a disk that holds no data but is configured as a replacement | rebuild the mirror automatically, without waiting for a human to swap a disk |

**In plain words.** A snapshot is a bookmark in a book rather than a photocopy of
it — you can always flip back, and it costs you one slip of paper. Replication is
posting a copy of every letter to a second office so a fire cannot lose the
correspondence. A hot spare is a spare tyre already bolted to the car and inflated,
so a puncture fixes itself while you drive.

**Example (traced).** A RAID 1+0 array loses one disk at 03:00. With a hot spare the
controller starts rebuilding onto it immediately; the mirror is redundant again
after the rebuild time. Without a hot spare the array stays in the **exposed**
state — only one failure away from data loss — until an engineer arrives and
replaces the disk, which is exactly the MTTR that the $5 \times 10^8$ h MTTDL
calculation assumes is short.

![[Chapter11.pdf#page=26]]
*Figure: snapshot, replication, hot spare. (`Chapter11.pdf` p. 26)*

---

## 20. Highlights

- A disk is a stack of platters on one arm; the arm's **cylinder** position, not
  the track, is what costs time.
- Access time is $t_{\text{seek}} + t_{\text{rot}} + t_{\text{xfer}} + t_{\text{ctrl}}$, and the mechanics dominate: a "1 Gb/s" drive delivers $3.5\,\text{Mb/s}$ on random 4 KB reads.
- The random-versus-sequential gap is enormous (here $184\times$) and is the reason
  file layout, buffering and scheduling all matter.
- The disk is addressed as a flat array of **logical blocks**; defects are hidden
  by remapping, and non-constant sectors per track are the one thing that breaks
  the simple formula.
- **SSTF** is fast but starves; **SCAN** bounds waiting by sweeping wall to wall;
  **LOOK** stops at the last request; **C-SCAN** and **C-LOOK** trade movement for
  uniform waiting. Default choice: SSTF or LOOK, as a swappable module.
- An array's MTTF is the single-disk MTTF divided by the number of disks — so
  redundancy is mandatory, and $\text{MTTDL} = \text{MTTF}^2/(2\text{MTTR})$.
- **Striping** buys parallelism; **parity** buys redundancy more cheaply than
  **mirroring**; level order matters (1+0 tolerates more than 0+1).

---

## 21. Exam traps

- *"Transfer rate = bandwidth."* → Only for very large sequential transfers. For
  one random block, bandwidth $=$ block $/ (t_{\text{seek}}+t_{\text{rot}}+t_{\text{xfer}})$.
- *"Average rotational latency = one full rotation."* → **Half** a rotation
  ($60/\text{RPM}/2$). Full rotation is the worst case.
- *"SCAN always beats C-SCAN on total movement, so use SCAN."* → SCAN has less
  total movement but a much wider *spread* of waiting times; C-SCAN is chosen for
  uniformity at moderate-to-heavy load.
- *"SSTF and SCAN give the same answer."* → Only coincidence on this queue (both
  236). On an upward-first SCAN it is 331.
- *"LOOK = 308 on this queue."* → The p.19 slide has a typo; LOOK is **208**
  (p.17's own figure).
- *"C-SCAN's return trip is free."* → It is not serviced, but it **is travelled**
  and **is counted**: 199 of the 382 cylinders.
- *"RAID 0 improves reliability by spreading data."* → RAID 0 has **no**
  redundancy; it makes the array *less* reliable (one failure loses everything).
- *"RAID 5 survives two failures because there are several disks."* → RAID 5
  survives exactly **one**; two is RAID 6.
- *"RAID 1+0 and 0+1 are the same thing spelled differently."* → Losing one disk
  of a 0+1 stripe destroys the whole stripe and its mirror carries 100 % of the
  load; 1+0 only loses that disk's mirror partner's redundancy.
- *"MTTDL is per disk."* → It is per *array*, and it is quadratic in MTTF, so
  doubling disk reliability squares the array's protection.
- *"SSDs schedule like disks."* → No seek, no rotation, so FCFS/SCAN are pointless
  on flash; the bus and the write cycle limit become the constraints.
- *"Bit-level striping needs exactly 8 disks."* → Any multiple of 8, or any
  divisor of 8 (e.g. 4 disks hold bits $i$ and $4+i$).
