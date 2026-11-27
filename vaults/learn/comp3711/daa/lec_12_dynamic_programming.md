# Lecture 12 — Dynamic Programming

> Source: `12_DP1.pdf` (36 pages). Goal: turn a correct-but-exponential recursion into a
> polynomial table fill by **storing** each subproblem's answer once — then learn to read the
> answer *and the choices* back out of the table. Follows [[lec_10-11_greedy]] (where greedy
> failed) and leads into [[lec_13_2d_dynamic_programming]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The technique:** [[terms/dynamic-programming|Dynamic programming (DP)]] · [[terms/memoization|Memoization]]

**The problems:** [[terms/coin-change]] · [[terms/weighted-interval-scheduling]]

**Complexity:** [[terms/golden-ratio]]

---

## 1. Why plain recursion is not enough

**Motivate.** Counting the ways to climb a staircase looks like the easiest problem in the
course, and the obvious recursion is *correct* — yet it is unusable for $n = 40$. The reason
is the whole reason DP exists.

**Define.** You may climb 1 or 2 stairs per step. Let $F(n)$ be the number of distinct ways
to climb $n$ stairs. The last step into stair $n$ comes from stair $n-1$ or stair $n-2$, and
those two cases are disjoint, so

$$F(n) = F(n-1) + F(n-2), \qquad F(1) = 1,\; F(2) = 2$$

![[12_DP1.pdf#page=3]]
*Figure: the recursion tree for $F(n)$ — the same subproblem hangs off several parents.
(`12_DP1.pdf` p. 3)*

**In plain words.** Counting the ways up a staircase, one or two steps at a time: the number of
routes to step 40 is just the routes to step 39 plus the routes to step 38, and so on down. Ask a
computer for that 40th number the naive way and it re-answers the same tiny question millions of
times — like a shop that recounts the whole shelf from scratch for every single customer.

**Example (compute the numbers).** For $n = 6$ the tree has only 15 nodes, so it feels fine.
But the node count satisfies the same recursion, hence it grows like $\varphi^n$ with
$\varphi \approx 1.618$. At $n = 40$ the naive recursion makes $204{,}668{,}309$ calls to
compute a number equal to $165{,}580{,}141$ — a quarter of a billion calls for an answer
that fits in 28 bits. That is $\Theta(\varphi^n)$, not $\Theta(n)$.

**The fix, in one sentence.** Each subproblem $F(1),\dots,F(n)$ has only $n$ distinct
*identities*; the tree is huge only because identities are **repeated**. Compute each one
once.

> [!important] The DP condition
> A problem is DP-solvable when it has (1) **optimal substructure** — the optimum is built
> from optima of subproblems — and (2) **overlapping subproblems** — the same subproblems
> recur, so caching pays. Divide & conquer ([[LEC3_MergeSort]]) has (1) but deliberately has
> no (2): its subproblems are disjoint.

---

## 2. Two ways to store: top-down and bottom-up

Both are DP. The difference is only the order in which the table is filled.

![[12_DP1.pdf#page=4]]
*Figure: side-by-side memoized (top-down) and iterative (bottom-up) Fibonacci.
(`12_DP1.pdf` p. 4)*

| | **Top-down (memoized)** | **Bottom-up (tabular)** |
|---|---|---|
| Shape | Recursion that checks a cache first | Loop over subproblem sizes, increasing |
| Fill order | Whatever the recursion reaches | Chosen by you, so dependencies are ready |
| Cost | $\Theta(n)$ time, $\Theta(n)$ space, $\Theta(n)$ stack | $\Theta(n)$ time, table space, no stack |
| Needs | An array (or **hash table** if the state space is sparse) | A table of every state |
| Danger | Recursion depth; a lookup key you forgot to canonicalise | Filling a cell before its dependencies |

**In plain words.** Instead of asking and re-asking, write the answers down as you go: keep the
last two numbers, add them, shuffle forward. Forty additions instead of a quarter of a billion
phone calls. The lazy version (a notebook of every answer, still asking recursively) is slower
only because the asking costs as much as the adding.

**Example.** `BU-F(n)` keeps only the last two values, so Fibonacci costs $\Theta(1)$ space
instead of $\Theta(n)$. Bottom-up is the default; you switch to top-down when the state space
is *sparse* — i.e. when only a tiny fraction of the $O(\text{states})$ table is ever needed
(the coin-change deck, `12_DP1.pdf` p. 36, is the canonical case).

**Trap.** "Memoization makes it linear" is only true if the number of *distinct* states is
polynomial. Memoizing a recursion whose states are, say, subsets of $n$ items changes nothing.

---

## 3. Rod cutting: finding the recurrence

**Motivate.** Naive enumeration of all cutting plans is exponential, but the problem has
obvious structure: whatever you do first, the *remainder* is the same problem again.

**Define.** Given a rod of length $n$ and prices $p_1,\dots,p_n$ (price of a piece of length
$i$), cut it to maximise total revenue $r_n$.

![[12_DP1.pdf#page=5]]
*Figure: the price table used throughout the deck (`12_DP1.pdf` p. 5).*

| $i$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| $p_i$ | 1 | 5 | 8 | 9 | 10 | 17 | 17 | 20 | 24 | 30 |

There are $2^{n-1}$ ways to cut a rod of length $n$ — one binary decision per gap between
unit lengths — so $n = 10$ already means $2^9 = 512$ plans. Enumeration is out.

![[12_DP1.pdf#page=6]]
*Figure: the choice "cut a first piece of length $i$, then cut the rest optimally" —
$i = 1,\dots,n-1$ — or "sell the whole rod". (`12_DP1.pdf` p. 6)*

**The recurrence.** Condition on the **first piece**:

$$r_n = \max_{1 \le i \le n}\bigl(p_i + r_{n-i}\bigr), \qquad r_0 = 0$$

Note $i = n$ is the "sell it whole" case, and $r_0 = 0$ makes it fit without a special branch.

> [!important] Why "first piece" is a legal decomposition
> The pieces are unordered, so every cutting plan has exactly one *leftmost, longest-prefix*
> choice: the length $i$ of the piece at the left end. Choosing $i$ splits the rod into a
> piece of length $i$ (revenue $p_i$, no choice left) and a rod of length $n-i$ (revenue
> $r_{n-i}$). **This is what makes the subproblems independent** — the classic DP move: add
> information to the state until the two halves stop competing for the same rod.

---

## 4. Rod cutting: filling the table

![[12_DP1.pdf#page=11]]
*Figure: the completed $r$-table for $n = 10$. (`12_DP1.pdf` p. 11)*

```text
ROD-CUT(p, n)
    let r[0..n] be a new array
    r[0] <- 0
    for j <- 1 to n
        q <- -infinity
        for i <- 1 to j
            q <- max(q, p[i] + r[j-i])
        r[j] <- q
    return r[n]
```

**In plain words.** A timber yard does not pay by the metre. A 2-metre plank fetches 5 while a
1-metre fetches 1, so chopping a 4-metre log into two 2s beats selling it whole. To decide about a
4-metre log you only need to know the best you can do with 1, 2 and 3 metres — answers you have
already written down.

**Example (traced).** $r_2$: $\max(p_1 + r_1, p_2 + r_0) = \max(1+1,\,5+0) = 5$. Then
$r_3 = \max(1+5,\,5+1,\,8+0) = 8$ (no cut beats the whole rod), and $r_4 = \max(1+8,\,5+5,\,8+1,\,9+0) = 10$
— the first length where cutting wins.

| $j$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $r_j$ | 0 | 1 | 5 | 8 | 10 | 13 | 17 | 18 | 22 | 25 | 30 |

**Cost.** $\sum_{j=1}^{n} j = \Theta(n^2)$ time, $\Theta(n)$ space. The inner loop only ever
looks *left* in the table, so filling $j$ in increasing order is always safe.

**Trap.** The table alone gives the **value**, not the **cut**. If a question asks "which
pieces?", Section 5 is mandatory — this is the single most common lost mark in DP questions.

---

## 5. Reconstructing the solution

**Define.** Store, for every $j$, the winning first-piece length in $s[j]$; then walk
downwards peeling off pieces.

![[12_DP1.pdf#page=18]]
*Figure: the $s$-table, and the walk for $n = 9$ giving the pieces $\{3\}$ then $\{6\}$.
(`12_DP1.pdf` p. 18)*

```text
for j <- 1 to n
    q <- -infinity
    for i <- 1 to j
        if q < p[i] + r[j-i] then
            q <- p[i] + r[j-i]
            s[j] <- i          // remember the decision, not just the value
    r[j] <- q

j <- n
while j > 0
    print s[j]
    j <- j - s[j]              // the rest of the rod is a smaller subproblem
```

| $j$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $p_j$ | 0 | 1 | 5 | 8 | 9 | 10 | 17 | 17 | 20 | 24 | 30 |
| $r_j$ | 0 | 1 | 5 | 8 | 10 | 13 | 17 | 18 | 22 | 25 | 30 |
| $s_j$ | 0 | 1 | 2 | 3 | 2 | 2 | 6 | 1 | 2 | 3 | 10 |

**In plain words.** The table says a 9-metre log can earn 25 but not how to cut it. So write a
second note beside every length: "the first piece I cut off was this long". Start at 9, read 3,
cut 3 metres off, and you are now holding a 6-metre log whose note says 6. Two cuts and you are
done.

**Example (traced).** $n = 9$: $s_9 = 3 \to$ print 3, $j = 6$; $s_6 = 6 \to$ print 6, $j = 0$.
Pieces $\{3,6\}$: revenue $p_3 + p_6 = 8 + 17 = 25 = r_9$. ✓

Two more, to show the table is not "greedy in disguise": $s_7 = 1$, so $n = 7$ becomes
$\{1,6\}$ with $1 + 17 = 18$ — the piece of length 1 is *not* the best single price per unit.
And $s_8 = 2 \to \{2,6\}$, $5 + 17 = 22$.

> [!tip] The `s`-table is the answer to "give me the optimum", not the `r`-table
> The `r`-table is what you print when asked for the *value*; the `s`-table is what you walk
> when asked for the *plan*. Every DP in this course has this pair (see `keep` in Section 7, `b` in
> Section 6, `S` in Section 10).

---

## 6. Max sum of non-adjacent elements

**Motivate.** A greedy "take the biggest, delete its neighbours" is the natural first idea and
it is **wrong**. This is a case where DP is forced.

**Define.** Given positive $a_1,\dots,a_n$, choose $S \subseteq \{1,\dots,n\}$ maximising
$\sum_{i \in S} a_i$ subject to: if $a_i \in S$ then $a_{i-1}, a_{i+1} \notin S$.

![[12_DP1.pdf#page=20]]
*Figure: the two cases for $a_i$ — in the solution (then $a_{i-1}$ is out) or not in it.
(`12_DP1.pdf` p. 20)*

**The recurrence.** Let $W_i$ be the best sum using only $a_1,\dots,a_i$.

$$W_i = \max\bigl(W_{i-2} + a_i,\; W_{i-1}\bigr)$$

with $W_0 = 0$, $W_1 = a_1$.

**In plain words.** Same rule as before: no two neighbours. Grab the 6 and you forfeit both 4s to
gain six; leave it and take the two 4s for eight. The biggest number is a trap precisely because
its neighbours are also big.

**Example (greedy vs optimal).** $A = (1,4,6,4)$.

| | chosen | sum |
|---|---|---|
| Greedy | $6$ then $1$ (its neighbours $4,4$ are deleted) | $7$ |
| Optimal | $4, 4$ | $8$ |

**In plain words.** Walk along the row deciding, at each number, "take this one plus the best from
two places back, or keep what I already had". Down the row 1, 8, 6, 3, 7 the best-so-far reads
1, 8, 8, 11, 15: you keep the 8, shrug at the 6, take the 3, then take the 7 because 8 + 7 beats
11.

**Example (DP traced).** $A = (1,8,6,3,7)$, DP gives $15$ from $\{8,7\}$:

| $i$ | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| $a_i$ | 1 | 8 | 6 | 3 | 7 |
| $W_i$ | 1 | 8 | 8 | 11 | 15 |
| $b_i$ (`true` = $a_i$ used) | true | true | false | true | true |

$\Theta(n)$ time. Reconstruction walks the flags: $b_5$ true $\to$ print 7, jump to $i=3$;
$b_3$ false $\to$ $i=2$; $b_2$ true $\to$ print 8, jump to $i=0$. Output $\{8,7\}$.

**Trap.** $b_i$ means "the optimum **for the prefix** $a_1..a_i$ uses $a_i$" — not
"$a_i$ is in the final answer". It is only after the walk lands on $i$ that the flag becomes
part of the final answer. That is exactly why you walk from $i=n$ and skip over rejected
indices, instead of printing every `true`.

---

## 7. Weighted interval scheduling

**Motivate.** Interval scheduling with unit weights was solved by greedy (earliest finish
first, [[lec_10-11_greedy]]). Add weights and greedy dies instantly.

**Define.** Job $j$ has start $s_j$, finish $f_j$, weight $v_j$. Two jobs are compatible if
they do not overlap. Find a maximum-weight compatible subset.

![[12_DP1.pdf#page=25]]
*Figure: greedy's disaster — one long job worth 999 versus one short job worth 1; earliest
finish first takes the 1. (`12_DP1.pdf` p. 25)*

**Sort and index.** Sort jobs so that $f_1 \le f_2 \le \cdots \le f_n$. Define
$p(j)$ = the largest index $i < j$ with $f_i \le s_j$ — the last job that can precede $j$.

![[12_DP1.pdf#page=26]]
*Figure: $p(j)$ for each job; all jobs strictly between $p(j)$ and $j$ clash with $j$.
(`12_DP1.pdf` p. 26)*

**Computing $p(j)$.** Sort by finish time; for each $j$ binary-search $s_j$ among the
finishes. $O(\log n)$ each, $O(n\log n)$ total.

**The recurrence.** Condition on job $j$: take it (then you may use $1..p(j)$) or drop it
(then you may use $1..j-1$):

$$V(j) = \max\bigl(v_j + V(p(j)),\; V(j-1)\bigr), \qquad V(0) = 0$$

**In plain words.** Four jobs, each with a start, a finish and a fee. Taking a job rules out the
ones that overlap it, so the only question is "is this job worth more than the jobs it pushes
out?". Sweeping left to right and writing down the best total for each prefix answers that with a
single comparison per job.

**Example (mine, traced — the deck's figure is graphical only).** Four jobs already sorted by
finish:

| $j$ | interval | $v_j$ | $p(j)$ |
|---|---|---|---|
| 1 | 0–2 | 3 | 0 |
| 2 | 1–3 | 5 | 0 |
| 3 | 2–5 | 6 | 1 |
| 4 | 4–6 | 5 | 2 |

$V(1) = \max(3+0,\,0) = 3$; $V(2) = \max(5+0,\,3) = 5$; $V(3) = \max(6+V(1),\,V(2)) = \max(9,5) = 9$;
$V(4) = \max(5+V(2),\,V(3)) = \max(10,9) = 10$. Answer 10, from jobs $\{2,4\}$ — job 2 ends at 3,
job 4 starts at 4, compatible. Check $p(3) = 1$: job 2 ends at 3, but job 3 starts at 2, so
job 2 clashes; job 1 ends at 2, and $2 \le 2$, so it is compatible.

![[12_DP1.pdf#page=24]]
*Figure: the deck's own instance, with the optimum $\{d,h\}$ of value $17 + 1 = 18$ shaded.
(`12_DP1.pdf` p. 24)*

```text
sort all jobs by finish time
V[0] <- 0
for j <- 1 to n
    if v[j] + V[p(j)] > V[j-1] then
        V[j] <- v[j] + V[p(j)];  keep[j] <- 1     // job j in opt soln for 1..j
    else
        V[j] <- V[j-1];          keep[j] <- 0     // job j not in it
j <- n
while j > 0
    if keep[j] = 1 then print j;  j <- p(j)
    else                        j <- j - 1
```

**Cost.** $\Theta(n\log n)$, dominated by sorting; the fill and the reconstruction are
$\Theta(n)$. Note the reconstruction jump is $j \gets p(j)$, not $j-1$ — the same "peel off
the decision, continue on the subproblem" pattern as Section 5.

> [!warning] The greedy instinct survives in the format, not the algorithm
> The *unweighted* case is still solved by greedy, and greedy's proof is the exchange
> argument. The *weighted* case needs the table because "earliest finish" says nothing about
> value. If a question has weights (or profits, or revenues), go straight to DP.

---

## 8. Highway billboards (same recurrence, different clothes)

**Problem.** Sites at $x_1 < x_2 < \dots < x_n$ on $[0,M]$, revenue $r_i > 0$ at site $i$, and
any two chosen billboards must be at "at least 5 miles apart". Maximise revenue.

**Greedy?** No — the deck's argument is beautiful: it is *literally* the max-sum-of-non-adjacent
problem in disguise. Place sites 4 miles apart, and "cannot take the previous or next one"
becomes "must be 5 apart". Since Section 6 has a counterexample, so does this.

**DP.** Let $p(i)$ be the largest $j < i$ with $x_i - x_j > 5$ (the last site far enough to the
left), and $R(i)$ the best revenue using sites $1..i$:

$$R(i) = \max\bigl(R(i-1),\; r_i + R(p(i))\bigr), \qquad R(0) = 0$$

Identical to Section 7 with weights $r_i$ and intervals $[x_i, x_i + 5)$.

> [!warning] "At least 5 miles" vs `> 5`
> The problem statement says *at least* 5 miles apart, i.e. $x_i - x_j \ge 5$ is legal, but the
> deck's $p(i)$ uses strict $x_i - x_j > 5$. With integer coordinates and "at least", the test
> should be $\ge 5$. Read the wording, write the predicate, then the code.

---

## 9. Kadane's algorithm as a DP

**Motivate.** The maximum-subarray problem was solved "by hand" earlier in the course; the
deck now derives the same algorithm from the DP recipe, which shows the recipe is not
mechanical hand-waving.

**Define.** Let $V[i]$ be the best sum of a subarray **ending exactly at** $A[i]$:

$$V[i] = \max\bigl(A[i],\; A[i] + V[i-1]\bigr), \qquad V[1] = A[1]$$

The answer is $\max_i V[i]$, not $V[n]$ — the best subarray may end anywhere.

![[12_DP1.pdf#page=31]]
*Figure: $V[i]$ and the running maximum for $A = (-2,1,-3,4,-1,2,1,-5,4)$; note $V_{max}$ is a
separate array because the optimum does not have to end at $n$. (`12_DP1.pdf` p. 31)*

**In plain words.** Read the row keeping a running total, and the moment that total is worse than
simply starting again at the current number, start again there. The best total you glimpsed along
the way is the answer. It is a shop that only ever revises its record day when a fresh run beats
the old record.

**Example (traced).** $A = (-2,1,-3,4,-1,2,1,-5,4)$.

| $i$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|
| $A[i]$ | -2 | 1 | -3 | 4 | -1 | 2 | 1 | -5 | 4 |
| $V[i]$ | -2 | 1 | -2 | 4 | 3 | 5 | 6 | 1 | 5 |
| $V_{max}$ | -2 | 1 | 1 | 4 | 4 | 5 | 6 | 6 | 6 |

Answer $6$, the subarray $A[4..7] = (4,-1,2,1)$.

**Space.** $V[i]$ depends only on $V[i-1]$, so a single variable `V` suffices — $\Theta(1)$
space, $\Theta(n)$ time. To also return the *location*, remember `start`/`end`, and `temp`
(the candidate start) reset to $i$ whenever $A[i]$ beats $A[i] + V$:

![[12_DP1.pdf#page=32]]
*Figure: Kadane's algorithm with start/end tracking, and the rule for resetting `temp`.
(`12_DP1.pdf` p. 32)*

```text
Vmax <- -inf; V <- 0; start <- 1; end <- 1; temp <- 1
for i <- 1 to n
    V <- V + A[i]
    if V < A[i] then            // equivalently: V[i-1] < 0
        V <- A[i]; temp <- i    // restart the subarray here
    if V > Vmax then
        Vmax <- V; start <- temp; end <- i
return Vmax
```

**Trap.** `if V < A[i]` is *not* the same code path as `if V[i-1] < 0` only because they are
algebraically equal — write whichever you can defend. What is **not** optional is that
`temp` is only promoted to `start` when `Vmax` improves; setting `start <- i` on every reset
gives the *last* best subarray, not the best one.

---

## 10. Coin change: when greedy fails and DP saves you

**Define.** Given amount $n$ and denominations $d_1,\dots,d_k$, find the minimum number of
coins summing to $n$. (Greedy = repeatedly take the largest coin.)

**In plain words.** Coins of 1, 3 and 4. To pay 6 the greedy rule hands over a 4 and then needs
two 1s — three coins. Two 3s would have done it. The big coin is not wrong in itself; it is wrong
because of the hole it leaves behind.

**Example (greedy is wrong).** Denominations $\{1,3,4\}$, $n = 6$:

| | coins | count |
|---|---|---|
| Greedy | $4 + 1 + 1$ | 3 |
| Optimal | $3 + 3$ | 2 |

(HK coins $\{1,2,5,10\}$ *are* greedy-safe — that is a property of the denomination set, not of
greedy. See [[lec_10-11_greedy]] for the coin system that broke even the pre-1971 British set.)

**The recurrence.** Condition on the last coin used:

$$C(n) = 1 + \min_{i:\; d_i \le n} C(n - d_i), \qquad C(0) = 0$$

![[12_DP1.pdf#page=35]]
*Figure: the tabulated version, keeping `S[p]` = last coin used for amount $p$.
(`12_DP1.pdf` p. 35)*

```text
DP-COIN(n)
    C[0] <- 0
    for p <- 1 to n                    // problem size grows
        min <- infinity
        for i <- 1 to k                // every denomination
            if p >= d[i] and 1 + C[p - d[i]] < min then
                min <- C[p - d[i]] + 1
                coin <- d[i]
        C[p] <- min
        S[p] <- coin                   // remember the decision
    return C[n]

// print the solution
while n > 0
    print S[n]
    n <- n - S[n]
```

**Cost.** $\Theta(nk)$ — the state count $n$ times the $k$ choices. Reconstruction is $\Theta(\text{number of coins})$.

**In plain words.** Write down, for every amount from 1 upwards, the fewest coins that pay it and
which coin you handed over last. Each amount only looks back at a few smaller amounts and copies
the cheapest. Printing the answer is then just walking back down the notes: 6 was paid with a 3,
3 was paid with a 3, no amount left.

**Example (traced).** Denominations $\{1,3,4\}$, $n = 6$: $C = (0,1,2,1,1,2,2)$ with
$S = (0,1,1,3,4,1,3)$, so $C(6) = 2$ and the walk prints $S_6 = 3$, $6-3 = 3$, $S_3 = 3$, done
$\to \{3,3\}$. Note $C(5) = 2$ via $\{4,1\}$ while $C(6) = 2$ via $\{3,3\}$: the optimum for $n$
is *not* built from the greediest-looking single coin.

**When $n$ is huge.** Two escape hatches from the deck's last slide:

1. **Divide by the GCD** of all denominations — it changes nothing about the answer but shrinks
   $n$ proportionally (here $\gcd(1000,5000,9999,10000,50000) = 1$, so this does nothing).
2. **Top-down with a hash table.** For $n = 19{,}999$ and those denominations, a dense
   array of size 20,000 is fine, but for $n = 10^9$ you switch to
   `MakeChange(p)` with `p in C` as a hash lookup, and only the reachable amounts are ever
   computed. Cost becomes $\Theta(k \cdot \#\{\text{reachable amounts}\})$.

> [!tip] Which DP shape does the problem want?
> Ask: *is the state one number or two?* Amount alone (Section 10), rod length alone (Section 3), index
> alone (Sections 6, 7, 9) $\Rightarrow$ 1-D table. If a decision must remember **which items were
> already used**, one number is not enough — that is the 0/1 knapsack trap in
> [[lec_13_2d_dynamic_programming]].

---

## 11. Highlights

*(This deck has no summary slide; these are the load-bearing claims, gathered from its closing
slides and exercises.)*

- Exponential recursion + repeated subproblems = DP. Store each **distinct** subproblem once:
  $\Theta(\varphi^n) \to \Theta(n)$ for Fibonacci.
- Bottom-up is the default (no stack, allows space optimisation); top-down with a hash table
  wins when the state space is sparse.
- A DP solution is **three** artefacts, not one: the recurrence, the value table, and the
  decision table used to reconstruct the answer.
- Every recurrence here conditions on the **last/first decision**, then recurses on what is
  left: first piece (rod), last coin (change), job $j$ in or out (WIS), $a_i$ in or out
  (non-adjacent), subarray ending at $i$ (Kadane).
- "Greedy fails" is the recurring theme: coins $\{1,3,4\}$, non-adjacent $(1,4,6,4)$, and
  weighted intervals are all one-line counterexamples.

## 12. Exam traps

- **Value table without decision table** $\to$ you can print $r_n$ but not the cut. Keep `s[]`.
- **$W_i = \max(W_{i-2}+a_i, W_{i-1})$ with $W_1 = 0$** $\to$ wrong; the base case is $W_1 = a_1$. A
  common slip that only shows up as an off-by-one in the last cell.
- **Max subarray: reporting `V[n]`** $\to$ wrong. The answer is $\max_i V[i]$, because the best
  subarray need not end at $n$.
- **Kadane on all-negative input returning 0** $\to$ initialise `Vmax <- -inf`, not `0`; with
  all negatives the answer is the largest (negative) element.
- **Rod cutting: "the greedy price-per-unit must be in the optimum"** $\to$ false; $s_7 = 1$,
  not 6, even though $p_6/6 \approx 2.83$ beats $p_1/1 = 1$.
- **WIS reconstruction stepping $j \gets j-1$ after taking job $j$** $\to$ must be
  $j \gets p(j)$, otherwise you silently allow an overlapping job.
- **`p(j)` counted as "compatible with some $i<j$"** $\to$ it must be the **largest** such
  index; jobs $p(j) < i' < j$ are exactly the ones that clash with $j$.
- **Highway billboards: `> 5` vs `>= 5`** $\to$ "at least 5 apart" is legal at exactly 5. Read
  the statement, not the deck's shorthand.
- **Coin change: assuming greedy works** $\to$ it depends on the denomination set; prove it or
  tabulate. $\{1,3,4\}$, $n=6$ is the standard killer.
- **Copying an $O(n^2)$ table when only the previous row matters** $\to$ Fibonacci, Kadane and
  coin change all reduce to $\Theta(1)$/$\Theta(n)$ space; say so.
- **Top-down memoisation of an $n$-item subset state** $\to$ memory blows up; the state
  space, not the recursion, decides the complexity.
- **Recurrence direction** $\to$ fill in increasing order of subproblem size; a cell that
  reads a *larger* index than itself means you wrote the recurrence backwards.
