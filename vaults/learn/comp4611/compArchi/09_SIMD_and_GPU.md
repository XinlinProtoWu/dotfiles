# Topic 9 — SIMD, GPUs, Warps and Dynamic Warp Formation

> Source: `COMP4611L8_2026F.pdf` (Lecture 8). Exercises: [[T5_GPU_SIMD_Utilization]]. Next:
> [[10_GPU_Programming_Performance]].

## 1. Flynn's taxonomy — how many instruction/data streams?

Classify a machine by how many **instruction streams** and **data streams** it handles at once.

| Class | Instruction streams | Data streams | Idea | Example |
|---|---|---|---|---|
| **SISD** | 1 | 1 | classic scalar CPU | a single simple in-order core |
| **SIMD** | 1 | many | one control unit, many ALUs doing the same op on different data | CPU vector unit (SSE/AVX), **GPU** |
| **MIMD** | many | many | independent cores/programs | multicore CPU, cluster |
| MISD | many | 1 | practically never used | — |

![[COMP4611L8_2026F.pdf#page=4]]

*SISD: one program, one data stream, one operation at a time (p. 4).*

![[COMP4611L8_2026F.pdf#page=5]]

*SIMD: one instruction stream **broadcast** to many processing units, each with its own data (p. 5).*

![[COMP4611L8_2026F.pdf#page=6]]

*MIMD: each unit runs its own program on its own data (p. 6).*

> 💡 **Example that makes the difference obvious** — add two 8-element arrays:
> - **SISD:** 8 separate `add` instructions, 8 ALU uses.
> - **SIMD:** 1 vector `add` owning 8 lanes → still *one* instruction, one fetch, one decode.
> - **MIMD:** 8 cores each running their own loop; 8 fetches/decodes, and they may run *different*
>   code.
>
> SIMD's win is **amortised control**: fetch/decode once, compute 8×.

**The catch of SIMD:** all lanes must do the *same* operation in lock-step. If lanes need different
work, they can't all be busy → see divergence in §7.

## 2. SIMD in ordinary CPUs: vector extensions

- **SSE** (Streaming SIMD Extensions): 128-bit vector registers.
- **AVX** (Advanced Vector Extensions): 256-bit vector registers.

![[COMP4611L8_2026F.pdf#page=8]]

*One AVX add does 8 32-bit integer additions (p. 8).*

```
C[0..7] = A[0..7] + B[0..7]      // 8 adds, 1 instruction
```

> 💡 **Real-number example:** a 256-bit AVX register holds 8 `int32` (or 4 `double`). `vaddps` on
> two such registers = 8 FLOPs per instruction ⇒ potentially 8× the scalar throughput, *provided
> your data is contiguous* (which is why compilers love loops over arrays).

Vector ISAs make SIMD **explicit**: the instruction names a vector length (`VLEN`).

## 3. GPUs are SIMD engines — the hardware hierarchy

![[COMP4611L8_2026F.pdf#page=9]]

*GPU → Streaming Multiprocessor (SM) → warp → core (p. 9).*

| Level | What it is |
|---|---|
| **GPU** | the whole chip: many SMs + L2 + memory controllers |
| **SM** (Streaming Multiprocessor) | a block of cores with its own register file, L1/shared memory, warp schedulers |
| **Warp** | the **basic unit of instruction execution**: *one* instruction is issued for the whole warp |
| **Core** (Streaming Processor, SP) | one SIMD lane: executes that instruction for one thread's data |

Scale across generations (SMs × SPs): Tesla 30×8, Fermi 16×32, Kepler 15×192, Maxwell 24×128,
Pascal 56×64, Volta 80×64.

**A warp typically has 32 threads** ⇒ one instruction processes **32 data elements** at once.
NVIDIA calls this model **SIMT — Single Instruction, Multiple Threads**.

### SIMD (CPU) vs SIMT (GPU)

| | CPU SIMD | GPU SIMT |
|---|---|---|
| Programmer writes | *vector* code: `[VLD, VLD, VADD, VST]` | *scalar* code per thread: `[LD, LD, ADD, ST]` |
| Parallelism comes from | `VLEN` in the instruction | number of threads in the warp |
| Who groups work | the compiler/programmer (vectors) | **hardware** (threads → warps) |
| Per-thread state | one vector register per lane | each thread has its own registers and can branch |

![[COMP4611L8_2026F.pdf#page=12]]

*CPU SIMD: `[VLD, VLD, VADD, VST]` with an explicit `VLEN`. GPU SIMT: `[LD, LD, ADD, ST]` issued
once for `NumThreads` scalar threads (p. 12).*

> 💡 **Example:** `c[i] = a[i] + b[i]` for 32 elements.
> - **AVX:** you write `vadd` on 8-wide registers, 4 times, and must handle the tail yourself.
> - **GPU:** you write `C[tid] = A[tid] + B[tid]` once; 32 threads run it as one warp instruction.
>   Same hardware efficiency, far simpler code — but you get no say in which threads are grouped.

## 4. GPU programming in one slide

```
        Serial Code (host)
KernelA<<<nBlk, nThr>>>(args);      // device: massively parallel
        Serial Code (host)
KernelB<<<nBlk, nThr>>>(args);
```

![[COMP4611L8_2026F.pdf#page=13]]

*Host serial code alternates with device kernel launches (p. 13).*

- The programmer declares **#blocks** and **#threads per block** per kernel.
- Hardware maps **a block → one SM**, then groups the block's threads into **warps**.
- Every thread runs the *same* code but indexes different data by its **thread id**.

![[COMP4611L8_2026F.pdf#page=14]]

*N = 16 elements, 4 threads per warp → 4 warps; lane i of each warp handles element `warp·4+i` (p. 14).*

```
CPU:   for (ii = 0; ii < 100000; ++ii) C[ii] = A[ii] + B[ii];

CUDA:  __global__ void KernelFunction(...) {
         int tid = blockDim.x * blockIdx.x + threadIdx.x;   // global thread id
         C[tid] = aa[tid] + bb[tid];
       }
```

The formula `global tid = blockIdx.x * blockDim.x + threadIdx.x` is the GPU equivalent of a loop
index — 100000 threads, one per element. See [[10_GPU_Programming_Performance]] §4 for the 2-D
version.

## 5. Two independent levers for performance

The SIMT model has exactly two things to optimise:

1. **Inter-warp scheduling** — each warp has its own PC and register context, so *different* warps
   can be issued in successive cycles. This is **fine-grained multithreading (FGMT)**: hides
   latency, keeps the pipeline busy.
2. **Intra-warp SIMD utilisation** — inside a warp, all 32 lanes should be doing useful work. Branch
   divergence wastes lanes; **dynamic warp formation** fixes some of it.

![[COMP4611L8_2026F.pdf#page=17]]

*The two levers side by side (p. 17).*

## 6. Fine-grained multithreading of warps (inter-warp)

![[COMP4611L8_2026F.pdf#page=19]]

*A warp shares one PC; fetch/decode happen once for all threads (p. 19).*

### Why warps exist at all

A warp is *a set of threads that execute the same instruction on different data*. Because they
share a PC, the hardware fetches and decodes **once** per warp ⇒ control overhead is amortised over
32 threads. That is what makes cheap GPU cores (simple, in-order, no OOO logic) viable.

> 💡 **Example:** `for (i=0;i<N;i++) C[i]=A[i]+B[i]`, warp = 32 threads, 32K iterations ⇒
> **1K warps**. Warp 0 handles `i=0..31`, warp 1 `i=32..63`, … Each warp runs the same 4
> instructions (`LD, LD, ADD, ST`), so the instruction stream is 1/32 of the scalar-equivalent.

### Fine-grained multithreading

Each warp is a thread-of-execution with its **own PC and registers**. The scheduler keeps a
**ready pool** and issues from ready warps in **round-robin**:

```
cycle 1: warp 0: load
cycle 2: warp 1: load        <- warp 0's load is still in flight
cycle 3: warp 2: load
cycle 4: warp 3: load
cycle 5: warp 0: add         <- data arrived, warp 0 is ready again
...
```

If a warp blocks on a **long-latency memory access**, it is removed from the ready pool and other
warps run. When the data returns it rejoins.

![[COMP4611L8_2026F.pdf#page=23]]

*Four warps at different PCs interleaved through one pipeline (p. 23).*

![[COMP4611L8_2026F.pdf#page=24]]

*Ready pool, round-robin issue, blocked warps going to memory (p. 24).*

**Benefits:** memory latency is hidden *without* caches or OOO tricks (latency hiding by
parallelism), and fetch/decode is amortised over the whole warp.

> 💡 **Concrete comparison** ([[10_GPU_Programming_Performance]] §6): with 4 resident warps and a
> 4-cycle memory latency, the pipeline never idles; with only 2 resident warps, the same code
> leaves bubbles. More resident warps ⇒ more latency tolerance ⇒ this is why **occupancy**
> matters.

### Where the parallelism physically comes from: SIMD lanes

![[COMP4611L8_2026F.pdf#page=25]]

*32-thread warp `C[tid]=A[tid]+B[tid]` on 1 lane (8 cycles/instruction) vs 4 lanes (2 cycles) (p. 25).*

- With **1** pipelined functional unit, the 32 lanes are serialised over time (32 cycles per warp
  instruction, minus pipelining).
- With **4** units, the warp completes in 8 issue slots: **space** (more lanes) buys **time**.

![[COMP4611L8_2026F.pdf#page=26]]

*Each lane owns the registers of its threads — no cheap cross-lane access (p. 26).*

Registers are **partitioned per lane**: with 4 lanes, lane 0 holds the registers of threads
0, 4, 8, …; lane 1 holds 1, 5, 9, … A thread's registers are physically tied to its lane — this
fact is what limits warp regrouping later (§8).

## 7. Branch divergence (intra-warp)

In SIMT each thread *may* have its own control flow, but the warp has **one PC**. So divergence is
handled by **serialising the paths**:

![[COMP4611L8_2026F.pdf#page=29]]

*Threads 1 and 4 take different paths from a common PC (p. 29).*

![[COMP4611L8_2026F.pdf#page=30]]

*Timeline: path A runs with a partial mask, then path B (p. 30).*

```
if (A[i] % 3 == 0) { A[i] = A[i] * B[i]; }     // I1 test, I2 multiply
```

If 8 of 32 threads pass the test:

```
I1: 32 lanes active   (all threads evaluate the condition)
I2:  8 lanes active   (only the 8 that passed)
```

**SIMD utilisation** = fraction of issued lane-slots doing useful work:

```
U = (active lanes summed over issued instructions) / (32 × issued instructions)
  = (32 + 8) / (32 × 2) = 40/64 = 62.5%
```

> 💡 **Intuition:** the 24 lanes that skipped `I2` still *occupied* their slot for that instruction —
> they were masked off, not given other work. Wasted lanes = wasted throughput.

Two extreme cases:

- **All 32 threads take the branch** → 2 instructions × 32 lanes all useful → **100 %**.
- **No thread takes it** → the warp does not issue `I2` at all → **100 %** (1 instruction, full).

So utilisation depends on the *mask pattern*, not just on "divergence exists". Full analysis and
three exam-style problems: [[T5_GPU_SIMD_Utilization]].

## 8. Dynamic warp formation / merging

![[COMP4611L8_2026F.pdf#page=31]]

*Idea: collect active threads at the same PC from **different** waiting warps into one warp (p. 31).*

Divergence wastes lanes because each warp walks its paths separately. But two warps may both be
stuck at, say, path A with only a few active lanes. **Merge them.**

```
Warp X: path A  (some lanes active)   \
Warp Y: path A  (some lanes active)    >  one full warp at path A
Warp X: path B  (some lanes active)   \
Warp Y: path B                        >  one fuller warp at path B
Warp Z: path B                        /
```

![[COMP4611L8_2026F.pdf#page=32]]

*Baseline: warp X then warp Y each execute A, B, C, D, E, F, G — many near-empty issues (p. 32).*

![[COMP4611L8_2026F.pdf#page=33]]

*With merging, the thread counts per issue rise (e.g. `C` and `D` each need one issue) (p. 33).*

> 💡 **Worked example (4-lane pipeline, masks as bit strings, `1` = active):**
> ```
> Warp X: A 1111 → B 1110 → C 1000 / D 0110 → E 1110 → G 1111
> Warp Y: A 1111 → B 0011 → C 0010 / F 1100 → E 0011 → G 1111
> ```
> Baseline issues: A,A,B,B,C,C,D,D,E,E,F,F,G,G = **14 issues**, average lanes
> `(4+4+3+2+2+1+2+1+3+2+2+2+4+4)/14 ≈ 2.6/4`.
> Merged: A,A,B,B, **C+D (one issue, 4 lanes)**, E,E, **F (3 lanes)**, G,G = **9 issues** — the same
> work in fewer warp instructions, and fuller ones.

### Constraint that limits merging

![[COMP4611L8_2026F.pdf#page=34]]

*Registers are per-lane, so a thread cannot simply move to another lane (p. 34).*

- **Threads must keep their lane position**: a thread's registers live in its lane's register file.
  Swapping two threads between warps is fine only if they exchange *lane slots* (a register-file
  swap), never change lane.
- Hence, if two threads in the **same lane** are both active, they can never be in the same warp →
  they need separate issues.
- Merging also costs bookkeeping (masks, swapping register state) and can increase pressure on
  the register file / scheduler.

> 💡 **Same-lane conflict, concretely:** warp X has thread at lane 0 active, warp Y also has a thread
> at lane 0 active. Both want to run `I2`. They cannot occupy the same lane simultaneously ⇒ at
> least **2** `I2` issues, no matter how you regroup. That is exactly Tutorial 5, Q2.

> 💡 **When merging cannot help at all:** pattern `if (tid % 2 == 0) A else B`. The *even* threads are
> always the same lane indices in every warp, so every warp still needs 2 issues and every issue is
> half empty — see [[T5_GPU_SIMD_Utilization]] and §9 of the next note for the software fix.

## 9. Summary

| Concept | One-line definition | Why it matters |
|---|---|---|
| Flynn SISD/SIMD/MIMD | count instruction vs data streams | SIMD = one control stream, many data |
| Vector ISA (SSE/AVX) | explicit SIMD in the ISA | 128/256-bit registers, `VLEN` width |
| SM / warp / core | SM = cluster of cores; warp = 32 threads, one PC; core = one lane | instruction is issued per warp |
| SIMT | programmer writes scalar per-thread code; hardware forms warps | GPU programmability |
| FGMT of warps | round-robin issue of ready warps | hides memory latency, amortises fetch/decode |
| SIMD utilisation | active lanes / issued lane slots | measures wasted work |
| Branch divergence | warp splits and serialises paths | wastes lanes |
| Dynamic warp formation | merge same-PC threads across warps | raises utilisation, lane-position constrained |

### Exam-style checklist

- [ ] Draw/label SISD, SIMD, MIMD; place a GPU and an AVX unit.
- [ ] Explain the difference between calling a warp "SIMD" and "SIMT".
- [ ] State the hardware hierarchy and where a *block* is scheduled.
- [ ] Explain how FGMT hides latency; what happens to a warp that misses in cache?
- [ ] Compute SIMD utilisation given a mask pattern (see T5).
- [ ] Explain dynamic warp formation and the lane-position constraint in terms of the register file.
- [ ] Explain why dynamic warp formation cannot fix `tid % 2` divergence.
