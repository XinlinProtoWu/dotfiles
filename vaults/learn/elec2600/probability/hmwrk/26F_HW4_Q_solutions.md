# ELEC2600 Homework #4 — Solutions

## Question 1

Let lifetimes $X_1,\dots,X_n$ be i.i.d. with mean $\mu$ and $\sigma=5$. The sample mean is
$M_n=\frac1n\sum_{i=1}^n X_i$.

**1.1** By CLT, $M_n\sim\mathcal N(\mu,\sigma^2/n)$ approximately. We need

$$P\bigl(|M_n-\mu|\le 1\bigr)\ge 0.95.$$

Standardising,

$$P\left(\left|\frac{M_n-\mu}{\sigma/\sqrt n}\right|\le \frac{1}{5/\sqrt n}\right)
=2\Phi\!\left(\frac{\sqrt n}{5}\right)-1\ge 0.95,$$

so $\Phi(\sqrt n/5)\ge0.975$ and $\sqrt n/5\ge1.96$. Therefore

$$n\ge(1.96\cdot 5)^2=96.04\implies n=97.$$

**Answer: $n=97$ devices**

**1.2** With $n=80$:

$$P\bigl(|M_{80}-8|\le 1\bigr)
=P\left(|Z|\le \frac{1}{5/\sqrt{80}}\right)
=P\left(|Z|\le 1.7889\right)
=2\Phi(1.7889)-1\approx 0.9264.$$

**Answer: $\approx 0.9264$**

---

## Question 2

Poisson process with $\lambda=4$ buses/hour $=\frac1{15}$ buses/min. For an interval of $t$ minutes,
$N(t)\sim\mathrm{Poisson}(\lambda t)$.

**2.1** $t=25$ min, mean $\lambda t=4\cdot\frac{25}{60}=\frac53$:

$$P[N(25)=2]=e^{-5/3}\frac{(5/3)^2}{2!}
=\frac{25}{18}e^{-5/3}\approx 0.2623.$$

**2.2** Let the second factor be the count in the next $30$-min interval. Non-overlapping intervals have independent increments:

$$P[N(25)=2,\ N_{\text{next}}(30)=3]
=P[N(25)=2]\,P[N_{\text{next}}(30)=3].$$

Here $N_{\text{next}}(30)\sim\mathrm{Poisson}(2)$, so

$$P[N_{\text{next}}(30)=3]=e^{-2}\frac{2^3}{3!}=\frac43 e^{-2}.$$

Hence

$$P=\frac{25}{18}e^{-5/3}\cdot \frac43 e^{-2}
=\frac{50}{27}e^{-11/3}\approx 0.0473.$$

**2.3** First bus before $15$ min means at least one arrival in $[0,15]$, with mean $1$:

$$P[T_1<15]=P[N(15)\ge1]=1-e^{-1}\approx 0.6321.$$

**2.4**

$$P[10\le T_1\le20]
=P[N(10)=0]\,P[N(20)-N(10)\ge1]
=e^{-4(10/60)}\left(1-e^{-4(10/60)}\right)
=e^{-2/3}-e^{-4/3}\approx 0.2498.$$

**2.5** Second bus before $25$ min means at least two arrivals by $t=25$:

$$P[T_2<25]=P[N(25)\ge2]
=1-e^{-5/3}-\frac53 e^{-5/3}
=1-\frac83 e^{-5/3}\approx 0.4963.$$

---

## Question 3

Let $A_n$ be the number of aces in $n$ draws. Then $A_n\sim\mathrm{Binomial}(n,p)$ with
$p=4/52=1/13$. In the original walk, $D_n=10A_n$.

**3.1**

$$E[D_8]=10E[A_8]=10\cdot 8\cdot\frac1{13}=\frac{80}{13}\approx6.154,$$

$$\operatorname{Var}[D_8]=100\operatorname{Var}[A_8]
=100\cdot 8\cdot\frac1{13}\cdot\frac{12}{13}
=\frac{9600}{169}\approx56.80.$$

Since $D_{12}=D_8+(D_{12}-D_8)$ and the increment $D_{12}-D_8$ is independent of $D_8$,

$$C_D(8,12)=\operatorname{Cov}(D_8,D_{12})=\operatorname{Var}[D_8]
=\frac{9600}{169}\approx56.80.$$

**Answer: $E[D_8]=80/13$, $\operatorname{Var}[D_8]=C_D(8,12)=9600/169$**

**3.2**

$$P[D_6=30]=P[A_6=3]
=\binom63\left(\frac1{13}\right)^3\left(\frac{12}{13}\right)^3
=\frac{20\cdot12^3}{13^6}\approx0.00716.$$

**3.3** Given $D_6=30$ (i.e. $A_6=3$), we need 3 aces in the next 6 draws:

$$P[D_{12}=60\mid D_6=30]
=P[A_{12}-A_6=3]
=\binom63\left(\frac1{13}\right)^3\left(\frac{12}{13}\right)^3
\approx0.00716.$$

**3.4**

$$P[D_{12}=60\cap D_6=30]
=P[A_6=3]\,P[A_{12}-A_6=3]
=\left(\frac{20\cdot12^3}{13^6}\right)^2
=\frac{400\cdot12^6}{13^{12}}\approx5.13\times10^{-5}.$$

**3.5** New rule: $+10$ for ace, $-5$ otherwise, $D_0=25$. After 5 steps with $A$ aces,

$$D_5=25+10A-5(5-A)=15A,$$

where $A\sim\mathrm{Binomial}(5,1/13)$. Thus

$$P[D_5>0]=P[A\ge1]=1-\left(\frac{12}{13}\right)^5\approx0.3298.$$

**3.6** New rule: $+10$ for ace, $-10$ otherwise, $D_0=25$. After 8 steps,

$$D_8=25+10A-10(8-A)=20A-55,$$

where $A\sim\mathrm{Binomial}(8,1/13)$. Then $D_8>0\iff A\ge3$, so

$$P[D_8>0]=P[A\ge3]
=1-\sum_{k=0}^{2}\binom8k\left(\frac1{13}\right)^k\left(\frac{12}{13}\right)^{8-k}
=1-\frac{12^8+8\cdot12^7+28\cdot12^6}{13^8}
\approx0.01899.$$

---

## Question 4

$Y_i=X_i-\frac12 X_{i-1}$ for $i\ge2$.

### 4.1  i.i.d. case

Mean:

$$m_Y(i)=E[X_i]-\frac12E[X_{i-1}]=400-200=200.$$

For $i,j\ge2$, using $E[X_kX_\ell]=\mu^2+\sigma^2\delta_{k,\ell}$ with $\mu=400$, $\sigma^2=8000$:

$$\operatorname{Cov}(Y_i,Y_j)
=\sigma^2\left[\delta_{i,j}-\frac12\delta_{i,j-1}-\frac12\delta_{i-1,j}+\frac14\delta_{i-1,j-1}\right].$$

Therefore

$$C_Y(i,j)=\begin{cases}
\frac54\sigma^2=10000, & i=j,\\[4pt]
-\frac12\sigma^2=-4000, & |i-j|=1,\\[4pt]
0, & |i-j|\ge2.
\end{cases}$$

Autocorrelation $R_Y(i,j)=C_Y(i,j)+m_Y^2=C_Y(i,j)+40000$:

$$R_Y(i,j)=\begin{cases}
50000, & i=j,\\
36000, & |i-j|=1,\\
40000, & |i-j|\ge2.
\end{cases}$$

### 4.2  Gaussian WSS case

Since $C_X(j,k)=8000e^{-2|j-k|}$ and $E[X_i]=400$,

$$m_Y(i)=400-\frac12(400)=200.$$

For lag $k=i-j$,

$$\begin{aligned}
C_Y(i,j)
&=\operatorname{Cov}\!\left(X_i-\tfrac12X_{i-1},\ X_j-\tfrac12X_{j-1}\right)\\
&=8000\Bigl[e^{-2|k|}-\tfrac12 e^{-2|k+1|}-\tfrac12 e^{-2|k-1|}+\tfrac14 e^{-2|k|}\Bigr]\\
&=8000\Bigl[\tfrac54 e^{-2|k|}-\tfrac12 e^{-2|k+1|}-\tfrac12 e^{-2|k-1|}\Bigr].
\end{aligned}$$

This depends only on $k=i-j$, so $Y_i$ is WSS (and Gaussian). The autocorrelation is

$$R_Y(i,j)=C_Y(i,j)+m_Y^2=C_Y(i,j)+40000.$$

### 4.3  Joint density of $Y_2,Y_3$

Let $\mathbf Y=[Y_2\ Y_3]^T$. Both entries have mean $200$. From 4.2:

$$c_0=C_Y(2,2)=C_Y(3,3)=8000\left(\frac54-e^{-2}\right)=10000-8000e^{-2},$$

$$c_1=C_Y(2,3)=C_Y(3,2)
=8000\left(\frac54e^{-2}-\frac12-\frac12e^{-4}\right)
=10000e^{-2}-4000-4000e^{-4}.$$

Thus

$$\mathbf m=\begin{bmatrix}200\\200\end{bmatrix},
\qquad
C=\begin{bmatrix}c_0&c_1\\c_1&c_0\end{bmatrix}.$$

Since $Y_2,Y_3$ are jointly Gaussian, the joint pdf is

$$f_{Y_2,Y_3}(y_2,y_3)
=\frac{1}{2\pi\sqrt{c_0^2-c_1^2}}
\exp\!\left(-\frac{c_0[(y_2-200)^2+(y_3-200)^2]-2c_1(y_2-200)(y_3-200)}{2(c_0^2-c_1^2)}\right).$$
