# Lecture 14 — Dynamic Programming over Intervals

> Source: `14_DPinterval.pdf` (31 pages). Goal: the third table shape. [[lec_12_dynamic_programming|Lecture 12]] and
> [[lec_13_2d_dynamic_programming|Lecture 13]] ranged over *prefixes*; here the state is a **contiguous interval** $[i,j]$, the table is filled by
> **diagonals** (increasing interval length), and the answer lands in the top-right corner. Four
> instances of the same skeleton: palindromes, matrix-chain multiplication, optimal BSTs, RNA.

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The technique:** [[terms/interval-dp|Interval DP]] · [[terms/dynamic-programming]]

**The problems:** [[terms/palindrome]] · [[terms/matrix-chain-multiplication]] · [[terms/optimal-bst]] · [[terms/rna-secondary-structure]]

**Contrast cases:** [[terms/LCS]] · [[terms/longest-common-substring]] · [[terms/huffman-coding]] · [[terms/greedy-algorithm]]

---

## 1. Longest palindromic substring

**Motivate.** "Find the longest stretch of this string that reads the same both ways." The naive
answer checks every start, every end, and compares — the deck quotes $O(n^3)$. The structure that
saves you is that **a palindrome contains a smaller palindrome**: shave both ends and you still
have one.

**Define.** $p[i,j]$ is `true` iff $X[i..j]$ is a palindrome. Then

$$p[i,j] = \text{true} \iff x_i = x_j \text{ and } p[i+1,j-1]$$

with base cases $p[i,i] = \text{true}$ (every single character) and
$p[i,i+1] = [x_i = x_{i+1}]$ (a two-character window).

**In plain words.** A word is a mirror if its two end letters agree *and* what is left after
removing both ends is also a mirror. So you start from the tiniest mirrors — one letter always
qualifies, two letters qualify only when they match — and grow outwards: each longer window asks
just one question about the two letters you are adding, and looks up the window you already
answered inside. Nothing is ever recomputed, and the biggest window you ever marked true is the
answer.

**Example (deck p. 2, checked).** $X = $ `ACCABA`. The palindromic substrings of length at least
2 are `CC` (positions 2–3), `ACCA` (1–4) and `ABA` (4–6). The longest is `ACCA`, length 4. Brute
force compares $O(n)$ characters per window over $\Theta(n^2)$ windows; the DP fills 21 cells, each
in constant time.

![[14_DPinterval.pdf#page=2]]
*Figure: the problem statement and the `ACCABA` instance. (`14_DPinterval.pdf` p. 2)*

**Trap.** A substring must be **contiguous** — this is not the subsequence problem of Section 3,
and the two recurrences look different for exactly that reason.

---

## 2. The table, filled by diagonals

**Why diagonals.** $p[i,j]$ reads $p[i+1,j-1]$: one step in from *both* ends. In a matrix indexed
by $i$ (row) and $j$ (column), that cell lies one row **down** and one column **left** — i.e. on
the previous diagonal. So the whole table must be filled by increasing $j - i$, never row by row.

![[14_DPinterval.pdf#page=4]]
*Figure: the four stages of the fill — base diagonals, then $j = i+2$, $i+3$, and the rest — with
the complete table on the right. (`14_DPinterval.pdf` p. 4)*

```text
max <- 1
for i <- 1 to n-1                       // base cases: lengths 1 and 2
    p[i,i] <- true
    if x_i = x_{i+1} then p[i,i+1] <- true;  max <- 2
    else                 p[i,i+1] <- false
p[n,n] <- true
for l <- 3 to n                         // then by increasing length
    for i <- 1 to n-l+1
        j <- i+l-1
        if x_i = x_j and p[i+1,j-1] then
            p[i,j] <- true;  max <- l
        else p[i,j] <- false
return max
```

**In plain words.** All the length-1 windows go on the main diagonal, all the length-2 windows on
the diagonal above it, and so on; each diagonal only ever looks at the one below it. Reading the
table diagonally is the same as saying "solve the short stretches before the long ones".

**Example (deck p. 4, checked).** $X = $ `BABBCCCB` (n = 8). Filling by length gives:

| $i \backslash j$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 1 | T | F | **T** | F | F | F | F | F |
| 2 | — | T | F | F | F | F | F | F |
| 3 | — | — | T | T | F | F | F | F |
| 4 | — | — | — | T | F | F | F | **T** |
| 5 | — | — | — | — | T | T | T | F |
| 6 | — | — | — | — | — | T | T | F |
| 7 | — | — | — | — | — | — | T | F |
| 8 | — | — | — | — | — | — | — | T |

The longest true cell is $p[4,8]$: `BCCCB`, length 5. Every entry is explained by one look
one-diagonal-in:

- $p[1,3]$: $x_1 = x_3 = $ `B` and $p[2,2] = $ T ⇒ **T** (`BAB`).
- $p[5,7]$: $x_5 = x_7 = $ `C` and $p[6,6] = $ T ⇒ **T** (`CCC`).
- $p[4,8]$: $x_4 = x_8 = $ `B` and $p[5,7] = $ T ⇒ **T** (`BCCCB`).
- $p[3,7]$: $x_3 = $ `B` but $x_7 = $ `A` ⇒ F, whatever $p[4,6]$ says.

**Cost.** $O(n^2)$ time: $\Theta(n^2)$ cells, $O(1)$ each. Space $O(n^2)$, reducible to $O(n)$
because a cell only needs the previous diagonal (the deck's note).

> [!warning] The deck changes strings between p. 2 and p. 4
> The worked instance on p. 2 is `ACCABA`; the table on p. 4 is for `BABBCCCB`, whose characters
> are printed above the table. Both are correct — they are different examples. Do not "verify" the
> p. 2 string against the p. 4 table.

---

## 3. Longest palindromic subsequence

**Define.** A **subsequence** may skip characters. $dp[i,j]$ = length of the longest palindromic
subsequence of $X[i..j]$, with

$$\begin{aligned}
& dp[i,j] = dp[i+1,j-1] + 2 && x_i = x_j \\
& dp[i,j] = \max\{dp[i+1,j],\, dp[i,j-1]\} && x_i \ne x_j
\end{aligned}$$

base cases $dp[i,i] = 1$ and $dp[i,i+1] = 2$ if the two characters match, else $1$.

**In plain words.** Same mirror idea, but you are allowed to throw letters away, so a window has
two options instead of one: if its end letters match, glue them on to whatever the inside can do
(gaining two); if they do not match, at least one end must be abandoned, so take whichever of
"drop the left end" or "drop the right end" leaves more. Nothing is ever recomputed, so the
top-right cell is the answer.

**Example (deck pp. 6–7, checked).** $X = $ `ACBBCABA` (n = 8). The DP gives
$dp[1,8] = 6$; one witness is $X[1..5]$ plus $X[7]$: `A` `C` `B` `B` `C` `A` = `ACBBCA`, which
reads the same backwards. (`ABCBA` of length 5 is available too — the DP only promises the
*length*.)

| window | why | value |
|---|---|---|
| `BB` at 3–4 | equal ends, inside empty ⇒ $0 + 2$ | 2 |
| `BCB` at 4–7 | $x_4 = x_7 = $ `B` ⇒ $dp[5,6] + 2 = 1 + 2$ | 3 |
| `ACBBCABA` at 1–8 | $x_1 = x_8 = $ `A` ⇒ $dp[2,7] + 2 = 4 + 2$ | 6 |

**Reconstruction.** Store in $sol[i,j]$ which of the three cases won: 1 = "ends matched", 2 = "take
the left-dropped window", 3 = "take the right-dropped window". Then print recursively — match ⇒
print $x_i$, recurse inside, print $x_j$; otherwise recurse into the chosen side. $O(n^2)$ time and
space, prints in $O(n)$.

![[14_DPinterval.pdf#page=8]]
*Figure: `printsol` — the print-twice-around-the-recursion pattern. (`14_DPinterval.pdf` p. 8)*

> [!tip] Substring vs subsequence, in one table row each
> Contiguous: `p[i,j]` is true iff $x_i = x_j$ **and** $p[i+1,j-1]$ — a **predicate**, whose base is
> the diagonal. Non-contiguous: $dp[i,j]$ is $dp[i+1,j-1] + 2$ when $x_i = x_j$, otherwise the
> larger of $dp[i+1,j]$ and $dp[i,j-1]$ — a **maximisation** that never fails, it only abandons an
> end.

---

## 4. The reverse-string trap

**The tempting shortcut.** A palindrome reads the same as its reverse, so: compute the LCS of $X$
and $\text{rev}(X)$ and you have the longest palindromic something. Does it work?

**In plain words.** Take the word and its mirror image and look for the longest piece they share.
It feels like that shared piece must be a palindrome — but sharing a run of letters with your own
mirror only says the letters appear in both, not that they appear *in a mirror pattern* in the
same place. Two different letters can each be found in the mirror, and you can stitch them into a
"common" piece that never was a palindrome at all.

**Example (deck p. 9, checked).** $X = $ `abcdba`, $\text{rev}(X) = $ `abdcba`.

| quantity | value |
|---|---|
| longest palindromic **substring** of `abcdba` | `a` (length 1 — no two adjacent letters match) |
| longest **common substring** of `abcdba` and `abdcba` | `ab` (and `ba`), length 2 |

So the shortcut answers 2 for a string whose true answer is 1 — it is **wrong** for substrings.

**For subsequences it is right, but only the length.** $X = $ `abcab`, $\text{rev}(X) = $ `bacba`:
the LPS has length 3 (`aba`, `bcb`), and the LCS also has length 3 — but the LCS includes `acb`,
which is not a palindrome. The deck's phrasing is exact: *the length must be equal*, and proving
that this always holds is not easy.

> [!warning] "Same length" is not "same answer"
> An exam question that asks you to *print* a longest palindromic subsequence cannot be answered by
> running LCS against the reverse and printing whatever comes out — the strings differ. Use the
> $dp$/$sol$ table of Section 3.

---

## 5. The interval-DP pattern

![[14_DPinterval.pdf#page=10]]
*Figure: the fill order — base diagonals first, then every interval of length 2, 3, …, $n$; the
answer of the whole problem sits at the top-right. (`14_DPinterval.pdf` p. 10)*

Every problem in this lecture is the same five-part skeleton:

| Part | What it is |
|---|---|
| **State** | $T[i,j]$ = best/true answer for the contiguous range $i..j$ |
| **Base cases** | intervals of length 1 (and sometimes 2) — the diagonal |
| **Split** | some index $k$ with $i \le k < j$ that divides $[i,j]$ into left and right parts |
| **Recurrence** | combine $T[i,k]$ and $T[k+1,j]$ (or $T[i,k-1]$, $T[k+1,j]$) plus a cost for the split; take the best over all $k$ |
| **Answer** | $T[1,n]$ — the **top-right** cell, not the bottom-right one |

**In plain words.** All four problems are "the whole is made of a left part and a right part that
only touch at one seam". So you guess where the seam is, solve both sides (already done, because
they are shorter), add the price of stitching, and keep the cheapest seam. Filling by length
guarantees both sides are finished before you need them.

**Cost pattern.** $n^2$ states × $O(n)$ split points = $O(n^3)$ for matrix-chain, optimal BST and
RNA; $O(n^2)$ when the recurrence does not try all splits (palindromes).

> [!important] Why $[i,j]$ and not "first $j$ items"
> A prefix state cannot describe a range whose left end moves. Interval DP buys that freedom by
> paying one extra dimension — which is exactly why the table is filled by diagonal length rather
> than by row.

---

## 6. Matrix-chain multiplication: what a product costs

**Motivate.** Multiplying a $p \times q$ matrix by a $q \times r$ matrix costs $pqr$ scalar
multiplications. Matrix multiplication is associative, so the *order* is free — and the order
changes the cost enormously.

**Define.** $A_i$ has dimensions $p_{i-1} \times p_i$, so the input is the array
$p_0, p_1, \dots, p_n$. A parenthesisation of $A_1 A_2 \cdots A_n$ splits it at some $k$ into
$A_{1..k}$ (dimensions $p_0 \times p_k$) and $A_{k+1..n}$ (dimensions $p_k \times p_n$), whose
product costs $p_0\,p_k\,p_n$.

![[14_DPinterval.pdf#page=11]]
*Figure: one multiplication — the middle dimension is consumed. (`14_DPinterval.pdf` p. 11)*

**In plain words.** Think of multiplying as "the two outer sizes are what you pay, the inner size
is what is cancelled". Multiplying a long thin matrix by a thin tall one is cheap; if instead you
first create a huge square matrix, you pay for its size twice. So the parenthesisation decides
when a big matrix gets created, and therefore how often you pay for it.

**Example (deck p. 12, checked).** $A_{10\times100}$, $B_{100\times5}$, $C_{5\times50}$:

| order | first product | then | total |
|---|---|---|---|
| $(AB)C$ | $AB$: $10\cdot100\cdot5 = 5{,}000$ (gives $10\times5$) | $10\cdot5\cdot50 = 2{,}500$ | **$7{,}500$** |
| $A(BC)$ | $BC$: $100\cdot5\cdot50 = 25{,}000$ (gives $100\times50$) | $10\cdot100\cdot50 = 50{,}000$ | $75{,}000$ |

A factor of 10 from parentheses alone. With $n$ matrices the number of parenthesizations is the
Catalan number, exponential in $n$ — enumeration is out.

![[14_DPinterval.pdf#page=12]]
*Figure: the two parenthesizations of three matrices, with their costs. (`14_DPinterval.pdf` p. 12)*

---

## 7. Matrix-chain: trying every split

**The recurrence.** Let $m[i,j]$ be the minimum number of scalar multiplications to compute
$A_{i..j}$:

$$m[i,j] = \min_{i \le k < j}\bigl\{m[i,k] + m[k+1,j] + p_{i-1}\,p_k\,p_j\bigr\},
\qquad m[i,i] = 0$$

**In plain words.** To multiply a run of matrices, the very last multiplication joins two
finished pieces — a left run and a right run — and you may choose where that join happens. Pay for
the left run, pay for the right run, pay for the join, and try every possible join point. The
smallest total wins. Every piece you ask about is shorter than the whole run, so it is already in
the table.

![[14_DPinterval.pdf#page=17]]
*Figure: the recurrence with its three terms labelled — left cost, right cost, join cost.
(`14_DPinterval.pdf` p. 17)*

**Example (deck pp. 13–14, checked).** $A_{5\times5}\,B_{5\times4}\,C_{4\times8}\,D_{8\times2}$,
i.e. $p = (5,5,4,8,2)$. The five parenthesizations cost:

| # | order | arithmetic | total |
|---|---|---|---|
| 1 | $(A(B(CD)))$ | $50 + 40 + 64$ | **154** ← best |
| 2 | $(A((BC)D))$ | $50 + 80 + 160$ | 290 |
| 3 | $((AB)(CD))$ | $40 + 100 + 64$ | 204 |
| 4 | $((A(BC))D)$ | $80 + 200 + 160$ | 440 |
| 5 | $(((AB)C)D)$ | $80 + 160 + 100$ | 340 |

**Why #1 wins.** $CD$ is the cheapest pair to multiply ($4\cdot8\cdot2 = 64$) and it produces a
tiny $4\times2$ matrix, so `B(CD)` is cheap and every later step is small. The DP finds this
without trying all 5 orders for $n=4$ or all 14 for $n=5$.

**The table (checked).** Filling by length:

| $m[i,j]$ | $j{=}1$ | 2 | 3 | 4 |
|---|---|---|---|---|
| $i{=}1$ | 0 | 100 | 260 | **154** |
| 2 | — | 0 | 160 | 104 |
| 3 | — | — | 0 | 64 |
| 4 | — | — | — | 0 |

Read one cell by hand: $m[1,3] = \min\{m[1,1] + m[2,3] + 5\cdot5\cdot8,\; m[1,2] + m[3,3] + 5\cdot4\cdot8\} = \min\{0+160+200,\; 100+0+160\} = 260$.

**Reconstruction.** Keep $s[i,j] = k$ where the minimum occurred; then
`solve(i,j)`: if $i=j$ return $A_i$, else return `(` $+$ `solve(i, s[i,j])` $+$
`solve(s[i,j]+1, j)` $+$ `)`.

**Cost.** $\Theta(n^3)$ time, $\Theta(n^2)$ space. Hu and Shing (1981) do $O(n\log n)$; the deck
only mentions it.

![[14_DPinterval.pdf#page=18]]
*Figure: `MATRIX-CHAIN-ORDER` — three nested loops, plus the split table that makes reconstruction
possible. (`14_DPinterval.pdf` p. 18)*

---

## 8. Optimal binary search tree: why greedy dies

**Define.** Given keys $a_1 < \cdots < a_n$ with access weights $f(a_i)$, build a BST minimising

$$B(T) = \sum_{i=1}^{n} f(a_i)\,(d(a_i) + 1)$$

where $d(a_i)$ is the depth. The $+1$ counts the node itself, so $B(T)$ is the expected number of
comparisons.

![[14_DPinterval.pdf#page=20]]
*Figure: the problem, and the two differences from Huffman — the keys must stay in sorted order,
and keys may sit at internal nodes. (`14_DPinterval.pdf` p. 20)*

**In plain words.** A phone directory where some names are looked up far more often than others.
You want the popular names near the top, but you are not free to arrange them any way you like —
the alphabetical order must still hold, so putting a crowd favourite on top forces everyone
smaller into the left half and everyone larger into the right. That constraint is what makes this
a different problem from Huffman, where leaves can be shuffled freely.

**Why the obvious greedy fails.** "Put the heaviest key at the root, recurse on both sides." Weights
$A{:}0.1$, $B{:}0.2$, $C{:}0.3$, $D{:}0.4$:

| tree | shape | cost |
|---|---|---|
| greedy | root $D$, then $C$, then $B$, then $A$ — a **chain** | $0.4\cdot1 + 0.3\cdot2 + 0.2\cdot3 + 0.1\cdot4 = 2.0$ |
| better | root $C$, left $B$ (with left $A$), right $D$ | $0.3\cdot1 + 0.2\cdot2 + 0.1\cdot3 + 0.4\cdot2 = 1.8$ |

**In plain words (the failure).** Putting the heaviest key on top sounds right, but the second and
third heaviest are then forced to hang below it, and the lightest key gets buried four levels deep.
Rooting at the *middle* key instead lets the heaviest key sit one level down on the short side —
you lose one step on the top key and win a step for everyone else. Locally cheap, globally worse.

![[14_DPinterval.pdf#page=21]]
*Figure: the two trees and their costs, $2.0$ versus $1.8$. (`14_DPinterval.pdf` p. 21)*

> [!warning] "It looks like Huffman"
> Two differences destroy the Huffman argument: keys are **ordered** (so a leaf cannot be moved
> anywhere), and keys are **internal nodes** (so depth counts differently — Huffman's $d$ versus
> this $d+1$). The merges Huffman relies on are not available here.

---

## 9. Optimal BST: the recurrence

**The key step.** If the root of the optimal tree on $a_i \dots a_j$ is $a_k$, then its left subtree
must be an optimal tree on $a_i \dots a_{k-1}$ and its right subtree an optimal tree on
$a_{k+1} \dots a_j$ — otherwise swapping in a cheaper subtree would improve the whole tree.

**The subtlety.** Pruning a subtree makes every key in it **one level shallower**, so the cost of a
subtree is not directly comparable: it is measured relative to its own root. That is why the
recurrence adds $w[i,j]$, the total weight of the range, once per level:

$$\begin{aligned}
B(T_{i,j}) &= B(T_{i,k-1}) + w[i,k-1] + f(a_k) + B(T_{k+1,j}) + w[k+1,j] \\
&= B(T_{i,k-1}) + B(T_{k+1,j}) + w[i,j]
\end{aligned}$$

where $w[i,j] = f(a_i) + \cdots + f(a_j)$.

**In plain words.** Every key in the range must be pushed one step further down when you attach the
range under a new root, so each of them gets one extra comparison — one extra step costs the sum of
their weights. That single "plus the whole range's weight" term is the entire difference from the
matrix-chain recurrence, and it is what students forget.

$$e[i,j] = \min_{i \le k \le j}\bigl\{e[i,k-1] + e[k+1,j] + w[i,j]\bigr\},
\qquad e[i,j] = 0 \text{ for } i > j$$

**Base cases.** $e[i,i] = f(a_i)$ (a single key at level 1), and $e[i,j] = 0$ for $i > j$ (empty
range, which is what makes $k = i$ and $k = j$ work without special cases).

**Example (deck's weights, checked).** $f = (0.1, 0.2, 0.3, 0.4)$ for $A,B,C,D$. The DP gives
$e[1,4] = 1.8$ with root $C$, left root $B$, right root $D$ — exactly the $1.8$ tree above, and
$1.8 < 2.0$, confirming the greedy tree was not optimal.

| range | $w[i,j]$ | $e[i,j]$ | root |
|---|---|---|---|
| $[1,1]$ | 0.1 | 0.1 | A |
| $[2,2]$ | 0.2 | 0.2 | B |
| $[1,2]$ | 0.3 | 0.4 | B |
| $[3,4]$ | 0.7 | 1.0 | D |
| $[1,3]$ | 0.6 | 1.0 | B |
| $[2,4]$ | 0.9 | 1.5 | C |
| $[1,4]$ | 1.0 | **1.8** | **C** |

Check the whole range by hand, $k$ running over all four keys:

| root $k$ | $e[i,k-1] + e[k+1,j] + w[1,4]$ | total |
|---|---|---|
| A | $0 + e[2,4] + 1.0 = 0 + 1.5 + 1.0$ | 2.5 |
| B | $e[1,1] + e[3,4] + 1.0 = 0.1 + 1.0 + 1.0$ | 2.1 |
| C | $e[1,2] + e[4,4] + 1.0 = 0.4 + 0.4 + 1.0$ | **1.8** |
| D | $e[1,3] + 0 + 1.0 = 1.0 + 1.0$ | 2.0 |

**Cost.** Pre-compute all $w[i,j]$ in $O(n^2)$ (or as running sums), then $O(n^3)$ for the table:
$n^2$ ranges × $n$ possible roots. Knuth–Yao brings it to $O(n^2)$; the deck states the bound
without proof.

![[14_DPinterval.pdf#page=26]]
*Figure: the algorithm — fill $w$, then $e$ and `root` by increasing range length. (`14_DPinterval.pdf` p. 26)*

**Reconstruction.** `root[i,j]` gives the key at the root of the optimal tree for $[i,j]$; recurse
on $[i, root-1]$ and $[root+1, j]$; the empty range returns nil. $O(n)$.

---

## 10. RNA secondary structure

**Define.** Given bases $b_1 \dots b_n$, a secondary structure is a set of pairs satisfying:

| Constraint | Meaning |
|---|---|
| Watson–Crick | only A–U, U–A, C–G, G–C |
| no sharp turns | if $(b_i, b_j)$ is a pair then $i < j-4$ (at least 4 bases in between) |
| non-crossing | pairs $(b_i,b_j)$ and $(b_k,b_l)$ may not have $i < k < j < l$ |

Maximise the number of pairs (the free-energy proxy).

![[14_DPinterval.pdf#page=28]]
*Figure: OK, sharp turn, and crossing structures; the RNA folds into stems.
(`14_DPinterval.pdf` p. 28)*

**In plain words.** A strand of RNA folds back on itself and glues matching letters together, but
only letters that are far enough apart can reach, and the strand cannot pass through itself — so
two glued pairs either sit side by side or nest, never cross. Maximising pairs is then the same
game as before: look at the last base, and decide either "it glues to nothing" or "it glues to some
earlier base", which cuts the strand into an inside and an outside that can be solved separately.

**The recurrence.** $M[i,j]$ = max pairs in $b_i \dots b_j$:

$$\begin{aligned}
& M[i,j] = 0 && i \ge j-4 \quad \text{(no sharp turns)} \\
& M[i,j] = \max\Bigl(M[i,j-1],\; \max_{k}\{1 + M[i,k-1] + M[k+1,j-1]\}\Bigr)
\end{aligned}$$

the inner max over $k$ with $i \le k \le j-5$ and $b_k, b_j$ complementary. Case 2a ($b_j$
unmatched) and case 2b ($b_j$ pairs with $b_k$) are the two options.

**Example (mine — the deck gives no numeric instance).** $B = $ `AUGUGGCCAU`, $n = 10$. Optimal
value 3, with three **nested** pairs:

| pair | bases | gap $j-i$ |
|---|---|---|
| $(1,10)$ | A–U | 9 |
| $(2,9)$ | U–A | 7 |
| $(3,8)$ | G–C | 5 |

All three gaps are $\ge 5$, and the pairs nest ($1<2<3<8<9<10$), so no crossing. Taking any
fourth pair is impossible: bases 4–7 are `UGGC`, and the only complement available for a base in
the middle would have to reach past an already-nested pair, which crosses.

**Why the non-crossing constraint is what makes DP possible.** Removing the pair $(k,j)$ leaves
two independent intervals $[i,k-1]$ and $[k+1,j-1]$; crossing pairs would leave three interleaved
pieces, and no two-index state could describe them.

**Cost.** $O(n^3)$ time, $O(n^2)$ space. Reconstruction keeps $s[i,j]$ = the partner of $j$ (0 if
unmatched) and recurses exactly as the palindrome printer does.

![[14_DPinterval.pdf#page=31]]
*Figure: the algorithm and `Construct-RNA`. (`14_DPinterval.pdf` p. 31)*

---

## 11. Highlights

*(The deck has no summary slide; this is its 31 pages distilled.)*

- Interval DP replaces the prefix state of Lectures 12–13 with a **range** $[i,j]$; the price is a
  second dimension and a diagonal fill order.
- Fill by **increasing length**: length 1 (and often 2) are the base cases on the main diagonal,
  and the answer for the whole problem is the **top-right** cell.
- Palindromic substring is a *predicate*: extend only when both ends agree and the inside is
  already a palindrome. $O(n^2)$.
- Palindromic subsequence is a *maximisation*: matching ends add 2, mismatching ends abandon one.
  Also $O(n^2)$.
- LCS against $\text{rev}(X)$ is **wrong** for palindromic substrings, and gives only the right
  *length* for palindromic subsequences.
- Matrix-chain: cost of joining is $p_{i-1}p_k p_j$; the split point $k$ is the only choice;
  $O(n^3)$, and the parenthesisation changes the answer by orders of magnitude.
- Optimal BST: like matrix-chain but every key drops one level when attached, so the recurrence
  adds $w[i,j]$ — the range's total weight — at every step. Greedy (heaviest at the root) is not
  optimal; weights $0.1,0.2,0.3,0.4$ give $2.0$ versus $1.8$.
- RNA: non-crossing pairs plus a minimum gap; choose "last base unmatched" or "last base pairs with
  $b_k$", giving two independent sub-intervals.

## 12. Exam traps

- **Filling by rows instead of diagonals** → $p[i,j]$ (or $m$, $e$, $M$) reads cells one diagonal
  in; row-major order reads zeros. This is the single most common mistake on this topic.
- **Looking for the answer in the bottom-right cell** → for interval DP it is the **top-right**,
  $T[1,n]$.
- **Missing the length-2 base case** → every odd-length palindrome then silently disappears and
  the answer is too small by one.
- **Palindrome substring: forgetting contiguity** → the subsequence recurrence (with a `max`) is
  wrong here; a substring needs $x_i = x_j$ **and** $p[i+1,j-1]$, with no alternative branch.
- **"Use LCS with the reverse"** → fails on `abcdba` (true answer 1, LCS-substring answer 2), and
  for subsequences it gives the right length but possibly a non-palindrome.
- **Matrix chain: charging $p_i p_j$ instead of $p_{i-1}p_k p_j$** → the joining cost uses the
  *outer* dimensions of the two pieces, which is the middle dimension $p_k$, not something else.
- **Matrix chain: multiplying the "cost" tables as if they were matrices** → $m[i,j]$ is a scalar
  count; only the dimensions $p$ matter.
- **Optimal BST: dropping $w[i,j]$** → you get the matrix-chain recurrence, which computes
  something else (it does not account for every key dropping one level). Always re-derive with
  the $+1$ in $B(T)$.
- **Optimal BST: applying Huffman** → keys are ordered and are internal nodes; Huffman's exchange
  lemma needs free leaves.
- **Optimal BST: greedy heaviest-as-root** → $2.0$ versus the optimal $1.8$ on four keys.
- **RNA: forgetting the $j-i \ge 5$ gap** → the "sharp turn" rule is part of the problem, not an
  optimisation; $k$ ranges only to $j-5$.
- **RNA: allowing crossing pairs** → the two-interval split is then invalid and no $[i,j]$ state
  can express the solution.
- **$O(n^3)$ claimed as optimal** → matrix chain has an $O(n\log n)$ algorithm (Hu–Shing) and
  optimal BST an $O(n^2)$ one (Knuth–Yao); the deck quotes these as asides, so say "the DP is
  $O(n^3)$", not "the problem is $O(n^3)$".
