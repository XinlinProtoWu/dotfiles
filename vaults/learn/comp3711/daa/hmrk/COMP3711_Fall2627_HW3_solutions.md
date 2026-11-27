# COMP 3711 — Written Assignment 3 — Solutions

**Name:** ____________________________  
**Student ID:** ______________________  
**Email:** ___________________________

---

## 1. Lexicographically smallest array, ≤ K adjacent swaps

### (a) Idea

Build the output left to right. With `K` swaps remaining, the next element can only
come from the first `min(K+1, n)` elements of the current array. So repeatedly:

- find the **minimum** among the first `K+1` remaining elements,
- move it to the current front with adjacent swaps,
- subtract the number of swaps used from `K`.

### (b) Correctness

**Claim.** Greedy is optimal.

**Proof sketch (induction on length N).** Let `p` be the index of the smallest element
among the first `min(b+1, N)` elements of `S`. Greedy moves `S[p]` to the front using
`p-1` swaps.

- Any element after position `b+1` needs `> b` swaps to reach the front, so no reachable
  sequence can start with anything smaller than `S[p]`.
- Since `S[p]` itself is reachable as the first element, the optimal sequence must start
  with `S[p]`.
- Moving `S[p]` to the front costs at least `p-1` swaps, leaving budget `b-(p-1)` on the
  remaining sequence `S[1..p-1] S[p+1..N]`. By induction, greedy solves that suffix
  optimally. ∎

### (c) Implementation — O(n log n + k)

Use a **Fenwick tree** (active positions, supports `prefix`, `kth`, `add` in O(log n)) and
a **segment tree** over original positions (range-min over active positions, with the
achieving index).

```text
GreedyFinal(A, K):
    BIT = all n positions active
    SEG = segment tree over A (inactive leaf = +inf)
    out = []; rem = n

    for i = 1..n:
        if K == 0: break
        t = min(K+1, rem)
        x = BIT.kth(t)              # original index of t-th remaining element
        (m, p) = SEG.queryMin(1, x) # min value among first t remaining, and its index
        out.append(m)
        K = K - (BIT.prefix(p) - 1) # swaps needed to bring A[p] forward
        BIT.add(p, -1); SEG.update(p, +inf); rem = rem - 1

    append remaining active positions in original order to out
    return out
```

There are ≤ n iterations, and each uses O(1) Fenwick/segment-tree operations at O(log n) each, so total O(n log n) ⊆ O(n log n + k).

---

## 2. Text justification

### (a) Subproblem and recurrence

`DP[j]` = minimum penalty to format words `1..j`. Base: `DP[0] = 0`.

$$DP[j] = \min_{1 \le i \le j,\ \operatorname{len}(i,j) \le L} \big( DP[i-1] + \operatorname{cost}(i,j) \big)$$

with `cost(i,j) = 0` if `j = n`, otherwise `(L - len(i,j))^3`.

### (b) Algorithm and running time

Precompute prefix sums so `len(i,j) = P[j] - P[i-1] + (j-i)` is O(1).

```text
DP[0] = 0
for j = 1..n:
    DP[j] = +inf
    for i = j downto 1:
        if len(i,j) > L: break
        c = 0 if j == n else (L - len(i,j))^3
        if DP[i-1] + c < DP[j]:
            DP[j] = DP[i-1] + c; choice[j] = i
return DP[n]
```

Running time: for each `j` the inner loop tries ≤ j values of `i`, so `Σ j = O(n²)`. Space: O(n).

### (c) Reconstructing the layout

Walk back from `j = n` using `choice[j]` (start of the last line of prefix `j`), recording
`j` as the last word of each line, then reverse.

```text
j = n; lines = []
while j > 0:
    i = choice[j]
    lines.append(j)   # last word of this line
    j = i - 1
return reverse(lines)
```

---

## 3. Cargo loading (weight + volume knapsack)

`DP[i][w][v]` = max value using items `1..i`, weight ≤ `w`, volume ≤ `v`.

Base: `DP[0][w][v] = 0`.

Recurrence (skip / take item `i`):

$$DP[i][w][v] =
\begin{cases}
DP[i-1][w][v], & \text{skip}\\[2pt]
\max\big(DP[i-1][w][v],\ p_i + DP[i-1][w-w_i][v-v_i]\big), & \text{if } w \ge w_i,\ v \ge v_i.
\end{cases}$$

Fill three nested loops `i = 1..n`, `w = 0..W`, `v = 0..V`; answer `DP[n][W][V]`.

Running time: **O(n W V)**; space O(nWV) (or O(WV) with a rolling layer).

---

## 4. Egg dropping

### (a) Two eggs

`DP[f]` = min worst-case drops with 2 eggs, f floors.

- Base: `DP[0] = 0`.
- Recurrence (drop first from floor `x`):

$$DP[f] = 1 + \min_{1 \le x \le f} \max\big(x-1,\ DP[f-x]\big)$$

- Algorithm: fill `f = 1..n`, loop `x = 1..f`. Running time **O(n²)**, space O(n).

### (b) General m eggs

`DP[m][f]` = min worst-case drops with m eggs, f floors.

- Base: `DP[m][0] = 0` for all m; `DP[1][f] = f`.
- Recurrence (m ≥ 2, f ≥ 1):

$$DP[m][f] = 1 + \min_{1 \le x \le f} \max\big(DP[m-1][x-1],\ DP[m][f-x]\big)$$

- Algorithm: loop `M = 2..m`, `f = 1..n`, `x = 1..f`. Running time **O(m n²)**, space O(mn).

### (c) Optimal strategy

Precompute `choice[m][f]` = the `x` achieving the minimum above. Then recurse with state
`(m, f, lo)` = m eggs, f floors numbered `lo+1..lo+f`:

```text
solve(m, f, lo):
    if f == 0: return lo + 1
    if m == 1:                          # one egg: test bottom-up
        for x = 1..f:
            if eggdrop(lo+x): return lo + x
        return lo + f + 1
    x = choice[m][f]
    if eggdrop(lo + x): return solve(m-1, x-1, lo)   # broke
    else:               return solve(m,   f-x, lo+x) # survived
```

Call `solve(m, n, 0)`. Each state makes one drop and follows the optimal choice, so it
uses ≤ `DP[m][n]` drops; each `true` consumes an egg, so ≤ m calls return true.

---

## 5. Coin game (minimax)

`DP[i][j]` = max value the current player can guarantee from coins `v_i..v_j`.
Prefix sums `P[t]`, so `S(i,j) = P[j] - P[i-1]`.

- Base: `DP[i][i] = v_i`.
- Recurrence (take left `v_i` or right `v_j`; opponent then takes their optimal share):

$$DP[i][j] = \max\Big(
v_i + \big(S(i+1,j) - DP[i+1][j]\big),\quad
v_j + \big(S(i,j-1) - DP[i][j-1]\big)\Big)$$

Fill by increasing length:

```text
for len = 2..n:
    for i = 1..n-len+1:
        j = i + len - 1
        left  = v[i] + (P[j] - P[i])     - DP[i+1][j]
        right = v[j] + (P[j-1] - P[i-1]) - DP[i][j-1]
        DP[i][j] = max(left, right)
```

Player 1's first move: compare

- `takeLeft  = v[1] + (P[n] - P[1]) - DP[2][n]`
- `takeRight = v[n] + (P[n-1] - P[0]) - DP[1][n-1]`

and pick the larger.

Running time: there are O(n²) intervals `(i,j)`, each computed in O(1), so **O(n²)**. Space: O(n²) for the table.
