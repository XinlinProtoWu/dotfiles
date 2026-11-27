# Lecture 12: Pairs of Discrete Random Variables

## Overview

- Multiple random variables (vector RVs)
- Joint probability mass function of two discrete RVs
- Marginal probability mass function

---

## Vector Random Variables

A **vector random variable** ${}\vec X{}$ is a function that assigns a vector of real numbers to every outcome ${}\zeta{}$ of an experiment:

$$
\vec X=\begin{pmatrix}X_1\\X_2\\X_3\end{pmatrix}
$$

Examples:

- **Height, weight, age** of a randomly selected student: ${}(H(\zeta),W(\zeta),A(\zeta)){}$.
- **Sampled voltage (ADC):** ${}\vec X=(X_1,X_2,\dots,X_n){}$ where ${}X_k=X(kT,\zeta){}$ is the ${}k{}$-th sample.
- **Typhoon MEGI:** (maximum wind speed, distance from land).
- **Skin detection:** pixel color vector ${}(R,G,B){}$.

---

## Two Random Variables

- One RV maps the sample space ${}S{}$ to the **real line**.
- Two RVs map ${}S{}$ to the **plane** ${}\mathbb R^2{}$.
- Given the outcome ${}\zeta{}$, both ${}X(\zeta){}$ and ${}Y(\zeta){}$ are determined simultaneously.

**Scattergrams** visualize joint behavior: repeat the experiment many times and plot each observation pair ${}(x,y){}$ as a dot.

---

## Events Involving Two RVs

Events involving two RVs are **regions in the ${}x{}$-${}y{}$ plane**. To find the region:

1. Find the boundary of the event (it splits the plane into regions).
2. Test a point inside each region to see whether it belongs to the event.

>[!Example]
>For ${}\vec X=(X,Y){}$:
>- ${}A=\{X+Y\le 10\}{}$: the half-plane below the line ${}x+y=10{}$.
>- ${}B=\{\min(X,Y)\le 5\}{}$: the L-shaped region where ${}x\le 5{}$ or ${}y\le 5{}$.
>- ${}C=\{X^2+Y^2\le 100\}{}$: the disk of radius 10 centered at the origin.

---

## Pairs of Discrete Random Variables

Assume ${}X{}$ and ${}Y{}$ take integer values. The **joint probability mass function (joint pmf)** is

$$
p_{X,Y}(j,k)=P[\{X=j\}\cap\{Y=k\}]
$$

Properties:

1. **Probability of an event:** ${}P[(X,Y)\in A]=\sum_{(j,k)\in A}p_{X,Y}(j,k){}$.
2. **Normalization:**
$$
\sum_{j=-\infty}^{\infty}\sum_{k=-\infty}^{\infty}p_{X,Y}(j,k)=1
$$

>[!Example]
>**Two fair dice.** Let ${}X{}$ = dots on first die, ${}Z{}$ = dots on second die, and ${}Y=7-X{}$. Then
>$$
>P[X\le 2,\ Y\le 2]=0
>$$
>because ${}Y=7-X\ge 5{}$ whenever ${}X\le 2{}$. But
>$$
>P[X\le 2,\ Z\le 2]=P[X\le 2]P[Z\le 2]=\frac{2}{6}\cdot\frac{2}{6}=\frac19
>$$

>[!Example]
>**Loaded dice.** The joint pmf is a ${}6\times 6{}$ table (rows ${}k{}$, columns ${}j{}$) with entries mostly ${}1/42{}$ and a ${}2/42{}$ on each "diagonal". Then
>$$
>P[\min(X,Y)=3]=p_{X,Y}(3,3)+p_{X,Y}(3,4)+p_{X,Y}(3,5)+p_{X,Y}(3,6)
>+p_{X,Y}(4,3)+p_{X,Y}(5,3)+p_{X,Y}(6,3)
>$$
>$$
>=6\cdot\frac{1}{42}+\frac{2}{42}=\frac{8}{42}
>$$
>(the ${}2/42{}$ entry contributes once).

---

## Marginal Probability Mass Function

The **marginal pmf** of one RV is its distribution ignoring the other RV (summing the joint pmf over the other variable):

$$
p_X(j)=P[X=j]=\sum_{k=-\infty}^{\infty}p_{X,Y}(j,k)
$$

$$
p_Y(k)=P[Y=k]=\sum_{j=-\infty}^{\infty}p_{X,Y}(j,k)
$$

>[!note]
>Be careful when doing these sums: many entries may be zero.

>[!Example]
>**Loaded dice marginals.** Summing each column (over ${}k{}$) gives
>$$
>p_X(j)=\frac{2}{42}+\frac{1}{42}+\frac{1}{42}+\frac{1}{42}+\frac{1}{42}+\frac{1}{42}=\frac{7}{42}=\frac16
>$$
>for every ${}j{}$, and similarly ${}p_Y(k)=1/6{}$ for every ${}k{}$. Each die is marginally fair even though the joint distribution is not independent.

>[!Example]
>**${}X{}$ = die, ${}Y{}$ uniform on ${}\{1,\dots,X\}{}$.** The joint pmf is
>$$
>p_{X,Y}(j,k)=\begin{cases}\dfrac{1}{6}\cdot\dfrac{1}{j},&1\le k\le j\le 6\\[6pt]0,&\text{otherwise}\end{cases}
>$$
>For ${}j=1,\dots,6{}$:
>$$
>p_X(j)=\sum_{k=1}^{j}\frac{1}{6j}=j\cdot\frac{1}{6j}=\frac16
>$$
>For ${}k=1,\dots,6{}$:
>$$
>p_Y(k)=\sum_{j=k}^{6}\frac{1}{6j}
>$$
>e.g. ${}p_Y(1)=1/6+1/12+1/18+1/24+1/30+1/36=147/360\approx0.408{}$.

---

## Joint PMF from a Transformation

>[!Example]
>**Messages and packets.** The number of bytes ${}N{}$ in a message has geometric distribution
>$$
>p_N(n)=(1-q)q^{n},\qquad n=0,1,2,\dots
>$$
>(here ${}q=1-p{}$ where ${}p{}$ is the stopping probability; ${}E[N]=q/(1-q){}$). Messages are broken into packets of maximum length ${}M{}$ bytes. Let
>- ${}K{}$ = number of full packets,
>- ${}L{}$ = number of bytes left over.
>
>Then ${}N=KM+L{}$, so
>$$
>p_{K,L}(k,l)=P[K=k,L=l]=P[N=kM+l]=(1-q)q^{kM+l}
>$$
>for ${}k=0,1,2,\dots{}$ and ${}l=0,1,\dots,M-1{}$, and 0 otherwise.

### Marginal pmf of ${}K{}$

$$
p_K(k)=\sum_{l=0}^{M-1}(1-q)q^{kM+l}=(1-q)q^{kM}\sum_{l=0}^{M-1}q^l
$$

$$
p_K(k)=(1-q)q^{kM}\cdot\frac{1-q^M}{1-q}=(1-q^M)(q^M)^k,\qquad k=0,1,2,\dots
$$

So ${}K{}$ is geometric with parameter ${}q^M{}$ (in the "number of failures before stopping" form).

### Marginal pmf of ${}L{}$

$$
p_L(l)=\sum_{k=0}^{\infty}(1-q)q^{kM+l}=(1-q)q^l\sum_{k=0}^{\infty}(q^M)^k
$$

$$
p_L(l)=\frac{1-q}{1-q^M}\,q^l,\qquad l=0,1,\dots,M-1
$$

---

## Major Points

- The **joint pmf** contains all information about a pair of discrete RVs.
- **Marginal pmfs** are obtained by summing the joint pmf over the other variable.
- Events involving two RVs correspond to summing the joint pmf over a region of the plane.
