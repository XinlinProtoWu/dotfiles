# COMP 3711 – HW1 Solutions

Notation follows the lecture notes: $\log_2$ is the base-2 logarithm, and
plain $\log$ is used inside asymptotic bounds (where the base does not matter).

---

## Question 1 — Asymptotic relations

| $A$                                       | $B$                     | Relation            |
| ----------------------------------------- | ----------------------- | ------------------- |
| $n^{\log_2 \log_2 n}$                     | $(\log_2 n)^{\log_2 n}$ | **$A = \Theta(B)$** |
| $2^{\sqrt{2 \log_2 n}}$                   | $\sqrt{n}$              | **$A = O(B)$**      |
| $n!$                                      | $n^{n/2}$               | **$A = \Omega(B)$** |
| $4^{\sqrt{n}}$                            | $2^{n}$                 | **$A = O(B)$**      |
| $\displaystyle\sum_{i=1}^{n} \frac{1}{i}$ | $n \log n$              | **$A = O(B)$**      |

Reasoning:

1. Take $\log_2$ of both sides:
   $$\log_2 A = (\log_2 n)(\log_2 \log_2 n), \qquad \log_2 B = (\log_2 n)(\log_2 \log_2 n)$$
   so $A = B$ exactly, hence **$A = \Theta(B)$**.

2. Write $B = 2^{\frac{1}{2}\log_2 n}$. Compare the exponents:
   $\sqrt{2\log_2 n} = o\!\left(\tfrac{1}{2}\log_2 n\right)$, so $A = o(B)$, i.e. **$A = O(B)$**.

3. By Stirling's approximation $\log(n!) = n\log n - n + \Theta(\log n)$, while
   $\log(n^{n/2}) = \frac{n}{2}\log n$. Both are $\Theta(n\log n)$, but their
   difference grows without bound:
   $$\log(n!) - \log\!\left(n^{n/2}\right) = \frac{n}{2}\log n - n + \Theta(\log n) \to \infty$$
   so $\dfrac{n!}{n^{n/2}} \to \infty$, i.e. $n! = \omega(n^{n/2})$. Hence
   **$A = \Omega(B)$** (in fact $A = \omega(B)$, so $A \neq O(B)$).

4. $4^{\sqrt{n}} = 2^{2\sqrt{n}} = o(2^n)$, so **$A = O(B)$**.

5. $\displaystyle\sum_{i=1}^{n}\frac{1}{i} = H_n = \Theta(\log n) = o(n\log n)$, so **$A = O(B)$**.

---

## Question 2 — Recurrences (no Master theorem)

### (a) $T(1)=1$, $T(n)=2T(n/2)+\sqrt{n}$, $n = 2^k$

Repeated expansion:

$$T(n) = 2T(n/2) + \sqrt{n}$$
$$= 2\Big[2T(n/4) + \sqrt{n/2}\Big] + \sqrt{n}$$
$$= 4T(n/4) + 2\sqrt{n/2} + \sqrt{n}$$
$$= 4T(n/4) + \sqrt{n}\left(\sqrt{2} + 1\right)$$

After $i$ expansions:

$$T(n) = 2^{i}\,T\!\left(\frac{n}{2^{i}}\right) + \sqrt{n}\sum_{j=0}^{i-1}(\sqrt{2})^{j}
= 2^{i}\,T\!\left(\frac{n}{2^{i}}\right) + \sqrt{n}\cdot\frac{(\sqrt{2})^{i}-1}{\sqrt{2}-1}$$

Set $i = k = \log_2 n$ so that $n/2^{i} = 1$:

$$T(n) = 2^{k}\,T(1) + \sqrt{n}\cdot\frac{(\sqrt{2})^{k}-1}{\sqrt{2}-1}
= n + \sqrt{n}\cdot\frac{\sqrt{n}-1}{\sqrt{2}-1}
= \Theta(n)$$

**Answer: $T(n) = \Theta(n)$.**

---

### (b) $T(1)=1$, $T(n)=3T(n/5)+2n$, $n = 5^k$

Repeated expansion:

$$T(n) = 3T(n/5) + 2n$$
$$= 9T(n/25) + \frac{6n}{5} + 2n$$
$$= 9T(n/25) + 2n\left(1 + \frac{3}{5}\right)$$

After $i$ expansions:

$$T(n) = 3^{i}\,T\!\left(\frac{n}{5^{i}}\right) + 2n\sum_{j=0}^{i-1}\left(\frac{3}{5}\right)^{j}$$

Set $i = k = \log_5 n$ so that $n/5^{i} = 1$:

$$T(n) = 3^{k}\,T(1) + 2n\cdot\frac{1 - (3/5)^{k}}{1 - 3/5}
= 3^{k} + 5n\left(1 - (3/5)^{k}\right)$$

Now $3^{k} = 3^{\log_5 n} = n^{\log_5 3}$. Since $\log_5 3 < 1$, the term
$n^{\log_5 3} = o(n)$. Also $(3/5)^{k} \to 0$ as $k \to \infty$. Therefore

$$T(n) = n^{\log_5 3} + 5n\,(1 - o(1)) = \Theta(n)$$

**Answer: $T(n) = \Theta(n)$.**

---

### (c) $T(2)=1$, $T(n)=T(\sqrt{n})+\log n$ for $n > 2$

Substitute $n = 2^{m}$ (so $m = \log_2 n$) and let $S(m) = T(2^{m})$.
Then $\sqrt{n} = 2^{m/2}$, so $T(\sqrt{n}) = T(2^{m/2}) = S(m/2)$, and
$\log n = \log_2(2^{m}) = m$ (here $\log = \log_2$, matching the lecture
convention). Hence

$$S(m) = S(m/2) + m, \qquad S(1) = T(2) = 1$$

(The base case is at $n = 2 = 2^{1}$, i.e. $m = 1$. Even if the original
$\log$ had some other base $b$, we would get $\log_b n = m\log_b 2 = \Theta(m)$,
so the final answer $\Theta(\log n)$ is unchanged.)

Expand:

$$S(m) = S(m/2) + m$$
$$= S(m/4) + \frac{m}{2} + m$$
$$= S(m/8) + \frac{m}{4} + \frac{m}{2} + m$$
$$\vdots$$
$$= S(1) + m\left(1 + \frac{1}{2} + \frac{1}{4} + \cdots + \frac{1}{2^{i-1}}\right),
\quad \text{where } \frac{m}{2^{i}} = 1,\ i = \log_2 m$$

The geometric sum is
$$\sum_{j=0}^{i-1}\left(\frac12\right)^{j} = \frac{1 - (1/2)^{i}}{1 - 1/2} = 2\left(1 - 2^{-i}\right) = 2 - 2^{-i+1}$$
and with $i = \log_2 m$ we have $2^{-i} = 1/m$, so the sum is $2 - \frac{2}{m}$. Therefore

$$S(m) = 1 + m\left(2 - \frac{2}{m}\right) = 2m - 1 = \Theta(m)$$

Back-substituting $m = \log_2 n$:

**Answer: $T(n) = \Theta(\log n)$.**

> **Alternative (if the original `log` were base 10):**
> Let $c = \log_{10} 2 \approx 0.301$. Keeping the same substitution
> $n = 2^{m}$, $S(m) = T(2^{m})$, we now get
> $$\log_{10} n = \log_{10}(2^{m}) = m\log_{10} 2 = c\,m$$
> so
> $$S(m) = S(m/2) + c\,m, \qquad S(1) = T(2) = 1$$
> Expanding as before gives
> $$S(m) = 1 + c\,m\left(1 + \frac{1}{2} + \cdots + \frac{1}{2^{i-1}}\right),
> \quad i = \log_2 m$$
> $$= 1 + 2c\,m\left(1 - \frac{1}{m}\right) = 2c\,m + (1 - 2c) = \Theta(m)$$
> Back-substituting $m = \log_2 n$:
> $$T(n) = 2c\,\log_2 n + O(1) = 2\log_{10} 2\cdot\log_2 n + O(1) = 2\log_{10} n + O(1) = \Theta(\log_{10} n)$$
> which is the **same** $\Theta(\log n)$ answer — only the constant $2\log_{10} 2$
> appears instead of $2$. The base of the logarithm never changes the
> asymptotic result.

---

### (d) $T(1)=1$, $T(n)=T(\alpha n)+T(\beta n)+O(n)$, $\alpha,\beta>0$, $\alpha+\beta=1$

Use induction. Guess **$T(n) = O(n \log n)$**, i.e. show $T(n) \le c\,n\log n$.

Let the $O(n)$ term be at most $Cn$. Inductively assume
$T(k) \le c\,k\log k$ for all $k < n$. Then

$$T(n) \le c\,\alpha n \log(\alpha n) + c\,\beta n \log(\beta n) + Cn$$
$$= c\,\alpha n\,(\log n + \log \alpha) + c\,\beta n\,(\log n + \log \beta) + Cn$$
$$= c(\alpha+\beta)\,n\log n + c\,n\,(\alpha \log \alpha + \beta \log \beta) + Cn$$
$$= c\,n\log n + n\Big[c(\alpha \log \alpha + \beta \log \beta) + C\Big]$$

Since $0 < \alpha, \beta < 1$, both $\log \alpha < 0$ and $\log \beta < 0$, hence
$\alpha \log \alpha + \beta \log \beta < 0$. Choose

$$c \ge \frac{C}{-(\alpha \log \alpha + \beta \log \beta)}$$

so the bracket is $\le 0$. Then $T(n) \le c\,n\log n$. (Enlarge $c$ to handle base cases.)

**Answer: $T(n) = O(n \log n)$.**

---

### (e) $T(1)=1$, $T(n)=T(\alpha n)+T(\beta n)+O(n)$, $\alpha,\beta>0$, $\alpha+\beta<1$

Use induction. Guess **$T(n) = O(n)$**, i.e. $T(n) \le c\,n$.

Let the $O(n)$ term be at most $Cn$. Assume $T(k) \le c\,k$ for $k < n$. Then

$$T(n) \le c\,\alpha n + c\,\beta n + Cn = c(\alpha+\beta)\,n + Cn = n\Big[c(\alpha+\beta) + C\Big]$$

Choose $c \ge \dfrac{C}{1 - (\alpha+\beta)}$ (note $1 - (\alpha+\beta) > 0$). Then $T(n) \le c\,n$.

**Answer: $T(n) = O(n)$.**

---

## Question 3 — $k$-near-sorted array

Definition: $A$ is $k$-near-sorted if removing some $k$ elements leaves a
non-decreasing array.

### (a) $O(n)$ algorithm returning $R$ with $|R| \le 2k$

**Algorithm (stack):**

```
RemoveSmall(A[1..n]):
    R = ∅                       // indices to remove
    S = empty stack             // stores indices of KEPT elements

    for i = 1 to n:
        if S is empty or A[S.top] ≤ A[i]:
            S.push(i)           // keep i; stack stays non-decreasing
        else:
            j = S.pop()         // A[j] > A[i]: one inversion
            R = R ∪ {j, i}      // remove BOTH endpoints of this inversion

    return R                    // kept elements = contents of S
```

**Correctness (2–3 lines):**
At all times $S$ is non-decreasing from bottom to top (we only push when
$A[i] \ge A[S.top]$). Hence the elements left in $S$ are sorted, so deleting
$R$ gives a sorted subarray. Moreover each time we remove two indices
$\{j, i\}$ they form an inversion $A[j] > A[i]$ with $j < i$; these removed
pairs are disjoint, so $R$ is the set of endpoints of a *matching* of
inversions.

**Why $|R| \le 2k$:**
The removed pairs form a maximal matching $M$ of inversions: after the loop,
any two remaining (unmatched) indices $u < v$ satisfy $A[u] \le A[v]$, so no
two unmatched elements form an inversion, i.e. no further disjoint inversion
pair can be added. Any valid deletion set (in particular the size-$k$ set
promised by the problem) must delete at least one endpoint of every matched
pair, and the pairs are disjoint, so $k \ge |M|$. Therefore

$$|R| = 2\,|M| \le 2k.$$

**Time:** $O(n)$ — each index is pushed at most once and popped at most once.

---

### (b) Sort the array in $O(n + k \log k)$ using (a) as a black box

**Algorithm:**

```
SortNearSorted(A[1..n]):
    R = RemoveSmall(A)             // |R| ≤ 2k; A\R (in order) is sorted
    K = A with indices in R deleted      // sorted list, length n - |R|
    B = [ A[i] : i in R ]                // removed values, length |R| ≤ 2k
    sort B                               // O(|R| log |R|) = O(k log k)
    return Merge(K, B)                   // O(n), K and B both sorted
```

**Correctness:** $K$ and $B$ together contain exactly the elements of $A$, and
both are sorted, so merging them gives $A$ fully sorted.

**Time:**
- Step 1: $O(n)$ by part (a).
- Step 3: $O(|R| \log |R|) = O(k \log k)$ since $|R| \le 2k$.
- Step 4: $O(n)$.

Total: **$O(n + k \log k)$.**

---

## Question 4 — Detecting candidates with $> n/3$ votes (only `equals()`)

### (a) At most two winners

Suppose three candidates $x, y, z$ each received more than $n/3$ votes. Their
vote counts are disjoint and add up to more than $3\cdot(n/3) = n$ votes,
impossible since there are only $n$ votes. Hence at most two candidates can
exceed $n/3$.

### (b) Divide-and-conquer algorithm

```
FindWinners(V[1..n]):                 // returns a set of candidates (≤ 2)
    if n == 1:
        return { V[1] }
    if n == 2:
        if equals(V[1], V[2]): return { V[1] }
        else: return {}

    m = floor(n/2)
    C1 = FindWinners(V[1..m])
    C2 = FindWinners(V[m+1..n])
    C = C1 ∪ C2                        // deduplicate using equals(); |C| ≤ 4

    winners = {}
    for each c in C:
        count = 0
        for i = 1 to n:
            if equals(V[i], c): count = count + 1
        if count > n/3:
            winners = winners ∪ { c }
    return winners

Main:
    W = FindWinners(V)
    if W is empty: output "Red Bird for Exco!"
    else: output W
```

**Correctness:**
- Lemma: if $x$ has more than $n/3$ votes overall, then $x$ has more than
  $m/3$ votes in the first half or more than $(n-m)/3$ in the second half.
  Otherwise its total would be at most $\tfrac{m}{3} + \tfrac{n-m}{3} = \tfrac{n}{3}$,
  a contradiction.
- Therefore every global winner appears in $C_1 \cup C_2 = C$, and the final
  counting step identifies it (count $> n/3$).
- Conversely, any candidate output passes the count $> n/3$ check.
- $|C_1|, |C_2| \le 2$ by part (a), so $|C| \le 4$ and counting is $O(n)$.

**Time:** $T(n) = 2T(n/2) + O(n)$. By the Master theorem
($a = b = 2$, $f(n) = O(n)$, case 2): **$T(n) = \Theta(n \log n)$.**

---

## Question 5 — Making a point set stable

A set is stable if every pair $(a,b)$ either shares an $x$-coordinate, shares
a $y$-coordinate, or has a third point inside their axis-aligned rectangle.

### Algorithm (divide and conquer)

```
Stabilize(P):                        // P: points with distinct x and distinct y
    if |P| ≤ 1: return P
    sort P by x
    split P into L (left half) and R (right half)
    x* = (max x in L + min x in R) / 2     // strictly between the two halves

    S_L = Stabilize(L)
    S_R = Stabilize(R)

    // cross-stabilizer: vertical line at x*, one point per original y in P
    M = { (x*, y_p) : p ∈ P }

    return S_L ∪ S_R ∪ M
```

### Correctness

**Claim:** $\mathrm{Stabilize}(P)$ is stable, for every point set $P$.

Proof by induction on $m = |P|$.

- **Base $m \le 1$:** trivially stable.

- **Step:** let $S_L = \mathrm{Stabilize}(L)$, $S_R = \mathrm{Stabilize}(R)$,
  $M = \{(x^{*}, y_p) : p \in P\}$, and $S = S_L \cup S_R \cup M$. By induction
  $S_L, S_R$ are stable. Note every point in $S$ has a $y$-coordinate equal to
  the $y$-coordinate of some original point of $P$ (added points copy original
  $y$'s). Consider any two points $a \neq b$ in $S$:

  - **Both in $S_L$ (or both in $S_R$):** stable by induction (witness lies in $S$).
  - **Both in $M$:** they share the $x$-coordinate $x^{*}$.
  - **$a \in M$, $b \in S_L$ ($b \in S_R$ symmetric):** $x_b < x^{*}$
    (or $x_b > x^{*}$). If $y_a = y_b$ we are done. Otherwise let
    $c = (x^{*}, y_b)$. Since $b$'s $y$-coordinate is some original $y$ of $P$,
    $c \in M$. Then $x^{*}$ lies between $x_a$ and $x_b$, and
    $y_c = y_b \in \big[\min(y_a, y_b),\ \max(y_a, y_b)\big]$, and $c$ is
    distinct from both $a$ and $b$. So $c$ is a valid witness.
  - **$a \in S_L$, $b \in S_R$:** then $x_a < x^{*} < x_b$. Let
    $c = (x^{*}, y_a) \in M$ ($y_a$ is an original $y$ of $L$). Then $c$ lies
    inside the rectangle spanned by $a$ and $b$ and is distinct from both, so
    $c$ is a valid witness.

So $S$ is stable. $\blacksquare$

**Distinctness:** original $x$'s are distinct; every $x^{*}$ is chosen strictly
between the two halves of its node, so all added $x$'s are distinct and also
distinct from all original $x$'s. Points added on the same line have distinct
$y$'s (copied from distinct original $y$'s). Hence no two points coincide.

### Running time and number of added points

Let $A(m)$ be the number of added points for a subproblem of size $m$.

$$A(m) = A\!\left(\left\lfloor \frac{m}{2}\right\rfloor\right) + A\!\left(\left\lceil \frac{m}{2}\right\rceil\right) + m, \qquad A(1) = 0$$

By the Master theorem this solves to **$A(m) = O(m \log m)$**, so total added
points = **$O(n \log n)$**.

The running time satisfies $T(n) = 2T(n/2) + O(n)$ plus one initial sort, so

**$T(n) = O(n \log n)$.**
