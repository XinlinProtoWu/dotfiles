# ELEC 2600 — Lectures 13–20 Master Notes

> **How to use this page.** Start with the roadmap below, then read the lecture note for each topic. Each lecture file contains intuition, worked examples, common mistakes, and a 60-second summary. This page is the formula sheet and study plan.

---

## Lecture map

| Lecture | Topic | Note |
|---|---|---|
| 13 | Pairs of continuous RVs: joint CDF/PDF, marginals, mixed pairs | [[lec_13_pairs_of_continuous_random_variables]] |
| 14 | Conditional distributions, Bayes, independence | [[lec_14_conditional_probability_and_independence]] |
| 15 | Joint moments, covariance, correlation, conditional expectation | [[lec_15_joint_moments_and_conditional_expectation]] |
| 16 | Sums of two RVs, convolution, mean/variance of sums | [[lec_16_sums_of_two_random_variables]] |
| 17 | Jointly Gaussian pairs, covariance matrix, conditional Gaussian | [[lec_17_pairs_of_jointly_gaussian]] |
| 18 | Random vectors, multinomial, covariance matrices, Gaussian vectors | [[lec_18_more_than_two_random_variables]] |
| 19 | Sample means, Markov/Chebyshev, laws of large numbers | [[lec_19_laws_of_large_numbers]] |
| 20 | Central Limit Theorem, Q function, normal approximation | [[lec_20_central_limit_theorem]] |

---

## The big story

1. **Describe two variables together.** Use a joint CDF, joint PDF (continuous), or joint pmf (discrete). Integrate/sum out one variable to get marginals.
2. **Update after observing.** Use conditional distributions, the product rule, total probability, and Bayes.
3. **Summarize dependence.** Use covariance and correlation. Independence implies uncorrelated, but not conversely.
4. **Add variables.** Find the distribution of $X+Y$ by summing/integrating over pairs, or by convolution when independent.
5. **Special case: Gaussian.** Jointly Gaussian pairs/vectors are fully described by means and covariances, and stay Gaussian under affine operations.
6. **Many variables.** Use vectors and matrices: mean vector, correlation matrix, covariance matrix.
7. **Many observations.** Sample means are unbiased and concentrate around the true mean. Markov/Chebyshev give bounds; the laws of large numbers give convergence.
8. **Many small contributions.** The CLT says standardized sums/averages become Gaussian, regardless of the original distribution.

---

## Core formula sheet

### Joint distributions (Lecture 13)

$$
F_{X,Y}(x,y)=P[X\le x,\ Y\le y]
$$

$$
f_{X,Y}(x,y)=\frac{\partial^2F_{X,Y}(x,y)}{\partial x\,\partial y}
$$

$$
P[(X,Y)\in A]=\iint_A f_{X,Y}(x,y)\,dx\,dy
$$

$$
f_X(x)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dy,
\qquad
f_Y(y)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dx
$$

Rectangle probability:

$$
P[x_1<X\le x_2,\ y_1<Y\le y_2]
=
F_{X,Y}(x_2,y_2)-F_{X,Y}(x_2,y_1)
-F_{X,Y}(x_1,y_2)+F_{X,Y}(x_1,y_1)
$$

Mixed discrete–continuous:

$$
p_X(x)=\int f_{X,Y}(x,y)\,dy,
\qquad
f_Y(y)=\sum_x f_{X,Y}(x,y)
$$

---

### Conditional distributions and independence (Lecture 14)

$$
p_{Y\mid X}(k\mid j)=\frac{p_{X,Y}(j,k)}{p_X(j)}
$$

$$
f_{Y\mid X}(y\mid x)=\frac{f_{X,Y}(x,y)}{f_X(x)}
$$

Product rule:

$$
p_{X,Y}(j,k)=p_{Y\mid X}(k\mid j)p_X(j)
$$

Total probability:

$$
p_Y(k)=\sum_j p_{Y\mid X}(k\mid j)p_X(j)
$$

$$
f_Y(y)=\int f_{Y\mid X}(y\mid x)f_X(x)\,dx
$$

Bayes:

$$
p_{X\mid Y}(j\mid k)=\frac{p_{Y\mid X}(k\mid j)p_X(j)}{p_Y(k)}
$$

$$
f_{X\mid Y}(x\mid y)=
\frac{f_{Y\mid X}(y\mid x)f_X(x)}
{\int f_{Y\mid X}(y\mid u)f_X(u)\,du}
$$

Independence:

$$
X\perp Y
\iff
p_{X,Y}(j,k)=p_X(j)p_Y(k)
\iff
f_{X,Y}(x,y)=f_X(x)f_Y(y)
$$

If independent:

$$
p_{Y\mid X}(k\mid j)=p_Y(k),
\qquad
f_{Y\mid X}(y\mid x)=f_Y(y)
$$

---

### Moments, covariance, correlation (Lecture 15)

$$
E[g(X,Y)]=\iint g(x,y)f_{X,Y}(x,y)\,dx\,dy
$$

$$
E[aX+bY+c]=aE[X]+bE[Y]+c
$$

$$
\operatorname{Cov}(X,Y)=E[(X-E[X])(Y-E[Y])]
=E[XY]-E[X]E[Y]
$$

$$
\operatorname{Cov}(aX,bY)=ab\operatorname{Cov}(X,Y)
$$

$$
\rho_{X,Y}=\frac{\operatorname{Cov}(X,Y)}{\sigma_X\sigma_Y},
\qquad
-1\le\rho_{X,Y}\le1
$$

$$
\operatorname{Var}(aX+bY+c)
=a^2\operatorname{Var}(X)
+2ab\operatorname{Cov}(X,Y)
+b^2\operatorname{Var}(Y)
$$

Independent:

$$
X\perp Y\ \Longrightarrow\ E[XY]=E[X]E[Y]
\ \Longrightarrow\ \operatorname{Cov}(X,Y)=0
$$

Uncorrelated does **not** imply independent in general.

Conditional expectation:

$$
E[Y\mid X=x]=\int y f_{Y\mid X}(y\mid x)\,dy
$$

$$
E[Y]=E[E[Y\mid X]]
$$

$$
\operatorname{Var}(Y)
=E[\operatorname{Var}(Y\mid X)]
+\operatorname{Var}(E[Y\mid X])
$$

---

### Sums of random variables (Lecture 16)

Discrete:

$$
p_{X+Y}(k)=\sum_{i+j=k}p_{X,Y}(i,j)
$$

If independent:

$$
p_{X+Y}(k)=\sum_i p_X(i)p_Y(k-i)
$$

Continuous CDF method:

$$
F_Z(z)=\iint_{\{(x,y):g(x,y)\le z\}}f_{X,Y}(x,y)\,dx\,dy
$$

$$
f_Z(z)=\frac{d}{dz}F_Z(z)
$$

Sum:

$$
f_{X+Y}(z)=\int f_{X,Y}(x,z-x)\,dx
$$

If independent:

$$
f_{X+Y}(z)=\int f_X(x)f_Y(z-x)\,dx
$$

Means and variances:

$$
E[X+Y]=E[X]+E[Y]
$$

$$
\operatorname{Var}(X+Y)
=\operatorname{Var}(X)+2\operatorname{Cov}(X,Y)+\operatorname{Var}(Y)
$$

If uncorrelated:

$$
\operatorname{Var}(X+Y)=\operatorname{Var}(X)+\operatorname{Var}(Y)
$$

---

### Gaussian pairs (Lecture 17)

$$
f_X(x)=\frac{1}{\sqrt{2\pi}\sigma}
e^{-(x-m)^2/(2\sigma^2)}
$$

Bivariate Gaussian:

$$
\mathbf C=
\begin{pmatrix}
\sigma_1^2 & \rho\sigma_1\sigma_2\\
\rho\sigma_1\sigma_2 & \sigma_2^2
\end{pmatrix},
\qquad
|\mathbf C|=(1-\rho^2)\sigma_1^2\sigma_2^2
$$

$$
f_{\vec X}(\vec x)
=
\frac{1}{(2\pi)^{n/2}\sqrt{|\mathbf C|}}
\exp\left[
-\frac12(\vec x-\vec m)^T\mathbf C^{-1}(\vec x-\vec m)
\right]
$$

Key properties for jointly Gaussian:

$$
\rho=0\iff X\perp Y
$$

$$
Y=aX_1+bX_2+c\ \text{is Gaussian}
$$

$$
E[Y]=aE[X_1]+bE[X_2]+c
$$

$$
\operatorname{Var}(Y)
=a^2\operatorname{Var}(X_1)
+2ab\operatorname{Cov}(X_1,X_2)
+b^2\operatorname{Var}(X_2)
$$

Conditional Gaussian:

$$
E[X\mid Y=y]
=m_X+\rho\frac{\sigma_X}{\sigma_Y}(y-m_Y)
$$

$$
\operatorname{Var}(X\mid Y=y)
=\sigma_X^2(1-\rho^2)
$$

---

### Random vectors (Lecture 18)

Mean vector:

$$
E[\vec X]=
\begin{pmatrix}
E[X_1]\\
\vdots\\
E[X_n]
\end{pmatrix}
$$

Correlation and covariance matrices:

$$
\mathbf R=E[\vec X\vec X^T],
\qquad
R_{ij}=E[X_iX_j]
$$

$$
\mathbf C=E[(\vec X-E\vec X)(\vec X-E\vec X)^T]
$$

$$
C_{ij}=
\begin{cases}
\operatorname{Var}(X_i),&i=j,\\
\operatorname{Cov}(X_i,X_j),&i\ne j
\end{cases}
$$

$$
\mathbf C=\mathbf R-E[\vec X]E[\vec X]^T
$$

Multinomial:

$$
p_{X_1,\dots,X_m}(k_1,\dots,k_m)
=
\frac{n!}{k_1!\cdots k_m!}
p_1^{k_1}\cdots p_m^{k_m}
$$

Jointly Gaussian vector:

$$
f_{\vec X}(\vec x)
=
\frac{1}{(2\pi)^{n/2}\sqrt{|\mathbf C|}}
\exp\left[
-\frac12(\vec x-\vec m)^T\mathbf C^{-1}(\vec x-\vec m)
\right]
$$

Affine transformation:

$$
E[\mathbf A\vec X+\vec b]=\mathbf A E[\vec X]+\vec b
$$

$$
\operatorname{Cov}(\mathbf A\vec X+\vec b)
=\mathbf A\,\operatorname{Cov}(\vec X)\,\mathbf A^T
$$

---

### Sample means and laws of large numbers (Lecture 19)

For i.i.d. $X_i$ with mean $\mu$ and variance $\sigma^2$:

$$
E[S_n]=n\mu,
\qquad
\operatorname{Var}(S_n)=n\sigma^2
$$

$$
E[M_n]=\mu,
\qquad
\operatorname{Var}(M_n)=\frac{\sigma^2}{n}
$$

Markov:

$$
P[X\ge a]\le\frac{E[X]}{a}
\qquad(X\ge0)
$$

Chebyshev:

$$
P[|X-m|\ge a]\le\frac{\sigma^2}{a^2}
$$

Weak law:

$$
\lim_{n\to\infty}P[|M_n-\mu|<\varepsilon]=1
$$

Strong law:

$$
P\left[\lim_{n\to\infty}M_n=\mu\right]=1
$$

Relative frequency:

$$
f_A(n)=\frac1n\sum_{j=1}^{n}I_j
\ \longrightarrow\ P[A]
$$

---

### Central Limit Theorem (Lecture 20)

$$
Z_n=\frac{S_n-n\mu}{\sigma\sqrt n}
\ \overset{d}{\longrightarrow}\ \mathcal N(0,1)
$$

Equivalently:

$$
S_n\approx\mathcal N(n\mu,n\sigma^2)
$$

$$
M_n\approx\mathcal N\left(\mu,\frac{\sigma^2}{n}\right)
$$

Q function:

$$
Q(x)=\int_x^{\infty}\frac{1}{\sqrt{2\pi}}e^{-t^2/2}\,dt
$$

$$
P[Y>y]=Q\left(\frac{y-m}{\sigma}\right)
$$

$$
P[|Y-m|<\varepsilon]
=1-2Q\left(\frac{\varepsilon}{\sigma}\right)
$$

Binomial approximation:

$$
S_n\sim\text{Binomial}(n,p)
\approx
\mathcal N(np,np(1-p))
$$

---

## Problem-solving recipes

### Recipe 1: Find a probability involving two continuous variables

1. Draw the support of $f_{X,Y}$.
2. Draw the event region.
3. Intersect the two regions.
4. Integrate $f_{X,Y}$ over the intersection.
5. If the density is constant on the region, use area.

### Recipe 2: Find a marginal

- Continuous: integrate out the other variable.
- Discrete: sum out the other variable.
- Mixed: integrate over the continuous variable, sum over the discrete variable.

### Recipe 3: Find a conditional distribution

$$
\text{conditional}=\frac{\text{joint}}{\text{marginal of the conditioning variable}}
$$

Always state the support.

### Recipe 4: Test independence

1. Find the marginals.
2. Check whether $f_{X,Y}=f_Xf_Y$ or $p_{X,Y}=p_Xp_Y$ **everywhere**.
3. Check the support: a triangular support usually means dependence.

### Recipe 5: Find the distribution of $Z=g(X,Y)$

1. Write $F_Z(z)=P[g(X,Y)\le z]$.
2. Draw $D_z=\{(x,y):g(x,y)\le z\}$.
3. Integrate the joint density over $D_z$.
4. Differentiate with respect to $z$.

For $Z=X+Y$ with independent variables, skip to convolution:

$$
f_Z(z)=\int f_X(x)f_Y(z-x)\,dx.
$$

### Recipe 6: Gaussian affine combination

1. Check that the variables are **jointly** Gaussian.
2. Compute the mean with linearity.
3. Compute the variance with the covariance terms.
4. Write the Gaussian density with those two numbers.

### Recipe 7: Conditional Gaussian

$$
E[X\mid Y=y]
=m_X+\rho\frac{\sigma_X}{\sigma_Y}(y-m_Y)
$$

$$
\operatorname{Var}(X\mid Y=y)
=\sigma_X^2(1-\rho^2)
$$

No integration needed.

### Recipe 8: LLN / CLT approximation

1. Identify $S_n$ or $M_n$.
2. Compute its mean and variance.
3. If using the CLT, standardize.
4. Use $\Phi$ or $Q$ to finish.
5. For integer-valued variables, consider continuity correction.

---

## Common exam traps

1. **PDF value is not a probability.** Integrate over an area.
2. **Marginals do not determine the joint.** Dependence information is lost.
3. **Conditional pmf sums to 1 over the conditioned variable, not the conditioning variable.**
4. **Independent implies uncorrelated, but uncorrelated does not imply independent** (except for jointly Gaussian variables).
5. **Correlation measures linear dependence only.** $\rho=0$ does not mean "no relationship."
6. **Convolution requires independence.** For dependent variables use the joint density.
7. **Watch integration limits.** Draw the support and the event region.
8. **Gaussian formulas use variance, not standard deviation, in the exponent.**
9. **Uncorrelated jointly Gaussian variables are independent.** This is a special property.
10. **A sum of jointly Gaussian variables is Gaussian; a sum of merely marginally Gaussian variables need not be.**
11. **$\operatorname{Var}(S_n)=n\sigma^2$, but $\operatorname{Var}(M_n)=\sigma^2/n$.**
12. **Markov requires nonnegative $X$; Chebyshev does not.**
13. **Weak law is convergence in probability; strong law is almost sure convergence.**
14. **CLT is asymptotic.** For small $n$, the approximation may be poor.
15. **For discrete CLT, use continuity correction.**

---

## Quick self-check

Try these without looking at the notes.

1. If $f_{X,Y}(x,y)=c$ on $0\le x\le2$, $0\le y\le1$, find $c$, $f_X$, $f_Y$, and $P[X+Y<1]$.
2. If $f_{X,Y}(x,y)=2e^{-x}e^{-y}$ on $0\le y\le x$, find $f_X$, $f_Y$, $f_{X\mid Y}$, and $f_{Y\mid X}$.
3. Are the variables in Question 2 independent? Why or why not?
4. For the variables in Question 2, compute $\operatorname{Cov}(X,Y)$.
5. If $X\sim\text{Uniform}[-1,1]$ and $Y=X^2$, are $X,Y$ uncorrelated? Independent?
6. If $X,Y$ are independent exponentials with rate $\lambda$, find the pdf of $X+Y$.
7. If $X,Y$ are independent Gaussian with means $1,-2$ and variances $4,9$, find the distribution of $3X-2Y+1$.
8. If $X,Y$ are jointly Gaussian with $\rho=0.5$, $\sigma_X=2$, $\sigma_Y=3$, find $E[X\mid Y=y]$ when $m_X=m_Y=0$.
9. If $X_1,\dots,X_{100}$ are i.i.d. with mean $5$ and variance $4$, find $E[M_{100}]$ and $\operatorname{Var}(M_{100})$.
10. Use Chebyshev to bound $P[|M_{100}-5|\ge2]$.
11. State the CLT for $S_n$ and for $M_n$.
12. If $S$ is approximately $\mathcal N(800,400)$, compute $P[S>840]$ using $Q$.
13. Why is the CLT surprising?
14. What is the difference between the weak and strong laws of large numbers?
15. When can you conclude that uncorrelated variables are independent?

### Answers (brief)

1. $c=1/2$, $f_X=1/2$ on $[0,2]$, $f_Y=1$ on $[0,1]$, $P[X+Y<1]=1/4$. (The triangle below $x+y=1$ inside the rectangle has area $1/2$, times $1/2$.)
2. $f_X(x)=2e^{-x}(1-e^{-x})$, $f_Y(y)=2e^{-2y}$, $f_{X\mid Y}(x\mid y)=e^{-(x-y)}$ for $x\ge y$, $f_{Y\mid X}(y\mid x)=e^{-y}/(1-e^{-x})$ for $0\le y\le x$.
3. No. The support $0\le y\le x$ couples them, and $f_Xf_Y\ne f_{X,Y}$.
4. Use the joint density. $E[X]=3/2$, $E[Y]=1/2$, and $E[XY]=1$. Hence $\operatorname{Cov}(X,Y)=1-(3/2)(1/2)=1/4$.
5. Uncorrelated because $E[X]=0$ and $E[XY]=E[X^3]=0$. Dependent because $Y=X^2$.
6. $f_{X+Y}(z)=\lambda^2 z e^{-\lambda z}$ for $z\ge0$.
7. $3X-2Y+1\sim\mathcal N(3(1)-2(-2)+1,\ 9(4)+4(9))=\mathcal N(8,72)$ since independent.
8. $E[X\mid Y=y]=0.5\cdot\frac{2}{3}y=\frac{y}{3}$.
9. $E[M_{100}]=5$, $\operatorname{Var}(M_{100})=4/100=0.04$.
10. $P[|M_{100}-5|\ge2]\le0.04/4=0.01$.
11. $Z_n=(S_n-n\mu)/(\sigma\sqrt n)\to\mathcal N(0,1)$; equivalently $S_n\approx\mathcal N(n\mu,n\sigma^2)$ and $M_n\approx\mathcal N(\mu,\sigma^2/n)$.
12. $P[S>840]\approx Q((840-800)/20)=Q(2)\approx0.0228$.
13. Because the result is Gaussian regardless of the original distribution, as long as the variables are i.i.d. with finite mean and variance.
14. Weak: $\lim P[|M_n-\mu|<\varepsilon]=1$ (convergence in probability). Strong: $P[\lim M_n=\mu]=1$ (almost sure convergence).
15. When the variables are **jointly Gaussian** (or in other special cases, but not in general).

---

## Suggested study plan

### Day 1 — Lectures 13–14

- Read the joint CDF/PDF sections.
- Redo the uniform rectangle example and the triangular-support example.
- Practice computing marginals and conditional densities.
- Do the loaded-dice and chip-defect examples.

### Day 2 — Lectures 15–16

- Memorize covariance and correlation formulas.
- Practice the $\pm a$ example and signal-plus-noise example.
- Redo the standby exponential convolution.
- Practice affine mean/variance calculations.

### Day 3 — Lectures 17–18

- Write the bivariate Gaussian formula from memory.
- Practice affine Gaussian examples.
- Build a covariance matrix from moments.
- Review multivariate Gaussian properties.

### Day 4 — Lectures 19–20

- Memorize Markov and Chebyshev.
- Practice sample-mean calculations.
- State weak and strong laws precisely.
- Do CLT approximations with $Q$.
- Practice the sample-size comparison.

### Final review

- Read the 60-second summary at the end of each lecture file.
- Redo the quick self-check above.
- Make sure you can explain **why** each formula is true, not just plug into it.
