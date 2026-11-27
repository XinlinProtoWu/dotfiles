# ELEC2600 Homework #2 — Solutions

> Numerical answers are given exactly and to 3 significant figures where appropriate.

---

## Question 1

The pmf of ${}X{}$:

| ${}x{}$ | 0 | 1 | 2 | 3 | 4 | 5 | otherwise |
|---|---|---|---|---|---|---|---|
| ${}p_X(x){}$ | 0.15 | 0.25 | 0.10 | ${}a{}$ | 0.20 | 0.10 | 0 |

### (1.1) Find ${}a{}$

A pmf must sum to 1 over all values of ${}x{}$:

$$
\sum_x p_X(x)=0.15+0.25+0.10+a+0.20+0.10=0.80+a=1
$$

$$
a=1-0.80=0.20
$$

**Answer: ${}a=0.20{}$**

---

### (1.2) Find ${}E[X]{}$ and ${}VAR[X]{}$

$$
E[X]=\sum_x x\,p_X(x)
$$

$$
E[X]=0(0.15)+1(0.25)+2(0.10)+3(0.20)+4(0.20)+5(0.10)
$$

$$
E[X]=0+0.25+0.20+0.60+0.80+0.50=2.35
$$

For the variance, first compute the second moment:

$$
E[X^2]=\sum_x x^2 p_X(x)
$$

$$
E[X^2]=0^2(0.15)+1^2(0.25)+2^2(0.10)+3^2(0.20)+4^2(0.20)+5^2(0.10)
$$

$$
E[X^2]=0+0.25+0.40+1.80+3.20+2.50=8.15
$$

$$
VAR[X]=E[X^2]-(E[X])^2=8.15-(2.35)^2=8.15-5.5225=2.6275
$$

**Answer: ${}E[X]=2.35{}$, ${}VAR[X]=2.6275\approx 2.63{}$**

---

### (1.3) Probability of ${}A=\{X>1\}{}$

$$
P[A]=P[X>1]=P[X=2]+P[X=3]+P[X=4]+P[X=5]
$$

$$
P[A]=0.10+0.20+0.20+0.10=0.60
$$

**Answer: ${}P[A]=0.60{}$**

---

### (1.4) Conditional pmf of ${}X{}$ given ${}A{}$

For ${}x\in A=\{2,3,4,5\}{}$:

$$
p_{X|A}(x)=P[X=x\mid A]=\frac{P[\{X=x\}\cap A]}{P[A]}=\frac{p_X(x)}{P[A]}
$$

and ${}p_{X|A}(x)=0{}$ for ${}x\notin A{}$.

$$
p_{X|A}(2)=\frac{0.10}{0.60}=\frac16,\qquad
p_{X|A}(3)=\frac{0.20}{0.60}=\frac13
$$

$$
p_{X|A}(4)=\frac{0.20}{0.60}=\frac13,\qquad
p_{X|A}(5)=\frac{0.10}{0.60}=\frac16
$$

Check: ${}\tfrac16+\tfrac13+\tfrac13+\tfrac16=1{}$.

**Answer:**

$$
p_{X|A}(x)=\begin{cases}
1/6, & x=2\\
1/3, & x=3\\
1/3, & x=4\\
1/6, & x=5\\
0, & \text{otherwise}
\end{cases}
$$

---

### (1.5) Find ${}E[X|A]{}$ and ${}VAR[X|A]{}$

$$
E[X|A]=\sum_{x\in A}x\,p_{X|A}(x)
=2\cdot\frac16+3\cdot\frac13+4\cdot\frac13+5\cdot\frac16
$$

$$
E[X|A]=\frac{2+5}{6}+\frac{3+4}{3}=\frac{7}{6}+\frac{7}{3}=\frac{7}{6}+\frac{14}{6}=\frac{21}{6}=3.5
$$

$$
E[X^2|A]=2^2\cdot\frac16+3^2\cdot\frac13+4^2\cdot\frac13+5^2\cdot\frac16
=\frac{4+25}{6}+\frac{9+16}{3}=\frac{29}{6}+\frac{25}{3}=\frac{79}{6}
$$

$$
VAR[X|A]=E[X^2|A]-(E[X|A])^2=\frac{79}{6}-(3.5)^2=\frac{79}{6}-\frac{49}{4}=\frac{79}{6}-\frac{73.5}{6}=\frac{5.5}{6}=\frac{11}{12}
$$

**Answer: ${}E[X|A]=3.5{}$, ${}VAR[X|A]=\dfrac{11}{12}\approx 0.917{}$**

---

### (1.6) pmf of ${}Y=|X-2|{}$

Evaluate ${}Y{}$ for each possible ${}x{}$:

| ${}x{}$ | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| ${}y=|x-2|{}$ | 2 | 1 | 0 | 1 | 2 | 3 |

So ${}Y\in\{0,1,2,3\}{}$, and we add probabilities of ${}x{}$-values that give the same ${}y{}$:

$$
p_Y(0)=p_X(2)=0.10
$$

$$
p_Y(1)=p_X(1)+p_X(3)=0.25+0.20=0.45
$$

$$
p_Y(2)=p_X(0)+p_X(4)=0.15+0.20=0.35
$$

$$
p_Y(3)=p_X(5)=0.10
$$

Check: ${}0.10+0.45+0.35+0.10=1{}$.

**Answer:**

$$
p_Y(y)=\begin{cases}
0.10, & y=0\\
0.45, & y=1\\
0.35, & y=2\\
0.10, & y=3\\
0, & \text{otherwise}
\end{cases}
$$

---

## Question 2

Let ${}E{}$ = "orders from PizzaExpress" and ${}H{}$ = "orders from Pizza Hut".

$$
P[E]=0.6,\qquad P[H]=0.4
$$

Given the restaurant, ${}X{}$ is Poisson:

$$
X\mid E\sim\text{Poisson}(12),\qquad X\mid H\sim\text{Poisson}(8)
$$

### (2.1) Conditional pmf of ${}X{}$ given PizzaExpress

For a Poisson RV with mean ${}\lambda{}$: ${}P[X=k]=\dfrac{e^{-\lambda}\lambda^k}{k!}{}$.

$$
p_{X|E}(k)=P[X=k\mid E]=\frac{e^{-12}12^k}{k!},\qquad k=0,1,2,\dots
$$

---

### (2.2) Conditional pmf of ${}X{}$ given Pizza Hut

$$
p_{X|H}(k)=P[X=k\mid H]=\frac{e^{-8}8^k}{k!},\qquad k=0,1,2,\dots
$$

---

### (2.3) pmf of ${}X{}$

By the **total probability theorem** (${}E{}$ and ${}H{}$ partition the sample space):

$$
p_X(k)=p_{X|E}(k)P[E]+p_{X|H}(k)P[H]
$$

$$
p_X(k)=0.6\,\frac{e^{-12}12^k}{k!}+0.4\,\frac{e^{-8}8^k}{k!},\qquad k=0,1,2,\dots
$$

This is a **mixture** of two Poisson pmfs.

---

### (2.4) ${}E[X]{}$

Using the law of total expectation:

$$
E[X]=E[X|E]P[E]+E[X|H]P[H]
$$

For a Poisson RV, ${}E[X]=\lambda{}$:

$$
E[X]=0.6(12)+0.4(8)=7.2+3.2=10.4
$$

**Answer: ${}E[X]=10.4{}$**

---

### (2.5) ${}VAR[X]{}$

For a Poisson RV, ${}E[X^2]=\lambda+\lambda^2{}$ (since ${}VAR[X]=\lambda{}$ and ${}E[X]=\lambda{}$). Thus

$$
E[X^2|E]=12+12^2=156,\qquad E[X^2|H]=8+8^2=72
$$

By total expectation for the second moment:

$$
E[X^2]=E[X^2|E]P[E]+E[X^2|H]P[H]=0.6(156)+0.4(72)=93.6+28.8=122.4
$$

$$
VAR[X]=E[X^2]-(E[X])^2=122.4-(10.4)^2=122.4-108.16=14.24
$$

**Answer: ${}VAR[X]=14.24{}$**

> Alternative: law of total variance
> $$
> VAR[X]=E[VAR(X|\text{restaurant})]+VAR(E[X|\text{restaurant}])
> =0.6(12)+0.4(8)+\big(0.6(12^2)+0.4(8^2)-10.4^2\big)=10.4+3.84=14.24
> $$

---

### (2.6) ${}P[H\mid X=10]{}$

By Bayes' rule:

$$
P[H\mid X=10]=\frac{P[X=10\mid H]P[H]}{P[X=10]}
$$

Compute the pieces:

$$
P[X=10\mid H]=\frac{e^{-8}8^{10}}{10!}=0.0992615\dots
$$

$$
P[X=10\mid E]=\frac{e^{-12}12^{10}}{10!}=0.1048372\dots
$$

$$
P[X=10]=P[X=10\mid E]P[E]+P[X=10\mid H]P[H]
$$

$$
P[X=10]=0.6(0.1048372\dots)+0.4(0.0992615\dots)=0.0629023+0.0397046=0.1026069
$$

$$
P[H\mid X=10]=\frac{0.4(0.0992615)}{0.1026069}=\frac{0.0397046}{0.1026069}=0.38696
$$

**Answer: ${}P[H\mid X=10]\approx 0.387{}$**

---

## Question 3

> Corrected reading: ${}f_X(x)=\frac{1}{c}\left(x+\frac{3}{2}\right){}$ for ${}0\le x\le 3{}$.

The pdf of ${}X{}$ is

$$
f_X(x)=\begin{cases}
\dfrac{1}{c}\left(x+\dfrac{3}{2}\right), & 0\le x\le 3\\[10pt]
0, & \text{otherwise}
\end{cases}
$$

### (3.1) Find ${}c{}$

The pdf must integrate to 1:

$$
\int_{-\infty}^{\infty}f_X(x)\,dx=\int_0^3 \frac{1}{c}\left(x+\tfrac32\right)dx=1
$$

$$
\frac{1}{c}\int_0^3\left(x+\frac32\right)dx
=\frac{1}{c}\left[\frac{x^2}{2}+\frac{3x}{2}\right]_0^3
$$

$$
=\frac{1}{c}\left(\frac{9}{2}+\frac{9}{2}\right)
=\frac{9}{c}
$$

$$
\frac{9}{c}=1\qquad\Rightarrow\qquad c=9
$$

**Answer: ${}c=9{}$**

Substituting back:

$$
f_X(x)=\frac{x+\tfrac32}{9}=\frac{x}{9}+\frac{1}{6},\qquad 0\le x\le 3
$$

---

### (3.2) Plot the pdf for ${}-1\le x\le 4{}$

The pdf is 0 outside ${}[0,3]{}$, and linear inside:

$$
f_X(0)=\frac{1}{6}\approx 0.167,\qquad f_X(3)=\frac{3}{9}+\frac{1}{6}=\frac{1}{3}+\frac{1}{6}=\frac{1}{2}=0.5
$$

Sketch: 0 for ${}-1\le x<0{}$; straight line from ${}(0,1/6){}$ to ${}(3,1/2){}$; 0 for ${}3<x\le 4{}$.

**Important values:** ${}f_X(0)=1/6{}$, ${}f_X(3)=1/2{}$, and ${}f_X(x)=0{}$ for ${}x<0{}$ or ${}x>3{}$.

---

### (3.3) CDF of ${}X{}$

For ${}0\le x\le 3{}$:

$$
F_X(x)=\int_0^x\left(\frac{t}{9}+\frac{1}{6}\right)dt
=\left[\frac{t^2}{18}+\frac{t}{6}\right]_0^x
=\frac{x^2}{18}+\frac{x}{6}
$$

Therefore

$$
F_X(x)=\begin{cases}
0, & x<0\\[6pt]
\dfrac{x^2}{18}+\dfrac{x}{6}, & 0\le x\le 3\\[8pt]
1, & x>3
\end{cases}
$$

Check: ${}F_X(3)=\dfrac{9}{18}+\dfrac{3}{6}=0.5+0.5=1{}$.

---

### (3.4) ${}E[X]{}$

$$
E[X]=\int_0^3 x\,f_X(x)\,dx=\int_0^3 x\left(\frac{x}{9}+\frac{1}{6}\right)dx
=\int_0^3\left(\frac{x^2}{9}+\frac{x}{6}\right)dx
$$

$$
E[X]=\left[\frac{x^3}{27}+\frac{x^2}{12}\right]_0^3
=\frac{27}{27}+\frac{9}{12}
=1+\frac{3}{4}
=\frac{7}{4}=1.75
$$

**Answer: ${}E[X]=1.75{}$**

---

### (3.5) ${}P[A]{}$ where ${}A=\{2\le X\le 3\}{}$

$$
P[A]=F_X(3)-F_X(2)=1-\left(\frac{2^2}{18}+\frac{2}{6}\right)
=1-\left(\frac{4}{18}+\frac{1}{3}\right)
$$

$$
P[A]=1-\left(\frac29+\frac{3}{9}\right)=1-\frac59=\frac49
$$

**Answer: ${}P[A]=\dfrac{4}{9}\approx 0.444{}$**

---

### (3.6) Conditional pdf of ${}X{}$ given ${}A{}$

For ${}x\in A{}$:

$$
f_{X|A}(x\mid A)=\frac{f_X(x)}{P[A]},\qquad 2\le x\le 3
$$

and 0 otherwise.

$$
f_{X|A}(x)=\frac{\dfrac{x}{9}+\dfrac{1}{6}}{\dfrac{4}{9}}
=\frac{9}{4}\left(\frac{x}{9}+\frac{1}{6}\right)
=\frac{x}{4}+\frac{3}{8},\qquad 2\le x\le 3
$$

**Answer:**

$$
f_{X|A}(x\mid A)=\begin{cases}
\dfrac{x}{4}+\dfrac{3}{8}, & 2\le x\le 3\\[8pt]
0, & \text{otherwise}
\end{cases}
$$

Check: ${}\displaystyle\int_2^3\left(\frac{x}{4}+\frac{3}{8}\right)dx=\left[\frac{x^2}{8}+\frac{3x}{8}\right]_2^3=\frac{18}{8}-\frac{10}{8}=1{}$.

---

### (3.7) ${}E[X|A]{}$

$$
E[X|A]=\int_2^3 x\,f_{X|A}(x)\,dx
=\int_2^3 x\left(\frac{x}{4}+\frac{3}{8}\right)dx
=\int_2^3\left(\frac{x^2}{4}+\frac{3x}{8}\right)dx
$$

$$
E[X|A]=\left[\frac{x^3}{12}+\frac{3x^2}{16}\right]_2^3
=\left(\frac{27}{12}+\frac{27}{16}\right)-\left(\frac{8}{12}+\frac{12}{16}\right)
$$

$$
=\left(\frac{9}{4}+\frac{27}{16}\right)-\left(\frac{2}{3}+\frac{3}{4}\right)
=\left(\frac{36}{16}+\frac{27}{16}\right)-\left(\frac{8}{12}+\frac{9}{12}\right)
=\frac{63}{16}-\frac{17}{12}
$$

$$
=\frac{189}{48}-\frac{68}{48}
=\frac{121}{48}=2.52083\dots
$$

**Answer: ${}E[X|A]=\dfrac{121}{48}=2.52083\dots\approx 2.52{}$**

---

## Question 4

${}T\sim\text{Exp}(\lambda=0.5){}$:

$$
f_T(t)=0.5\,e^{-0.5t},\quad t\ge 0;\qquad
F_T(t)=1-e^{-0.5t},\quad t\ge 0
$$

### (4.1) Plot the pdf for ${}0\le t\le 8{}$

Exponential decay:

$$
f_T(0)=0.5,\qquad f_T(8)=0.5e^{-4}\approx 0.00916
$$

Sketch: starts at ${}(0,0.5){}$ and decays exponentially toward 0; at ${}t=8{}$ the value is about 0.00916.

---

### (4.2) ${}E[T]{}$ and ${}VAR[T]{}$

For ${}\text{Exp}(\lambda){}$:

$$
E[T]=\frac{1}{\lambda}=\frac{1}{0.5}=2,\qquad
VAR[T]=\frac{1}{\lambda^2}=\frac{1}{0.25}=4
$$

**Answer: ${}E[T]=2{}$ weeks, ${}VAR[T]=4{}$ weeks${}^2{}$**

---

### (4.3) Conditional pdf given ${}A=\{T\le 3\}{}$

$$
P[A]=P[T\le 3]=F_T(3)=1-e^{-0.5(3)}=1-e^{-1.5}
$$

For ${}0\le t\le 3{}$:

$$
f_{T|A}(t\mid A)=\frac{f_T(t)}{P[A]}
=\frac{0.5\,e^{-0.5t}}{1-e^{-1.5}},\qquad 0\le t\le 3
$$

and 0 otherwise.

**Answer:**

$$
f_{T|A}(t)=\begin{cases}
\dfrac{0.5\,e^{-0.5t}}{1-e^{-1.5}}, & 0\le t\le 3\\[10pt]
0, & \text{otherwise}
\end{cases}
$$

---

### (4.4) Plot the conditional pdf for ${}0\le t\le 8{}$

Same exponential shape as ${}f_T(t){}$ but renormalized so the area over ${}[0,3]{}$ equals 1, and 0 for ${}t>3{}$.

Key values:

$$
f_{T|A}(0)=\frac{0.5}{1-e^{-1.5}}\approx\frac{0.5}{0.77687}=0.6436
$$

$$
f_{T|A}(3)=\frac{0.5\,e^{-1.5}}{1-e^{-1.5}}\approx\frac{0.5(0.22313)}{0.77687}=0.1436
$$

$$
f_{T|A}(t)=0\quad\text{for }t>3
$$

---

### (4.5) Conditional expectation ${}E[T|A]{}$

$$
E[T|A]=\int_0^3 t\,f_{T|A}(t)\,dt
=\frac{\displaystyle\int_0^3 t\,(0.5)e^{-0.5t}\,dt}{1-e^{-1.5}}
$$

Compute the numerator using integration by parts, or the standard formula

$$
\int_0^a \lambda t e^{-\lambda t}\,dt=\frac{1}{\lambda}\left[1-e^{-\lambda a}(\lambda a+1)\right]
$$

With ${}\lambda=0.5{}$, ${}a=3{}$:

$$
\int_0^3 0.5\,t\,e^{-0.5t}\,dt=2\left[1-e^{-1.5}(0.5\cdot 3+1)\right]=2\left[1-2.5e^{-1.5}\right]
$$

$$
E[T|A]=\frac{2\left(1-2.5e^{-1.5}\right)}{1-e^{-1.5}}
=\frac{2-5e^{-1.5}}{1-e^{-1.5}}
$$

Numerically, ${}e^{-1.5}=0.22313{}$:

$$
E[T|A]=\frac{2-5(0.22313)}{1-0.22313}
=\frac{2-1.11565}{0.77687}
=\frac{0.88435}{0.77687}=1.13835
$$

**Answer: ${}E[T|A]\approx 1.14{}$ weeks**

---

### (4.6) ${}P[T>5]{}$

$$
P[T>5]=1-F_T(5)=e^{-0.5(5)}=e^{-2.5}=0.082085
$$

**Answer: ${}P[T>5]=e^{-2.5}\approx 0.0821{}$**

---

### (4.7) ${}P[T\ge 7\mid T\ge 5]{}$

"At least another 2 weeks from now, given it has already been 5 weeks" means:

$$
P[T\ge 7\mid T\ge 5]=\frac{P[T\ge 7]}{P[T\ge 5]}=\frac{e^{-0.5(7)}}{e^{-0.5(5)}}=\frac{e^{-3.5}}{e^{-2.5}}=e^{-1}
$$

This is exactly the **memoryless property** of the exponential distribution:

$$
P[T\ge 5+2\mid T\ge 5]=P[T\ge 2]=e^{-0.5(2)}=e^{-1}
$$

**Answer: ${}P[T\ge 7\mid T\ge 5]=e^{-1}\approx 0.368{}$**

---

## Question 5

${}X\sim\text{Uniform}[15,25]{}$ and ${}Y=1.8X+32{}$.

### (5.1) pdf of ${}X{}$

$$
f_X(x)=\begin{cases}
\dfrac{1}{25-15}=\dfrac{1}{10}, & 15\le x\le 25\\[8pt]
0, & \text{otherwise}
\end{cases}
$$

---

### (5.2) ${}E[X]{}$ and ${}VAR[X]{}$

For ${}\text{Uniform}[a,b]{}$:

$$
E[X]=\frac{a+b}{2}=\frac{15+25}{2}=20
$$

$$
VAR[X]=\frac{(b-a)^2}{12}=\frac{(25-15)^2}{12}=\frac{100}{12}=\frac{25}{3}\approx 8.333
$$

**Answer: ${}E[X]=20{}$, ${}VAR[X]=\dfrac{25}{3}\approx 8.33{}$**

---

### (5.3) CDF of ${}Y{}$ in terms of the cdf of ${}X{}$

Since ${}1.8>0{}$, the transformation is increasing:

$$
F_Y(y)=P[Y\le y]=P[1.8X+32\le y]=P\!\left[X\le \frac{y-32}{1.8}\right]
$$

$$
F_Y(y)=F_X\!\left(\frac{y-32}{1.8}\right)
$$

---

### (5.4) pdf of ${}Y{}$

Differentiate the cdf:

$$
f_Y(y)=\frac{d}{dy}F_Y(y)
=\frac{d}{dy}F_X\!\left(\frac{y-32}{1.8}\right)
=\frac{1}{1.8}\,f_X\!\left(\frac{y-32}{1.8}\right)
$$

Since ${}X{}$ is uniform on ${}[15,25]{}$, ${}Y{}$ is uniform on

$$
[1.8(15)+32,\;1.8(25)+32]=[27+32,\;45+32]=[59,77]
$$

$$
f_Y(y)=\frac{1}{1.8}\cdot\frac{1}{10}=\frac{1}{18},\qquad 59\le y\le 77
$$

**Answer:**

$$
f_Y(y)=\begin{cases}
\dfrac{1}{18}, & 59\le y\le 77\\[8pt]
0, & \text{otherwise}
\end{cases}
$$

---

### (5.5) ${}E[Y]{}$ and ${}VAR[Y]{}$

Using linearity of expectation and the variance scaling rule:

$$
E[Y]=E[1.8X+32]=1.8E[X]+32=1.8(20)+32=36+32=68
$$

$$
VAR[Y]=VAR[1.8X+32]=1.8^2\,VAR[X]=3.24\cdot\frac{25}{3}=27
$$

**Answer: ${}E[Y]=68{}$, ${}VAR[Y]=27{}$**

> Check: for ${}Y\sim\text{Uniform}[59,77]{}$,
> ${}E[Y]=\dfrac{59+77}{2}=68{}$ and ${}VAR[Y]=\dfrac{(77-59)^2}{12}=\dfrac{324}{12}=27{}$.

---

### (5.6) ${}P[65\le Y\le 75]{}$

Since ${}Y{}$ is uniform on ${}[59,77]{}$:

$$
P[65\le Y\le 75]=\frac{75-65}{77-59}=\frac{10}{18}=\frac59=0.5556
$$

**Answer: ${}P[65\le Y\le 75]=\dfrac{5}{9}\approx 0.556{}$**
