# Lecture 7: Important Discrete Random Variables

## Overview

Important discrete RVs covered in this lecture:

| RV                | Models                          | PMF                              | ${}E[X]{}$    | ${}VAR[X]{}$     |
| ----------------- | ------------------------------- | -------------------------------- | ------------- | ---------------- |
| Bernoulli         | single trial, success/failure   | ${}p,1-p{}$                      | ${}p{}$       | ${}p(1-p){}$     |
| Binomial          | # successes in ${}n{}$ trials   | ${}\binom{n}{k}p^k(1-p)^{n-k}{}$ | ${}np{}$      | ${}np(1-p){}$    |
| Geometric         | # trials until 1st success      | ${}(1-p)^{k-1}p{}$               | ${}1/p{}$     | ${}(1-p)/p^2{}$  |
| Discrete Uniform  | equally likely consecutive ints | ${}1/M{}$                        | ${}(M-1)/2{}$ | ${}(M^2-1)/12{}$ |
| **Poisson (new)** | # events in an interval         | ${}\alpha^k e^{-\alpha}/k!{}$    | ${}\alpha{}$  | ${}\alpha{}$     |

---

## Bernoulli Random Variable

- Assumes value ${}0{}$ with prob ${}(1-p){}$ and value ${}1{}$ with prob ${}p{}$.
$$
p_X(0)=1-p,\qquad p_X(1)=p
$$
- **Mean & variance:**
$$
E[X]=p,\qquad VAR[X]=p(1-p)
$$
- Models a single coin toss, or the occurrence/non-occurrence of any event of interest.

>[!Example]
>A single fair coin toss (${}p=0.5{}$): ${}E[X]=0.5{}$, ${}VAR[X]=0.25{}$.

---

## Binomial Random Variable

- Repeat an experiment ${}n{}$ **independent** times; event ${}A{}$ occurs each time with prob ${}p{}$.
- ${}X={}$ number of times ${}A{}$ occurs.
$$
p_X(k)=\binom{n}{k}p^k(1-p)^{n-k}\qquad k=0,1,\dots,n
$$
- **Mean & variance:**
$$
E[X]=np,\qquad VAR[X]=np(1-p)
$$
>[!note] Key insight
>These are exactly ${}n{}$ times the Bernoulli values — a binomial RV is a **sum of ${}n{}$ independent Bernoulli** RVs.

- Applications: multiple coin flips, bit errors in a transmission, defective parts in a batch.
- The pmf is **symmetric when ${}p=0.5{}$**.

>[!Example]
>${}n=10{}$ coin flips, fair coin. Probability of exactly 5 heads:
$$p_X(5)=\binom{10}{5}(0.5)^5(0.5)^5=\frac{252}{1024}\approx 0.246$$

---

## Geometric Random Variable

- Repeat an experiment until event ${}A{}$ **first** occurs (each trial independent, success prob ${}p{}$).
- ${}M={}$ number of trials until the first success.
$$
p_M(k)=(1-p)^{k-1}p\qquad k=1,2,\dots
$$
- **Mean & variance:**
$$
E[M]=\frac{1}{p},\qquad VAR[M]=\frac{1-p}{p^2}
$$
- **Second form:** ${}M'=M-1{}$ = number of **failures before** the first success:
$$
p_{M'}(k)=(1-p)^k p\qquad k=0,1,2,\dots
$$
$$
E[M']=\frac{1}{p}-1=\frac{1-p}{p},\qquad VAR[M']=\frac{1-p}{p^2}
$$
- Applications: white dots between successive black dots in a document scan, transmissions until an error-free one.

>[!Example]
>Rolling a die until a "6" appears (${}p=\tfrac16{}$). The expected number of rolls is ${}E[M]=6{}$.

### Memoryless Property of the Geometric RV
- ${}M=$ # trials to first success. Given that the first ${}m{}$ trials had **no** success, what is the prob it takes ${}k{}$ **more** trials?
$$
P[M=k+m \mid M>m]=\frac{P[M=k+m]}{P[M>m]}=\frac{(1-p)^{k+m-1}p}{(1-p)^m}=(1-p)^{k-1}p=P[M=k]
$$
- The conditional probability is **independent of ${}m{}$** — the process "forgets" past failures.

---

## Discrete Uniform Random Variable

- Assumes values in ${}S_X=\{0,1,2,\dots,M-1\}{}$ with **equal** probability.
$$
p_X(k)=\frac{1}{M}\qquad k\in\{0,1,\dots,M-1\}
$$
- **Mean & variance:**
$$
E[X]=\frac{M-1}{2},\qquad VAR[X]=\frac{M^2-1}{12}
$$
- Applications: fair coin/die, roulette wheel, lottery ("Mark 6").

>[!Example]
>A fair die (${}M=6{}$): ${}E[X]=\frac{5}{2}=2.5{}$, ${}VAR[X]=\frac{35}{12}{}$.

---

## Poisson Random Variable (new)

- Models the **number of occurrences of an event in a given interval of time/space**, where events occur completely **at random**.
$$
P[N=k]=\frac{\alpha^k}{k!}e^{-\alpha}\qquad k=0,1,2,\dots
$$
- The parameter ${}\alpha{}$ = **average number of events** in the interval.
- **Mean & variance** (both equal!):
$$
E[N]=\alpha,\qquad VAR[N]=\alpha
$$

### Applications
- Hits on a website in one hour.
- Customer service requests in one day.
- Defects on a semiconductor chip.
- Photons arriving at a light detector.
- Particles emitted by a radioactive mass in a fixed time.

### The pmf sums to 1
$$
\sum_{k=0}^{\infty}\frac{\alpha^k}{k!}e^{-\alpha}=e^{-\alpha}\sum_{k=0}^{\infty}\frac{\alpha^k}{k!}=e^{-\alpha}e^{\alpha}=1
$$
(using the Taylor series ${}e^{\alpha}=\sum_{k=0}^{\infty}\alpha^k/k!{}$).

### Shape of the pmf
- ${}P[N=k]{}$ is maximized at the largest integer ${}\le\alpha{}$. If ${}\alpha{}$ is a positive integer, the maximum is at both ${}\alpha{}$ and ${}\alpha-1{}$.

>[!Example]
>Calls arrive at a switchboard at rate ${}\lambda{}$ per second. Number of calls in ${}t{}$ seconds is Poisson with ${}\alpha=\lambda t{}$.
>- ${}P[\text{no requests in }t\text{ s}]=P[N(t)=0]=\frac{(\lambda t)^0}{0!}e^{-\lambda t}=e^{-\lambda t}{}$
>- ${}P[\text{at least }n\text{ requests}]=1-P[N(t)<n]=1-e^{-\lambda t}\sum_{k=0}^{n-1}\frac{(\lambda t)^k}{k!}{}$

---

## Poisson Approximation to the Binomial

- For **large ${}n{}$ and small ${}p{}$**, the binomial pmf is approximated by a Poisson pmf with ${}\alpha=np{}$:
$$
\binom{n}{k}p^k(1-p)^{n-k}\approx \frac{\alpha^k}{k!}e^{-\alpha},\qquad \alpha=np
$$

### Intuition
- Poisson counts events in an interval ${}T{}$ with average ${}\alpha{}$.
- Split ${}T{}$ into ${}n\gg\alpha{}$ subintervals; at most one event per subinterval with prob ${}p=\alpha/n{}$.
- As ${}n\to\infty{}$, ${}p\to 0{}$ and the "at most one per subinterval" assumption becomes exact → binomial → Poisson.

### Mathematical justification
With ${}p=\alpha/n{}$:
- No successes: ${}p_0=(1-p)^n=(1-\alpha/n)^n\to e^{-\alpha}{}$ as ${}n\to\infty{}$.
- Ratio of successive terms:
$$
\frac{p_{k+1}}{p_k}=\frac{(n-k)p}{(k+1)(1-p)}\to\frac{\alpha}{k+1}
$$
- By induction: ${}p_0=e^{-\alpha},\ p_1=\alpha e^{-\alpha},\ p_2=\frac{\alpha^2}{2}e^{-\alpha},\ \dots\ p_k=\frac{\alpha^k}{k!}e^{-\alpha}{}$ — the **Poisson pmf**.

>[!Example]
>Bit error prob ${}p=10^{-3}{}$, block of ${}n=1000{}$ bits, errors independent. Find ${}P[N\ge 5]{}$.
>
>${}N{}$ is binomial, but with large ${}n{}$ we approximate with Poisson ${}\alpha=np=1{}$:
$$P[N\ge 5]=1-P[N<5]=1-e^{-1}\Big(1+\tfrac11+\tfrac12+\tfrac16+\tfrac{1}{24}\Big)=0.00366$$

---

## Python (FYI)

```python
import numpy as np
import scipy.stats
import matplotlib.pyplot as plt

# pmf values
scipy.stats.binom.pmf(x, n, p)     # Binomial
scipy.stats.geom.pmf(x, p)         # Geometric (x starts at 1)
scipy.stats.poisson.pmf(x, a)      # Poisson
scipy.stats.randint.pmf(low, high) # Discrete uniform on [low, high-1]

# random samples
scipy.stats.binom.rvs(n=15, p=0.5, size=50000)
scipy.stats.geom.rvs(p=0.3, size=n)
scipy.stats.poisson.rvs(mu=2, loc=0, size=n)
scipy.stats.randint.rvs(low, high, size=n)
```
