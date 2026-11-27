# ELEC2600 Homework #1 — Solutions for Questions 2–4

Notation used below (from lecture notes):

- Conditional probability: $P[A\mid B]=\frac{P[A\cap B]}{P[B]}$
- Total probability: $P[A]=\sum_i P[A\mid B_i]P[B_i]$ where $\{B_i\}$ partition $S$
- Bayes’ Rule: $P[B_j\mid A]=\frac{P[A\mid B_j]P[B_j]}{\sum_i P[A\mid B_i]P[B_i]}$
- Binomial law: $p_n(k)=\binom{n}{k}p^k(1-p)^{n-k}$
- Geometric law: $P[\text{first success on trial }m]=p(1-p)^{m-1}$

---

## Question 2

Box 1: 4 red, 6 white (10 total).
Box 2: 3 red, 7 white (10 total).

### Case 1: two balls from Box 1 without replacement

**(2.1) P(both red)**

$$
P(R_1\cap R_2)=P(R_1)P(R_2\mid R_1)
=\frac{4}{10}\cdot\frac{3}{9}
=\frac{12}{90}
=\frac{2}{15}\approx 0.133.
$$

**(2.2) P(one red, one white)**

The ball colours can be ordered RW or WR:

$$
P(RW)+P(WR)
=\frac{4}{10}\cdot\frac{6}{9}+\frac{6}{10}\cdot\frac{4}{9}
=\frac{24}{90}+\frac{24}{90}
=\frac{48}{90}
=\frac{8}{15}\approx 0.533.
$$

### Case 2: one ball from each box

The two picks are from separate boxes, so they are independent.

**(2.3) P(both red)**

$$
P(R_1\cap R_2)=\frac{4}{10}\cdot\frac{3}{10}
=\frac{12}{100}
=\frac{3}{25}=0.12.
$$

**(2.4) P(one red, one white)**

$$
P(R_1\cap W_2)+P(W_1\cap R_2)
=\frac{4}{10}\cdot\frac{7}{10}+\frac{6}{10}\cdot\frac{3}{10}
=\frac{28}{100}+\frac{18}{100}
=\frac{46}{100}
=\frac{23}{50}=0.46.
$$

### Case 3: transfer one ball from Box 1 into Box 2, then pick from Box 2

**(2.5) P(second ball red | first ball red)**

If a red ball is moved into Box 2, Box 2 then has $3+1=4$ red and $7$ white balls, 11 total:

$$
P(R_2\mid R_1)=\frac{4}{11}\approx 0.364.
$$

**(2.6) P(second ball red)**

Use the total probability theorem, partitioning on the colour of the transferred ball:

$$
\begin{aligned}
P(R_2)
&=P(R_2\mid R_1)P(R_1)+P(R_2\mid W_1)P(W_1)\\
&=\frac{4}{11}\cdot\frac{4}{10}+\frac{3}{11}\cdot\frac{6}{10}\\
&=\frac{16}{110}+\frac{18}{110}
=\frac{34}{110}
=\frac{17}{55}\approx 0.309.
\end{aligned}
$$

(If a white ball was moved, Box 2 would contain 3 red and 8 white, so $P(R_2\mid W_1)=3/11$.)

---

## Question 3

Let

- $D$ = person has the disease, $P(D)=0.05$, $P(D^c)=0.95$.
- Sensitivity $P(T^+\mid D)=0.90$, so $P(T^-\mid D)=0.10$.
- Specificity $P(T^-\mid D^c)=0.99$, so $P(T^+\mid D^c)=0.01$.

**(3.1) P(error)**

An error is a false negative or a false positive:

$$
\begin{aligned}
P(\text{error})
&=P(D\cap T^-)+P(D^c\cap T^+)\\
&=P(T^-\mid D)P(D)+P(T^+\mid D^c)P(D^c)\\
&=0.10(0.05)+0.01(0.95)\\
&=0.005+0.0095
=0.0145.
\end{aligned}
$$

**(3.2) Accuracy**

$$
\text{Accuracy}=1-P(\text{error})=1-0.0145=0.9855=98.55\%.
$$

(Equivalently $P(T^+\mid D)P(D)+P(T^-\mid D^c)P(D^c)=0.045+0.9405=0.9855$.)

**(3.3) P(test positive)**

Total probability theorem:

$$
\begin{aligned}
P(T^+)
&=P(T^+\mid D)P(D)+P(T^+\mid D^c)P(D^c)\\
&=0.90(0.05)+0.01(0.95)\\
&=0.045+0.0095
=0.0545.
\end{aligned}
$$

**(3.4) P(disease | positive)**

Bayes’ Rule:

$$
\begin{aligned}
P(D\mid T^+)
&=\frac{P(T^+\mid D)P(D)}{P(T^+)}\\
&=\frac{0.90(0.05)}{0.0545}
=\frac{0.045}{0.0545}
=\frac{90}{109}
\approx 0.826.
\end{aligned}
$$

**(3.5) P(no disease | negative)**

First, $P(T^-)=1-P(T^+)=1-0.0545=0.9455$. By Bayes’ Rule:

$$
\begin{aligned}
P(D^c\mid T^-)
&=\frac{P(T^-\mid D^c)P(D^c)}{P(T^-)}\\
&=\frac{0.99(0.95)}{0.9455}
=\frac{0.9405}{0.9455}
\approx 0.995.
\end{aligned}
$$

**(3.6) Estimated undetected cases**

Population $N=4{,}000{,}000$; 80% tested, 20% not tested.

Undetected cases are diseased people who are either **not tested** or **tested with a false negative**:

$$
\begin{aligned}
\text{Undetected}
&=N\left[0.2\,P(D)+0.8\,P(D)\,P(T^-\mid D)\right]\\
&=4{,}000{,}000\left[0.2(0.05)+0.8(0.05)(0.10)\right]\\
&=4{,}000{,}000\left[0.01+0.004\right]\\
&=4{,}000{,}000(0.014)
=56{,}000.
\end{aligned}
$$

So about **56,000** undetected cases.

---

## Question 4

Let $X$ be the number of successful 3-point shots out of $n=9$.
Each shot is an independent Bernoulli trial with success probability $p=0.42$, so $X\sim\text{Binomial}(9,0.42)$.

**(4.1) P(exactly 5 successes)**

$$
\begin{aligned}
P(X=5)
&=\binom{9}{5}(0.42)^5(0.58)^4\\
&=126(0.42)^5(0.58)^4\\
&\approx 0.186.
\end{aligned}
$$

**(4.2) P(at most 5 successes)**

Use the complement (fewer terms to sum):

$$
P(X\le 5)=1-P(X\ge 6).
$$

$$
\begin{aligned}
P(X=6)&=\binom{9}{6}(0.42)^6(0.58)^3\approx 0.089962,\\
P(X=7)&=\binom{9}{7}(0.42)^7(0.58)^2\approx 0.027919,\\
P(X=8)&=\binom{9}{8}(0.42)^8(0.58)^1\approx 0.005054,\\
P(X=9)&=\binom{9}{9}(0.42)^9\approx 0.000407.
\end{aligned}
$$

$$
P(X\le 5)=1-(0.089962+0.027919+0.005054+0.000407)
=1-0.123342
\approx 0.877.
$$

**(4.3) P(first success on the third shot)**

Geometric law: $m-1$ failures then a success.

$$
P(M=3)=p(1-p)^{m-1}=0.42(0.58)^2
=0.42(0.3364)
\approx 0.141.
$$

**(4.4) P(first success on or after the fourth shot)**

This happens exactly when the first three shots are all failures:

$$
P(M\ge 4)=(1-p)^3=(0.58)^3\approx 0.195.
$$

**(4.5) P(exactly one failure, occurring on or after the sixth shot)**

Exactly one failure means 8 successes and 1 failure. The single failure must be on shot 6, 7, 8, or 9, giving 4 equally likely sequences, each with probability $p^8(1-p)$:

$$
P=4\,p^8(1-p)
=4(0.42)^8(0.58)
\approx 0.00225.
$$
