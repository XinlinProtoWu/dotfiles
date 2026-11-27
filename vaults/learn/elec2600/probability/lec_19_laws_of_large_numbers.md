# Lecture 19: Laws of Large Numbers

> **Big picture.** Averages of many independent observations become predictable. The **sample mean** is unbiased and its variance shrinks like $1/n$. The **weak law** says the sample mean is likely to be close to the true mean for large $n$. The **strong law** says it actually converges for almost every outcome. These laws explain why relative frequencies converge to probabilities.

---

## Learning goals

By the end of this lecture you should be able to:

1. Compute means and variances of sums.
2. Compute the mean and variance of the sample mean.
3. Use Markov's and Chebyshev's inequalities.
4. State and use the weak law of large numbers.
5. State the strong law and distinguish it from the weak law.
6. Explain why relative frequency converges to probability.

---

## 1. Mean and variance of sums

For any random variables $X_1,\dots,X_n$,

$$
\boxed{
E\left[\sum_{j=1}^{n}X_j\right]
=
\sum_{j=1}^{n}E[X_j]
}
$$

This does **not** require independence.

For the variance,

$$
\boxed{
\operatorname{Var}\left(\sum_{j=1}^{n}X_j\right)
=
\sum_{j=1}^{n}\operatorname{Var}(X_j)
+
\sum_{j=1}^{n}\sum_{k\ne j}\operatorname{Cov}(X_j,X_k)
}
$$

or equivalently,

$$
\boxed{
\operatorname{Var}\left(\sum_{j=1}^{n}X_j\right)
=
\sum_{j=1}^{n}\operatorname{Var}(X_j)
+
2\sum_{j<k}\operatorname{Cov}(X_j,X_k)
}.
$$

For two variables,

$$
\boxed{
\operatorname{Var}(X+Y)
=
\operatorname{Var}(X)
+2\operatorname{Cov}(X,Y)
+\operatorname{Var}(Y)
}.
$$

If the variables are uncorrelated, all covariance terms vanish:

$$
\boxed{
\operatorname{Var}\left(\sum_{j=1}^{n}X_j\right)
=
\sum_{j=1}^{n}\operatorname{Var}(X_j)
}.
$$

In particular, independence implies uncorrelatedness, so the variance of a sum of independent variables is the sum of the variances.

---

## 2. i.i.d. random variables

"i.i.d." means **independent and identically distributed**.

Let $X_1,\dots,X_n$ be i.i.d. with

$$
E[X_i]=\mu,
\qquad
\operatorname{Var}(X_i)=\sigma^2.
$$

Define the sum

$$
S_n=\sum_{i=1}^{n}X_i.
$$

Then

$$
\boxed{
E[S_n]=n\mu
}
$$

and, because independence implies uncorrelatedness,

$$
\boxed{
\operatorname{Var}(S_n)=n\sigma^2
}.
$$

So both the mean and variance of the sum grow linearly with $n$.

> **Intuition check:** if you add more random terms, the center of the distribution moves to the right at rate $\mu$, and the spread grows like $\sqrt n$ in standard deviation.

---

## 3. The sample mean

The **sample mean** is

$$
\boxed{
M_n=\frac1n\sum_{j=1}^{n}X_j
=\frac{S_n}{n}
}.
$$

It is a random variable: a different sample gives a different average.

### Unbiasedness

An estimator $Y$ of a constant $c$ is **unbiased** if

$$
E[Y]=c.
$$

For i.i.d. $X_j$ with mean $\mu$,

$$
\boxed{
E[M_n]
=
\frac1n\sum_{j=1}^{n}E[X_j]
=
\frac1n\cdot n\mu
=
\mu
}.
$$

So the sample mean is an **unbiased estimator** of the true mean $\mu$.

### Variance

$$
\begin{aligned}
\operatorname{Var}(M_n)
&=\operatorname{Var}\left(\frac1n\sum_{j=1}^{n}X_j\right)\\
&=\frac{1}{n^2}\operatorname{Var}\left(\sum_{j=1}^{n}X_j\right)\\
&=\frac{1}{n^2}\cdot n\sigma^2\\
&=\frac{\sigma^2}{n}.
\end{aligned}
$$

Thus

$$
\boxed{
\operatorname{Var}(M_n)=\frac{\sigma^2}{n}
}.
$$

The standard deviation of the sample mean is

$$
\boxed{
\sigma_{M_n}=\frac{\sigma}{\sqrt n}
}.
$$

As $n$ grows, the sample mean clusters more and more tightly around $\mu$.

> [!Example]
> **Sample mean of Bernoulli variables.** If $X_j\sim\text{Bernoulli}(p)$, then
> $$
> E[X_j]=p,
> \qquad
> \operatorname{Var}(X_j)=p(1-p).
> $$
> Therefore
> $$
> E[M_n]=p,
> \qquad
> \operatorname{Var}(M_n)=\frac{p(1-p)}{n}.
> $$
> Here $M_n$ is the relative frequency of successes.

---

## 4. Markov's inequality

If $X$ is a **nonnegative** random variable and $a>0$, then

$$
\boxed{
P[X\ge a]\le\frac{E[X]}{a}
}.
$$

### Proof

$$
\begin{aligned}
E[X]
&=\int_0^{\infty}xf_X(x)\,dx\\
&=\int_0^{a}xf_X(x)\,dx+\int_a^{\infty}xf_X(x)\,dx\\
&\ge\int_a^{\infty}xf_X(x)\,dx\\
&\ge\int_a^{\infty}af_X(x)\,dx\\
&=aP[X\ge a].
\end{aligned}
$$

Divide by $a$:

$$
P[X\ge a]\le\frac{E[X]}{a}.
$$

> **Key point:** Markov uses only the mean and requires $X\ge0$.

> [!Example]
> If $X\ge0$ and $E[X]=10$, then
> $$
> P[X\ge30]\le\frac{10}{30}=\frac13.
> $$
> This is a loose bound, but it requires almost no information.

---

## 5. Chebyshev's inequality

Let $X$ have mean $m$ and variance $\sigma^2$. For any $a>0$,

$$
\boxed{
P[|X-m|\ge a]\le\frac{\sigma^2}{a^2}
}.
$$

Equivalently,

$$
\boxed{
P[|X-m|<a]\ge1-\frac{\sigma^2}{a^2}
}.
$$

### Proof

Let $D=X-m$. Then $D^2\ge0$, so we can apply Markov's inequality to $D^2$:

$$
P[(X-m)^2\ge a^2]
\le
\frac{E[(X-m)^2]}{a^2}
=
\frac{\operatorname{Var}(X)}{a^2}.
$$

But

$$
(X-m)^2\ge a^2
\iff
|X-m|\ge a.
$$

Therefore

$$
P[|X-m|\ge a]\le\frac{\sigma^2}{a^2}.
$$

> **Interpretation:** the probability of being more than $a$ away from the mean is small when $a$ is large compared with $\sigma$.

> [!Example]
> If $E[X]=50$ and $\sigma=5$, then for $a=15$ (three standard deviations),
> $$
> P[|X-50|\ge15]\le\frac{25}{225}=\frac19\approx0.111.
> $$
> So
> $$
> P[45<X<65]\ge1-\frac19=\frac89\approx0.889.
> $$

> [!Example]
> **Sample-size estimate using Chebyshev.** Suppose $\sigma=1$ and we want
> $$
> P[|M_n-\mu|<0.5]\ge0.9.
> $$
> Since $\operatorname{Var}(M_n)=1/n$,
> $$
> P[|M_n-\mu|<0.5]
> \ge1-\frac{1}{n(0.5)^2}
> =1-\frac{4}{n}.
> $$
> Require
> $$
> 1-\frac4n\ge0.9
> \iff
> \frac4n\le0.1
> \iff
> n\ge40.
> $$
> Chebyshev guarantees this with $n=40$, though it is often very conservative.

---

## 6. Weak law of large numbers (WLLN)

Let $X_1,X_2,\dots$ be i.i.d. with finite mean $\mu$. For any $\varepsilon>0$,

$$
\boxed{
\lim_{n\to\infty}P[|M_n-\mu|<\varepsilon]=1
}.
$$

Equivalently,

$$
\boxed{
M_n\overset{P}{\longrightarrow}\mu
}
$$

(convergence in probability).

### Proof assuming finite variance

Suppose $\operatorname{Var}(X_i)=\sigma^2<\infty$. By Chebyshev applied to $M_n$,

$$
P[|M_n-\mu|\ge\varepsilon]
\le
\frac{\operatorname{Var}(M_n)}{\varepsilon^2}
=
\frac{\sigma^2}{n\varepsilon^2}.
$$

Therefore

$$
P[|M_n-\mu|<\varepsilon]
\ge
1-\frac{\sigma^2}{n\varepsilon^2}
\longrightarrow
1
\quad\text{as }n\to\infty.
$$

So

$$
\boxed{
\lim_{n\to\infty}P[|M_n-\mu|<\varepsilon]=1
}.
$$

> The theorem is true even when the variance is infinite, but the proof above uses a finite variance.

---

## 7. Strong law of large numbers (SLLN)

Let $X_1,X_2,\dots$ be i.i.d. with finite mean $\mu$ (and, in this course, finite variance). Then

$$
\boxed{
P\left[\lim_{n\to\infty}M_n=\mu\right]=1
}.
$$

This is **almost sure convergence**:

$$
\boxed{
M_n\overset{\text{a.s.}}{\longrightarrow}\mu
}.
$$

### Weak vs strong

- **Weak law:** for each large $n$, the probability that $M_n$ is close to $\mu$ is close to $1$.
- **Strong law:** for almost every outcome, the entire sequence $M_n(\zeta)$ eventually converges to $\mu$.

The strong law is a statement about individual sequences; the weak law is a statement about probabilities at each $n$.

> **Memory picture:** weak law says "most of the $M_n$'s are close"; strong law says "each sequence eventually stays close."

---

## 8. Relative frequency and statistical regularity

Let $A$ be an event and define the indicator

$$
I_j=
\begin{cases}
1,&A\text{ occurs on trial }j,\\
0,&A\text{ does not occur on trial }j.
\end{cases}
$$

Then

$$
E[I_j]=1\cdot P[A]+0\cdot P[A^c]=P[A].
$$

The number of occurrences in $n$ trials is

$$
N_n=\sum_{j=1}^{n}I_j,
$$

and the relative frequency is

$$
\boxed{
f_A(n)=\frac{N_n}{n}
=
\frac1n\sum_{j=1}^{n}I_j
=
M_n
}.
$$

So the relative frequency is exactly the sample mean of the indicators.

Applying the weak law,

$$
\boxed{
\lim_{n\to\infty}P[|f_A(n)-P[A]|<\varepsilon]=1
}.
$$

Applying the strong law,

$$
\boxed{
P\left[\lim_{n\to\infty}f_A(n)=P[A]\right]=1
}.
$$

> **Why this matters:** in Chapter 1 we observed that relative frequencies stabilize. The laws of large numbers show that probability theory **predicts** this statistical regularity. The theory and observed behavior are consistent.

---

## 9. Common mistakes

1. **Thinking $M_n$ is not random.** It is a random variable; its value changes with the sample.
2. **Confusing the variance of the sum with the variance of the mean.** $\operatorname{Var}(S_n)=n\sigma^2$, but $\operatorname{Var}(M_n)=\sigma^2/n$.
3. **Using Markov's inequality on a variable that can be negative.** Markov requires $X\ge0$.
4. **Using Chebyshev with $\sigma$ instead of $\sigma^2$.** The bound is $\sigma^2/a^2$.
5. **Thinking Chebyshev is tight.** It is usually conservative.
6. **Confusing weak and strong laws.** Weak is convergence in probability; strong is almost sure convergence.
7. **Forgetting the i.i.d. assumption.** The clean formulas for $E[M_n]$ and $\operatorname{Var}(M_n)$ use identical distributions; the variance simplification uses independence/uncorrelatedness.
8. **Writing $P[\lim M_n=\mu]=1$ as if it were the same as $\lim P[|M_n-\mu|<\varepsilon]=1$.** These are different modes of convergence.

---

## 10. 60-second summary

$$
\boxed{
E\left[\sum_{j=1}^{n}X_j\right]
=
\sum_{j=1}^{n}E[X_j]
}
$$

$$
\boxed{
\operatorname{Var}\left(\sum_{j=1}^{n}X_j\right)
=
\sum_{j=1}^{n}\operatorname{Var}(X_j)
+
2\sum_{j<k}\operatorname{Cov}(X_j,X_k)
}
$$

For i.i.d. $X_i$ with mean $\mu$ and variance $\sigma^2$:

$$
\boxed{
E[S_n]=n\mu,
\qquad
\operatorname{Var}(S_n)=n\sigma^2
}
$$

$$
\boxed{
E[M_n]=\mu,
\qquad
\operatorname{Var}(M_n)=\frac{\sigma^2}{n}
}
$$

Markov:

$$
\boxed{
P[X\ge a]\le\frac{E[X]}{a}
\quad(X\ge0)
}
$$

Chebyshev:

$$
\boxed{
P[|X-m|\ge a]\le\frac{\sigma^2}{a^2}
}
$$

Weak law:

$$
\boxed{
\lim_{n\to\infty}P[|M_n-\mu|<\varepsilon]=1
}
$$

Strong law:

$$
\boxed{
P\left[\lim_{n\to\infty}M_n=\mu\right]=1
}
$$

Relative frequency:

$$
\boxed{
f_A(n)=\frac1n\sum_{j=1}^{n}I_j
\ \longrightarrow\ P[A]
}
$$
