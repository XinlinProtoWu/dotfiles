# COMP3711 — HW2 Solutions (Greedy, Divide & Conquer, Randomized, Heaps, Radix Sort)

These solutions use the ideas from `lec_8_heapsort.md`, `lec_9_linearsort.md`, `lec_10-11_greedy.md`, and the earlier divide-and-conquer / quicksort notes.

---

## Problem 1 — Local Minimum in an n × n Grid

### (a) Divide-and-conquer algorithm in O(n)

**Idea.** Instead of scanning the whole grid, scan only the **middle row and middle column** (the "cross") of the current square. Find the smallest value on that cross. If it is smaller than all its neighbors, return it. Otherwise, move into the **quadrant** that contains a smaller neighbor and recurse. Each step halves both the number of rows and columns, so the total work is a geometric series.

```text
LocalMin(A, top, bottom, left, right):
    size <- bottom - top + 1

    // Base case: scan the small square and return its minimum cell.
    if size ≤ 2 then
        minRow <- top
        minCol <- left
        for row <- top to bottom do
            for col <- left to right do
                if A[row, col] < A[minRow, minCol] then
                    minRow <- row
                    minCol <- col
                end if
            end for
        end for
        return (minRow, minCol)
    end if

    midRow <- floor((top + bottom) / 2)
    midCol <- floor((left + right) / 2)

    // Find the minimum cell on the middle row + middle column (the cross).
    crossMinRow <- midRow
    crossMinCol <- left
    for col <- left + 1 to right do
        if A[midRow, col] < A[crossMinRow, crossMinCol] then
            crossMinRow <- midRow
            crossMinCol <- col
        end if
    end for
    for row <- top to bottom do
        if A[row, midCol] < A[crossMinRow, crossMinCol] then
            crossMinRow <- row
            crossMinCol <- midCol
        end if
    end for

    // If a neighbor is smaller, remember it; otherwise this is the answer.
    if crossMinRow > top and
       A[crossMinRow - 1, crossMinCol] < A[crossMinRow, crossMinCol] then
        neighborRow <- crossMinRow - 1
        neighborCol <- crossMinCol
    else if crossMinRow < bottom and
            A[crossMinRow + 1, crossMinCol] < A[crossMinRow, crossMinCol] then
        neighborRow <- crossMinRow + 1
        neighborCol <- crossMinCol
    else if crossMinCol > left and
            A[crossMinRow, crossMinCol - 1] < A[crossMinRow, crossMinCol] then
        neighborRow <- crossMinRow
        neighborCol <- crossMinCol - 1
    else if crossMinCol < right and
            A[crossMinRow, crossMinCol + 1] < A[crossMinRow, crossMinCol] then
        neighborRow <- crossMinRow
        neighborCol <- crossMinCol + 1
    else
        return (crossMinRow, crossMinCol)   // no smaller neighbor
    end if

    // Recurse into the quadrant that contains the smaller neighbor.
    if neighborRow < midRow then
        quadTop <- top
        quadBottom <- midRow - 1
    else
        quadTop <- midRow + 1
        quadBottom <- bottom
    end if

    if neighborCol < midCol then
        quadLeft <- left
        quadRight <- midCol - 1
    else
        quadLeft <- midCol + 1
        quadRight <- right
    end if

    return LocalMin(A, quadTop, quadBottom, quadLeft, quadRight)
```

For `size ≤ 2`, the base case scans all (at most 4) cells and returns the smallest one.

### (b) Recurrence

Scanning the cross of an `m x m` square costs `Θ(m)` (there are `2m - 1` cells on the cross). The recursive call is on a quadrant of side length at most `⌈m/2⌉`, so

```
T(n) = T(n/2) + Θ(n)
```

Solving the recurrence:

```
T(n) = Θ(n) + Θ(n/2) + Θ(n/4) + ... = Θ(n (1 + 1/2 + 1/4 + ...))
     = Θ(2n)
     = Θ(n)
```

So the running time is **O(n)**.

### (c) Correctness

**Correctness:** If the cross-minimum `c` has no smaller neighbor, then `c` is a local minimum and the algorithm returns it. Otherwise `c` has a smaller neighbor `d`. Since `c` is the smallest cell on the cross, `d` is not on the cross, so `d` lies in a quadrant `Q`; moreover every cross cell (the boundary of `Q`) is larger than `d`. Following strictly decreasing neighbors from `d` can therefore never leave `Q`, so it must end at a local minimum of the whole grid, which the recursion finds. Squares of technique produces a completely sorted permutation of A.side `≤ 2` are solved by scanning all their cells.

---

## Problem 2 — Reservoir Sampling

### (a) Induction proof: every item is in R with probability `k/t`

**Claim.** After processing `x_t` (`t ≥ k`), each of `x_1, ..., x_t` is in the reservoir with probability exactly `k/t`.

**Proof.** The claim is immediate for `t = k`, since all `k` items are stored. Now assume it holds after step `t-1`. The new item `x_t` is kept with probability `k/t`. For an earlier item `x_i`, it is in R after step `t` iff it was in R after step `t-1` (probability `k/(t-1)` by induction) and its slot is not replaced at step `t` (probability `1 - 1/t`). Hence `P(x_i in R after t) = k/(t-1) · (t-1)/t = k/t`. Both old and new items therefore have probability `k/t`.

### (b) Are `E_i = {x_i ∈ R}` and `E_j = {x_j ∈ R}` independent?

**No.** The events are negatively correlated because the reservoir has fixed size `k`.

A tiny counterexample: `k = 1`, `t = 2`.

```
P(E_1) = 1/2,   P(E_2) = 1/2
P(E_1 ∩ E_2) = 0        // a size-1 reservoir cannot contain both items
```

If they were independent we would have `P(E_1 ∩ E_2) = 1/4`, but it is actually `0`. Hence they are **not independent**.

In general, the set of `k` items in the reservoir is a uniformly random `k`-subset of `{x_1,...,x_t}`, so

```
P(i and j both in R) = C(t-2, k-2) / C(t, k)
                     = k(k-1)/(t(t-1))
                     < (k/t)^2 = P(i in R) · P(j in R)
```

which again shows negative correlation, not independence.

### (c) Expected number of items that ever reside in the reservoir

For each item, define an indicator `I_t = 1` if `x_t` ever resides in R.

- For `t ≤ k`: `x_t` is always placed in R initially, so `E[I_t] = 1`.
- For `t > k`: `x_t` enters R at step `t` with probability `k/t`, so `E[I_t] = k/t`.

By linearity of expectation:

```
E[total] = Σ_{t=1}^{N} E[I_t]
         = k + Σ_{t=k+1}^{N} (k/t)
         = k + k (H_N - H_k)          // H_m = 1 + 1/2 + ... + 1/m
```

Since `H_N - H_k = Θ(log(N/k))`, the tight asymptotic bound is

```
E[total] = Θ(k + k log(N/k))
```

(Equivalently `Θ(k(1 + log(N/k)))`. When `N ≫ k`, this is simply `Θ(k log(N/k))`; the extra `+k` covers the case where `N` is close to `k`.)

---

## Problem 3 — Quicksort with Duplicates (3-Way Quicksort)

### (a) Bad instance with ties

Take an array of **all equal elements**, e.g.

```
A = [1, 1, 1, ..., 1]   (n copies of 1)
```

With the usual 2-way partition (elements are split into `≤ pivot` and `> pivot`), every pivot leaves all other `n-1` equal elements on one side, so each call does `Θ(n)` work and recurses on `n-1` elements:

```
T(n) = T(n-1) + Θ(n) = Θ(n^2)
```

The pivot choice does not matter (every pivot behaves the same), so even randomized quicksort takes **`Θ(n^2)` time in expectation**.

### (b) Complete the 3-way quicksort pseudocode

The invariants are:

- `A[l .. lt-1]` contains elements `< pivot`
- `A[lt .. i-1]` contains elements `= pivot`
- `A[gt+1 .. r]` contains elements `> pivot`
- `A[i .. gt]` is still unprocessed

```text
procedure Quicksort3Way(A, l, r)
    if l ≥ r then
        return
    end if

    pivot <- A[random(l, r)]       // one element chosen uniformly from A[l..r]

    lt <- l                        // A[l..lt-1] < pivot
    i  <- l                        // A[lt..i-1] = pivot
    gt <- r                        // A[gt+1..r] > pivot

    while i ≤ gt do
        if A[i] < pivot then
            temp <- A[i]
            A[i] <- A[lt]
            A[lt] <- temp
            lt <- lt + 1
            i <- i + 1
        else if A[i] > pivot then
            temp <- A[i]
            A[i] <- A[gt]
            A[gt] <- temp
            gt <- gt - 1
        else
            i <- i + 1
        end if
    end while

    Quicksort3Way(A, l, lt - 1)   // sort the < pivot part
    Quicksort3Way(A, gt + 1, r)   // sort the > pivot part
end procedure
```

So:

- **(A)** `i ≤ gt`
- **(B)** `temp <- A[i]; A[i] <- A[lt]; A[lt] <- temp; lt <- lt + 1; i <- i + 1`
- **(C)** `temp <- A[i]; A[i] <- A[gt]; A[gt] <- temp; gt <- gt - 1` (do **not** increment `i`, because the swapped-in element has not been inspected yet)
- **(D)** `i <- i + 1`

### (c) Why `E[X_ij] ≤ 2/(j-i+1)`

**Setup.** Sort the elements into `z_1, ..., z_n`, breaking ties arbitrarily. For a pair `i < j`, define the **block**

```
B = { z_k : z_i ≤ z_k ≤ z_j }
```

that is, all elements whose value lies in `[z_i, z_j]`. In sorted order `B` is a contiguous run `z_a, ..., z_b` with `a ≤ i < j ≤ b`, so

```
|B| = b - a + 1 ≥ j - i + 1.
```

**Key observation.** `z_i` and `z_j` are compared **iff the first pivot chosen from `B` is `z_i` or `z_j`.**

- *Before* any pivot from `B` is chosen, all of `B` stays in one subproblem: any pivot with value `< z_i` or `> z_j` sends all of `B` to the same side. (There is no pivot outside `B` whose value lies in `[z_i, z_j]`, by definition of `B`.)
- If the first pivot from `B` is `z_i` or `z_j`, then one of them is the pivot and the other is still in the same subarray, so they are compared (`X_ij = 1`).
- If the first pivot from `B` is some other `z_p` (`p ≠ i, j`), its value lies in `[z_i, z_j]`, so `z_i` and `z_j` are sent to different regions (`<`, `=`, or `>`), and are never compared with each other now or later (`X_ij = 0`).

Since the pivot is chosen uniformly within each subarray, and `B` stays together until its first pivot, the **first pivot from `B` is uniform over `B`**. Hence

```
E[X_ij] = P(first pivot from B is z_i or z_j) = 2/|B| ≤ 2/(j-i+1).
```

**The two cases requested by the hint.**

- **Case `z_i = z_j`:** every element of `B` has the same value `v`, so `|B| = m`, the multiplicity of `v`. Then

```
E[X_ij] = 2/m ≤ 2/(j-i+1)
```

  because `m ≥ j-i+1`. (Equal elements *are* compared when one of them is the pivot, which is why the probability is `2/m`, not `0`.)

- **Case `z_i < z_j`:** `B` contains every value in `[z_i, z_j]`, so

```
E[X_ij] = 2/|B| ≤ 2/(j-i+1).
```

  If all values are distinct then `|B| = j-i+1` and equality holds.

**Summing over all pairs.** Each pair counted by `X_ij = 1` is compared at most twice (once as `< pivot`, once as `> pivot`), so the total number of comparisons `C` satisfies

```
E[C] ≤ 2 · Σ_{i<j} E[X_ij] ≤ 2 · Σ_{i<j} 2/(j-i+1) = 4 · Σ_{i<j} 1/(j-i+1).
```

Now evaluate the sum. Group pairs by their distance `d = j - i` (there are `n - d` such pairs, `d = 1, ..., n-1`):

```
Σ_{i<j} 1/(j-i+1) = Σ_{d=1}^{n-1} (n - d)/(d + 1)
                  ≤ n · Σ_{d=1}^{n-1} 1/(d + 1)
                  = n (H_n - 1)
                  = O(n log n).
```

Therefore

```
E[C] = O(n log n).
```

Each partition iteration does `O(1)` work per comparison, and the recursive-call overhead is `O(n)` in total (every non-trivial call retires at least one element into the `=` region, so there are `O(n)` calls). Hence the expected running time is `O(n log n)`.

---

## Problem 4 — k-th Smallest Element in a Read-Only Min-Heap
>[!todo]
>What is extractmin and why does it cost o(logn)
>what is an invariant?
>suffix of a string?
### (a) Naive approach and why it is unsatisfactory

The naive approach calls `Extract-Min` `k` times on `H`. Each `Extract-Min` costs `O(log n)` because it must restore the heap property, so the total is

```
O(k log n)
```

Two problems:

1. **It modifies the heap.** `Extract-Min` removes elements from `H`. If `H` is read-only, we would first have to copy all `n` elements into a new heap, costing `O(n)` extra time and space — which defeats the purpose when `k ≪ n`.
2. **It depends on `log n` rather than `log k`.** We can do better by working only with `k` candidate elements, giving `O(k log k)`.

### (b) Algorithm using an auxiliary heap of size ≤ k

The key observation: in a min-heap, every element is `≥` its parent. So the next smallest element is always one of the children of the elements already extracted.

```text
KthSmallest(H, n, k):
    if k < 1 or k > n then
        return error
    end if

    frontier <- empty min-heap of pairs (value, index)

    Insert(frontier, (H[1], 1))              // root is the smallest candidate

    for i <- 1 to k do
        // value is the i-th smallest element of the whole heap
        (value, nodeIndex) <- Extract-Min(frontier)

        if i = k then
            return value
        end if

        leftChild <- 2 * nodeIndex
        rightChild <- 2 * nodeIndex + 1

        if leftChild ≤ n then
            Insert(frontier, (H[leftChild], leftChild))
        end if

        if rightChild ≤ n then
            Insert(frontier, (H[rightChild], rightChild))
        end if
    end for
```

We stop and return after the `k`-th extraction, so we never insert children of the `k`-th extracted node, and the frontier never exceeds `k` elements.

### (c) Correctness, time, and space

**Correctness (short).**

- **Invariant:** `frontier` always holds exactly the children of the nodes extracted so far (initially just the root).
- **The next minimum is in `frontier`:** take any unextracted element `u`. The topmost unextracted node `v` on the path from the root down to `u` is a child of an extracted node, so `v` is in `frontier`. Since parent ≤ child along that path, `v ≤ u`. So `frontier` contains some element ≤ every unextracted element.
- **Conclusion:** the minimum of `frontier` is the smallest unextracted element. Extracting it repeatedly therefore yields the elements of `H` in sorted order, so the `i`-th extraction is the `i`-th smallest.

**Running Time:** There are `k` iterations. Each `insert`/`extract-min` on `frontier` costs `O(log |frontier|)`, and `|frontier| ≤ k` throughout. Total time: **`O(k log k)`**.

**Space:** `frontier` stores at most `k` pairs, so **`O(k)`** auxiliary space. The original heap `H` is only read, never modified.

---

## Problem 5 — Sorting Variable-Length Strings

### (a) Bad input for padded radix sort

Let the total number of characters be `n`. Consider the input consisting of:

- **one string** of length `n/2`, and
- **`n/2` strings** of length `1`.

Total characters = `n/2 + n/2 = n`. ✔

The maximum string length is `L = n/2`. After padding all strings with nulls to length `L`, radix sort performs `L` passes, and each pass processes all `m = n/2 + 1` strings:

```
cost = Ω(L · m) = Ω((n/2) · (n/2 + 1)) = Ω(n^2)
```

So padded radix sort takes **`Ω(n^2)`** time on this input.

### (b) O(n) algorithm

**Main idea (from the hint).** First sort the strings by length. Then run LSD radix sort from the longest character position down to position 1, but at each position `d` touch **only** the strings of length `≥ d`. Padded nulls are never examined, so the cost is proportional to the real characters.

**Algorithm (pseudocode).**

```text
SortStrings(strings):
    // Step 1: stable counting sort by length (all lengths are in [0, n]).
    strings <- CountingSortByLength(strings)

    L <- max length over all strings

    // Step 2: LSD radix sort, touching only real characters.
    for d <- L downto 1 do
        s0 <- first index s with length(strings[s]) >= d
        // strings[s0..numStrings] is the suffix of strings that have a d-th character
        strings[s0..numStrings] <- StableCountingSortByChar(strings[s0..numStrings], d)
    end for

    return strings
```

Because of Step 1, the strings with `length >= d` form a contiguous suffix, so `s0` is well defined and only that block is ever sorted.

**Correctness sketch.** This is exactly LSD radix sort on the null-padded strings, minus the nulls. A null sorts before every real character, which is what makes a shorter string precede a longer string that shares its prefix; sorting by length first encodes that fact. Standard LSD radix sort correctness then gives lexicographic order (`a < ab < b`).

**Running time.** The length sort costs `O(n)` (the number of strings and the maximum length are both `≤ n`). Each LSD pass visits only the real characters at that position; over all positions, every character is visited once, so `O(n)`. Total: **`O(n)`** time, `O(n)` space.

---

## Summary of Answers

| Problem | Answer |
| ------- | ------ |
| 1 | Cross-based divide-and-conquer, `T(n) = T(n/2) + Θ(n) = O(n)` |
| 2(a) | Induction gives `k/t` for every item |
| 2(b) | Not independent (negatively correlated) |
| 2(c) | `k + Σ_{t=k+1}^N k/t = k + k(H_N - H_k) = Θ(k + k log(N/k))` |
| 3(a) | All-equal array gives `Θ(n^2)` |
| 3(b) | `(A) i ≤ gt`, `(B) swap(A[i], A[lt]); lt <- lt + 1; i <- i + 1`, `(C) swap(A[i], A[gt]); gt <- gt - 1`, `(D) i <- i + 1` |
| 3(c) | Equal pairs never compared; distinct pairs compared with prob `2/(j-i+1)` |
| 4 | Auxiliary min-heap of frontier; `O(k log k)` time, `O(k)` space |
| 5(a) | One length-`n/2` string + `n/2` length-1 strings → `Ω(n^2)` |
| 5(b) | Sort by length, LSD radix sort only real characters → `O(n)` |
