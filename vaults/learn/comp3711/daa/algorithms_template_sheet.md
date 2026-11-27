# Algorithms Template Sheet — Lectures 3–9

> Cheat sheet: **which algorithm to use for which scenario**, plus **general
> templates** (pseudocode skeletons) and a **basic example** for each.

---

## Part A — Quick Decision Guide (Scenario → Algorithm)

### Sorting
| Scenario | Algorithm | Complexity | Notes |
|---|---|---|---|
| General comparison sort, want predictable worst case | **Mergesort** | `Θ(n log n)`, `O(n)` space | Stable, recursive D&C |
| Comparison sort, in-place, fast in practice | **Quicksort** (randomized) | `Θ(n log n)` expected, `Θ(n²)` worst | Small constants, cache-friendly |
| Comparison sort, in-place, hard worst-case guarantee | **Heapsort** | `O(n log n)`, `O(1)` space | Not stable |
| Keys are small integers in range `0..k` | **Counting sort** | `Θ(n + k)` | No comparisons |
| Integers/strings with `d` digits | **Radix sort** | `Θ(d(n + k))` | Sorts by digit using counting sort |

### Searching / Selection
| Scenario | Algorithm | Complexity |
|---|---|---|
| Sorted array, find a key | **Binary search** | `Θ(log n)` |
| Unsorted array, find `i`-th smallest (median, etc.) | **Randomized selection** | `Θ(n)` expected |
| Two sorted arrays, find `k`-th smallest overall | **D&C selection** (discard halves) | `Θ(log k)` |

### Sequence / Subarray optimization
| Scenario | Algorithm | Complexity |
|---|---|---|
| Maximum sum subarray | **Kadane's algorithm** (linear DP-style) | `Θ(n)` |
| Maximum sum subarray (also with start/end indices) | Kadane + `start`/`temp` tracking | `Θ(n)` |
| Max profit from one buy + one sell | Transform prices to differences → max subarray | `Θ(n)` |

### Priority-based operations
| Scenario | Data structure | Complexity |
|---|---|---|
| Repeated "get max" + insertions | **Max-heap** (priority queue) | Insert/Extract-Max `O(log n)` |
| Sorting via a heap | **Heapsort** | `O(n log n)` |

### Randomized / Probabilistic
| Scenario | Technique |
|---|---|
| Generate a uniform random permutation | **Fisher–Yates (Knuth) shuffle** |
| Avoid quicksort worst case on adversarial input | **Random pivot** |
| Compute expected values/counts | **Indicator random variables + linearity of expectation** |
| Expected wait until first success | **Geometric distribution** |
| Expected tries to collect all `n` types | **Coupon collector** (`Θ(n log n)`) |
| Hash with collisions | **Chaining**; expected collisions ≤ `n/m` |

### Recurrence / Recursion
| Scenario | Technique |
|---|---|
| Recursive problem on halves/parts | **Divide & Conquer** template |
| Solve `T(n) = aT(n/b) + f(n)` | **Master theorem / expansion / tree** |

---

## Part B — General Templates + Examples

---

## 1. Recursion (3-step recipe)

Use when a problem reduces to **the same problem on a smaller input**.

**Template (the 3 steps):**
1. **Base case:** write `f(1)` (or smallest case) directly.
2. **Assume:** assume `f(n-1)` works.
3. **Show:** build `f(n)` from `f(n-1)`.

**Example — Tower of Hanoi** (move `n` discs from `start` to `target` using
`aux`):

```
moveTower(n, start, aux, target):
    if n = 1:
        move disc from start to target
        return
    moveTower(n-1, start, target, aux)   // move top n-1 to aux
    move disc from start to target
    moveTower(n-1, aux, start, target)   // move n-1 from aux to target
```

Recurrence: `T(n) = 2T(n-1) + 1`, `T(1) = 1` → `T(n) = 2ⁿ − 1`.

---

## 2. Divide & Conquer (D&C) template

Use when the problem splits into **independent halves/parts** that can be
solved recursively and then **combined**.

**Template:**
```
Solve(problem P):
    if P is a base case: solve directly; return
    Split P into subproblems P1, P2, ...
    S1 = Solve(P1); S2 = Solve(P2); ...      // recursive calls
    return Combine(S1, S2, ...)              // merge step
```

### 2a. Mergesort

```
Mergesort(A, l, r):
    if l = r: return
    m ← (l + r) / 2
    Mergesort(A, l, m)
    Mergesort(A, m+1, r)
    Merge(A, l, m, r)

Merge(A, l, m, r):
    L ← A[l..m];  R ← A[m+1..r]
    ldx ← 1; rdx ← 1
    for k ← l to r:
        if ldx > L.size:      A[k] ← R[rdx]; rdx++
        else if rdx > R.size: A[k] ← L[ldx]; ldx++
        else if L[ldx] ≤ R[rdx]: A[k] ← L[ldx]; ldx++
        else:                 A[k] ← R[rdx]; rdx++
```

- Recurrence `T(n) = 2T(n/2) + n` → `Θ(n log n)`.

### 2b. Maximum subarray (D&C version)

```
MaxSubarray(A, l, r):
    if l = r: return A[l]
    m ← (l + r) / 2
    M1 ← MaxSubarray(A, l, m)         // best entirely left
    M2 ← MaxSubarray(A, m+1, r)       // best entirely right
    Lm ← -∞; V ← 0
    for i ← m downto l:               // best suffix of left half
        V ← V + A[i]; if V > Lm: Lm ← V
    Rm ← -∞; V ← 0
    for i ← m+1 to r:                 // best prefix of right half
        V ← V + A[i]; if V > Rm: Rm ← V
    return max(M1, M2, Lm + Rm)       // crossing = Lm + Rm
```

- Recurrence `T(n) = 2T(n/2) + n` → `Θ(n log n)`.
- **Use Kadane instead** if you just need the value → `Θ(n)`.

### 2c. Karatsuba multiplication

Split numbers: `a = 2^(n/2)·a₁ + a₀`, `b = 2^(n/2)·b₁ + b₀`.

- Naive D&C computes 4 products → `T(n) = 4T(n/2) + n = Θ(n²)` (no gain).
- Karatsuba uses 3 products via:
  `a₁b₀ + a₀b₁ = (a₁+a₀)(b₁+b₀) − a₁b₁ − a₀b₀`
- Recurrence `T(n) = 3T(n/2) + n` → `Θ(n^log₂3) ≈ Θ(n^1.585)`.

**Key idea:** reduce the number of recursive calls by algebraic reuse.

---

## 3. Solving recurrences

### 3a. Master theorem

For `T(n) = aT(n/b) + f(n)`:

| Case | Condition | Solution |
|---|---|---|
| Leaves dominate | `f(n) = O(n^(log_b a − ε))` | `T(n) = Θ(n^(log_b a))` |
| Equal (common) | `f(n) = Θ(n^(log_b a))` | `T(n) = Θ(n^(log_b a) · log n)` |
| Root dominates | `f(n) = Ω(n^(log_b a + ε))` + regularity | `T(n) = Θ(f(n))` |

**Quick rule for `T(n) = aT(n/b) + n`:**

| Relation | Solution |
|---|---|
| `a > b` | `Θ(n^(log_b a))` |
| `a = b` | `Θ(n log n)` |
| `a < b` | `Θ(n)` |

### 3b. Expansion (substitution) method

Unroll the recurrence until base case. Example `T(n) = 2T(n/2) + n`:

```
T(n) = 2T(n/2) + n
     = 2(2T(n/4) + n/2) + n = 4T(n/4) + 2n
     ...
     = 2^k · T(n/2^k) + k·n
```
Stop at `n/2^k = 1` → `k = log n` → `T(n) = n·T(1) + n log n = Θ(n log n)`.

### 3c. Recursion tree

Draw one node per subproblem; add cost per level; sum over levels.

- `T(n) = 2T(n/2) + n`: `log n` levels, each costing `n` → `Θ(n log n)`.

---

## 4. Randomized algorithms

Use randomization to make behavior **independent of adversarial input**.

### 4a. Uniform random permutation — Fisher–Yates / Knuth shuffle

```
RandomPermute(A):
    n ← A.length
    for i ← 1 to n:
        swap A[i] with A[Random(1, i)]     // uniform integer in [1, i]
```

- `O(n)` time, `O(1)` space; each of `n!` orderings equally likely (`1/n!`).
- ❌ **Bug:** `Random(1, n)` (full range) is **not** uniform.

### 4b. Randomized Quicksort

```
Quicksort(A, l, r):
    if l ≥ r: return
    m ← Partition(A, l, r)
    Quicksort(A, l, m-1)
    Quicksort(A, m+1, r)

Partition(A, l, r):                  // pivot = last element A[r]
    x ← A[r]
    i ← l - 1
    for j ← l to r-1:
        if A[j] ≤ x:
            i ← i + 1
            swap A[i], A[j]
    swap A[i+1], A[r]
    return i + 1                     // pivot position
```

- Invariant: `[l..i] ≤ x`, `[i+1..j-1] > x`, rest unrestricted.
- **Randomize:** swap a random element into `A[r]` before partitioning.
- Expected `Θ(n log n)`; worst case `Θ(n²)`.

### 4c. Randomized selection (find `i`-th smallest)

```
Select(A, l, r, i):
    if l = r: return A[l]
    choose random pivot in A[l..r]; swap with A[r]
    m ← Partition(A, l, r)
    k ← m - l + 1                    // pivot is k-th smallest in A[l..r]
    if i = k: return A[m]
    else if i < k: return Select(A, l, m-1, i)
    else:          return Select(A, m+1, r, i-k)
```

- Expected `Θ(n)`; a "good" pivot (middle 25–75%) halves the problem w.p. 1/2.

### 4d. D&C selection in two sorted arrays

```
Search(A1, A2, s1, e1, s2, e2, k):
    if k = 1: return min(A1[s1], A2[s2])
    if A1[s1 + k/2 - 1] < A2[s2 + k/2 - 1]:
        discard first k/2 elements of A1
        return Search(A1, A2, s1 + k/2, e1, s2, e2, k - k/2)
    else:
        discard first k/2 elements of A2
        return Search(A1, A2, s1, e1, s2 + k/2, e2, k - k/2)
```

- Cost `Θ(log k)`. **Idea:** compare the `k/2`-th element of each array and
  discard the smaller half.

---

## 5. Probabilistic analysis toolkit

Use for expected running times / counts.

### 5a. Core rules

- **Expectation:** `E[X] = Σ i · Pr[X = i]`.
- **Indicator variable:** if `X ∈ {0,1}` then `E[X] = Pr[X = 1]`.
- **Linearity:** `E[X + Y] = E[X] + E[Y]` — **no independence needed**.
- `E[XY] = E[X]E[Y]` **only** when `X`, `Y` independent.

### 5b. Hash table with chaining

- Hash function `h : U → {0..m-1}`; collision → linked list in slot.
- **Theorem:** for any key, expected #colliding keys ≤ `n/m` (load factor).

**Example (birthday paradox):** expected #pairs sharing a birthday among `k`
people: `E[X] = C(k,2) · (1/n)` where `n = 365`. It reaches ~1 around
`k ≈ √(2n) ≈ 28`.

### 5c. Hiring problem (expectation = harmonic number)

- In a random permutation, candidate `i` is hired iff they are best among first
  `i`, with prob `1/i`.
- `E[hires] = 1 + 1/2 + ⋯ + 1/n = H_n = Θ(log n)`.

### 5d. Geometric distribution (wait for first success)

- Success prob `p`; first success on trial `m`: `P(m) = p(1-p)^(m-1)`.
- `E[X] = 1/p`.

### 5e. Coupon collector

- `n` coupon types; expected trials to collect all = `n·H_n = Θ(n log n)`.
- Stage `i` (have `i` types, want `i+1`): success prob `(n-i)/n`, wait `n/(n-i)`;
  sum over stages.

### 5f. Useful series

- Finite geometric: `Σ_{i=1..j} a·r^(i-1) = a(1 - r^j)/(1 - r)`.
- Infinite (|r| < 1): `Σ_{i=1..∞} a·r^(i-1) = a/(1 - r)`.
- Harmonic: `H_n = Σ 1/i = Θ(log n)`.
- `log(n!) = Θ(n log n)` (Stirling).

---

## 6. Heaps & priority queues

Use when you repeatedly need the **max/min** among a changing set.

### 6a. Data structure facts (1-indexed array)

- Root `A[1]`; left child of `i` = `2i`; right = `2i+1`; parent = `⌊i/2⌋`.
- Height `⌊log n⌋`.
- **Max-heap property:** parent ≥ both children.

### 6b. Max-Heapify (bubble a violation down) — `O(log n)`

```
Max-Heapify(A, i):
    l ← 2i; r ← 2i+1; k ← i
    if l ≤ n and A[l] > A[k]: k ← l
    if r ≤ n and A[r] > A[k]: k ← r
    if k ≠ i:
        swap A[i], A[k]
        Max-Heapify(A, k)
```

### 6c. Build-Max-Heap — `O(n)`

```
Build-Max-Heap(A):
    for i ← ⌊n/2⌋ downto 1:
        Max-Heapify(A, i)
```

- **Why reverse order?** heapify works only when both children are already
  heaps; processing from bottom guarantees this.

### 6d. Extract-Max — `O(log n)`

```
Extract-Max(A):
    m ← A[1]
    A[1] ← A[n]; n ← n-1
    Max-Heapify(A, 1)
    return m
```

### 6e. Insert (bubble up) — `O(log n)`

```
Insert(A, x):
    n ← n+1; A[n] ← x; i ← n
    while i > 1 and A[⌊i/2⌋] < A[i]:
        swap A[⌊i/2⌋], A[i]; i ← ⌊i/2⌋
```

### 6f. Heapsort — `O(n log n)`, in-place

```
Heapsort(A):
    Build-Max-Heap(A)
    for i ← n downto 2:
        swap A[1], A[i]     // move max to its final sorted slot
        n ← n-1
        Max-Heapify(A, 1)
```

---

## 7. Linear-time (non-comparison) sorting

Use when **keys are bounded integers** — beats the `Ω(n log n)` comparison
bound by **not comparing**.

### 7a. Counting sort — `Θ(n + k)`

Input `A[1..n]`, each `A[j] ∈ {0..k}`.

```
CountingSort(A, B):
    C[0..k] ← 0
    for j ← 1 to n: C[A[j]] ← C[A[j]] + 1        // counts
    for i ← 1 to k: C[i] ← C[i] + C[i-1]         // prefix: #elements ≤ i
    for j ← n downto 1:
        B[C[A[j]]] ← A[j]
        C[A[j]] ← C[A[j]] - 1
```

- `C[i]` = number of elements `≤ i`; use it as the **next output index**.
- Stable if the last loop goes `n downto 1`.

### 7b. Radix sort — `Θ(d(n + k))`

Sort by **least significant digit → most significant digit**, using a stable
digit sort (counting sort) each pass.

```
RadixSort(A, d):           // d = max number of digits
    exp ← 1
    for i ← 1 to d:
        CountingSortByDigit(A, exp)
        exp ← exp * 10

CountingSortByDigit(A, exp):
    C[0..9] ← 0
    for j ← 1 to n: C[(A[j]/exp) mod 10]++
    for i ← 1 to 9: C[i] ← C[i] + C[i-1]
    for j ← n downto 1:
        digit ← (A[j]/exp) mod 10
        B[C[digit]] ← A[j]; C[digit]--
    copy B back into A
```

---

## 8. Lower bounds (decision tree model)

Use to argue a problem **cannot** be done faster with comparisons.

- Any binary tree with `N` leaves has height `≥ log₂ N`.
- **Searching** a sorted array of `n` keys: `≥ n+1` outputs → `Ω(log n)`.
- **Sorting** `n` keys: `≥ n!` outputs (permutations) → height
  `≥ log(n!) = Ω(n log n)`.
- Hence **comparison-based sorting** is `Ω(n log n)` — mergesort & heapsort are
  optimal; linear sorts must avoid comparisons.

---

## Quick "Which technique?" decision tree

1. **Need to sort?**
   - comparisons, general → Mergesort (guaranteed) / Quicksort (practice) /
     Heapsort (in-place)
   - small-integer keys → Counting / Radix sort
2. **Need the k-th smallest / median?** → Randomized selection `Θ(n)`
3. **Need repeated max/min + inserts?** → Heap (priority queue)
4. **Problem has overlapping sub-structure on halves?** → Divide & Conquer
5. **Problem reduces to same smaller problem?** → Recursion template
6. **Need expectation / average cost?** → indicator vars + linearity
7. **Want worst case independent of input?** → randomize (pivot, shuffle)
8. **Want to prove no faster comparison algorithm exists?** → decision tree
