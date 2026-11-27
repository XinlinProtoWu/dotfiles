# Lecture 17: Pairs of Jointly Gaussian Random Variables

> **Big picture.** The Gaussian is the most important continuous distribution in engineering. A pair of **jointly Gaussian** variables has a bell-shaped joint density whose contours are ellipses. The whole distribution is determined by only five numbers: two means, two variances, and the correlation coefficient. Many operations on jointly Gaussian variables produce Gaussian variables, so we often only need to update means and variances.

---

## Learning goals

By the end of this lecture you should be able to:

1. Write the univariate Gaussian density.
2. Write the bivariate Gaussian density in scalar and vector form.
3. Build the mean vector and covariance matrix.
4. Interpret the correlation coefficient through contour plots.
5. Use the key closure properties of jointly Gaussian variables.
6. Find means and variances of affine combinations without integrating.
7. Use the conditional Gaussian formulas.

---

## 1. Single Gaussian random variable

$X$ is Gaussian (normal) with mean $m$ and variance $\sigma^2$ if

$$
\boxed{
f_X(x)=\frac{1}{\sqrt{2\pi}\,\sigma}
\exp\left[-\frac{(x-m)^2}{2\sigma^2}\right],
\qquad -\infty<x<\infty.
}
$$

Notation:

$$
X\sim\mathcal N(m,\sigma^2).
$$

Properties:

$$
E[X]=m,
\qquad
\operatorname{Var}(X)=\sigma^2.
$$

The density is a bell curve centered at $m$. The standard deviation $\sigma$ controls the width: about $68\%$ of the probability lies within one standard deviation of the mean.

> **Warning:** the second parameter in $\mathcal N(m,\sigma^2)$ is the **variance**, not the standard deviation.

---

## 2. Bivariate Gaussian density

Let $X_1$ and $X_2$ be jointly Gaussian with

$$
E[X_i]=m_i,
\qquad
\operatorname{Var}(X_i)=\sigma_i^2,
\qquad
\rho=\rho_{X_1,X_2}.
$$

Then

$$
\boxed{
\begin{aligned}
&f_{X_1,X_2}(x_1,x_2)\\
&=\frac{1}{2\pi\sigma_1\sigma_2\sqrt{1-\rho^2}}
\exp\left\{
-\frac{1}{2(1-\rho^2)}
\left[
\frac{(x_1-m_1)^2}{\sigma_1^2}
-2\rho\frac{(x_1-m_1)(x_2-m_2)}{\sigma_1\sigma_2}
+\frac{(x_2-m_2)^2}{\sigma_2^2}
\right]
\right\}.
\end{aligned}
}
$$

The joint density is a bell-shaped **hill** centered at

$$
(m_1,m_2).
$$

The contours of constant density are ellipses.

> **Check the special case.** If $\rho=0$ and $\sigma_1=\sigma_2=1$, then
> $$
> f_{X_1,X_2}(x_1,x_2)
> =\frac{1}{2\pi}
> \exp\left[-\frac{x_1^2+x_2^2}{2}\right],
> $$
> which is a circularly symmetric bell centered at the origin.

---

## 3. Vector notation

Define the random vector

$$
\vec X=
\begin{pmatrix}
X_1\\
X_2
\end{pmatrix},
\qquad
\vec x=
\begin{pmatrix}
x_1\\
x_2
\end{pmatrix}.
$$

The **mean vector** is

$$
\boxed{
\vec m=E[\vec X]
=
\begin{pmatrix}
E[X_1]\\
E[X_2]
\end{pmatrix}
=
\begin{pmatrix}
m_1\\
m_2
\end{pmatrix}
}.
$$

The **covariance matrix** is

$$
\boxed{
\mathbf C
=E\left[(\vec X-E[\vec X])(\vec X-E[\vec X])^T\right]
=
\begin{pmatrix}
\operatorname{Var}(X_1) & \operatorname{Cov}(X_1,X_2)\\
\operatorname{Cov}(X_2,X_1) & \operatorname{Var}(X_2)
\end{pmatrix}
=
\begin{pmatrix}
\sigma_1^2 & \rho\sigma_1\sigma_2\\
\rho\sigma_1\sigma_2 & \sigma_2^2
\end{pmatrix}
}.
$$

The determinant is

$$
\boxed{
|\mathbf C|
=\sigma_1^2\sigma_2^2(1-\rho^2)
}.
$$

The inverse is

$$
\mathbf C^{-1}
=
\frac{1}{(1-\rho^2)\sigma_1^2\sigma_2^2}
\begin{pmatrix}
\sigma_2^2 & -\rho\sigma_1\sigma_2\\
-\rho\sigma_1\sigma_2 & \sigma_1^2
\end{pmatrix}.
$$

Then the bivariate Gaussian density can be written compactly as

$$
\boxed{
f_{\vec X}(\vec x)
=
\frac{1}{(2\pi)^{n/2}\sqrt{|\mathbf C|}}
\exp\left[
-\frac12(\vec x-\vec m)^T\mathbf C^{-1}(\vec x-\vec m)
\right],
\qquad n=2.
}
$$

For general dimension $n$, the same formula holds with $n\times n$ mean vector and covariance matrix.

> **Memory aid:** in one dimension, the exponent is $-(x-m)^2/(2\sigma^2)$ and the constant is $1/(\sqrt{2\pi}\sigma)$. In $n$ dimensions, the exponent becomes a quadratic form with $\mathbf C^{-1}$, and $\sigma$ becomes $\sqrt{|\mathbf C|}$.

---

## 4. Contour diagrams

The contours of a bivariate Gaussian are ellipses centered at $(m_1,m_2)$.

- If $\rho=0$ and $\sigma_1=\sigma_2$, the contours are **circles**.
- If $\rho=0$ but $\sigma_1\ne\sigma_2$, the ellipses are **axis-aligned**.
- If $\rho>0$, the ellipses tilt **upward to the right** (positive slope).
- If $\rho<0$, the ellipses tilt **downward to the right** (negative slope).
- Larger $|\rho|$ means narrower, more elongated ellipses.
- Larger variances mean larger ellipses.

> [!Example]
> Let $m_1=m_2=0$, $\sigma_1^2=\sigma_2^2=2$, and $\rho=0.75$. The contours are elongated ellipses tilted along the line $x_2=x_1$.
>
> The conditional distribution of $X_1$ given $X_2=y$ has mean
> $$
> E[X_1\mid X_2=y]=\rho\frac{\sigma_1}{\sigma_2}y=0.75y,
> $$
> and variance
> $$
> \operatorname{Var}(X_1\mid X_2=y)
> =\sigma_1^2(1-\rho^2)
> =2(1-0.75^2)=0.875.
> $$
> So knowing $X_2$ shifts the mean of $X_1$ and shrinks its variance.

---

## 5. Key properties of jointly Gaussian variables

Assume $X_1$ and $X_2$ are jointly Gaussian.

### Property 1: Marginals are Gaussian

$X_1$ and $X_2$ are each Gaussian. In fact,

$$
X_1\sim\mathcal N(m_1,\sigma_1^2),
\qquad
X_2\sim\mathcal N(m_2,\sigma_2^2).
$$

### Property 2: Uncorrelated implies independent

For jointly Gaussian variables,

$$
\boxed{
\rho=0
\iff
X_1\text{ and }X_2\text{ are independent}.
}
$$

This is special to the Gaussian case. For general random variables, uncorrelated does not imply independent.

### Property 3: Conditional densities are Gaussian

$$
X_1\mid X_2=y
\sim
\mathcal N\left(
m_1+\rho\frac{\sigma_1}{\sigma_2}(y-m_2),
\ \sigma_1^2(1-\rho^2)
\right).
$$

Similarly,

$$
X_2\mid X_1=x
\sim
\mathcal N\left(
m_2+\rho\frac{\sigma_2}{\sigma_1}(x-m_1),
\ \sigma_2^2(1-\rho^2)
\right).
$$

### Property 4: Affine combinations are Gaussian

If

$$
Y=aX_1+bX_2+c,
$$

then $Y$ is Gaussian, with

$$
\boxed{
E[Y]=aE[X_1]+bE[X_2]+c
}
$$

and

$$
\boxed{
\operatorname{Var}(Y)
=a^2\operatorname{Var}(X_1)
+2ab\operatorname{Cov}(X_1,X_2)
+b^2\operatorname{Var}(X_2)
}.
$$

This is why we usually do **not** need to integrate to find the density of a linear combination: just compute its mean and variance, then plug into the Gaussian formula.

> **Important nuance:** "each variable is Gaussian" is not enough to conclude they are **jointly** Gaussian. Joint Gaussian is a stronger statement about the joint density. The nice properties above assume **joint** Gaussianity.

---

## 6. Worked example: marginal of a bivariate Gaussian

Suppose

$$
f_{X,Y}(x,y)
=
\frac{1}{2\pi\sqrt{1-\rho^2}}
\exp\left[
-\frac{x^2-2\rho xy+y^2}{2(1-\rho^2)}
\right].
$$

This is the standard bivariate Gaussian with $m_X=m_Y=0$ and $\sigma_X^2=\sigma_Y^2=1$.

Find $f_X(x)$:

$$
f_X(x)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dy.
$$

Complete the square in $y$:

$$
x^2-2\rho xy+y^2
=(y-\rho x)^2+x^2(1-\rho^2).
$$

Then

$$
\begin{aligned}
f_X(x)
&=\frac{1}{2\pi\sqrt{1-\rho^2}}
e^{-x^2/2}
\int_{-\infty}^{\infty}
\exp\left[-\frac{(y-\rho x)^2}{2(1-\rho^2)}\right]dy\\
&=\frac{1}{\sqrt{2\pi}}e^{-x^2/2}.
\end{aligned}
$$

The integral equals $\sqrt{2\pi(1-\rho^2)}$, which cancels the prefactor. Thus

$$
\boxed{
X\sim\mathcal N(0,1)
}.
$$

By symmetry, $Y\sim\mathcal N(0,1)$ as well.

---

## 7. Uncorrelated jointly Gaussian variables are independent

Set $\rho=0$ in the bivariate density:

$$
\begin{aligned}
f_{X_1,X_2}(x_1,x_2)
&=\frac{1}{2\pi\sigma_1\sigma_2}
\exp\left[
-\frac{(x_1-m_1)^2}{2\sigma_1^2}
-\frac{(x_2-m_2)^2}{2\sigma_2^2}
\right]\\
&=
\frac{1}{\sqrt{2\pi}\sigma_1}
e^{-(x_1-m_1)^2/(2\sigma_1^2)}
\cdot
\frac{1}{\sqrt{2\pi}\sigma_2}
e^{-(x_2-m_2)^2/(2\sigma_2^2)}\\
&=f_{X_1}(x_1)f_{X_2}(x_2).
\end{aligned}
$$

The joint density factors into the product of the marginals, so

$$
\boxed{
\rho=0
\Longrightarrow
X_1\perp X_2
}
$$

for jointly Gaussian variables.

Equivalently, the covariance matrix is diagonal:

$$
\mathbf C=
\begin{pmatrix}
\sigma_1^2 & 0\\
0 & \sigma_2^2
\end{pmatrix}.
$$

---

## 8. Sum of independent Gaussian variables

Let

$$
X_1\sim\mathcal N(m_1,\sigma_1^2),
\qquad
X_2\sim\mathcal N(m_2,\sigma_2^2)
$$

be independent, and let

$$
Z=X_1+X_2.
$$

We can find the density by convolution:

$$
f_Z(z)=\int_{-\infty}^{\infty}f_{X_1}(x)f_{X_2}(z-x)\,dx.
$$

After completing the square, the result is

$$
\boxed{
Z\sim\mathcal N(m_1+m_2,\ \sigma_1^2+\sigma_2^2)
}.
$$

If $X_1$ and $X_2$ are jointly Gaussian but correlated, the sum is still Gaussian, with

$$
\boxed{
Z\sim\mathcal N\left(
m_1+m_2,\
\sigma_1^2+2\rho\sigma_1\sigma_2+\sigma_2^2
\right)
}.
$$

> **Shortcut:** do not integrate. Use
> $$
> E[Z]=m_1+m_2,
> $$
> $$
> \operatorname{Var}(Z)
> =\sigma_1^2+2\operatorname{Cov}(X_1,X_2)+\sigma_2^2,
> $$
> and the fact that $Z$ is Gaussian.

---

## 9. Worked example: affine function of two Gaussian variables

Suppose $X_1,X_2$ are jointly Gaussian with

$$
E[X_1]=1,\quad \operatorname{Var}(X_1)=4,
$$

$$
E[X_2]=-2,\quad \operatorname{Var}(X_2)=9,
$$

$$
\rho=0.5.
$$

Let

$$
Y=-2X_1+X_2+3.
$$

### Mean

$$
E[Y]=-2E[X_1]+E[X_2]+3
=-2(1)+(-2)+3=-1.
$$

### Covariance

$$
\operatorname{Cov}(X_1,X_2)
=\rho\sigma_1\sigma_2
=0.5\cdot2\cdot3=3.
$$

### Variance

$$
\begin{aligned}
\operatorname{Var}(Y)
&=(-2)^2\operatorname{Var}(X_1)
+2(-2)(1)\operatorname{Cov}(X_1,X_2)
+(1)^2\operatorname{Var}(X_2)\\
&=4(4)-4(3)+9\\
&=16-12+9\\
&=13.
\end{aligned}
$$

### Density

Since $Y$ is an affine combination of jointly Gaussian variables, $Y$ is Gaussian:

$$
\boxed{
Y\sim\mathcal N(-1,13)
}.
$$

Therefore

$$
\boxed{
f_Y(y)=\frac{1}{\sqrt{2\pi\cdot13}}
\exp\left[-\frac{(y+1)^2}{2\cdot13}\right]
}.
$$

---

## 10. Conditional Gaussian formulas

For jointly Gaussian $X,Y$ with means $m_X,m_Y$, standard deviations $\sigma_X,\sigma_Y$, and correlation $\rho$:

$$
\boxed{
E[X\mid Y=y]
=m_X+\rho\frac{\sigma_X}{\sigma_Y}(y-m_Y)
}
$$

and

$$
\boxed{
\operatorname{Var}(X\mid Y=y)
=\sigma_X^2(1-\rho^2)
}.
$$

Interpretation:

- The conditional mean is a **linear** function of the observation $y$.
- The term $\rho\frac{\sigma_X}{\sigma_Y}$ converts units of $Y$ into units of $X$.
- The conditional variance is **smaller** than $\sigma_X^2$ unless $|\rho|=1$.
- If $\rho=0$, then $E[X\mid Y=y]=m_X$ and $\operatorname{Var}(X\mid Y=y)=\sigma_X^2$: knowing $Y$ tells us nothing.

For a general Gaussian vector, the same idea becomes

$$
E[\vec X_1\mid \vec X_2=\vec x_2]
=\vec m_1+\mathbf C_{12}\mathbf C_{22}^{-1}(\vec x_2-\vec m_2),
$$

$$
\operatorname{Cov}(\vec X_1\mid \vec X_2=\vec x_2)
=\mathbf C_{11}-\mathbf C_{12}\mathbf C_{22}^{-1}\mathbf C_{21}.
$$

---

## 11. Common mistakes

1. **Using $\sigma$ where $\sigma^2$ is needed.** The normalization has $\sigma_1\sigma_2$, while the exponent has $\sigma_1^2,\sigma_2^2$.
2. **Forgetting the factor $\sqrt{1-\rho^2}$.** It appears in both the prefactor and the exponent denominator.
3. **Confusing covariance and correlation.** $\operatorname{Cov}(X_1,X_2)=\rho\sigma_1\sigma_2$.
4. **Saying uncorrelated implies independent for any variables.** This is only true for jointly Gaussian variables.
5. **Assuming marginals Gaussian implies joint Gaussian.** False in general.
6. **Integrating when a shortcut exists.** For affine combinations of jointly Gaussian variables, compute mean and variance only.
7. **Thinking conditional variance is zero.** It is $\sigma_X^2(1-\rho^2)$, which is zero only when $|\rho|=1$.

---

## 12. 60-second summary

$$
\boxed{
f_X(x)=\frac{1}{\sqrt{2\pi}\sigma}
e^{-(x-m)^2/(2\sigma^2)}
}
$$

$$
\boxed{
\mathbf C=
\begin{pmatrix}
\sigma_1^2 & \rho\sigma_1\sigma_2\\
\rho\sigma_1\sigma_2 & \sigma_2^2
\end{pmatrix},
\qquad
|\mathbf C|=(1-\rho^2)\sigma_1^2\sigma_2^2
}
$$

$$
\boxed{
f_{\vec X}(\vec x)
=\frac{1}{(2\pi)^{n/2}\sqrt{|\mathbf C|}}
\exp\left[-\frac12(\vec x-\vec m)^T\mathbf C^{-1}(\vec x-\vec m)\right]
}
$$

For jointly Gaussian variables:

$$
\boxed{
\rho=0\iff X_1\perp X_2
}
$$

$$
\boxed{
Y=aX_1+bX_2+c
\ \text{is Gaussian}
}
$$

$$
\boxed{
E[Y]=aE[X_1]+bE[X_2]+c
}
$$

$$
\boxed{
\operatorname{Var}(Y)
=a^2\operatorname{Var}(X_1)
+2ab\operatorname{Cov}(X_1,X_2)
+b^2\operatorname{Var}(X_2)
}
$$

$$
\boxed{
E[X\mid Y=y]
=m_X+\rho\frac{\sigma_X}{\sigma_Y}(y-m_Y)
}
$$

$$
\boxed{
\operatorname{Var}(X\mid Y=y)
=\sigma_X^2(1-\rho^2)
}
$$
