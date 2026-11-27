# Lecture 14: Conditional Probability and Independence

> **Big picture.** Conditioning updates probabilities after we learn something. For random variables, conditioning on $X=x$ turns the joint distribution into a new distribution for $Y$. **Independence** is the special case where this update changes nothing: learning $X$ tells us nothing about $Y$.

---

## Learning goals

By the end of this lecture you should be able to:

1. Compute conditional pmfs and conditional pdfs.
2. Use the product rule in either direction.
3. Use the total probability theorem for distributions.
4. Use Bayes' theorem for classification.
5. Test whether two random variables are independent.
6. Distinguish discrete, continuous, and mixed cases.

---

## 1. Conditional PMF

For discrete $X,Y$,

$$
p_{Y\mid X}(k\mid j)=P[Y=k\mid X=j]
=\frac{P[Y=k,\ X=j]}{P[X=j]}
=\frac{p_{X,Y}(j,k)}{p_X(j)},
$$

provided $p_X(j)>0$.

If $p_X(j)=0$, the conditional pmf is **undefined**, because we are conditioning on an impossible event.

### Interpretation

$p_{Y\mid X}(k\mid j)$ is the probability that $Y=k$ **among those outcomes where $X=j$**.

### Properties

For fixed $j$, it is a valid pmf in $k$:

$$
\sum_{k=-\infty}^{\infty}p_{Y\mid X}(k\mid j)=1.
$$

But it is **not** a pmf in $j$:

$$
\sum_{j=-\infty}^{\infty}p_{Y\mid X}(k\mid j)\ne1
\quad\text{usually}.
$$

> [!Example]
> **Loaded dice.** $X$ is the first die, $Y$ is the second die, with the joint pmf table from the lecture. The marginal pmf of $X$ is uniform:
> $$
> p_X(j)=\frac16,\qquad j=1,\dots,6.
> $$
> To condition on $Y=5$, take row $5$ of the joint table. Its entries are
> $$
> \frac1{42},\frac1{42},\frac1{42},\frac1{42},\frac2{42},\frac1{42}.
> $$
> Since $p_Y(5)=\frac16=\frac7{42}$, we divide by $\frac7{42}$:
> $$
> p_{X\mid Y}(j\mid 5)=
> \begin{cases}
> \dfrac17,&j=1,2,3,4,6,\\[6pt]
> \dfrac27,&j=5.
> \end{cases}
> $$
> Conditioning changed the distribution: given $Y=5$, $X=5$ is twice as likely as each other value.

---

## 2. Product rule

Rearranging the definition gives two forms:

$$
\boxed{p_{X,Y}(j,k)=p_{Y\mid X}(k\mid j)\,p_X(j)}
$$

$$
\boxed{p_{X,Y}(j,k)=p_{X\mid Y}(j\mid k)\,p_Y(k)}
$$

This gives a **sequential recipe** for generating a pair:

1. Generate $X$ from $p_X$.
2. Given $X=j$, generate $Y$ from $p_{Y\mid X}(\cdot\mid j)$.

Or the other way around.

---

## 3. Total probability theorem

Sum the joint pmf over $X$:

$$
\boxed{p_Y(k)=\sum_j p_{X,Y}(j,k)
=\sum_j p_{Y\mid X}(k\mid j)\,p_X(j)}.
$$

In words: compute the probability of $Y=k$ under each possible value of $X$, then average those probabilities using the probabilities of the $X$ values.

More generally, for an event $A$ depending on $Y$,

$$
P[Y\in A]=\sum_j P[Y\in A\mid X=j]\,p_X(j).
$$

> [!Example]
> **Defects on a chip.** The total number of defects $X$ is Poisson with mean $\alpha$:
> $$
> p_X(n)=e^{-\alpha}\frac{\alpha^n}{n!},\qquad n=0,1,2,\dots
> $$
> Given $X=n$, the number $Y$ of defects in a region $R$ is binomial:
> $$
> p_{Y\mid X}(k\mid n)=\binom{n}{k}p^k(1-p)^{n-k},
> \qquad 0\le k\le n.
> $$
> Here $p$ is the probability that a defect falls in $R$.
>
> Find the pmf of $Y$:
> $$
> \begin{aligned}
> p_Y(k)
> &=\sum_{n=k}^{\infty}\binom{n}{k}p^k(1-p)^{n-k}\,
> e^{-\alpha}\frac{\alpha^n}{n!}\\
> &=\frac{(\alpha p)^k}{k!}e^{-\alpha}
> \sum_{n=k}^{\infty}\frac{[\alpha(1-p)]^{n-k}}{(n-k)!}\\
> &=\frac{(\alpha p)^k}{k!}e^{-\alpha}e^{\alpha(1-p)}\\
> &=\frac{(\alpha p)^k}{k!}e^{-\alpha p}.
> \end{aligned}
> $$
> Therefore
> $$
> \boxed{Y\sim\text{Poisson}(\alpha p)}.
> $$
>
> **Intuition:** each defect independently lands in $R$ with probability $p$, so the average number landing in $R$ is $\alpha p$.

---

## 4. Conditional PDF for continuous variables

If $X$ is continuous, then $P[X=x]=0$ for every $x$, so the formula $P[Y\le y\mid X=x]$ cannot be defined by direct division. Instead define the conditional CDF as a limit:

$$
F_{Y\mid X}(y\mid x)
=\lim_{h\to0^+}
\frac{P[Y\le y,\ x\le X\le x+h]}{P[x\le X\le x+h]}.
$$

For small $h$,

$$
P[Y\le y,\ x\le X\le x+h]
\approx h\int_{-\infty}^{y}f_{X,Y}(x,v)\,dv,
$$

$$
P[x\le X\le x+h]\approx h f_X(x).
$$

Therefore

$$
F_{Y\mid X}(y\mid x)
=\frac{\int_{-\infty}^{y}f_{X,Y}(x,v)\,dv}{f_X(x)}.
$$

Differentiate with respect to $y$:

$$
\boxed{f_{Y\mid X}(y\mid x)=\frac{f_{X,Y}(x,y)}{f_X(x)}},
\qquad f_X(x)>0.
$$

Similarly,

$$
\boxed{f_{X\mid Y}(x\mid y)=\frac{f_{X,Y}(x,y)}{f_Y(y)}},
\qquad f_Y(y)>0.
$$

### Graphical interpretation

Fix $x$. The function $y\mapsto f_{X,Y}(x,y)$ is a **slice** of the joint density. Dividing by $f_X(x)$ rescales that slice so that its area is $1$. Thus

$$
f_{Y\mid X}(y\mid x)
\propto f_{X,Y}(x,y)
\quad\text{as a function of }y.
$$

The conditional density is the joint density along the slice, normalized to unit area.

> [!Example]
> **Conditional densities for the triangular-support density.**
> $$
> f_{X,Y}(x,y)=
> \begin{cases}
> 2e^{-x}e^{-y},&0\le y\le x<\infty,\\
> 0,&\text{otherwise}.
> \end{cases}
> $$
> From Lecture 13,
> $$
> f_Y(y)=2e^{-2y},\qquad y\ge0,
> $$
> $$
> f_X(x)=2e^{-x}(1-e^{-x}),\qquad x\ge0.
> $$
>
> **Find $f_{X\mid Y}(x\mid y)$:** for $x\ge y$,
> $$
> f_{X\mid Y}(x\mid y)
> =\frac{2e^{-x}e^{-y}}{2e^{-2y}}
> =e^{-(x-y)}.
> $$
> So
> $$
> f_{X\mid Y}(x\mid y)=
> \begin{cases}
> e^{-(x-y)},&x\ge y,\\
> 0,&x<y.
> \end{cases}
> $$
> Given $Y=y$, the excess $X-y$ is exponential with rate $1$.
>
> **Find $f_{Y\mid X}(y\mid x)$:** for $0\le y\le x$,
> $$
> f_{Y\mid X}(y\mid x)
> =\frac{2e^{-x}e^{-y}}{2e^{-x}(1-e^{-x})}
> =\frac{e^{-y}}{1-e^{-x}}.
> $$
> So
> $$
> f_{Y\mid X}(y\mid x)=
> \begin{cases}
> \dfrac{e^{-y}}{1-e^{-x}},&0\le y\le x,\\[8pt]
> 0,&\text{otherwise}.
> \end{cases}
> $$
> This is an exponential density truncated to $[0,x]$.

---

## 5. Product rule, total probability, and Bayes for densities

The same rules hold with densities:

$$
\boxed{f_{X,Y}(x,y)=f_{Y\mid X}(y\mid x)f_X(x)}
$$

$$
\boxed{f_{X,Y}(x,y)=f_{X\mid Y}(x\mid y)f_Y(y)}
$$

$$
\boxed{f_Y(y)=\int_{-\infty}^{\infty}f_{Y\mid X}(y\mid x)f_X(x)\,dx}
$$

$$
\boxed{f_{X\mid Y}(x\mid y)
=\frac{f_{Y\mid X}(y\mid x)f_X(x)}
{\int_{-\infty}^{\infty}f_{Y\mid X}(y\mid u)f_X(u)\,du}}
$$

These are the continuous versions of the total probability theorem and Bayes' theorem.

> [!Example]
> **Uniform $X$, then uniform $Y$ below $X$.** Let
> $$
> X\sim\text{Uniform}[0,1],
> \qquad
> Y\mid X=x\sim\text{Uniform}[0,x].
> $$
> So
> $$
> f_X(x)=1,\quad 0\le x\le1,
> \qquad
> f_{Y\mid X}(y\mid x)=\frac1x,\quad 0\le y\le x.
> $$
> By total probability, for $0\le y\le1$,
> $$
> f_Y(y)=\int_y^1 \frac1x\cdot1\,dx
> =\big[\ln x\big]_y^1
> =-\ln y.
> $$
> Thus
> $$
> \boxed{f_Y(y)=-\ln y,\qquad 0<y\le1}.
> $$

> [!Example]
> **Bank queue.** The number of arrivals in time $t$ is Poisson with mean $\beta t$:
> $$
> p_{N\mid T}(k\mid t)=e^{-\beta t}\frac{(\beta t)^k}{k!}.
> $$
> The service time is exponential with rate $\alpha$:
> $$
> f_T(t)=\alpha e^{-\alpha t},\qquad t\ge0.
> $$
> Then
> $$
> \begin{aligned}
> p_N(k)
> &=\int_0^{\infty}p_{N\mid T}(k\mid t)f_T(t)\,dt\\
> &=\int_0^{\infty}e^{-\beta t}\frac{(\beta t)^k}{k!}
> \alpha e^{-\alpha t}\,dt\\
> &=\frac{\alpha\beta^k}{k!}\int_0^{\infty}t^k e^{-(\alpha+\beta)t}\,dt\\
> &=\frac{\alpha\beta^k}{(\alpha+\beta)^{k+1}}\\
> &=\frac{\alpha}{\alpha+\beta}
> \left(\frac{\beta}{\alpha+\beta}\right)^k.
> \end{aligned}
> $$
> Therefore $N$ is geometric on $\{0,1,2,\dots\}$ with success probability
> $$
> \boxed{p=\frac{\alpha}{\alpha+\beta}},
> \qquad
> p_N(k)=p(1-p)^k.
> $$
> Check: if service is fast ($\alpha$ large), $p\approx1$, so $N=0$ is likely.

---

## 6. Bayes' theorem and classification

### Urn example

Two urns $C_1,C_2$ are equally likely. The conditional probabilities of drawing a ball labeled "1" or "2" are

$$
P[\text{"1"}\mid C_1]=0.8,\quad P[\text{"2"}\mid C_1]=0.2,
$$

$$
P[\text{"1"}\mid C_2]=0.4,\quad P[\text{"2"}\mid C_2]=0.6.
$$

Total probability:

$$
P[\text{"1"}]=0.8(0.5)+0.4(0.5)=0.6,
$$

$$
P[\text{"2"}]=0.2(0.5)+0.6(0.5)=0.4.
$$

If we observe a "2", Bayes gives

$$
P[C_2\mid \text{"2"}]
=\frac{P[\text{"2"}\mid C_2]P[C_2]}
{P[\text{"2"}\mid C_1]P[C_1]+P[\text{"2"}\mid C_2]P[C_2]}
=\frac{0.6(0.5)}{0.2(0.5)+0.6(0.5)}
=0.75.
$$

So observing a "2" makes $C_2$ more likely, but we are only $75\%$ sure.

If instead $P[C_1]=0.9$ and $P[C_2]=0.1$, then

$$
P[C_2\mid \text{"2"}]
=\frac{0.8(0.1)}{0.2(0.9)+0.8(0.1)}
\approx0.3077.
$$

Even though $C_2$ has more "2" balls, the strong prior for $C_1$ makes $C_1$ more likely after observing a "2".

### Height classification (mixed discrete/continuous)

Let $X\in\{M,F\}$ with priors

$$
p_X(M)=0.7,\qquad p_X(F)=0.3.
$$

The height densities given sex are

$$
f_{Y\mid X}(y\mid M)=\mathcal N(y\mid175,64),
$$

$$
f_{Y\mid X}(y\mid F)=\mathcal N(y\mid160,40).
$$

After observing height $y$, the posterior probability of male is

$$
\boxed{
p_{X\mid Y}(M\mid y)
=\frac{0.7\,\mathcal N(y\mid175,64)}
{0.7\,\mathcal N(y\mid175,64)+0.3\,\mathcal N(y\mid160,40)}
}.
$$

And

$$
p_{X\mid Y}(F\mid y)=1-p_{X\mid Y}(M\mid y).
$$

This is the Bayes classifier: choose the class with the larger posterior probability.

---

## 7. Independence

### Definition

$X$ and $Y$ are **independent** if for all events $A_X$ depending only on $X$ and $A_Y$ depending only on $Y$,

$$
\boxed{P[X\in A_X,\ Y\in A_Y]
=P[X\in A_X]\,P[Y\in A_Y]}.
$$

Intuition: learning one variable gives no information about the other.

### Discrete case

$X$ and $Y$ are independent **if and only if**

$$
\boxed{p_{X,Y}(j,k)=p_X(j)p_Y(k)}
\quad\text{for all }j,k.
$$

Proof of the "if" direction: for product-form events,

$$
\begin{aligned}
P[X\in A_X,\ Y\in A_Y]
&=\sum_{j\in A_X}\sum_{k\in A_Y}p_{X,Y}(j,k)\\
&=\sum_{j\in A_X}\sum_{k\in A_Y}p_X(j)p_Y(k)\\
&=\left(\sum_{j\in A_X}p_X(j)\right)
\left(\sum_{k\in A_Y}p_Y(k)\right)\\
&=P[X\in A_X]P[Y\in A_Y].
\end{aligned}
$$

### Conditional probability view

If $X$ and $Y$ are independent and the denominators are positive,

$$
\boxed{p_{Y\mid X}(k\mid j)=p_Y(k)},
\qquad
\boxed{p_{X\mid Y}(j\mid k)=p_X(j)}.
$$

So conditioning does not change the distribution.

### Continuous case

The following are equivalent:

1. $X$ and $Y$ are independent.
2. $F_{X,Y}(x,y)=F_X(x)F_Y(y)$ for all $x,y$.
3. $f_{X,Y}(x,y)=f_X(x)f_Y(y)$ for all $x,y$.

> [!Example]
> **Independent exponentials.** If
> $$
> f_{X,Y}(x,y)=
> \begin{cases}
> \alpha\beta e^{-\alpha x}e^{-\beta y},&x\ge0,\ y\ge0,\\
> 0,&\text{otherwise},
> \end{cases}
> $$
> then
> $$
> f_X(x)=\alpha e^{-\alpha x},\quad x\ge0,
> \qquad
> f_Y(y)=\beta e^{-\beta y},\quad y\ge0.
> $$
> Since $f_{X,Y}(x,y)=f_X(x)f_Y(y)$, $X$ and $Y$ are independent.

> [!Example]
> **Dependent even with a product-looking formula.** For
> $$
> f_{X,Y}(x,y)=
> \begin{cases}
> 2e^{-x}e^{-y},&0\le y\le x<\infty,\\
> 0,&\text{otherwise},
> \end{cases}
> $$
> the support $0\le y\le x$ couples $X$ and $Y$. The marginals are
> $$
> f_X(x)=2e^{-x}(1-e^{-x}),\qquad
> f_Y(y)=2e^{-2y}.
> $$
> Their product is not equal to $f_{X,Y}(x,y)$, so $X$ and $Y$ are **dependent**.

> [!Example]
> **Loaded dice are not independent.** The joint table has a $2/42$ on each diagonal. The marginals are uniform, so if the dice were independent every joint entry would be
> $$
> \frac16\cdot\frac16=\frac1{36}.
> $$
> But the table contains entries $1/42$ and $2/42$, not $1/36$. Therefore the outcomes are dependent.

> [!Example]
> **Packet lengths.** Let $N$ be the message length in bytes, geometric:
> $$
> p_N(n)=(1-q)q^n,\qquad n=0,1,2,\dots
> $$
> Break the message into full packets of size $M$ and a leftover of $L$ bytes. Then
> $$
> N=KM+L,\qquad 0\le L\le M-1.
> $$
> One can show
> $$
> p_{K,L}(k,l)=(1-q)q^{kM+l},
> $$
> $$
> p_K(k)=(1-q^M)(q^M)^k,
> \qquad
> p_L(l)=\frac{1-q}{1-q^M}q^l.
> $$
> Then
> $$
> p_K(k)p_L(l)
=(1-q^M)(q^M)^k\cdot\frac{1-q}{1-q^M}q^l
=(1-q)q^{kM+l}
=p_{K,L}(k,l).
> $$
> So $K$ and $L$ are independent. Intuitively, once you know the packet size $M$, the leftover is just the remainder of a geometric process, and the number of full packets carries no extra information about it.

---

## 8. Common mistakes

1. **Conditioning on a zero-probability event.** For discrete variables, $p_{Y\mid X}(k\mid j)$ is undefined if $p_X(j)=0$.
2. **Summing a conditional pmf over the wrong variable.** For fixed $j$, $\sum_k p_{Y\mid X}(k\mid j)=1$, not $\sum_j$.
3. **Thinking $f_{Y\mid X}(y\mid x)$ is a probability.** It is a density in $y$.
4. **Forgetting the support when dividing.** The conditional density is zero outside the slice where the joint density is nonzero.
5. **Confusing independence with "the formula looks separable."** Always compare with the product of the **marginals**, and check the support.
6. **Using $P[A\mid B]=P[A]$ without independence.** This is true only when $A$ and $B$ are independent.
7. **Bayes with the wrong denominator.** The denominator is the total probability of the observation, summed/integrated over all classes.

---

## 9. 60-second summary

$$
\boxed{p_{Y\mid X}(k\mid j)=\frac{p_{X,Y}(j,k)}{p_X(j)}}
\qquad
\boxed{f_{Y\mid X}(y\mid x)=\frac{f_{X,Y}(x,y)}{f_X(x)}}
$$

$$
\boxed{p_{X,Y}(j,k)=p_{Y\mid X}(k\mid j)p_X(j)}
$$

$$
\boxed{p_Y(k)=\sum_j p_{Y\mid X}(k\mid j)p_X(j)}
$$

$$
\boxed{f_Y(y)=\int f_{Y\mid X}(y\mid x)f_X(x)\,dx}
$$

$$
\boxed{f_{X\mid Y}(x\mid y)=\frac{f_{Y\mid X}(y\mid x)f_X(x)}
{\int f_{Y\mid X}(y\mid u)f_X(u)\,du}}
$$

$$
\boxed{X\perp Y
\iff p_{X,Y}(j,k)=p_X(j)p_Y(k)
\iff f_{X,Y}(x,y)=f_X(x)f_Y(y)}
$$

If independent, conditioning does nothing: $p_{Y\mid X}(k\mid j)=p_Y(k)$ and $f_{Y\mid X}(y\mid x)=f_Y(y)$.
