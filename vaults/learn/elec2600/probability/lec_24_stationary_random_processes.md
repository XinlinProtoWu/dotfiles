# Lecture 24: Stationary and Wide-Sense Stationary Random Processes

> **Big picture.** A process is **stationary** if shifting the clock does not change any joint distribution — the process is time-invariant in law. Stationarity forces the mean and variance to be constant and makes the autocorrelation depend only on the time difference. Checking full stationarity is hard, so we weaken the requirement to **wide-sense stationarity (WSS)**: constant mean and autocorrelation depending only on lag. Every stationary process is WSS, but not conversely. For **Gaussian** processes the two notions coincide, which is why Gaussian models are so convenient.

---

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. Each is linked at its **first use** below.

**Stationarity:** [[terms/stationarity]] · [[terms/wss]]

**Descriptions:** [[terms/autocorrelation]] · [[terms/gaussian-process]]

---

## Learning goals

By the end of this lecture you should be able to:

1. Define strict stationarity.
2. Show that an i.i.d. process is stationary.
3. Explain why a sum process is not stationary.
4. Show that stationary processes have constant mean and variance.
5. Define wide-sense stationarity.
6. Give an example that is WSS but not stationary.
7. Show that a WSS Gaussian process is stationary.
8. Use the properties of the autocorrelation of a WSS process.
9. Build joint Gaussian densities from a covariance matrix.
10. Compute the covariance of a moving-average process.

---

## 1. Definition of stationarity

A process $X(t)$ is **stationary** if the joint distribution of any set of samples does not depend on the placement of the time origin:

$$
\boxed{
F_{X(t_1),\dots,X(t_k)}(x_1,\dots,x_k)
=
F_{X(t_1+\Delta),\dots,X(t_k+\Delta)}(x_1,\dots,x_k)
}
$$

for all $x_1,\dots,x_k$, all $t_1,\dots,t_k$, and all shifts $\Delta$.

In particular,

$$
F_{X(t_1)}(x_1)=F_{X(t_1+\Delta)}(x_1),
$$

and

$$
F_{X(t_1),X(t_2)}(x_1,x_2)
=
F_{X(t_1+\Delta),X(t_2+\Delta)}(x_1,x_2).
$$

Stationarity is **time invariance in law**.

![[Part4.pdf#page=70]]
*Figure: shifting all sample times by $\Delta$ leaves every joint distribution unchanged. (`Part4.pdf` p. 70)*

**In plain words.** A stationary process is like a factory that has been running forever with no warm-up and no drift. If you record a window today and an identical-length window next year, the two recordings have the same statistical character. You cannot tell from the statistics where the window was cut.

---

## 2. i.i.d. processes are stationary

For an i.i.d. process, any set of samples is independent with the same marginal $F_X$:

$$
F_{X(t_1),\dots,X(t_k)}(x_1,\dots,x_k)
=F_X(x_1)F_X(x_2)\cdots F_X(x_k).
$$

After shifting all times by $\Delta$, the samples are still i.i.d. with the same marginal, so

$$
F_{X(t_1+\Delta),\dots,X(t_k+\Delta)}(x_1,\dots,x_k)
=F_X(x_1)F_X(x_2)\cdots F_X(x_k).
$$

The two expressions are equal. Hence the i.i.d. process is stationary.

**In plain words.** A fair coin does not care what day it is. A block of tosses made on Monday has the same joint distribution as a block of the same length made on Tuesday, because every toss is independent and every toss has the same bias.

> [!important] Stationarity does not require independence
> i.i.d. is a sufficient condition, not a necessary one. A process with dependence can still be stationary, as long as the dependence pattern itself does not change with time.

---

## 3. Mean and variance of a stationary process are constant

If $X(t)$ is stationary, then the first-order distribution is the same at every time:

$$
f_{X(t)}(x)=f(x).
$$

Therefore

$$
m_X(t)=\int x f_{X(t)}(x)\,dx
=\int x f(x)\,dx
=m,
$$

and

$$
\operatorname{Var}[X(t)]
=\int (x-m)^2 f_{X(t)}(x)\,dx
=\int (x-m)^2 f(x)\,dx
=\sigma^2.
$$

Both are constants, independent of $t$.

![[Part4.pdf#page=72]]
*Figure: the first-order density is the same at every time. (`Part4.pdf` p. 72)*

**In plain words.** If the process looks statistically the same at every instant, then its average level and its spread cannot depend on the clock. A constant mean and constant variance are necessary consequences of stationarity — but they are not enough to guarantee it.

---

## 4. The sum process is not stationary

Let

$$
S_n=X_1+\cdots+X_n
$$

with the $X_n$ i.i.d., mean $m$, variance $\sigma^2$. Then

$$
m_S(n)=nm,
\qquad
\operatorname{Var}[S_n]=n\sigma^2.
$$

Both change with $n$, so the first-order distribution changes with time. Therefore the sum process is **not stationary**.

![[Part4.pdf#page=73]]
*Figure: the mean and variance of a sum process grow with $n$. (`Part4.pdf` p. 73)*

**In plain words.** A random walk drifts away from its starting point and spreads out more and more. The distribution at step $100$ is much wider than the distribution at step $10$, so the process cannot look the same at every time. It has stationary *increments*, but the process itself is not stationary.

> [!warning] Stationary increments $\ne$ stationary process
> The Poisson process has stationary increments, but its mean $\lambda t$ grows, so it is not stationary. Keep the two concepts separate.

---

## 5. Autocorrelation of a stationary process

For a stationary process, the joint distribution of $(X(t_1),X(t_2))$ depends only on the time difference. Therefore

$$
R_X(t_1,t_2)=R_X(t_1-t_2),
$$

and, since the mean is constant,

$$
\boxed{
C_X(t_1,t_2)=R_X(t_1-t_2)-m_X^2.
}
$$

The autocorrelation and autocovariance are functions of the **lag** $\tau=t_1-t_2$ only.

**In plain words.** For a stationary process, only the gap between two samples matters. Two samples taken one second apart have the same relationship whether that second is at noon or at midnight. The absolute clock reading is irrelevant.

---

## 6. Wide-sense stationarity

Checking every finite-order distribution is usually impossible. We often settle for the first two moments.

A process $X(t)$ is **wide-sense stationary (WSS)** if and only if

$$
\boxed{
m_X(t)=m\quad\text{for all }t,
}
$$

$$
\boxed{
R_X(t_1,t_2)=R_X(t_1-t_2)\quad\text{for all }t_1,t_2,
}
$$

or, equivalently,

$$
\boxed{
C_X(t_1,t_2)=C_X(t_1-t_2)\quad\text{for all }t_1,t_2.
}
$$

![[Part4.pdf#page=77]]
*Figure: WSS requires only a constant mean and a lag-dependent autocorrelation. (`Part4.pdf` p. 77)*

> [!important] The logical relationship
> **Stationary $\Longrightarrow$ WSS.** Every stationary process is wide-sense stationary, because its mean is constant and its joint distributions depend only on lag.
>
> **WSS $\not\Longrightarrow$ stationary.** The converse is false in general. A process can have constant mean and lag-only covariance while its higher-order distributions or even its marginal distribution change with time.

**In plain words.** Full stationarity says the entire statistical personality of the process is unchanged by a clock shift. WSS only says its average level and its two-sample correlation are unchanged. That is a much cheaper check: you only need means and second moments.

---

## 7. Example 9.34: interleaved processes — WSS but not stationary

Let $X_n$ consist of two interleaved i.i.d. sequences.

For **even** $n$:

$$
P[X_n=+1]=\frac12,
\qquad
P[X_n=-1]=\frac12.
$$

For **odd** $n$:

$$
P\left[X_n=+\frac13\right]=\frac{9}{10},
\qquad
P[X_n=-3]=\frac{1}{10}.
$$

![[Part4.pdf#page=78]]
*Figure: even and odd time slots use different distributions. (`Part4.pdf` p. 78)*

### The process is not stationary

The marginal pmf at even $n$ is supported on $\{\pm1\}$, while at odd $n$ it is supported on $\{+1/3,-3\}$. The marginal distribution changes with $n$, so the process is not stationary.

### The process is WSS

Check the mean at even $n$:

$$
E[X_n]=\frac12(1)+\frac12(-1)=0.
$$

Check the mean at odd $n$:

$$
E[X_n]=\frac{9}{10}\left(\frac13\right)+\frac{1}{10}(-3)
=0.3-0.3=0.
$$

So $m_X(n)=0$ for all $n$.

Check the second moment at even $n$:

$$
E[X_n^2]=\frac12(1)^2+\frac12(-1)^2=1.
$$

Check the second moment at odd $n$:

$$
E[X_n^2]=\frac{9}{10}\left(\frac13\right)^2+\frac{1}{10}(-3)^2
=\frac{9}{10}\cdot\frac19+\frac{9}{10}
=0.1+0.9=1.
$$

So $E[X_n^2]=1$ at every $n$.

For $i\ne j$, the two samples come from different interleaved i.i.d. sequences (or from different positions of the same sequence), so they are independent and

$$
E[X_iX_j]=E[X_i]E[X_j]=0.
$$

Therefore

$$
C_X(i,j)=
\begin{cases}
1, & i=j,\\
0, & i\ne j.
\end{cases}
$$

This depends only on whether the lag is zero, so the process is WSS.

**In plain words.** Imagine two different games alternate: on even turns you flip a fair coin that pays $+1$ or $-1$, and on odd turns you spin a very biased wheel that almost always pays a small $+1/3$ but rarely costs $-3$. The *average* payout is zero in both games, and the *spread* is one unit in both games, so from the first two moments the turns look identical. But the actual possible payouts are completely different, so anyone looking at the full distribution can tell even from odd. That is exactly WSS without stationarity.

> [!important] Lesson
> WSS controls only the first two moments. It cannot see a change in the shape of the marginal distribution if the mean and variance stay fixed.

---

## 8. The random phase process is WSS

For

$$
X(t)=\cos(2\pi t+\xi),
\qquad
\xi\sim\text{Uniform}[-\pi,\pi],
$$

we computed in Lecture 23:

$$
m_X(t)=0,
$$

$$
R_X(t_1,t_2)=\frac12\cos(2\pi(t_1-t_2)).
$$

The mean is constant and the autocorrelation depends only on $t_1-t_2$. Hence the process is WSS.

![[Part4.pdf#page=79]]
*Figure: the random phase process has a lag-only autocorrelation. (`Part4.pdf` p. 79)*

In fact, the random phase process is **strictly stationary** as well. A time shift $\Delta$ gives

$$
X(t+\Delta)=\cos(2\pi(t+\Delta)+\xi)
=\cos(2\pi t+\xi'),
$$

where

$$
\xi'=\xi+2\pi\Delta \pmod{2\pi}.
$$

Because $\xi$ is uniform on a full period, $\xi'$ is also uniform on that period. So every joint distribution is unchanged by the shift.

**In plain words.** The only randomness is where the cosine starts. Sliding the clock forward by $\Delta$ is exactly the same as changing the starting phase by a fixed amount. Since the starting phase is equally likely anywhere, the shifted process has the same distribution as the original. That is stationarity, and the mean and correlation calculations already showed WSS.

---

## 9. A WSS Gaussian process is stationary

If $X(t)$ is Gaussian, every finite set of samples is jointly Gaussian. A jointly Gaussian distribution is determined by its mean vector and covariance matrix. If the process is WSS, then:

- every mean is the same constant $m$,
- every covariance $C_X(t_i,t_j)$ depends only on $t_i-t_j$.

Shifting all times by $\Delta$ leaves the mean vector unchanged and leaves every pairwise lag unchanged, so it leaves the covariance matrix unchanged. Therefore every joint distribution is unchanged, and the process is stationary.

$$
\boxed{
\text{Gaussian} + \text{WSS}
\Longrightarrow
\text{stationary}.
}
$$

**In plain words.** For a bell-shaped process, the mean and the covariance matrix are the entire story. If those do not change when you move the clock, then nothing about the distribution changes. There is no hidden higher-order shape that could give away the time.

---

## 10. Joint densities of a WSS Gaussian process

Let $X(t)$ be a continuous-time WSS Gaussian process with

$$
m_X(t)=0,
\qquad
C_X(t_1,t_2)=4e^{-0.5\lvert t_1-t_2\rvert}.
$$

Every joint density has the form

$$
f(\mathbf x)=
\frac{1}{(2\pi)^{k/2}\lvert C\rvert^{1/2}}
\exp\left[-\frac12(\mathbf x-\mathbf m)^T
C^{-1}(\mathbf x-\mathbf m)\right].
$$

Only $\mathbf m$ and $C$ change with the chosen samples.

### Samples $X(10)$ and $X(11)$

$$
\mathbf m=
\begin{bmatrix}
0\\
0
\end{bmatrix}.
$$

$$
C=
\begin{bmatrix}
4 & 4e^{-0.5}\\
4e^{-0.5} & 4
\end{bmatrix}
\approx
\begin{bmatrix}
4 & 2.426\\
2.426 & 4
\end{bmatrix}.
$$

### Samples $X(10)$ and $X(14)$

The lag is $4$, so

$$
C=
\begin{bmatrix}
4 & 4e^{-2}\\
4e^{-2} & 4
\end{bmatrix}
\approx
\begin{bmatrix}
4 & 0.541\\
0.541 & 4
\end{bmatrix}.
$$

### Samples $X(10)$, $X(11)$, $X(14)$

$$
C=
\begin{bmatrix}
4 & 4e^{-0.5} & 4e^{-2}\\
4e^{-0.5} & 4 & 4e^{-1.5}\\
4e^{-2} & 4e^{-1.5} & 4
\end{bmatrix}.
$$

$$
C\approx
\begin{bmatrix}
4 & 2.426 & 0.541\\
2.426 & 4 & 0.893\\
0.541 & 0.893 & 4
\end{bmatrix}.
$$

![[Part4.pdf#page=82]]
*Figure: the same Gaussian formula with different mean vectors and covariance matrices. (`Part4.pdf` p. 82)*

**In plain words.** The further apart two samples are in time, the less they know about each other. At a lag of one second the exponential factor is $e^{-0.5}\approx0.61$, so the off-diagonal covariance is about $2.43$. At a lag of four seconds the factor is $e^{-2}\approx0.135$, so the covariance drops to about $0.54$. The diagonal is always $4$, the variance at zero lag.

---

## 11. Properties of the autocorrelation of a WSS process

Let $\tau=t_1-t_2$ and write

$$
R_X(\tau)=R_X(t_1,t_2).
$$

Then:

1. **Power at the origin.**

$$
\boxed{
R_X(0)=E[X(t)^2].
}
$$

2. **Even symmetry.**

$$
\boxed{
R_X(-\tau)=R_X(\tau).
}
$$

3. **Maximum at the origin.**

$$
\boxed{
\lvert R_X(\tau)\rvert\le R_X(0).
}
$$

4. **Slow decay means slow change.** The slower $R_X(\tau)$ decays as $\lvert\tau\rvert\to\infty$, the more slowly the realizations change.

![[Part4.pdf#page=84]]
*Figure: slowly decaying autocorrelation (left) versus quickly decaying autocorrelation (right). (`Part4.pdf` p. 84)*

### Proof of the slow-change statement

For a WSS process,

$$
E[(X(t+\tau)-X(t))^2]
=2R_X(0)-2R_X(\tau).
$$

By Chebyshev's inequality,

$$
\begin{aligned}
P[\lvert X(t+\tau)-X(t)\rvert>\varepsilon]
&=P[\lvert X(t+\tau)-X(t)\rvert^2>\varepsilon^2]\\
&\le\frac{E[(X(t+\tau)-X(t))^2]}{\varepsilon^2}\\
&=\frac{2(R_X(0)-R_X(\tau))}{\varepsilon^2}.
\end{aligned}
$$

If $R_X(\tau)$ is still close to $R_X(0)$ at a large lag, the right-hand side is small, so $X(t+\tau)$ is likely to be close to $X(t)$. The process changes slowly.

**In plain words.** If the autocorrelation at a long lag is still high, the process at that later time is still strongly tied to where it was, so it cannot have wandered far. If the autocorrelation has already fallen to zero, the later value has forgotten the earlier one and can be anywhere.

> [!warning] Use the absolute value
> The correct bound is $\lvert R_X(\tau)\rvert\le R_X(0)$. The autocorrelation can be negative, so writing only $R_X(\tau)\le R_X(0)$ is not the full statement.

---

## 12. Examples: very slow, very fast, and averaged processes

### 12.1 Constant random level

Let $X_n=x$ for all $n$, where $x$ is chosen once from $[0,1]$ and then fixed.

This process does not change at all over time. It is WSS with

$$
R_X(n_1,n_2)=E[X(n_1)X(n_2)]=E[x^2].
$$

For $x\sim\text{Uniform}[0,1]$,

$$
E[x^2]=\frac13.
$$

So

$$
R_X(\tau)=\frac13
$$

for every lag: the autocorrelation never decays.

![[Part4.pdf#page=85]]
*Figure: a constant random level versus white noise. (`Part4.pdf` p. 85)*

**In plain words.** You roll a die once and then keep showing that same number forever. Every sample is perfectly predictable from the first one, so the correlation is just as strong after a million steps as at lag zero. The process is slow because it never moves.

### 12.2 White noise

Let $X_n$ be i.i.d. with zero mean and variance $\sigma^2$. Then

$$
R_X(n_1,n_2)=\sigma^2\delta(n_1-n_2)
=
\begin{cases}
\sigma^2, & n_1=n_2,\\
0, & n_1\ne n_2.
\end{cases}
$$

The autocorrelation drops to zero immediately.

**In plain words.** Each sample is a fresh independent roll of the die, so once one step has passed there is no memory left. The process is as fast as possible.

### 12.3 Example 9.36: moving average of white noise

Let $X_n$ be i.i.d. Gaussian with zero mean and variance $\sigma^2$, and define

$$
Y_n=\frac{X_n+X_{n-1}}{2}.
$$

Then $Y_n$ is a Gaussian process. Its mean is

$$
m_Y(n)=E\left[\frac{X_n+X_{n-1}}{2}\right]=0.
$$

Its covariance is, for $i,j$,

$$
\begin{aligned}
C_Y(i,j)
&=E[Y_iY_j]\\
&=\frac14E[(X_i+X_{i-1})(X_j+X_{j-1})]\\
&=\frac14\left(
E[X_iX_j]+E[X_iX_{j-1}]
+E[X_{i-1}X_j]+E[X_{i-1}X_{j-1}]
\right).
\end{aligned}
$$

Because the $X$'s are independent with variance $\sigma^2$,

$$
E[X_kX_\ell]=
\begin{cases}
\sigma^2, & k=\ell,\\
0, & k\ne\ell.
\end{cases}
$$

**Case $i=j$:** all four terms with matching indices survive:

$$
C_Y(i,i)=\frac14(\sigma^2+\sigma^2)=\frac{\sigma^2}{2}.
$$

**Case $i=j+1$:** only the term $X_{i-1}X_j=X_jX_j$ contributes, and it contributes $\sigma^2$, giving

$$
C_Y(i,j)=\frac14(\sigma^2)=\frac{\sigma^2}{4}.
$$

By symmetry, the same holds when $j=i+1$:

$$
C_Y(i,j)=\frac{\sigma^2}{4}\quad\text{if }\lvert i-j\rvert=1.
$$

**Case $\lvert i-j\rvert\ge2$:** no index matches, so

$$
C_Y(i,j)=0.
$$

Therefore

$$
\boxed{
C_Y(i,j)=
\begin{cases}
\dfrac{\sigma^2}{2}, & i=j,\\[4pt]
\dfrac{\sigma^2}{4}, & \lvert i-j\rvert=1,\\[4pt]
0, & \lvert i-j\rvert\ge2.
\end{cases}
}
$$

This depends only on $i-j$, so $Y_n$ is WSS. Since it is Gaussian and WSS, it is also stationary.

![[Part4.pdf#page=86]]
*Figure: averaging consecutive samples spreads the correlation over one extra lag. (`Part4.pdf` p. 86)*

**In plain words.** A one-step moving average is like smoothing a noisy sequence by averaging each reading with the one before it. Neighbouring outputs now share one input, so they are correlated; outputs two steps apart share nothing, so they are independent. The averaging halves the variance, because averaging two independent equal-variance readings reduces the spread by a factor of two.

---

## 13. Common mistakes

1. **Thinking WSS implies stationarity.** The interleaved example is WSS but not stationary.
2. **Thinking stationarity means independent samples.** Dependence is allowed; only the *distribution* must be time-invariant.
3. **Confusing stationary increments with stationarity.** The Poisson and Wiener processes have stationary increments but are not stationary.
4. **Checking only constant mean.** WSS also requires the autocorrelation to depend only on lag.
5. **Using $R_X(0)$ as the variance when the mean is nonzero.** $R_X(0)=E[X^2]$, while $\operatorname{Var}(X)=R_X(0)-m^2$.
6. **Forgetting the absolute value in the bound.** The correct statement is $\lvert R_X(\tau)\rvert\le R_X(0)$.
7. **Assuming every Gaussian process is stationary.** Gaussian plus WSS is stationary; Gaussian alone is not enough.
8. **Computing a covariance with the wrong lag sign.** For real processes $R_X(-\tau)=R_X(\tau)$, so the sign of the lag does not matter.

---

## 14. 60-second summary

Stationarity:

$$
\boxed{
F_{X(t_1),\dots,X(t_k)}(x_1,\dots,x_k)
=
F_{X(t_1+\Delta),\dots,X(t_k+\Delta)}(x_1,\dots,x_k).
}
$$

Stationary implies constant mean and variance:

$$
\boxed{
m_X(t)=m,
\qquad
\operatorname{Var}[X(t)]=\sigma^2.
}
$$

Stationary autocorrelation depends only on lag:

$$
\boxed{
R_X(t_1,t_2)=R_X(t_1-t_2),
\qquad
C_X(t_1,t_2)=R_X(t_1-t_2)-m^2.
}
$$

WSS:

$$
\boxed{
m_X(t)=m,
\qquad
R_X(t_1,t_2)=R_X(t_1-t_2).
}
$$

Logical relations:

$$
\boxed{
\text{stationary}\Longrightarrow\text{WSS},
\qquad
\text{WSS}\not\Longrightarrow\text{stationary}.
}
$$

Gaussian special case:

$$
\boxed{
\text{Gaussian}+\text{WSS}\Longrightarrow\text{stationary}.
}
$$

Autocorrelation properties:

$$
\boxed{
R_X(0)=E[X(t)^2],
\qquad
R_X(-\tau)=R_X(\tau),
\qquad
\lvert R_X(\tau)\rvert\le R_X(0).
}
$$

Slow decay:

$$
\boxed{
P[\lvert X(t+\tau)-X(t)\rvert>\varepsilon]
\le
\frac{2(R_X(0)-R_X(\tau))}{\varepsilon^2}.
}
$$

Moving average:

$$
\boxed{
Y_n=\frac{X_n+X_{n-1}}{2},
\qquad
C_Y(i,j)=
\begin{cases}
\sigma^2/2, & i=j,\\
\sigma^2/4, & \lvert i-j\rvert=1,\\
0, & \lvert i-j\rvert\ge2.
\end{cases}
}
$$

Continue with [[lec_25_multiple_random_processes]].
