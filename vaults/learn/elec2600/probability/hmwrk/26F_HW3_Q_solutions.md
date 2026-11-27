# ELEC2600 Homework #3 — Solutions

## Question 1

Joint pmf (rows $y$, columns $x$):

| $p_{X,Y}(x,y)$ | $x=1$ | $x=2$ | $x=3$ |
|---|---|---|---|
| $y=1$ | 0.1 | $a$ | 0.1 |
| $y=2$ | 0.2 | 0.2 | $b$ |
| $y=3$ | 0.1 | 0.05 | 0.05 |

Given $P[Y=2]=0.5$.

**1.1** $P[Y=2]=0.2+0.2+b=0.5 \Rightarrow b=0.1$. Normalization: $0.8+a+b=1 \Rightarrow a=0.1$.

**Answer: $a=0.1$, $b=0.1$**

**1.2** Marginals:
$$p_X=(0.4,\ 0.35,\ 0.25),\qquad p_Y=(0.3,\ 0.5,\ 0.2)$$

**1.3** $F_{X,Y}(2,3)=P[X\le2]=p_X(1)+p_X(2)=0.75$

**1.4** $E[X]=1.85$, $E[Y]=1.9$, $E[XY]=3.45$:
$$\operatorname{Cov}(X,Y)=3.45-(1.85)(1.9)=-0.065$$
$\operatorname{Cov}\ne0$, so $X$ and $Y$ are correlated.

**1.5** $P[X<2]=p_X(1)=0.4$, so $p_{Y\mid X<2}(y)=\dfrac{p_{X,Y}(1,y)}{0.4}$:
$$p_{Y\mid X<2}=(0.25,\ 0.5,\ 0.25)$$

**1.6** $E[Y\mid X<2]=1(0.25)+2(0.5)+3(0.25)=2$

---

## Question 2

$$f_{X,Y}(x,y)=c e^{-x}e^{-y},\quad 0\le x\le y<\infty$$

**2.1** Support: $R=\{(x,y):0\le x\le y\}$ (wedge above $y=x$).

**2.2** $1=c\int_0^\infty\int_0^y e^{-x}e^{-y}\,dx\,dy=c\int_0^\infty e^{-y}(1-e^{-y})\,dy=\dfrac c2 \Rightarrow c=2$

**2.3** $f_X(x)=\int_x^\infty 2e^{-x}e^{-y}\,dy=2e^{-2x}$, $x\ge0$. So $X\sim\text{Exp}(2)$.

**2.4** $f_Y(y)=\int_0^y 2e^{-x}e^{-y}\,dx=2e^{-y}(1-e^{-y})$, $y\ge0$.

**2.5** $f_{X\mid Y}(x\mid y)=\dfrac{2e^{-x}e^{-y}}{2e^{-y}(1-e^{-y})}=\dfrac{e^{-x}}{1-e^{-y}},\ 0\le x\le y$.

**2.6** $E[X\mid Y=y]=\dfrac{1}{1-e^{-y}}\int_0^y xe^{-x}\,dx=\dfrac{1-(y+1)e^{-y}}{1-e^{-y}}$

---

## Question 3

$X\sim\text{Exp}(\lambda)$, $\lambda=1/5$; $Y\sim\text{Exp}(\mu)$, $\mu=1/10$; independent.

**3.1** $f_{X,Y}(x,y)=\dfrac{1}{50}e^{-x/5}e^{-y/10}$, $x,y\ge0$.

**3.2** $F_{X,Y}(x,y)=\left(1-e^{-x/5}\right)\left(1-e^{-y/10}\right)$, $x,y\ge0$.

**3.3** $P[Y>X]=\int_0^\infty \lambda e^{-\lambda x}e^{-\mu x}\,dx=\dfrac{\lambda}{\lambda+\mu}=\dfrac{1/5}{3/10}=\dfrac23\approx0.667$

**3.4** $P[X>7,Y>7]=e^{-7/5}e^{-7/10}=e^{-21/10}\approx0.122$

**3.5** $P[X+Y<8]=\left(1-e^{-4/5}\right)^2\approx0.303$

---

## Question 4

$X\sim\text{Uniform}[4,8]$, $Y\sim\text{Uniform}[2,6]$, independent, $Z=X+Y$.

**4.1** Convolution gives a triangular pdf:

$$f_Z(z)=\begin{cases}\dfrac{z-6}{16},&6\le z\le10,\\[6pt]\dfrac{14-z}{16},&10\le z\le14,\\[6pt]0,&\text{otherwise}.\end{cases}$$

**4.2** Triangle: rises from $0$ at $z=6$ to $\frac14$ at $z=10$, falls to $0$ at $z=14$.

**4.3** $E[X]=6$, $E[Y]=4$, $\operatorname{Var}(X)=\operatorname{Var}(Y)=\frac43$:
$$E[Z]=10,\qquad \operatorname{Var}(Z)=\frac43+\frac43=\frac83\approx2.67$$

**4.4** $P[10\le Z\le13]=\int_{10}^{13}\dfrac{14-z}{16}\,dz=\dfrac{15}{32}=0.46875$

---

## Question 5

$E[X]=70$, $E[Y]=75$, $\operatorname{Var}(X)=1.5$, $\operatorname{Var}(Y)=2.5$, $Z=2X-Y$.

Since $X,Y$ are jointly Gaussian, $Z$ is Gaussian; we only need its mean and variance.

**5.1** Uncorrelated ($\operatorname{Cov}=0$):
$$E[Z]=2(70)-75=65,\qquad \operatorname{Var}(Z)=4(1.5)+2.5=8.5$$
$$Z\sim\mathcal N(65,8.5),\qquad f_Z(z)=\frac{1}{\sqrt{17\pi}}e^{-(z-65)^2/17}$$

**5.2** $\rho=0.6$:
$$\operatorname{Cov}(X,Y)=0.6\sqrt{(1.5)(2.5)}=\frac{3\sqrt{15}}{10}$$
$$E[Z]=65,\qquad \operatorname{Var}(Z)=8.5-4\left(\frac{3\sqrt{15}}{10}\right)=\frac{85-12\sqrt{15}}{10}\approx3.852$$
$$Z\sim\mathcal N\!\left(65,\ \frac{85-12\sqrt{15}}{10}\right)$$
