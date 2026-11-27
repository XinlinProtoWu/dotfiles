# COMP4611 Homework 3 — Solutions

**Design and Analysis of Computer Architectures · Fall 2026**
**Source material: Lectures 8–9 (`09_SIMD_and_GPU.md`, `10_GPU_Programming_Performance.md`) and Tutorial 5 (`T5_GPU_SIMD_Utilization.md`)**

---

## Part A — Single-choice questions (3 points each)

| Question | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| **Answer** | **C** | **A** | **D** | **B** | **C** | **A** | **D** | **B** | **D** | **B** |

**Reasoning (brief):**

1. **C** — GPUs hide long global-memory latency with fine-grained multithreading (FGMT): while one warp waits on memory, the scheduler issues instructions from another *ready* warp. They do **not** rely on sophisticated per-thread out-of-order execution (A), memory still takes hundreds of cycles (B), and warps on an SM need not execute the same instruction (D).

2. **A** — CPU SIMD uses explicit vector instructions (e.g. AVX) operating on vector registers; GPU SIMT lets the programmer write ordinary scalar per-thread code that the hardware groups into warps. A CPU vector lane does not have a separate PC (B), an SM runs many threads (C), and SIMT does support branches via predication/serialization (D).

3. **D** — With row-major storage and width 64,
   ```
   col = blockIdx.x * blockDim.x + threadIdx.x = 2*8 + 3 = 19
   row = blockIdx.y * blockDim.y + threadIdx.y = 1*4 + 2 = 6
   index = row * 64 + col = 6*64 + 19 = 403
   ```

4. **B** — `__syncthreads()` is a block-level barrier: it synchronizes **all threads in the same block**.

5. **C** — An ordinary grid-wide barrier can deadlock because blocks are scheduled in any order/degree of concurrency. Resident blocks may wait for a block that has not yet been scheduled while occupying all SM resources, so nothing can progress.

6. **A** — A 32-thread warp instruction needs `32 / 8 = 4` groups on 8 lanes.

7. **D** — L1 cache is **hardware-managed** (automatic allocation/eviction), whereas shared memory is **explicitly managed by the programmer**.

8. **B** — Tiling loads a neighborhood once into shared memory so neighboring threads **reuse input pixels already on chip** instead of repeatedly hitting global memory.

9. **D** — Per-block privatization gives each block its own sub-histogram, reducing contention on a single shared histogram; the partial histograms are merged at the end.

10. **B** — Total transfer `tT = 8 ms`, total compute `tE = 12 ms`, `n = 4` chunks. Compute dominates, so
    ```
    finish = tT/n + tE = 8/4 + 12 = 2 + 12 = 14 ms
    ```

---

## Question 11 — GPU execution and SIMD utilization (30 points)

```c
__global__ void kernel(const int *A, int *B) {
    int t = blockIdx.x * blockDim.x + threadIdx.x;
    if (t % 2 == 0) B[t] = A[t] + 1;
    else            B[t] = A[t] * 2;
}
kernel<<<4, 32>>>(A, B);
```

**Model:** 32 threads/warp, 32 lanes, 1 warp per block. The predicate `t % 2 == 0` is one instruction; each branch body is one arithmetic instruction, issued only if ≥1 thread takes it. Each issued warp instruction uses 32 lane-slots / 1 cycle. Ignore memory/indexing.

### (a) Thread organization — 6 points

**(i) Blocks, threads, warps (3 pts):** `gridDim.x = 4` ⇒ **4 blocks**; `4 × 32 = 128 threads`; 32 threads/block = 1 warp ⇒ **4 warps**.

**(ii) Global ID of thread 5, block 2 (3 pts):** `t = 2·32 + 5 = 69`.

### (b) Branch divergence — 6 points

**(i) Warp 0 (2 pts):** IDs `0..31` ⇒ **16 even, 16 odd** threads.

**(ii) Other warps (2 pts):** **Yes.** Every warp covers 32 consecutive IDs (0–31, 32–63, 64–95, 96–127), so each has 16 even / 16 odd.

**(iii) Instructions per warp (2 pts):** predicate + even branch + odd branch = **3 instructions**.

### (c) SIMD utilization — 6 points

Per warp: predicate = 32 active / 32 slots; each branch = 16 active / 32 slots.

| Instruction | Active lanes | Slots |
|---|---|---|
| Predicate `t % 2 == 0` | 32 | 32 |
| Even branch (`+1`) | 16 | 32 |
| Odd branch (`*2`) | 16 | 32 |
| **Total / warp** | **64** | **96** |

Over 4 warps: `U = 4·64 / 4·96 = 256/384 = 2/3 ≈ 66.67 %`.

### (d) Dynamic warp formation — 4 points

**No.** Threads must keep their physical lane. The even branch already activates lanes `0,2,…,30` and the odd branch lanes `1,3,…,31` in every warp, so merging two warps would collide on the same lanes. Each branch still issues one half-full (16/32) instruction ⇒ utilization stays 2/3.

### (e) Improving SIMD utilization — 8 points

```c
int j = (t < 64) ? 2*t : 2*(t - 64) + 1;
if (j % 2 == 0) B[j] = A[j] + 1;
else            B[j] = A[j] * 2;
```

**(i) Branches per warp (3 pts):** `t = 0..63` → even `j`; `t = 64..127` → odd `j`. So **warps 0–1 run the even branch, warps 2–3 the odd branch**.

**(ii) New utilization (3 pts):** every warp is uniform: predicate 32/32 + one taken branch 32/32 = **64/64 = 100 %**.

**(iii) Same output? (2 pts):** **Yes.** `j(t)` is a bijection onto `{0,…,127}` (all evens then all odds), and each `j` gets the same operation as before. Only the grouping changes.

---

## Question 12 — GPU memory access and performance (40 points)

**Model:** 32 threads/warp, each `float` = 4 B. Global memory uses 128-B segments = 32 floats per segment; a warp load touches every segment containing a requested address. Shared memory has 32 banks, `bank = word_index % 32`; different words in the same bank serialize.

### (a) Global-memory coalescing — 12 points

`X` is 128-B-aligned, so segment `s` holds `X[32s]…X[32s+31]`.

**(i) Accesses (9 pts):**

| Access | Word indices requested | 128-B segments touched | Explanation |
|---|---|---|---|
| **A — `X[threadIdx.x]`** | `0..31` | **1** | 32 consecutive floats all in segment 0 — perfectly coalesced |
| **B — `X[32*threadIdx.x]`** | `0, 32, …, 992` | **32** | stride 32 floats (128 B) puts each request in a different segment |
| **C — `X[threadIdx.x + 1]`** | `1..32` | **2** | consecutive but shifted by 1, so it crosses one segment boundary |

**(ii) Access C bytes (3 pts):** useful `32 × 4 = 128 B`; transferred `2 × 128 = 256 B` ⇒ **128/256 = 50 %**.

### (b) Shared-memory bank conflicts — 14 points

```c
__shared__ float tile[32][32];    // Layout A
__shared__ float tilePad[32][33]; // Layout B
// access: tile[t][0] / tilePad[t][0],  t = 0..31
```

**(i) Offsets (4 pts):** A: `32t`; B: `33t` words.

**(ii) Layout A (4 pts):** `bank = 32t % 32 = 0` for all `t` ⇒ all threads hit **bank 0**, different words ⇒ **32-way conflict**.

**(iii) Layout B (4 pts):** `bank = 33t % 32 = t` ⇒ threads hit **banks 0–31**, one each ⇒ **no conflict**.

**(iv) Extra bytes (2 pts):** `32×33 − 32×32 = 32 floats = 128 B`.

### (c) SM occupancy — 10 points

256 threads/block ⇒ **8 warps/block**. Limits: 64 warps, 8 blocks, 64 KiB shared memory (registers not limiting).

| | Kernel U (24 KiB) | Kernel V (16 KiB) |
|---|---|---|
| Shared-memory blocks | ⌊64/24⌋ = **2** | ⌊64/16⌋ = **4** |
| Warp-limit blocks | 64/8 = 8 | 64/8 = 8 |
| Block limit | 8 | 8 |
| **Binding limit** | shared ⇒ **2 blocks** | shared ⇒ **4 blocks** |
| **(i) Resident blocks/SM** | **2** | **4** |
| **(ii) Resident warps/SM** | 2×8 = **16** | 4×8 = **32** |
| **(iii) Occupancy** | 16/64 = **25 %** | 32/64 = **50 %** |

### (d) Occupancy and performance — 4 points

**No.** Higher occupancy only improves latency hiding (FGMT). If the kernel is compute- or bandwidth-bound, extra warps add no throughput, and Kernel U's larger shared memory may enable tiling/reuse that reduces global-memory traffic — potentially running faster despite lower occupancy.

---

## Summary of numerical answers

| Question | Answer |
|---|---|
| Q1–Q10 | C, A, D, B, C, A, D, B, D, B |
| Q11(a)(i) | 4 blocks, 128 threads, 4 warps |
| Q11(a)(ii) | Global thread ID = 69 |
| Q11(b)(i) | 16 even, 16 odd |
| Q11(b)(ii) | Yes — every warp has 16/16 |
| Q11(b)(iii) | 3 instructions per warp |
| Q11(c) | U = 256/384 ≈ 66.67 % |
| Q11(d) | No — lane-position constraint prevents regrouping |
| Q11(e)(i) | Warps 0–1 even branch; warps 2–3 odd branch |
| Q11(e)(ii) | U = 100 % |
| Q11(e)(iii) | Yes — bijective index mapping, same operations |
| Q12(a)(i) | A: 1 seg; B: 32 seg; C: 2 seg |
| Q12(a)(ii) | 128 useful / 256 transferred = 50 % |
| Q12(b)(i) | A: `32t`; B: `33t` |
| Q12(b)(ii) | Bank 0, 32-way conflict |
| Q12(b)(iii) | Banks 0–31, no conflict |
| Q12(b)(iv) | 128 extra bytes |
| Q12(c) | U: 2 blocks, 16 warps, 25 %; V: 4 blocks, 32 warps, 50 % |
| Q12(d) | No guarantee (latency hiding vs other bottlenecks) |
