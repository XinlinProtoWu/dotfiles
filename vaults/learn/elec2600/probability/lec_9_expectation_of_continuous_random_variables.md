# Lecture 9: Expectation of Continuous Random Variables

## Overview

1. Expectation of continuous RVs
2. Variance of continuous RVs
3. Important continuous RVs (Uniform, Exponential, Gaussian)

---

## Review: Expectation

- Interpretation: the long-run **average** of ${}X{}$ over many repetitions; the limit of the sample mean; our "best guess".
- Discrete RV: ${}E[X]=\sum_k x_k p_X(x_k){}$.
- Problem for continuous RVs: ${}P[X=x]=0{}$ for all ${}x{}$, so we cannot use a pmf.

---

## Expectation for Continuous RVs

$$
E[X]=\int_{-\infty}^{+\infty} x\,f_X(x)\,dx
$$
- Defined only if the integral converges **absolutely**: ${}\int_{-\infty}^{+\infty}|x|f_X(x)\,dx<\infty{}$.
- Notation: ${}\eta, m, \mu{}$.

### Reduction to the discrete formula (sifting property)
A discrete RV has "pdf" ${}f_X(x)=\sum_k p_X(x_k)\delta(x-x_k){}$. Substituting:
$$
E[X]=\int_{-\infty}^{+\infty}x\sum_k p_X(x_k)\delta(x-x_k)\,dx=\sum_k p_X(x_k)\int x\,\delta(x-x_k)\,dx=\sum_k x_k p_X(x_k)
$$

$$
\int x f_{X}(x)dx
$$
- **Sifting property:** the delta function is zero except at ${}x=a{}$, so ${}\int f(x)\delta(x-a)\,dx=f(a){}$.

>[!Example]
>**Mean of Uniform RV on [a,b]:**
$$E[X]=\int_a^b \frac{x}{b-a}\,dx=\frac{1}{b-a}\cdot\frac{x^2}{2}\Big|_a^b=\frac{b^2-a^2}{2(b-a)}=\frac{a+b}{2}$$

>[!Example]
>**Mean of Exponential RV** (${}f_X(x)=\lambda e^{-\lambda x}u(x){}$):
$$E[X]=\int_0^\infty x\lambda e^{-\lambda x}\,dx=\underbrace{-xe^{-\lambda x}\Big|_0^\infty}_{=0}+\int_0^\infty e^{-\lambda x}\,dx=\frac{1}{\lambda}$$
> - *${}u\cdot v{}$ written as a boundary subtraction is because that's just how it is for definite integrals that use uv sub*

---

## Expected Value of a Function of a RV

For ${}Y=g(X){}$:
$$
E[Y]=E[g(X)]=\int_{-\infty}^{+\infty}g(x)\,f_X(x)\,dx
$$
- This **avoids finding the pdf of ${}Y{}$** (compare: ${}E[Y]=\int y f_Y(y)\,dy{}$).
- Continuous analog of the discrete result ${}E[Y]=\sum_k g(x_k)p_X(x_k){}$.

### Linearity of expectation
For constants ${}a_i{}$ and functions ${}g_i{}$:
$$
E\Big[\sum_i a_i g_i(X)\Big]=\sum_i a_i E[g_i(X)]
$$
>[!warning]
>In general ${}E[\sum_i a_i g_i(X)]\neq\sum_i a_i g_i(E[X]){}$ **unless** the ${}g_i{}$ are linear.

>[!Example]
>${}Y=aX+b{}$:
$$E[Y]=E[aX+b]=aE[X]+b$$
>Special cases: ${}E[b]=b{}$, ${}E[aX]=aE[X]{}$, ${}E[X+b]=E[X]+b{}$.

>[!Example]
>**Sinusoid with random phase.** ${}Y=a\cos(\omega t+\Theta){}$, ${}\Theta\sim\text{Uniform}[0,2\pi]{}$:
$$E[Y]=a\int_0^{2\pi}\cos(\omega t+\theta)\frac{1}{2\pi}\,d\theta=0$$
>(a cosine averages to zero over a full period).

---

## Variance

$$
VAR[X]=\sigma_X^2=E\Big[(X-E[X])^2\Big]
$$
$$
STD[X]=\sigma_X=\sqrt{VAR[X]}
$$
- All variance properties from the discrete case carry over unchanged.

>[!Example]
>**Variance of Gaussian** (see Gaussian section below): ${}VAR[X]=\sigma^2{}$ — the parameter ${}\sigma^2{}$ **is** the variance.

---

## Moments

- **${}n{}$-th (raw) moment:** ${}E[X^n]=\int_{-\infty}^{\infty}x^n f_X(x)\,dx{}$
- **${}n{}$-th central moment:** ${}E[(X-E[X])^n]=\int_{-\infty}^{\infty}(x-E[X])^n f_X(x)\,dx{}$
- Mean = 1st moment; Variance = 2nd central moment.
- Moments are constants summarizing the pdf; under some conditions knowing all moments = knowing the pdf.

---

## Minimum Mean Squared Error (MMSE) Estimation

- Treat the mean as a "best guess" ${}c{}$ of ${}X{}$. Mean squared error:
$$
MSE(c)=E[(X-c)^2]=\int_{-\infty}^{\infty}(x-c)^2 f_X(x)\,dx
$$
- Minimize by setting the derivative to zero:
$$
\frac{d}{dc}MSE(c)=-2\int(x-c)f_X(x)\,dx=-2E[X]+2c=0\quad\Rightarrow\quad c=E[X]
$$
>[!note] Key insight
>- The **mean minimizes the mean squared error** — it is the best constant estimate.
>- The **variance is the minimum MSE** achieved by the best guess.

---

## Important Continuous RVs

### 1. Uniform on [a, b]
$$
f_X(x)=\frac{1}{b-a}\ (a\le x\le b),\qquad F_X(x)=\frac{x-a}{b-a}
$$
$$
E[X]=\frac{a+b}{2},\qquad VAR[X]=\frac{(b-a)^2}{12}
$$

### 2. Exponential
$$
f_X(x)=\lambda e^{-\lambda x}u(x),\qquad F_X(x)=(1-e^{-\lambda x})u(x)
$$
$$
E[X]=\frac{1}{\lambda},\qquad VAR[X]=\frac{1}{\lambda^2}
$$
- ${}\lambda{}$ = **rate** of events. Models time between random events (typhoons, customers arriving, etc.).

#### Memoryless property
$$
P[X>t+h\mid X>t]=\frac{P[X>t+h]}{P[X>t]}=\frac{e^{-\lambda(t+h)}}{e^{-\lambda t}}=e^{-\lambda h}=P[X>h]
$$
- The future lifetime is **independent of how long it has already survived** — an old device is as good as a new one.

#### Geometric → Exponential limit
- Split a unit interval into ${}n{}$ subintervals; event per subinterval with prob ${}\lambda/n{}$.
- ${}M={}$ # subintervals until first event is **geometric**; actual time ${}X=M/n{}$.
$$
P[X>t]=P[M>nt]=\Big(1-\frac{\lambda}{n}\Big)^{nt}\ \xrightarrow{n\to\infty}\ e^{-\lambda t}
$$

using:
$$
\lim_{ n \to \infty } \left[ \left( 1-\frac{x}{n} \right) \right]^n = e^x 
$$
- The **exponential RV is the continuous limit of the geometric RV**.

### 3. Gaussian (Normal)
- Models quantities clustered around a mean ${}m{}$.
$$
f_X(x)=\frac{1}{\sqrt{2\pi}\sigma}e^{-\frac{(x-m)^2}{2\sigma^2}}
$$
- ${}m={}$ mean (center/symmetry), ${}\sigma={}$ standard deviation (spread); ${}\sigma^2={}$ variance.
- Applications: noise voltages, Brownian motion, thermal voltage across a resistor.

#### Standard (normalized) Gaussian CDF: ${}\Phi(x){}$
$$
\Phi(x)=P[X\le x]=\frac{1}{\sqrt{2\pi}}\int_{-\infty}^{x}e^{-t^2/2}\,dt \qquad (m=0,\ \sigma=1)
$$
- **No closed form** — computed numerically.
- For a general Gaussian ${}Y{}$ with mean ${}m{}$ and std ${}\sigma{}$:
$$
F_Y(y)=\Phi\Big(\frac{y-m}{\sigma}\Big)
$$
- **Standardization:** for any Gaussian ${}X\sim(m,\sigma){}$, ${}Z=\frac{X-m}{\sigma}{}$ is standard normal (mean 0, std 1).

#### Q-function (survival function)
$$
Q(x)=P[X>x]\qquad (X\text{ standard normal})
$$
- Relationships:
$$
Q(x)=1-\Phi(x),\qquad Q(x)=\Phi(-x)
$$
- For general Gaussian ${}Y{}$:
$$
P[Y>y]=Q\Big(\frac{y-m}{\sigma}\Big)
$$

>[!Example]
>Communication system: ${}Y=av+N{}$ with noise ${}N\sim\mathcal N(0,\sigma=2){}$, ${}a=10^{-2}{}$. Find minimum ${}v{}$ so ${}P[Y<0]\le 10^{-6}{}$.
>$$P[Y<0]=P[N<-av]=\Phi\Big(\frac{-av}{\sigma}\Big)\le 10^{-6}\ \Rightarrow\ v\ge-\frac{\sigma}{a}\Phi^{-1}(10^{-6})\approx 950.7$$

---

## Python (scipy.stats)

```python
from scipy import stats
import numpy as np

# Gaussian
stats.norm.cdf(x, loc=m, scale=sd)   # Φ
stats.norm.sf(x)                     # Q-function (survival)
stats.norm.ppf(y)                    # inverse cdf
stats.norm.isf(y)                    # inverse survival

# Continuous RV classes
stats.expon.rvs(scale=1/lam, size=n)      # Exponential
stats.uniform.rvs(loc=a, scale=b-a)       # Uniform
stats.norm.rvs(loc=m, scale=sigma)        # Gaussian
stats.laplace.rvs(scale=1/alpha)          # Laplacian
stats.gamma.rvs(a=alpha, scale=1/lam)     # Gamma

# Useful: plot limits covering 98% of probability
x = np.linspace(stats.norm.ppf(0.01), stats.norm.ppf(0.99))
plt.plot(x, stats.norm.pdf(x))
```
   for i in 01 02 03 04 05 06 07 08; do
     ./mlfq < pa2_given_io/in$i.txt > myout$i.txt
     if diff -q myout$i.txt pa2_given_io/out$i.txt >/dev/null; then
       echo "in$i OK"
     else
       echo "in$i DIFF"
       diff --side-by-side myout$i.txt pa2_given_io/out$i.txt | head -20
     fi
   done