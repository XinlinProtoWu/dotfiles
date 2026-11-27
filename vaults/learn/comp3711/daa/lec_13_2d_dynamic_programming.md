# Lecture 13 — 2D Dynamic Programming

> Source: `13_DP2.pdf` (19 pages). Goal: recognise when **one** state variable is not enough —
> and add a second dimension instead of adding a hack. Every algorithm here is the same
> rectangle-filling loop; only the recurrence inside the cell changes. Continues in
[[lec_14_dp_over_intervals]], where the state becomes an *interval* and the table is filled by
diagonals.

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The technique:** [[terms/dynamic-programming]] · [[terms/memoization|Memoization (top-down)]]

**The problems:** [[terms/0-1-knapsack|0/1 knapsack]] · [[terms/LCS|Longest common subsequence]] · [[terms/edit-distance]] · [[terms/longest-common-substring]]

**Graphs, for later:** [[terms/DAG]]

---

## 1. Why the natural knapsack recurrence is wrong

**Motivate.** Rod cutting had a one-variable state ("how much rod is left") and it worked. The
knapsack looks identical — "how much capacity is left" — so the obvious translation is a
one-dimensional table. It is wrong, and seeing *why* is the whole lecture.

**Define.** $n$ items, item $i$ has weight $w_i$ and value $v_i$; knapsack capacity $W$.
Choose $x_1,\dots,x_n \in \{0,1\}$ with $\sum_i x_i w_i \le W$ maximising $\sum_i x_i v_i$.

![[13_DP2.pdf#page=2]]
*Figure: the 0/1 knapsack statement. (`13_DP2.pdf` p. 2)*

**The broken attempt.** $V[w] = \max_i(v_i + V(w - w_i))$, i.e. the rod-cutting recurrence.

**Why it breaks.** The transition $V[w - w_i]$ is free to pick item $i$ **again** — nothing in
the state records that item $i$ is used up. On $w = 7$ with items $(v,w) = (10,5)$ and $(40,4)$
this can legally build $10 + 10 + \dots$, which is the *unbounded* knapsack, not 0/1.

> [!important] The state must remember the restriction
> "Capacity used" is not enough information: two different ways of filling capacity $w$ may be
> legally different (item $i$ available or not). Add the missing information to the state:
> **$V[i,w]$ = best value achievable with capacity $w$ using only items $1..i$.**

---

## 2. The 2-D recurrence

$$V[i,w] = \max\bigl(V[i-1,w],\; v_i + V[i-1,\,w - w_i]\bigr)$$

with $V[0,w] = V[i,0] = 0$.

Read it as the two cases for item $i$: **skip** it (fall back to the first $i-1$ items at the
same capacity) or **take** it (gain $v_i$, and the remainder must be the *optimum for $i-1$
items* at the reduced capacity — which is what prevents a second copy).

![[13_DP2.pdf#page=4]]
*Figure: subproblem, recurrence, fill order and required answer, all on one slide.
(`13_DP2.pdf` p. 4)*

**Fill order.** Outer loop over $i = 1$ to $n$, inner loop over $w = 1$ to $W$. Cell $(i,w)$ reads
$(i-1,w)$ — the row above — and $(i-1, w-w_i)$ — above and to the left. Both are already
filled.

```text
let V[0..n, 0..W] be a new 2D array of all 0
for i <- 1 to n
    for w <- 1 to W
        if w[i] <= w and v[i] + V[i-1, w-w[i]] > V[i-1, w] then
            V[i, w] <- v[i] + V[i-1, w-w[i]]
        else
            V[i, w] <- V[i-1, w]
return V[n, W]
```

**Cost.** $\Theta(nW)$ time, $\Theta(nW)$ space — **pseudo-polynomial**: $W$ is a *number* in
the input, so a capacity of $10^9$ written in 30 bits still produces a $10^9$-column table.

**In plain words.** A hiker with a 10-kilo pack and four things to take. Fill a grid: one row per
item, one column per pack size, and every cell answers "best value using only these items in this
much room". Each cell is one comparison — would adding this item to the best answer for the
smaller pack beat leaving it out? The item index is what stops you taking the same thing twice.

**Example (traced — the deck's own instance).** Items $(v_i, w_i)$: 1=(10,5), 2=(40,4),
3=(30,6), 4=(50,3). Capacity $W = 10$.

![[13_DP2.pdf#page=5]]
*Figure: the completed table; the answer $V[4,10] = 90$ is the bottom-right cell.
(`13_DP2.pdf` p. 5)*

| $V[i,w]$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $i=0$ | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 0 | 0 | 0 | 10 | 10 | 10 | 10 | 10 | 10 |
| 2 | 0 | 0 | 0 | 0 | 40 | 40 | 40 | 40 | 40 | 50 | 50 |
| 3 | 0 | 0 | 0 | 0 | 40 | 40 | 40 | 40 | 40 | 50 | 70 |
| 4 | 0 | 0 | 0 | 50 | 50 | 50 | 50 | 90 | 90 | 90 | 90 |

Two cells worth checking by hand:

- $V[2,9] = \max(V[1,9], 40 + V[1,5]) = \max(10, 40+10) = 50$. Items 1 and 2 weigh $9$ together.
- $V[4,10] = \max(V[3,10], 50 + V[3,7]) = \max(70, 50+40) = 90$. Taking item 4 leaves capacity
  $7$ for items $1..3$, and the best there is item 2 (value 40).

> [!warning] "Space can be improved to $\Theta(n + W)$"
> The deck's phrasing on p. 5 is loose. Since row $i$ depends only on row $i-1$, you can keep
> **two rows** ($\Theta(W)$) — or even one row filled right-to-left ($\Theta(W)$), which is the
> standard 1-D trick. But **one row left-to-right is the bug from Section 1**: it lets an item be
> reused. The loop direction here is a *correctness* constraint, not a performance detail.

---

## 3. Reconstructing which items were taken

Same pair as always: a value table and a **decision** table.

![[13_DP2.pdf#page=6]]
*Figure: adding `keep[i,w]` and walking backwards from $(n,W)$. (`13_DP2.pdf` p. 6)*

```text
for i <- 1 to n
    for w <- 1 to W
        if w[i] <= w and v[i] + V[i-1, w-w[i]] > V[i-1, w] then
            V[i, w] <- v[i] + V[i-1, w-w[i]];  keep[i, w] <- 1
        else
            V[i, w] <- V[i-1, w];              keep[i, w] <- 0
K <- W
for i <- n downto 1
    if keep[i, K] = 1 then
        print i
        K <- K - w[i]
```

**In plain words.** The grid tells you the best value but not which items to pack. So tick a cell
every time you decide "yes, this item goes in". Then start at the bottom-right corner and walk
backwards: a tick means the item is in the bag and you jump left by its weight, a blank means you
ignore the item and look one row up.

**Example (traced).** $i = 4$, $K = 10$: `keep[4,10] = 1` (since $50 + V[3,7] = 90 > 70$), print
4, $K = 7$. $i = 3$: $V[3,7] = 40$ and $30 + V[2,1] = 30$, so the `keep` flag stays 0. $i = 2$: $K = 7$,
$40 + V[1,3] = 40 > V[1,7] = 10$, so print 2, $K = 3$. $i = 1$: $V[1,3] = 0$, flag 0 again.
Answer: items $\{4, 2\}$, total weight $3 + 4 = 7 \le 10$, total value $50 + 40 = 90$. ✓

**Cost.** $\Theta(nW)$ time and space. The deck's note stands: top-down with a hash table is
better when $W$ is huge and the reachable $(i,w)$ pairs are sparse.

---

## 4. A third dimension: two knapsacks

**Problem (deck exercise, p. 7).** Two knapsacks, both capacity $W$. Maximise total value with
$O(nW^2)$.

**State.** $V[i,w_1,w_2]$ = best value using items $1..i$ with capacities $w_1$ and $w_2$.

**Recurrence — three cases, one per item:**

$$\begin{aligned}
V[i,w_1,w_2] = \max\{ & V[i-1,w_1,w_2], \\
& v_i + V[i-1,w_1-w_i,w_2], \\
& v_i + V[i-1,w_1,w_2-w_i] \}
\end{aligned}$$

Answer $V[n,W,W]$; cost $\Theta(nW^2)$ time and space.

**In plain words.** Two hikers, two packs, and items that cannot be split between them. Knowing
the two packs hold 20 kilos altogether tells you nothing, because a 6-kilo item must go wholly
into one pack or the other and may leave a 4-kilo hole in the wrong one. That is why the grid needs
one axis per pack.

**Example (my instance, chosen so the split matters).** Three items, all weight $6$, values
$1, 1, 10$; two bags, each capacity $10$.

| model | what fits | value |
|---|---|---|
| One bag of capacity $2W = 20$ | all three items (weight 18) | $12$ |
| Two bags of capacity $10$ each | any **one** item per bag (two items weigh 12) | $10+1 = 11$ |

The merged-capacity model over-counts, and the correct answer is $11$ (the weight-6 item of
value 10 plus either other item). This is exactly why the state needs both capacities: at
$V[3,10,10]$ the recurrence must decide *which* bag item 3 goes into, and after putting it in
bag 1 only $4$ units of bag-1 capacity remain — useless for a weight-6 item.

**On the Section 2 instance** ($W = 10$, items 1=(10,5), 2=(40,4), 3=(30,6), 4=(50,3)) every
item fits: bag 1 $= \{1,2\}$ (weight 9, value 50), bag 2 $= \{3,4\}$ (weight 9, value 80),
total $130$. Useful as a check that the recurrence does not *lose* value, but it does not
separate the two models — the three-item instance above does.

> [!tip] Dimension counting is the whole skill
> Number of state variables = number of independent constraints you must remember. Capacity
> (1) $\to$ 2-D with the item index. Two capacities (2) $\to$ 3-D. Time cost = (states) ×
> (choices per state) — here $(n+1)(W+1)^2 \times 3$.

---

## 5. Longest common subsequence: the problem

**Define.** $X = (x_1,\dots,x_m)$, $Y = (y_1,\dots,y_n)$. A sequence $Z = (z_1,\dots,z_k)$ is a
**common subsequence** if there are indices $i_1 < \cdots < i_k$ and $j_1 < \cdots < j_k$ with
$x_{i_p} = y_{j_p} = z_p$. Find the longest such $Z$.

Note "subsequence", not "substring": the characters need **not** be contiguous (Section 8 is the
contiguous version, and the recurrence is completely different).

![[13_DP2.pdf#page=8]]
*Figure: $Z = (B,C,B,A)$ is a common subsequence of $X = (A,B,A,C,B,D,A,B)$ and
$Y = (B,D,C,A,B,A)$ — it skips characters freely in both. (`13_DP2.pdf` p. 8)*

**The reformulation that makes the recurrence obvious.** Draw $X$ above $Y$ and match equal
characters with straight lines; a valid common subsequence is exactly a set of matches with
**no crossings**. So LCS = maximum non-crossing matching.

![[13_DP2.pdf#page=10]]
*Figure: two different non-crossing matchings of the same pair of strings — $BCBA$ and $BABA$.
Both legal, both of length 4. (`13_DP2.pdf` p. 10)*

---

## 6. The LCS recurrence

**Define.** $c[i,j]$ = length of the LCS of $X[1..i]$ and $Y[1..j]$.

$$\begin{aligned}
& c[i,j] = 0 && i = 0 \text{ or } j = 0 \\
& c[i,j] = c[i-1,j-1] + 1 && i,j > 0,\; x_i = y_j \\
& c[i,j] = \max\{c[i,j-1],\, c[i-1,j]\} && i,j > 0,\; x_i \ne y_j
\end{aligned}$$

**Why case 2 is safe.** If $x_i = y_j$ then *some* optimal solution matches them. Reason: in
any optimal non-crossing matching, the last character of $X$ (and of $Y$) is either matched or
not; if unmatched, it can be matched to the other's last character and nothing breaks, because
they are the rightmost pair. (The deck asks "why?" — this is the exchange argument.)

**Why case 3 is a max of two.** If $x_i \ne y_j$ they cannot be matched *to each other*, so at
least one of them is unmatched in every solution; dropping $x_i$ or dropping $y_j$ gives the two
candidates.

![[13_DP2.pdf#page=12]]
*Figure: the algorithm with the `b` table (`↖` match, `↑` drop $x_i$, `←` drop $y_j$).
(`13_DP2.pdf` p. 12)*

**In plain words.** Two words, and you want the longest line of letters you can pick out of both
without changing order. Fill a grid of "best so far" for every pair of starting prefixes: when the
two letters under the cursor agree, the answer grows by one along the diagonal; when they disagree,
you copy whichever of the neighbour above or the neighbour to the left is better.

**Example (traced, deck's instance).** $X = $ `ABACBDAB` ($m=8$), $Y = $ `BDCABA` ($n=6$).

| $c[i,j]$ | – | B | D | C | A | B | A |
|---|---|---|---|---|---|---|---|
| **–** | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **A** | 0 | 0 | 0 | 0 | 1 | 1 | 1 |
| **B** | 0 | 1 | 1 | 1 | 1 | 2 | 2 |
| **A** | 0 | 1 | 1 | 1 | 2 | 2 | 3 |
| **C** | 0 | 1 | 1 | 2 | 2 | 2 | 3 |
| **B** | 0 | 1 | 1 | 2 | 2 | 3 | 3 |
| **D** | 0 | 1 | 2 | 2 | 2 | 3 | 3 |
| **A** | 0 | 1 | 2 | 2 | 3 | 3 | 4 |
| **B** | 0 | 1 | 2 | 2 | 3 | 4 | 4 |

Answer $c[8,6] = 4$. Tracing the `b` arrows from $(8,6)$, using the deck's tie-break
`c[i-1,j] >= c[i,j-1]` $\Rightarrow$ `↑`:

| step | cell | $x_i$ vs $y_j$ | move | printed |
|---|---|---|---|---|
| 1 | $(8,6)$ | B vs A, differ; $c[7,6] = c[8,5] = 4$ | `↑` | – |
| 2 | $(7,6)$ | A = A | `↖` | A |
| 3 | $(6,5)$ | D vs B; $3 > 2$ | `↑` | – |
| 4 | $(5,5)$ | B = B | `↖` | B |
| 5 | $(4,4)$ | C vs A; $2 = 2$ | `↑` | – |
| 6 | $(3,4)$ | A = A | `↖` | A |
| 7 | $(2,3)$ | B vs C; $0 < 1$ | `←` | – |
| 8 | $(2,2)$ | B vs D; $0 < 1$ | `←` | – |
| 9 | $(2,1)$ | B = B | `↖` | B |

Read bottom-up that is $BABA$; break the ties the other way and you get $BCBA$. Both have length
4, and they are exactly the two non-crossing matchings drawn on `13_DP2.pdf` p. 10 — so the LCS
is **not unique**. The table stores the length; the reconstruction picks one optimum.

**Cost.** $\Theta(mn)$ time. Space $\Theta(mn)$, reducible to $\Theta(\min(m,n))$ **if you only
need the length** (two rows suffice, since cell $(i,j)$ reads row $i-1$ only). Note the
reconstruction needs the whole `b` table, so the space reduction is incompatible with printing
$Z$ — a favourite exam contradiction.

---

## 7. Printing the LCS

![[13_DP2.pdf#page=13]]
*Figure: `Print-LCS` follows `b` backwards and prints on the `↖` branch, so characters come out
in order. (`13_DP2.pdf` p. 13)*

```text
Print-LCS(b, i, j):
    if i = 0 or j = 0 then return
    if b[i, j] = "NW" then              // match: x_i = y_j
        Print-LCS(b, i-1, j-1)
        print x_i                       // print AFTER the recursive call
    else if b[i, j] = "UP" then         // x_i not matched
        Print-LCS(b, i-1, j)
    else                                // "LEFT": y_j not matched
        Print-LCS(b, i, j-1)
```

> [!warning] Print before vs after the recursion
> Printing *before* the recursive call emits the LCS backwards. The recursion unwinds from
> $(0,0)$ to $(i,j)$, so the `print` must sit **after** the recursive call — same reason a
> post-order traversal of a tree prints leaves before roots.

---

## 8. Longest common substring

**Define.** The longest $Z$ that occurs **contiguously** in both strings: largest $k$ with
$x_i x_{i+1}\cdots x_{i+k-1} = y_j y_{j+1}\cdots y_{j+k-1}$ for some $i,j$.

**In plain words.** Same idea, but the letters have to sit together. `DEADBEEF` and `EATBEEF`
share the run BEEF and nothing longer, and the way you find it is to notice where a run of matches
breaks: the moment two letters disagree that run is over, and you start counting again from zero.

**Example.** $X = $ `DEADBEEF`, $Y = $ `EATBEEF` → $Z = $ `BEEF` (length 4). Check:
`DEADBEEF`[5..8] and `EATBEEF`[4..7]. Length 5 fails: no 5-letter run is shared.

![[13_DP2.pdf#page=15]]
*Figure: the definition change — $d[i,j]$ must be an LCS **ending at** both $x_i$ and $y_j$.
(`13_DP2.pdf` p. 15)*

**The trap in the definition.** $d[i,j]$ = "longest common substring of $X[1..i]$, $Y[1..j]$"
does **not** work: the optimum for $(i,j)$ need not contain $x_i$, so you cannot extend it.
Add the restriction to the state:

$$\begin{aligned}
& d[i,j] = d[i-1,j-1] + 1 && x_i = y_j \\
& d[i,j] = 0 && x_i \ne y_j \\
& d[i,0] = d[0,j] = 0
\end{aligned}$$

and the answer is $\max_{i,j} d[i,j]$ — **not** $d[m,n]$.

**Cost.** $\Theta(mn)$; space reducible to $\Theta(\min(m,n))$. Reconstruction needs only the
position of the maximum (`lm` = best length, `pm` = the $i$ where it ended), then print
$X[p_m - l_m + 1 \,..\, p_m]$.

**Brute force for comparison.** The deck quotes $O(n^4)$; counted carefully, comparing all
$\Theta(mn)$ pairs of start positions costs $O(\min(m,n))$ each, so a naive triple loop is
$O(mn\min(m,n))$ — for $m = n$ that is $O(n^3)$. Either way, the DP's $\Theta(mn)$ is the point.
*(The tightening of the deck's bound is mine.)*

---

## 9. Edit distance

**Define.** $\text{edit}(s,t)$ = minimum number of insertions, deletions and substitutions
turning $s$ into $t$.

**In plain words.** Turning `abode` into `blog`: delete the a, add an l, delete the d, change the e
to a g. Four single-key edits. The grid asks, for every pair of prefixes, the cheapest of three
moves — throw away a letter of the first word, add a letter of the second, or change one letter —
and the bottom-right corner is the answer.

**Example (deck's).** $s = $ `abode`, $t = $ `blog`, distance 4:

| # | operation | result |
|---|---|---|
| 0 | start | `abode` |
| 1 | delete `a` | `bode` |
| 2 | insert `l` after `b` | `blode` |
| 3 | delete `d` | `bloe` |
| 4 | substitute `e`→`g` | `blog` |

Four, not three: $s$ and $t$ share only the subsequence `bo`, and the remaining letters
(`a`,`d`,`e` against `l`,`g`) would each need their own operation. A DP run confirms
$\text{edit}[5,4] = 4$.

![[13_DP2.pdf#page=18]]
*Figure: the three-way minimum — insert, delete, substitute — with the indicator
$I[s_i \ne t_j]$. (`13_DP2.pdf` p. 18)*

**Recurrence.** With $\text{edit}[i,j] = \text{edit}\bigl(s[1..i],\, t[1..j]\bigr)$:

$$\begin{aligned}
\text{edit}[i,j] = \min\{ & 1 + \text{edit}[i,j-1], \\
& 1 + \text{edit}[i-1,j], \\
& I[s_i \ne t_j] + \text{edit}[i-1,j-1] \}
\end{aligned}$$

Base cases $\text{edit}[0,j] = j$ (insert everything) and $\text{edit}[i,0] = i$ (delete
everything) — these are the ones people forget, and they are what makes the table's first row
and column non-zero.

**Cost.** $\Theta(mn)$ time; $\Theta(\min(m,n))$ space suffices for the distance alone.

> [!tip] LCS and edit distance are cousins
> With insert/delete only (no substitution), $\text{edit}(s,t) = m + n - 2\cdot\text{LCS}(s,t)$:
> you keep the LCS and delete/insert everything else. With substitution allowed the relation
> breaks, which is why edit distance needs its own table.

---

## 10. Exercise: choose $m$ of $n$, one from every $k$ consecutive

**Problem.** Array $A[1..n]$; choose exactly $m$ numbers maximising the sum, subject to: every
window of $k$ consecutive positions contains at least one chosen number. ($k, m \le n$.)

**State.** $dp[i,j]$ = max sum choosing $i$ numbers from $A[1..j]$ **with $A[j]$ chosen**.

**Recurrence.** The previous chosen index $t$ must be within $k-1$ to the left (otherwise the
$k$-window before $j$ is empty):

$$dp[i,j] = A[j] + \max_{t \in [\max(0,\,j-k),\; j-1]} dp[i-1,t]$$

Base: $dp[0,0] = 0$, all other $dp[0,\cdot] = -\infty$; answer
$\max_{t \in [n-k+1,\,n]} dp[m,t]$ (the last chosen index must be within the final window).

**Cost.** $O(nmk)$ naive. The inner term is a **sliding-window maximum** over a window of size
$k$; recomputing it per $(i,j)$ is the waste. A monotonic deque gives each window max in
amortised $O(1)$, so the whole fill is $O(nm)$.

> [!important] Recognising a reusable subroutine inside a DP
> The transfer is "$O(mnk) \to O(nm)$" by *not* recomputing the max. Exam questions love this
> shape: the DP outer structure is fixed, and marks come from spotting that the inner
> optimisation was already solved in an earlier lecture (sliding-window maximum).

---

## 11. Highlights

*(The deck has no summary slide; this is the distilled version of its 19 pages.)*

- If a decision must remember **which items were used**, one state variable is not enough. Add
  the index: $V[i,w]$ instead of $V[w]$, and the "same item twice" bug disappears.
- Every table here is filled in row-major order and each cell reads only **up, left, up-left**;
  therefore two rows (or one row, correctly directed) suffice for the *value*.
- LCS = maximum non-crossing matching. The recurrence has three cases, and the third
  ($\max$ of two) is the price of not being able to match $x_i$ with $y_j$.
- Changing the state definition is legitimate — $d[i,j]$ for substrings *must* mean "ends at
  $x_i, y_j$". When you change the state, the answer may no longer be the corner cell;
  it becomes a $\max$ over cells.
- Reconstruction needs the decision table; space-optimised tables cannot reconstruct.
- Pseudo-polynomial is not polynomial: $\Theta(nW)$ and $\Theta(mn)$ depend on *values* in the
  input, not on its length.

## 12. Exam traps

- **Knapsack with $V[w]$ only** $\to$ recomputes items; that is the *unbounded* knapsack.
  Use $V[i,w]$, or a 1-D array filled **right-to-left**.
- **Initialising the knapsack table to $-\infty$ instead of $0$** $\to$ row 0 / column 0 must be
  0 (zero items / zero capacity is feasible with value 0). Filling them with $-\infty$ makes
  the "take item $i$ exactly" case leak into "take nothing".
- **`V[n,W]` for a capacity that need not be exactly met** $\to$ fine here (values are
  positive, so filling more is never worse), but with penalties for wasted capacity the answer
  becomes $\max_w V[n,w]$.
- **LCS vs longest common *substring*** $\to$ substring forbids the $\max(c[i,j-1],c[i-1,j])$
  case; a mismatch resets $d[i,j]$ to 0. Mixing them up is the most expensive single error in
  this lecture.
- **Answering $d[m,n]$ for longest common substring** $\to$ the answer is $\max_{i,j} d[i,j]$.
  A shared substring can end anywhere.
- **LCS reconstruction printing in the wrong order** $\to$ `print` after the recursive call.
- **Claiming the LCS is unique** $\to$ it is not; $BCBA$ and $BDAB$ both have length 4 on the
  deck's example. State "an LCS", not "the LCS".
- **Space-optimising and then trying to reconstruct** $\to$ impossible without the `b`/`keep`
  table. Say which one you are giving.
- **Edit distance without the $[0,\cdot]$ and $[\cdot,0]$ base rows** $\to$ you get "free"
  insertions of prefixes and an answer that is too small.
- **Edit distance substitution cost** $\to$ it is $I[s_i \ne t_j]$, i.e. **0** when the
  characters already agree. Writing 1 unconditionally overcounts every match.
- **Two knapsacks as one knapsack of capacity $2W$** $\to$ wrong: an item cannot be split, so
  a total-weight bound does not model two separate capacity constraints. The state is
  $(w_1, w_2)$.
- **Forgetting pseudo-polynomial** $\to$ knapsack is $\Theta(nW)$, which is exponential in the
  *bit length* of $W$. Saying "knapsack is polynomial" is a classic wrong answer.
