# Lecture 15: Joint Moments and Conditional Expectation

> **Big picture.** Joint moments summarize how two random variables behave together. The most important are the **covariance** (do they move together?) and the **correlation coefficient** (how strong is the linear relationship, in unit-free terms?). **Conditional expectation** is the best mean-squared-error guess of one variable after observing the other.

---

## Learning goals

By the end of this lecture you should be able to:

1. Compute $E[g(X,Y)]$ using a joint pmf or pdf.
2. Use linearity of expectation.
3. Compute covariance and correlation.
4. Decide whether variables are uncorrelated or independent.
5. Compute conditional expectations.
6. Use the law of total expectation.

---

## 1. Expectation of a function of two variables

If $Z=g(X,Y)$, then

$$
\boxed{E[Z]=E[g(X,Y)]
=\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
g(x,y)f_{X,Y}(x,y)\,dx\,dy}
$$

for jointly continuous $X,Y$, and

$$
\boxed{E[g(X,Y)]=\sum_j\sum_k g(j,k)p_{X,Y}(j,k)}
$$

for discrete $X,Y$.

This is the **law of the unconscious statistician** for two variables: we do not need to find the distribution of $Z$ first.

> [!Example]
> **Sum of two random variables.** Let $Z=X+Y$.
> $$
> \begin{aligned}
> E[Z]
> &=\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
> (x+y)f_{X,Y}(x,y)\,dx\,dy\\
> &=\int_{-\infty}^{\infty}x\left(\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dy\right)dx
> +\int_{-\infty}^{\infty}y\left(\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dx\right)dy\\
> &=\int_{-\infty}^{\infty}xf_X(x)\,dx
> +\int_{-\infty}^{\infty}yf_Y(y)\,dy\\
> &=E[X]+E[Y].
> \end{aligned}
> $$
> So
> $$
> \boxed{E[X+Y]=E[X]+E[Y]}.
> $$
> This holds **whether or not** $X$ and $Y$ are independent.

---

## 2. Linearity of expectation

Expectation is linear:

$$
\boxed{E[aX+bY+c]=aE[X]+bE[Y]+c}.
$$

Also, for any constants $a_i$,

$$
\boxed{E\left[a_0+\sum_{i=1}^{n}a_iX_i\right]
=a_0+\sum_{i=1}^{n}a_iE[X_i]}.
$$

Linearity does **not** require independence.

> **Warning:** nonlinear functions do not commute with expectation in general:
> $$
> E[g(X)]\ne g(E[X]),
> \qquad
> E[g(X,Y)]\ne g(E[X],E[Y]).
> $$
> For example, $E[X^2]\ne(E[X])^2$ unless $X$ is constant.

---

## 3. Expectation of products

If $X$ and $Y$ are independent, then for any functions $g_1,g_2$,

$$
\boxed{E[g_1(X)g_2(Y)]=E[g_1(X)]\,E[g_2(Y)]}.
$$

In particular,

$$
\boxed{E[XY]=E[X]E[Y]}.
$$

Proof for the continuous case:

$$
\begin{aligned}
E[g_1(X)g_2(Y)]
&=\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
g_1(x)g_2(y)f_X(x)f_Y(y)\,dx\,dy\\
&=\left(\int_{-\infty}^{\infty}g_1(x)f_X(x)\,dx\right)
\left(\int_{-\infty}^{\infty}g_2(y)f_Y(y)\,dy\right)\\
&=E[g_1(X)]E[g_2(Y)].
\end{aligned}
$$

> **Important:** $E[XY]=E[X]E[Y]$ is **not** true in general for dependent variables.

---

## 4. Joint moments

The **joint moment of order $(j,k)$** is

$$
\boxed{m_{jk}=E[X^jY^k]
=\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
x^j y^k f_{X,Y}(x,y)\,dx\,dy}.
$$

The **joint central moment** is

$$
\boxed{E[(X-E[X])^j(Y-E[Y])^k]}.
$$

The most important first- and second-order quantities are:

| Quantity | Formula |
|---|---|
| Mean of $X$ | $E[X]$ |
| Mean of $Y$ | $E[Y]$ |
| Variance of $X$ | $\operatorname{Var}[X]=E[(X-E[X])^2]$ |
| Variance of $Y$ | $\operatorname{Var}[Y]=E[(Y-E[Y])^2]$ |
| Covariance | $\operatorname{Cov}(X,Y)=E[(X-E[X])(Y-E[Y])]$ |
| Raw second moment (sometimes called correlation) | $E[XY]$ |

---

## 5. Covariance

$$
\boxed{\operatorname{Cov}(X,Y)
=E[(X-E[X])(Y-E[Y])]}.
$$

### Interpretation

- If $\operatorname{Cov}(X,Y)>0$: when $X$ is above its mean, $Y$ tends to be above its mean too.
- If $\operatorname{Cov}(X,Y)<0$: when $X$ is above its mean, $Y$ tends to be below its mean.
- If $\operatorname{Cov}(X,Y)\approx0$: there is no **linear** co-movement.

### Useful computational formula

$$
\boxed{\operatorname{Cov}(X,Y)=E[XY]-E[X]E[Y]}.
$$

Proof:

$$
\begin{aligned}
\operatorname{Cov}(X,Y)
&=E[XY-XE[Y]-E[X]Y+E[X]E[Y]]\\
&=E[XY]-E[X]E[Y]-E[X]E[Y]+E[X]E[Y]\\
&=E[XY]-E[X]E[Y].
\end{aligned}
$$

If either $X$ or $Y$ has zero mean, then

$$
\operatorname{Cov}(X,Y)=E[XY].
$$

Also,

$$
\operatorname{Cov}(X,X)=\operatorname{Var}(X).
$$

### Units

Covariance depends on the units used to measure $X$ and $Y$. For constants $a,b$,

$$
\boxed{\operatorname{Cov}(aX,bY)=ab\,\operatorname{Cov}(X,Y)}.
$$

For example, if height is measured in meters and weight in kilograms, then changing weight to grams multiplies the covariance by $1000$.

---

## 6. Uncorrelated random variables

$X$ and $Y$ are **uncorrelated** if

$$
\boxed{\operatorname{Cov}(X,Y)=0}.
$$

Equivalently,

$$
\boxed{E[XY]=E[X]E[Y]}.
$$

### Independence implies uncorrelated

If $X$ and $Y$ are independent, then $E[XY]=E[X]E[Y]$, so

$$
\operatorname{Cov}(X,Y)=0.
$$

Thus:

$$
\boxed{\text{independent}\ \Longrightarrow\ \text{uncorrelated}}.
$$

The converse is **false** in general:

$$
\text{uncorrelated}\ \not\Longrightarrow\ \text{independent}.
$$

> [!Example]
> **Uncorrelated but dependent.** Let $\Theta\sim\text{Uniform}[0,2\pi]$, and define
> $$
> X=\cos\Theta,\qquad Y=\sin\Theta.
> $$
> Then
> $$
> E[X]=\frac1{2\pi}\int_0^{2\pi}\cos\theta\,d\theta=0,
> $$
> $$
> E[Y]=\frac1{2\pi}\int_0^{2\pi}\sin\theta\,d\theta=0,
> $$
> $$
> E[XY]=\frac1{2\pi}\int_0^{2\pi}\cos\theta\sin\theta\,d\theta
> =\frac1{4\pi}\int_0^{2\pi}\sin(2\theta)\,d\theta=0.
> $$
> So $\operatorname{Cov}(X,Y)=0$ and $X,Y$ are uncorrelated.
>
> But they are **dependent**: $X^2+Y^2=1$ always. Knowing $X$ determines $Y$ up to sign.

> [!Example]
> **A simpler uncorrelated-but-dependent example.** Let $X\sim\text{Uniform}[-1,1]$ and $Y=X^2$. Then
> $$
> E[X]=0,\qquad E[XY]=E[X^3]=0,
> $$
> so $\operatorname{Cov}(X,Y)=0$. But $Y$ is completely determined by $X$, so they are dependent.

---

## 7. Correlation coefficient

The **correlation coefficient** is

$$
\boxed{\rho_{X,Y}
=\frac{\operatorname{Cov}(X,Y)}{\sigma_X\sigma_Y}
=\frac{\operatorname{Cov}(X,Y)}
{\sqrt{\operatorname{Var}(X)\operatorname{Var}(Y)}}},
$$

where $\sigma_X=\sqrt{\operatorname{Var}(X)}$ and $\sigma_Y=\sqrt{\operatorname{Var}(Y)}$.

It is unit-free, unlike covariance.

### Properties

$$
\rho_{X,Y}=\rho_{Y,X},
\qquad
-1\le\rho_{X,Y}\le1.
$$

### Proof that $|\rho|\le1$

For any real sign $\pm$,

$$
0\le E\left[\left(\frac{X-E[X]}{\sigma_X}
\pm\frac{Y-E[Y]}{\sigma_Y}\right)^2\right].
$$

Expand:

$$
\begin{aligned}
0&\le
E\left[\frac{(X-E[X])^2}{\sigma_X^2}\right]
\pm2E\left[\frac{(X-E[X])(Y-E[Y])}{\sigma_X\sigma_Y}\right]
+E\left[\frac{(Y-E[Y])^2}{\sigma_Y^2}\right]\\
&=\frac{\operatorname{Var}(X)}{\sigma_X^2}
\pm2\frac{\operatorname{Cov}(X,Y)}{\sigma_X\sigma_Y}
+\frac{\operatorname{Var}(Y)}{\sigma_Y^2}\\
&=1\pm2\rho_{X,Y}+1\\
&=2\pm2\rho_{X,Y}.
\end{aligned}
$$

Thus $1+\rho\ge0$ and $1-\rho\ge0$, so

$$
-1\le\rho_{X,Y}\le1.
$$

### Interpretation

- $\rho=1$: perfect positive linear relationship.
- $\rho=-1$: perfect negative linear relationship.
- $\rho=0$: no linear relationship.
- $|\rho|$ close to $1$: strong linear relationship.
- $|\rho|$ close to $0$: weak linear relationship.

> **Warning:** $\rho$ measures **linear** dependence only. A strong nonlinear relationship can still have $\rho=0$.

---

## 8. Example: signal plus noise

Let

$$
Y=X+N,
$$

where

- $X$ is the signal with $E[X]=0$ and $\operatorname{Var}(X)=\sigma_X^2$,
- $N$ is the noise with $E[N]=0$ and $\operatorname{Var}(N)=\sigma_N^2$,
- $X$ and $N$ are independent.

Then $E[Y]=0$ and

$$
\operatorname{Var}(Y)=\sigma_X^2+\sigma_N^2.
$$

The correlation coefficient between $X$ and $Y$ is

$$
\begin{aligned}
\rho_{X,Y}
&=\frac{\operatorname{Cov}(X,Y)}{\sigma_X\sigma_Y}\\
&=\frac{E[XY]}{\sigma_X\sigma_Y}\\
&=\frac{E[X(X+N)]}{\sigma_X\sigma_Y}\\
&=\frac{E[X^2]+E[X]E[N]}{\sigma_X\sigma_Y}\\
&=\frac{\sigma_X^2}{\sigma_X\sigma_Y}
=\frac{\sigma_X}{\sigma_Y}.
\end{aligned}
$$

So

$$
\boxed{\rho_{X,Y}=\frac{\sigma_X}{\sqrt{\sigma_X^2+\sigma_N^2}}}.
$$

This is the fraction of the standard deviation of $Y$ that comes from the signal $X$.

---

## 9. Variance of a sum

For any $X,Y$,

$$
\boxed{\operatorname{Var}(X+Y)
=\operatorname{Var}(X)+2\operatorname{Cov}(X,Y)+\operatorname{Var}(Y)}.
$$

More generally,

$$
\boxed{\operatorname{Var}\left(\sum_{i=1}^{n}X_i\right)
=\sum_{i=1}^{n}\operatorname{Var}(X_i)
+2\sum_{i<j}\operatorname{Cov}(X_i,X_j)}.
$$

Proof for two variables:

$$
\begin{aligned}
\operatorname{Var}(X+Y)
&=E[(X+Y-E[X]-E[Y])^2]\\
&=E[((X-E[X])+(Y-E[Y]))^2]\\
&=E[(X-E[X])^2]
+2E[(X-E[X])(Y-E[Y])]\\
&\quad+E[(Y-E[Y])^2]\\
&=\operatorname{Var}(X)+2\operatorname{Cov}(X,Y)+\operatorname{Var}(Y).
\end{aligned}
$$

If $X$ and $Y$ are uncorrelated,

$$
\boxed{\operatorname{Var}(X+Y)=\operatorname{Var}(X)+\operatorname{Var}(Y)}.
$$

If $X$ and $Y$ are independent, this also holds.

For an affine combination,

$$
\boxed{\operatorname{Var}(aX+bY+c)
=a^2\operatorname{Var}(X)+2ab\operatorname{Cov}(X,Y)+b^2\operatorname{Var}(Y)}.
$$

---

## 10. Worked example: discrete $\pm a$ variables

Let $X,Y\in\{-a,a\}$ with joint pmf

| | $Y=a$ | $Y=-a$ |
|---|---|---|
| $X=-a$ | $1/8$ | $3/8$ |
| $X=a$ | $3/8$ | $1/8$ |

The marginals are uniform: $P[X=a]=P[X=-a]=1/2$, and similarly for $Y$. Thus

$$
E[X]=0,\qquad E[Y]=0,
$$

$$
\operatorname{Var}(X)=E[X^2]=\frac12(-a)^2+\frac12(a)^2=a^2,
$$

$$
\operatorname{Var}(Y)=a^2.
$$

Compute

$$
\begin{aligned}
E[XY]
&=\frac18(-a)(a)+\frac38(a)(a)+\frac38(-a)(-a)+\frac18(a)(-a)\\
&=-\frac{a^2}{8}+\frac{3a^2}{8}+\frac{3a^2}{8}-\frac{a^2}{8}\\
&=\frac{4a^2}{8}
=\frac{a^2}{2}.
\end{aligned}
$$

Since means are zero,

$$
\operatorname{Cov}(X,Y)=E[XY]=\frac{a^2}{2}.
$$

Therefore

$$
\rho_{X,Y}
=\frac{a^2/2}{a\cdot a}
=\frac12.
$$

By changing the table, one can get $\rho=-1,-0.5,0,0.5,1$, illustrating that correlation only captures linear co-movement.

---

## 11. Conditional expectation

### Definition

If $Y$ is continuous,

$$
\boxed{E[Y\mid X=x]=\int_{-\infty}^{\infty}y\,f_{Y\mid X}(y\mid x)\,dy}.
$$

If $Y$ is discrete and integer-valued,

$$
\boxed{E[Y\mid X=x]=\sum_j j\,p_{Y\mid X}(j\mid x)}.
$$

More generally,

$$
\boxed{E[g(Y)\mid X=x]
=\int_{-\infty}^{\infty}g(y)f_{Y\mid X}(y\mid x)\,dy}.
$$

### Key point: it is a function of $x$

$E[Y\mid X=x]$ is a number for each fixed $x$.

$E[Y\mid X]$ is a **random variable**: it is the function of $X$ obtained by evaluating the conditional expectation at the random value $X$.

### Intuition: best mean-squared-error guess

$E[Y\mid X]$ is the best guess of $Y$ given $X$ in the minimum mean-squared-error sense. It minimizes

$$
E[(Y-g(X))^2]
$$

over all functions $g$.

> [!Example]
> **Conditional expectation with a hybrid density.** Let
> $$
> f(x,y)=
> \begin{cases}
> xe^{-x(y+1)},&x\ge0,\ y\ge0,\\
> 0,&\text{otherwise}.
> \end{cases}
> $$
>
> **Step 1: marginal of $X$.** For $x\ge0$,
> $$
> f_X(x)=\int_0^{\infty}xe^{-x(y+1)}\,dy
> =e^{-x}\int_0^{\infty}xe^{-xy}\,dy
> =e^{-x}.
> $$
>
> **Step 2: conditional density of $Y$ given $X=x$.** For $y\ge0$,
> $$
> f_{Y\mid X}(y\mid x)
> =\frac{f(x,y)}{f_X(x)}
> =\frac{xe^{-x(y+1)}}{e^{-x}}
> =xe^{-xy}.
> $$
> So given $X=x$, $Y$ is exponential with rate $x$.
>
> **Step 3: conditional expectation.**
> $$
> E[Y\mid X=x]
> =\int_0^{\infty}y\,xe^{-xy}\,dy
> =\frac1x.
> $$
> Therefore
> $$
> \boxed{E[Y\mid X]=\frac1X}.
> $$

---

## 12. Law of total expectation

Since $E[Y\mid X]$ is a random variable, we can take its expectation. The conditioning disappears:

$$
\boxed{E[Y]=E\big[E[Y\mid X]\big]}.
$$

More generally,

$$
\boxed{E[g(Y)]=E\big[E[g(Y)\mid X]\big]}.
$$

Proof for continuous variables:

$$
\begin{aligned}
E[E[Y\mid X]]
&=\int_{-\infty}^{\infty}\left(\int_{-\infty}^{\infty}
y f_{Y\mid X}(y\mid x)\,dy\right)f_X(x)\,dx\\
&=\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
y f_{Y\mid X}(y\mid x)f_X(x)\,dy\,dx\\
&=\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
y f_{X,Y}(x,y)\,dy\,dx\\
&=E[Y].
\end{aligned}
$$

This is the **expectation version of the total probability theorem**.

> [!Example]
> **Defects on a chip (again).** $X\sim\text{Poisson}(\alpha)$ is the total number of defects. Given $X$, the number $Y$ in region $R$ is binomial with parameters $X$ and $p$. Then
> $$
> E[Y\mid X]=pX.
> $$
> Therefore
> $$
> E[Y]=E[E[Y\mid X]]=E[pX]=pE[X]=\alpha p.
> $$
> This matches the Poisson$(\alpha p)$ result from Lecture 14.

> [!Example]
> **Service station.** Customers arrive as a Poisson process with rate $\beta$. A particular customer's service time is $T\sim\text{Exponential}(\alpha)$, independent of arrivals. Let $N$ be the number of arrivals during $T$.
>
> Given $T=t$,
> $$
> N\mid T=t\sim\text{Poisson}(\beta t),
> $$
> so
> $$
> E[N\mid T]=\beta T.
> $$
> Thus
> $$
> E[N]=E[E[N\mid T]]=\beta E[T]=\frac{\beta}{\alpha}.
> $$
>
> **Variance:** use the law of total variance,
> $$
> \operatorname{Var}(N)
> =E[\operatorname{Var}(N\mid T)]
> +\operatorname{Var}(E[N\mid T]).
> $$
> Since $N\mid T$ is Poisson,
> $$
> \operatorname{Var}(N\mid T)=\beta T,
> \qquad
> E[N\mid T]=\beta T.
> $$
> Therefore
> $$
> \operatorname{Var}(N)
> =E[\beta T]+\operatorname{Var}(\beta T)
> =\beta\frac1\alpha+\beta^2\frac1{\alpha^2}.
> $$
> So
> $$
> \boxed{\operatorname{Var}(N)=\frac{\beta}{\alpha}
> +\frac{\beta^2}{\alpha^2}}.
> $$

> **Bonus formula (law of total variance):**
> $$
> \boxed{\operatorname{Var}(Y)
> =E[\operatorname{Var}(Y\mid X)]
> +\operatorname{Var}(E[Y\mid X])}.
> $$
> It is often the easiest way to compute a variance when a natural conditioning variable exists.

---

## 13. Common mistakes

1. **Assuming $E[XY]=E[X]E[Y]$ without independence.** This requires independence (or at least uncorrelatedness, but that is what you are trying to prove).
2. **Confusing uncorrelated with independent.** Uncorrelated only rules out linear dependence.
3. **Thinking covariance is unit-free.** It is not; use $\rho$ to compare across units.
4. **Forgetting that $\operatorname{Cov}(X,X)=\operatorname{Var}(X)$.** The diagonal of a covariance matrix contains variances.
5. **Treating $E[Y\mid X]$ as a number.** $E[Y\mid X=x]$ is a number; $E[Y\mid X]$ is a random variable.
6. **Forgetting the support in conditional expectation.** Integrate only over the region where $f_{Y\mid X}>0$.
7. **Using the wrong conditional density.** $f_{Y\mid X}=f_{X,Y}/f_X$, not $f_{X,Y}/f_Y$.

---

## 14. 60-second summary

$$
\boxed{E[g(X,Y)]=\iint g(x,y)f_{X,Y}(x,y)\,dx\,dy}
$$

$$
\boxed{E[aX+bY+c]=aE[X]+bE[Y]+c}
$$

$$
\boxed{\operatorname{Cov}(X,Y)=E[XY]-E[X]E[Y]}
$$

$$
\boxed{\rho_{X,Y}
=\frac{\operatorname{Cov}(X,Y)}{\sigma_X\sigma_Y},
\qquad -1\le\rho_{X,Y}\le1}
$$

$$
\boxed{\text{independent}\Rightarrow\text{uncorrelated},
\qquad \text{uncorrelated}\not\Rightarrow\text{independent}}
$$

$$
\boxed{\operatorname{Var}(aX+bY+c)
=a^2\operatorname{Var}(X)+2ab\operatorname{Cov}(X,Y)+b^2\operatorname{Var}(Y)}
$$

$$
\boxed{E[Y\mid X=x]=\int y f_{Y\mid X}(y\mid x)\,dy}
$$

$$
\boxed{E[Y]=E[E[Y\mid X]]}
$$

$$
\boxed{\operatorname{Var}(Y)
=E[\operatorname{Var}(Y\mid X)]+\operatorname{Var}(E[Y\mid X])}
$$
