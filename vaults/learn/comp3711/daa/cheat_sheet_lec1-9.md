1. Divide & Conquer Template
	- Divide: Split problem into $a$ subproblems of size $n/b$.
	- Conquer: Recursively solve each subproblem.
	- Combine: Merge results in time $f(n)$. $\rightarrow T(n) = aT(n/b) + f(n)$
2. Timing Analysis Methods
	- Substitution Method: Guess solution form, use induction to prove constants.
	- Recursion Tree: Unroll recurrence, sum work per level across $k = \log_b n$ levels.
3. Master Theorem (Compare $f(n)$ vs $n^{\log_b a}$)
	- $f(n) = O(n^{\log_b a - \varepsilon}) \implies T(n) = \Theta(n^{\log_b a})$
	- $f(n) = \Theta(n^{\log_b a}) \implies T(n) = \Theta(n^{\log_b a} \log n)$
	- $f(n) = \Omega(n^{\log_b a + \varepsilon})$ and regular $\implies T(n) = \Theta(f(n))$
4. Key Probability Formulas
	- Linearity of Expectation: $E[\sum X_i] = \sum E[X_i]$ (no independence needed). Indicator: $E[I_A] = \Pr(A)$.
	- Binomial Distribution: $\Pr(X = k) = \binom{n}{k} p^k (1-p)^{n-k}$, $E[X] = np$.
	- Geometric Distribution: $\Pr(X = m) = (1-p)^{m-1} p$, $E[X] = 1/p$.
	- Geometric Series: Finite $\sum_{i=0}^{j-1} a r^i = \frac{a(1-r^j)}{1-r}$; Infinite $\sum_{i=0}^{\infty} a r^i = \frac{a}{1-r}$ (|r| < 1).
	- Harmonic Series: $H_n = \sum_{i=1}^{n} \frac{1}{i} = \ln n + O(1) = \Theta(\log n)$. Indefinite sum $\sum H_n = n \ln n - n + O(\log n)$.
5. Quicksort & Selection
	- Quicksort: Partition around random pivot. Expected time $\Theta(n \log n)$, worst case $\Theta(n^2)$. Comparison prob: $\Pr(z_i, z_j \text{ compared}) = \frac{2}{j-i+1}$.
	- Randomized Select: Find $k$-th smallest in expected $\Theta(n)$ time.
6. Heaps & Priority Queues
	- Complete binary tree ($A[1]$ root, left $2i$, right $2i+1$, parent $\lfloor i/2 \rfloor$).
	- Operations: Heapify $O(\log n)$ | Build-Max-Heap $O(n)$ | Extract-Max/Insert $O(\log n)$ | Heapsort $O(n \log n)$ in-place, unstable.
7. Linear Sorts
	- Counting Sort: $\Theta(n+k)$ stable sort using frequency & prefix sum arrays.
	- Radix Sort: $\Theta(d(n+k))$ using stable digit-by-digit sorting (LSD to MSD).