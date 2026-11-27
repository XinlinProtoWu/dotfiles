# COMP 3511 — Homework 4 Solutions

> Sources: `Chapter9.pdf` (main memory), `Chapter10.pdf` (virtual memory),
> `chap11_mass_storage.md`, `chap13_file_system_interface.md`,
> `chap14_file_system_implementation.md`, `chap17_protection.md`.
>
> Conventions used throughout: 1 KB = 2^10 B, 1 MB = 2^20 B, 1 GB = 2^30 B.

---

## 1. Multiple Choices

| MC1 | MC2 | MC3 | MC4 | MC5 | MC6 | MC7 | MC8 | MC9 | MC10 |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|------|
| C   | B   | B   | D   | C   | D   | A   | A   | D   | A    |

**Brief justifications**

1. **C** — Logical address 3500 ≥ limit register 3200, so the reference is out of range; the hardware traps to the OS with an addressing error.
2. **B** — First-fit takes the first hole that fits (600 KB, since 300 < 340). Best-fit takes the smallest hole that fits (350 KB). Worst-fit takes the largest hole (750 KB).
3. **B** — 51,350 B needs ⌈51350/4096⌉ = 13 pages = 53,248 B; internal fragmentation = 53,248 − 51,350 = **1,898 B**.
4. **D** — With copy-on-write, only the written page is copied; the child modifies its own copy and the parent keeps the original.
5. **C** — FIFO can exhibit Belady's anomaly: more frames can cause more page faults.
6. **D** — TLB reach = TLB size × page size = 128 × 8 KB = 1024 KB = **1 MB**.
7. **A** — RAID 5 on 6 × 2 TB disks: 5 usable data disks = **10 TB**. RAID 1+0: 3 mirrored pairs striped = **6 TB**.
8. **A** — SSTF always serves the nearest request, so a distant request can starve indefinitely if near requests keep arriving.
9. **D** — `chmod 754` = owner `rwx`, group `r-x`, other `r--`. Bob is in group `staff` (not owner), so he gets the group triple `r-x`: execute is allowed, write is not.
10. **A** — The current file-position pointer (offset) is per process, held in the per-process open-file table.

---

## 2. Main Memory

### 2.1 Paging and address translation

Page size = 2 KB = 2^11 B ⇒ **offset = 11 bits**.
Logical addresses are 15 bits ⇒ **page number = 15 − 11 = 4 bits**.

**(a)**

- Page-number bits: **4**
- Page-offset bits: **11**
- Complete page table entries: 2^4 = **16 entries**

**(b)**

| Logical address | Page number | Offset | Physical address / result |
|-----------------|-------------|--------|---------------------------|
| 0x0A3C | 1 | 0x23C (572) | **0x4A3C** (19004) — page 1 → frame 9 |
| 0x1F00 | 3 | 0x700 (1792) | **0x1700** (5888) — page 3 → frame 2 |
| 0x2C15 | 5 | 0x415 (1045) | **0x415** (1045) — page 5 → frame 0 |
| 0x3456 | 6 | 0x456 (1110) | **Invalid reference → trap to the OS** — page 6 is marked `i` |

Translation rule: physical address = (frame number × 2048) + offset.

- 0x0A3C: page 1, offset 572 → 9 × 2048 + 572 = 19004 = 0x4A3C
- 0x1F00: page 3, offset 1792 → 2 × 2048 + 1792 = 5888 = 0x1700
- 0x2C15: page 5, offset 1045 → 0 × 2048 + 1045 = 1045 = 0x415
- 0x3456: page 6 is invalid (`i`), so the MMU traps to the operating system.

---

### 2.2 Two-level paging and the TLB

**(a) Field split**

- Page size 8 KB = 2^13 ⇒ offset `d` = **13 bits**.
- PTE = 4 bytes; each inner page table fits one 8 KB frame ⇒ 8192 / 4 = 2048 = 2^11 entries ⇒ inner page number `p2` = **11 bits**.
- Remaining outer page number `p1` = 32 − 13 − 11 = **8 bits**.

```
   p1 (8 bits)       p2 (11 bits)        d (13 bits)
```

**(b) Page-table memory**

- One inner page table covers 2048 × 8 KB = 16 MB of logical address space.
- 64 MB code/data (starting at 0): 64 MB / 16 MB = **4 inner tables**.
- 8 MB stack ending at 0xFFFFFFFF: 8 MB = 1024 pages < 2048 pages, so it fits in **1 inner table**.
- Total inner tables = 4 + 1 = **5**; plus **1** outer table = **6 page tables**.

Each table occupies one whole 8 KB frame:

```
page-table memory = 6 × 8 KB = 48 KB
```

Single-level page table covering the whole 32-bit space:

```
entries = 2^32 / 2^13 = 2^19
size    = 2^19 × 4 B = 2^21 B = 2 MB
```

**(c) Effective access time**

- TLB hit: 5 ns lookup + 100 ns memory = **105 ns**
- TLB miss: 5 ns lookup + 2 × 100 ns (both page-table levels) + 100 ns data = **305 ns**

**(i)** At 95% hit ratio:

```
EAT = 0.95 × 105 + 0.05 × 305 = 99.75 + 15.25 = 115 ns
```

**(ii)** Minimum hit ratio α for EAT ≤ 110 ns:

```
EAT = α × 105 + (1 − α) × 305 = 305 − 200α ≤ 110
200α ≥ 195
α ≥ 0.975 = 97.5%
```

Minimum hit ratio = **97.5%**.

---

## 3. Virtual Memory

### 3.1 Page-replacement algorithms

Reference string: `7, 6, 4, 1, 7, 1, 4, 2, 4, 1, 3, 2, 7, 0, 4, 2`
Three frames, initially empty.

**(a) FIFO**

| Reference | 7 | 6 | 4 | 1 | 7 | 1 | 4 | 2 | 4 | 1 | 3 | 2 | 7 | 0 | 4 | 2 |
|-----------|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Frame 1 | 7 | 7 | 7 | 1 | 1 | 1 | 1 | 1 | 4 | 4 | 4 | 2 | 2 | 2 | 4 | 4 |
| Frame 2 | – | 6 | 6 | 6 | 7 | 7 | 7 | 7 | 7 | 1 | 1 | 1 | 7 | 7 | 7 | 2 |
| Frame 3 | – | – | 4 | 4 | 4 | 4 | 4 | 2 | 2 | 2 | 3 | 3 | 3 | 0 | 0 | 0 |
| Page fault | PF | PF | PF | PF | PF | | | PF | PF | PF | PF | PF | PF | PF | PF | PF |

Total page faults: **14**

**(b) LRU**

| Reference | 7 | 6 | 4 | 1 | 7 | 1 | 4 | 2 | 4 | 1 | 3 | 2 | 7 | 0 | 4 | 2 |
|-----------|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Frame 1 | 7 | 7 | 7 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 7 | 7 | 7 | 2 |
| Frame 2 | – | 6 | 6 | 6 | 7 | 7 | 7 | 2 | 2 | 2 | 3 | 3 | 3 | 0 | 0 | 0 |
| Frame 3 | – | – | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 2 | 2 | 2 | 4 | 4 |
| Page fault | PF | PF | PF | PF | PF | | | PF | | | PF | PF | PF | PF | PF | PF |

Total page faults: **12**

**(c) Optimal (OPT)**

| Reference | 7 | 6 | 4 | 1 | 7 | 1 | 4 | 2 | 4 | 1 | 3 | 2 | 7 | 0 | 4 | 2 |
|-----------|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Frame 1 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |
| Frame 2 | – | 6 | 6 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 3 | 3 | 7 | 0 | 0 | 0 |
| Frame 3 | – | – | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| Page fault | PF | PF | PF | PF | | | | PF | | | PF | | PF | PF | | |

Total page faults: **8**

---

### 3.2 Effective access time with demand paging

Memory access = 150 ns.

Expected page-fault service time:

```
t_pf = 0.7 × 10 ms + 0.3 × 22 ms = 13.6 ms = 13,600,000 ns
```

**(a)** Page-fault rate p = 1 / 500,000:

```
EAT = (1 − p) × 150 + p × 13,600,000
    = 150 + (1/500,000) × 13,599,850
    = 150 + 27.2
    ≈ 177 ns
```

**(b)** Largest p with EAT ≤ 165 ns:

```
150 + p × 13,599,850 ≤ 165
p × 13,599,850 ≤ 15
p ≤ 15 / 13,599,850 = 1.10 × 10⁻⁶
```

Largest page-fault rate = **1.10 × 10⁻⁶** (about one fault per 907,000 accesses).

---

### 3.3 Working sets and thrashing

Window Δ = 4, so the working set at time t is the set of pages referenced at times
t − 3 … t.

**(a)**

- Working set at t = 7: times 4, 5, 6, 7 → pages 1, 5, 2, 6 ⇒ **{1, 2, 5, 6}**
- Working set at t = 10: times 7, 8, 9, 10 → pages 6, 5, 3, 5 ⇒ **{3, 5, 6}**
- Working-set size at t = 10: **3**

**(b)**

Total demand D = 4 + 6 + 5 = **15 frames**, but the system has m = **14 frames**.

Since D > m (15 > 14), **thrashing is expected**. The working-set model prescribes
that the OS **suspend (swap out) one of the processes** to reduce total demand
below the available frames.

---

## 4. Mass-Storage Systems

### 4.1 Disk access time

Given: average seek 5 ms, 6000 RPM, transfer rate 200 MB/s, controller overhead
0.2 ms, 512 KB random read.

```
one rotation  = 60 / 6000 = 0.010 s = 10 ms
avg latency   = 10 / 2 = 5 ms
transfer      = 512 KB / 200 MB/s = 0.5 MB / 200 MB/s = 0.0025 s = 2.5 ms
```

**(a)** Average I/O time:

```
t = seek + latency + transfer + controller
  = 5 + 5 + 2.5 + 0.2 = 12.7 ms
```

**(b)** Effective bandwidth:

```
0.5 MB / 12.7 ms = 0.5 / 0.0127 ≈ 39.4 MB/s
```

---

### 4.2 Disk-scheduling algorithms

Cylinders 0–1999, head at 1043, moving toward 0 (previous request was 1210).
Queue: `1470, 912, 1801, 133, 1288, 607, 1095, 1956, 480, 54`.

**FCFS**

| Move | Distance |
|------|----------|
| 1043 → 1470 | 427 |
| 1470 → 912 | 558 |
| 912 → 1801 | 889 |
| 1801 → 133 | 1668 |
| 133 → 1288 | 1155 |
| 1288 → 607 | 681 |
| 607 → 1095 | 488 |
| 1095 → 1956 | 861 |
| 1956 → 480 | 1476 |
| 480 → 54 | 426 |

Order: 1043 → 1470 → 912 → 1801 → 133 → 1288 → 607 → 1095 → 1956 → 480 → 54
Total seek distance: **8629**

**SSTF**

| Move | Distance |
|------|----------|
| 1043 → 1095 | 52 |
| 1095 → 912 | 183 |
| 912 → 607 | 305 |
| 607 → 480 | 127 |
| 480 → 133 | 347 |
| 133 → 54 | 79 |
| 54 → 1288 | 1234 |
| 1288 → 1470 | 182 |
| 1470 → 1801 | 331 |
| 1801 → 1956 | 155 |

Order: 1043 → 1095 → 912 → 607 → 480 → 133 → 54 → 1288 → 1470 → 1801 → 1956
Total seek distance: **2995**

**SCAN** (moving toward 0, continue to 0, then reverse, stop at highest request)

| Move | Distance |
|------|----------|
| 1043 → 912 | 131 |
| 912 → 607 | 305 |
| 607 → 480 | 127 |
| 480 → 133 | 347 |
| 133 → 54 | 79 |
| 54 → (0) | 54 |
| 0 → 1095 | 1095 |
| 1095 → 1288 | 193 |
| 1288 → 1470 | 182 |
| 1470 → 1801 | 331 |
| 1801 → 1956 | 155 |

Order: 1043 → 912 → 607 → 480 → 133 → 54 → (0) → 1095 → 1288 → 1470 → 1801 → 1956
Total seek distance: **2999**

**C-LOOK** (serving only toward 0, then return to highest, continue toward 0)

| Move | Distance |
|------|----------|
| 1043 → 912 | 131 |
| 912 → 607 | 305 |
| 607 → 480 | 127 |
| 480 → 133 | 347 |
| 133 → 54 | 79 |
| 54 → 1956 (return) | 1902 |
| 1956 → 1801 | 155 |
| 1801 → 1470 | 331 |
| 1470 → 1288 | 182 |
| 1288 → 1095 | 193 |

Order: 1043 → 912 → 607 → 480 → 133 → 54 → 1956 → 1801 → 1470 → 1288 → 1095
Total seek distance: **3752**

Summary:

| Algorithm | Total seek distance |
|-----------|--------------------|
| FCFS | 8629 |
| SSTF | 2995 |
| SCAN | 2999 |
| C-LOOK | 3752 |

---

## 5. File Systems

### 5.1 Combined indexed allocation

Block size = 2 KB = 2048 B, pointer = 4 B ⇒ pointers per block = 2048 / 4 = **512**.

**(a) Maximum file size**

| Level | Blocks reachable | Bytes |
|-------|------------------|-------|
| Direct (10) | 10 | 20 KB |
| Single indirect (512) | 512 | 1 MB |
| Double indirect (512²) | 262,144 | 512 MB |
| Triple indirect (512³) | 134,217,728 | 256 GB |

```
total blocks = 10 + 512 + 512² + 512³ = 134,480,394
total bytes  = 134,480,394 × 2048 = 275,415,846,912 bytes
             ≈ 256.50 GB
```

Maximum file size = **275,415,846,912 bytes ≈ 256.50 GB**.

**(b) Offset → pointer and disk reads**

Direct covers offsets 0–20,479 (first 10 blocks); single indirect covers up to
1,070,591; double indirect covers up to 537,939,967.

| Offset | Pointer | Disk reads (incl. data) |
|--------|---------|-------------------------|
| 15,000 | direct | **1** (data block only) |
| 1,000,000 | single indirect | **2** (index block + data block) |
| 600,000,000 | triple indirect | **4** (triple + double + single index blocks + data block) |

**(c) File of 5,263,360 bytes (5 MB + 20 KB)**

```
data blocks = 5,263,360 / 2048 = 2570 data blocks (exact)
```

- Direct pointers cover the first 10 data blocks → 0 index blocks.
- Single indirect pointer covers the next 512 data blocks → 1 index block.
- Remaining 2570 − 10 − 512 = 2048 data blocks go through the double indirect
  pointer → 1 double-indirect block + 2048/512 = 4 single-indirect blocks.

```
data blocks  = 2570
index blocks = 1 + 1 + 4 = 6
```

---

### 5.2 File-allocation table (FAT)

`report.txt` starts at block 12.

**(a) Blocks in order**

```
FAT[12] = 27 → FAT[27] = 5 → FAT[5] = 33 → FAT[33] = 18 → FAT[18] = EOF
```

Blocks of `report.txt`: **12, 27, 5, 33, 18**

**(b) Growth by one block**

Free blocks (entry 0): 9, 15, 21, 22, 30, 31, 36, 37. Lowest free block = **9**.

- `FAT[18]` changes from `EOF` to `9` (old last block now points to the new block).
- `FAT[9]` changes from `0` to `EOF` (new last block).

**(c) Reading the 4th block**

File blocks in order: 12 (1st), 27 (2nd), 5 (3rd), 33 (4th), 18 (5th). The 4th
block is **33**.

- **FAT cached in memory:** walk 12 → 27 → 5 → 33 in memory, then read block 33.
  Disk reads = **1**.
- **Plain linked allocation:** each data block holds the next pointer, so blocks
  12, 27, and 5 must be read from disk to follow the chain before reading 33.
  Disk reads = **4**.

---

### 5.3 Free-space management

Bit vector (bit i = 1 ⇒ free), bits 0–31 left to right:

```
0000 1111 0001 1100 0000 0011 1111 0100
```

Indexed by nibble:

| Bits | 0–3 | 4–7 | 8–11 | 12–15 | 16–19 | 20–23 | 24–27 | 28–31 |
|------|-----|-----|------|-------|-------|-------|-------|-------|
| Value | 0000 | 1111 | 0001 | 1100 | 0000 | 0011 | 1111 | 0100 |

**(a)** First free block: the lowest index with bit = 1 is **block 4**.

**(b)** Counting method — runs of consecutive free blocks:

```
(4, 4), (11, 1), (12, 2), (22, 2), (24, 4), (29, 1)
```

Explanation of the runs:

- blocks 4–7: four free
- block 11: one free
- blocks 12–13: two free
- blocks 22–23: two free
- blocks 24–27: four free
- block 29: one free
