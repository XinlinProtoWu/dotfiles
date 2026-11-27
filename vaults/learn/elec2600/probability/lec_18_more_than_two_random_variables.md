# Lecture 18: More Than Two Random Variables

> **Big picture.** Everything from pairs extends to $n$ random variables, but the notation becomes vector/matrix notation. A random vector has a joint CDF, joint PDF or PMF, marginal distributions, conditional distributions, a **mean vector**, a **correlation matrix**, and a **covariance matrix**. Jointly Gaussian vectors are especially nice: they are completely described by their mean vector and covariance matrix.

---

## Learning goals

By the end of this lecture you should be able to:

1. Write joint CDFs, PDFs, and PMFs for $n$ variables.
2. Compute marginal distributions by integrating or summing out variables.
3. Use the chain rule for conditional distributions.
4. Test independence of $n$ variables.
5. Build mean, correlation, and covariance matrices.
6. Use the multivariate Gaussian density.
7. Use the closure properties of Gaussian vectors.

---

## 1. Random vectors

An $n$-dimensional random vector is a mapping from the sample space to $\mathbb R^n$:

$$
\vec X=
\begin{pmatrix}
X_1\\
X_2\\
\vdots\\
X_n
\end{pmatrix}.
$$

Given an outcome, all $X_1,\dots,X_n$ are determined simultaneously.

### Joint CDF

$$
\boxed{
F_{X_1,\dots,X_n}(x_1,\dots,x_n)
=P[X_1\le x_1,\ X_2\le x_2,\dots,X_n\le x_n]
}
$$

To eliminate a variable, send its argument to $+\infty$:

$$
F_{X_1,\dots,X_{n-1}}(x_1,\dots,x_{n-1})
=F_{X_1,\dots,X_n}(x_1,\dots,x_{n-1},\infty).
$$

### Joint PDF (continuous case)

$$
\boxed{
f_{X_1,\dots,X_n}(x_1,\dots,x_n)
=
\frac{\partial^n F_{X_1,\dots,X_n}(x_1,\dots,x_n)}
{\partial x_1\cdots\partial x_n}
}
$$

For any set $A$,

$$
\boxed{
P[\vec X\in A]
=\int\cdots\int_A
f_{X_1,\dots,X_n}(x_1,\dots,x_n)\,dx_1\cdots dx_n
}
$$

### Joint PMF (discrete case)

$$
\boxed{
p_{X_1,\dots,X_n}(k_1,\dots,k_n)
=P[X_1=k_1,\dots,X_n=k_n]
}
$$

For any set $A$,

$$
\boxed{
P[\vec X\in A]
=\sum_{(k_1,\dots,k_n)\in A}
p_{X_1,\dots,X_n}(k_1,\dots,k_n)
}
$$

---

## 2. The multinomial distribution

The multinomial distribution generalizes the binomial distribution from two outcomes to $m$ outcomes.

Suppose each trial produces exactly one of $m$ outcomes, with probabilities

$$
p_1,p_2,\dots,p_m,
\qquad
p_1+\cdots+p_m=1.
$$

Let $X_j$ be the number of times outcome $j$ occurs in $n$ independent trials. Then

$$
X_1+\cdots+X_m=n.
$$

The joint pmf is

$$
\boxed{
p_{X_1,\dots,X_m}(k_1,\dots,k_m)
=
\frac{n!}{k_1!k_2!\cdots k_m!}
p_1^{k_1}p_2^{k_2}\cdots p_m^{k_m}
}
$$

if $k_1+\cdots+k_m=n$ and each $k_i\ge0$; otherwise it is zero.

> [!Example]
> **Rolling a die 10 times.** Let $X_j$ be the number of times face $j$ appears, with $p_j=1/6$. Then
> $$
> P[X_1=k_1,\dots,X_6=k_6]
> =
> \frac{10!}{k_1!\cdots k_6!}
> \left(\frac16\right)^{10}
> $$
> whenever $k_1+\cdots+k_6=10$.

---

## 3. Marginal distributions

To eliminate one variable, integrate it out (continuous) or sum it out (discrete).

For example,

$$
\boxed{
f_{X_1,\dots,X_{n-1}}(x_1,\dots,x_{n-1})
=
\int_{-\infty}^{\infty}
f_{X_1,\dots,X_n}(x_1,\dots,x_n)\,dx_n
}
$$

and

$$
\boxed{
p_{X_1,\dots,X_{n-1}}(k_1,\dots,k_{n-1})
=
\sum_{k_n=-\infty}^{\infty}
p_{X_1,\dots,X_n}(k_1,\dots,k_n)
}.
$$

Repeated integration/summation gives any marginal:

$$
f_{X_1}(x_1)
=
\int_{-\infty}^{\infty}\cdots\int_{-\infty}^{\infty}
f_{X_1,\dots,X_n}(x_1,x_2,\dots,x_n)
\,dx_2\cdots dx_n.
$$

> [!Example]
> **Computer system with three lines.** Let $X_j$ be the number of messages received on line $j$ in one hour. Suppose
> $$
> p_{X_1,X_2,X_3}(k_1,k_2,k_3)
> =
> (1-a_1)(1-a_2)(1-a_3)
> a_1^{k_1}a_2^{k_2}a_3^{k_3}
> $$
> for $k_1,k_2,k_3\ge0$, with $0<a_i<1$, and zero otherwise.
>
> **Find $p_{X_1,X_2}(k_1,k_2)$.** Sum over $k_3$:
> $$
> \begin{aligned}
> p_{X_1,X_2}(k_1,k_2)
> &=(1-a_1)(1-a_2)(1-a_3)a_1^{k_1}a_2^{k_2}
> \sum_{k_3=0}^{\infty}a_3^{k_3}\\
> &=(1-a_1)(1-a_2)(1-a_3)a_1^{k_1}a_2^{k_2}
> \cdot\frac{1}{1-a_3}\\
> &=(1-a_1)(1-a_2)a_1^{k_1}a_2^{k_2}.
> \end{aligned}
> $$
>
> **Find $p_{X_1}(k_1)$.** Sum over $k_2$:
> $$
> \begin{aligned}
> p_{X_1}(k_1)
> &=(1-a_1)(1-a_2)a_1^{k_1}
> \sum_{k_2=0}^{\infty}a_2^{k_2}\\
> &=(1-a_1)(1-a_2)a_1^{k_1}\cdot\frac{1}{1-a_2}\\
> &=(1-a_1)a_1^{k_1}.
> \end{aligned}
> $$
>
> So each $X_j$ is geometric on $\{0,1,2,\dots\}$.

---

## 4. Conditional distributions

For continuous variables,

$$
\boxed{
f_{X_1,X_2\mid X_3}(x_1,x_2\mid x_3)
=
\frac{f_{X_1,X_2,X_3}(x_1,x_2,x_3)}
{f_{X_3}(x_3)}
}
$$

and

$$
\boxed{
f_{X_1\mid X_2,X_3}(x_1\mid x_2,x_3)
=
\frac{f_{X_1,X_2,X_3}(x_1,x_2,x_3)}
{f_{X_2,X_3}(x_2,x_3)}
}.
$$

For discrete variables, replace $f$ by $p$:

$$
\boxed{
p_{X_1,X_2\mid X_3}(k_1,k_2\mid k_3)
=
\frac{p_{X_1,X_2,X_3}(k_1,k_2,k_3)}
{p_{X_3}(k_3)}
}
$$

$$
\boxed{
p_{X_1\mid X_2,X_3}(k_1\mid k_2,k_3)
=
\frac{p_{X_1,X_2,X_3}(k_1,k_2,k_3)}
{p_{X_2,X_3}(k_2,k_3)}
}.
$$

### Chain rule

The product rule extends to a chain:

$$
\boxed{
p_{X_1,X_2,X_3}(k_1,k_2,k_3)
=
p_{X_1\mid X_2,X_3}(k_1\mid k_2,k_3)
\,p_{X_2\mid X_3}(k_2\mid k_3)
\,p_{X_3}(k_3)
}
$$

and similarly for densities:

$$
\boxed{
f_{X_1,X_2,X_3}(x_1,x_2,x_3)
=
f_{X_1\mid X_2,X_3}(x_1\mid x_2,x_3)
\,f_{X_2\mid X_3}(x_2\mid x_3)
\,f_{X_3}(x_3)
}.
$$

This gives a sequential generation recipe:

1. Generate $X_3$.
2. Given $X_3$, generate $X_2$.
3. Given $X_2,X_3$, generate $X_1$.

---

## 5. Independence of $n$ variables

The following are equivalent:

1. $X_1,\dots,X_n$ are independent:

$$
\boxed{
P[X_1\in A_1,\dots,X_n\in A_n]
=
P[X_1\in A_1]\cdots P[X_n\in A_n]
}
$$

for all sets $A_1,\dots,A_n$.

2. The joint CDF factors:

$$
\boxed{
F_{X_1,\dots,X_n}(x_1,\dots,x_n)
=
F_{X_1}(x_1)\cdots F_{X_n}(x_n)
}
$$

3. The joint PDF/PMF factors:

$$
\boxed{
f_{X_1,\dots,X_n}(x_1,\dots,x_n)
=
f_{X_1}(x_1)\cdots f_{X_n}(x_n)
}
$$

or

$$
\boxed{
p_{X_1,\dots,X_n}(k_1,\dots,k_n)
=
p_{X_1}(k_1)\cdots p_{X_n}(k_n)
}.
$$

> **Warning:** pairwise independence does **not** imply mutual independence for three or more variables in general. The full joint distribution must factor.

---

## 6. Mean vector and linearity

The expectation of a vector is taken element by element:

$$
\boxed{
E[\vec X]
=
\begin{pmatrix}
E[X_1]\\
\vdots\\
E[X_n]
\end{pmatrix}
}
$$

The expectation of a matrix is also element by element.

Linearity holds:

$$
\boxed{
E\left[a_0+\sum_{i=1}^{n}a_iX_i\right]
=a_0+\sum_{i=1}^{n}a_iE[X_i]
}
$$

Again, nonlinear functions do not commute with expectation:

$$
E[g(X_1,\dots,X_n)]
\ne
g(E[X_1],\dots,E[X_n])
\quad\text{in general}.
$$

---

## 7. Correlation matrix

The **correlation matrix** $\mathbf R$ contains all pairwise correlations $E[X_iX_j]$:

$$
\boxed{
\mathbf R=E[\vec X\vec X^T]
=
\begin{pmatrix}
E[X_1X_1] & E[X_1X_2] & \cdots & E[X_1X_n]\\
E[X_2X_1] & E[X_2X_2] & \cdots & E[X_2X_n]\\
\vdots & \vdots & \ddots & \vdots\\
E[X_nX_1] & E[X_nX_2] & \cdots & E[X_nX_n]
\end{pmatrix}
}
$$

with entries

$$
\boxed{R_{ij}=E[X_iX_j]}.
$$

---

## 8. Covariance matrix

The **covariance matrix** $\mathbf C$ (also denoted $\mathbf K$ or $\boldsymbol\Sigma$) contains all pairwise covariances:

$$
\boxed{
\mathbf C
=E\left[(\vec X-E[\vec X])(\vec X-E[\vec X])^T\right]
}
$$

$$
=
\begin{pmatrix}
\operatorname{Var}(X_1) & \operatorname{Cov}(X_1,X_2) & \cdots & \operatorname{Cov}(X_1,X_n)\\
\operatorname{Cov}(X_2,X_1) & \operatorname{Var}(X_2) & \cdots & \operatorname{Cov}(X_2,X_n)\\
\vdots & \vdots & \ddots & \vdots\\
\operatorname{Cov}(X_n,X_1) & \operatorname{Cov}(X_n,X_2) & \cdots & \operatorname{Var}(X_n)
\end{pmatrix}.
$$

Equivalently,

$$
\boxed{
C_{ij}=
\begin{cases}
\operatorname{Var}(X_i),&i=j,\\
\operatorname{Cov}(X_i,X_j),&i\ne j.
\end{cases}
}
$$

### Relationship between $\mathbf R$ and $\mathbf C$

$$
\boxed{
\mathbf C=\mathbf R-E[\vec X]E[\vec X]^T
}.
$$

If the mean vector is zero, then

$$
\mathbf C=\mathbf R.
$$

### Properties

1. **Symmetric:**
$$
C_{ij}=C_{ji}.
$$

2. **Diagonal if and only if the variables are uncorrelated:**

$$
\mathbf C\ \text{is diagonal}
\iff
\operatorname{Cov}(X_i,X_j)=0
\quad\text{for all }i\ne j.
$$

The diagonal entries are the variances.

3. **Positive semidefinite:** for any vector $\vec a$,
$$
\vec a^T\mathbf C\vec a\ge0.
$$
(This is a consequence of covariance being an expected squared projection.)

---

## 9. Jointly Gaussian random vectors

$X_1,\dots,X_n$ are **jointly Gaussian** if their joint density is

$$
\boxed{
f_{\vec X}(\vec x)
=
\frac{1}{(2\pi)^{n/2}\sqrt{|\mathbf C|}}
\exp\left[
-\frac12(\vec x-\vec m)^T\mathbf C^{-1}(\vec x-\vec m)
\right]
}
$$

where

$$
\vec m=E[\vec X],
\qquad
\mathbf C=\text{covariance matrix of }\vec X,
\qquad
|\mathbf C|=\det(\mathbf C).
$$

A jointly Gaussian vector is **completely specified** by its mean vector and covariance matrix.

> **Notation check:** the denominator is $(2\pi)^{n/2}\sqrt{|\mathbf C|}$. For $n=1$, $\mathbf C=\sigma^2$, and this becomes $\sqrt{2\pi}\sigma$, matching the scalar Gaussian formula.

---

## 10. Worked example: building $\mathbf C$ from moments

Suppose $X_1,X_2,X_3$ are jointly Gaussian with

$$
E[X_1]=5,\quad E[X_2]=3,\quad E[X_3]=2,
$$

$$
E[X_1^2]=31,\quad E[X_2^2]=13,\quad E[X_3^2]=11,
$$

$$
E[X_1X_2]=16,\quad E[X_1X_3]=13,\quad E[X_2X_3]=8.
$$

The mean vector is

$$
\vec m=
\begin{pmatrix}
5\\
3\\
2
\end{pmatrix}.
$$

The correlation matrix is

$$
\mathbf R=
\begin{pmatrix}
31 & 16 & 13\\
16 & 13 & 8\\
13 & 8 & 11
\end{pmatrix}.
$$

The covariance matrix is

$$
\begin{aligned}
\mathbf C
&=\mathbf R-\vec m\vec m^T\\
&=
\begin{pmatrix}
31 & 16 & 13\\
16 & 13 & 8\\
13 & 8 & 11
\end{pmatrix}
-
\begin{pmatrix}
5\\3\\2
\end{pmatrix}
\begin{pmatrix}
5&3&2
\end{pmatrix}\\
&=
\begin{pmatrix}
31 & 16 & 13\\
16 & 13 & 8\\
13 & 8 & 11
\end{pmatrix}
-
\begin{pmatrix}
25 & 15 & 10\\
15 & 9 & 6\\
10 & 6 & 4
\end{pmatrix}\\
&=
\begin{pmatrix}
6 & 1 & 3\\
1 & 4 & 2\\
3 & 2 & 7
\end{pmatrix}.
\end{aligned}
$$

Thus

$$
\boxed{
\vec m=
\begin{pmatrix}5\\3\\2\end{pmatrix},
\qquad
\mathbf C=
\begin{pmatrix}
6&1&3\\
1&4&2\\
3&2&7
\end{pmatrix}
}.
$$

The joint density is obtained by substituting these into the multivariate Gaussian formula.

---

## 11. Properties of Gaussian random vectors

Assume $X_1,\dots,X_n$ are jointly Gaussian.

1. **Any subset is jointly Gaussian.** For example, $(X_1,X_3)$ is jointly Gaussian.

2. **Marginals are Gaussian.** In particular, every $X_i$ is Gaussian.

3. **Uncorrelated implies independent.** If all pairwise covariances are zero (i.e. $\mathbf C$ is diagonal), then the variables are independent.

4. **Conditional distributions are Gaussian.** Conditioning any subset on any other subset gives a Gaussian distribution.

5. **Affine transformations are Gaussian.** If $\vec Y=\mathbf A\vec X+\vec b$, then $\vec Y$ is jointly Gaussian.

> **Shortcut:** for affine transformations, compute the new mean vector and covariance matrix:
> $$
> \boxed{E[\vec Y]=\mathbf A E[\vec X]+\vec b}
> $$
> $$
> \boxed{\operatorname{Cov}(\vec Y)=\mathbf A\,\mathbf C\,\mathbf A^T}.
> $$
> Then use the Gaussian formula.

> [!Example]
> **Independent standard normals.** If $X_1,\dots,X_n$ are independent and each $X_i\sim\mathcal N(0,1)$, then
> $$
> f_{X_1,\dots,X_n}(x_1,\dots,x_n)
> =\prod_{i=1}^{n}\frac{1}{\sqrt{2\pi}}e^{-x_i^2/2}
> =
> \frac{1}{(2\pi)^{n/2}}
> \exp\left[-\frac12\sum_{i=1}^{n}x_i^2\right].
> $$
> This is the multivariate standard normal density with
> $$
> \vec m=\vec 0,
> \qquad
> \mathbf C=\mathbf I_n.
> $$

> [!Example]
> **Marginal of a subset.** Using the $\vec m$ and $\mathbf C$ from the previous example, the pair $(X_1,X_3)$ has
> $$
> \vec m_{13}=
> \begin{pmatrix}5\\2\end{pmatrix},
> \qquad
> \mathbf C_{13}=
> \begin{pmatrix}
> 6&3\\
> 3&7
> \end{pmatrix}.
> $$
> Since the pair is jointly Gaussian, its density is
> $$
> f_{X_1,X_3}(x_1,x_3)
> =
> \frac{1}{2\pi\sqrt{|\mathbf C_{13}|}}
> \exp\left[
> -\frac12
> (\vec x_{13}-\vec m_{13})^T
> \mathbf C_{13}^{-1}
> (\vec x_{13}-\vec m_{13})
> \right].
> $$
> You do not need to integrate the three-dimensional density.

---

## 12. Conditional density of two Gaussians

For jointly Gaussian $X,Y$,

$$
\boxed{
X\mid Y=y
\sim
\mathcal N\left(
m_X+\rho\frac{\sigma_X}{\sigma_Y}(y-m_Y),
\ \sigma_X^2(1-\rho^2)
\right)
}.
$$

Equivalently,

$$
\boxed{
f_{X\mid Y}(x\mid y)
=
\frac{1}{\sqrt{2\pi\operatorname{Var}(X\mid y)}}
\exp\left[
-\frac{(x-E[X\mid y])^2}{2\operatorname{Var}(X\mid y)}
\right]
}
$$

where

$$
E[X\mid y]=m_X+\rho\frac{\sigma_X}{\sigma_Y}(y-m_Y),
$$

$$
\operatorname{Var}(X\mid y)=\sigma_X^2(1-\rho^2).
$$

This is the same conditional Gaussian formula as in Lecture 17. The multivariate version is

$$
E[\vec X_1\mid \vec X_2=\vec x_2]
=\vec m_1+\mathbf C_{12}\mathbf C_{22}^{-1}(\vec x_2-\vec m_2),
$$

$$
\operatorname{Cov}(\vec X_1\mid \vec X_2=\vec x_2)
=\mathbf C_{11}-\mathbf C_{12}\mathbf C_{22}^{-1}\mathbf C_{21}.
$$

---

## 13. Common mistakes

1. **Confusing $\mathbf R$ and $\mathbf C$.** $\mathbf R=E[\vec X\vec X^T]$ contains raw second moments; $\mathbf C$ contains central second moments.
2. **Using $\mathbf C=\mathbf R-\vec m\vec m^T$ with the wrong order.** It is $\vec m\vec m^T$, an $n\times n$ matrix, not $\vec m^T\vec m$, a scalar.
3. **Thinking a diagonal covariance matrix means independence for any variables.** It means uncorrelated; independence follows only for jointly Gaussian vectors.
4. **Assuming pairwise independence is enough.** Mutual independence requires the full joint factorization.
5. **Forgetting that a subset of a Gaussian vector is Gaussian.** This is a powerful shortcut.
6. **Applying the multivariate Gaussian formula with a singular $\mathbf C$.** Then $|\mathbf C|=0$ and $\mathbf C^{-1}$ does not exist; the density is degenerate (supported on a lower-dimensional set).
7. **Mixing up the conditioning subsets.** In the general conditional formulas, the covariance blocks must match the partition of the vector.

---

## 14. 60-second summary

$$
\boxed{
F_{\vec X}(\vec x)=P[X_1\le x_1,\dots,X_n\le x_n]
}
$$

$$
\boxed{
f_{\vec X}(\vec x)=
\frac{\partial^n F}{\partial x_1\cdots\partial x_n}
}
$$

$$
\boxed{
p_{X_1,\dots,X_m}(k_1,\dots,k_m)
=
\frac{n!}{k_1!\cdots k_m!}
p_1^{k_1}\cdots p_m^{k_m}
}
$$

$$
\boxed{
\mathbf R=E[\vec X\vec X^T],
\qquad
\mathbf C=E[(\vec X-E\vec X)(\vec X-E\vec X)^T]
}
$$

$$
\boxed{
\mathbf C=\mathbf R-E[\vec X]E[\vec X]^T
}
$$

$$
\boxed{
f_{\vec X}(\vec x)
=
\frac{1}{(2\pi)^{n/2}\sqrt{|\mathbf C|}}
\exp\left[
-\frac12(\vec x-\vec m)^T\mathbf C^{-1}(\vec x-\vec m)
\right]
}
$$

For jointly Gaussian vectors:

$$
\boxed{
\text{uncorrelated}\iff\text{independent}
}
$$

$$
\boxed{
E[\mathbf A\vec X+\vec b]=\mathbf A E[\vec X]+\vec b
}
$$

$$
\boxed{
\operatorname{Cov}(\mathbf A\vec X+\vec b)
=\mathbf A\,\operatorname{Cov}(\vec X)\,\mathbf A^T
}
$$
