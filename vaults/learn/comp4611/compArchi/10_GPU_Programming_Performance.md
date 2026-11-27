# Topic 10 — GPU Programming Model & Performance

> Source: `COMP4611L9_2026F.pdf` (Lecture 9). Prerequisite: [[09_SIMD_and_GPU]]. Exercises:
> [[T5_GPU_SIMD_Utilization]].

## 1. Why GPUs, and what they cost

GPUs are attractive because many workloads are **inherently parallel over data**:

- matrix / linear algebra,
- image and video processing,
- deep neural networks (mostly big matrix multiplies).

Nothing is free, though:

- a **new programming model** (SIMT) and new algorithms (data-parallel thinking, tiling,
  reductions),
- **data movement**: kernels are fast, but the CPU↔GPU link is not.

### CPU vs GPU design philosophy

![[COMP4611L9_2026F.pdf#page=4]]

*CPU: a few big out-of-order cores. GPU: many small in-order FGMT cores (p. 4).*

| | CPU | GPU |
|---|---|---|
| Cores | few (4–16), powerful | thousands of lanes |
| Per-core machinery | OoO, branch prediction, deep caches | in-order, many warps to hide latency |
| Optimised for | **latency** of a single thread | **throughput** of many threads |
| Control | fine-grained | amortised over 32-thread warps |

> 💡 **Analogy:** a CPU is a sports car — one passenger arrives fast. A GPU is a bus fleet — each
> bus is slower, but thousands of passengers move per hour. Use the bus when everyone goes the same
> way (data-parallel); use the car for a single twisty trip (branchy scalar code).

### The three steps of GPU computing

![[COMP4611L9_2026F.pdf#page=5]]

*(1) host→device copy, (2) kernel execution, (3) device→host copy (p. 5).*

Two **bottlenecks** dominate: **global-memory (HBM) access** and **CPU–GPU transfers**, limited by
PCIe/NVLink and by DRAM/HBM bandwidth. Everything in §5–§9 is about those two.

## 2. The CUDA object model

![[COMP4611L9_2026F.pdf#page=7]]

*Grid → blocks → warps → threads (p. 7).*

| Term | Definition |
|---|---|
| **Kernel** | a function executed on the GPU by many threads in parallel |
| **Grid** | all thread blocks created by one kernel launch |
| **Block** | a group of threads **assigned to one SM**; can synchronise internally |
| **Warp** | the minimum independently schedulable group, typically **32 threads** |
| **Thread** | one execution instance, mapped to a lane |

Nothing in CUDA says "warp": you choose blocks and threads per block; **the hardware** cuts each
block into warps of 32 consecutive thread IDs.

## 3. Synchronisation — three levels, one missing

| Level | Mechanism | Scope |
|---|---|---|
| **Block** | `__syncthreads()` | barrier: wait until all threads of *this block* arrive |
| **Grid** | *none inside a kernel* — split work into **separate kernels** | a kernel's completion is the barrier |
| **Host↔device** | `cudaDeviceSynchronize()` (or an implicit sync in `cudaMemcpy`) | CPU waits for queued device work |

**Why is there no grid-wide barrier?**

![[COMP4611L9_2026F.pdf#page=9]]

*Blocks may be scheduled in any order and at any concurrency (p. 9).*

Hardware schedules blocks in **any order** and with **any degree of concurrency** — a block may not
start until another *finishes*. So a barrier that makes block 0 wait for block 7 **can deadlock**:
if all SMs are full of blocks waiting for a not-yet-scheduled block, nothing progresses. This is a
hardware guarantee, not a software limitation. Rule: **independent blocks, barriers only inside a
block.**

Also note: **a kernel launch is asynchronous** — `kernel<<<...>>>(...)` returns as soon as the launch
succeeds, not when computation finishes.

```
start_timer();
kernel<<<blocks, threads>>>(args);
cudaDeviceSynchronize();      // needed to time it correctly
stop_timer();
```

> 💡 **`__syncthreads()` example** — load a tile to shared memory then read a neighbour:
> ```
> __global__ void kernel(float *input){
>     __shared__ float tile[256];
>     int tid = threadIdx.x;
>     tile[tid] = input[blockIdx.x*blockDim.x + tid];
>     __syncthreads();                       // without this, thread 5 may read
>     float neighbor = tile[(tid+1)%blockDim.x];  // tile[6] before thread 6 wrote it
> }
> ```
> Without the barrier the read is a **race** — cheap to write, expensive to debug.

## 4. Program skeleton and thread indexing

Standard host code:

```
main() {
  1) cudaMalloc(&d_in, bytes);              // allocate on device
  2) cudaMemcpy(d_in, h_in, ..., H2D);      // copy in
  3) set #blocks, #threads
  4) kernel<<<blocks, threads>>>(args...);  // launch
  5) cudaMemcpy(h_out, d_out, ..., D2H);    // copy out
  6) cudaFree(d_in);
}
```

Steps 2–5 **repeat as needed**. `cudaMemcpy` waits for previously launched kernels before copying,
so no explicit sync is needed in this pattern.

### 1-D indexing

```
global_id = blockIdx.x * blockDim.x + threadIdx.x
```

- `blockDim.x` = threads per block
- `blockIdx.x` = which block in the grid
- `threadIdx.x` = thread within the block

> 💡 **Example:** block size 4. Pixel 25 (0-based) is handled by block `6`, thread `1`:
> `6*4 + 1 = 25`.

![[COMP4611L9_2026F.pdf#page=16]]

*Block 0 (4 threads) covers the first four pixels of a flattened image (p. 16).*

### Row-major 2-D layout

For an image `height × width`, element `Image[j][i]` lives at `Image_Array[j*width + i]`.
**Stride = width** — remember this, coalescing (§6) depends on it.

![[COMP4611L9_2026F.pdf#page=14]]

*Image coordinates: row j, column i (p. 14).*

![[COMP4611L9_2026F.pdf#page=15]]

*Row-major flattening: `Image[1][2] → Image_Array[1*8 + 2]` (p. 15).*

### 2-D blocks / 2-D grids

A block can be `blockDim.x × blockDim.y` threads; a grid `gridDim.x × gridDim.y` blocks.

```
row = blockIdx.y * blockDim.y + threadIdx.y      // global row of this thread
col = blockIdx.x * blockDim.x + threadIdx.x      // global col of this thread
```

![[COMP4611L9_2026F.pdf#page=18]]

*Thread (1,0) of block (2,1) in a 2×2 block / 2-D grid (p. 18).*

> 💡 **Worked index:** thread `(1,0)` in block `(2,1)` with `blockDim = (2,2)`:
> `row = 1*2 + 0 = 2`, `col = 2*2 + 1 = 5` → it handles `Image[2][5]`.

![[COMP4611L9_2026F.pdf#page=19]]

*Same computation laid out on the image (p. 19).*

## 5. GPU memory hierarchy

![[COMP4611L9_2026F.pdf#page=12]]

*Per-SM storage: registers, L1 cache / shared memory, read-only cache (p. 12).*

![[COMP4611L9_2026F.pdf#page=13]]

*L2 shared by all SMs; global memory is off-chip DRAM (HBM2 on A100) (p. 13).*

| Level | Size / owner | Managed by | Latency |
|---|---|---|---|
| Registers | per thread, per lane | compiler | ~1 cycle |
| **Shared memory (SHM)** | per SM, per **block** | **programmer** | ~20–30 cycles |
| **L1 cache** | per SM | **hardware** | ~30 cycles |
| **L2 cache** | shared by all SMs | hardware | ~200 cycles |
| **Global memory (HBM)** | GBs, off-chip | hardware (coalescing) | ~400–800 cycles |

Key facts:

- L1 and shared memory often share **one unified on-chip SRAM**, split by a configurable boundary.
- L1 is **automatic** (allocate/evict by hardware); SHM is **explicit** — you allocate it, so it
  stays resident for the block's lifetime and you control layout (tiling, padding).
- Capacity grows and speed drops as you go down. This is the same trade-off as the CPU hierarchy
  ([[11_Memory_Fundamentals]] §10).

## 6. Performance considerations — the checklist

Main bottlenecks: **global memory accesses** and **CPU–GPU transfers**. Five memory techniques plus
two structural ones:

| Technique | Fixes | One-line recipe |
|---|---|---|
| **Latency hiding** | long memory latency | keep enough **resident warps** (high occupancy) |
| **Memory coalescing** | too many memory transactions | adjacent threads → adjacent addresses |
| **Data reuse (SHM tiling)** | repeated global loads | load a tile once into SHM, compute from SHM |
| **Bank-conflict avoidance** | SHM serialisation | avoid strides ≡ 0 mod 32; pad or hash |
| **Atomic-conflict reduction** | serialised updates | privatise (per-block sub-results) |
| **Overlapped transfer** | idle link / idle GPU | streams: copy chunk k+1 while computing chunk k |
| **SIMD utilisation** | wasted lanes | avoid intra-warp divergence; remap threads |

### 6.1 Latency hiding and SM occupancy

FGMT hides latency: when a warp stalls on a long-latency access, the scheduler issues from another
ready warp. **More resident warps ⇒ more tolerance.**

![[COMP4611L9_2026F.pdf#page=23]]

*4 active warps keep the pipeline full; 2 warps leave bubbles (p. 23).*

```
SM occupancy = resident warps on the SM / max warps the SM supports
```

Limits (typical): max **64 warps/SM**, max **32 blocks/SM**, register file **256 KB**, shared
memory **64 KB**. **The first resource to run out sets the occupancy.**

> 💡 **Worked example:** block = 256 threads, 30 KB shared memory per block, SM has 64 KB SHM.
> 1. SHM allows `floor(64/30) = 2` blocks.
> 2. Warps per block = `256/32 = 8` → 2 blocks = **16 warps**.
> 3. Occupancy = `16/64 = 25 %`.
>
> Now halve SHM per block to 16 KB → 4 blocks → 32 warps → **50 %**. Same code, twice the latency
> tolerance — this is why "reduce shared memory per block" is a standard tuning step.

### 6.2 Memory coalescing

Global memory is fetched in **cache lines** (e.g. 128 B). A warp's 32 loads are merged into as few
transactions as possible **only if the addresses are close**.

> 💡 **Uncoalesced example** (each thread walks *down a column* of a row-major matrix):
> ```
> Thread 0: M0,0 M1,0 M2,0 M3,0
> Thread 1: M0,1 M1,1 ...
> ```
> In time period 1 threads read `M0,0 M1,0 M2,0 M3,0` — the same *column*: these are `width`
> apart in memory ⇒ up to **4 separate cache lines** per warp instruction (p. 26).

![[COMP4611L9_2026F.pdf#page=26]]

*Uncoalesced: threads' addresses are far apart (p. 26).*

> 💡 **Coalesced version** (swap loops so each thread walks *across a row*):
> time period 1 reads `M0,0 M0,1 M0,2 M0,3` — **contiguous** ⇒ **1 cache line**.

![[COMP4611L9_2026F.pdf#page=29]]

*Coalesced: one transaction serves the whole warp (p. 29).*

**Rule:** make `threadIdx.x` map to the **fastest-varying** array index. Peak bandwidth is reached
when all 32 lanes fall inside one cache line.

### 6.3 Data reuse through shared memory (tiling)

> 💡 **Gaussian 3×3 filter:** each output pixel is a weighted sum of its 3×3 neighbourhood.
> ```
> sum = 0;
> for (i=0;i<3;i++) for (j=0;j<3;j++)
>     sum += gauss[i][j] * Image[(row+i-1)*width + (col+j-1)];
> Output[row][col] = sum;
> ```

![[COMP4611L9_2026F.pdf#page=31]]

*3×3 kernel slides over the image: 9 reads per output pixel (p. 31).*

![[COMP4611L9_2026F.pdf#page=32]]

*Neighbouring output pixels share 6 of their 9 inputs (p. 32).*

- **Baseline:** 2 neighbouring threads issue 9 + 9 global loads, 6 of them the *same* addresses
  (relying on the L1 cache, which may not help).
- **Tiling:** load an `L×L` tile into SHM once, `__syncthreads()`, then compute all outputs of the
  tile from SHM.

```
__shared__ int tile[len*len];
tile[threadIdx.x] = input[blockIdx.x*blockDim.x + threadIdx.x];
__syncthreads();
for (i=0;i<3;i++) for (j=0;j<3;j++)
    sum += gauss[i][j] * tile[(row+i-1)*len + (col+j-1)];
```

Per output pixel the global traffic drops from 9 loads to ~1, and all 9 reads hit SHM. **Cost:**
one barrier + SHM capacity (which lowers occupancy → a real trade-off).

### 6.4 Shared-memory bank conflicts

SHM is **banked**: 32 banks, each serving **one address per cycle**.

```
bank = address % 32          (successive words → successive banks)
```

- Accesses to **different** banks proceed in parallel.
- Accesses to **different addresses in the same bank** are **serialised**.
- "Bank conflict" is defined **within one warp instruction**. Different warps hitting the same bank
  is ordinary resource contention, not a bank conflict.

![[COMP4611L9_2026F.pdf#page=35]]

*No conflict: 1 word stride → thread i hits bank i (p. 35).*

| Access pattern | Banks hit | Conflict | Effective bandwidth |
|---|---|---|---|
| `A[threadIdx.x]` (stride 1) | 0,1,2,… | none | 100 % |
| `A[2*threadIdx.x]` (stride 2) | 0,2,4,… (even only) | **2-way** | 50 % |
| `A[8*threadIdx.x]` (stride 8) | 0,8,16,24 → 4 banks | **8-way** | 12.5 % |
| `A[32*threadIdx.x]` (stride 32) | all bank 0 | **32-way** | 3.1 % |
| random | mostly distinct | ~none | ~100 % |

![[COMP4611L9_2026F.pdf#page=36]]

*2-way conflict: two loads per bank (p. 36).*

![[COMP4611L9_2026F.pdf#page=37]]

*8-way conflict: eight serialised loads per bank (p. 37).*

> 💡 **The classic killer — a 32×32 tile read by column:**
> ```
> __shared__ float tile[32][32];       // row-major, stride 32
> value = tile[threadIdx.x][col];      // thread i -> address i*32 + col
> ```
> All 32 threads map to `bank = (i*32 + col) % 32 = col` ⇒ **32-way conflict**.
> **Fix — padding one column:**
> ```
> __shared__ float tile[32][33];       // stride 33
> bank = (i*33 + col) % 32 = (i + col) % 32   -> distinct per thread
> ```
> Conflicts gone at the price of 32 floats of wasted SHM (which slightly reduces occupancy).

![[COMP4611L9_2026F.pdf#page=38]]

*Padding turns stride 32 into an effective stride of 1 (p. 38).*

Other fix: **randomised/hashed bank mapping**, `bank = hash(address) % 32`, which breaks regular
strides but adds latency/hardware.

### 6.5 Atomic conflicts

An atomic (e.g. `atomicAdd(&x, 1)`) on the *same* address from several threads must be
**serialised** — one after another, `n` updates take `n` times longer.

![[COMP4611L9_2026F.pdf#page=40]]

*No conflict vs. serialised updates within a warp (p. 40).*

> 💡 **Histogram** is the canonical victim:
> ```
> for (each pixel i) Histogram[Computation(I[i])]++;
> ```
> A natural image has many pixels in the *same* bin ⇒ repeated conflicts on hot bins. If 32 lanes
> all vote for bin 7, that is 32 serialised updates (p. 41).

**Fix — privatisation:** give each block its own sub-histogram **in shared memory**, then aggregate
all sub-histograms into the global one (atomics only once per bin per block).

![[COMP4611L9_2026F.pdf#page=42]]

*Per-block SHM sub-histograms, then a final merge (p. 42).*

> 💡 **Numbers:** 1000 blocks × 32 lanes hitting bin 7 → with privatisation, 1000 atomic updates
> (SHM, cheap, plus one global per block) instead of 32000 global atomics.

### 6.6 CPU–GPU data transfer: streams and overlap

![[COMP4611L9_2026F.pdf#page=44]]

*Serial: transfer all data, then run all blocks — link idle while GPU computes (p. 44).*

A **stream** (command queue) is an ordered sequence: H2D copy → kernel → D2H copy. Work in
*different* streams may overlap. The **default stream** serialises everything.

Split the work into `nStreams` chunks (`D/nStreams` items, `B/nStreams` blocks each):

![[COMP4611L9_2026F.pdf#page=45]]

*Chunk k+1 transfers while chunk k computes (p. 45).*

Let `tT` = total transfer time, `tE` = total kernel time:

```
finish time =  tT/nStreams + tE      if tE >= tT   (compute dominates)
               tT + tE/nStreams      if tT >= tE   (transfer dominates)
```

vs. `tT + tE` for the serial version.

> 💡 **Example:** `tT = 4 ms`, `tE = 8 ms` (compute dominates), `nStreams = 4`:
> serial `4 + 8 = 12 ms` → streamed `4/4 + 8 = 9 ms` (**25 % faster**). Split into 8 streams →
> `0.5 + 8 = 8.5 ms`, with diminishing returns; too many streams adds launch overhead.

Video processing is the textbook beneficiary: each frame is independent, so frame `k+1` can be
copied in while frame `k` is filtered.

## 7. GPU utilisation: divergence revisited

![[COMP4611L9_2026F.pdf#page=48]]

*Divergent paths leave idle lanes (p. 48).*

Two distinct cases:

1. **Inter-warp divergence** — different warps take different paths. Harmless! Each warp is
   uniformly busy. This is the normal case and utilisation stays 100 %.
2. **Intra-warp divergence** — the same warp splits. Lanes are masked off ⇒ **dynamic warp
   formation** may help by merging same-PC threads across warps.

But some patterns defeat DWF:

![[COMP4611L9_2026F.pdf#page=50]]

*`tid % 2` divergence: the same lane indices are active in every warp, so no regrouping helps (p. 50).*

```
if (threadIdx.x % 2 == 0) Do_path_A(threadIdx.x);
else                      Do_path_B(threadIdx.x);
```

Even threads always occupy even lanes. Merging cannot put two threads in one lane ⇒ every warp
still issues both paths at 50 % occupancy.

**Software fix — change the thread→data mapping so each warp is uniform:**

![[COMP4611L9_2026F.pdf#page=51]]

*Remapping threads to data so that warp 0 handles all even elements and warp 1 all odd ones (p. 51).*

```
if (threadIdx.x < 32) Do_this(threadIdx.x * 2);            // warp 0: all even elements
else                  Do_that((threadIdx.x % 32) * 2 + 1); // warp 1: all odd elements
```

Now the first half of the block handles all even-indexed *data*, the second half all odd-indexed
data: each warp is divergence-free, two full warps instead of two half-full ones.

> 💡 **Classic example — tree reduction** (`partialSum[t] += partialSum[t+stride]`):
>
> | Version | Condition | Active lanes per step |
> |---|---|---|
> | **Bad** | `if (t % (2*stride) == 0)`, `stride = 1,2,4,…` | 1/2, 1/4, 1/8 … of **every** warp |
> | **Good** | `if (t < stride)`, `stride = blockDim/2, …, 1` | 1, ½, ¼ … of the warps — the **low-index contiguous** warps |
>
> With 256 threads (8 warps): the bad version keeps all 8 warps alive doing 1/8 useful work at
> the end; the good version keeps warp 0 fully busy and lets warps 1–7 **exit** early.

![[COMP4611L9_2026F.pdf#page=52]]

*Interleaved pattern: active threads are scattered, so all warps stay resident (p. 52).*

![[COMP4611L9_2026F.pdf#page=53]]

*Contiguous pattern: active threads are packed into the first warps (p. 53).*

## 8. Optimisation checklist (exam-ready)

- [ ] **Coalesce**: `threadIdx.x` ↔ fastest-varying index; all lanes in one cache line.
- [ ] **Reuse**: tile hot data in SHM; one global load per element per block.
- [ ] **Bank conflicts**: stride-1 SHM access; pad `[32][33]`; check `(i*stride) % 32`.
- [ ] **Occupancy**: find the binding limit (warps / blocks / regs / SHM); 64 warps max.
- [ ] **Divergence**: uniform per warp if possible; prefer contiguous active sets.
- [ ] **Atomics**: privatise per block/SM; aggregate at the end.
- [ ] **Transfers**: chunk into streams; overlap copy and compute.
- [ ] **Measure**: `cudaDeviceSynchronize()` before stopping the timer.

### Key takeaways

1. GPU = throughput machine: many in-order cores, latency hidden by **warp-level FGMT**.
2. CUDA objects: grid → block (→SM) → warp (32) → thread (lane); index with
   `blockIdx*blockDim + threadIdx`.
3. No grid-wide barrier inside a kernel — hardware schedules blocks in arbitrary order.
4. Global memory + CPU↔GPU transfers are the bottlenecks; fix them with **coalescing, tiling,
   occupancy, streams**.
5. Shared memory is fast but **banked**: conflicts serialise; pad or change the access pattern.
6. Divergence hurts through **lane utilisation**, not through extra instructions alone — and
   thread↔data remapping is often the cheapest fix.
