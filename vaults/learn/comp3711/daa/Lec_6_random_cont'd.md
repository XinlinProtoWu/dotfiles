# Random Permutations (Lecture 06 — Random, cont'd)

## Recap: Expectation
- Expectation: multiply each possible value by its probability, then add them up.
- Just like in Genshin dmg calcs: `crit rate * dmg after crit + (1 - cr) * dmg with no crit`.

## Note about ${}\binom{n}{k}{}$
- Use this when the question asks to choose *combinations* of *k* items out of *n* total items and *order does not matter*.
- ${}\binom{n}{k} = \frac{n!}{k!(n-k)!}{}$ = number of combinations possible.

## Random Permutation

**Goal:** generate a *uniformly random* permutation — every one of the ${}n!{}$ orderings equally likely, each with probability ${}\frac{1}{n!}{}$.

### Algorithm (Fisher–Yates / Knuth shuffle)
```
RandomPermute(A):
    n ← A.length
    for i ← 1 to n
        swap A[i] with A[Random(1, i)]   # uniform integer in [1, i]
```
- ${}O(n){}$ time, ${}O(1){}$ extra space.
- At step ${}i{}$, position ${}i{}$ is **finalized**: it's swapped with a uniformly random position among the first ${}i{}$, so each of the first ${}i{}$ elements is equally likely to land at position ${}i{}$.

### Correctness (proof by induction)
**Claim:** after the ${}i{}$-th iteration, every permutation of ${}A[1..i]{}$ has probability ${}\frac{1}{i!}{}$.

- **Base case ${}i = 1{}$:** one element → one permutation → probability 1. Trivial.
- **Inductive step:** consider any target permutation ${}(a_1, \dots, a_i){}$ of ${}A[1..i]{}$.
  - Let ${}j{}$ be the position where the *original* ${}A[i]{}$ ends up, i.e. ${}a_j = A[i]{}$.
  - Final state ${}(a_1,\dots,a_i){}$ happens **iff** two independent events both occur:
    1. After step ${}i-1{}$, positions ${}1..i-1{}$ hold ${}(a_1,\dots,a_{j-1}, a_i, a_{j+1},\dots,a_{i-1}){}$ — the value ${}a_i{}$ is temporarily parked at position ${}j{}$. By induction: probability ${}\frac{1}{(i-1)!}{}$.
    2. The random choice is ${}Random(1,i) = j{}$: probability ${}\frac{1}{i}{}$.
  - Multiply: ${}\Pr[A[1..i] = (a_1,\dots,a_i)] = \frac{1}{(i-1)!}\cdot\frac{1}{i} = \frac{1}{i!}{}$. ∎
- **Special case ${}j = i{}$:** swap ${}A[i]{}$ with itself (no-op). Still holds.

### Intuition (bijection argument)
The algorithm picks ${}j_1\in[1,1],\, j_2\in[1,2],\,\dots,\, j_n\in[1,n]{}$. There are exactly
$$1 \cdot 2 \cdots n = n!$$
equally likely *choice sequences*. There is a **bijection** between choice sequences and final permutations (each sequence → one permutation, and each permutation has a unique inverse sequence). So each permutation gets probability ${}\frac{1}{n!}{}$.

### ⚠️ Common bug
```
for i ← 1 to n
    swap A[i] with A[Random(1, n)]   # ❌ NOT uniform
```
This has ${}n^n{}$ equally likely choice sequences but only ${}n!{}$ permutations, and ${}n^n{}$ is generally not divisible by ${}n!{}$ → some permutations more likely. Not uniform.

## Why we care: The Hiring Problem
```
Hire-Secretary(n):
    randomly permute all n candidates
    best ← 0
    for i ← 1 to n
        interview candidate i
        if candidate i is better than best:
            hire candidate i; best ← i
```
- Let ${}X_i = 1{}$ if candidate ${}i{}$ is hired, else 0.
- Candidate ${}i{}$ is hired **iff they are the best among the first ${}i{}$**. In a random permutation all ${}i!{}$ orderings of the first ${}i{}$ are equally likely, so the best is equally likely at any position:
$$E[X_i] = \Pr[X_i = 1] = \frac{1}{i}$$
- By linearity of expectation:
$$E[X] = E[X_1] + \cdots + E[X_n] = 1 + \frac{1}{2} + \cdots + \frac{1}{n} = H_n = \Theta(\log n)$$

## Geometric Distribution
- Waiting time for first success; success probability ${}p{}$, fail probability ${}1-p{}$.
- Probability first success on flip ${}m{}$:
$$P_M(m) = p(1-p)^{m-1}$$
- Expectation (two ways):
$$E[X] = \sum_{j=1}^{\infty} j(1-p)^{j-1}p = \frac{1}{p}$$
$$E[X] = \sum_{i=1}^{\infty} \Pr[X \ge i] = \sum_{i=1}^{\infty}(1-p)^{i-1} = \frac{1}{1-(1-p)} = \frac{1}{p}$$

#### Recall: Infinite geometric series: ${}\sum_{n=1}^{\infty}a(r)^{n-1} = \frac{a}{1-r}{}$

#### Recall: Finite geometric series: ${}\sum_{n=1}^{j}a_{1}(r)^{n-1}=\frac{a_{1}(1-r^j)}{1-r}{}$

![[Pasted image 20260924104243.png]]

#### Note: for converging (i.e. ratio < 1) geometric series with unknown upper bound, just treat it as an ${}\infty{}$ geometric series since it converges anyway.
### Key difference between Expectation and Probability:
- *Probability:* What are the chances of the first flip on this turn?
- *Expectation:* How many fails do we expect?

## Coupon Collector
- ${}n{}$ coupon types, each box equally likely any type. Expected boxes to collect all types?
- Stage ${}i{}$ = time between ${}i{}$ and ${}i+1{}$ distinct coupons. In stage ${}i{}$ success prob ${}=\frac{n-i}{n}{}$, so expected wait ${}=\frac{n}{n-i}{}$.
$$E[X] = \sum_{i=0}^{n-1} \frac{n}{n-i} = n\sum_{i=1}^{n}\frac{1}{i} = \Theta(n\log n)$$
#### Recall: Harmonic series: ${}\sum_{i=k}^{n} \frac{1}{i} = \ln n + \gamma - \left( \frac{1}{1} + \frac{1}{2} + \dots + \frac{1}{k-1} \right){}$
