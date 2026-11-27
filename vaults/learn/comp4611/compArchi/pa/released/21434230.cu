/*
 * ============================================================
 * COMP4611 Programming Assignment 2: Matrix Multiplication
 * on the CPU and on the GPU with CUDA (C = A x B)
 *
 * Name: Xinlin Wu
 * Student ID: 21434230
 * Email: xwudz@connect.ust.hk
 *
 * This file is a skeleton to be completed.
 *   - Complete the parts marked TODO 1-7.
 *   - Write code ONLY between the "BEGIN YOUR CODE" and
 *     "END YOUR CODE" markers, and do not change the markers.
 *     During grading, everything outside the markers is replaced
 *     by the original skeleton.
 * ============================================================
 */

#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cuda_runtime.h>

/* Provided: abort with a message if a CUDA runtime call fails. */
#define CUDA_CHECK(call)                                                       \
  do {                                                                         \
    cudaError_t err_ = (call);                                                 \
    if (err_ != cudaSuccess) {                                                 \
      fprintf(stderr, "CUDA error at %s:%d: %s\n", __FILE__, __LINE__,         \
              cudaGetErrorString(err_));                                       \
      exit(EXIT_FAILURE);                                                      \
    }                                                                          \
  } while (0)

/*
 * All matrices are row-major 1-D arrays:
 *   A is M x K, B is K x N, C is M x N, and
 *   C[i][j] = sum_k A[i][k] * B[k][j]
 * C is not initialized before the call: every element must be
 * written.
 */

/* ============================================================
 * TODO 1: Compute C = A x B sequentially on the CPU.
 * ============================================================ */
static void cpu_matmul(const double *A, const double *B, double *C, int M,
                       int K, int N) {
  /* ----- BEGIN YOUR CODE (TODO 1) ----- */
  // i = rows of C and A
  // j = cols of C and B
  // k = shared inner dimension (cols of A / rows of B)
  for (int i = 0; i < M; i++) {
    for (int j = 0; j < N; j++) {
      double sum = 0.0;
      for (int k = 0; k < K; k++) {
        sum += A[i * K + k] * B[k * N + j];
      }
      C[i * N + j] = sum;
    }
  }
  /* ----- END YOUR CODE (TODO 1) ----- */
}

/* ============================================================
 * TODO 2: Implement the kernel (see the step-by-step guide in
 *   README.md), e.g. each thread computes one element C[row][col].
 *   M, K and N need not be multiples of the block size, so
 *   threads that fall outside C must not read or write memory.
 *   You may #define constants (e.g. a tile size) inside the
 *   markers; they are also visible in gpu_matmul.
 * ============================================================ */
__global__ void matmul_kernel(const double *A, const double *B, double *C,
                              int M, int K, int N) {
  /* ----- BEGIN YOUR CODE (TODO 2) ----- */
  int row = blockIdx.y * blockDim.y + threadIdx.y; // i : row of C
  int col = blockIdx.x * blockDim.x + threadIdx.x; // j : col of C

  // Bounds check: the grid is rounded up to whole blocks, so the last block
  // in each direction may contain extra threads falling outside C.
  // Those must do nothing

  if (row < M && col < N) {
    double sum = 0.0;
    for (int k = 0; k < K; k++) {
      // Dot product over shared dimension K
      sum += A[row * K + k] * B[k * N + col];
    }
    C[row * N + col] = sum;
  }
  /* ----- END YOUR CODE (TODO 2) ----- */
}

/*
 * The GPU part is split into the functions below. The provided
 * gpu_matmul calls them in order, and each one receives only the
 * data it needs. In TODO 3-7, use only the CUDA calls named in the
 * TODO (cudaMemset, cudaGetLastError, cudaDeviceSynchronize and the
 * cudaEvent* functions are also allowed), and wrap each call in
 * CUDA_CHECK.
 */

/* TODO 3: Allocate d_A (M * K), d_B (K * N) and d_C (M * N)
 *         doubles on the device with cudaMalloc. */
static void gpu_alloc(double **d_A, double **d_B, double **d_C, int M, int K,
                      int N) {
  /* ----- BEGIN YOUR CODE (TODO 3) ----- */
  CUDA_CHECK(cudaMalloc(d_A, (size_t)M * K * sizeof(double)));
  CUDA_CHECK(cudaMalloc(d_B, (size_t)K * N * sizeof(double)));
  CUDA_CHECK(cudaMalloc(d_C, (size_t)M * N * sizeof(double)));

  /* ----- END YOUR CODE (TODO 3) ----- */
}

/* TODO 4: Copy A to d_A and B to d_B with cudaMemcpy
 *         (cudaMemcpyHostToDevice). */
static void copy_in(const double *A, const double *B, double *d_A, double *d_B,
                    int M, int K, int N) {
  /* ----- BEGIN YOUR CODE (TODO 4) ----- */
  CUDA_CHECK(cudaMemcpy(d_A, A, (size_t)M * K * sizeof(double),
                        cudaMemcpyHostToDevice));
  CUDA_CHECK(cudaMemcpy(d_B, B, (size_t)K * N * sizeof(double),
                        cudaMemcpyHostToDevice));

  /* ----- END YOUR CODE (TODO 4) ----- */
}

/* TODO 5: Choose a 2-D block size (e.g. 16 x 16), compute a grid that
 *         covers all M x N elements of C, launch matmul_kernel with
 *         <<<grid, block>>>, and check the launch with
 *         CUDA_CHECK(cudaGetLastError()). */
static void launch(const double *d_A, const double *d_B, double *d_C, int M,
                   int K, int N) {
  /* ----- BEGIN YOUR CODE (TODO 5) ----- */
  // Block = 16 x 16 threads per block
  // grid = number of blocks needed to cover all N columns and M rows, rounded
  // up
  // ceil(a / b) = (a + b - 1) / b
  dim3 block(16, 16);
  dim3 grid((N + block.x - 1) / block.x, (M + block.y - 1) / block.y);

  // launch the kernel: one thread is created per element of C.
  matmul_kernel<<<grid, block>>>(d_A, d_B, d_C, M, K, N);

  // Kernel launches are asynchronous
  // cudaGetLastError() reports launch/configuration errors such as invalid grid
  // or block size
  CUDA_CHECK(cudaGetLastError());
  /* ----- END YOUR CODE (TODO 5) ----- */
}

/* TODO 6: Copy d_C to C with cudaMemcpy (cudaMemcpyDeviceToHost). */
static void copy_out(const double *d_C, double *C, int M, int N) {
  /* ----- BEGIN YOUR CODE (TODO 6) ----- */
  // copies device to host
  // A synchronous call, so it also waits for the kernel to finish.
  CUDA_CHECK(cudaMemcpy(C, d_C, (size_t)M * N * sizeof(double),
                        cudaMemcpyDeviceToHost));
  /* ----- END YOUR CODE (TODO 6) ----- */
}

/* TODO 7: Free d_A, d_B and d_C with cudaFree. */
static void gpu_free(double *d_A, double *d_B, double *d_C) {
  /* ----- BEGIN YOUR CODE (TODO 7) ----- */
  // Free every device allocation made in gpu_alloc
  CUDA_CHECK(cudaFree(d_A));
  CUDA_CHECK(cudaFree(d_B));
  CUDA_CHECK(cudaFree(d_C));
  /* ----- END YOUR CODE (TODO 7) ----- */
}

/* Provided: compute C = A x B on the GPU. A, B and C are host arrays. */
static void gpu_matmul(const double *A, const double *B, double *C, int M,
                       int K, int N) {
  double *d_A = NULL;
  double *d_B = NULL;
  double *d_C = NULL;

  gpu_alloc(&d_A, &d_B, &d_C, M, K, N);
  copy_in(A, B, d_A, d_B, M, K, N);
  launch(d_A, d_B, d_C, M, K, N);
  copy_out(d_C, C, M, N);
  gpu_free(d_A, d_B, d_C);
}

/*
 * Provided: read the input file.
 * Format:
 *   First line: three integers M K N
 *   Next M lines, K numbers each: matrix A (M x K)
 *   Next K lines, N numbers each: matrix B (K x N)
 */
static void read_matrix_file(const char *filename, int *M, int *K, int *N,
                             double **A, double **B) {
  FILE *fp = fopen(filename, "r");

  if (fp == NULL) {
    fprintf(stderr, "Cannot open input file: %s\n", filename);
    exit(EXIT_FAILURE);
  }

  if (fscanf(fp, "%d %d %d", M, K, N) != 3 || *M <= 0 || *K <= 0 || *N <= 0) {
    fprintf(stderr, "Invalid input format\n");
    fclose(fp);
    exit(EXIT_FAILURE);
  }

  *A = (double *)malloc((size_t)(*M) * (*K) * sizeof(double));
  *B = (double *)malloc((size_t)(*K) * (*N) * sizeof(double));

  if (*A == NULL || *B == NULL) {
    fprintf(stderr, "Memory allocation failed\n");
    fclose(fp);
    exit(EXIT_FAILURE);
  }

  for (size_t i = 0; i < (size_t)(*M) * (*K); i++) {
    if (fscanf(fp, "%lf", &(*A)[i]) != 1) {
      fprintf(stderr, "Invalid matrix A data\n");
      fclose(fp);
      exit(EXIT_FAILURE);
    }
  }

  for (size_t i = 0; i < (size_t)(*K) * (*N); i++) {
    if (fscanf(fp, "%lf", &(*B)[i]) != 1) {
      fprintf(stderr, "Invalid matrix B data\n");
      fclose(fp);
      exit(EXIT_FAILURE);
    }
  }

  fclose(fp);
}

/*
 * Provided: print the result.
 * Format: first line "RESULT M N", then one row of C per line.
 */
static void print_result(const double *C, int M, int N) {
  printf("RESULT %d %d\n", M, N);

  for (int i = 0; i < M; i++) {
    for (int j = 0; j < N; j++) {
      printf("%.10g", C[(size_t)i * N + j]);

      if (j != N - 1) {
        printf(" ");
      }
    }
    printf("\n");
  }
}

/*
 * Provided: run cpu_matmul or gpu_matmul and return its wall-clock
 * time in ms. C is filled with NaN first, so elements that are never
 * written show up as "nan" in the output.
 */
static double timed_matmul(bool use_gpu, const double *A, const double *B,
                           double *C, int M, int K, int N) {
  for (size_t i = 0; i < (size_t)M * N; i++) {
    C[i] = NAN;
  }

  if (use_gpu) {
    /* Create the CUDA context outside the timed region. */
    CUDA_CHECK(cudaFree(0));
  }

  auto start = std::chrono::steady_clock::now();
  if (use_gpu) {
    gpu_matmul(A, B, C, M, K, N);
    CUDA_CHECK(cudaDeviceSynchronize());
  } else {
    cpu_matmul(A, B, C, M, K, N);
  }
  auto stop = std::chrono::steady_clock::now();

  return std::chrono::duration<double, std::milli>(stop - start).count();
}

/* Provided: fill X with pseudo-random integers in [-9, -1] U [1, 9]. */
static void fill_random(double *X, size_t n, unsigned int *state) {
  for (size_t i = 0; i < n; i++) {
    *state = *state * 1103515245u + 12345u;
    int v = (int)((*state >> 16) % 18u);
    X[i] = (double)(v < 9 ? v - 9 : v - 8);
  }
}

/*
 * Provided: --bench M K N
 * Multiply random M x K and K x N matrices with both cpu_matmul and
 * gpu_matmul, and report their wall-clock times and whether the two
 * results agree.
 */
static int run_bench(int M, int K, int N) {
  if (M <= 0 || K <= 0 || N <= 0) {
    fprintf(stderr, "Invalid bench size\n");
    return EXIT_FAILURE;
  }

  double *A = (double *)malloc((size_t)M * K * sizeof(double));
  double *B = (double *)malloc((size_t)K * N * sizeof(double));
  double *C_cpu = (double *)malloc((size_t)M * N * sizeof(double));
  double *C_gpu = (double *)malloc((size_t)M * N * sizeof(double));

  if (A == NULL || B == NULL || C_cpu == NULL || C_gpu == NULL) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }

  unsigned int state = 4611u;
  fill_random(A, (size_t)M * K, &state);
  fill_random(B, (size_t)K * N, &state);

  double cpu_ms = timed_matmul(false, A, B, C_cpu, M, K, N);
  double gpu_ms = timed_matmul(true, A, B, C_gpu, M, K, N);

  size_t mismatches = 0;
  for (size_t i = 0; i < (size_t)M * N; i++) {
    if (!(C_cpu[i] == C_gpu[i])) {
      mismatches++;
    }
  }

  printf("BENCH M=%d K=%d N=%d\n", M, K, N);
  printf("  cpu_matmul: %10.3f ms\n", cpu_ms);
  printf("  gpu_matmul: %10.3f ms (incl. device allocation and transfers)\n",
         gpu_ms);
  printf("  speedup:    %10.1fx\n", cpu_ms / gpu_ms);
  printf("  CPU and GPU results %s (%zu mismatched elements)\n",
         mismatches == 0 ? "match" : "DIFFER", mismatches);

  free(A);
  free(B);
  free(C_cpu);
  free(C_gpu);

  return EXIT_SUCCESS;
}

int main(int argc, char **argv) {
  if (argc == 5 && strcmp(argv[1], "--bench") == 0) {
    return run_bench(atoi(argv[2]), atoi(argv[3]), atoi(argv[4]));
  }

  if (argc != 3 ||
      (strcmp(argv[1], "cpu") != 0 && strcmp(argv[1], "gpu") != 0)) {
    fprintf(stderr, "Usage: %s cpu|gpu <dataset_file>\n", argv[0]);
    fprintf(stderr, "       %s --bench M K N\n", argv[0]);
    return EXIT_FAILURE;
  }

  bool use_gpu = strcmp(argv[1], "gpu") == 0;
  int M = 0;
  int K = 0;
  int N = 0;
  double *A = NULL;
  double *B = NULL;

  read_matrix_file(argv[2], &M, &K, &N, &A, &B);

  double *C = (double *)malloc((size_t)M * N * sizeof(double));

  if (C == NULL) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }

  double ms = timed_matmul(use_gpu, A, B, C, M, K, N);

  print_result(C, M, N);
  fprintf(stderr, "TIME %s_matmul %.3f ms\n", argv[1], ms);

  free(A);
  free(B);
  free(C);

  return EXIT_SUCCESS;
}
