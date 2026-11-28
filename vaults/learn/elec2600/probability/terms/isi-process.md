# Independent stationary increment (i.s.i.) process

**What it is.** A process whose non-overlapping increments $X(t_2)-X(t_1)$ are independent, and whose increments over intervals of equal length have the same distribution. In discrete time, every i.s.i. process with $S_0=0$ is a sum process $S_n=X_1+\cdots+X_n$ with the $X_i$ i.i.d.

**Why it exists.** It captures “fresh, time-invariant noise added to a running total.” It lets you build any joint distribution from first-order distributions plus independence, and it is the common structure behind the binomial counting process, random walks, the Poisson process, and the Wiener process.

**Example.** For a sum process with i.i.d. steps of variance $\sigma^2$,

$$
S_{n+h}-S_n=\sum_{i=n+1}^{n+h}X_i
$$

is a sum of $h$ fresh steps, so increments of the same length have the same distribution. The covariance is

$$
C_S(m,n)=\sigma^2\min(m,n).
$$

**Where it appears:** [[lec_22_sum_processes_and_isi]] Sections 4–9 · [[lec_23_mean_and_autocorrelation]] Section 9

**Related:** [[terms/iid-process]] · [[terms/poisson-process]] · [[terms/wiener-process]]
