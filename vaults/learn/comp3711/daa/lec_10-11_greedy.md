# Lectures 10–11 — Greedy Algorithms & Huffman Coding

> Sources: `10_Greedy.pdf` (28 pages, Sections 1–9) and `11_Huffman.pdf` (24 pages,
> Sections 10–14). Goal: one recipe (pick the locally best feasible choice, never look back),
> five problems where it works, three counterexamples where it does not, and the one proof
> technique — the **exchange argument** — that separates the two cases. Continues from
> [[lec_9_linearsort]]; the failures motivate [[lec_12_dynamic_programming]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The technique:** [[terms/greedy-algorithm|Greedy algorithm]] · [[terms/exchange-argument|Exchange argument]]

**Greedy that fails:** [[terms/coin-change]] · [[terms/0-1-knapsack|0/1 knapsack]]

**Greedy that works:** [[terms/interval-scheduling|Interval scheduling, covering and partitioning]] · [[terms/fractional-knapsack|Fractional knapsack]] · [[terms/huffman-coding|Huffman coding]] · [[terms/prefix-code|Prefix(-free) code]] · [[terms/weighted-external-path-length|Weighted external path length]]

**Supporting structures:** [[terms/priority-queue|Priority queue (min-heap)]] · [[terms/dynamic-programming]] · [[terms/big-O]]

---

## 1. What makes an algorithm greedy

**Motivate.** Every algorithm in this lecture looks the same at the top level: sort something,
then sweep. What differs is *why* the sweep is safe — and for three of the problems below it
is not safe at all.

**Define.** A greedy algorithm builds a solution through a sequence of choices that are

| Property | Meaning |
|---|---|
| **Feasible** | satisfies the problem's constraints |
| **Locally optimal** | best at this moment, ignoring the future |
| **Irrevocable** | never undone — no backtracking |

![[10_Greedy.pdf#page=2]]
*Figure: the three properties, and the honest caveat — for some problems greedy is globally
optimal, for others it is only a fast approximation. (`10_Greedy.pdf` p. 2)*

**Example (the cost shape).** Nearly every greedy algorithm here has one dominant step: the
sort. Interval scheduling, fractional knapsack and fractional-knapsack-style problems are
$\Theta(n\log n)$; interval partitioning and Huffman are $\Theta(n\log n)$ because of a
heap, not a sort. A greedy algorithm that needs no sort at all is $\Theta(n)$ — and that is
a strong hint you have found something better than the general recipe.

> [!important] The two duties of a greedy answer
> (1) State the rule precisely — *what* to sort by, and what "compatible" means.
> (2) **Prove** it. Without the proof, "greedy" is a guess; Section 2 is what a guess costs.

### 1.1 Where the rule comes from: the resource the future consumes

Do not guess the sort key. Ask two questions:

1. **What does the objective count?** (jobs, bits, coins, total weight.)
2. **What does one choice consume that the rest of the solution then has to live with?** That
   consumed quantity is the *resource*, and the greedy key is "resource consumed per unit of
   progress" — minimize it.

| Problem | One unit of progress | Resource it burns | Key to sort by |
|---|---|---|---|
| interval scheduling | 1 job | the time line from $f_j$ onwards | $f_j$ (finish time) |
| fractional knapsack | 1 unit of value | capacity $w_i$ | $v_i/w_i$ |
| interval covering | some coverage | one whole interval | right endpoint |
| interval partitioning | 1 lecture | one room until $f_j$ | process by $s_j$, track $\min f$ |
| Huffman | 1 character | one extra bit of depth | $f(a)$ |
| MST (Prim/Kruskal) | connecting a cut | one edge | $w(e)$ over crossing edges |

**Example of the method.** Interval scheduling: the objective counts jobs, and the only thing a
chosen job does to the future is *set when you are next free*. So the key is the job's finish
time — not its start, not its length. Interval partitioning looks like the same problem but the
resource is a **room**, and rooms are rented for a fixed stretch; you cannot reorder the demand,
so you sweep in arrival order ($s_j$) and the choice you make is *which room* — hence a heap of
finish times rather than a sort of them.

### 1.2 Try to break it before you try to prove it

A counterexample **is** a complete proof of wrongness, and it takes a minute. Try these three
adversarial patterns first; if one of them kills the rule, you are done.

| Pattern | How to build it | Where it works in this lecture |
|---|---|---|
| one big commit blocks many small ones | one long/valuable item versus several small ones | earliest-start scheduling, 0/1 knapsack, greedy coin change |
| a tie in the key | two items with the same sort key but different futures | interval partitioning sorted by finish time |
| high local score, expensive neighbourhood | the best item touches everything else | max sum of non-adjacent elements, $(1,4,6,4)$ |

If no counterexample survives, the rule is probably right — now prove it.

### 1.3 The four templates (every greedy proof in this course is one of these)

| Template | Claim structure | Used by |
|---|---|---|
| **A. Stays ahead** | invariant: after $t$ steps, greedy has consumed no more of the resource than *any* feasible solution has; then count | interval scheduling (Section 5), fractional knapsack (Section 6) |
| **B. Exchange / swap** | first disagreement → replace the optimal's choice by greedy's → still feasible, still optimal, one more index agrees → iterate | Sections 5, 6, 7, and the cut lemma ([[lec_17_minimum_spanning_trees]] Section 3) |
| **C. Lower bound + attain it** | prove no algorithm can beat $L$ (depth, $\lvert V\rvert-1$ edges, a cut's cheapest edge), then prove greedy achieves $L$ | interval partitioning (Section 8) |
| **D. Structural lemma + induction on size** | shrink the instance by one merge, show cost shifts by a known amount, induct | Huffman (Section 13) |

Templates A and B are the same argument in two costumes: A is the *invariant* version (compare
greedy to an arbitrary solution at every step), B is the *mutation* version (walk one optimal
solution towards greedy step by step). A is easier to state correctly; B is easier to invent,
because it only asks about one step.

### 1.4 The six obligations of a written greedy proof

1. **Canonical order.** Fix the representation: $G = (i_1,\dots,i_k)$, $O = (j_1,\dots,j_m)$, both in
   the same order (by time, by weight, by index).
2. **Name the invariant.** The scalar the future depends on (finish time, used weight, coverage
   point, tree size, depth).
3. **Single-step lemma.** Either "$f(i_t) \le f(j_t)$" (A) or "$j_{r+1}$ can be replaced by
   $i_{r+1}$" (B). This is the only creative part.
4. **Feasibility arithmetic.** Show the new solution is legal with **explicit inequalities on both
   sides** — the left neighbour and the right neighbour. Hand-waving here is where marks go.
5. **Objective preserved.** Same cardinality, same value, or no weight increase ⇒ still optimal.
6. **Closing.** Induction on the step count *and* a size argument showing greedy did not stop
   early. Obligation 6 is the one the deck's slide 14 skips — see Section 5.3.

---

## 2. Change-making: greedy is not automatically right

**Define.** Given amount $n$ and denominations $d_1 > d_2 > \dots > d_m$, pay $n$ with the fewest
coins. Greedy: use as many of the largest coin as possible, then the next, and so on.

**In plain words.** Hong Kong coins are 1, 2, 5 and 10 dollars, and a shopkeeper does exactly what
you would do: hand over the biggest coin that still fits, then the next biggest, and so on. For
19 dollars that is one ten, one five and two twos. Nothing beats it — but only because of how
those particular coins are sized, not because being greedy is a good idea in general.

**Example (Hong Kong coins, where it works).** $d = (10,5,2,1)$, $n = 19$:

$$19 = 10 + 5 + 2 + 2 \quad\Longrightarrow\quad 4 \text{ coins}$$

That is optimal, but the *reason* is a property of the set $\{1,2,5,10\}$, not of greedy.

**In plain words.** Before 1971 Britain had 30, 24, 12, 6 and 3 penny coins. To pay 48p, the greedy
rule grabs the 30 first, and now the 24 is useless, so it finishes with 30 + 12 + 6 — three coins.
Two 24s would have done it in two. The big coin was not a bad coin; it was a bad *opening move*,
because of the awkward amount it left behind.

**Example (British coinage before 1971, where it fails).** $d = (1,3,6,12,24,30,60)$, $n = 48$:

| | coins | count |
|---|---|---|
| Greedy | $30 + 12 + 6$ | 3 |
| Optimal | $24 + 24$ | 2 |

![[10_Greedy.pdf#page=3]]
*Figure: both instances on one slide. (`10_Greedy.pdf` p. 3)*

> [!warning] The denomination set is the hypothesis
> "Greedy is optimal for coin change" is **false as stated**. It is a theorem about *canonical*
> coin systems. The correct exam answer names the system or gives the counterexample — see
> [[terms/coin-change]] and the $\Theta(nk)$ DP in [[lec_12_dynamic_programming]] Section 10.

---

## 3. Max sum of non-adjacent elements

**Define.** Given positive $A[1..n]$, choose a subset of **non-adjacent** positions with maximum
sum.

**In plain words.** You may take numbers from a row but never two that sit side by side, and you
want the biggest total. In the row 1, 8, 6, 3, 6 the 8 is worth taking even though it costs you
the 6 beside it — because the 6 at the far end is then free. Best is 8 + 6 = 14.

**Example (deck's).** $A = (1,8,6,3,6)$: the optimum is $A[2] + A[5] = 8 + 6 = 14$. Note it
skips $A[3] = 6$ and $A[4] = 3$; the largest element and its neighbourhood are not the answer.

**In plain words.** Now the trap. In 1, 4, 6, 4 the tallest number stands between two 4s, so
grabbing the 6 throws away eight points of neighbours to gain six. Sit on your hands, take the two
4s, and you score 8 instead of 7. A tall poppy with rich neighbours is precisely what this rule
cannot see.

**The natural greedy, and its counterexample.** Repeatedly take the largest remaining element and
delete it with its two neighbours. On $A = (1,4,6,4)$:

| | chosen | sum |
|---|---|---|
| Greedy | take $6$, delete both $4$s, then take $1$ | $7$ |
| Optimal | $\{4,4\}$ | $8$ |

Greedy's myopia is exactly this: the largest element can be flanked by *two* good elements, and
the greedy rule throws both away.

**The fix (preview).** $W_i = \max(W_{i-1},\, W_{i-2} + a_i)$ — a two-case DP, developed in
[[lec_12_dynamic_programming]] Section 6.

---

## 4. Interval scheduling: the template, and three rules that fail

**Define.** Job $j$ runs from $s_j$ to $f_j$; two jobs are **compatible** if they do not overlap.
Find a maximum-size subset of mutually compatible jobs.

![[10_Greedy.pdf#page=7]]
*Figure: the deck's instance, with $\{b,e,h\}$ marked as a maximum-size subset.
(`10_Greedy.pdf` p. 7)*

**The template.** Consider the jobs in some order; take a job iff it is compatible with those
already taken. The **only** design decision is the order — and the deck's point is that three
obvious orders are all wrong.

![[10_Greedy.pdf#page=8]]
*Figure: the three candidate rules as the deck states them. (`10_Greedy.pdf` p. 8)*

**In plain words.** Three orders that sound sensible, and each dies on a tiny instance. Take the
job that starts first and one all-day job locks out four short ones. Take the shortest job and a
medium job in the middle blocks the two long jobs either side of it. Count conflicts and you are
using a global statistic as if it were local advice, so the job that quarrels with fewest others
can still be the one that ruins the day.

![[10_Greedy.pdf#page=9]]
*Figure: one counterexample per rule. Earliest start picks the single long $e$ instead of
$\{a,b,c,d\}$; shortest interval picks the middle $c$ instead of $\{a,b\}$; fewest conflicts
picks $f$, forcing $\{a,f,d\}$ instead of $\{a,b,c,d\}$. (`10_Greedy.pdf` p. 9)*

**My own instances, so the failure is checkable rather than visual.**

| Rule | Instance | Rule picks | Optimal |
|---|---|---|---|
| earliest start | $[0,10]$, $[1,2]$, $[3,4]$, $[5,6]$ | $\{[0,10]\}$, size 1 | 3 short jobs |
| shortest interval | $[0,5]$, $[6,10]$, $[4,7]$ | $\{[4,7]\}$ (length 3), size 1 | $\{[0,5],[6,10]\}$, size 2 |
| fewest conflicts | see the deck's figure above | $\{a,f,d\}$, size 3 | $\{a,b,c,d\}$, size 4 |

**Why each fails, in one line.** Earliest start commits to a job that may block many others;
shortest interval has no reason to prefer a central short job over the two long ones it blocks;
"fewest conflicts" is a global count used as if it were a local property, and it ignores *which*
jobs conflict.

> [!important] The lesson the deck draws explicitly
> A greedy rule is a **hypothesis about structure**. Three plausible hypotheses die on
> three-line instances. Finding the counterexample is half the work; the other half is the
> proof in Section 5.

---

## 5. Interval scheduling: earliest finish time is correct

**The rule.** Sort by finish time and take each job that starts after the last one taken. The
intuition is a single sentence: finishing as early as possible leaves the largest possible
interval for everything that remains.

![[10_Greedy.pdf#page=11]]
*Figure: the algorithm, the compatibility test $s_j \ge last$, and the $\Theta(n\log n)$ cost.
(`10_Greedy.pdf` p. 11)*

```text
Sort jobs so that f_1 <= f_2 <= ... <= f_n
A <- empty set;  last <- 0
for j <- 1 to n
    if s_j >= last then
        A <- A + {j}
        last <- f_j
return A
```

**In plain words.** Six meetings, each with a start and an end. Read them in the order they
*finish* and grab any that starts after the last one you grabbed — you end up with four, and four
is the most possible. Read them by finishing time because a meeting that ends early leaves the
whole rest of the day free.

**Example (my instance, traced).** Jobs: 1=[0,3], 2=[1,2], 3=[2,4], 4=[4,6], 5=[3,7], 6=[6,8].
Sort by finish: 2 (2), 1 (3), 3 (4), 4 (6), 5 (7), 6 (8).

| step | job | $s_j \ge last$? | action | `last` |
|---|---|---|---|---|
| 1 | 2=[1,2] | $1 \ge 0$ ✓ | take | 2 |
| 2 | 1=[0,3] | $0 \ge 2$ ✗ | skip | 2 |
| 3 | 3=[2,4] | $2 \ge 2$ ✓ | take | 4 |
| 4 | 4=[4,6] | $4 \ge 4$ ✓ | take | 6 |
| 5 | 5=[3,7] | $3 \ge 6$ ✗ | skip | 6 |
| 6 | 6=[6,8] | $6 \ge 6$ ✓ | take | 8 |

Answer $\{2,3,4,6\}$, size 4 — and exhaustive search confirms 4 is the maximum. Note that
touching intervals are *compatible* ($f_i \le s_j$), which is why step 3 accepts job 3 at the
instant job 2 ends.

**Proof, part 1 — the invariant ("greedy stays ahead").** Let $G = (i_1,\dots,i_k)$ be greedy's
output and $O = (j_1,\dots,j_m)$ any feasible solution, both in increasing time order.

> **Claim.** For every $t \le \min(k,m)$: $f(i_t) \le f(j_t)$.

*Proof by induction on $t$.*

- **$t = 1$.** $i_1$ is the job with the smallest finish time in the whole instance, so
  $f(i_1) \le f(j_1)$ for any job $j_1$.
- **$t > 1$.** Assume $f(i_{t-1}) \le f(j_{t-1})$. Because $O$ is feasible, $j_t$ does not overlap
  $j_{t-1}$, so $s(j_t) \ge f(j_{t-1}) \ge f(i_{t-1})$. Hence $j_t$ was **available** at the moment
  greedy chose its $t$-th job: it starts after greedy's last finish. Greedy takes the available
  job of minimum finish, so $f(i_t) \le f(j_t)$. ∎

One detail worth knowing, because it is the step people skip: $j_t$ cannot have been *rejected*
by greedy earlier. If greedy had scanned $j_t$ at some step $t' \le t-1$ and refused it, then
$j_t$ overlapped $i_{t'}$, i.e. $s(j_t) < f(i_{t'}) \le f(i_{t-1})$, contradicting
$s(j_t) \ge f(i_{t-1})$ just derived. So $j_t$ really is still on the table, and the argument is
not circular.

![[10_Greedy.pdf#page=12]]
*Figure: the picture behind the claim — greedy's $(r+1)$-th job finishes no later than $O$'s
$(r+1)$-th, so the two sequences are "interleaved" with greedy always ahead.
(`10_Greedy.pdf` p. 12)*

**Proof, part 2 — the count (why greedy does not stop early).** Take $O$ optimal, so $m = \mathrm{OPT}$.
Suppose $m > k$. Then $O$ has a job $j_{k+1}$, compatible with $j_k$, so
$s(j_{k+1}) \ge f(j_k) \ge f(i_k)$ by the claim at $t = k$. Two consequences:

- $f(j_{k+1}) \ge s(j_{k+1}) \ge f(i_k)$, so $j_{k+1}$ sits at or after $i_k$ in the finish-time
  order, i.e. greedy has **not yet scanned** it when it chooses $i_k$.
- When greedy does reach $j_{k+1}$, its last selected job is $i_k$ (or later) and
  $s(j_{k+1}) \ge f(i_k)$, so $j_{k+1}$ is compatible and greedy takes it or something better.

That contradicts "greedy's output has exactly $k$ jobs". Hence $m \le k$. Greedy's output is
feasible, so $k \le \mathrm{OPT} = m$. Therefore $k = m$: **greedy is optimal.**

> [!warning] Ties in finish times
> Part 2 assumes distinct finish times, which is what makes "scanned before / after" meaningful.
> If two jobs finish at the same instant, they are interchangeable as greedy choices, and the
> argument still goes through once you fix a consistent tie-break — but *say so* in the proof.
> The deck writes "$i_{r+1}$ finishes **before** $j_{r+1}$" on slide 12; the correct inequality is
> $\le$, and it matters exactly here.

**Proof, part 3 — the deck's exchange version (slides 13–14), line by line.** The deck proves the
same thing by *mutating* one optimal solution instead of comparing invariants. Let $r$ be the
largest index with $i_t = j_t$ for all $t \le r$ (so $O$ and $G$ agree on a prefix of length $r$).

| | first $r$ jobs | job $r+1$ | the rest |
|---|---|---|---|
| $G$ | $i_1,\dots,i_r$ | $i_{r+1}$ | … |
| $O$ (before) | $j_1,\dots,j_r$ (same) | $j_{r+1}$ | $j_{r+2},\dots,j_m$ |
| $O^*$ (after) | $i_1,\dots,i_r$ | $\mathbf{i_{r+1}}$ | $j_{r+2},\dots,j_m$ |

*One exchange step, with all three obligations checked:*

1. **Which job enters.** $i_{r+1}$, and $f(i_{r+1}) \le f(j_{r+1})$ — Part 1's argument applied at
   $t = r+1$, since $j_{r+1}$ is compatible with $j_r = i_r$ and so was available to greedy.
2. **Left neighbour.** $s(i_{r+1}) \ge f(i_r)$: true because greedy itself placed $i_{r+1}$ after
   $i_r$, so it is legal *on the left*.
3. **Right neighbour.** $f(i_{r+1}) \le f(j_{r+1}) \le s(j_{r+2})$: the first inequality is
   obligation 1, the second is just $O$'s feasibility. So $i_{r+1}$ is legal *on the right* too.
   **This is the "must still be compatible with the remainder of O" note on slide 13** — it is
   about $j_{r+2}$, not about $j_{r+1}$.
4. **Size.** One job out, one job in: $\lvert O^* \rvert = \lvert O \rvert = m$. The deck's phrase
   "cost remains the same" means exactly this — for *this* problem the objective is the job
   count, so preserving the count preserves optimality. (Same template, different currency: in
   weighted interval scheduling or MST the preserved quantity is value or total weight.)
5. **Conclusion of one step.** $O^*$ is feasible, has size $m$, and $O$ was optimal, so $O^*$ is
   optimal and agrees with $G$ on the first $r+1$ jobs.

![[10_Greedy.pdf#page=14]]
*Figure: the deck's "proof so far" slide — the inductive step boxed, and the instruction to repeat
with $O^*$ as the new optimal solution. (`10_Greedy.pdf` p. 14)*

*Repeat.* Each round starts from an optimal solution $O^*$ that agrees with $G$ on one more index,
so a legitimate guess at the end of round $r$ is "agreement length $r+1$". Since $r$ strictly
increases and $r \le k$, the process terminates after at most $k$ rounds, with an optimal solution
that begins with $i_1,\dots,i_k$.

> [!warning] What slide 14 leaves implicit (the gap your instinct noticed)
> "Eventually $O$ becomes the same as greedy" needs $\lvert O \rvert = \lvert G \rvert$, and that is
> **precisely the claim being proved** — you cannot assume it. The iteration stalls legitimately at
> $r = k$ with $O^* = (i_1,\dots,i_k,\, j_{k+1},\dots,j_m)$ if $m > k$, and nothing so far is
> contradicted. So the exchange argument alone gives you *"an optimal solution that agrees with
> greedy exists"*, not optimality. The missing line is Part 2: $m > k$ would have left $j_{k+1}$
> compatible when greedy stopped. State Part 1 + Part 2 and the proof is airtight; state only the
> swap and it is circular.

**The whole argument on a small instance (my numbers).** Jobs 1=[0,2], 2=[0,3], 3=[2,5], 4=[3,6].
Greedy sorts by finish: 1 (2), 2 (3), 3 (5), 4 (6), and takes 1, then 3 (since $2 \ge 2$), skipping
2 ($0 < 2$) and 4 ($3 < 5$): $G = (1,3)$, $k = 2$. The maximum is indeed 2 (1 and 2 overlap; 3 and 4
overlap), so any optimum has size 2 — take the adversary's
$O = (2,4)$, i.e. $j_1 = 2$, $j_2 = 4$.

| round | $r$ | $f(i_{r+1}) \le f(j_{r+1})$? | swap | $O^*$ | feasible check | size |
|---|---|---|---|---|---|---|
| 1 | 0 | $f(1) = 2 \le f(2) = 3$ ✓ | $2 \to 1$ | $(1,4)$ | $s(1) = 0$ ok; $f(1) = 2 \le s(4) = 3$ ✓ | 2 |
| 2 | 1 | $f(3) = 5 \le f(4) = 6$ ✓ | $4 \to 3$ | $(1,3) = G$ | $s(3) = 2 \ge f(1) = 2$ ✓; nothing on the right | 2 |

After round 2 the agreement length is $k = 2 = \lvert G \rvert$, so $O^{**}$ *is* $G$ and the
process stops — here it never needs Part 2, because the instance happens to have $m = k$. On an
instance where $m > k$ were possible, Part 2 is what rules it out. The "stays ahead" claim on this
instance: $f(i_1) = 2 \le 3 = f(j_1)$ and $f(i_2) = 5 \le 6 = f(j_2)$ — greedy is ahead at every
step, which is the invariant in one line.

> [!important] The shape of every exchange argument in this course
> Find the first place the greedy solution and an optimal one disagree → show the greedy choice
> is **at least as good** on the same "resource" (here: finish time) → swap it in without
> losing feasibility or value → repeat. Sections 6, 7, 8 and [[lec_17_minimum_spanning_trees]]
> Section 3 are all this exact template, with a different resource. And in every one of them,
> the swap alone is not the proof: you also owe the closing count (obligation 6 in Section 1.4).

---

## 6. Fractional knapsack

**Define.** Items with weights $w_i$ and values $v_i$, capacity $W$. Two versions:

| Version | Choice | Greedy? |
|---|---|---|
| **0/1 knapsack** | $x_i \in \{0,1\}$ | **no** — needs the DP of [[lec_13_2d_dynamic_programming]] |
| **fractional knapsack** | $0 \le x_i \le 1$ | **yes**: sort by $v_i/w_i$, take as much as fits |

![[10_Greedy.pdf#page=15]]
*Figure: the same instance, optimal 0/1 versus optimal fractional — the fractional optimum fills
the slack with part of an item. (`10_Greedy.pdf` p. 15)*

```text
Sort items so that v_1/w_1 >= v_2/w_2 >= ... >= v_n/w_n
w <- W
for i <- 1 to n
    if w_i <= w then x_i <- 1;  w <- w - w_i
    else            x_i <- w / w_i;  return
return
```

**In plain words.** Three sacks of flour worth 60, 100 and 120, weighing 10, 20 and 30 kilos, and
you can carry 50 kilos. If flour can be poured, fill the car with the best-value sacks first and
top up with two-thirds of the last one: 240. If sacks must go whole, that top-up is impossible —
and the greedy order, which has already loaded the two smaller sacks, cannot undo the choice. That
is the whole difference between the two problems.

**Example (mine, traced — one instance, three answers).** Items $(v_i,w_i)$ = (60,10), (100,20),
(120,30); $W = 50$. Ratios: $6, 5, 4$.

| Strategy | takes | value |
|---|---|---|
| fractional greedy | all of 1, all of 2, $\tfrac{2}{3}$ of 3 | $60 + 100 + 80 = 240$ |
| 0/1 greedy (same order) | items 1, 2 — item 3 no longer fits | $160$ |
| 0/1 optimum | items 2, 3 (weight exactly 50) | $220$ |

So greedy-by-ratio is *optimal for fractional* and *off by 27% for 0/1*: the fractional solution
uses a resource (splitting) that 0/1 does not allow. Exhaustive search confirms 220 is the best
0/1 value.

**Proof (exchange argument), fully packed case.** Assume $\sum w_i \ge W$; otherwise every
solution takes everything and greedy is trivially optimal. Let $G = (x_1,\dots,x_k,0,\dots,0)$
with $x_i = 1$ for $i < k$ and $0 \le x_k \le 1$, and let $O = (y_1,\dots,y_n)$ be optimal. Both
use the same total weight $W$. Take the first index $i$ where they differ:

1. By the greedy rule (sorted by ratio), $x_i \ge y_i$.
2. Set $y_i \gets x_i$: this adds weight $(x_i - y_i)w_i$.
3. Remove that same weight from items $i+1,\dots,n$. Possible because the remaining weight
   available in those items is identical in the two solutions.
4. Value cannot decrease: every item removed has ratio $\le v_i/w_i$, so the value lost is at
   most the value gained.
5. $O$ was optimal, so its value cannot increase either ⇒ value is unchanged ⇒ $O$ is still an
   optimal solution, now agreeing with $G$ on index $i$.
6. Repeat; the first differing index increases, so $G$ is reached.

![[10_Greedy.pdf#page=18]]
*Figure: the exchange in the deck's notation, including the reason step 3 is always possible.
(`10_Greedy.pdf` p. 18)*

> [!warning] The same sort, two different problems
> "Sort by value per unit weight" solves the *fractional* problem. It does **not** solve 0/1 —
> the 160-versus-220 gap above is the proof. The deck's p. 16 says this in one line; it is the
> most commonly dropped mark on this topic.

---

## 7. Interval covering (exercise)

**Problem.** Intervals covering $[0,1]$ (all endpoints distinct); find a **minimum** subset that
still covers $[0,1]$.

**Rule.** Sweep from the left: at the current coverage point $x$, among intervals that start at
or before $x$, pick the one that extends furthest right; set $x$ to its right endpoint; repeat
until $x = 1$.

![[10_Greedy.pdf#page=19]]
*Figure: the problem, the greedy rule, the exchange proof and the $O(n\log n)$ target.
(`10_Greedy.pdf` p. 19)*

**In plain words.** A strip of pavement has to be covered, and each plank you own covers a
different stretch of it. Stand at the left end and, among planks starting at or before you, take
the one that reaches furthest right; then walk to its far end and repeat. Reaching less far is
always safe to refuse, because a longer plank covers everything the shorter one would have.

**Example (mine, traced).** Intervals: 1=[0,0.5], 2=[0,0.2], 3=[0.15,0.7], 4=[0.6,1].

| step | $x$ | candidate starts $\le x$ | furthest | new $x$ |
|---|---|---|---|---|
| 1 | 0 | 1, 2 | 1 (ends 0.5) | 0.5 |
| 2 | 0.5 | 3 | 3 (ends 0.7) | 0.7 |
| 3 | 0.7 | 4 | 4 (ends 1.0) | 1.0 |

Answer $\{1,3,4\}$, and 2 intervals are impossible: $\{1,4\}$ leaves the gap $(0.5,0.6)$ and
$\{3,4\}$ leaves $[0,0.15)$ uncovered.

**Why it is optimal.** Same exchange: at the first index where greedy and an optimal solution
differ, greedy's interval reaches strictly further right, so replacing the optimal one keeps the
cover valid.

---

## 8. Interval partitioning: the minimum number of classrooms

**Define.** Lectures with $[s_j, f_j]$; assign every lecture to a classroom so that no two in the
same room overlap. Minimise the number of classrooms.

![[10_Greedy.pdf#page=21]]
*Figure: the same 10 lectures scheduled in 4 rooms naively, and in 3 rooms optimally.
(`10_Greedy.pdf` p. 21)*

**Rule.** Sort by **start time** and put each lecture in any compatible room; open a new room
only when forced.

```text
Sort so that s_1 <= s_2 <= ... <= s_n
d <- 0
for j <- 1 to n
    if lecture j fits in some room k then assign it there
    else allocate room d+1; assign j there; d <- d+1
```

**In plain words.** Four classes and a set of rooms; a room becomes free again only when the class
in it finishes. Walk the timetable in order of *starting* (you cannot change when people turn up),
give each class any room that has just emptied, and open a new room only when none has. Two rooms
suffice here — and two is also the largest number of classes ever running at the same moment, so
nobody could have done better.

**Example (deck's counterexample instance, traced).** Lectures A=[1,3], B=[2,4], C=[4,5],
D=[3,6]. Sorted by start: A, B, D, C.

| step | lecture | rooms (last finish) | action |
|---|---|---|---|
| 1 | A=[1,3] | — | open room 1, finish 3 |
| 2 | B=[2,4] | r1: 3 > 2 | open room 2, finish 4 |
| 3 | D=[3,6] | r1: 3 ≤ 3 ✓ | put in room 1, finish 6 |
| 4 | C=[4,5] | r1: 6 > 4; r2: 4 ≤ 4 ✓ | put in room 2, finish 5 |

2 rooms, and the **depth** (maximum number of lectures simultaneously open) is also 2, so 2 is
optimal.

**Lower bound.** Any schedule needs at least **depth** rooms, because at the instant of maximum
overlap that many lectures are all running.

![[10_Greedy.pdf#page=24]]
*Figure: the depth of the instance is 3, so 3 rooms is optimal. (`10_Greedy.pdf` p. 24)*

**Proof that greedy meets the bound.** Greedy opens room $d$ only for a lecture $j$ that is
incompatible with all $d-1$ existing rooms. Since we process by start time, each of those
$d-1$ lectures starts no later than $s_j$ and finishes after $s_j$ — so at time $s_j$ there are
$d$ lectures open, i.e. depth $\ge d$. Hence greedy's $d$ equals the optimum.

**Running time.** Checking "some room is compatible" naively costs $O(n)$ per lecture ⇒ $O(n^2)$.
The observation that saves it: if $j$ does not fit in the room with the **earliest finish time**,
it fits in no room. So keep the rooms in a min-heap keyed by last-finish-time:

![[10_Greedy.pdf#page=27]]
*Figure: the heap accounting — $O(1)$ to read the minimum, $O(\log n)$ per extract/insert.
(`10_Greedy.pdf` p. 27)*

| step | cost |
|---|---|
| read min finish time and compare with $s_j$ | $O(1)$ |
| reuse that room (extract-min + insert with $f_j$) | $O(\log n)$ |
| open a new room (insert) | $O(\log n)$ |

Total $\Theta(n\log n)$ after sorting.

> [!tip] Two rules that look alike and are not
> Interval **scheduling** (maximise the number of jobs) sorts by **finish** time.
> Interval **partitioning** (minimise rooms) sorts by **start** time and uses a heap of finish
> times. Memorising "sort by finish" for both is the classic mix-up.

---

## 9. Interval partitioning sorted by finish time (the wrong sort)

**What the deck shows.** Sorting by **finish** time and assigning to an arbitrary free room is
**not** optimal. Instance: $(1,3), (2,4), (4,5), (3,6)$ — depth 2, so 2 rooms suffice.

| order | trace | rooms used |
|---|---|---|
| by finish, any free room | (1,3)→r1; (2,4)→r2; (4,5)→r1; (3,6)→**r3** | **3** |
| by finish, room with **latest** finish among free | (1,3)→r1; (2,4)→r2; (4,5)→r2 (latest free is 4); (3,6)→r1 | 2 |
| by start (Section 8) | A→r1; B→r2; D→r1; C→r2 | 2 |

![[10_Greedy.pdf#page=28]]
*Figure: the counterexample, the tie-breaking fix, and the open question of how to implement it in
$O(n\log n)$. (`10_Greedy.pdf` p. 28)*

So the fix is a **tie-breaking rule**: among free rooms, use the one with the latest finish time.
That version is always optimal, but — as the deck says — the proof is not easy, which is exactly
why the start-time version is the one that gets proved.

---

## 10. From fixed-length to prefix-free codes

**Motivate.** There are more than $10^6$ characters across all languages, so a fixed-length code
needs 21 bits; English needs about 7. Message: give common characters **short** codewords and
rare ones long ones.

**Problem.** With variable lengths, the decoder cannot see where a codeword ends.

**Define.** A code is **prefix(-free)** if no codeword is a prefix of another. Then decoding is
forced: repeatedly take the first codeword you can read, peel it off, and continue.

![[11_Huffman.pdf#page=4]]
*Figure: $C_1$ and $C_2$ are prefix codes; $C_3 = \{a=1,\;b=110,\;c=10,\;d=111\}$ is not, and
$1101111$ decodes both as `bad` and as `acad`. (`11_Huffman.pdf` p. 4)*

**In plain words.** If one character's code is the opening of another's, the decoder cannot tell
where a code ends. With `a` given the single bit 1 and `b` given 110, the string 1101111 reads
either as "b a d" or as "a c a d" — every bit arrived intact and the message is still lost.

**Example (verify the ambiguity).** Under $C_3$:
`110 1 111` $=$ `b a d`, while `1 10 1 111` $=$ `a c a d` — the same bit string, two messages.

![[11_Huffman.pdf#page=3]]
*Figure: UTF-8 is a prefix code for a second reason — the leading `10` in continuation bytes gives
**self-synchronisation**, so a decoder that jumps into the middle of a file resynchronises instead
of decoding garbage. (`11_Huffman.pdf` p. 3)*

**The theorem.** Every message encoded by a prefix-free code is uniquely decodable. *Proof idea:*
no codeword is a prefix of another, so the first codeword is always determined; induct on the
message length. (The converse is false — there are non-prefix uniquely decodable codes — which is
why the deck says "note".)

---

## 11. Prefix codes are binary trees

**Define.** Left edge $= 0$, right edge $= 1$; the codeword of a character is the root-to-leaf
label string, so **depth = codeword length**. Prefix-freeness holds automatically, because no
leaf lies on the path to another leaf.

![[11_Huffman.pdf#page=6]]
*Figure: the fixed-length and variable-length codes of the deck's table as two binary trees.
(`11_Huffman.pdf` p. 6)*

**Define (cost).** For leaves $a_1,\dots,a_n$ with frequencies $f(a_i)$ and depths $d(a_i)$,

$$B(T) = \sum_{i=1}^{n} f(a_i)\, d(a_i)$$

the **weighted external path length** — the total number of bits of the encoded file (weighted
by frequency).

**In plain words.** Six letters and a 100,000-character file. Three bits per letter, always, costs
300,000 bits. Give the commonest letter one bit and the two rarest four bits and the same file
costs 224,000 — a quarter of it saved, simply by noticing that `a` is everywhere and `f` is not.

**Example (the deck's numbers, checked).** Frequencies $a{=}45$, $b{=}13$, $c{=}12$, $d{=}16$,
$e{=}9$, $f{=}5$ (thousands):

| code | codewords | $B(T)$ | for 100,000 chars |
|---|---|---|---|
| fixed | 3 bits each | $(45+13+12+16+9+5)\cdot 3 = 300$ | 300,000 bits |
| variable | $a{=}0$, $b{=}101$, $c{=}100$, $d{=}111$, $e{=}1101$, $f{=}1100$ | $45\cdot1 + 40\cdot3 + 14\cdot4 = 224$ | 224,000 bits |

Check the middle term: $(13+12+16)\cdot 3 = 123$, and $45 + 123 + 56 = 224$. ✓

> [!important] The reduction that makes the lecture work
> **Minimum-cost prefix code = minimum-cost binary tree** with leaf weights $f(a_i)$. From here
> on, the problem is a tree problem, and greedy can be applied to trees.

---

## 12. Huffman's algorithm

**Idea.** The two rarest characters should be the *deepest* leaves, so make them siblings and
merge them into one super-character with the summed frequency; repeat $n-1$ times.

![[11_Huffman.pdf#page=11]]
*Figure: the algorithm — a min-priority queue, $n-1$ merges, $O(n\log n)$.
(`11_Huffman.pdf` p. 11)*

```text
Huffman(A):
    create a min-priority queue Q on A, keyed by frequency
    for i <- 1 to n-1
        allocate a new node z
        x <- Extract-Min(Q);  y <- Extract-Min(Q)
        z.left <- x;  z.right <- y
        z.weight <- x.weight + y.weight
        Insert(Q, z)
    return Extract-Min(Q)        // the root
```

**In plain words.** Tie the two rarest letters together, call the pair a new letter, and add their
frequencies; repeat until one letter is left. Rarity buys depth, depth costs bits, so the letters
nobody uses end up at the bottom of the tree where long codes live — which is exactly where they
are cheapest to leave them.

**In plain words (the smallest possible run).** Four letters, one of them everywhere and two of
them nearly absent. Glue the two absent ones together so they share one long name, then treat that
pair as a single new letter that appears twice as often, and glue it to the next rarest. The
letter everybody uses is the last one left, so it gets the shortest name of all — and a name that
is one bit long is worth a lot when it appears four times out of eight.

**Example (four letters — the smallest complete run).** Frequencies $a{:}4$, $b{:}2$,
$c{:}1$, $d{:}1$ (8 characters in total). Merge the two smallest, insert the sum, repeat:

| merge | the two smallest in the queue | new node | queue afterwards |
|---|---|---|---|
| 1 | $c{:}1$, $d{:}1$ | $cd{:}2$ | $a{:}4,\ b{:}2,\ cd{:}2$ |
| 2 | $b{:}2$, $cd{:}2$ | $bcd{:}4$ | $a{:}4,\ bcd{:}4$ |
| 3 | $a{:}4$, $bcd{:}4$ | $abcd{:}8$ (root) | — |

Read the codes off the tree (left = 0, right = 1): $a{=}0$, $b{=}10$, $c{=}110$, $d{=}111$ —
depths 1, 2, 3, 3, and $a$ is the shallowest because it is the most frequent.

**Encode and decode a real string.** `abacadab` has exactly those frequencies:

| letter | code | bits |
|---|---|---|
| a | `0` | 0 |
| b | `10` | 10 |
| a | `0` | 0 |
| c | `110` | 110 |
| a | `0` | 0 |
| d | `111` | 111 |
| a | `0` | 0 |
| b | `10` | 10 |

So `abacadab` $\to$ `01001100111010`, **14 bits**. A fixed two-bit code would have used
$2 \cdot 8 = 16$. Decoding needs no separators: read bits until they match a codeword
(`0` $\to$ a, `10` $\to$ b, `110` $\to$ c, `111` $\to$ d), emit it, continue — that is
prefix-freeness doing its job.

**Two checks anyone can do by hand.** (1) $B(T) = 4\cdot1 + 2\cdot2 + 1\cdot3 + 1\cdot3 = 14$, and
equally the **sum of all merged weights** $2 + 4 + 8 = 14$ — the same number by two routes, which
is a good sign you built the tree correctly. (2) Exhaustive search over every full tree on four
leaves confirms 14 is the minimum; the only competing shape (depths 2,2,2,2, i.e. the fixed-length
code) costs 16.

**The deck's own instance, same machine.** Six letters instead of four, and the gluing happens in
an order you would not guess: the rarest two go together first, but then a *sum* outranks a real
letter, so the tree grows lopsided — one letter ends up one bit from the root and two end up four
bits away.

**In plain words.** Six letters, with `a` appearing almost as often as the other five put together.
Glue the two rarest, then keep gluing whatever is now smallest — including the glued pairs, which
compete with the real letters on equal terms. The result is a tree where the only common letter
sits next to the root and the two rarest sit at the bottom, four bits from it.

**Example (deck's instance, traced).** $f{:}5,\ e{:}9,\ c{:}12,\ b{:}13,\ d{:}16,\ a{:}45$.

| merge | operands | new node |
|---|---|---|
| 1 | $f{=}5$, $e{=}9$ | $14$ |
| 2 | $c{=}12$, $b{=}13$ | $25$ |
| 3 | $14$, $d{=}16$ | $30$ |
| 4 | $25$, $30$ | $55$ |
| 5 | $a{=}45$, $55$ | $100$ (root) |

Codewords read off the tree: $a{=}0$, $c{=}100$, $b{=}101$, $d{=}111$, $f{=}1100$,
$e{=}1101$ — cost $224$, matching Section 11. Note the merge order is forced at every step by
"two smallest in the queue": after step 2 the queue is $\{14, 16, 25, 45\}$, so step 3 must merge
$14$ with $16$.

![[11_Huffman.pdf#page=10]]
*Figure: all six frames of the build, ending with the codewords written under the leaves.
(`11_Huffman.pdf` p. 10)*

**Cost.** $n-1$ iterations, each with two extracts and one insert on a heap of size $\le n$:
$O(n\log n)$. With the frequencies sorted first, a two-queue version runs in $\Theta(n\log n)$
for the sort and $\Theta(n)$ afterwards.

---

## 13. Why Huffman is optimal

Four lemmas, then induction. Every one of them is an exchange or a counting identity on
$B(T) = \sum f(a_i)d(a_i)$.

**Lemma 1 (optimal trees are full).** Every internal node of an optimal tree has exactly two
children. *Proof:* replacing a one-child internal node by its child leaves every leaf at no
greater depth and some strictly shallower, so the cost drops.

![[11_Huffman.pdf#page=12]]
*Figure: the one-child node and its removal. (`11_Huffman.pdf` p. 12)*

**Lemma 2 (swap two leaves).** If $f(x) \le f(b)$ and $d(x) \le d(b)$, swapping leaves $x$ and
$b$ does not increase the cost:

$$B(T') = B(T) + \bigl(f(x) - f(b)\bigr)\bigl(d(b) - d(x)\bigr) \le B(T)$$

because the first factor is $\le 0$ and the second $\ge 0$. Reading it operationally: **a rarer
character may always be pushed deeper**.

![[11_Huffman.pdf#page=14]]
*Figure: the algebra of Lemma 2 with the sign of each factor marked. (`11_Huffman.pdf` p. 14)*

**Lemma 3 (the two rarest can be deepest siblings).** Let $x,y$ have the two smallest
frequencies. Some optimal tree has $x,y$ as sibling leaves at maximum depth. *Proof:* a full tree
has two deepest siblings $b,c$; swap $x$ with $b$ and $y$ with $c$; by Lemma 2 the cost cannot
increase, and since the tree was optimal it stays optimal.

![[11_Huffman.pdf#page=15]]
*Figure: the two swaps of Lemma 3. (`11_Huffman.pdf` p. 15)*

**Lemma 4 (merge identity).** If $T'$ is obtained from $T$ by deleting sibling leaves $x,y$ and
naming their parent $z$ with $f(z) = f(x)+f(y)$, then

$$B(T) = B(T') + f(x) + f(y)$$

*Proof:* in $T$ the two leaves are one level deeper than $z$ was, so
$B(T) = B(T') - f(z)d(z) + (f(x)+f(y))(d(z)+1) = B(T') + f(x) + f(y)$.

![[11_Huffman.pdf#page=16]]
*Figure: Lemma 4 as a diagram. (`11_Huffman.pdf` p. 16)*

**Theorem (induction on $n$).** Huffman's tree $H$ for alphabet $A$ is optimal.

- **Base case** $n = 2$: the only full tree with two leaves is optimal.
- **Inductive step.** Let $x,y$ be Huffman's first merge and $z$ their parent, and let
  $A' = A - \{x,y\} \cup \{z\}$ with $H'$ the tree Huffman builds for $A'$ (deleting $x,y$ from
  $H$ literally gives $H'$ — the deck's observation on p. 17).
  - By induction, $H'$ is optimal for $A'$.
  - By Lemma 3, some optimal tree $T$ for $A$ has $x,y$ as siblings; shrink it to $T'$ for $A'$.
  - Lemma 4 applied twice:
    $B(H) = B(H') + f(x) + f(y) \le B(T') + f(x) + f(y) = B(T)$.
  - So $B(H) \le B(T)$ for an optimal $T$: $H$ is optimal.

> [!important] Where each lemma is used
> Lemma 1 (full tree) ⇒ a deepest pair of siblings exists. Lemma 2 ⇒ cheap characters may go
> deep, which lets Lemma 3 move the two rarest down. Lemma 3 ⇒ Huffman's *first* merge can be
> assumed in an optimal tree. Lemma 4 ⇒ the merged instance's cost differs by exactly
> $f(x)+f(y)$, so optimality transfers between $A$ and $A'$.

---

## 14. Optimal 2-way merge

**Problem.** Merge $n$ sorted lists, two at a time. Merging sizes $a$ and $b$ costs $a+b$
comparisons; minimise the total.

**In plain words.** Merging two piles of 30 and 20 costs fifty comparisons, and the merged pile is
now bigger, so every later merge that touches it costs more. Merge the two smallest piles first
and the big pile is only paid for once, at the very end. Merging the big pile first means paying
for it twice — 110 instead of 90.

**Example (deck's, checked).** Sizes 30, 20, 10:

| merge order | costs | total |
|---|---|---|
| $(30+20)$ then $+10$ | $50$, then $60$ | 110 |
| $(30+10)$ then $+20$ | $40$, then $60$ | 100 |
| $(20+10)$ then $+30$ | $30$, then $60$ | **90** |

![[11_Huffman.pdf#page=22]]
*Figure: the two merge trees — the cheaper one puts the largest list at the *shallowest* depth.
(`11_Huffman.pdf` p. 22)*

**The identity.** A merge tree's weighted external path length is exactly the total comparison
count (each element is compared once per merge it takes part in), so **this is Huffman with list
sizes as weights**: repeatedly merge the two smallest, $O(n\log n)$.

**In plain words.** Same lesson on five piles: keep gluing together the two smallest, so nothing
big is ever handled more than once. The total 57 is just each pile's size multiplied by the number
of times it got merged.

**Example (deck's, checked).** Sizes 2, 3, 5, 7, 9: merge $2+3=5$ (cost 5), then $5+5=10$
(cost 10), then $7+9=16$ (cost 16), then $10+16=26$ (cost 26); total
$5+10+16+26 = 57$, which equals $2\cdot3 + 3\cdot3 + 5\cdot2 + 7\cdot2 + 9\cdot2 = 57$. ✓

![[11_Huffman.pdf#page=24]]
*Figure: the four iterations and the cost computation for 2, 3, 5, 7, 9. (`11_Huffman.pdf` p. 24)*

> [!tip] One algorithm, two disguises
> Huffman coding and optimal 2-way merge are the *same* algorithm on the same objective. If an
> exam asks for one, you already have the other — only the story around the weights changes.

---

## 15. Highlights

*(Neither deck has a summary slide; this is the distilled version of both.)*

- Greedy = feasible + locally optimal + irrevocable, usually with a sort or a heap, so
  $\Theta(n\log n)$. Optimality is never obvious and must be proved.
- Counterexamples are cheap and decisive: change-making (British coinage, $n=48$), max
  non-adjacent sum ($(1,4,6,4)$), and all three "obvious" interval-scheduling rules.
- Exchange argument: first disagreement → greedy is at least as good on the resource → swap →
  repeat. Used for interval scheduling (finish time), fractional knapsack (value/weight),
  interval covering (right endpoint), interval partitioning (a lower bound instead), and MST.
- The right rules: interval **scheduling** → sort by finish; interval **partitioning** → sort by
  start + min-heap of finish times (or sort by finish with a latest-finish tie-break); fractional
  knapsack → sort by value per weight; Huffman → repeatedly merge the two smallest.
- Fractional and 0/1 knapsack differ by whether splitting is allowed; greedy solves only the
  fractional one.
- Prefix codes are binary trees; cost = weighted external path length. Huffman builds the
  optimal tree by merging the two rarest characters, proved optimal by a full-tree lemma, a swap
  lemma, a deepest-siblings lemma, a merge identity, and induction.
- Optimal 2-way merge is Huffman in disguise.

## 16. Exam traps

- **"Greedy is optimal for coin change"** → only for canonical systems. $\{1,3,6,12,24,30,60\}$
  with $n=48$: greedy 3 coins, optimum 2.
- **Greedy for 0/1 knapsack** → wrong. Items (60,10), (100,20), (120,30), $W=50$: greedy by
  ratio gives 160, the optimum is 220, while the *fractional* optimum is 240.
- **Taking "largest element" for max non-adjacent sum** → $(1,4,6,4)$ gives 7 versus 8.
- **Sorting interval scheduling by start time** → wrong; sort by **finish** time. Sorting
  partitioning by finish time (without the latest-finish tie-break) is also wrong; sort by
  **start** time.
- **Touching intervals treated as overlapping** → $f_i \le s_j$ is **compatible**. Getting this
  backwards changes every trace by one job.
- **Interval scheduling proof "greedy obviously leaves more room"** → that is intuition, not a
  proof; the marks are for the exchange argument (first disagreement, swap, same size).
- **Interval partitioning: proving optimality from the algorithm instead of a lower bound** → the
  proof needs *depth* as a lower bound plus "greedy's $d$ equals depth".
- **Interval partitioning in $O(n^2)$** → acceptable if you say so, but the intended answer is
  the min-heap of finish times, $\Theta(n\log n)$. The key observation is that only the room
  with the **earliest** finish time needs checking.
- **Interval covering: picking the longest interval** → the rule is "the interval that extends
  coverage *furthest right* from the current point", not the globally longest one.
- **Prefix-free confused with uniquely decodable** → prefix-free ⇒ uniquely decodable, not the
  converse. $C_3$ in Section 10 is neither; a non-prefix uniquely decodable code exists and is
  outside this lecture.
- **Huffman merging more than two, or merging the two largest** → exactly two, and always the
  two **smallest**; the queue must be a min-priority queue.
- **Huffman: using codeword *count* to compare codes** → compare the weighted cost
  $\sum f(a_i)d(a_i)$; a code with more long codewords can still be cheaper.
- **Recovering codewords without fixing the left/right convention** → left $= 0$, right $= 1$;
  swapping them gives a different but equally optimal code, so state your convention.
- **Lemma 2 applied with the inequality backwards** → it says a *rarer* character may be moved
  *deeper*, i.e. $f(x) \le f(b)$ and $d(x) \le d(b)$; for the swap to be free you need both
  inequalities, and the depth inequality is what Lemma 3 provides.
- **2-way merge solved by "merge the largest two first"** → it is merge the **smallest** two;
  30, 20, 10 gives 90, not 110.
