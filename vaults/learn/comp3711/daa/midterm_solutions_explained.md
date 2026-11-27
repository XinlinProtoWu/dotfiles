# COMP3711 Midterm (Spring 2026) — Full Solutions Explained

Below I go through every question, explaining **why** each answer is correct and writing out the math step by step.

Throughout, "algorithm X is faster" means: for all large enough $n$, $T_X(n)$ is (asymptotically) smaller than the other algorithm's running time.

---

## Question 1 — Asymptotic Analysis

### 1(a) Comparing growth rates

The rule: **whichever running time grows slower is the faster algorithm.** So we compare the two functions in each case.

**Case 0 (example):** $T_A(n) = \Theta(n)$, $T_B(n) = \Theta(n^2)$.
Since $n$ grows slower than $n^2$, $A$ is faster → **A**.

---

**Case 1:** $T_A(n) = \Theta\!\left(\dfrac{n^2}{(\log n)^{10}}\right)$, $T_B(n) = \Theta(n^{1.5})$.

Compare by ratio:

$$
\frac{T_A(n)}{T_B(n)}
= \frac{n^2/(\log n)^{10}}{n^{1.5}}
= \frac{n^{2-1.5}}{(\log n)^{10}}
= \frac{n^{0.5}}{(\log n)^{10}}
\;\to\; \infty
$$

because any polynomial power $n^{0.5}$ grows faster than any fixed power of $\log n$. So $T_A$ grows **faster** than $T_B$, meaning $B$ is faster → **B**.

---

**Case 2:** $T_A(n) = \Theta(2^{\sqrt n})$, $T_B(n) = \Theta(10^{\sqrt[3]{n}})$.

Both are exponential in a sublinear exponent. Compare the exponents by taking logs (base 2):

$$
\log_2 T_A(n) = \sqrt n = n^{1/2},
\qquad
\log_2 T_B(n) = \sqrt[3]{n}\cdot \log_2 10 = c\cdot n^{1/3},\quad c \approx 3.32.
$$

Their ratio:

$$
\frac{\log_2 T_A(n)}{\log_2 T_B(n)}
= \frac{n^{1/2}}{c\,n^{1/3}}
= \frac{1}{c}\, n^{1/2 - 1/3}
= \frac{1}{c}\, n^{1/6}
\;\to\; \infty.
$$

So $\log_2 T_A \gg \log_2 T_B$, hence $T_A$ grows much faster than $T_B$. Therefore $B$ is faster → **B**.

---

**Case 3:** $T_A(n) = O(\sqrt{\log n})$, $T_B(n) = \Omega(\log \log n)$.

Here we only have an **upper** bound for $A$ and a **lower** bound for $B$:

- $T_A$ could be as small as $\Theta(1)$ (a constant) — then $A$ is faster;
- or $T_A$ could be as large as $\Theta(\sqrt{\log n})$, while $T_B$ could be as small as $\Theta(\log\log n)$ — then $B$ is faster.

Both scenarios are consistent with the given bounds, so we **cannot** decide which algorithm is always faster → **U**.

---

**Case 4:** $T_A(n) = \Theta(5^n)$, $T_B(n) = \Theta(7^n)$.

$$
\frac{T_B(n)}{T_A(n)} = \frac{7^n}{5^n} = \left(\frac{7}{5}\right)^n \;\to\; \infty.
$$

$T_B$ grows faster, so $A$ is faster → **A**.

---

**Case 5:** $T_A(n) = \Theta(n^2)$, and $T_B$ satisfies the merge-sort recurrence

$$
T_B(n) = 2T_B(n/2) + n,\quad T_B(1) = 1.
$$

Unroll it (assume $n$ is a power of 2):

$$
\begin{aligned}
T_B(n) &= 2T_B(n/2) + n \\
&= 2\Big(2T_B(n/4) + n/2\Big) + n = 4T_B(n/4) + 2n \\
&= 4\Big(2T_B(n/8) + n/4\Big) + 2n = 8T_B(n/8) + 3n \\
&\;\;\vdots \\
&= 2^k T_B(n/2^k) + k n.
\end{aligned}
$$

Stop at $k = \log_2 n$, where $n/2^k = 1$:

$$
T_B(n) = 2^{\log_2 n} T_B(1) + n\log_2 n = n\cdot 1 + n\log_2 n = \Theta(n\log n).
$$

Now compare:

$$
\frac{T_A(n)}{T_B(n)} = \frac{n^2}{n\log n} = \frac{n}{\log n} \;\to\; \infty.
$$

$T_A$ grows faster, so $B$ is faster → **B**.

**Final answer: 1-B, 2-B, 3-U, 4-A, 5-B.** ✓

---

### 1(b) Solving $T(n) = 64\,T(n/4) + n^3$, $T(1) = 1$ by unrolling

Note $64 = 4^3$. Unroll level by level:

$$
\begin{aligned}
T(n) &= 4^3\,T\!\left(\frac{n}{4}\right) + n^3 \\[4pt]
&= 4^3\left[4^3\,T\!\left(\frac{n}{4^2}\right) + \left(\frac{n}{4}\right)^3\right] + n^3 \\[4pt]
&= 4^6\,T\!\left(\frac{n}{4^2}\right) + 4^3\cdot\frac{n^3}{4^3} + n^3 \\[4pt]
&= 4^6\,T\!\left(\frac{n}{4^2}\right) + n^3 + n^3 \\[4pt]
&= 4^6\,T\!\left(\frac{n}{4^2}\right) + 2n^3 \\[4pt]
&= 4^9\,T\!\left(\frac{n}{4^3}\right) + 4^6\left(\frac{n}{4^2}\right)^3 + 2n^3 \\[4pt]
&= 4^9\,T\!\left(\frac{n}{4^3}\right) + 4^6\cdot\frac{n^3}{4^6} + 2n^3 \\[4pt]
&= 4^9\,T\!\left(\frac{n}{4^3}\right) + n^3 + 2n^3 \\[4pt]
&= 4^9\,T\!\left(\frac{n}{4^3}\right) + 3n^3.
\end{aligned}
$$

*(Note: the answer key has a typo "2n²" here — it should be $2n^3$, since $4^6(n/4^2)^3 = n^3$.)*

The pattern after $k$ unrollings:

$$
T(n) = 4^{3k}\,T\!\left(\frac{n}{4^k}\right) + k\,n^3.
$$

We reach the base case when $n/4^k = 1$, i.e. $4^k = n$, so

$$
k = \log_4 n.
$$

At that point $4^{3k} = (4^k)^3 = n^3$, and $T(1) = 1$, so

$$
\begin{aligned}
T(n) &= n^3\cdot T(1) + (\log_4 n)\,n^3 \\
&= n^3 + n^3\log_4 n \\
&= \Theta\big(n^3 \log n\big).
\end{aligned}
$$

Since $\log_4 n = \dfrac{\log n}{\log 4} = \Theta(\log n)$, the final answer is

$$
\boxed{T(n) = \Theta\!\left(n^3 \log n\right)}, \quad \alpha = 3,\ \beta = 1.
$$

**Intuition:** each of the $\log_4 n$ levels does $n^3$ total work ($4^3$ subproblems × $(n/4)^3$ work each $= n^3$), and there are $\log_4 n$ levels, plus the leaves contribute $n^3$.

---

## Question 2 — Randomization (Coupon Collector)

### 2(a) Expected boxes to collect $n/2$ distinct coupons

Let $X_i$ = number of boxes opened to go **from having $i$ distinct coupons to $i+1$ distinct coupons**.

When you already have $i$ distinct coupons, there are $n - i$ coupon types you still don't have. Each box gives a new coupon with probability

$$
p_i = \frac{n-i}{n}.
$$

So $X_i$ is a geometric random variable with success probability $p_i$, and its expectation is

$$
\mathbb{E}[X_i] = \frac{1}{p_i} = \frac{n}{n-i}.
$$

To collect $n/2$ distinct coupons, we need to go from $0$ distinct to $n/2$ distinct, so we sum $i = 0$ up to $n/2 - 1$:

$$
\begin{aligned}
\mathbb{E}[\text{total boxes}]
&= \sum_{i=0}^{n/2-1} \mathbb{E}[X_i] \\
&= \sum_{i=0}^{n/2-1} \frac{n}{n-i} \\
&= n\left(\frac{1}{n} + \frac{1}{n-1} + \cdots + \frac{1}{n/2+1}\right).
\end{aligned}
$$

Now bound the bracket.

**Upper bound:** there are $n/2$ terms, and every denominator is $\ge n/2$, so every term is $\le \dfrac{1}{n/2} = \dfrac{2}{n}$:

$$
\frac{1}{n} + \cdots + \frac{1}{n/2+1}
\;\le\; \frac{n}{2}\cdot\frac{2}{n} = 1.
$$

**Lower bound:** every denominator is $\le n$, so every term is $\ge \dfrac{1}{n}$:

$$
\frac{1}{n} + \cdots + \frac{1}{n/2+1}
\;\ge\; \frac{n}{2}\cdot\frac{1}{n} = \frac{1}{2}.
$$

Therefore the bracket is $\Theta(1)$, and

$$
\mathbb{E}[\text{total boxes}] = n\cdot\Theta(1) = \boxed{\Theta(n)}, \quad \alpha = 1,\ \beta = 0.
$$

Intuition: getting the first half of the coupons is "easy" — the hard part (the $\log n$ factor) only shows up when you try to collect the *last* few coupons.

---

### 2(b) Expected distinct coupons after opening exactly $n$ boxes

Use the hint. Define, for each coupon type $i$,

$$
X_i = \begin{cases} 1, & \text{if coupon type } i \text{ is } \textbf{not} \text{ collected}, \\ 0, & \text{otherwise}. \end{cases}
$$

For a single box, the probability of **not** getting type $i$ is $1 - \frac{1}{n}$. Since boxes are independent, the probability of missing type $i$ in **all $n$ boxes** is

$$
\Pr[X_i = 1] = \left(1 - \frac{1}{n}\right)^n.
$$

So by linearity of expectation,

$$
\mathbb{E}[X_i] = \left(1 - \frac{1}{n}\right)^n.
$$

The expected number of **missing** coupon types is

$$
\mathbb{E}\!\left[\sum_{i=1}^n X_i\right]
= \sum_{i=1}^n \mathbb{E}[X_i]
= n\left(1 - \frac{1}{n}\right)^n.
$$

Therefore the expected number of **distinct coupons collected** is

$$
\boxed{\;n - n\left(1 - \frac{1}{n}\right)^n\;}.
$$

As $n \to \infty$, $\left(1 - \frac{1}{n}\right)^n \to \frac{1}{e} \approx 0.368$, so this is approximately

$$
n\left(1 - \frac{1}{e}\right) \approx 0.63\,n.
$$

(That final approximation is not required for credit, but it's the intuition.)

---

## Question 3 — Searching: distinct values + frequencies in $O((\log n)^2)$

**Setup.** $A[1..n]$ is sorted (non-decreasing) and has $m = \Theta(\log n)$ **distinct** values. Because the array is sorted, all copies of each value form one **contiguous block**:

$$
A[1..k_1],\ A[k_1{+}1..k_2],\ \dots,\ A[k_{m-1}{+}1..n]
$$

where block $j$ is all copies of the $j$-th distinct value.

So the whole problem reduces to: **find the end index of each block.** Once we know a block is $A[\ell..r]$ with value $v$, its frequency is $r - \ell + 1$.

### The key subroutine `Search(A, p, r, x)`

Precondition: $A[p] = x$ and $p \le r$. It returns the **largest** index $k \in [p,r]$ with $A[k] = x$ (the right end of $x$'s block).

It's a binary search:

```
Search(A, p, r, x):
  if p = r or A[r] = x:
      return r
  else:
      q = floor((p+r)/2)
      if A[q] = x:
          if A[q+1] > x: return q
          else: return Search(A, q+1, r, x)
      else:            # here A[q] > x (cannot be < x, since A[p]=x and A sorted)
          return Search(A, p, q-1, x)
```

**Why it's correct:**

- If $p = r$, there's only one position, which must be $x$ → return $r$.
- If $A[r] = x$, then since the array is sorted and $A[p] = x$, everything in $[p,r]$ is $x$ → the right end is $r$.
- Otherwise $A[r] > x$. Look at the midpoint $q$:
  - If $A[q] = x$:
    - if $A[q+1] > x$, then $q$ is exactly the last occurrence → return $q$;
    - else $A[q+1] = x$, so the block extends past $q$ → search right half $[q+1, r]$.
  - If $A[q] > x$, the block of $x$ ends before $q$ → search left half $[p, q-1]$. (The precondition $A[p]=x$ is still satisfied.)

**Running time of `Search`:** each call halves the index range ($q$ is strictly between the new endpoints), doing $O(1)$ work, so it satisfies $T(n) = T(n/2) + O(1)$, giving $O(\log n)$.

### The overall algorithm

1. $i \leftarrow 1$ (index of the start of the current block).
2. Call `Search(A, i, n, A[i])` → get $k$, the end of the current block.
3. Output the pair $\big(A[i],\ k - i + 1\big)$ — the value and its frequency.
4. If $k = n$, we're done (that was the last block).
5. Otherwise set $i \leftarrow k + 1$ (start of the next block, whose value is guaranteed to be strictly larger since $A$ is sorted) and go back to step 2.

**Correctness:** each iteration correctly identifies one complete block (value + its exact count) and moves to the beginning of the next block. Since $A$ is finite and each step moves past at least one element, it terminates when the last block ends at $n$.

**Running time:** each block costs one `Search` = $O(\log n)$. There are $m = \Theta(\log n)$ blocks. Hence

$$
\text{total time} = m \cdot O(\log n) = O(\log n)\cdot O(\log n) = \boxed{O\!\left((\log n)^2\right)}.
$$

This beats the $O(n)$ scan because $m$ (the number of distinct values) is only $\Theta(\log n)$, so we only need $\Theta(\log n)$ binary searches.

---

## Question 4 — Heaps

### 4(a) Min-heap insertions

**Recall the rules of a min-heap:**
1. It's a **complete** binary tree (fill level by level, left to right).
2. Every parent is $\le$ its children.
3. **Insert:** place the new key in the next free position (leftmost empty spot on the bottom level), then **bubble up**: repeatedly swap it with its parent while it's smaller than its parent.

Insert the sequence $5, 8, 1, 4, 7, 3, 2, 6$.

**After inserting 5:**
```
5
```

**After inserting 8** (8 is 5's left child; $8 > 5$, no swap):
```
  5
 /
8
```

**After inserting 1** (right child of 5; $1 < 5$, so swap → 1 becomes root):
```
  1
 / \
8   5
```

**After inserting 4** (left child of 8; $4 < 8$, swap; now $4 > 1$, stop):
```
    1
   / \
  4   5
 /
8
```

**After inserting 7** (right child of 4; $7 > 4$, no swap):
```
    1
   / \
  4   5
 / \
8   7
```

**After inserting 3** (left child of 5; $3 < 5$, swap; now $3 > 1$, stop):
```
      1
     / \
    4   3
   / \ /
  8  7 5
```

**After inserting 2** (right child of 3; $2 < 3$, swap; now $2 > 1$, stop):
```
      1
     / \
    4   2
   / \ / \
  8  7 5  3
```

**After inserting 6** (left child of 8; $6 < 8$, swap; now $6 > 4$, stop). **Final heap:**
```
        1
       / \
      4   2
     / \ / \
    6  7 5  3
   /
  8
```

---

### 4(b) Finding the largest $\lceil \log_2 n\rceil$ numbers in $O(n \log\log n)$

> **Note on the answer key:** the key's text says to use a *min*-heap on the *first* (smallest) element of each block and "extract min." As written, that would output the **smallest** elements, which contradicts the problem asking for the **largest** ones. The intended (correct) algorithm uses a **max-heap** starting from the **last** (largest) element of each block and "extract max." The running time is identical either way. I explain the correct version below.

**Step 1 — Sort blocks of size $\log_2 n$.**
Partition $A$ into $\dfrac{n}{\log_2 n}$ blocks, each of size $\log_2 n$. Sort each block in increasing order.

- Sorting one block of size $s = \log_2 n$ takes $O(s \log s) = O(\log n \cdot \log\log n)$ (e.g., mergesort or heapsort).
- Total over all blocks:

$$
\frac{n}{\log n}\cdot O(\log n \cdot \log\log n)
= O(n \log \log n).
$$

Call the sorted blocks $B_1, B_2, \dots$, and store pairs $(i, \text{value})$ so we can track which block an element came from.

**Step 2 — Build a max-heap of block maxima.**
Put the **largest** element of each block (the last entry of each sorted block) into a **max-heap** keyed on value. There are $n/\log n$ elements.

- Each insertion costs $O\!\left(\log\frac{n}{\log n}\right) = O(\log n)$.
- Total: $\dfrac{n}{\log n}\cdot O(\log n) = O(n)$.

Also keep a pointer $p_i$ for each block, initially pointing at its last element.

**Step 3 — Extract the max $\lceil \log_2 n\rceil$ times.**
Repeat:
1. Extract-max from the heap; suppose it returns $(i, v)$.
2. Output $v$ (this is the next largest overall).
3. Move block $i$'s pointer one step left and insert the new element $B_i[p_i]$ into the heap.

We do $\lceil \log_2 n\rceil$ extractions + insertions, each $O(\log n)$:

$$
O(\log n)\cdot O(\log n) = O(\log^2 n).
$$

**Correctness idea:** this is a standard **$k$-way merge** of the sorted blocks, run "backwards." At any moment the heap contains the largest *not-yet-output* element of each block, so the maximum of the heap is the largest remaining element overall.

**Total running time:**

$$
\underbrace{O(n\log\log n)}_{\text{step 1}}
+\underbrace{O(n)}_{\text{step 2}}
+\underbrace{O(\log^2 n)}_{\text{step 3}}
= \boxed{O(n \log \log n)}.
$$

Step 1 dominates (since $n \log\log n$ grows faster than both $n$ and $\log^2 n$).

---

## Summary of key takeaways

- **Q1:** compare growth rates (polynomial beats polylog; bigger base/root decides exponentials; $O$/$\Omega$ alone can't determine order); unroll recurrences.
- **Q2:** geometric random variables for coupon collector; linearity of expectation.
- **Q3:** sorted array ⇒ blocks of duplicates ⇒ binary-search each block's right endpoint; $m = \Theta(\log n)$ blocks × $O(\log n)$ each.
- **Q4:** min-heap insert + bubble-up; and $k$-way merge over sorted blocks for top-$k$ in $O(n\log\log n)$.
