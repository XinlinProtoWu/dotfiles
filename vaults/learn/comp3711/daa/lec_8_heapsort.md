## Motivation: Priority Queues

A **priority queue** stores elements each with a *priority* (key) and supports:

- **Insert(x)** — add an element
- **Extract-Max** — remove and return the element with the largest priority

Use case: OS process scheduling (CPU runs the highest-priority process next).

| Data structure | Insert       | Extract-Max                 |
| -------------- | ------------ | --------------------------- |
| Unsorted list  | O(1)         | O(n)                        |
| Sorted list    | O(n)         | O(1)                        |
| BST            | O(log n)     | O(log n) but heavy overhead |
| **Heap**       | **O(log n)** | **O(log n)**, tiny overhead |

We can turn a heap into a **sorting algorithm** — that's heapsort.

---

## What is a Heap

A **max-heap** is a *complete binary tree* with the **heap-order property**:

> Every node's priority ≥ priority of both its children.

Two structural facts:

1. **Complete binary tree**: all levels full except possibly the last; the last level is packed from the left.
2. **Array representation — no pointers needed** (1-indexed):
   - root = `A[1]`
   - left child of `A[i]` = `A[2i]`
   - right child of `A[i]` = `A[2i+1]`
   - parent of `A[i]` = `A[⌊i/2⌋]`

Height of a heap with `n` nodes: **`h = ⌊log n⌋`**

Example (n = 7):

```
        9
       / \
      7   8
     / \ / \
    1  5 3  2
```

Array form: `[9, 7, 8, 1, 5, 3, 2]` — check the indexing: node 1 (9) has children at 2 and 3 (7, 8); node 2 (7) has children at 4 and 5 (1, 5); etc.

> A **min-heap** is the same but every node ≤ its children. To get a min-heap from a max-heap, negate the priorities.

---

## The Core Operation: Max-Heapify ("bubble down")

`Max-Heapify(A, i)` fixes a *single* violation at node `i`, assuming both of `i`'s subtrees are already valid heaps.

```
Max-Heapify(A, i):
    l ← 2i, r ← 2i+1
    k ← i
    if l ≤ n and A[l] > A[k]: k ← l      // find largest among i and children
    if r ≤ n and A[r] > A[k]: k ← r
    if k ≠ i:
        swap A[i] and A[k]
        Max-Heapify(A, k)                // the swapped child may now violate
```

**Principle:** compare node `i` with its two children; if a child is bigger, swap with the *largest* child, then recurse down that branch. Each swap moves the violation one level deeper.

**Time:** `O(log n)` — at most the height of the tree.

---

## Building a Heap

```
Build-Max-Heap(A):
    for i ← ⌊n/2⌋ downto 1:
        Max-Heapify(A, i)
```

**Key principle — why reverse order?**

- Leaves (indices `⌊n/2⌋+1 … n`) are already trivial heaps.
- `Max-Heapify(A, i)` only works correctly when **both subtrees of `i` are already heaps**.
- Going from `⌊n/2⌋` **down to 1** guarantees that by the time we heapify node `i`, its children (at larger indices, already processed) are heaps.

### Simple example

Start with `A = [7, 5, 2, 1, 9, 3, 8]`, `n = 7`, so `⌊n/2⌋ = 3`.

Initial tree:

```
        7
       / \
      5   2
     / \ / \
    1  9 3  8
```

- **i = 3** (value 2): children 6=3, 7=8 → 8 is largest → swap → value 8 moves up.
- **i = 2** (value 5): children 4=1, 5=9 → 9 is largest → swap → value 9 moves up.
- **i = 1** (value 7): children 2=9, 3=8 → 9 is largest → swap; now node 2 holds 7, whose children (1, 5) are both smaller, so stop.

Result:

```
        9
       / \
      7   8
     / \ / \
    1  5 3  2
```

`[9, 7, 8, 1, 5, 3, 2]` — a valid max-heap.

**Running time of build:** `O(n)`, not `O(n log n)`. A node at level `i` is heapified at cost `O(h − i)`, and summing over levels gives `O(n)` (most nodes are near the bottom and cost almost nothing).

---

## Extract-Max (remove the biggest element)

```
Extract-Max(A):
    m ← A[1]          // root is the max
    A[1] ← A[n]       // move last element to root
    n ← n − 1
    Max-Heapify(A, 1) // fix the root
    return m
```

**Principle:** the max is always at the root. Remove it by overwriting the root with the *last* array element, shrink the heap, and bubble the new root down.

**Time:** `O(log n)`.

---

## Insert (add an element) — "bubble up"

```
Insert(A, x):
    n ← n + 1
    A[n] ← x
    i ← n
    while i > 1 and A[⌊i/2⌋] < A[i]:
        swap A[⌊i/2⌋] and A[i]
        i ← ⌊i/2⌋
```

**Principle:** append at the next free leaf slot, then repeatedly swap upward while the parent is smaller. Opposite direction of Max-Heapify.

**Time:** `O(log n)`.

---

## Heapsort

**Idea:** repeatedly extract the max — but reuse the freed array slots to hold the sorted output, so no extra space is needed.

```
Heapsort(A):
    Build-Max-Heap(A)
    for i ← n downto 2:
        swap A[1] and A[i]
        n ← n − 1
        Max-Heapify(A, 1)
```

**Principle:**

1. Build a max-heap → the largest element is at `A[1]`.
2. Swap `A[1]` with `A[n]` → the largest element lands in its final sorted position (the end of the array).
3. Shrink the heap by 1 (exclude that last slot) and re-heapify the root.
4. Repeat. After each iteration, the end of the array fills up with the largest remaining elements, in place.

Because we only ever swap and heapify inside `A`, this is **in-place** — `O(1)` extra working space.

### Simple example

Start from the heap we built: `[9, 7, 8, 1, 5, 3, 2]`.

- **i = 7:** swap `A[1]=9` and `A[7]=2` → `[2, 7, 8, 1, 5, 3, 9]`; heapify the root over size 6 → `[8, 7, 3, 1, 5, 2, 9]`. Now `9` is locked at the end.
- **i = 6:** swap `8` with `2` → heapify size 5 → `[7, 5, 3, 1, 2, 8, 9]`. Now `8, 9` locked.
- **i = 5:** swap `7` with `2` → heapify size 4 → `[5, 2, 3, 1, 7, 8, 9]`. Now `7, 8, 9` locked.
- … continue swapping root with the last heap slot and heapifying …

Final result:

```
[1, 2, 3, 5, 7, 8, 9]   ✓ sorted ascending
```

The locked region grows from the right; the heap shrinks from the right.

---

## Running Times (summary)

| Operation | Time |
|---|---|
| Max-Heapify | O(log n) |
| Build-Max-Heap | O(n) |
| Extract-Max | O(log n) |
| Insert | O(log n) |
| **Heapsort** | **O(n log n)** worst-case |

- **Working space:** O(1) — in-place.
- **Stability:** not stable (equal elements can be reordered by the swaps).
- **Comparison-based:** yes → matches the `Ω(n log n)` sorting lower bound, so it's *asymptotically optimal* like mergesort.

---

## Key ideas to remember

1. A heap = complete binary tree + heap-order property, stored in a flat array.
2. **Max-Heapify** bubbles a violation *down* — the workhorse (O(log n)).
3. **Build-Max-Heap** heapifies in *reverse* order so every subtree is already a heap (O(n) total).
4. **Extract-Max** = move last element to root + bubble down.
5. **Heapsort** = build heap, then repeatedly swap root to the end and re-heapify — sorted in place, O(n log n), no extra array.
