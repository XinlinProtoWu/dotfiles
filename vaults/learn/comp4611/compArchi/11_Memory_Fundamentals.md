# Topic 11 — Memory Fundamentals: Arrays, DRAM/SRAM, Hierarchy

> Source: `COMP4611L10_2026F.pdf` (Lecture 10). Links back to caches in
> [[05_Pipelining_and_Hazards]] and to GPU memory in [[10_GPU_Programming_Performance]].

## 1. How can we store a bit?

Four technologies, four points on the cost/speed curve.

| Technology | Stores a bit with | Speed | Cost | Volatile? |
|---|---|---|---|---|
| **Register (flip-flop)** | ~tens of transistors, edge-triggered | fastest, parallel access | very expensive | yes |
| **SRAM** | **6 transistors** (cross-coupled inverters) | fast (~1 ns) | expensive | yes |
| **DRAM** | **1 transistor + 1 capacitor** | slower (~50–100 ns) | cheap | yes (**needs refresh**) |
| Flash / disk / tape | charge / magnetism | very slow (µs–ms) | very cheap | **non-volatile** |

> 💡 **Why not build everything from registers?** A 1 GiB register file at ~50 transistors/bit is
> ~50 G transistors — impossible to power or afford. A 1 GiB DRAM at 1T+1C per bit is a normal
> chip. The whole memory hierarchy exists because **bit cost varies by ~10⁶×**.

> 💡 **DRAM is "dynamic"** because the capacitor leaks: a stored `1` fades to `0` within
> milliseconds unless **refreshed**. It is also **destructive to read**: reading dumps the charge
> onto the bitline, so the value must be written back.

## 2. Array organisation — the basic building block

![[COMP4611L10_2026F.pdf#page=6]]

*A memory array: storage cells + address decoder + readout circuitry (p. 6).*

Every memory is a **2-D array of bit cells**, plus:

1. the **array** itself (stores the data),
2. **address selection logic** (the decoder — picks exactly one row),
3. **readout circuitry** (sense amplifiers / drivers).

An array with **N address bits** and **M data bits** has:

```
rows (depth)  = 2^N          columns (width) = M
size          = 2^N × M bits
```

Each unique N-bit address selects one row of M bits ⇒ at any time you can read/write **M bits at
one address**.

![[COMP4611L10_2026F.pdf#page=7]]

*Depth = number of rows (words), width = number of columns (word size) (p. 7).*

> 💡 **Example — a 2² × 3-bit array:** N = 2, M = 3 ⇒ **4 rows**, each 3 bits, 12 bits total.
> Address `10` (binary) selects row 2, whose contents are `100`.

![[COMP4611L10_2026F.pdf#page=8]]

*The 4×3 array of the example; row `10` holds `100` (p. 8).*

> 💡 **Sizing example:** 4 KiB of data with 1-byte words ⇒ `2^N = 4096` rows, `M = 8` ⇒ N = 12
> address bits, array = `4096 × 8`. If you instead make the word 32 bits, you need only
> `2^10 = 1024` rows of 32 bits — **deeper vs. wider** is a design choice (fewer, longer words =
> fewer decodes but more data per access).

### How a read works: wordline and bitline

![[COMP4611L10_2026F.pdf#page=10]]

*Each column is one bitline; the decoder raises exactly one wordline (p. 10).*

![[COMP4611L10_2026F.pdf#page=11]]

*Wordline `10` active ⇒ column values `1 0 0` appear on the bitlines (p. 11).*

- **Wordline** = horizontal wire per row; the address decoder asserts **exactly one**.
- **Bitline** = vertical wire per column, connecting all cells of that column.
- Cells connect to the bitline through an **access transistor** gated by the wordline.

![[COMP4611L10_2026F.pdf#page=12]]

*Access transistor + wordline/bitline for DRAM and SRAM cells (p. 12).*

> 💡 **Example:** think of a spreadsheet of light switches. The decoder is the row-selector: it
> "presses the button" for one row only, so the lamps in that row light up their column wires.
> Nothing in any other row can affect the wires — that is why one row is read at a time.

### Making arrays bigger and wider

To get more capacity *and* more bits out per access, add **column multiplexing** (select a subset of
bitlines) and **sense amplifiers/drivers**, and stack arrays: the address splits into a **row
address** (row decoder) and a **column address** (column mux).

![[COMP4611L10_2026F.pdf#page=9]]

*A larger, wider array with row decoder, column mux and I/O (p. 9).*

## 3. Why large arrays are slow → hierarchy and banking

**The problem:** a single huge array has long wordlines/bitlines (large RC delay), a huge decoder
(the address must be decoded *before* the access even starts), and can serve **only one access at a
time** ⇒ long latency, no parallelism.

**Idea:** break the memory into **smaller independently-accessible pieces** and interconnect them.

### Banking

![[COMP4611L10_2026F.pdf#page=15]]

*Banks share the address/data bus (to save chip pins) but are accessed independently (p. 15).*

- Each bank is smaller ⇒ **faster** than one monolithic array.
- Accesses to **different banks** can proceed **in parallel** ⇒ **higher bandwidth**.
- All banks **share the address and data buses** (pin count!), so bus transfers are still
  serialised — the parallelism is inside the banks, not on the bus.

> 💡 **Example:** 16 banks, and a burst of 16 requests that happen to hit 16 *different* banks →
> all 16 can start in the same cycle ⇒ effective bandwidth ≈ 16× a single bank. If instead all 16
> requests map to the **same** bank (e.g. because the address bits that choose a bank are not
> varying), they serialise ⇒ 16× slower. This is exactly why memory addresses are **interleaved**
> across banks (low-order bits select the bank).

### Hierarchical array structure (inside a real DRAM)

![[COMP4611L10_2026F.pdf#page=16]]

*Channel → Rank → DRAM die → Bank → Subarray → Mat (p. 16).*

| Level | Meaning |
|---|---|
| **Channel** | independent bus from a memory controller to one or more DIMMs |
| **Rank** | the set of chips driven together by one chip-select (one "wide" word) |
| **DRAM die** | one chip |
| **Bank** | independently activatable array inside a die |
| **Subarray** | smaller array inside a bank (short bitlines) |
| **Mat** | smallest array tile |

A row **activation** opens a row in a bank (into the row buffer); subsequent column accesses to
that same row are fast. Switching rows costs a **precharge + activate** — this is the origin of
DRAM's row-buffer locality and why "sequential access is cheap, random is expensive".

> 💡 **Example:** reading 64 B sequentially from one open row = one activate + one burst. Reading
> 64 B scattered over 64 different rows = 64 activates. Same bytes, ~50× the time.

### High Bandwidth Memory (HBM)

![[COMP4611L10_2026F.pdf#page=17]]

*Stacked DRAM dies with TSV, placed beside the processor (p. 17).*

- **3-D stacking:** multiple DRAM dies stacked vertically, connected by **TSV** (through-silicon
  vias).
- **Short, wide interconnect:** HBM sits next to the processor ⇒ thousands of short wires ⇒ high
  bandwidth at low energy/bit (vs. long PCB traces to DIMMs).

> 💡 **Rule of thumb:** bandwidth = width × frequency. HBM trades frequency for **width** (e.g.
> thousands of bits per stack instead of 64), which is why a GPU's HBM bandwidth is many times a
> CPU's DDR bandwidth.

## 4. DRAM vs SRAM: the two on-chip/off-chip technologies

![[COMP4611L10_2026F.pdf#page=19]]

*DRAM cell: one transistor + one capacitor; leaking charge = "dynamic" (p. 19).*

**DRAM (1T1C):**

- Charged capacitor = `1`, discharged = `0`.
- Read: wordline on ⇒ charge shared with bitline ⇒ **sense amplifier** detects the tiny difference ⇒
  value is **restored** (read is destructive without restore).
- Leakage ⇒ **periodic refresh**: every row must be read+rewritten within the retention time.
- `2^N` rows must all be refreshed; overhead is a few percent of bandwidth.

> 💡 **Refresh numbers:** 8192 rows per bank refreshed every 64 ms ⇒ ~128 000 refreshes/s per bank.
> At ~50 ns each, that is ~0.6 % of the time — small but not free, and it grows as DRAM scales.

![[COMP4611L10_2026F.pdf#page=20]]

*SRAM cell: two cross-coupled inverters + 2 access transistors = 6T (p. 20).*

**SRAM (6T):**

- Two inverters in a **feedback loop**: `1` at `Q` forces `0` at `Q̄`, which reinforces `Q` ⇒ the
  bit is **statically** held as long as power is on. **No refresh.**
- Both bitlines (`bitline`, `bitline_bar`) are driven for fast differential sensing.
- 6 transistors per bit ⇒ **much larger cell** ⇒ lower density, higher cost/bit.

| Property | **SRAM** | **DRAM** |
|---|---|---|
| Stored state | feedback circuit (2 inverters) | capacitor charge |
| Cell | 6 transistors | 1 transistor + 1 capacitor |
| Refresh | unnecessary | **required** |
| Read | non-destructive | destructive (needs restore) |
| Density | lower | **higher** |
| Cost per bit | higher | **lower** |
| Speed | **fast** | slower |
| Typical use | **caches, register-adjacent storage** | **main memory** |

Both are **volatile** — power off ⇒ data gone (unlike flash/disk).

> 💡 **One-line intuition:** SRAM = a light switch held by a latch (stays put, costs 6 transistors).
> DRAM = a bucket with a hole (cheap, but you must keep topping it up).

## 5. Why a hierarchy? The ideal-memory contradiction

![[COMP4611L10_2026F.pdf#page=23]]

*Metrics: capacity, access latency, bandwidth, cost/energy (p. 23).*

We *want*: infinite capacity, zero latency, infinite bandwidth, zero cost/energy. These
**conflict**:

- **Bigger is slower** — more address bits to decode, longer wires.
- **Faster is more expensive** — SRAM vs DRAM vs SSD per bit.
- **More bandwidth is more expensive** — more banks, more ports, more channels, higher frequency.

![[COMP4611L10_2026F.pdf#page=25]]

*Combine levels: small+fast on top, big+slow below (p. 25).*

**Hierarchy:** registers → L1 → L2 → L3 → DRAM → SSD/disk, each level **bigger and slower**.
If the data the processor needs is usually in a fast level, the whole memory **looks** fast *and*
big.

![[COMP4611L10_2026F.pdf#page=28]]

*The level stack and what each level holds (p. 28).*

![[COMP4611L10_2026F.pdf#page=31]]

*A modern hierarchy with the actual management mechanism at each boundary (p. 31).*

## 6. Locality — the reason hierarchy works

![[COMP4611L10_2026F.pdf#page=26]]

*Temporal and spatial locality with examples (p. 26).*

- **Temporal locality:** a program tends to reference the **same** address many times in a short
  window.
  > 💡 The instructions of a loop body: the same 5 instructions execute a million times. Keeping
  > them in the I-cache/L1 makes 999 999 of those fetches fast. Also a scalar loop variable `i`
  > that lives in a register.
- **Spatial locality:** a program tends to reference **nearby** addresses in a short window.
  > 💡 `for (i=0;i<N;i++) sum += A[i];` — consecutive 4-byte elements. One 64-byte block fetch
  > brings 16 elements, so only 1 in 16 accesses goes to the next level. Contrast with a
  > **strided** access `A[i*16]`, which uses 1 element per block (bad spatial locality).

**How a cache exploits them** (automatic hardware):

1. *Temporal* → keep recently used data in the fast level.
2. *Spatial* → divide memory into fixed-size **blocks/lines** (a range of consecutive addresses),
   and on a **miss** load the **whole block**, so the neighbours come along for free.

> 💡 **Example:** L1 line = 64 B. Accessing `A[0]` misses and loads `A[0..15]`. The next 15
> iterations then **hit**. Miss rate ≈ 1/16 for a streaming loop — even with a tiny cache.

## 7. Manual vs. automatic management

| | **Manual (scratchpad)** | **Automatic (cache)** |
|---|---|---|
| Who moves data | programmer / compiler | hardware |
| Examples | 1950s "core vs drum"; embedded on-chip SRAM; **GPU shared memory**; ML accelerators | L1/L2/L3, TLB, virtual memory |
| Pros | full control: predictable latency, no tag/associativity overhead, can guarantee residency, avoid thrashing | programmer's life is easy; works for arbitrary code; transparent |
| Cons | programmer must get tiling/DMA right; no reuse ⇒ wasted space | unpredictable timing; conflicts/thrashing; limited programmability (hardware decides) |

![[COMP4611L10_2026F.pdf#page=30]]

*Hopper SM: 256 KB per SM usable as **L1 cache or scratchpad** (p. 30).*

> 💡 **GPU example:** CUDA `__shared__` is a **scratchpad** — you explicitly load a tile, then all
> 9 Gaussian taps hit it ([[10_GPU_Programming_Performance]] §6.3). You pay with
> `__syncthreads()` and with occupancy; you gain guaranteed hits and full control of bank layout
> (§6.4), which no cache gives you.

## 8. Hierarchical latency: the AMAT formula

Each level i has a **local access time `t_i`** (hit time) and an **average access time `T_i`** that
includes misses, with miss rate `m_i` (hit rate `h_i = 1 - m_i`):

```
T_i = h_i · t_i + m_i · (t_i + T_{i+1})
    = t_i + m_i · T_{i+1}
```

Two terms: **always pay the hit time**, then **pay the next level only on a miss**.

![[COMP4611L10_2026F.pdf#page=32]]

*Definitions and the recurrence (p. 32).*

> 💡 **Worked example** (from the slides): `t1 = 4`, `t2 = 18`, `t_DRAM = 180` cycles, so
> `T2 = 18 + m2·180` and `T1 = 4 + m1·T2`.
>
> | `m1` | `m2` | `T2` (L2) | `T1` (L1) |
> |---|---|---|---|
> | 10 % | 10 % | `18 + 0.10·180 = 36` | `4 + 0.10·36 = 7.6` |
> | 1 % | 50 % | `18 + 0.50·180 = 108` | `4 + 0.01·108 = 5.08` |
>
> **Surprise:** the second row has an L2 that is **5× worse** (108 vs 36) yet a **better overall**
> `T1` (5.08 vs 7.6). Why? `m2` only applies to requests that **already missed in L1**. With
> `m1 = 1 %`, only 1 % of accesses ever see the slow L2 ⇒ `0.01 × 108 = 1.08` cycles.
>
> **Lesson:** a low L1 miss rate protects you from a slow lower level; a high L1 miss rate makes the
> L2 latency dominate everything.

![[COMP4611L10_2026F.pdf#page=33]]

*The two scenarios side by side (p. 33).*

### How to reduce `T1`

- **Lower `m_i`:** bigger capacity (but that raises `t_i`!), smarter **replacement** (anticipate what
  you *won't* need) and **prefetching** (anticipate what you *will* need).
- **Lower `T_{i+1}`:** faster lower levels (costly), or insert an **intermediate level** as a
  compromise (that is why L2/L3 exist).

> 💡 **Sanity check with numbers:** doubling L1 from 32 KB to 64 KB may cut `m1` from 5 % to 3 %, but
> raise `t1` from 4 to 5 cycles. `T1` goes `4 + 0.05·T2 → 5 + 0.03·T2`; with `T2 = 20` that is
> `5.0 → 5.6` — **worse**. Bigger is not automatically better; this is the classic cache-design
> trade-off.

## 9. Summary

| Idea | Reason |
|---|---|
| Memory = 2-D array + decoder + readout | one row (word) selected per address |
| `2^N` rows × M columns | N address bits, M-bit word |
| Banks / hierarchy | small arrays are fast; independent banks give bandwidth |
| DRAM 1T1C, refresh | cheap, dense, but leaks and reads destructively |
| SRAM 6T, no refresh | fast but big ⇒ caches only |
| Hierarchy | you cannot have fast + big + cheap in one level |
| Locality | the only reason the hierarchy works |
| `T_i = t_i + m_i·T_{i+1}` | always pay hit time, pay next level on a miss |
| Manual (scratchpad) vs automatic (cache) | control/predictability vs. programmability |

### Exam-style checklist

- [ ] Given "4 KiB, 8-bit words", state depth, width, address bits.
- [ ] Explain wordline/bitline/decoder and what "one row per access" means.
- [ ] Explain why a monolithic array is slow and how banking fixes latency **and** bandwidth.
- [ ] List the levels channel → rank → die → bank → subarray → mat.
- [ ] Contrast DRAM and SRAM cells, refresh, density, cost, use.
- [ ] Define temporal and spatial locality with a code example each.
- [ ] Compute `T1` given `t1, t2, t_DRAM, m1, m2` and explain why a bad L2 can still be fine.
- [ ] Give one pro and one con of scratchpads vs caches (use GPU SHM as the example).
