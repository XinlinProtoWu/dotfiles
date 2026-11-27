# Lecture 8: Continuous Random Variables

## Overview

- So far we studied **discrete** RVs (countable/finite set of values).
- Many quantities take values in an **uncountably infinite** set (e.g. the unit interval, the real line).
- For these we **cannot use a pmf**. We use instead:
  1. **Cumulative Distribution Function (CDF)**
  2. **Probability Density Function (PDF)**
  3. Characteristic function

---

## Cumulative Distribution Function (CDF)

$$
F_X(x)=P[X\le x]\qquad -\infty<x<\infty
$$
- **Relative frequency view:** ${}F_X(x){}$ is the proportion of times (over many repetitions) that ${}X{}$ lands at or below ${}x{}$.
- It only gives probabilities of semi-infinite intervals, but **every** event probability can be derived from it.

### Example: 3 coin tosses (discrete)
${}X={}$ number of heads, ${}S_X=\{0,1,2,3\}{}$ with pmf ${}1/8,3/8,3/8,1/8{}$.

| ${}x{}$ | ${}p_X(x){}$ | ${}F_X(x)=P[X\le x]{}$ |
| ------- | ------------ | ---------------------- |
| 0       | ${}1/8{}$    | ${}1/8{}$              |
| 1       | ${}3/8{}$    | ${}4/8=1/2{}$          |
| 2       | ${}3/8{}$    | ${}7/8{}$              |
| 3       | ${}1/8{}$    | ${}1{}$                |

Properties observed: the cdf is **piecewise constant** and **continuous from the right**.

At the jump at ${}1{}$:
- Left limit: ${}F_X(1-\delta)=P[X\le 1-\delta]=P\{0\text{ heads}\}=1/8{}$
- Right limit & value: ${}F_X(1)=P[X\le 1]=P\{0\text{ or }1\text{ heads}\}=1/2{}$

The cdf takes the **right** limit because of the non-strict inequality ${}X\le x{}$.

---

## Unit Step Function

$$
u(x)=\begin{cases}1 & x\ge 0\\0 & x<0\end{cases}
$$
- Useful for functions that vanish for negative ${}x{}$, e.g. ${}(1-e^{-\lambda x})u(x){}$.
- Scaled/shifted steps ${}a\cdot u(x-x_0){}$ build piecewise-constant functions.

### CDF as a sum of steps
For the 3-coin example:
$$
F_X(x)=\tfrac18 u(x)+\tfrac38 u(x-1)+\tfrac38 u(x-2)+\tfrac18 u(x-3)
$$
Each jump of the cdf has height equal to the pmf at that point.

---

## Continuous vs Mixed RVs (examples)

### Continuous example: exponential cdf
Waiting time for a taxi:
$$
F_X(x)=(1-e^{-\lambda x})u(x)=\begin{cases}1-e^{-\lambda x} & x\ge 0\\0 & \text{otherwise}\end{cases}
$$
- ${}\lambda{}$ = rate parameter (larger ${}\lambda{}$ ⇒ shorter average wait).
- This cdf is **continuous everywhere**.

### Mixed-type example
Waiting time ${}X{}$ at a taxi stand: ${}0{}$ if a taxi is already there (prob ${}p{}$), else exponential. By the **Total Probability Theorem**:
$$
F_X(x)=u(x)\cdot p+(1-e^{-\lambda x})u(x)\cdot(1-p)
$$
- Has a **jump** at ${}0{}$ (prob ${}p{}$) but is **not flat** between jumps ⇒ mixed type.

---

## Properties of the CDF

1. ${}0\le F_X(x)\le 1{}$ (it is a probability).
2. ${}\lim_{x\to\infty}F_X(x)=1{}$ and ${}\lim_{x\to-\infty}F_X(x)=0{}$.
3. **Non-decreasing:** ${}a<b\Rightarrow F_X(a)\le F_X(b){}$.
4. **Continuous from the right:** ${}F_X(b)=\lim_{h\to 0^+}F_X(b+h){}$.
5. If ${}F_X(x_0)=0{}$ then ${}F_X(x)=0{}$ for all ${}x<x_0{}$.
6. **Survival function:** ${}P[X>a]=1-F_X(a){}$.

### Probabilities of intervals
$$
P[a<X\le b]=F_X(b)-F_X(a)
$$

$$
P[a\leq X<b] = F_{X}(b^-)-F_{X}(a^-)
$$
$$
P[X=a]=F_X(a)-F_X(a^-),\qquad P[X<a]=F_X(a^-),\qquad P[X\le a]=F_X(a)
$$
where ${}F_X(a^-)=\lim_{\delta\to 0^+}F_X(a-\delta){}$.

>[!Example]
>3 coin tosses. Find ${}P[1<X\le 2]{}$, ${}P[0.5\le X<2.5]{}$, ${}P[1\le X<2]{}$:
>- ${}P[1<X\le 2]=F_X(2)-F_X(1)=\tfrac78-\tfrac12=\tfrac38{}$
>- ${}P[0.5\le X<2.5]=F_X(2.5^-)-F_X(0.5^-)=\tfrac78-\tfrac18=\tfrac68{}$
>- ${}P[1\le X<2]=F_X(2^-)-F_X(1^-)=\tfrac48-\tfrac18=\tfrac38{}$

---

## Three Types of Random Variables (Summary)

| Type           | CDF                                              | Notes                                                                                   |
| -------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------- |
| **Discrete**   | piecewise constant, jumps at ${}x_0,x_1,\dots{}$ | only takes jump values; ${}p_k=P[X=x_k]={}$ jump size; ${}F_X(x)=\sum_k p_k u(x-x_k){}$ |
| **Continuous** | continuous everywhere                            | ${}P[X=x]=0{}$ for every ${}x{}$                                                        |
| **Mixed**      | has jumps but not constant between them          | combination of both                                                                     |

---

## Probability Density Function (PDF)

- The **slope of the cdf** is informative: flat regions = "impossible", steep regions = "more likely".
- PDF = derivative of the CDF:
$$
f_X(x)=\frac{dF_X(x)}{dx}=\lim_{h\to 0}\frac{F_X(x+h)-F_X(x)}{h}
$$
>[!warning] Important
>The pdf is **NOT** ${}P[X=x]{}$. It is proportional to the probability that ${}X{}$ is **near** ${}x{}$:
$$P[x<X\le x+h]=F_X(x+h)-F_X(x)\approx f_X(x)\,h\qquad(h\text{ small})$$

### Properties of the PDF
1. ${}f_X(x)\ge 0{}$ (cdf is non-decreasing).
2. ${}F_X(x)=\int_{-\infty}^{x}f_X(t)\,dt{}$ (pdf ⇔ cdf are equivalent).
3. ${}\int_{-\infty}^{+\infty}f_X(t)\,dt=1{}$ (a good check!).
4. ${}P[a<X\le b]=\int_{a^+}^{b}f_X(x)\,dx{}$.

---

## Examples of Continuous RVs

>[!NOTE]
> Probability mass function P[X=x] is defined by the *Height* of the jump at x. Mathematically, it is defined as ${}P[X=x]=F_{X}(x) - F_{X}(x^-){}$
> For this reason, any continuous RV will have a P[X=x] = 0 because it has no jumps (right and left of x are the exact same so ${}F_{X}(x) - F_{X}(x^-) = 0{}$)

### Uniform RV on [a, b]
All values in ${}[a,b]{}$ equally likely.
$$
f_X(x)=\begin{cases}\frac{1}{b-a} & a\le x\le b\\0 & \text{otherwise}\end{cases}
$$
$$
F_X(x)=\begin{cases}0 & x<a\\ \frac{x-a}{b-a} & a\le x\le b\\1 & x>b\end{cases}
$$

### Exponential RV
$$
F_X(x)=(1-e^{-\lambda x})u(x)\quad\Rightarrow\quad f_X(x)=\lambda e^{-\lambda x}u(x)=\begin{cases}\lambda e^{-\lambda x} & x\ge 0\\0 & \text{otherwise}\end{cases}
$$
- Models time until next event (train arrival, etc.).

---

## PDF of Discrete RVs: the Dirac Delta Function

- The cdf of a discrete RV is a sum of steps: ${}F_X(x)=\sum_k p_k u(x-x_k){}$.
- The derivative of the unit step is the **delta function** ${}\delta(x){}$:
  - ${}\delta(x)=0{}$ for all ${}x\ne 0{}$.
  - For any interval ${}(a,b){}$ containing ${}0{}$: ${}\int_a^b\delta(x)\,dx=1{}$.
  - ${}\delta(0){}$ is undefined (infinite).
- So a discrete RV also has a "pdf" (generalized):
$$
f_X(x)=\sum_k p_k\,\delta(x-x_k)
$$

>[!Example]
>3 coin tosses: ${}F_X(x)=\tfrac18u(x)+\tfrac38u(x-1)+\tfrac38u(x-2)+\tfrac18u(x-3){}$,
$$f_X(x)=\tfrac18\delta(x)+\tfrac38\delta(x-1)+\tfrac38\delta(x-2)+\tfrac18\delta(x-3)$$

### Delta as a limiting function
$$
\delta(x)=\lim_{A\to\infty}d_A(x),\qquad d_A(x)=\begin{cases}A & -\frac{1}{2A}\le x\le\frac{1}{2A}\\0 & \text{otherwise}\end{cases}
$$
(a tall, narrow rectangle of unit area).
