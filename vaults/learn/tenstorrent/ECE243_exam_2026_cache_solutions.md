# ECE243 Exam 2026 — Cache Memory (Q4): Full Solutions & Explanations

Question 4 has four parts (a, b, c, d). Graded scores on the copy: Q4abc = 8/13,
Q4d = 1.5/3. Notes on where marks were lost are included.

> **Note on fidelity:** this exam is a scanned PDF, so the cache-state table and
> address column had to be reconstructed from OCR. The values below are the best
> reconstruction; the method and formulas are exact. Where one bit is genuinely
> ambiguous in the scan, it is flagged.

---

## Q4(a) — Address decomposition [4 marks]

**Given:** 32-bit byte-addressable addresses, **4-way set-associative** cache,
**8-byte** lines, **2 sets** → total 2 × 4 × 8 = **64 bytes**.

Address = `[ tag ][ set index ][ block offset ]`

```
block offset bits = log₂(line size)   = log₂(8)  = 3 bits
set index bits    = log₂(#sets)       = log₂(2)  = 1 bit
tag bits          = 32 − 1 − 3        = 28 bits
```

**Answer: offset = 3 bits, set = 1 bit, tag = 28 bits.**

> Sanity check: 2 sets × 4 ways × 8 B = 64 B ✓. The three fields must sum to 32.

---

## Q4(b) — Hit/Miss for the read/write sequence [6 marks]

### Bit layout of an address

With 8-bit addresses shown (leading 0s omitted), the fields split as:

```
address[2:0]  = block offset   (byte within the 8-byte line)
address[3]    = set index      (set 0 or set 1)
address[7:4]  = tag (low 4 bits; upper 24 tag bits are 0)
```

### Reconstructed initial cache state

Set 0:

| UsedOrder | D | V | Tag | Data (byte 7 … byte 0) |
|---|---|---|---|---------------------------|
| 00 (MRU) | 0 | 1 | 0100 | 0x1234 5478 1234 5678 |
| 01       | 0 | 1 | 0101 | 0xaaaa bbbb cccc dddd |
| 11 (LRU) | 0 | 0 | 0111 | 0xabcd abcd abcd abcd ← **invalid (V=0)** |
| 10       | 1 | 1 | 1000 | 0x1111 2222 3333 4444 |

Set 1:

| UsedOrder | D | V | Tag | Data (byte 7 … byte 0) |
|---|---|---|---|---------------------------|
| 00 (MRU) | 1 | 1 | 0101 | 0xeeff efef eeff efef |
| 01       | 1 | 1 | 0001 | 0x4321 5432 6543 7654 |
| 10       | 1 | 1 | 0011 | 0x8899 aabb ccdd eeff |
| 11 (LRU) | 0 | 1 | 0111 | 0x5555 6666 7777 8888 |

> `UsedOrder`: 00 = most recently used, 11 = least recently used. On a hit the
> accessed way becomes 00 and every way that was *more* recent than it ages by 1;
> on a miss the way holding 11 is evicted.

### The sequence

| # | Address | Operation | tag / set / off | Result |
|---|---|---|---|---|
| 1 | `0b0100 0000` | read | 0100 / 0 / 0 | **HIT** — set 0 has valid tag 0100 |
| 2 | `0b0100 0100` | write 0x3456 | 0100 / 0 / 4 | **HIT** — same line; write bytes 4–7, set D=1 |
| 3 | `0b0111 0100` | read | 0111 / 0 / 4 | **MISS** — set 0 has tag 0111 but V = 0 (invalid) |
| 4 | `0b0001 0000` | read | 0001 / 0 / 0 | **MISS** — set 0 has no tag 0001 |
| 5 | `0b0011 1100` | write 0x8765 | 0011 / 1 / 4 | **HIT** — set 1 has valid tag 0011 |
| 6 | `0b1000 1000` | read | 1000 / 1 / 0 | **MISS** — set 1 has no tag 1000 |

**Answers: Hit, Hit, Miss, Miss, Hit, Miss.**

The trap is **access 3**: its tag *matches* (0111 is present in set 0) but that
line's **valid bit is 0**, so it is still a miss — a hit requires **tag match AND
V = 1**. This is exactly what the invalid line in the initial state is there to
test. Access 4 is a plain tag miss (tag 0001 absent from set 0).

---

## Q4(c) — Which main-memory blocks get updated (write-back) [3 marks]

With a **write-back** cache, main memory is written **only when a dirty line is
evicted**. Writes (accesses 2 and 5) just set the dirty bit in the cache.

Track the LRU state set by set:

**Set 0** — initial `{00:0100, 01:0101, 10:1000, 11:0111(inv)}`

```
access 1: hit tag 0100 (already MRU)      → no change
access 2: hit tag 0100, mark dirty        → no rank change
access 3: MISS tag 0111 → evict LRU = tag 0111 (V=0, D=0)
          → invalid line, NO write-back; load 0111 (clean)
          {00:0111, 01:0100(D=1), 10:0101, 11:1000(D=1)}
access 4: MISS tag 0001 → evict LRU = tag 1000 (V=1, D=1, DIRTY)
          → WRITE BACK 0x1111 2222 3333 4444 to block 0x80
```

**Set 1** — initial `{00:0101, 01:0001, 10:0011, 11:0111}`

```
access 5: hit tag 0011 (was rank 10) → 0011 becomes MRU, stays dirty
          {00:0011(D=1), 01:0101(D=1), 10:0001(D=1), 11:0111(D=0)}
access 6: MISS tag 1000 → evict LRU = tag 0111 (V=1, D=0, clean)
          → NO write-back; load 1000
```

Only one dirty line is evicted during the sequence: set 0's `tag 1000`.

| Main-memory block starting address | New data written back |
|---|---|
| `0b1000 0000` (= 0x80) | 0x1111 2222 3333 4444 |

(Remaining rows blank — only one block is updated.)

**Block address check:** tag 1000, set 0, offset 000 → `1000_0_000` = 0x80.

> **Grader note "Part c all incorrect":** the submitted answer listed the *write
> data values* (0x3456, 0x8765, …). That is write-**through** behaviour. In a
> **write-back** cache a write does **not** touch memory — it dirties the line,
> and the whole 8-byte line is written back only if/when that line is evicted.
>
> Note the answer is independent of the two hard-to-read UsedOrder bits: set 0
> holds one dirty line (tag 1000) and one invalid line (tag 0111), and accesses
> 3 and 4 evict them *both* — so the dirty line is written back either way.

---

## Q4(d) — Miss rate of the C code [3 marks]

```c
#define N 512
int a[N];                 // 512 × 4 B = 2048 B
int sum = 0;
for (int i = 0; i < N; i++)        sum += a[i];
int sum_square = 0;
for (int i = 0; i < N; i++)        sum_square += a[i] * a[i];
```

Direct-mapped cache, **64 B lines**, **1024 B** capacity. Only `a[]` accesses.

### Step 1 — geometry

```
elements per line = 64 B / 4 B = 16 ints
a[] total lines   = 2048 B / 64 B = 32 lines
cache lines       = 1024 B / 64 B = 16 lines
```

Direct-mapped: line number `L` goes into slot `L mod 16`. The array (32 lines)
is exactly **2× the cache**, so lines 0–15 and lines 16–31 alias onto the same
16 slots.

### Step 2 — loop 1 (cold)

Sequential scan a[0]…a[511]: each line is touched once with 16 accesses
(1 miss + 15 hits). 32 compulsory misses in 512 accesses:

```
miss rate loop 1 = 32 / 512 = 1/16 = 6.25%
```

At the end of loop 1 the cache holds **lines 16–31** (the second half evicted
the first half).

### Step 3 — loop 2 (the part that loses marks)

Loop 2 re-reads a[0]…a[511] from the start:

- a[0] is line 0 → slot 0 currently holds line 16 → **miss** (evict line 16).
- Same story for every line: lines 0–15 all miss (evicting 16–31), and then
  lines 16–31 all miss again (evicting 0–15).

So loop 2 is **also 32 misses / 512 accesses = 6.25%** — the array is 2× the
cache size, so *nothing survives from the first loop*.

### Answer

```
total miss rate = (32 + 32) / (512 + 512) = 64 / 1024 = 1/16 = 6.25%
```

> **Grader notes:** "incorrect number of elements per line" (−0.5): the line
> holds **16** ints (64/4), not 8 or 32. "missing/incorrect second loop
> calculation" (−1): the second loop is **not** free — every line misses again
> because the two halves of the array keep evicting each other in a direct-mapped
> cache that is exactly half the array size. A common wrong answer was 3.125%
> (counting loop 2 as all hits).
>
> **Takeaway:** sequential access → miss rate ≈ 1 block per line = `1 / (line
> size / element size)`. But reuse only helps if the working set *fits*; at 2×
> capacity in a direct-mapped cache, the second pass re-misses every line.

---

## Summary

| Part | Answer | Key concept |
|---|---|---|
| (a) | offset 3, set 1, tag 28 bits | `size = 2^offset × 2^index` |
| (b) | Hit, Hit, Miss, Miss, Hit, Miss | hit = tag match **and** V=1 (access 3 = valid-bit trap) |
| (c) | one block: 0x80 ← 0x1111 2222 3333 4444 | write-back: memory only on dirty eviction |
| (d) | 6.25% | 2× capacity → second loop re-misses everything |
