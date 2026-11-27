# COMP4611 Programming Assignment 2: Matrix Multiplication on CPU and GPU

- **Submission**: Submit exactly one `student_id.cu` to Canvas

---

## 1. Assignment Overview

Implement General Matrix–Matrix Multiplication (GEMM) twice — sequentially on
the CPU and in parallel on the GPU with CUDA — and compare their run times:
given `A (M×K)` and `B (K×N)`, compute `C = A × B`.

You only need to complete the parts marked `TODO` in `matmul.cu`:

1. `cpu_matmul`: compute `C` sequentially on the CPU.
2. `matmul_kernel`: each thread computes one element `C[row][col]`.
   `M`, `K` and `N` need not be multiples of the block size, so threads
   outside `C` must not read or write memory.
3. `gpu_alloc`: allocate `d_A`, `d_B` and `d_C` with `cudaMalloc`.
4. `copy_in`: copy `A` and `B` to the device with `cudaMemcpy`.
5. `launch`: choose the block and grid sizes and launch `matmul_kernel` with
   `<<<grid, block>>>`.
6. `copy_out`: copy `d_C` back to `C` with `cudaMemcpy`.
7. `gpu_free`: free the device memory with `cudaFree`.

The provided `gpu_matmul` calls functions 3–7 in order.

All matrices are stored as row-major one-dimensional `double` arrays. `C` is
not initialized before your function is called, so write every element.

Write your code **only** between the `BEGIN YOUR CODE` and `END YOUR CODE`
markers, and do not change the markers. During grading, everything outside the
markers is replaced by the original skeleton.

## 2. Directory Structure

| File | Description |
| --- | --- |
| `matmul.cu` | The CUDA program skeleton — the only file you modify |
| `Makefile` / `test.sh` | Build and run the public tests |
| `dataset/` | Public input datasets |
| `expected/` | Expected output for the public datasets |
| `tuxiv.conf` | TACC SDK submission configuration (resources and entrypoint) |
| `sdk-test.sh` | Remote test entrypoint on TACC (activates env → runs `test.sh`) |
| `README.md` | This guide |

## 3. Input / Output Format

**Input**: the first line contains three integers `M K N`; followed by `M` rows of `A` (each with `K` numbers); followed by `K` rows of `B` (each with `N` numbers).

**Output** (stdout): the first line is `RESULT M N`; followed by `M` rows of `C` (each with `N` numbers).

Example input (`dataset/test1.txt`, M=2, K=2, N=2):

```text
2 2 2
1 2
3 4
5 6
7 8
```

Expected output (`expected/test1.txt`):

```text
RESULT 2 2
19 22
43 50
```

### Running the program

```bash
./matmul cpu ./dataset/test1.txt    # use cpu_matmul
./matmul gpu ./dataset/test1.txt    # use gpu_matmul
```

The result goes to stdout; the wall-clock time of the chosen function is
printed to stderr, e.g. `TIME gpu_matmul 0.512 ms`. The GPU time includes
device allocation and host–device transfers.

### Benchmark mode

```bash
./matmul --bench 1024 1024 1024
```

multiplies random matrices of the given size with both `cpu_matmul` and
`gpu_matmul`, and prints both wall-clock times, the speedup, and whether the
two results agree. `test.sh` runs it at the end. Performance is **not** graded.

## 4. Step-by-Step Guide

This guide walks through the simplest correct GPU version: **one thread
computes one element of `C`**. All matrices are row-major 1-D arrays, so
element `[i][j]` of a matrix with `cols` columns is at index `i * cols + j`:

| Element | Index |
| --- | --- |
| `A[i][k]` (M×K) | `i * K + k` |
| `B[k][j]` (K×N) | `k * N + j` |
| `C[i][j]` (M×N) | `i * N + j` |

### Step 1 — `cpu_matmul` (TODO 1)

Use three nested loops over `i` (rows of `C`), `j` (columns of `C`) and `k`.
For each `(i, j)`, start a `double sum = 0.0`, add `A[i][k] * B[k][j]` for
every `k`, then store the sum in `C[i][j]`. `C` is not initialized, so assign
(`=`) rather than accumulate into it.

### Step 2 — `matmul_kernel` (TODO 2)

The kernel replaces the two outer CPU loops: instead of looping over `(i, j)`,
you launch one thread per `(i, j)`. Threads are grouped into 2-D *blocks*, and
blocks into a 2-D *grid*. Each thread finds its position from built-in
variables; we use `x` for columns and `y` for rows:

```cpp
int row = blockIdx.y * blockDim.y + threadIdx.y;   // i
int col = blockIdx.x * blockDim.x + threadIdx.x;   // j
```

Then:

1. **Bounds check.** The grid is rounded up to whole blocks, so some threads
   fall outside `C`. If `row >= M` or `col >= N`, the thread must do nothing.
2. **Dot product.** Loop `k` from `0` to `K - 1` and accumulate
   `A[row][k] * B[k][col]` into a local `double sum`.
3. **Store.** Write `sum` to `C[row][col]`.

### Step 3 — `gpu_alloc` (TODO 3)

Allocate the three device arrays with `cudaMalloc(pointer, bytes)`. Here
`d_A` is already a `double **`, so pass it directly. The size is in **bytes**:
for `d_A` it is `(size_t)M * K * sizeof(double)`.

```cpp
CUDA_CHECK(cudaMalloc(d_A, (size_t)M * K * sizeof(double)));
```

Do the same for `d_B` (K×N) and `d_C` (M×N).

### Step 4 — `copy_in` (TODO 4)

Copy each input with `cudaMemcpy(destination, source, bytes, direction)`.
The destination comes first: copy `A` into `d_A` and `B` into `d_B` with
`cudaMemcpyHostToDevice`.

### Step 5 — `launch` (TODO 5)

1. Pick a block of 16×16 threads: `dim3 block(16, 16);`
2. Compute how many blocks cover all `N` columns (x) and `M` rows (y),
   rounding **up**: `(N + block.x - 1) / block.x` blocks in x, and likewise
   with `M` and `block.y` in y. Store them in a `dim3 grid(...)`.
3. Launch: `matmul_kernel<<<grid, block>>>(d_A, d_B, d_C, M, K, N);`
4. Check the launch: `CUDA_CHECK(cudaGetLastError());`

### Step 6 — `copy_out` (TODO 6)

Copy `d_C` into `C` (`M * N` doubles) with `cudaMemcpyDeviceToHost`. This call
also waits for the kernel to finish.

### Step 7 — `gpu_free` (TODO 7)

Free `d_A`, `d_B` and `d_C` with `cudaFree`.

### Common mistakes

| Symptom | Likely cause |
| --- | --- |
| Wrong results only for non-square tests | `x`/`y` (columns/rows) swapped between the kernel and the grid |
| `nan` in the output | Grid too small (rounded down), so some elements were never written |
| `illegal memory access`, or wrong results in `test3`–`test5` | Missing bounds check in the kernel |
| Only part of the matrix is correct | Byte count missing `sizeof(double)` |
| `invalid argument` from `cudaMemcpy` | Source and destination swapped, or wrong direction |

A kernel error is often reported by the next CUDA call (usually the
`cudaMemcpy` in `copy_out`), not by the kernel launch itself.

### Optional: shared-memory tiling (not graded)

In the simple kernel, every element of `A` and `B` is read from global memory
`N` or `M` times. A tiled kernel lets each block load a `TILE × TILE` tile of
`A` and of `B` into fast `__shared__` memory, synchronize with
`__syncthreads()`, accumulate the partial products from the tiles, and repeat
along `K`. Official examples:

- CUDA C++ Programming Guide (CUDA 12.1), [Shared Memory](https://docs.nvidia.com/cuda/archive/12.1.0/cuda-c-programming-guide/index.html#shared-memory):
  matrix multiplication without and with shared memory.
- NVIDIA CUDA Samples, [`matrixMul.cu`](https://github.com/NVIDIA/cuda-samples/blob/v13.4/cpp/0_Introduction/matrixMul/matrixMul.cu).

Both assume the matrix sizes are multiples of the block size and use `float`.
To adapt them here, load `0.0` for tile elements that fall outside `A` or `B`,
and write `C` only when `row < M` and `col < N`. Compare the two versions with
`./matmul --bench 1024 1024 1024`.

## 5. Testing on TACC (tcloud SDK)

The compute nodes have NVIDIA RTX 3090 GPUs. The course environment (CUDA 12.1
`nvcc`, GCC 12, Make) is preinstalled on TACC; you do not need CUDA or a GPU on
your own computer.

### 5.1 Install the tcloud SDK (once per computer)

Download the official tcloud SDK v0.4.1 for your system:

- macOS (Intel): `https://github.com/turingaicloud/quickstart/releases/download/v0.4.1/macos-amd64-v0.4.1.zip`
- Linux: `https://github.com/turingaicloud/quickstart/releases/download/v0.4.1/linux-amd64-v0.4.1.zip`

Unzip it and put `tcloud` on your `PATH` (or call it by its full path).

### 5.2 Configure your TACC account (once per computer)

```bash
tcloud config -u <username> -f <private_key_path>
tcloud init
```

- `<username>` is your TACC username.
- `<private_key_path>` is the private key corresponding to the public key
  registered with TACC (typically `~/.ssh/id_rsa`).

### 5.3 Submit a testing job

In the assignment directory containing `tuxiv.conf`, run:

```bash
tcloud submit
```

The SDK uploads your files; on TACC, `sdk-test.sh` activates the course
environment, compiles `matmul.cu`, runs the public tests with both `cpu` and
`gpu`, prints the time of every run, and finishes with the benchmark. A successful
submission prints something like:

```text
Submitted batch job 27453
```

Record this job ID (referred to as `JOB_ID` below).

### 5.4 Check the job status and result

```bash
tcloud ps -j JOB_ID                         # job status (R = running)
tcloud cat slurm_log/pa2-sdk-JOB_ID.log     # view the test log
```

A successful run ends with:

```text
CPU: 5/5 passed
GPU: 5/5 passed

ALL TESTS PASSED
```

### 5.5 Troubleshooting

| Symptom | Fix |
| --- | --- |
| `Failed to get env list` | Your account environment is not initialized; contact the TA |
| Log file not found | The job may still be queued or running; check `tcloud ps`, and replace `JOB_ID` with the actual numeric job ID |
| `tcloud: command not found` | Add `tcloud` to your `PATH` |
| Output contains `nan` | Some elements of `C` were never written by your kernel |

## 6. Submission

1. Complete and test your implementation in `matmul.cu` via `tcloud submit`.
2. Rename the completed file to **`student_id.cu`** (e.g., `20991234.cu`).
3. Upload this single `.cu` file to **Canvas** before the deadline.

- Submit **exactly one `.cu` file**. Do **not** submit a ZIP archive, executable, output file, screenshot, or any additional files.
- Fill in your **name, student ID, and email** in the comment at the beginning of the file.
- Running `tcloud submit` only tests your program; it does **not** replace the final Canvas submission.

## 7. Grading

| Part | Weight |
| --- | --- |
| CPU implementation (`cpu_matmul`) | 20% |
| GPU implementation (TODO 2–7) | 80% |

- Grading is on **correctness only**: your program is compiled and run with
  both `cpu` and `gpu` on multiple evaluation datasets (which may differ from
  the public ones, including sizes that are not multiples of your block
  size), and its stdout must match the expected output exactly. Each part's
  score is proportional to the evaluation datasets it passes.
- The CPU and GPU parts are graded independently.
- `C` must be computed by `matmul_kernel` on the GPU. Code in TODO 2–7 that
  could compute `C` on the host is reviewed manually and may lose the GPU
  credit, e.g. CUDA calls other than those named in each TODO (plus
  `cudaMemset`, `cudaGetLastError`, `cudaDeviceSynchronize` and
  `cudaEvent*`), calling `cpu_matmul`, loops in `copy_in`, or macros that
  change the provided code.
- **Performance / speedup is not graded.**
- A program that fails to compile scores 0.

## 8. Compiler and Library Policy

- Submissions are compiled with the provided `Makefile`:
  `nvcc -O2 -std=c++17 -arch=sm_86`.
- Only the standard C/C++ library and the CUDA runtime (`cuda_runtime.h`) are
  allowed. Do **not** use cuBLAS, Thrust, CUB, or any other library, and do
  not submit additional source/header files.

## 9. Notes

- Modify **only** the code between the `BEGIN YOUR CODE` / `END YOUR CODE`
  markers; changes elsewhere are discarded during grading.
- Do not change any file other than `matmul.cu` (`tuxiv.conf`, `sdk-test.sh`,
  `test.sh`, `Makefile`, `dataset/`, `expected/`); the TACC test job relies on
  them.
- Do not print to stdout (e.g. debug `printf`); it would corrupt the output
  that is compared with the expected result. Print debug messages to stderr.
- Wrap every CUDA runtime call in the provided `CUDA_CHECK` macro and free all
  device memory you allocate.
