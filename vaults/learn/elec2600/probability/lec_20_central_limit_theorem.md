# Lecture 20: Central Limit Theorem

> **Big picture.** Add up many independent, identically distributed random variables. Regardless of the shape of the original distribution, the **standardized sum** becomes approximately Gaussian. This is why the Gaussian distribution appears everywhere: measurement noise, aggregate effects, and sample averages are often sums of many small independent contributions.

---

## Learning goals

By the end of this lecture you should be able to:

1. State the Central Limit Theorem (CLT).
2. Standardize a sum correctly.
3. Approximate probabilities for sums and sample means.
4. Use the $Q$ function for Gaussian tails.
5. Apply the CLT to exponential sums, binomial sums, and real engineering problems.
6. Use the CLT to choose a sample size.

---

## 1. Central Limit Theorem

Let $X_1,X_2,\dots,X_n$ be **independent and identically distributed** with

$$
E[X_i]=\mu,
\qquad
\operatorname{Var}(X_i)=\sigma^2<\infty.
$$

Define the sum

$$
S_n=\sum_{i=1}^{n}X_i.
$$

We already know

$$
E[S_n]=n\mu,
\qquad
\operatorname{Var}(S_n)=n\sigma^2.
$$

Standardize:

$$
\boxed{
Z_n=\frac{S_n-n\mu}{\sigma\sqrt n}
}.
$$

Then

$$
E[Z_n]=0,
\qquad
\operatorname{Var}(Z_n)=1.
$$

The **Central Limit Theorem** says

$$
\boxed{
\lim_{n\to\infty}P[Z_n\le z]
=
\int_{-\infty}^{z}
\frac{1}{\sqrt{2\pi}}e^{-x^2/2}\,dx
=
\Phi(z)
}.
$$

In words:

$$
\boxed{
Z_n\ \text{converges in distribution to}\ \mathcal N(0,1)
}.
$$

> **Crucial point:** we make **no assumption** about the shape of the distribution of the $X_i$. It can be exponential, Bernoulli, uniform, etc. Only the mean and variance matter in the limit.

---

## 2. Equivalent forms

For large $n$,

$$
\boxed{
S_n\ \approx\ \mathcal N(n\mu,\ n\sigma^2)
}
$$

and

$$
\boxed{
M_n=\frac{S_n}{n}\ \approx\
\mathcal N\left(\mu,\ \frac{\sigma^2}{n}\right)
}.
$$

Equivalently, for a sum,

$$
P[S_n\le s]
\approx
\Phi\left(\frac{s-n\mu}{\sigma\sqrt n}\right),
$$

and for a sample mean,

$$
P[M_n\le m]
\approx
\Phi\left(\frac{m-\mu}{\sigma/\sqrt n}\right).
$$

> **Memory aid:** the sum has mean $n\mu$ and variance $n\sigma^2$. The average has mean $\mu$ and variance $\sigma^2/n$.

---

## 3. Why the Gaussian is everywhere

Many macroscopic quantities are sums of many small independent effects:

- noise voltage = sum of many tiny random disturbances,
- total demand = sum of many individual demands,
- measurement error = sum of many independent error sources,
- sample average = sum of many observations.

The CLT says that the **aggregate** often looks Gaussian even if the individual contributions do not.

> **Warning:** the CLT is an asymptotic statement. For small $n$, the distribution of $S_n$ may look very non-Gaussian. For heavily skewed or heavy-tailed distributions, a larger $n$ may be needed.

---

## 4. Review of the $Q$ function

The **$Q$ function** is the tail probability of a standard normal:

$$
\boxed{
Q(x)=\int_x^{\infty}
\frac{1}{\sqrt{2\pi}}e^{-t^2/2}\,dt
}.
$$

It is related to the standard normal CDF $\Phi$ by

$$
Q(x)=1-\Phi(x).
$$

If $X\sim\mathcal N(0,1)$, then

$$
\boxed{
P[X>x]=Q(x)
}.
$$

If $Y\sim\mathcal N(m,\sigma^2)$, then

$$
\boxed{
P[Y>y]
=
Q\left(\frac{y-m}{\sigma}\right)
}.
$$

By symmetry,

$$
\boxed{
P[|Y-m|<\varepsilon]
=
1-2Q\left(\frac{\varepsilon}{\sigma}\right)
}.
$$

Useful values:

$$
Q(0)=0.5,
\qquad
Q(1)\approx0.1587,
$$

$$
Q(1.96)\approx0.025,
\qquad
Q(2)\approx0.0228.
$$

Python:

```python
from scipy.stats import norm

# P[X > x] for standard normal
p = norm.sf(x)

# P[Y > y] for Y ~ N(m, sigma^2)
p = norm.sf(y, loc=m, scale=sigma)
```

---

## 5. Example: insurance processing times

The processing times for forms are independent with mean $8$ minutes and standard deviation $2$ minutes. Estimate the probability that it takes more than $840$ minutes to process the first $100$ forms.

Let $T_i$ be the time for form $i$, and

$$
S=\sum_{i=1}^{100}T_i.
$$

We have

$$
E[S]=100\cdot8=800,
$$

$$
\operatorname{Var}(S)=100\cdot2^2=400,
$$

so the standard deviation is

$$
\sigma_S=\sqrt{400}=20.
$$

By the CLT,

$$
S\approx\mathcal N(800,400).
$$

Therefore

$$
\begin{aligned}
P[S>840]
&\approx
P\left[\frac{S-800}{20}>\frac{840-800}{20}\right]\\
&=
P[Z>2]\\
&=Q(2)\\
&\approx0.0228.
\end{aligned}
$$

So there is about a $2.28\%$ chance that processing 100 forms takes more than 840 minutes.

---

## 6. Example: sum of exponential random variables

The sum of $m$ i.i.d. exponential random variables with rate $\lambda$ is an **$m$-Erlang** random variable, with

$$
E[S_m]=\frac{m}{\lambda},
\qquad
\operatorname{Var}(S_m)=\frac{m}{\lambda^2}.
$$

For large $m$, the Erlang distribution is approximately Gaussian:

$$
\boxed{
S_m\approx
\mathcal N\left(\frac{m}{\lambda},\frac{m}{\lambda^2}\right)
}.
$$

> **Intuition:** exponential variables are very skewed, but after adding many of them, the sum becomes bell-shaped. This is a good demonstration that the CLT does not require the original variables to be Gaussian.

---

## 7. Example: sum of Bernoulli random variables

If $X_i\sim\text{Bernoulli}(p)$ are independent, then

$$
S_n=\sum_{i=1}^{n}X_i\sim\text{Binomial}(n,p).
$$

We have

$$
E[S_n]=np,
\qquad
\operatorname{Var}(S_n)=np(1-p).
$$

The CLT gives the **normal approximation to the binomial**:

$$
\boxed{
S_n\approx
\mathcal N\big(np,\ np(1-p)\big)
}.
$$

This is also called the **De Moivre–Laplace theorem**:

$$
\boxed{
\binom{n}{k}p^k(1-p)^{n-k}
\approx
\frac{1}{\sqrt{2\pi np(1-p)}}
\exp\left[
-\frac{(k-np)^2}{2np(1-p)}
\right]
}.
$$

> **Rule of thumb:** the approximation is usually reasonable when $np$ and $n(1-p)$ are both not too small (often both at least $5$ or $10$).

---

## 8. Example: the 1000th event

The times between events are i.i.d. exponential random variables with mean $m$ seconds. Find the probability that the 1000th event occurs between $950m$ and $1050m$ seconds.

Let $X_i$ be the time between the $(i-1)$-th and $i$-th events. Then

$$
E[X_i]=m,
\qquad
\operatorname{Var}(X_i)=m^2.
$$

The time of the 1000th event is

$$
S_{1000}=\sum_{i=1}^{1000}X_i.
$$

By the CLT,

$$
E[S_{1000}]=1000m,
\qquad
\operatorname{Var}(S_{1000})=1000m^2,
$$

so

$$
\sigma_{S_{1000}}=m\sqrt{1000}.
$$

Therefore

$$
\begin{aligned}
&P[950m\le S_{1000}\le1050m]\\
&=
P\left[
\frac{950m-1000m}{m\sqrt{1000}}
\le
\frac{S_{1000}-1000m}{m\sqrt{1000}}
\le
\frac{1050m-1000m}{m\sqrt{1000}}
\right]\\
&=
P\left[
-\frac{50}{\sqrt{1000}}
\le Z\le
\frac{50}{\sqrt{1000}}
\right]\\
&=
P[-1.581\le Z\le1.581]\\
&=
1-2Q(1.581)\\
&\approx0.886.
\end{aligned}
$$

So the probability is about $88.6\%$.

> **Check:** $50/\sqrt{1000}\approx1.581$. Using $Q(1.58)\approx0.057$, we get $1-2(0.057)\approx0.886$.

---

## 9. Discrete CLT and continuity correction

If the $X_i$ are integer-valued, then $S_n$ is integer-valued, and the CLT says

$$
\boxed{
p_{S_n}(k)=P[S_n=k]
\approx
\frac{1}{\sqrt{2\pi n\sigma^2}}
\exp\left[
-\frac{(k-n\mu)^2}{2n\sigma^2}
\right]
}.
$$

For a binomial random variable,

$$
\boxed{
P[S_n=k]
\approx
\frac{1}{\sqrt{2\pi np(1-p)}}
\exp\left[
-\frac{(k-np)^2}{2np(1-p)}
\right]
}.
$$

> **Practical refinement: continuity correction.** Since a discrete value $k$ corresponds to the interval $[k-0.5,k+0.5]$ in the continuous approximation, use
> $$
> P[a\le S_n\le b]
> \approx
> P[a-0.5\le Y\le b+0.5],
> \qquad
> Y\sim\mathcal N(n\mu,n\sigma^2).
> $$
> This often improves the approximation substantially.

---

## 10. Choosing a sample size: Chebyshev vs CLT

Suppose $X_i\sim\text{Bernoulli}(p)$ and we use

$$
M_n=\frac1n\sum_{i=1}^{n}X_i
$$

to estimate $p$. We want

$$
P[|M_n-p|<0.01]\ge0.95.
$$

### Using Chebyshev

Since $\operatorname{Var}(X_i)=p(1-p)\le1/4$ and $\operatorname{Var}(M_n)=p(1-p)/n$,

$$
P[|M_n-p|<0.01]
\ge
1-\frac{p(1-p)}{n(0.01)^2}
\ge
1-\frac{1}{4n(0.01)^2}.
$$

Set

$$
1-\frac{1}{4n(0.01)^2}=0.95
\quad\Longrightarrow\quad
n=50{,}000.
$$

This is a **guarantee**, but it is very conservative.

### Using the CLT

For large $n$,

$$
M_n\approx
\mathcal N\left(p,\frac{p(1-p)}{n}\right).
$$

Using the worst-case variance $p(1-p)\le1/4$,

$$
P[|M_n-p|<0.01]
\approx
1-2Q\left(\frac{0.01}{\sqrt{1/(4n)}}\right)
=
1-2Q(0.02\sqrt n).
$$

Set this equal to $0.95$:

$$
Q(0.02\sqrt n)=0.025.
$$

Since $Q(1.96)=0.025$,

$$
0.02\sqrt n\approx1.96
\quad\Longrightarrow\quad
n\approx\left(\frac{1.96}{0.02}\right)^2
\approx9604.
$$

Using the lecture's rounded value $1.95$ gives

$$
n\approx\left(\frac{1.95}{0.02}\right)^2
\approx9506.
$$

So the CLT suggests roughly $9500$–$9600$ samples, much less than Chebyshev's $50{,}000$. The CLT answer is approximate, not a guarantee.

---

## 11. Common mistakes

1. **Forgetting to standardize.** The CLT is about
$$
\frac{S_n-n\mu}{\sigma\sqrt n},
$$
not about $S_n$ itself.
2. **Using $\sigma$ instead of $\sigma\sqrt n$.** The standard deviation of $S_n$ is $\sigma\sqrt n$.
3. **Using the wrong variance for the sample mean.** $\operatorname{Var}(M_n)=\sigma^2/n$, not $\sigma^2$.
4. **Applying the CLT to dependent variables without checking conditions.** The basic CLT assumes independence (or suitable weak dependence).
5. **Expecting exact normality for finite $n$.** The CLT is a limit theorem; for small $n$ the approximation can be poor.
6. **No continuity correction for discrete sums.** For integer-valued variables, use $\pm0.5$ boundaries.
7. **Confusing tail directions.** $P[Y>y]=Q((y-m)/\sigma)$, while $P[Y<y]=\Phi((y-m)/\sigma)$.
8. **Thinking the CLT says the original variables are Gaussian.** It says the **sum** is approximately Gaussian.

---

## 12. 60-second summary

$$
\boxed{
Z_n=\frac{S_n-n\mu}{\sigma\sqrt n}
\ \overset{d}{\longrightarrow}\ \mathcal N(0,1)
}
$$

$$
\boxed{
S_n\approx\mathcal N(n\mu,n\sigma^2)
}
$$

$$
\boxed{
M_n\approx\mathcal N\left(\mu,\frac{\sigma^2}{n}\right)
}
$$

$$
\boxed{
Q(x)=\int_x^{\infty}\frac{1}{\sqrt{2\pi}}e^{-t^2/2}\,dt
}
$$

$$
\boxed{
P[Y>y]=Q\left(\frac{y-m}{\sigma}\right)
}
$$

$$
\boxed{
P[|Y-m|<\varepsilon]
=1-2Q\left(\frac{\varepsilon}{\sigma}\right)
}
$$

Binomial approximation:

$$
\boxed{
S_n\sim\text{Binomial}(n,p)
\approx
\mathcal N(np,np(1-p))
}
$$

Continuity correction:

$$
\boxed{
P[a\le S_n\le b]
\approx
P[a-0.5\le Y\le b+0.5]
}
$$
