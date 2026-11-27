# Lecture 10: Conditional PMF/CDF/PDF

## Overview

- Conditional Probability Mass Function (discrete RVs)
- Conditional Expected Value and Variance
- Conditional CDF & PDF (continuous RVs)
- Total Probability Theorem for distributions and expectations

---

## Conditional Probability Mass Function

Partial information about an experiment changes the distribution of a random variable. If we know an event ${}C{}$ occurred (with ${}P[C]>0{}$), the **conditional pmf** of a discrete RV ${}X{}$ given ${}C{}$ is

$$
p_X(x\mid C)=P[X=x\mid C]
$$

By the definition of conditional probability:

$$
p_X(x\mid C)=\frac{P[\{X=x\}\cap C]}{P[C]}
$$

### Interpretation

Recall that the unconditional pmf is ${}p_X(x_k)=P[X=x_k]=P[\zeta\in A_k]{}$ where ${}A_k=\{\zeta:X(\zeta)=x_k\}{}$. Conditioning restricts the sample space to ${}C{}$:

$$
p_X(x\mid C)=\frac{P[\{X=x\}\cap C]}{P[C]}
$$

---

## Properties of the Conditional PMF

The conditional pmf has the same properties as an ordinary pmf:

1. **Non-negative:** ${}p_X(x\mid C)\ge 0{}$
2. **Sums to 1:**
$$
\sum_{x\in S_X}p_X(x\mid C)=1
$$
3. **Probability of events:**
$$
P[X\in B\mid C]=\sum_{x\in B}p_X(x\mid C)\qquad (B\subseteq S_X)
$$

---

## Conditioning Event Defined by X

Often the conditioning event is defined in terms of ${}X{}$ itself, e.g. ${}C=\{X>10\}{}$ or ${}C=\{a\le X\le b\}{}$. Then the conditional pmf can be found directly from the pmf:

$$
p_X(x_k\mid C)=
\begin{cases}
\dfrac{p_X(x_k)}{P[C]}, & x_k\in C\\[8pt]
0, & x_k\notin C
\end{cases}
\qquad\text{where } P[C]=\sum_{x\in C}p_X(x)
$$

>[!Example]
>**Residual waiting time.** ${}X{}$ is uniform on ${}S_X=\{1,2,\dots,20\}{}$, so ${}p_X(k)=1/20{}$. Let ${}C={}$"message not finished by time 12" ${}=\{13,14,\dots,20\}{}$. There are 8 outcomes, so ${}P[C]=8/20{}$.
>$$
>p_X(j\mid C)=\frac{p_X(j)}{8/20}=\frac{1/20}{8/20}=\frac18,\qquad j\in\{13,\dots,20\}
>$$
>and 0 otherwise. The conditional distribution is uniform on ${}\{13,\dots,20\}{}$.

---

## Total Probability Theorem (for pmfs)

If ${}B_1,B_2,\dots,B_n{}$ form a partition of the sample space, then

$$
p_X(x)=\sum_i p_X(x\mid B_i)\,P[B_i]
$$

>[!Example]
>**Device lifetimes.** A production line makes two device types:
>- Type 1 (prob ${}\alpha{}$): lifetime geometric with parameter ${}r{}$,
>- Type 2 (prob ${}1-\alpha{}$): lifetime geometric with parameter ${}s{}$.
>
>Conditional pmfs: ${}p_X(k\mid B_1)=(1-r)^{k-1}r{}$, ${}p_X(k\mid B_2)=(1-s)^{k-1}s{}$ for ${}k=1,2,3,\dots{}$.
>
>By total probability:
>$$
>p_X(k)=\alpha(1-r)^{k-1}r+(1-\alpha)(1-s)^{k-1}s
>$$

---

## Conditional Expected Value and Variance

Since the conditional pmf is a valid pmf, we can define expectation and variance on it.

### Conditional expectation

$$
m_{X|B}=E[X\mid B]=\sum_{x\in S_X}x\,p_X(x\mid B)
$$

Interpretation: the average of ${}X{}$ over many trials in which ${}B{}$ occurs.

### Conditional variance

$$
VAR[X\mid B]=E[(X-m_{X|B})^2\mid B]=\sum_k(x_k-m_{X|B})^2 p_X(x_k\mid B)
$$

$$
VAR[X\mid B]=E[X^2\mid B]-m_{X|B}^2
$$

---

## Using Conditioning to Compute Expectations

If ${}B_1,\dots,B_n{}$ partition the sample space:

$$
E[X]=\sum_i E[X\mid B_i]\,P[B_i]
$$

Proof: substitute the total-probability expression for ${}p_X(x_k){}$ into ${}E[X]=\sum_k x_k p_X(x_k){}$.

Similarly,

$$
E[X^2]=\sum_i E[X^2\mid B_i]\,P[B_i]
$$

>[!warning]
>In general,
>$$
>VAR[X]\;\neq\;\sum_i VAR[X\mid B_i]\,P[B_i]
>$$
>The correct way is ${}VAR[X]=E[X^2]-(E[X])^2{}$ using the conditional second moments above.

>[!Example]
>**Expected value of device lifetimes.** For a geometric RV with parameter ${}p{}$, ${}E=1/p{}$. Hence
>$$
>E[X]=E[X\mid B_1]\alpha+E[X\mid B_2](1-\alpha)=\frac{\alpha}{r}+\frac{1-\alpha}{s}
>$$

>[!Example]
>**Variance of device lifetimes.** Using ${}VAR[\text{Geom}(p)]=(1-p)/p^2{}$,
>$$
>E[X^2\mid B_1]=VAR[X\mid B_1]+m_{X|B_1}^2=\frac{1-r}{r^2}+\frac1{r^2}=\frac{2-r}{r^2}
>$$
>and similarly ${}E[X^2\mid B_2]=\dfrac{2-s}{s^2}{}$. Then
>$$
>E[X^2]=\alpha\frac{2-r}{r^2}+(1-\alpha)\frac{2-s}{s^2}
>$$
>$$
>VAR[X]=E[X^2]-\left(\frac{\alpha}{r}+\frac{1-\alpha}{s}\right)^2
>$$

---

## Conditional CDF and PDF

### Conditional CDF

$$
F_X(x\mid C)=\frac{P[\{X\le x\}\cap C]}{P[C]},\qquad P[C]>0
$$

### Conditional PDF

$$
f_X(x\mid C)=\frac{d}{dx}F_X(x\mid C)
$$

A conditional cdf/pdf has all the same properties as a regular cdf/pdf.

>[!Example]
>**Conditional CDF given ${}X>t{}$.** Let the lifetime ${}X{}$ have cdf ${}F_X(x){}$ and ${}C=\{X>t\}{}$.
>$$
>F_X(x\mid X>t)=P[X\le x\mid X>t]=\frac{P[\{X\le x\}\cap\{X>t\}]}{P[X>t]}
>$$
>$$
>F_X(x\mid X>t)=
>\begin{cases}
>0, & x\le t\\[6pt]
>\dfrac{F_X(x)-F_X(t)}{1-F_X(t)}, & x>t
>\end{cases}
>$$

>[!Example]
>**Exponential conditional PDF given ${}X>t{}$.** For ${}X\sim\text{Exp}(\lambda){}$,
>$$
>f_X(x\mid X>t)=
>\begin{cases}
>0, & x\le t\\[6pt]
>\dfrac{f_X(x)}{1-F_X(t)}=\dfrac{\lambda e^{-\lambda x}}{e^{-\lambda t}}=\lambda e^{-\lambda(x-t)}, & x>t
>\end{cases}
>$$
>This is the **memoryless property**: conditioned on ${}X>t{}$, the remaining lifetime is still exponential with the same parameter.

---

## Combining Conditional CDFs and PDFs

If ${}B_1,\dots,B_n{}$ partition the sample space, the total probability theorem gives

$$
F_X(x)=\sum_i F_X(x\mid B_i)\,P[B_i]
$$

Differentiating both sides with respect to ${}x{}$:

$$
f_X(x)=\sum_i f_X(x\mid B_i)\,P[B_i]
$$

>[!Example]
>**Mixture of exponentials.** Type 1 devices (prob ${}\alpha{}$) have lifetime ${}\text{Exp}(\lambda_1){}$; Type 2 devices (prob ${}1-\alpha{}$) have lifetime ${}\text{Exp}(\lambda_2){}$. Then
>$$
>f_X(x)=\alpha\,\lambda_1 e^{-\lambda_1 x}u(x)+(1-\alpha)\,\lambda_2 e^{-\lambda_2 x}u(x)
>$$
>i.e. a weighted sum (mixture) of the two exponential densities.

---

## Summary

- **Conditional pmf:** ${}p_X(x\mid C)=P[\{X=x\}\cap C]/P[C]{}$.
- If ${}C{}$ is defined by ${}X{}$, the conditional pmf is the ordinary pmf renormalized over ${}C{}$.
- **Total probability:** mix conditional pmfs/cdfs/pdfs with the partition probabilities.
- **Conditional expectation:** ${}E[X]=\sum_i E[X\mid B_i]P[B_i]{}$.
- **Conditional pdf given ${}X>t{}$** for the exponential RV is ${}\lambda e^{-\lambda(x-t)}{}$ for ${}x>t{}$ (memoryless).
