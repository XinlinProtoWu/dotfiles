# Poisson process

**What it is.** The Poisson counting process $N(t)$ is the continuous-time, non-negative, integer-valued i.s.i. process with

$$
P[N(t)=k]=\frac{(\lambda t)^k}{k!}e^{-\lambda t},\qquad k=0,1,2,\dots
$$

It counts events occurring at average rate $\lambda$ per unit time.

**Why it exists.** It is the standard model for random arrivals: customers, calls, photons, failures, and web requests. It is the continuous-time limit of a Bernoulli counting process with very many, very unlikely trials. Its independent and stationary increments make joint probabilities easy to factor.

**Example.** Calls arrive at rate $10$ per minute, so $\lambda=1/6$ per second. The probability of $2$ calls in the first $10$ seconds and $6$ in the first $30$ seconds is

$$
P[N(10)=2]\,P[N(20)=4]
\approx0.2623\cdot0.1835
\approx0.0481.
$$

**Where it appears:** [[lec_22_sum_processes_and_isi]] Sections 10–18 · [[lec_23_mean_and_autocorrelation]] Section 9 · [[lec_25_multiple_random_processes]] Sections 2–5

**Related:** [[terms/isi-process]] · [[terms/exponential-distribution]] · [[terms/wiener-process]]
