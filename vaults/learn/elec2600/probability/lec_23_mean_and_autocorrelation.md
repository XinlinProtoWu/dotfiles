# Lecture 23: Mean and Autocorrelation of a Random Process

> **Big picture.** A random process has a **mean function** $m_X(t)$ and a **variance function** — ordinary moments computed across the ensemble at each time. To describe how the process at one time relates to itself at another time, we use the **autocorrelation** $R_X(t_1,t_2)$ and the **autocovariance** $C_X(t_1,t_2)$. For i.i.d. processes the covariance is a spike at zero lag; for i.s.i. processes it grows like the shared history, $\sigma^2\min(m,n)$. A **Gaussian process** is completely specified by these two functions, and the **Wiener process** is the canonical continuous-time example.

---

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. Each is linked at its **first use** below.

**Descriptions:** [[terms/autocorrelation]] · [[terms/isi-process]] · [[terms/iid-process]]

**Processes:** [[terms/gaussian-process]] · [[terms/wiener-process]]

---

## Learning goals

By the end of this lecture you should be able to:

1. Compute the mean and variance functions of a process.
2. Compute autocorrelation and autocovariance functions.
3. Relate covariance, correlation, and variance.
4. Derive the covariance of i.i.d. and i.s.i. processes.
5. Explain why the i.s.i. covariance is $\sigma^2\min(m,n)$.
6. Write the density of a Gaussian process from its mean and covariance.
7. Work with the Wiener process and its covariance $\sigma^2\min(t_1,t_2)$.

---

## 1. Mean and variance functions

The **mean function** is the ensemble average at time $t$:

$$
\boxed{
m_X(t)=E[X(t)]=\int x\,f_{X(t)}(x)\,dx.
}
$$

The **variance function** is

$$
\boxed{
\operatorname{Var}[X(t)]
=E\left[(X(t)-m_X(t))^2\right]
=\int (x-m_X(t))^2 f_{X(t)}(x)\,dx
=E[X(t)^2]-m_X(t)^2.
}
$$

Both are functions of time, not numbers. They average over the ensemble, not over time in one realization.

> [!warning] Ensemble average versus time average
> $m_X(t)$ is the average across all possible sample paths at the same instant $t$. It is **not** the average of one recorded waveform over time. The two coincide only under ergodicity, which is a separate idea.

**In plain words.** Imagine freezing a video at one frame and averaging the picture brightness over many different recordings. That is the ensemble mean at that instant. The variance says how spread out the brightness is from recording to recording at that same instant.

---

## 2. Random amplitude sinusoid

Take

$$
X(t,\xi)=\xi\cos(2\pi t),
\qquad \xi\sim\text{Uniform}[-1,1].
$$

Then

$$
E[\xi]=0,
\qquad
E[\xi^2]=\frac{(1-(-1))^2}{12}=\frac{4}{12}=\frac13.
$$

### Mean

$$
m_X(t)=E[\xi\cos(2\pi t)]=E[\xi]\cos(2\pi t)=0.
$$

### Variance

$$
\begin{aligned}
\operatorname{Var}[X(t)]
&=E[X(t)^2]-m_X(t)^2\\
&=E[\xi^2\cos^2(2\pi t)]\\
&=E[\xi^2]\cos^2(2\pi t)\\
&=\frac13\cos^2(2\pi t).
\end{aligned}
$$

![[Part4.pdf#page=51]]
*Figure: three realizations (top) and the mean and variance functions (bottom). (`Part4.pdf` p. 51)*

**In plain words.** The volume knob is equally likely to be positive or negative, so on average the signal cancels to zero at every instant. But the *size* of the signal still depends on the knob: when the cosine is at a peak, the spread is largest; when the cosine crosses zero, every realization is near zero and the spread vanishes.

**Example (traced).** At $t=0$,

$$
\operatorname{Var}[X(0)]=\frac13\cos^2(0)=\frac13.
$$

At $t=\tfrac14$,

$$
\operatorname{Var}\left[X\left(\tfrac14\right)\right]
=\frac13\cos^2\left(\frac{\pi}{2}\right)=0.
$$

This matches the intuition: at $t=\tfrac14$ every sinusoid passes through zero.

---

## 3. Random phase sinusoid

Take

$$
X(t,\xi)=\cos(2\pi t+\xi),
\qquad \xi\sim\text{Uniform}[-\pi,\pi].
$$

### Mean

$$
\begin{aligned}
m_X(t)
&=E[\cos(2\pi t+\xi)]\\
&=\frac{1}{2\pi}\int_{-\pi}^{\pi}\cos(2\pi t+\xi)\,d\xi\\
&=0.
\end{aligned}
$$

The integral of a cosine over a full period is zero.

### Variance

$$
\begin{aligned}
\operatorname{Var}[X(t)]
&=E[X(t)^2]\\
&=\frac{1}{2\pi}\int_{-\pi}^{\pi}\cos^2(2\pi t+\xi)\,d\xi\\
&=\frac{1}{2\pi}\int_{-\pi}^{\pi}
\left(\frac12+\frac12\cos(4\pi t+2\xi)\right)d\xi\\
&=\frac12.
\end{aligned}
$$

![[Part4.pdf#page=52]]
*Figure: realizations and the constant mean/variance functions. (`Part4.pdf` p. 52)*

**In plain words.** The phase is completely unknown, so at any fixed clock time the wave is just as likely to be high as low, and the average cancels. But the wave always has the same strength — it is a pure cosine — so its squared value averages to one half everywhere.

**Example (traced).** At any $t$, $X(t)$ is a cosine with a uniform phase, so

$$
P[X(t)>0]=\frac12,
\qquad
E[X(t)^2]=\frac12.
$$

The variance is therefore $1/2$ at every instant, not just on average.

---

## 4. Mean and variance of i.i.d. and i.s.i. processes

### 4.1 i.i.d. process

If $X_n$ is i.i.d. with mean $m$ and variance $\sigma^2$, then

$$
\boxed{
m_X(n)=m,
\qquad
\operatorname{Var}[X_n]=\sigma^2.
}
$$

Both are constant in $n$. The proof is immediate: every sample has the same marginal density $f(x)$.

### 4.2 Sum process

If

$$
S_n=\sum_{i=1}^{n}X_i
$$

with the $X_i$ i.i.d., mean $\mu$, variance $\sigma^2$, then

$$
\boxed{
m_S(n)=E[S_n]=n\mu,
}
$$

$$
\boxed{
\operatorname{Var}[S_n]=n\sigma^2.
}
$$

Both grow **linearly** with time.

![[Part4.pdf#page=54]]
*Figure: the mean and variance of a sum process grow linearly. (`Part4.pdf` p. 54)*

**In plain words.** If each step has average size $\mu$, then after $n$ steps your average position is $n\mu$. If each step has uncertainty $\sigma^2$ and the steps are independent, the uncertainties add, so the spread after $n$ steps is $n\sigma^2$. The walk drifts and spreads at the same time.

**Example (traced).** For the binomial counting process, $X_i\sim\text{Bernoulli}(p)$, so

$$
\mu=p,
\qquad
\sigma^2=p(1-p).
$$

Hence

$$
m_S(n)=np,
\qquad
\operatorname{Var}[S_n]=np(1-p),
$$

which agrees with the binomial formulas.

---

## 5. Autocorrelation and autocovariance

The **autocorrelation function** is

$$
\boxed{
R_X(t_1,t_2)=E[X(t_1)X(t_2)]
=\iint xy\,f_{X(t_1),X(t_2)}(x,y)\,dx\,dy.
}
$$

The **autocovariance function** (often just **covariance function**) is

$$
\begin{aligned}
C_X(t_1,t_2)
&=\operatorname{Cov}(X(t_1),X(t_2))\\
&=E[(X(t_1)-m_X(t_1))(X(t_2)-m_X(t_2))]\\
&=R_X(t_1,t_2)-m_X(t_1)m_X(t_2).
\end{aligned}
$$

Setting $t_1=t_2=t$ recovers the variance:

$$
\boxed{
C_X(t,t)=\operatorname{Var}[X(t)].
}
$$

The **correlation coefficient** is

$$
\boxed{
\rho_X(t_1,t_2)
=\frac{C_X(t_1,t_2)}
{\sqrt{C_X(t_1,t_1)\,C_X(t_2,t_2)}}.
}
$$

> [!note] Terminology
> The covariance function is also called the **autocovariance function**. “Autocorrelation” usually means $R_X$; “autocovariance” means $C_X$. Always check which one a formula is using.

> [!warning] Two processes can share these functions
> It is possible for two genuinely different random processes to have the same mean, autocorrelation, and covariance functions. These functions summarise second-order behaviour, not the full distribution.

**In plain words.** The autocorrelation asks: if the process is high now, is it likely to be high a moment later? A large positive value means the two samples tend to move together; a value near zero means the later sample carries little memory of the earlier one. The covariance subtracts the average levels first, so it measures *fluctuations* around the mean rather than the mean itself.

---

## 6. Autocorrelation of the random amplitude sinusoid

For

$$
X(t)=\xi\cos(2\pi t),
\qquad
\xi\sim\text{Uniform}[-1,1],
$$

we found $m_X(t)=0$, so

$$
R_X(t_1,t_2)=C_X(t_1,t_2).
$$

Compute:

$$
\begin{aligned}
R_X(t_1,t_2)
&=E[X(t_1)X(t_2)]\\
&=E[\xi\cos(2\pi t_1)\,\xi\cos(2\pi t_2)]\\
&=E[\xi^2]\cos(2\pi t_1)\cos(2\pi t_2)\\
&=\frac13\cos(2\pi t_1)\cos(2\pi t_2).
\end{aligned}
$$

![[Part4.pdf#page=57]]
*Figure: the autocorrelation surface of the random amplitude sinusoid. (`Part4.pdf` p. 57)*

**In plain words.** The only randomness is the volume knob, and the same knob setting multiplies both samples. So the two samples are perfectly linked in *shape*: if the cosine has the same sign at both times, they tend to have the same sign; if the cosine changes sign between them, they tend to have opposite signs. The strength is the average squared knob setting, $1/3$.

**Example (traced).** At $t_1=0$, $t_2=0$,

$$
R_X(0,0)=\frac13\cos(0)\cos(0)=\frac13,
$$

which equals the variance at $t=0$. At $t_1=0$, $t_2=\tfrac14$,

$$
R_X\left(0,\tfrac14\right)
=\frac13\cos(0)\cos\left(\frac{\pi}{2}\right)=0.
$$

The two samples are uncorrelated because one is always zero.

---

## 7. Autocorrelation of the random phase sinusoid

For

$$
X(t)=\cos(2\pi t+\xi),
\qquad
\xi\sim\text{Uniform}[-\pi,\pi],
$$

again $m_X(t)=0$, so $R_X=C_X$. Using

$$
\cos a\cos b=\frac12\cos(a-b)+\frac12\cos(a+b),
$$

with $a=2\pi t_1+\xi$ and $b=2\pi t_2+\xi$,

$$
\begin{aligned}
R_X(t_1,t_2)
&=E[\cos(2\pi t_1+\xi)\cos(2\pi t_2+\xi)]\\
&=\frac12E[\cos(2\pi(t_1-t_2))]\\
&\quad+\frac12E[\cos(2\pi(t_1+t_2)+2\xi)]\\
&=\frac12\cos(2\pi(t_1-t_2)).
\end{aligned}
$$

The second term averages to zero because $2\xi$ runs uniformly over a full $2\pi$ period.

![[Part4.pdf#page=58]]
*Figure: the autocorrelation depends only on $t_1-t_2$. (`Part4.pdf` p. 58)*

**In plain words.** Two samples of the same cosine, taken $\tau$ seconds apart, are separated by a fixed phase $2\pi\tau$ no matter where the random starting phase happens to be. The unknown starting phase cancels when you subtract the times, so the correlation depends only on the gap. If the gap is a full period, the samples line up perfectly again; if it is a half period, they are opposite.

**Example (traced).** At zero lag,

$$
R_X(t,t)=\frac12\cos(0)=\frac12,
$$

which is the variance. At a lag of one quarter period, $\tau=\tfrac14$,

$$
R_X\left(t,t+\tfrac14\right)
=\frac12\cos\left(\frac{\pi}{2}\right)=0.
$$

At a lag of one full period, $\tau=1$,

$$
R_X(t,t+1)=\frac12\cos(2\pi)=\frac12.
$$

---

## 8. Covariance of an i.i.d. process

If $X_n$ is i.i.d., then samples at different times are independent, so

$$
\boxed{
C_X(m,n)=
\begin{cases}
\sigma^2, & m=n,\\
0, & m\ne n,
\end{cases}
}
$$

or, using the Kronecker delta,

$$
\boxed{
C_X(m,n)=\sigma^2\delta(m-n),
\qquad
\delta(k)=
\begin{cases}
1, & k=0,\\
0, & k\ne0.
\end{cases}
}
$$

Equivalently,

$$
\boxed{
R_X(m,n)=\sigma^2\delta(m-n)+\mu^2,
}
$$

where $\mu=E[X_n]$.

![[Part4.pdf#page=60]]
*Figure: the autocorrelation of an i.i.d. process is a single spike at zero lag. (`Part4.pdf` p. 60)*

**In plain words.** An i.i.d. process has no memory at all: once you know today's value, you still know nothing about tomorrow's. So the only time the two samples are correlated is when they are the same sample, at zero lag. Everywhere else the covariance is exactly zero.

**Example (traced).** For white Gaussian noise with $\mu=0$ and $\sigma^2=4$,

$$
C_X(m,n)=4\delta(m-n),
\qquad
R_X(m,n)=4\delta(m-n).
$$

At lag $1$,

$$
R_X(n,n+1)=0.
$$

---

## 9. Covariance of an i.s.i. process

For an i.s.i. process with $S_0=0$, increments variance $\sigma^2$ per unit time,

$$
\boxed{
C_S(m,n)=\sigma^2\min(m,n).
}
$$

### Proof for $m\ge n$

Write $S_m=S_n+(S_m-S_n)$. Then

$$
\begin{aligned}
C_S(m,n)
&=E[S_mS_n]-E[S_m]E[S_n]\\
&=E[(S_n+(S_m-S_n))S_n]-E[S_m]E[S_n]\\
&=E[S_n^2]+E[(S_m-S_n)S_n]-E[S_m]E[S_n].
\end{aligned}
$$

By independent increments, $S_m-S_n$ is independent of $S_n$, so

$$
E[(S_m-S_n)S_n]=E[S_m-S_n]E[S_n].
$$

Therefore

$$
\begin{aligned}
C_S(m,n)
&=E[S_n^2]+E[S_m-S_n]E[S_n]-E[S_m]E[S_n]\\
&=E[S_n^2]+(E[S_m]-E[S_n])E[S_n]-E[S_m]E[S_n]\\
&=E[S_n^2]-E[S_n]^2\\
&=\operatorname{Var}[S_n]\\
&=\sigma^2 n.
\end{aligned}
$$

A symmetric argument for $n\ge m$ gives $\sigma^2m$. Hence

$$
C_S(m,n)=\sigma^2\min(m,n).
$$

![[Part4.pdf#page=62]]
*Figure: $S_{25}$ and $S_{50}$ share the first $25$ steps, so their covariance is the variance of the shared part. (`Part4.pdf` p. 62)*

**In plain words.** Two positions of the walk share exactly the steps that both have already taken. If one checkpoint is at time $25$ and the other at time $50$, the common history is the first $25$ steps. The later part of the walk is fresh noise, independent of everything before, so it contributes nothing to the covariance. The covariance is therefore the variance of the shorter, shared stretch.

### Important examples

| Process | Mean | Variance | Covariance |
|---|---|---|---|
| Binomial counting | $np$ | $np(1-p)$ | $p(1-p)\min(n_1,n_2)$ |
| Poisson counting | $\lambda t$ | $\lambda t$ | $\lambda\min(t_1,t_2)$ |

**Example (traced).** For a Poisson process with $\lambda=3$ arrivals per minute, the covariance between the counts at $t_1=2$ and $t_2=5$ is

$$
C_N(2,5)=3\min(2,5)=3(2)=6.
$$

The variance at $t=2$ is $3(2)=6$, so the covariance equals the variance of the earlier count. The extra three minutes contribute independent noise.

> [!important] Shared history, not elapsed time
> The covariance is governed by $\min(m,n)$, the length of the common past. It does **not** grow with the longer time.

---

## 10. Gaussian random processes

A process is **Gaussian** if every finite set of samples is jointly Gaussian. For sample times $t_1,\dots,t_k$, the $k$-th order density is

$$
\boxed{
f_{X(t_1),\dots,X(t_k)}(x_1,\dots,x_k)
=
\frac{1}{(2\pi)^{k/2}\lvert C\rvert^{1/2}}
\exp\left[-\frac12(\mathbf x-\mathbf m)^T
C^{-1}(\mathbf x-\mathbf m)\right],
}
$$

where

$$
\mathbf x=
\begin{bmatrix}
x_1\\
\vdots\\
x_k
\end{bmatrix},
\qquad
\mathbf m=
\begin{bmatrix}
m_X(t_1)\\
\vdots\\
m_X(t_k)
\end{bmatrix},
$$

and

$$
C=
\begin{bmatrix}
C_X(t_1,t_1) & \cdots & C_X(t_1,t_k)\\
\vdots & \ddots & \vdots\\
C_X(t_k,t_1) & \cdots & C_X(t_k,t_k)
\end{bmatrix}.
$$

![[Part4.pdf#page=64]]
*Figure: a Gaussian process is specified by its mean vector and covariance matrix. (`Part4.pdf` p. 64)*

> [!important] Gaussian processes are easy
> A Gaussian process is **completely specified** by its mean function and its covariance function. Once you know those, every joint density is a multivariate Gaussian with the corresponding mean vector and covariance matrix.

---

## 11. The Wiener process

The **Wiener process** $W(t)$ is the continuous-time Gaussian i.s.i. process with

$$
\boxed{
m_W(t)=0,
\qquad
C_W(t_1,t_2)=\sigma^2\min(t_1,t_2).
}
$$

It models Brownian motion: the random jiggling of a particle suspended in a fluid, driven by many rapid molecular impacts. It is also used for stock prices and other slowly wandering quantities.

![[Part4.pdf#page=65]]
*Figure: a realization of a Wiener process. (`Part4.pdf` p. 65)*

**In plain words.** The Wiener process is a random walk in continuous time, with infinitely many infinitesimal steps. It has no preferred direction, so its average is zero, and its spread grows with the square root of time because variances add. Two times share the history up to the earlier time, so their covariance is the variance of that shared history.

### Example (traced)

Let $W(t)$ be a Wiener process with $\sigma^2=2$. Find the marginal density of $W(2)$ and the joint density of $W(2)$ and $W(5)$.

Because the process is Gaussian, only means and covariances are needed.

**Marginal of $W(2)$:**

$$
E[W(2)]=0,
\qquad
\operatorname{Var}[W(2)]=\sigma^2(2)=4.
$$

So

$$
W(2)\sim\mathcal N(0,4),
$$

$$
f_{W(2)}(w)=\frac{1}{\sqrt{2\pi\cdot4}}
\exp\left(-\frac{w^2}{8}\right)
=\frac{1}{2\sqrt{2\pi}}
\exp\left(-\frac{w^2}{8}\right).
$$

**Joint of $W(2)$ and $W(5)$:** the covariance matrix is

$$
C=
\begin{bmatrix}
C_W(2,2) & C_W(2,5)\\
C_W(5,2) & C_W(5,5)
\end{bmatrix},
$$

$$
C=
\begin{bmatrix}
4 & 4\\
4 & 10
\end{bmatrix}.
$$

The determinant is

$$
\lvert C\rvert=4(10)-4(4)=40-16=24.
$$

The inverse is

$$
C^{-1}
=\frac{1}{24}
\begin{bmatrix}
10 & -4\\
-4 & 4
\end{bmatrix}.
$$

Define the quadratic form

$$
Q=
\begin{bmatrix}w_2 & w_5\end{bmatrix}
C^{-1}
\begin{bmatrix}w_2\\ w_5\end{bmatrix}.
$$

Then

$$
f_{W(2),W(5)}(w_2,w_5)
=
\frac{1}{2\pi\sqrt{24}}
\exp\left(-\frac{Q}{2}\right).
$$

The quadratic form simplifies to

$$
\begin{aligned}
Q&=
\begin{bmatrix}w_2 & w_5\end{bmatrix}
C^{-1}
\begin{bmatrix}w_2\\ w_5\end{bmatrix}\\
&=
\frac{10w_2^2-8w_2w_5+4w_5^2}{24}\\
&=
\frac{5w_2^2-4w_2w_5+2w_5^2}{12}.
\end{aligned}
$$

So

$$
f_{W(2),W(5)}(w_2,w_5)
=
\frac{1}{2\pi\sqrt{24}}
\exp\left(-\frac{5w_2^2-4w_2w_5+2w_5^2}{24}\right).
$$

**In plain words.** The value at five seconds is the value at two seconds plus three seconds of fresh noise. That is why the two are strongly correlated but not identical: the early value is locked inside the later one, and the covariance equals the earlier variance, $4$. The later variance is larger, $10$, because it includes both the early stretch and the extra three seconds.

> [!note] Same covariance as the Poisson process
> The Wiener process and the Poisson process have the same covariance function, $\sigma^2\min(t_1,t_2)$, even though their sample paths look completely different. Second-order information does not determine the whole process.

---

## 12. Common mistakes

1. **Treating $m_X(t)$ as the time average of one realization.** It is the ensemble average at a fixed time.
2. **Forgetting that $m_X(t)$ is a function.** It can vary with $t$; only stationary processes have constant mean.
3. **Confusing $R_X$ and $C_X$.** They differ by $m_X(t_1)m_X(t_2)$.
4. **Using $C_X(t_1,t_2)=\operatorname{Var}[X(t_1)]$ for unequal times.** That is only true when the process has no correlation between the two times.
5. **Thinking zero correlation means independence.** It only means no linear relationship; independence is stronger.
6. **Using $\sigma^2\max(m,n)$ for an i.s.i. process.** It is $\sigma^2\min(m,n)$: only the shared past counts.
7. **Thinking the Wiener covariance grows with the later time.** It grows with the *earlier* time.
8. **Believing mean plus covariance specifies every process.** That is special to Gaussian processes.

---

## 13. 60-second summary

Mean and variance functions:

$$
\boxed{
m_X(t)=E[X(t)],
\qquad
\operatorname{Var}[X(t)]=E[X(t)^2]-m_X(t)^2.
}
$$

Autocorrelation:

$$
\boxed{
R_X(t_1,t_2)=E[X(t_1)X(t_2)].
}
$$

Autocovariance:

$$
\boxed{
C_X(t_1,t_2)=R_X(t_1,t_2)-m_X(t_1)m_X(t_2).
}
$$

Variance as a special case:

$$
\boxed{
C_X(t,t)=\operatorname{Var}[X(t)].
}
$$

i.i.d. process:

$$
\boxed{
C_X(m,n)=\sigma^2\delta(m-n),
\qquad
R_X(m,n)=\sigma^2\delta(m-n)+\mu^2.
}
$$

i.s.i. process:

$$
\boxed{
C_S(m,n)=\sigma^2\min(m,n).
}
$$

Binomial:

$$
\boxed{
m_S(n)=np,
\qquad
\operatorname{Var}[S_n]=np(1-p),
\qquad
C_S(n_1,n_2)=p(1-p)\min(n_1,n_2).
}
$$

Poisson:

$$
\boxed{
m_N(t)=\lambda t,
\qquad
\operatorname{Var}[N(t)]=\lambda t,
\qquad
C_N(t_1,t_2)=\lambda\min(t_1,t_2).
}
$$

Gaussian process density:

$$
\boxed{
f(\mathbf x)=\frac{1}{(2\pi)^{k/2}\lvert C\rvert^{1/2}}
\exp\left[-\frac12(\mathbf x-\mathbf m)^T
C^{-1}(\mathbf x-\mathbf m)\right].
}
$$

Wiener process:

$$
\boxed{
m_W(t)=0,
\qquad
C_W(t_1,t_2)=\sigma^2\min(t_1,t_2).
}
$$

Continue with [[lec_24_stationary_random_processes]].
