# Lecture 25: Further Examples and Multiple Random Processes

> **Big picture.** This lecture collects important worked processes — a random step, the **random telegraph signal**, **shot noise**, and the **Wiener process** — and then studies **two processes at once**. For two processes we need **cross-correlation** and **cross-covariance**, which measure how one process at time $t_1$ relates to another at time $t_2$. Independence implies zero cross-covariance, but zero cross-covariance does not imply independence.

> [!note] Source note
> `Part4.pdf` has no printed “Lecture 25” title slide. The material on pp. 89–103 (additional examples plus multiple random processes) is treated here as Lecture 25.

---

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. Each is linked at its **first use** below.

**Processes:** [[terms/random-process]] · [[terms/poisson-process]] · [[terms/wiener-process]]

**Two-process descriptions:** [[terms/cross-correlation]] · [[terms/autocorrelation]]

---

## Learning goals

By the end of this lecture you should be able to:

1. Find the pmf, mean, and variance of a random step.
2. Analyse the random telegraph signal.
3. Compute even/odd probabilities for a Poisson random variable.
4. Derive the mean and autocorrelation of the telegraph signal.
5. Compute the mean of a shot-noise process by conditioning.
6. Construct the Wiener process as a limit of random walks.
7. Derive the Wiener covariance $\sigma^2\min(t_1,t_2)$.
8. Define independence, cross-correlation, and cross-covariance for two processes.
9. Compute cross-covariance for a random-phase pair and a signal-plus-noise system.

---

## 1. Random step

Let $T$ be uniform on $[0,1]$, and let $X(t)$ be the unit step that switches on at time $T$:

$$
X(t)=u(t-T)=
\begin{cases}
0, & t<T,\\
1, & t\ge T.
\end{cases}
$$

![[Part4.pdf#page=89]]
*Figure: a unit step whose switching time $T$ is uniform on $[0,1]$. (`Part4.pdf` p. 89)*

For a fixed $t$, $X(t)$ is discrete (only $0$ or $1$).

- If $t<0$, the step has certainly not started yet:

$$
P[X(t)=0]=1,
\qquad
P[X(t)=1]=0.
$$

- If $t>1$, the step has certainly started:

$$
P[X(t)=0]=0,
\qquad
P[X(t)=1]=1.
$$

- If $0\le t\le1$,

$$
P[X(t)=0]=P[T>t]=1-t,
$$

$$
P[X(t)=1]=P[T\le t]=t.
$$

So the pmf changes with $t$.

**In plain words.** A lamp is switched on at a random moment during the first hour, and the switch time is equally likely anywhere in that hour. Before the hour starts the lamp is certainly off; after the hour ends it is certainly on. In between, the chance it is already on is exactly the fraction of the hour that has passed. The possible values are always just off and on, but their probabilities slide with the clock.

### Mean and variance

Since $X(t)$ is $0$ or $1$, its mean is simply the probability that it equals $1$:

$$
m_X(t)=E[X(t)]=P[X(t)=1].
$$

Also,

$$
E[X(t)^2]=P[X(t)=1],
$$

so

$$
\operatorname{Var}[X(t)]
=E[X(t)^2]-m_X(t)^2
=P[X(t)=1]-P[X(t)=1]^2.
$$

Therefore

$$
\boxed{
m_X(t)=
\begin{cases}
0, & t<0,\\
t, & 0\le t\le1,\\
1, & t>1,
\end{cases}
}
$$

and

$$
\boxed{
\operatorname{Var}[X(t)]=
\begin{cases}
0, & t<0,\\
t-t^2, & 0\le t\le1,\\
0, & t>1.
\end{cases}
}
$$

![[Part4.pdf#page=90]]
*Figure: the mean ramps up linearly, and the variance is a parabola peaking in the middle. (`Part4.pdf` p. 90)*

**In plain words.** Before the hour starts, and after it ends, there is no uncertainty: you know the lamp's state exactly, so the variance is zero. In the middle of the hour the state is genuinely uncertain, and the uncertainty is largest halfway through, when it is a fifty-fifty guess. At the very start or very end of the hour one outcome is almost certain again.

**Example (traced).** At $t=\tfrac12$,

$$
m_X\left(\tfrac12\right)=\frac12,
$$

$$
\operatorname{Var}\left[X\left(\tfrac12\right)\right]
=\frac12-\left(\frac12\right)^2
=\frac12-\frac14
=\frac14.
$$

This is the maximum possible variance for a $0$–$1$ random variable.

> [!warning] Slide typo
> The slide's mean plot labels the right-hand branch “$t>0$” but it should be “$t>1$”. The mean is $1$ only after the step has certainly occurred.

---

## 2. Random telegraph signal

The **random telegraph signal** $X(t)$ takes values $\pm1$ and changes polarity at every discontinuity of a Poisson counting process $N(t)$.

![[Part4.pdf#page=91]]
*Figure: a Poisson event flips the sign of the telegraph signal. (`Part4.pdf` p. 91)*

Assume

$$
P[X(0)=1]=P[X(0)=-1]=\frac12.
$$

Then for all $t$,

$$
P[X(t)=1]=P[X(t)=-1]=\frac12.
$$

**In plain words.** A switch sits in one of two positions, $+1$ or $-1$, and every time a Poisson “ping” arrives it flips to the other position. The pings arrive at random, independently of the switch. Since the initial position is a fair coin and every ping merely flips it, the switch is still a fair coin at every later time.

### Proof

Condition on the initial state:

$$
\begin{aligned}
P[X(t)=1]
&=P[X(t)=1\mid X(0)=1]P[X(0)=1]\\
&\quad+P[X(t)=1\mid X(0)=-1]P[X(0)=-1].
\end{aligned}
$$

Starting from $+1$, the signal is $+1$ at time $t$ exactly when the number of flips is even:

$$
P[X(t)=1\mid X(0)=1]
=P[N(t)\text{ even}]=\frac12\left(1+e^{-2\lambda t}\right).
$$

Starting from $-1$, the signal is $+1$ exactly when the number of flips is odd:

$$
P[X(t)=1\mid X(0)=-1]
=P[N(t)\text{ odd}]=\frac12\left(1-e^{-2\lambda t}\right).
$$

Substituting,

$$
\begin{aligned}
P[X(t)=1]
&=\frac12\left(1+e^{-2\lambda t}\right)\frac12
+\frac12\left(1-e^{-2\lambda t}\right)\frac12\\
&=\frac14\left(1+e^{-2\lambda t}+1-e^{-2\lambda t}\right)\\
&=\frac12.
\end{aligned}
$$

The same argument gives $P[X(t)=-1]=\tfrac12$.

---

## 3. Even and odd probabilities for a Poisson random variable

Let $N\sim\text{Poisson}(\alpha)$:

$$
p_N(n)=\frac{\alpha^n}{n!}e^{-\alpha},
\qquad n=0,1,2,\dots
$$

Find $P[N\text{ even}]$ and $P[N\text{ odd}]$.

Split the exponential series into even and odd terms:

$$
e^{\alpha}=\sum_{k=0}^{\infty}\frac{\alpha^k}{k!},
$$

$$
e^{-\alpha}=\sum_{k=0}^{\infty}\frac{(-\alpha)^k}{k!}.
$$

Adding the two series cancels the odd powers and doubles the even ones:

$$
e^{\alpha}+e^{-\alpha}
=2\sum_{k\text{ even}}\frac{\alpha^k}{k!}.
$$

Therefore

$$
P[N\text{ even}]
=e^{-\alpha}\sum_{k\text{ even}}\frac{\alpha^k}{k!}
=e^{-\alpha}\cdot\frac{e^{\alpha}+e^{-\alpha}}{2}
=\frac12+\frac12e^{-2\alpha}.
$$

Since the probabilities must sum to one,

$$
P[N\text{ odd}]
=1-P[N\text{ even}]
=\frac12-\frac12e^{-2\alpha}.
$$

Thus

$$
\boxed{
P[N\text{ even}]=\frac12\left(1+e^{-2\alpha}\right),
\qquad
P[N\text{ odd}]=\frac12\left(1-e^{-2\alpha}\right).
}
$$

**In plain words.** A Poisson count is usually either even or odd, but for large average counts the parity becomes a fair coin because the distribution is spread over many integers. The exponential correction is the memory of the average count: if $\alpha$ is small, zero is the most likely outcome, so “even” is more likely than “odd”. As $\alpha$ grows, both probabilities approach one half.

**Example (traced).** If $\alpha=2$,

$$
P[N\text{ even}]=\frac12\left(1+e^{-4}\right)
\approx\frac12(1+0.0183)
\approx0.5092,
$$

$$
P[N\text{ odd}]\approx0.4908.
$$

If $\alpha=0.1$,

$$
P[N\text{ even}]\approx\frac12(1+0.8187)\approx0.9094,
$$

so zero or two or four events is much more likely than an odd count, because zero dominates.

---

## 4. Mean and autocorrelation of the telegraph signal

### Mean

$$
\begin{aligned}
m_X(t)
&=E[X(t)]\\
&=(1)P[X(t)=1]+(-1)P[X(t)=-1]\\
&=\frac12-\frac12\\
&=0.
\end{aligned}
$$

### Autocorrelation

Assume $t_2\ge t_1$; the other case is symmetric. The product $X(t_1)X(t_2)$ is $+1$ if the signal has flipped an even number of times between $t_1$ and $t_2$, and $-1$ if it has flipped an odd number of times. By stationary increments, the number of flips in that gap is $N(t_2-t_1)$. Therefore

$$
\begin{aligned}
R_X(t_1,t_2)
&=(1)P[X(t_1)X(t_2)=1]+(-1)P[X(t_1)X(t_2)=-1]\\
&=P[N(t_2-t_1)\text{ even}]-P[N(t_2-t_1)\text{ odd}]\\
&=\frac12\left(1+e^{-2\lambda(t_2-t_1)}\right)
-\frac12\left(1-e^{-2\lambda(t_2-t_1)}\right)\\
&=e^{-2\lambda(t_2-t_1)}.
\end{aligned}
$$

In general,

$$
\boxed{
R_X(t_1,t_2)=e^{-2\lambda\lvert t_2-t_1\rvert}.
}
$$

![[Part4.pdf#page=93]]
*Figure: the telegraph autocorrelation decays exponentially with the lag. (`Part4.pdf` p. 93)*

**In plain words.** Two readings of the switch taken very close together are almost certainly the same, so their product is almost always $+1$. As the gap grows, more pings can arrive, and the parity of the number of flips becomes a fair coin, so the product averages to zero. The larger the ping rate $\lambda$, the faster the signal forgets its earlier state.

**Example (traced).** If $\lambda=0.5$ and the lag is $1$ second,

$$
R_X(t,t+1)=e^{-2(0.5)(1)}=e^{-1}\approx0.368.
$$

At lag $3$ seconds,

$$
R_X(t,t+3)=e^{-3}\approx0.0498,
$$

so the signal has almost completely forgotten its value three seconds earlier.

Since $m_X(t)=0$, the autocovariance equals the autocorrelation:

$$
C_X(t_1,t_2)=R_X(t_1,t_2).
$$

---

## 5. Shot noise

Photons arrive at a photodetector as a Poisson process. Let $S_i$ be the arrival time of the $i$-th photon, and let each photon produce a current pulse of shape $h(t)$. The total current at time $t$ is the sum of all pulses:

$$
\boxed{
X(t)=\sum_{i=1}^{\infty}h(t-S_i).
}
$$

This is the **shot-noise process**.

![[Part4.pdf#page=94]]
*Figure: overlapping pulses from Poisson arrivals produce a noisy current. (`Part4.pdf` p. 94)*

**In plain words.** Each photon is a tiny drumbeat that makes a decaying echo in the detector. Because photons arrive at random times, the echoes overlap unpredictably, and the total signal at any instant is the sum of however many echoes are still ringing. The result is a crackling noise whose average level depends on how often photons arrive and how long each echo lasts.

### Mean of shot noise

Condition on the number of arrivals $N(t)$ and then average over it:

$$
E[X(t)]=E\left[E[X(t)\mid N(t)]\right].
$$

Given $N(t)=n$,

$$
X(t)=\sum_{j=1}^{n}h(t-S_j).
$$

Conditioned on $N(t)=n$, the arrival times $S_j$ are independent and uniform on $[0,t]$. Therefore

$$
\begin{aligned}
E[h(t-S_j)]
&=\int_0^t h(t-s)f_{S_j}(s)\,ds\\
&=\int_0^t h(t-s)\frac1t\,ds.
\end{aligned}
$$

Substitute $u=t-s$, so $du=-ds$ and the limits become $t$ down to $0$:

$$
E[h(t-S_j)]
=\frac1t\int_0^t h(u)\,du.
$$

Hence

$$
E[X(t)\mid N(t)=n]
=\frac{n}{t}\int_0^t h(u)\,du.
$$

Now average over $N(t)$, whose mean is $\lambda t$:

$$
\begin{aligned}
E[X(t)]
&=\frac{E[N(t)]}{t}\int_0^t h(u)\,du\\
&=\frac{\lambda t}{t}\int_0^t h(u)\,du\\
&=\lambda\int_0^t h(u)\,du.
\end{aligned}
$$

As $t\to\infty$,

$$
\boxed{
E[X(t)]\to\lambda\int_0^{\infty}h(u)\,du.
}
$$

The limiting mean is the arrival rate times the total charge in one pulse.

**In plain words.** At any instant, the average current is the average number of photons arriving per second multiplied by the average contribution of one photon. Each photon's pulse spreads its charge over time, so you add up the whole pulse shape to get the total charge it delivers. More photons or longer pulses both raise the average current.

**Example (traced).** Let

$$
h(t)=e^{-t}u(t),
$$

and let the photon rate be $\lambda=5$ per second. Then

$$
\int_0^{\infty}h(u)\,du
=\int_0^{\infty}e^{-u}\,du
=1,
$$

so the limiting mean current is

$$
E[X(t)]\to5\cdot1=5.
$$

The units are “charge per second” if $h$ has units of current.

---

## 6. Constructing the Wiener process

Divide each unit interval into $m$ equal subintervals. In each subinterval toss a fair coin:

- head: step forward by $\sigma/\sqrt m$,
- tail: step backward by $\sigma/\sqrt m$.

Let $X_i$ be i.i.d. with $P[X_i=\pm1]=\tfrac12$. The position at time $t$ is

$$
\boxed{
W_m(t)=\sum_{i=1}^{\lfloor mt\rfloor}\frac{\sigma}{\sqrt m}X_i.
}
$$

![[Part4.pdf#page=96]]
*Figure: a fine random walk with step size $\sigma/\sqrt m$ converges to the Wiener process. (`Part4.pdf` p. 96)*

### Mean and variance

$$
E[W_m(t)]
=\frac{\sigma}{\sqrt m}\sum_{i=1}^{\lfloor mt\rfloor}E[X_i]
=0.
$$

$$
\begin{aligned}
\operatorname{Var}[W_m(t)]
&=\frac{\sigma^2}{m}
\sum_{i=1}^{\lfloor mt\rfloor}\operatorname{Var}(X_i)\\
&=\frac{\sigma^2}{m}\lfloor mt\rfloor\\
&\to\sigma^2t
\qquad\text{as }m\to\infty.
\end{aligned}
$$

![[Part4.pdf#page=97]]
*Figure: the variance converges to $\sigma^2t$. (`Part4.pdf` p. 97)*

By the central limit theorem, $W_m(t)$ is approximately Gaussian with mean $0$ and variance $\sigma^2t$. In the limit $m\to\infty$, it becomes the Wiener process.

**In plain words.** The construction is a random walk that takes more and more, smaller and smaller steps. The step size shrinks like one over the square root of the number of steps, so the variance—which is the number of steps times the squared step size—settles down to a finite value proportional to elapsed time. In the limit the jagged walk becomes a continuous but still very rough curve.

---

## 7. Definition and covariance of the Wiener process

The **Wiener process** $W(t)$ is the continuous-time Gaussian i.s.i. process with zero mean and variance $\sigma^2t$.

$$
\boxed{
m_W(t)=0,
\qquad
\operatorname{Var}[W(t)]=\sigma^2t.
}
$$

It is used to model Brownian motion and other slowly wandering quantities.

![[Part4.pdf#page=98]]
*Figure: a realization of the Wiener process. (`Part4.pdf` p. 98)*

### Covariance

Since the mean is zero,

$$
C_W(t_1,t_2)=R_W(t_1,t_2)=E[W(t_1)W(t_2)].
$$

Assume $t_1\ge t_2$. Write

$$
W(t_1)=W(t_2)+(W(t_1)-W(t_2)).
$$

Then

$$
\begin{aligned}
E[W(t_1)W(t_2)]
&=E[(W(t_2)+(W(t_1)-W(t_2)))W(t_2)]\\
&=E[W(t_2)^2]+E[(W(t_1)-W(t_2))W(t_2)].
\end{aligned}
$$

By independent increments, $W(t_1)-W(t_2)$ is independent of $W(t_2)$, so the second term factors:

$$
E[(W(t_1)-W(t_2))W(t_2)]
=E[W(t_1)-W(t_2)]E[W(t_2)]
=0\cdot0=0.
$$

Therefore

$$
E[W(t_1)W(t_2)]=E[W(t_2)^2]=\sigma^2t_2.
$$

A symmetric argument for $t_2\ge t_1$ gives $\sigma^2t_1$. Hence

$$
\boxed{
C_W(t_1,t_2)=R_W(t_1,t_2)=\sigma^2\min(t_1,t_2).
}
$$

![[Part4.pdf#page=99]]
*Figure: the Wiener covariance is the variance of the shared past. (`Part4.pdf` p. 99)*

**In plain words.** The value at the later time is the value at the earlier time plus a fresh independent increment. When you multiply the two values and average, the fresh increment averages to zero and drops out. What remains is the average squared value at the earlier time, which is $\sigma^2$ times that earlier time. So the two times share exactly the variance of the shorter history.

> [!note] Same covariance, different paths
> The Wiener process and the Poisson process share the covariance $\sigma^2\min(t_1,t_2)$, yet one has continuous paths and the other is a staircase. Covariance does not capture path shape.

---

## 8. Multiple random processes

When discussing two processes $X(t)$ and $Y(t)$, we need joint descriptions.

Two random processes $X(t)$ and $Y(t)$ are **independent** if the vectors

$$
\begin{bmatrix}
X(t_1)\\
X(t_2)\\
\vdots\\
X(t_k)
\end{bmatrix}
$$

and

$$
\begin{bmatrix}
Y(s_1)\\
Y(s_2)\\
\vdots\\
Y(s_j)
\end{bmatrix}
$$

are independent for all $k,j$ and all choices of times $t_1,\dots,t_k$ and $s_1,\dots,s_j$.

![[Part4.pdf#page=100]]
*Figure: independence of two processes means independence of every finite collection of samples. (`Part4.pdf` p. 100)*

**In plain words.** Two processes are independent if knowing the entire history of one tells you nothing about the other, no matter which times you look at. It is not enough for them to be uncorrelated at a single pair of times; every finite collection of samples on one side must be independent of every finite collection on the other.

---

## 9. Cross-correlation and cross-covariance

The **cross-correlation** of $X(t)$ and $Y(t)$ is

$$
\boxed{
R_{XY}(t_1,t_2)=E[X(t_1)Y(t_2)].
}
$$

The **cross-covariance** is

$$
\boxed{
C_{XY}(t_1,t_2)
=E[(X(t_1)-m_X(t_1))(Y(t_2)-m_Y(t_2))]
=R_{XY}(t_1,t_2)-m_X(t_1)m_Y(t_2).
}
$$

The processes are **uncorrelated** if

$$
\boxed{
C_{XY}(t_1,t_2)=0
\quad\text{for all }t_1,t_2.
}
$$

![[Part4.pdf#page=101]]
*Figure: the definitions of independence, cross-correlation, and cross-covariance. (`Part4.pdf` p. 101)*

> [!important] Independence versus uncorrelatedness
> Independent processes are uncorrelated, but uncorrelated processes need not be independent. Independence is a statement about the full joint distribution; uncorrelatedness only rules out linear dependence.

**In plain words.** The cross-correlation asks whether a high value of one process tends to accompany a high value of the other at some chosen times. The cross-covariance subtracts the average levels first, so it measures whether the *fluctuations* move together. Zero covariance means they do not move together on average, but they could still be linked by a curved relationship.

---

## 10. Example 9.11: cross-covariance of a random-phase pair

Let

$$
X(t)=\cos(2\pi t+\xi),
\qquad
Y(t)=\sin(2\pi t+\xi),
$$

where $\xi$ is uniform on $[-\pi,\pi]$.

From earlier results,

$$
m_X(t)=0,
\qquad
m_Y(t)=0.
$$

Therefore

$$
C_{XY}(t_1,t_2)=R_{XY}(t_1,t_2).
$$

Compute:

$$
\begin{aligned}
R_{XY}(t_1,t_2)
&=E[X(t_1)Y(t_2)]\\
&=E[\cos(2\pi t_1+\xi)\sin(2\pi t_2+\xi)].
\end{aligned}
$$

Use

$$
\cos a\sin b=\frac12\left[\sin(a+b)-\sin(a-b)\right].
$$

With $a=2\pi t_1+\xi$ and $b=2\pi t_2+\xi$,

$$
a+b=2\pi(t_1+t_2)+2\xi,
$$

$$
a-b=2\pi(t_1-t_2).
$$

The term involving $a+b$ averages to zero because $2\xi$ is uniform over a full $2\pi$ period. Hence

$$
\boxed{
R_{XY}(t_1,t_2)
=-\frac12\sin(2\pi(t_1-t_2)).
}
$$

![[Part4.pdf#page=102]]
*Figure: the cross-correlation surface for the cosine/sine pair. (`Part4.pdf` p. 102)*

**In plain words.** The two signals are the same wave, one shifted a quarter period ahead of the other. When the cosine is at a peak, the sine is crossing zero; a quarter period later the roles reverse. Because the starting phase is random, the relationship depends only on the time gap between the two samples, not on the absolute clock time.

**Example (traced).** At zero lag, $t_1=t_2$:

$$
R_{XY}(t,t)=-\frac12\sin(0)=0.
$$

The two samples are uncorrelated at the same instant, even though they are deterministically related, because one is at a peak exactly when the other is at zero.

At a lag of one quarter period, $t_1-t_2=\tfrac14$:

$$
R_{XY}\left(t,t+\frac14\right)
=-\frac12\sin\left(\frac{\pi}{2}\right)
=-\frac12.
$$

At a lag of one half period, $t_1-t_2=\tfrac12$:

$$
R_{XY}\left(t,t+\frac12\right)
=-\frac12\sin(\pi)=0.
$$

---

## 11. Example 9.12: signal plus noise

Suppose we observe

$$
Y(t)=X(t)+N(t),
$$

where $X(t)$ is the desired signal and $N(t)$ is noise, with $X$ and $N$ independent. Find the cross-correlation between the desired signal and the observed signal.

$$
\begin{aligned}
R_{XY}(t_1,t_2)
&=E[X(t_1)Y(t_2)]\\
&=E[X(t_1)(X(t_2)+N(t_2))]\\
&=E[X(t_1)X(t_2)]+E[X(t_1)N(t_2)].
\end{aligned}
$$

By independence,

$$
E[X(t_1)N(t_2)]=E[X(t_1)]E[N(t_2)]=m_X(t_1)m_N(t_2).
$$

Therefore

$$
\boxed{
R_{XY}(t_1,t_2)
=R_X(t_1,t_2)+m_X(t_1)m_N(t_2).
}
$$

If the noise is zero mean, $m_N(t)=0$, then

$$
\boxed{
R_{XY}(t_1,t_2)=R_X(t_1,t_2).
}
$$

The cross-covariance is

$$
\begin{aligned}
C_{XY}(t_1,t_2)
&=R_{XY}(t_1,t_2)-m_X(t_1)m_Y(t_2)\\
&=R_X(t_1,t_2)+m_X(t_1)m_N(t_2)
-m_X(t_1)(m_X(t_2)+m_N(t_2))\\
&=R_X(t_1,t_2)-m_X(t_1)m_X(t_2)\\
&=C_X(t_1,t_2).
\end{aligned}
$$

So the cross-covariance between the signal and the noisy observation is just the signal's own autocovariance.

**In plain words.** The observation is the signal plus independent hiss. When you compare the clean signal with the observation, the hiss averages away because it does not know anything about the signal. What remains is the signal compared with itself, which is exactly its autocorrelation. Adding independent zero-mean noise therefore does not change the cross-correlation with the original signal.

---

## 12. Common mistakes

1. **Forgetting the absolute value in the telegraph autocorrelation.** It is $e^{-2\lambda\lvert t_2-t_1\rvert}$, not $e^{-2\lambda(t_2-t_1)}$ without the absolute value.
2. **Using $P[N\text{ even}]=\tfrac12$ exactly.** That is only the limit as $\alpha\to\infty$; the exact formula has the $e^{-2\alpha}$ correction.
3. **Forgetting to condition on $N(t)$ in shot noise.** The arrival times are uniform only *given* the number of arrivals.
4. **Using the arrival rate instead of the mean count.** $E[N(t)]=\lambda t$, and the factor $1/t$ cancels it to leave $\lambda$.
5. **Thinking the Wiener covariance is $\sigma^2t_1t_2$.** It is $\sigma^2\min(t_1,t_2)$.
6. **Thinking uncorrelated means independent for two processes.** Independence is stronger.
7. **Using $R_{XY}(t_1,t_2)=R_{YX}(t_1,t_2)$.** They are generally different: $R_{XY}(t_1,t_2)=E[X(t_1)Y(t_2)]$, while $R_{YX}(t_1,t_2)=E[Y(t_1)X(t_2)]=R_{XY}(t_2,t_1)$.
8. **Assuming zero cross-correlation at one lag means the processes are uncorrelated.** Uncorrelatedness requires zero for *all* $t_1,t_2$.
9. **Forgetting that the random step's variance is zero outside $[0,1]$.** The step is deterministic before it can start and after it must have started.

---

## 13. 60-second summary

Random step:

$$
\boxed{
m_X(t)=P[X(t)=1],
\qquad
\operatorname{Var}[X(t)]=P[X(t)=1]-P[X(t)=1]^2.
}
$$

For $T\sim\text{Uniform}[0,1]$ and $0\le t\le1$:

$$
\boxed{
m_X(t)=t,
\qquad
\operatorname{Var}[X(t)]=t-t^2.
}
$$

Poisson parity:

$$
\boxed{
P[N\text{ even}]=\frac12\left(1+e^{-2\alpha}\right),
\qquad
P[N\text{ odd}]=\frac12\left(1-e^{-2\alpha}\right).
}
$$

Random telegraph signal:

$$
\boxed{
m_X(t)=0,
\qquad
R_X(t_1,t_2)=e^{-2\lambda\lvert t_2-t_1\rvert}.
}
$$

Shot noise:

$$
\boxed{
X(t)=\sum_{i=1}^{\infty}h(t-S_i),
\qquad
E[X(t)]\to\lambda\int_0^{\infty}h(u)\,du.
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

Cross-correlation and cross-covariance:

$$
\boxed{
R_{XY}(t_1,t_2)=E[X(t_1)Y(t_2)],
}
$$

$$
\boxed{
C_{XY}(t_1,t_2)=R_{XY}(t_1,t_2)-m_X(t_1)m_Y(t_2).
}
$$

Random-phase pair:

$$
\boxed{
R_{XY}(t_1,t_2)=-\frac12\sin(2\pi(t_1-t_2)).
}
$$

Signal plus independent noise:

$$
\boxed{
R_{XY}(t_1,t_2)=R_X(t_1,t_2)+m_X(t_1)m_N(t_2).
}
$$

Return to the Part IV index: [[lec_21_to_25_index]].
