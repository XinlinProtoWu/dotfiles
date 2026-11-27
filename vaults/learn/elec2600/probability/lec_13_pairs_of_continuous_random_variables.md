# Lecture 13: Pairs of Continuous Random Variables

> **Big picture.** A single random variable maps outcomes to the real line. A pair $(X,Y)$ maps outcomes to the plane. Instead of a pmf, we describe probabilities by a **joint CDF** and, when it is smooth enough, a **joint PDF**. Probabilities become **volumes under a surface** over regions in the $xy$-plane.

---

## Learning goals

By the end of this lecture you should be able to:

1. Write and use the joint CDF $F_{X,Y}(x,y)$.
2. Compute probabilities of rectangles and product-form events from the CDF.
3. Use the joint PDF $f_{X,Y}(x,y)$ and integrate it over a region.
4. Recover marginal densities by integrating out the unwanted variable.
5. Handle a pair where one variable is discrete and the other is continuous.

---

## 1. Joint cumulative distribution function

For two random variables $X$ and $Y$, the **joint CDF** is

$$
F_{X,Y}(x,y)=P\big[\{X\le x\}\cap\{Y\le y\}\big].
$$

It gives the probability that the random point $(X,Y)$ lies in the **southwest rectangle**

$$
(-\infty,x]\times(-\infty,y].
$$

### Properties

1. **Monotone in both arguments:**

$$
x_1\le x_2,\ y_1\le y_2
\quad\Longrightarrow\quad
F_{X,Y}(x_1,y_1)\le F_{X,Y}(x_2,y_2).
$$

2. **Limits:**

$$
F_{X,Y}(-\infty,-\infty)=0,
$$

$$
F_{X,Y}(-\infty,y)=F_{X,Y}(x,-\infty)=0,
$$

$$
F_{X,Y}(\infty,\infty)=1.
$$

3. **Right-continuous** in each argument.

4. **Marginal CDFs** are obtained by sending the other argument to $+\infty$:

$$
F_X(x)=F_{X,Y}(x,\infty),
\qquad
F_Y(y)=F_{X,Y}(\infty,y).
$$

> **Important:** the joint CDF determines the marginals, but the marginals do **not** determine the joint distribution in general.

---

## 2. Probabilities of rectangles from the CDF

For $x_1<x_2$ and $y_1<y_2$,

$$
P\big[x_1<X\le x_2,\ Y\le y\big]
=F_{X,Y}(x_2,y)-F_{X,Y}(x_1,y),
$$

$$
P\big[X\le x,\ y_1<Y\le y_2\big]
=F_{X,Y}(x,y_2)-F_{X,Y}(x,y_1).
$$

For a rectangle,

$$
\begin{aligned}
P\big[x_1<X\le x_2,\ y_1<Y\le y_2\big]
={}&F_{X,Y}(x_2,y_2)-F_{X,Y}(x_2,y_1)\\
&-F_{X,Y}(x_1,y_2)+F_{X,Y}(x_1,y_1).
\end{aligned}
$$

This is inclusion–exclusion: add the large southwest rectangle, subtract the two unwanted strips, then add back the part subtracted twice.

---

## 3. Product-form events

A **product-form event** is an intersection of an event depending only on $X$ and an event depending only on $Y$:

$$
A=\{X\in A_1\}\cap\{Y\in A_2\}.
$$

Such events are rectangular (possibly unbounded) regions.

> [!Example]
> **Event $\{|X|>x_1,\ y_1<Y\le y_2\}$ with $x_1>0$.**
>
> The region is two vertical strips: $x<-x_1$ or $x>x_1$, between $y_1$ and $y_2$.
>
> First take all of the horizontal slab $y_1<Y\le y_2$:
> $$
> P[y_1<Y\le y_2]=F_{X,Y}(\infty,y_2)-F_{X,Y}(\infty,y_1).
> $$
> Subtract the middle part $-x_1\le X\le x_1$:
> $$
> \begin{aligned}
> P\big[|X|>x_1,\ y_1<Y\le y_2\big]
> ={}&P[y_1<Y\le y_2]\\
> &-P[-x_1<X\le x_1,\ y_1<Y\le y_2].
> \end{aligned}
> $$
> Using the rectangle formula,
> $$
> \begin{aligned}
> P[-x_1<X\le x_1,\ y_1<Y\le y_2]
> ={}&F_{X,Y}(x_1,y_2)-F_{X,Y}(x_1,y_1)\\
> &-F_{X,Y}(-x_1,y_2)+F_{X,Y}(-x_1,y_1).
> \end{aligned}
> $$
> So the answer is
> $$
> \begin{aligned}
> &F_{X,Y}(\infty,y_2)-F_{X,Y}(\infty,y_1)\\
> &\quad-\big[F_{X,Y}(x_1,y_2)-F_{X,Y}(x_1,y_1)
> -F_{X,Y}(-x_1,y_2)+F_{X,Y}(-x_1,y_1)\big].
> \end{aligned}
> $$

---

## 4. Joint probability density function

Two random variables are **jointly continuous** if $F_{X,Y}$ is continuous and differentiable. The **joint PDF** is

$$
f_{X,Y}(x,y)=\frac{\partial^2 F_{X,Y}(x,y)}{\partial x\,\partial y}.
$$

Conversely,

$$
F_{X,Y}(x,y)=\int_{-\infty}^{x}\int_{-\infty}^{y} f_{X,Y}(u,v)\,dv\,du.
$$

### Key properties

1. **Nonnegative:**
$$
f_{X,Y}(x,y)\ge 0.
$$

2. **Normalization:**
$$
\int_{-\infty}^{\infty}\int_{-\infty}^{\infty}
f_{X,Y}(x,y)\,dx\,dy=1.
$$

3. **Probability of a region $A$:**
$$
P[(X,Y)\in A]=\iint_A f_{X,Y}(x,y)\,dx\,dy.
$$

In particular,

$$
P[x_1<X\le x_2,\ y_1<Y\le y_2]
=\int_{y_1}^{y_2}\int_{x_1}^{x_2}f_{X,Y}(x,y)\,dx\,dy.
$$

4. **Zero probability for exact points:**
$$
P[X=x,\ Y=y]=0.
$$

5. **The PDF is not a probability.** It can be larger than $1$. For a tiny rectangle,
$$
P[x<X\le x+\Delta x,\ y<Y\le y+\Delta y]
\approx f_{X,Y}(x,y)\,\Delta x\,\Delta y.
$$

> **Simple check.** If $f_{X,Y}(x,y)=c$ on a region $R$ and $0$ outside, then
> $$
> P[(X,Y)\in A]=c\cdot \text{area}(A\cap R).
> $$
> This is often faster than doing a double integral.

---

## 5. Marginal densities

To get the density of $X$ alone, integrate the joint density over all possible $y$:

$$
f_X(x)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dy.
$$

Similarly,

$$
f_Y(y)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dx.
$$

Geometrically:

- $f_X(x)$ is obtained by integrating along a **vertical line** at fixed $x$.
- $f_Y(y)$ is obtained by integrating along a **horizontal line** at fixed $y$.

> **Warning:** knowing $f_X$ and $f_Y$ is usually **not enough** to recover $f_{X,Y}$. The joint density also contains dependence information.

---

## 6. Worked example: uniform density on a rectangle

Let

$$
f_{X,Y}(x,y)=
\begin{cases}
c,&0\le x\le 2,\ 0\le y\le 1,\\
0,&\text{otherwise}.
\end{cases}
$$

### (a) Find $c$

The region is a rectangle of area

$$
2\times 1=2.
$$

Since the total probability is $1$,

$$
c\cdot 2=1
\quad\Longrightarrow\quad
c=\frac12.
$$

### (b) Find the joint CDF

$$
F_{X,Y}(x,y)=
\begin{cases}
0,&x<0\ \text{or}\ y<0,\\[4pt]
\dfrac{xy}{2},&0\le x\le 2,\ 0\le y\le 1,\\[6pt]
\dfrac{x}{2},&0\le x\le 2,\ y\ge 1,\\[6pt]
y,&x\ge 2,\ 0\le y\le 1,\\[4pt]
1,&x\ge 2,\ y\ge 1.
\end{cases}
$$

Check: for $0\le x\le 2$ and $0\le y\le 1$, the southwest rectangle has area $xy$, so its probability is $\frac12 xy$.

### (c) Marginals

For $0\le x\le 2$,

$$
f_X(x)=\int_0^1 \frac12\,dy=\frac12.
$$

For $0\le y\le 1$,

$$
f_Y(y)=\int_0^2 \frac12\,dx=1.
$$

So

$$
X\sim \text{Uniform}[0,2],
\qquad
Y\sim \text{Uniform}[0,1].
$$

### (d) Probabilities

$$
P[X+Y<0.5]
=\frac12\cdot \text{area of triangle with legs }0.5,0.5
=\frac12\cdot\frac18
=\frac1{16}.
$$

For $X+Y<1.5$, the part of the rectangle below the line has area $1$, so

$$
P[X+Y<1.5]=\frac12\cdot 1=\frac12.
$$

For $X+Y<2.5$, the excluded triangle in the top-right corner has area

$$
\frac12\cdot 0.5\cdot 0.5=\frac18,
$$

so

$$
P[X+Y<2.5]
=1-\frac12\cdot\frac18
=1-\frac1{16}
=\frac{15}{16}.
$$

---

## 7. Worked example: a triangular-support density

Let

$$
f_{X,Y}(x,y)=
\begin{cases}
c\,e^{-x}e^{-y},&0\le y\le x<\infty,\\
0,&\text{otherwise}.
\end{cases}
$$

The support is the wedge between $y=0$ and $y=x$.

### (a) Find $c$

Normalize:

$$
1=\int_0^\infty\int_0^x c e^{-x}e^{-y}\,dy\,dx.
$$

Inner integral:

$$
\int_0^x e^{-y}\,dy=1-e^{-x}.
$$

Thus

$$
1=c\int_0^\infty e^{-x}(1-e^{-x})\,dx
=c\left[\int_0^\infty e^{-x}dx-\int_0^\infty e^{-2x}dx\right]
=c\left(1-\frac12\right)
=\frac{c}{2}.
$$

Hence

$$
c=2.
$$

### (b) Marginal of $Y$

For $y\ge 0$, $x$ ranges from $y$ to $\infty$:

$$
f_Y(y)=\int_y^\infty 2e^{-x}e^{-y}\,dx
=2e^{-y}\int_y^\infty e^{-x}\,dx
=2e^{-y}\cdot e^{-y}
=2e^{-2y}.
$$

So

$$
f_Y(y)=2e^{-2y},\qquad y\ge 0.
$$

That is, $Y\sim\text{Exponential}(2)$.

### (c) Marginal of $X$

For $x\ge 0$, $y$ ranges from $0$ to $x$:

$$
f_X(x)=\int_0^x 2e^{-x}e^{-y}\,dy
=2e^{-x}(1-e^{-x}).
$$

So

$$
f_X(x)=2e^{-x}(1-e^{-x}),\qquad x\ge 0.
$$

### (d) Find $P[X+Y\le 1]$

We integrate over the triangle $0\le y\le x$ and $x+y\le1$:

$$
P[X+Y\le1]
=\int_0^{1/2}\int_y^{1-y}2e^{-x}e^{-y}\,dx\,dy.
$$

Inner integral:

$$
\int_y^{1-y}2e^{-x}e^{-y}\,dx
=2e^{-y}\left(e^{-y}-e^{-(1-y)}\right).
$$

Then

$$
\begin{aligned}
P[X+Y\le1]
&=\int_0^{1/2}2\left(e^{-2y}-e^{-1}\right)dy\\
&=\left[-e^{-2y}-2e^{-1}y\right]_0^{1/2}\\
&=\left(-e^{-1}-e^{-1}\right)-(-1)\\
&=1-2e^{-1}.
\end{aligned}
$$

Numerically,

$$
1-2e^{-1}\approx 0.2642.
$$

---

## 8. Pairs of continuous and discrete random variables

A very common pattern is:

- $X$ is **discrete** (a class label, a bit, a category).
- $Y$ is **continuous** (a measurement such as height or voltage).

### Joint CDF

$$
F_{X,Y}(x,y)=P[X\le x,\ Y\le y].
$$

### Hybrid "pmf in $X$, CDF in $Y$"

$$
p_{X,Y}(x,y)=P[X=x,\ Y\le y].
$$

### Hybrid "pmf in $X$, density in $Y$"

$$
f_{X,Y}(x,y)=\frac{d}{dy}P[X=x,\ Y\le y].
$$

This is a density in $y$ for each fixed value $x$, but a probability mass in $x$.

> **Notation warning.** Slides sometimes use $p$ and $f$ loosely. Always check the definition in the slide. Here $f_{X,Y}(x,y)$ is **not** a two-dimensional PDF; it is a hybrid object.

### Marginals

$$
p_X(x)=P[X=x]=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dy,
$$

$$
f_Y(y)=\sum_x f_{X,Y}(x,y).
$$

### Conditional objects

If $f_Y(y)>0$,

$$
p_{X\mid Y}(x\mid y)=\frac{f_{X,Y}(x,y)}{f_Y(y)},
$$

and if $p_X(x)>0$,

$$
f_{Y\mid X}(y\mid x)=\frac{f_{X,Y}(x,y)}{p_X(x)}.
$$

> [!Example]
> **Sex and height.** Let $X=0$ for male, $X=1$ for female. Suppose
> $$
> f_{X,Y}(x,y)=
> \begin{cases}
> 0.6\,\mathcal N(y\mid175,64),&x=0,\\
> 0.4\,\mathcal N(y\mid160,40),&x=1,
> \end{cases}
> $$
> where
> $$
> \mathcal N(y\mid m,\sigma^2)
> =\frac{1}{\sqrt{2\pi}\sigma}
> \exp\left[-\frac{(y-m)^2}{2\sigma^2}\right].
> $$
>
> **Marginal pmf of $X$:**
> $$
> P[X=0]=\int_{-\infty}^{\infty}0.6\mathcal N(y\mid175,64)\,dy=0.6,
> $$
> $$
> P[X=1]=\int_{-\infty}^{\infty}0.4\mathcal N(y\mid160,40)\,dy=0.4.
> $$
>
> **Marginal density of $Y$:**
> $$
> f_Y(y)=0.6\mathcal N(y\mid175,64)+0.4\mathcal N(y\mid160,40).
> $$
>
> This is a **mixture** of two Gaussian densities. It is not Gaussian in general.

---

## 9. Common mistakes

1. **Treating a PDF value as a probability.** $f_{X,Y}(x,y)$ is a density; only integrals over areas give probabilities.
2. **Forgetting the support.** Always write the region where $f_{X,Y}\ne0$ and use it as the integration limits.
3. **Using the wrong marginal.** $f_X$ integrates over $y$; $f_Y$ integrates over $x$.
4. **Assuming marginals determine the joint.** They do not.
5. **Mixing up CDF and PDF.** The CDF is a probability; the PDF is its derivative.
6. **Ignoring the hybrid case.** When one variable is discrete, sums and integrals are mixed.

---

## 10. 60-second summary

$$
\boxed{F_{X,Y}(x,y)=P[X\le x,\ Y\le y]}
$$

$$
\boxed{f_{X,Y}(x,y)=\frac{\partial^2 F_{X,Y}}{\partial x\,\partial y}}
$$

$$
\boxed{P[(X,Y)\in A]=\iint_A f_{X,Y}(x,y)\,dx\,dy}
$$

$$
\boxed{f_X(x)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dy}
\qquad
\boxed{f_Y(y)=\int_{-\infty}^{\infty}f_{X,Y}(x,y)\,dx}
$$

For a uniform density on a region $R$:

$$
\boxed{P[(X,Y)\in A]=\frac{\text{area}(A\cap R)}{\text{area}(R)}}.
$$

For mixed discrete–continuous pairs, replace the appropriate integral by a sum.
