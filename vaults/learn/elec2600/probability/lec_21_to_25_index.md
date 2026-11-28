# ELEC 2600 — Lectures 21–25 Master Notes (Part IV: Stochastic Processes)

> **How to use this page.** Read the lecture notes in order, then use this page as a formula sheet and revision checklist. Definitions live in `terms/`; each note links to the relevant term file at first use.
>
> Previous part: [[lec_13_to_20_index]].

---

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`.

**Processes:** [[terms/random-process]] · [[terms/iid-process]] · [[terms/isi-process]] · [[terms/poisson-process]] · [[terms/wiener-process]] · [[terms/gaussian-process]]

**Descriptions:** [[terms/autocorrelation]] · [[terms/cross-correlation]] · [[terms/stationarity]] · [[terms/wss]]

---

## Lecture map

| Lecture | Topic | Note |
|---|---|---|
| 21 | Definition, interpretations, joint distributions, i.i.d. processes | [[lec_21_definition_of_a_random_process]] |
| 22 | Sum processes, i.s.i. processes, binomial and Poisson processes | [[lec_22_sum_processes_and_isi]] |
| 23 | Mean, variance, autocorrelation, covariance, Gaussian and Wiener processes | [[lec_23_mean_and_autocorrelation]] |
| 24 | Stationary and wide-sense stationary processes | [[lec_24_stationary_random_processes]] |
| 25 | Random step, telegraph, shot noise, Wiener construction, cross-correlation | [[lec_25_multiple_random_processes]] |

> [!note] Lecture 25 numbering
> `Part4.pdf` prints title slides for Lectures 21–24 only. Pages 89–103 — the additional examples and the “Multiple Random Processes” material — are treated as Lecture 25 in these notes.

---

## The big story

1. **From numbers to functions.** A random process assigns a whole time function to each outcome. Fix the time to get a random variable; fix the outcome to get a sample path.
2. **Specify by joint distributions.** The first-order, second-order, and all higher-order distributions determine the process. Marginals alone do not.
3. **Add i.i.d. steps.** A sum process accumulates i.i.d. increments. It has independent and stationary increments, so it is an i.s.i. process.
4. **Count arrivals.** The binomial counting process is the discrete-time i.s.i. example. Its continuous-time limit is the Poisson process.
5. **Describe second-order behaviour.** Use the mean function, variance function, autocorrelation, and autocovariance. For i.i.d. processes the covariance is a spike; for i.s.i. processes it is $\sigma^2\min(m,n)$.
6. **Specialise to Gaussians.** A Gaussian process is fully specified by its mean and covariance. The Wiener process is the continuous-time Gaussian i.s.i. example.
7. **Weaken stationarity.** Full stationarity is hard to check; WSS needs only a constant mean and a lag-only autocorrelation. Gaussian plus WSS implies stationary.
8. **Compare two processes.** Cross-correlation and cross-covariance measure how one process at one time relates to another at another time.

---

## Core formula sheet

### Random processes (Lecture 21)

$$
F_{X(t_1),\dots,X(t_n)}(x_1,\dots,x_n)
=P[X(t_1)\le x_1,\dots,X(t_n)\le x_n]
$$

i.i.d. process:

$$
f_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\prod_{i=1}^{k}f(x_i)
$$

Bernoulli process:

$$
P[X_0=x_0,\dots,X_k=x_k]
=p^{\#1}(1-p)^{\#0}
$$

White Gaussian noise:

$$
f_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\frac{1}{(2\pi\sigma^2)^{k/2}}
\exp\left(-\frac{1}{2\sigma^2}\sum_{i=1}^{k}x_i^2\right)
$$

---

### Sum and i.s.i. processes (Lecture 22)

$$
S_n=\sum_{i=1}^{n}X_i,
\qquad
S_0=0,
\qquad
S_n=S_{n-1}+X_n
$$

Binomial counting process:

$$
p_{S_n}(k)=\binom{n}{k}p^k(1-p)^{n-k}
$$

Random walk:

$$
P[S_n=2k-n]=\binom{n}{k}p^k(1-p)^{n-k}
$$

Independent increments:

$$
X(t_2)-X(t_1),\dots,X(t_k)-X(t_{k-1})
\ \text{independent}
$$

Stationary increments:

$$
X(t+h)-X(t)\ \overset{d}{=}\ X(s+h)-X(s)
$$

Joint pmf from increments:

$$
p_{S_m,S_n}(j,k)=p_{S_m}(j)\,p_{S_{n-m}}(k-j)
$$

Poisson process:

$$
P[N(t)=k]=\frac{(\lambda t)^k}{k!}e^{-\lambda t}
$$

Poisson increment:

$$
N(t_2)-N(t_1)\sim\text{Poisson}(\lambda(t_2-t_1))
$$

Inter-arrival time:

$$
T\sim\text{Exponential}(\lambda),
\qquad
E[T]=\frac1\lambda,
\qquad
\operatorname{Var}(T)=\frac1{\lambda^2}
$$

Time to the $m$-th event:

$$
E[S_m]=\frac{m}{\lambda},
\qquad
\operatorname{Var}(S_m)=\frac{m}{\lambda^2}
$$

Conditional count:

$$
N(t_1)\mid N(t_2)=n
\sim
\text{Binomial}\left(n,\frac{t_1}{t_2}\right)
$$

---

### Mean and autocorrelation (Lecture 23)

$$
m_X(t)=E[X(t)],
\qquad
\operatorname{Var}[X(t)]=E[X(t)^2]-m_X(t)^2
$$

$$
R_X(t_1,t_2)=E[X(t_1)X(t_2)]
$$

$$
C_X(t_1,t_2)=R_X(t_1,t_2)-m_X(t_1)m_X(t_2)
$$

$$
C_X(t,t)=\operatorname{Var}[X(t)]
$$

i.i.d. process:

$$
C_X(m,n)=\sigma^2\delta(m-n),
\qquad
R_X(m,n)=\sigma^2\delta(m-n)+\mu^2
$$

i.s.i. process:

$$
C_S(m,n)=\sigma^2\min(m,n)
$$

Binomial:

$$
m_S(n)=np,
\qquad
\operatorname{Var}[S_n]=np(1-p),
\qquad
C_S(n_1,n_2)=p(1-p)\min(n_1,n_2)
$$

Poisson:

$$
m_N(t)=\lambda t,
\qquad
\operatorname{Var}[N(t)]=\lambda t,
\qquad
C_N(t_1,t_2)=\lambda\min(t_1,t_2)
$$

Gaussian process:

$$
f(\mathbf x)=\frac{1}{(2\pi)^{k/2}\lvert C\rvert^{1/2}}
\exp\left[-\frac12(\mathbf x-\mathbf m)^T C^{-1}(\mathbf x-\mathbf m)\right]
$$

Wiener process:

$$
m_W(t)=0,
\qquad
C_W(t_1,t_2)=\sigma^2\min(t_1,t_2)
$$

---

### Stationarity (Lecture 24)

$$
F_{X(t_1),\dots,X(t_k)}(x_1,\dots,x_k)
=
F_{X(t_1+\Delta),\dots,X(t_k+\Delta)}(x_1,\dots,x_k)
$$

Stationary implies:

$$
m_X(t)=m,
\qquad
R_X(t_1,t_2)=R_X(t_1-t_2)
$$

WSS:

$$
m_X(t)=m,
\qquad
R_X(t_1,t_2)=R_X(t_1-t_2)
$$

Logical relations:

$$
\text{stationary}\Longrightarrow\text{WSS},
\qquad
\text{WSS}\not\Longrightarrow\text{stationary}
$$

$$
\text{Gaussian}+\text{WSS}\Longrightarrow\text{stationary}
$$

Autocorrelation properties:

$$
R_X(0)=E[X(t)^2],
\qquad
R_X(-\tau)=R_X(\tau),
\qquad
\lvert R_X(\tau)\rvert\le R_X(0)
$$

Moving average:

$$
Y_n=\frac{X_n+X_{n-1}}{2},
\qquad
C_Y(i,j)=
\begin{cases}
\sigma^2/2, & i=j,\\
\sigma^2/4, & \lvert i-j\rvert=1,\\
0, & \lvert i-j\rvert\ge2
\end{cases}
$$

---

### Further examples and two processes (Lecture 25)

Random step:

$$
m_X(t)=P[X(t)=1],
\qquad
\operatorname{Var}[X(t)]=P[X(t)=1]-P[X(t)=1]^2
$$

Poisson parity:

$$
P[N\text{ even}]=\frac12\left(1+e^{-2\alpha}\right),
\qquad
P[N\text{ odd}]=\frac12\left(1-e^{-2\alpha}\right)
$$

Telegraph signal:

$$
m_X(t)=0,
\qquad
R_X(t_1,t_2)=e^{-2\lambda\lvert t_2-t_1\rvert}
$$

Shot noise:

$$
X(t)=\sum_{i=1}^{\infty}h(t-S_i),
\qquad
E[X(t)]\to\lambda\int_0^{\infty}h(u)\,du
$$

Cross-correlation:

$$
R_{XY}(t_1,t_2)=E[X(t_1)Y(t_2)]
$$

Cross-covariance:

$$
C_{XY}(t_1,t_2)=R_{XY}(t_1,t_2)-m_X(t_1)m_Y(t_2)
$$

Random-phase pair:

$$
R_{XY}(t_1,t_2)=-\frac12\sin(2\pi(t_1-t_2))
$$

Signal plus independent noise:

$$
R_{XY}(t_1,t_2)=R_X(t_1,t_2)+m_X(t_1)m_N(t_2)
$$

---

## Common exam traps

1. **A random process is not a random variable.** Fix $t$ to get a random variable; fix $\xi$ to get a sample path.
2. **First-order marginals do not specify the process.** You need all joint distributions.
3. **Independence turns joint densities into products, not sums.**
4. **Stationary increments do not make the process stationary.** The Poisson and Wiener processes have stationary increments but growing variance.
5. **Only non-overlapping increments are independent.** Overlapping intervals share randomness.
6. **The $m$-th Poisson arrival has mean $m/\lambda$, not $1/\lambda$.**
7. **Convert the rate to the same time unit as the question.**
8. **Conditional on $N(t_2)=n$, the count by $t_1$ is binomial with parameter $t_1/t_2$.**
9. **The i.s.i. covariance is $\sigma^2\min(m,n)$, not $\sigma^2\max(m,n)$ and not $\sigma^2\lvert m-n\rvert$.**
10. **$R_X(0)=E[X^2]$, not the variance, unless the mean is zero.**
11. **WSS does not imply stationary.** The interleaved process is the counterexample.
12. **Gaussian plus WSS does imply stationary.**
13. **The autocorrelation bound needs an absolute value:** $\lvert R_X(\tau)\rvert\le R_X(0)$.
14. **Uncorrelated does not imply independent** for two processes either.
15. **$R_{XY}(t_1,t_2)\ne R_{YX}(t_1,t_2)$ in general.** Instead $R_{YX}(t_1,t_2)=R_{XY}(t_2,t_1)$.
16. **The Wiener covariance is $\sigma^2\min(t_1,t_2)$, the same functional form as the Poisson covariance.**

---

## Terms index

All definitions live in `terms/`, one file per term:

**Processes:** [[terms/random-process]] · [[terms/iid-process]] · [[terms/isi-process]] · [[terms/poisson-process]] · [[terms/wiener-process]] · [[terms/gaussian-process]]

**Descriptions:** [[terms/autocorrelation]] · [[terms/cross-correlation]] · [[terms/stationarity]] · [[terms/wss]]

**Background:** [[terms/random-variable]] · [[terms/exponential-distribution]]

---

## Suggested study plan

### Day 1 — Lecture 21

- Write the definition of a random process and the four interpretations of $X(t,\xi)$.
- Redo the binary-sequence probabilities for $P[X(1)=0]$ and $P[X(1)=0,X(2)=1]$.
- Derive the first-order density of $\xi\cos(2\pi t)$.
- Write the joint density of white Gaussian noise.

### Day 2 — Lecture 22

- Derive the binomial counting pmf and the random-walk pmf.
- Prove that a sum process has independent and stationary increments.
- Build a joint pmf from increments.
- Derive the Poisson pmf as a limit.
- Redo the message-arrival and customer-service examples.
- Memorise the exponential and Erlang means and variances.

### Day 3 — Lecture 23

- Compute mean and variance functions for the amplitude and phase sinusoids.
- Derive $C_S(m,n)=\sigma^2\min(m,n)$.
- Write the Gaussian process density.
- Do the Wiener marginal/joint density example.

### Day 4 — Lecture 24

- State stationarity and WSS precisely.
- Reproduce the interleaved WSS-but-not-stationary example.
- Prove that Gaussian plus WSS implies stationary.
- Build covariance matrices for a WSS Gaussian process.
- Derive the moving-average covariance.

### Day 5 — Lecture 25

- Do the random-step pmf, mean, and variance.
- Derive the Poisson even/odd formulas.
- Derive the telegraph autocorrelation.
- Derive the shot-noise mean by conditioning.
- Derive the Wiener covariance.
- Compute cross-correlations for the phase pair and the signal-plus-noise model.

### Final review

- Read each lecture's 60-second summary.
- Recite the formula sheet from memory.
- Redo the examples without looking at the solutions.
- Check that you can explain *why* each formula holds, not just quote it.
