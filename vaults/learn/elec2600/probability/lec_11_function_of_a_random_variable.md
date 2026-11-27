# Lecture 11: Function of a Random Variable

## Overview

Given a RV ${}X{}$ with known distribution and a real-valued function ${}g(x){}$, we want the distribution of

$$
Y=g(X)
$$

---

## Determine the Type of Y First

The solution method depends on the type of the output RV:

| ${}X{}$ is ... | ${}Y=g(X){}$ is ... |
|---|---|
| discrete | always discrete |
| continuous | discrete, continuous, or mixed (depends on ${}g{}$) |

All methods are based on finding an **equivalent event in ${}X{}$** for a suitably defined event in ${}Y{}$.

---

## Three Approaches

### 1. Discrete ${}Y{}$ — find the pmf

$$
p_Y(k)=P[Y=k]=P[\{X:g(X)=k\}]
$$

### 2. Continuous ${}Y{}$ — find the cdf first

$$
F_Y(y)=P[Y\le y]=P[\{X:g(X)\le y\}]
$$

then differentiate: ${}f_Y(y)=\dfrac{d}{dy}F_Y(y){}$.

### 3. Continuous ${}Y{}$ — direct pdf formula

$$
f_Y(y_0)=\sum_{x:\,g(x)=y_0}\frac{f_X(x)}{|g'(x)|}
$$

(For monotonic ${}g{}$ this reduces to the single-inverse case.)

---

## Discrete X → Discrete Y

>[!Example]
>**Voice system with ${}M{}$ channels.** ${}X{}$ active speakers out of ${}N=48{}$, each active with ${}p=1/3{}$, so ${}X\sim\text{Binomial}(48,1/3){}$. The system can transmit up to ${}M=12{}$ signals; excess signals are dropped:
>$$
>Y=(X-M)^+=\begin{cases}x-M,&x>M\\0,&x\le M\end{cases}
>$$
>Then:
>$$
>P[Y=0]=P[0\le X\le M]=\sum_{i=0}^{M}p_X(i)
>$$
>$$
>p_Y(k)=p_X(M+k),\qquad k=1,2,\dots,N-M
>$$
>and 0 otherwise.

---

## Continuous X → Discrete Y

>[!Example]
>**Quantization of an exponential RV.** ${}X\sim\text{Exp}(\lambda=1){}$, and ${}Y=q(X){}$ discards the digits past the decimal point (floor):
>$$
>q(x)=k\quad\text{for }k\le x<k+1
>$$
>For ${}k=0,1,2,\dots{}$:
>$$
>p_Y(k)=P[k\le X<k+1]=\int_k^{k+1}\lambda e^{-\lambda x}\,dx=e^{-\lambda k}-e^{-\lambda(k+1)}
>$$
>$$
>p_Y(k)=(1-e^{-\lambda})\,e^{-\lambda k}=(1-e^{-1})\,e^{-k}
>$$
>so ${}Y{}$ is a **geometric** RV with success probability ${}p=1-e^{-\lambda}{}$.

---

## Continuous X → Continuous Y

### Linear transformation ${}Y=aX+b{}$

Using the cdf method:

$$
F_Y(y)=P[aX+b\le y]=P\!\left[X\le\frac{y-b}{a}\right]=F_X\!\left(\frac{y-b}{a}\right)
$$

Differentiating:

$$
f_Y(y)=\frac{1}{|a|}\,f_X\!\left(\frac{y-b}{a}\right)
$$

>[!Example]
>**Uniform input.** If ${}X\sim\text{Uniform}[0,1]{}$ and ${}Y=aX+b{}$ with ${}a>0{}$, then
>$$
>f_Y(y)=\frac{1}{a}\cdot 1=\frac1a,\qquad b\le y\le a+b
>$$
>so ${}Y{}$ is uniform on ${}[b,a+b]{}$. The scaling ${}a{}$ stretches the density by ${}1/a{}$; negative ${}a{}$ reflects it.

>[!Example]
>**Gaussian input.** If ${}X{}$ is Gaussian with mean ${}m{}$ and variance ${}\sigma^2{}$,
>$$
>f_X(x)=\frac{1}{\sqrt{2\pi}\sigma}e^{-\frac{(x-m)^2}{2\sigma^2}}
>$$
>and ${}Y=aX+b{}$:
>$$
>f_Y(y)=\frac{1}{|a|}\frac{1}{\sqrt{2\pi}\sigma}\exp\!\left[-\frac{((y-b)/a-m)^2}{2\sigma^2}\right]
>$$
>$$
>f_Y(y)=\frac{1}{\sqrt{2\pi}\,|a|\sigma}\exp\!\left[-\frac{(y-(am+b))^2}{2(a\sigma)^2}\right]
>$$
>So ${}Y{}$ is Gaussian with mean ${}am+b{}$ and variance ${}(a\sigma)^2{}$.
>
>**Important fact:** any linear function of a Gaussian RV is also Gaussian.

### Nonlinear transformation ${}Y=X^2{}$

>[!Example]
>For ${}Y=X^2{}$ with ${}X{}$ having density ${}f_X(x){}$:
>$$
>F_Y(y)=P[X^2\le y]=P[-\sqrt y\le X\le \sqrt y]=F_X(\sqrt y)-F_X(-\sqrt y),\qquad y>0
>$$
>and 0 for ${}y\le 0{}$. Differentiating:
>$$
>f_Y(y)=\frac{f_X(\sqrt y)+f_X(-\sqrt y)}{2\sqrt y},\qquad y>0
>$$
>and 0 otherwise.

>[!Example]
>**Chi-square random variable.** If ${}X\sim\mathcal N(0,1){}$, then
>$$
>f_X(x)=\frac{1}{\sqrt{2\pi}}e^{-x^2/2}
>$$
>For ${}Y=X^2{}$:
>$$
>f_Y(y)=\frac{1}{2\sqrt y}\left(\frac{1}{\sqrt{2\pi}}e^{-y/2}+\frac{1}{\sqrt{2\pi}}e^{-y/2}\right)
>=\frac{1}{\sqrt{2\pi y}}e^{-y/2},\qquad y>0
>$$
>This is the **chi-square distribution with one degree of freedom**.

---

## Summary

- First determine whether ${}Y{}$ is discrete or continuous.
- **Discrete ${}Y{}$:** ${}p_Y(k)=P[g(X)=k]{}$.
- **Continuous ${}Y{}$ (cdf method):** ${}F_Y(y)=P[g(X)\le y]{}$, then differentiate.
- **Continuous ${}Y{}$ (pdf method):** ${}f_Y(y_0)=\sum_{x:g(x)=y_0}f_X(x)/|g'(x)|{}$.
- **Linear:** ${}f_Y(y)=\dfrac{1}{|a|}f_X\!\left(\dfrac{y-b}{a}\right){}$; Gaussian stays Gaussian.
- **Square:** ${}f_Y(y)=\dfrac{f_X(\sqrt y)+f_X(-\sqrt y)}{2\sqrt y}{}$ for ${}y>0{}$.
