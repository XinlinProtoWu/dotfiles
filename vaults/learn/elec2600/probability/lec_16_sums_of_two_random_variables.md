# Lecture 16: Sums of Two Random Variables

> **Big picture.** Given the joint distribution of $X$ and $Y$, we want the distribution of $Z=X+Y$ (or a more general $Z=g(X,Y)$). For discrete variables we **sum over the pairs** that produce $Z=z$. For continuous variables we integrate over the region $g(x,y)\le z$ and differentiate. If $X$ and $Y$ are independent, the pdf of the sum is a **convolution** of their pdfs.

---

## Learning goals

By the end of this lecture you should be able to:

1. Find the pmf of $Z=X+Y$ for discrete variables.
2. Find the pdf of $Z=g(X,Y)$ using the CDF method.
3. Use the convolution formula for independent continuous variables.
4. Compute the mean and variance of sums and affine combinations.
5. Handle the integration limits correctly, especially when supports are bounded.

---

## 1. Sum of two discrete random variables

Suppose $X$ and $Y$ take integer values, and

$$
Z=X+Y.
$$

For each integer $k$,

$$
\boxed{p_Z(k)=P[Z=k]
=\sum_{i+j=k}p_{X,Y}(i,j)}
$$

where the sum is over all pairs $(i,j)$ with $i+j=k$.

Equivalently,

$$
p_Z(k)=\sum_{i=-\infty}^{\infty}p_{X,Y}(i,k-i).
$$

> [!Example]
> **Two fair dice.** Let $X,Y$ be the two die outcomes, independent and uniform on $\{1,\dots,6\}$. Then $Z=X+Y$ has pmf
>
> | $z$ | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
> |---|---|---|---|---|---|---|---|---|---|---|---|
> | $P[Z=z]$ | $\frac1{36}$ | $\frac2{36}$ | $\frac3{36}$ | $\frac4{36}$ | $\frac5{36}$ | $\frac6{36}$ | $\frac5{36}$ | $\frac4{36}$ | $\frac3{36}$ | $\frac2{36}$ | $\frac1{36}$ |
>
> The shape is triangular: there are more ways to get a sum near $7$.
>
> A compact formula is
> $$
> p_Z(k)=\frac{6-|k-7|}{36},\qquad k=2,3,\dots,12.
> $$

---

## 2. Independent discrete random variables: convolution

If $X$ and $Y$ are independent, then

$$
p_{X,Y}(i,j)=p_X(i)p_Y(j).
$$

Therefore

$$
\boxed{p_Z(k)=\sum_{i=-\infty}^{\infty}p_X(i)p_Y(k-i)}.
$$

This is the **discrete convolution** of the two pmfs.

> [!Example]
> **Independent nonnegative integer variables.** Suppose $X,Y$ take values in $\{0,1,2,\dots\}$ with
> $$
> P[X=n]=a_n,\qquad P[Y=n]=b_n.
> $$
> Then for $n\ge0$,
> $$
> \boxed{P[Z=n]=\sum_{k=0}^{n}a_kb_{n-k}},
> $$
> and $P[Z=n]=0$ for $n<0$.
>
> **Why the sum stops at $n$?** Because $a_k=0$ for $k<0$ and $b_{n-k}=0$ when $n-k<0$, i.e. when $k>n$.

> **Simple check:** if $X$ and $Y$ are independent Poisson with means $\lambda$ and $\mu$, the convolution gives $Z\sim\text{Poisson}(\lambda+\mu)$. This is a useful sanity check, though the full derivation is not required here.

---

## 3. General continuous transformation: the CDF method

Given $f_{X,Y}(x,y)$ and $Z=g(X,Y)$, use four steps.

### Step 1

Pick a real number $z$.

### Step 2

Find the region

$$
D_z=\{(x,y):g(x,y)\le z\}.
$$

### Step 3

Compute the CDF:

$$
\boxed{F_Z(z)=P[Z\le z]
=P[g(X,Y)\le z]
=\iint_{D_z}f_{X,Y}(x,y)\,dx\,dy}.
$$

### Step 4

Differentiate:

$$
\boxed{f_Z(z)=\frac{d}{dz}F_Z(z)}.
$$

This method works for any function $g$, not just sums. The hard part is usually drawing $D_z$ and setting up the limits.

---

## 4. Sum of two continuous random variables

Let

$$
Z=X+Y.
$$

Then

$$
D_z=\{(x,y):x+y\le z\}.
$$

For a fixed $x$, the condition $x+y\le z$ means

$$
y\le z-x.
$$

Therefore

$$
F_Z(z)=\int_{-\infty}^{\infty}\int_{-\infty}^{z-x}
f_{X,Y}(x,y)\,dy\,dx.
$$

Differentiate with respect to $z$. Using the Leibniz rule,

$$
\begin{aligned}
f_Z(z)
&=\frac{d}{dz}\int_{-\infty}^{\infty}\int_{-\infty}^{z-x}
f_{X,Y}(x,y)\,dy\,dx\\
&=\int_{-\infty}^{\infty}f_{X,Y}(x,z-x)\,dx.
\end{aligned}
$$

So

$$
\boxed{f_Z(z)=\int_{-\infty}^{\infty}f_{X,Y}(x,z-x)\,dx}.
$$

By symmetry, also

$$
f_Z(z)=\int_{-\infty}^{\infty}f_{X,Y}(z-y,y)\,dy.
$$

> **Geometric picture.** The event $X+Y\le z$ is the half-plane below the line $x+y=z$. Integrating the joint density over that half-plane gives the CDF; differentiating slides the line and gives the density along the line.

---

## 5. Convolution for independent continuous variables

If $X$ and $Y$ are independent, then

$$
f_{X,Y}(x,y)=f_X(x)f_Y(y).
$$

Substitute into the sum formula:

$$
\boxed{f_Z(z)=\int_{-\infty}^{\infty}f_X(x)f_Y(z-x)\,dx}.
$$

This is the **convolution integral**:

$$
\boxed{f_Z=f_X*f_Y}.
$$

> **Worth memorizing:** for independent continuous $X,Y$,
> $$
> f_{X+Y}(z)=\int_{-\infty}^{\infty}f_X(x)f_Y(z-x)\,dx.
> $$

> **Warning:** convolution is **not** ordinary multiplication. Also, the formula assumes independence. For dependent variables, use the joint density $f_{X,Y}(x,z-x)$.

---

## 6. Worked example: standby redundancy

A system has one operating component and one identical standby component. When the first fails, the second starts. The component lifetimes $X$ and $Y$ are independent exponential random variables with the same rate $\lambda$:

$$
f_X(x)=\lambda e^{-\lambda x}u(x),
\qquad
f_Y(y)=\lambda e^{-\lambda y}u(y).
$$

The system lifetime is

$$
Z=X+Y.
$$

For $z\ge0$,

$$
\begin{aligned}
f_Z(z)
&=\int_{-\infty}^{\infty}f_X(x)f_Y(z-x)\,dx\\
&=\int_0^z \lambda e^{-\lambda x}\cdot
\lambda e^{-\lambda(z-x)}\,dx\\
&=\lambda^2e^{-\lambda z}\int_0^z dx\\
&=\lambda^2 z e^{-\lambda z}.
\end{aligned}
$$

For $z<0$, $f_Z(z)=0$. Thus

$$
\boxed{f_Z(z)=\lambda^2 z e^{-\lambda z},\qquad z\ge0}.
$$

This is an **Erlang** density (a Gamma density with shape $2$ and rate $\lambda$).

Check the limits: the integrand is nonzero only when

$$
x\ge0
\quad\text{and}\quad
z-x\ge0\iff x\le z.
$$

So $x$ runs from $0$ to $z$, not from $-\infty$ to $\infty$.

---

## 7. Mean of a sum

For any $X,Y$,

$$
\boxed{E[X+Y]=E[X]+E[Y]}.
$$

For any finite collection,

$$
\boxed{E\left[\sum_{i=1}^{n}X_i\right]
=\sum_{i=1}^{n}E[X_i]}.
$$

This does **not** require independence.

---

## 8. Variance of a sum

For any $X,Y$,

$$
\boxed{\operatorname{Var}(X+Y)
=\operatorname{Var}(X)+2\operatorname{Cov}(X,Y)+\operatorname{Var}(Y)}.
$$

If $X$ and $Y$ are uncorrelated (in particular, if they are independent),

$$
\boxed{\operatorname{Var}(X+Y)=\operatorname{Var}(X)+\operatorname{Var}(Y)}.
$$

For the standby example, $X,Y$ are independent exponentials with variance $1/\lambda^2$, so

$$
E[Z]=\frac2\lambda,
\qquad
\operatorname{Var}(Z)=\frac2{\lambda^2}.
$$

Check this against the Erlang$(2,\lambda)$ density: mean $2/\lambda$, variance $2/\lambda^2$. Good.

---

## 9. Affine combinations

Let

$$
Z=aX+bY+c.
$$

Then

$$
\boxed{E[Z]=aE[X]+bE[Y]+c}.
$$

And

$$
\boxed{\operatorname{Var}(Z)
=a^2\operatorname{Var}(X)
+2ab\operatorname{Cov}(X,Y)
+b^2\operatorname{Var}(Y)}.
$$

The constant $c$ shifts the mean but does not change the variance.

> [!Example]
> **Find the mean and variance of $Z=5X+2Y+1$.**
> $$
> E[Z]=5E[X]+2E[Y]+1.
> $$
> $$
> \operatorname{Var}(Z)
> =25\operatorname{Var}(X)
> +20\operatorname{Cov}(X,Y)
> +4\operatorname{Var}(Y).
> $$
> If $X$ and $Y$ are uncorrelated, the covariance term disappears:
> $$
> \operatorname{Var}(Z)=25\operatorname{Var}(X)+4\operatorname{Var}(Y).
> $$

> **General rule:** for constants $a,b,c$,
> $$
> \boxed{\operatorname{Var}(aX+bY+c)
> =a^2\operatorname{Var}(X)+2ab\operatorname{Cov}(X,Y)+b^2\operatorname{Var}(Y)}.
> $$

---

## 10. Common mistakes

1. **Using the convolution formula without independence.** For dependent $X,Y$, use $f_{X,Y}(x,z-x)$, not $f_X(x)f_Y(z-x)$.
2. **Forgetting the support.** The limits $0$ to $z$ in the exponential example come from $x\ge0$ and $z-x\ge0$.
3. **Differentiating the CDF incorrectly.** Remember $F_Z(z)=\iint_{D_z}f_{X,Y}$, and the boundary of $D_z$ depends on $z$.
4. **Confusing pmf convolution with pdf convolution.** The discrete version is a sum; the continuous version is an integral.
5. **Assuming variance adds without checking correlation.** $\operatorname{Var}(X+Y)=\operatorname{Var}(X)+\operatorname{Var}(Y)$ only when $\operatorname{Cov}(X,Y)=0$.
6. **Dropping the constant in the mean.** $E[aX+bY+c]=aE[X]+bE[Y]+c$.
7. **Adding the constant into the variance.** $\operatorname{Var}(Z+c)=\operatorname{Var}(Z)$.

---

## 11. 60-second summary

$$
\boxed{p_{X+Y}(k)=\sum_{i+j=k}p_{X,Y}(i,j)}
$$

If independent,

$$
\boxed{p_{X+Y}(k)=\sum_i p_X(i)p_Y(k-i)}
$$

$$
\boxed{F_Z(z)=\iint_{\{g(x,y)\le z\}}f_{X,Y}(x,y)\,dx\,dy}
$$

$$
\boxed{f_{X+Y}(z)=\int_{-\infty}^{\infty}f_{X,Y}(x,z-x)\,dx}
$$

If independent,

$$
\boxed{f_{X+Y}(z)=\int_{-\infty}^{\infty}f_X(x)f_Y(z-x)\,dx}
$$

$$
\boxed{E[X+Y]=E[X]+E[Y]}
$$

$$
\boxed{\operatorname{Var}(X+Y)
=\operatorname{Var}(X)+2\operatorname{Cov}(X,Y)+\operatorname{Var}(Y)}
$$

$$
\boxed{E[aX+bY+c]=aE[X]+bE[Y]+c}
$$

$$
\boxed{\operatorname{Var}(aX+bY+c)
=a^2\operatorname{Var}(X)+2ab\operatorname{Cov}(X,Y)+b^2\operatorname{Var}(Y)}
$$
