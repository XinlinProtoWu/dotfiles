# Lecture 22: Sum Processes and Independent Stationary Increment Processes

> **Big picture.** Start with an i.i.d. sequence and keep a running total. The result is a **sum process** — a random walk. Sum processes have **independent increments** (disjoint stretches use disjoint random variables) and **stationary increments** (the same length of time always adds the same kind of random amount). Such a process is called **i.s.i.** and is completely specified by its first-order distribution. Two i.s.i. processes dominate engineering: the **binomial counting process** (discrete time) and the **Poisson process** (continuous time).

---

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. Each is linked at its **first use** below.

**Processes:** [[terms/random-process]] · [[terms/iid-process]] · [[terms/isi-process]] · [[terms/poisson-process]]

**Objects:** [[terms/random-variable]] · [[terms/exponential-distribution]]

---

## Learning goals

By the end of this lecture you should be able to:

1. Define a sum process and write it recursively.
2. Derive the pmf of the binomial counting process.
3. Analyse the one-dimensional random walk.
4. Define independent increments and stationary increments.
5. Prove that a sum process is i.s.i.
6. Build joint pmfs/pdfs of an i.s.i. process from increments.
7. Construct the Poisson process as a limit of binomial processes.
8. Use the Poisson process's first-order pmf, increments, and inter-arrival properties.
9. Solve arrival-time problems with exponential and Erlang distributions.

---

## 1. Sum processes

Let $X_n$ be an i.i.d. process. The **sum process** is

$$
\boxed{
S_n=\sum_{i=1}^{n}X_i=X_1+X_2+\cdots+X_n,
\qquad S_0=0.
}
$$

It can be generated recursively:

$$
\boxed{S_n=S_{n-1}+X_n.}
$$

![[Part4.pdf#page=24]]
*Figure: a unit delay plus an accumulator generates $S_n$. (`Part4.pdf` p. 24)*

Think of $S_n$ as your current position and $X_n$ as the size of your latest step. The process is a **random walk**.

**In plain words.** You start at zero and every second a stranger hands you a random amount of money, positive or negative. Your bank balance after $n$ seconds is $S_n$. The next balance is just the old balance plus the new gift, and the gift does not remember how much money you already have.

---

## 2. Binomial counting process (Example 9.7)

Let $X_n$ be i.i.d. Bernoulli with parameter $p$:

$$
P[X_n=1]=p,\qquad P[X_n=0]=1-p.
$$

Then

$$
S_n=\sum_{i=1}^{n}X_i
$$

is the number of ones in the first $n$ trials. It is integer-valued, non-decreasing, and grows by unit steps, so

$$
S_n\sim\text{Binomial}(n,p),
$$

with

$$
\boxed{
p_{S_n}(k)=\binom{n}{k}p^k(1-p)^{n-k},
\qquad k=0,1,\dots,n.
}
$$

![[Part4.pdf#page=25]]
*Figure: the binomial counting process accumulates Bernoulli successes. (`Part4.pdf` p. 25)*

**In plain words.** Flip a biased coin $n$ times and count the heads. You never lose a head you already collected, so the count only goes up, one click at a time. The only randomness is whether the next flip adds a click.

**Example (traced).** With $n=5$ and $p=\tfrac12$, the probability of exactly $3$ successes is

$$
p_{S_5}(3)=\binom{5}{3}\left(\frac12\right)^3\left(\frac12\right)^2
=10\cdot\frac{1}{32}
=\frac{10}{32}
=0.3125.
$$

---

## 3. One-dimensional random walk (Example 9.16)

Let $I_n$ be a Bernoulli process and define the step

$$
D_n=2I_n-1=
\begin{cases}
+1, & I_n=1,\\
-1, & I_n=0.
\end{cases}
$$

Then

$$
S_n=\sum_{i=1}^{n}D_i
$$

is a **one-dimensional random walk**.

Properties:

- $S_n\in\{-n,-n+2,\dots,n-2,n\}$.
- $S_n$ is even when $n$ is even, and odd when $n$ is odd.
- If there are $k$ steps of $+1$, there are $n-k$ steps of $-1$, so

$$
\boxed{S_n=2k-n.}
$$

Therefore, for $0\le k\le n$,

$$
\boxed{
P[S_n=2k-n]=\binom{n}{k}p^k(1-p)^{n-k}.
}
$$

![[Part4.pdf#page=26]]
*Figure: a random walk built from $\pm1$ steps. (`Part4.pdf` p. 26)*

**In plain words.** A drunkard leaves a lamppost and each second takes one pace forward or one pace back with equal chance. After an even number of seconds the drunkard must be an even number of paces from the post, because each pair of opposite paces can cancel. The number of forward paces tells you the final position completely.

**Example (traced).** With $n=4$, $p=\tfrac12$, the only way to finish at $S_4=2$ is $k=3$ forward steps and one backward step. There are $\binom{4}{3}=4$ such sequences, so

$$
P[S_4=2]=4\left(\frac12\right)^4=\frac{4}{16}=\frac14.
$$

The parity check holds: $n=4$ is even, and $S_4=2$ is even.

---

## 4. Increments and independent increments

An **increment** of a process is the change between two times:

$$
X(t_2)-X(t_1).
$$

A process has **independent increments** if for any

$$
t_1<t_2<\cdots<t_k,
$$

the increments

$$
X(t_2)-X(t_1),\quad X(t_3)-X(t_2),\quad\dots,\quad X(t_k)-X(t_{k-1})
$$

are independent random variables.

![[Part4.pdf#page=28]]
*Figure: only non-overlapping intervals give independent increments. (`Part4.pdf` p. 28)*

**In plain words.** The amount you gain during Monday is independent of the amount you gain during Tuesday, but it is not independent of the amount you gain from Monday through Wednesday, because that longer stretch contains Monday. Independence is a statement about **non-overlapping** stretches.

> [!warning] Overlapping increments are not independent
> $X(2)-X(1)$ and $X(3)-X(1)$ share the interval $[1,2]$, so they are generally dependent. The definition only covers a chain of consecutive, disjoint intervals.

---

## 5. Stationary increments

A process has **stationary increments** if increments over intervals of the same length have the same distribution. Formally, for all $t,s$ and $h$,

$$
X(t+h)-X(t)\ \overset{d}{=}\ X(s+h)-X(s).
$$

The intervals may overlap; only their **lengths** must match.

![[Part4.pdf#page=29]]
*Figure: two length-$h$ increments, possibly overlapping, have the same distribution. (`Part4.pdf` p. 29)*

**In plain words.** The traffic rule does not care what time it is. A ten-minute stretch at rush hour has the same *probability law* for the number of new arrivals as a ten-minute stretch at midnight, even though the actual counts differ. Stationarity is a statement about the distribution, not about the observed value.

> [!note] Definition of an i.s.i. process
> A process is an **independent stationary increment** process, or **i.s.i.** process, if its non-overlapping increments are both independent and stationary.

---

## 6. Theorem: every sum process is i.s.i.

Let

$$
S_n=\sum_{i=1}^{n}X_i
$$

with the $X_i$ i.i.d.

### Independent increments

For $n_1<n_2<\cdots<n_m$,

$$
S_{n_2}-S_{n_1}=\sum_{i=n_1+1}^{n_2}X_i,
$$

$$
S_{n_3}-S_{n_2}=\sum_{i=n_2+1}^{n_3}X_i,
$$

and so on. Each increment is a sum of a **different, disjoint** block of the independent $X_i$, so the increments are independent.

### Stationary increments

For any $n_1,n_2$ and $h>0$,

$$
S_{n_1+h}-S_{n_1}=\sum_{i=n_1+1}^{n_1+h}X_i,
$$

$$
S_{n_2+h}-S_{n_2}=\sum_{i=n_2+1}^{n_2+h}X_i.
$$

Both are sums of exactly $h$ i.i.d. random variables, so they have the same distribution.

![[Part4.pdf#page=30]]
*Figure: increments split the sum into disjoint blocks of equal length. (`Part4.pdf` p. 30)*

> [!important] Converse
> Every discrete-time i.s.i. process can be written as a sum process. So “sum process” and “discrete-time i.s.i. process” are essentially the same object when $S_0=0$.

---

## 7. Joint distributions from increments

For an integer-valued i.s.i. process with $m<n$,

$$
\begin{aligned}
P[S_m=j,\ S_n=k]
&=P[S_m=j,\ S_n-S_m=k-j]\\
&=P[S_m=j]\,P[S_n-S_m=k-j]\\
&=P[S_m=j]\,P[S_{n-m}=k-j].
\end{aligned}
$$

Thus

$$
\boxed{
p_{S_m,S_n}(j,k)
=p_{S_m}(j)\,p_{S_{n-m}}(k-j).
}
$$

For $n_1<n_2<\cdots<n_m$,

$$
\boxed{
p_{S_{n_1},\dots,S_{n_m}}(k_1,\dots,k_m)
=p_{S_{n_1}}(k_1)
\prod_{i=2}^{m}p_{S_{n_i-n_{i-1}}}(k_i-k_{i-1}).
}
$$

![[Part4.pdf#page=32]]
*Figure: a high-order joint pmf factorises into independent increment pmfs. (`Part4.pdf` p. 32)*

**In plain words.** Instead of asking “where was the walk at each checkpoint?”, ask “how far did it move between consecutive checkpoints?”. Those moves are the independent steps, so their probabilities multiply. This is the whole trick for building any joint distribution of an i.s.i. process.

---

## 8. Example 9.18: joint pmf of the binomial counting process

For $n_2>n_1$ and $k_2\ge k_1$,

$$
\begin{aligned}
p_{S_{n_1},S_{n_2}}(k_1,k_2)
&=P[S_{n_1}=k_1]\,P[S_{n_2-n_1}=k_2-k_1]\\
&=\binom{n_1}{k_1}p^{k_1}(1-p)^{n_1-k_1}
\binom{n_2-n_1}{k_2-k_1}p^{k_2-k_1}(1-p)^{(n_2-n_1)-(k_2-k_1)}\\
&=\binom{n_1}{k_1}\binom{n_2-n_1}{k_2-k_1}
p^{k_2}(1-p)^{n_2-k_2}.
\end{aligned}
$$

If $k_2<k_1$,

$$
p_{S_{n_1},S_{n_2}}(k_1,k_2)=0,
$$

because a counting process cannot lose successes.

**In plain words.** To have $k_1$ successes by time $n_1$ and $k_2$ by time $n_2$, you need $k_1$ successes in the first stretch, and then exactly $k_2-k_1$ fresh successes in the remaining stretch. The two stretches use different coin flips, so you multiply their probabilities.

**Example (traced).** Take $n_1=4$, $n_2=7$, $k_1=2$, $k_2=5$, $p=\tfrac12$. The first four trials must have exactly $2$ successes, and the next three trials must have exactly $3$ successes:

$$
p_{S_4,S_7}(2,5)
=\binom{4}{2}\binom{3}{3}\left(\frac12\right)^7
=6\cdot1\cdot\frac{1}{128}
=\frac{6}{128}
=0.046875.
$$

---

## 9. Example 9.19: joint pdf of a Gaussian sum process

Let $X_i$ be i.i.d. $\mathcal N(0,\sigma^2)$ and $S_n=\sum_{i=1}^{n}X_i$. Then

$$
S_n\sim\mathcal N(0,n\sigma^2),
$$

so

$$
f_{S_n}(y)=\frac{1}{\sqrt{2\pi n\sigma^2}}
\exp\left(-\frac{y^2}{2n\sigma^2}\right).
$$

For $n_2>n_1$, use increments:

$$
\boxed{
f_{S_{n_1},S_{n_2}}(y_1,y_2)
=f_{S_{n_1}}(y_1)\,f_{S_{n_2-n_1}}(y_2-y_1).
}
$$

Explicitly,

$$
\begin{aligned}
f_{S_{n_1},S_{n_2}}(y_1,y_2)
&=\frac{1}{\sqrt{2\pi n_1\sigma^2}}
\exp\left(-\frac{y_1^2}{2n_1\sigma^2}\right)\\
&\quad\times
\frac{1}{\sqrt{2\pi(n_2-n_1)\sigma^2}}
\exp\left(-\frac{(y_2-y_1)^2}{2(n_2-n_1)\sigma^2}\right).
\end{aligned}
$$

**In plain words.** The position at the later time is the earlier position plus a fresh Gaussian step. So the pair is determined by two independent Gaussian pieces: where you already were, and how far you moved afterwards. The joint bell curve is tilted because the later position contains the earlier one.

**Example (traced).** Let $n_1=2$, $n_2=5$, $\sigma^2=1$. Then

$$
f_{S_2,S_5}(y_1,y_2)
=\frac{1}{2\pi\sqrt{6}}
\exp\left(-\frac{y_1^2}{4}-\frac{(y_2-y_1)^2}{6}\right).
$$

The normalising constant is

$$
\frac{1}{\sqrt{2\pi\cdot2}}\cdot\frac{1}{\sqrt{2\pi\cdot3}}
=\frac{1}{2\pi\sqrt6}
\approx0.0650.
$$

---

## 10. Constructing the Poisson process

Divide the time axis into subintervals of length $1/m$. In each subinterval toss a coin with

$$
P[\text{head}]=\frac{\lambda}{m}.
$$

On a head, step forward by $1$; on a tail, stay put. The position at time $t$ is

$$
N_m(t)=\sum_{i=1}^{\lfloor mt\rfloor}X_i,
$$

where $X_i$ is Bernoulli with parameter $p=\lambda/m$.

![[Part4.pdf#page=35]]
*Figure: a fine time grid turns Bernoulli steps into a counting process. (`Part4.pdf` p. 35)*

For fixed $t$ and $m$,

$$
N_m(t)\sim
\text{Binomial}\left(\lfloor mt\rfloor,\frac{\lambda}{m}\right),
$$

so

$$
P[N_m(t)=k]
=\binom{\lfloor mt\rfloor}{k}
\left(\frac{\lambda}{m}\right)^k
\left(1-\frac{\lambda}{m}\right)^{\lfloor mt\rfloor-k}.
$$

Letting $m\to\infty$ gives the **Poisson theorem**:

$$
\boxed{
P[N(t)=k]
=\frac{(\lambda t)^k}{k!}e^{-\lambda t},
\qquad k=0,1,2,\dots
}
$$

**In plain words.** Make the clock tick faster and faster, but make each tick less and less likely to produce an event, in such a way that the average number of events per second stays at $\lambda$. In the limit, individual ticks blur into a continuous stream, and the count in any interval becomes Poisson. No matter how finely you slice time, you never get two events in the same instant.

---

## 11. Definition of the Poisson counting process

The **Poisson counting process** $N(t)$ is the continuous-time, non-negative, integer-valued i.s.i. process with

$$
\boxed{
P[N(t)=k]=\frac{(\lambda t)^k}{k!}e^{-\lambda t},
\qquad k=0,1,2,\dots
}
$$

It counts the number of events that have occurred up to time $t$, when events occur at an average rate of $\lambda$ per unit time.

Applications:

- customers arriving at a service station,
- breakdowns of a component,
- requests to a web server,
- photons arriving at a detector,
- calls arriving at a call centre.

![[Part4.pdf#page=37]]
*Figure: a Poisson counting process is a non-decreasing staircase. (`Part4.pdf` p. 37)*

> [!important] Two equivalent descriptions
> The Poisson process is an i.s.i. process whose first-order pmf is Poisson. Equivalently, it is the limit of the Bernoulli counting construction above. The increments over disjoint intervals are independent Poisson variables.

---

## 12. Example 9.21: message arrivals

Inquiries arrive at a recorded message device as a Poisson process with rate $15$ per minute. Find the probability that, in a one-minute period,

- $3$ inquiries arrive during the first $10$ seconds, and
- $2$ inquiries arrive during the last $15$ seconds.

Work in seconds:

$$
\lambda=\frac{15}{60}=\frac14\ \text{per second}.
$$

The two intervals $[0,10]$ and $[45,60]$ are disjoint, so their increments are independent. By stationarity, the second interval has the same law as an interval of length $15$:

$$
\begin{aligned}
&P[N(10)=3,\ N(60)-N(45)=2]\\
&=P[N(10)=3]\cdot P[N(60)-N(45)=2]\\
&=P[N(10)=3]\cdot P[N(15)=2]\\
&=\frac{(10/4)^3e^{-10/4}}{3!}
\cdot
\frac{(15/4)^2e^{-15/4}}{2!}.
\end{aligned}
$$

Numerically,

$$
P[N(10)=3]=\frac{(2.5)^3e^{-2.5}}{6}\approx0.2138,
$$

$$
P[N(15)=2]=\frac{(3.75)^2e^{-3.75}}{2}\approx0.1654,
$$

so

$$
P\approx0.2138\cdot0.1654\approx0.0354.
$$

**In plain words.** The first ten seconds and the last fifteen seconds do not overlap, so whatever happens in one tells you nothing about the other. The rate is fixed, so you can slide the last fifteen-second window to the start of the minute and use an ordinary fifteen-second Poisson probability. Multiply the two independent chances.

---

## 13. Customer service calls

Calls arrive as a Poisson process with rate $10$ per minute. Find the probability that $2$ calls arrive in the first $10$ seconds and $6$ calls arrive in the first $30$ seconds.

Convert the rate:

$$
\lambda=\frac{10}{60}=\frac16\ \text{per second}.
$$

The event is

$$
\{N(10)=2,\ N(30)=6\}
=\{N(10)=2,\ N(30)-N(10)=4\}.
$$

The increments are independent, so

$$
P[N(10)=2,\ N(30)=6]
=P[N(10)=2]\cdot P[N(20)=4].
$$

Thus

$$
P=
\frac{(10/6)^2e^{-10/6}}{2!}
\cdot
\frac{(20/6)^4e^{-20/6}}{4!}.
$$

Numerically,

$$
P[N(10)=2]\approx0.2623,
\qquad
P[N(20)=4]\approx0.1835,
$$

so

$$
P\approx0.2623\cdot0.1835\approx0.0481.
$$

**In plain words.** “Six calls by thirty seconds” includes the two calls already counted by ten seconds. So the second stretch asks only for four *new* calls between ten and thirty seconds. Those twenty seconds are independent of the first ten, and the rate is constant, so you multiply the two Poisson probabilities.

> [!warning] Do not use $P[N(30)=6]$ directly
> The events $\{N(10)=2\}$ and $\{N(30)=6\}$ are **not** independent, because the first interval is contained in the second. You must split at $t=10$ and use the increment over $(10,30]$.

---

## 14. Second-order pmf of the Poisson process

For $t_1<t_2$ and $j\ge i$,

$$
\begin{aligned}
P[N(t_1)=i,\ N(t_2)=j]
&=P[N(t_1)=i,\ N(t_2)-N(t_1)=j-i]\\
&=P[N(t_1)=i]\,P[N(t_2-t_1)=j-i]\\
&=\frac{(\lambda t_1)^i e^{-\lambda t_1}}{i!}
\cdot
\frac{(\lambda(t_2-t_1))^{j-i}e^{-\lambda(t_2-t_1)}}{(j-i)!}.
\end{aligned}
$$

If $j<i$, the probability is zero.

![[Part4.pdf#page=39]]
*Figure: the pair $(N(t_1),N(t_2))$ is built from the first count plus a later increment. (`Part4.pdf` p. 39)*

**In plain words.** A staircase cannot go down, so the later count must be at least the earlier count. Given the earlier count, the only new information is how many extra steps occurred in the remaining stretch, and that is an independent Poisson count.

---

## 15. Properties of the Poisson process

### 15.1 Inter-arrival times are exponential

Let $T$ be the time between adjacent events. For $t\ge0$,

$$
\begin{aligned}
F_T(t)
&=P[T\le t]\\
&=P[\text{at least one arrival in an interval of length }t]\\
&=P[N(t)>0]\\
&=1-P[N(t)=0]\\
&=1-e^{-\lambda t}.
\end{aligned}
$$

Hence

$$
\boxed{
f_T(t)=\lambda e^{-\lambda t},\qquad t\ge0,
}
$$

so $T\sim\text{Exponential}(\lambda)$.

The time to the **first** event has the same exponential distribution.

The inter-arrival times are **independent**, because they live on disjoint intervals and the process has independent increments.

![[Part4.pdf#page=41]]
*Figure: the waiting time to the next event is exponential. (`Part4.pdf` p. 41)*

**In plain words.** The chance that nothing happens for the next $t$ seconds is the chance that a Poisson count over that whole stretch is zero, which is $e^{-\lambda t}$. So the chance that you have to wait at most $t$ is $1-e^{-\lambda t}$, exactly the exponential CDF. The process has no memory: how long you have already waited does not change the law of the remaining wait.

### 15.2 Time to the $m$-th event is Erlang

The time to the $m$-th event is the sum of $m$ independent exponential inter-arrival times:

$$
S_m=T_1+T_2+\cdots+T_m.
$$

Therefore $S_m$ is an **$m$-Erlang** random variable, with

$$
\boxed{
E[S_m]=\frac{m}{\lambda},
\qquad
\operatorname{Var}(S_m)=\frac{m}{\lambda^2}.
}
$$

![[Part4.pdf#page=42]]
*Figure: the $m$-th arrival is the sum of $m$ exponential waits. (`Part4.pdf` p. 42)*

### 15.3 Conditional arrival times are uniform

If exactly one event occurs in $[0,t]$, its occurrence time $X$ is uniform on $[0,t]$. For $0\le x\le t$,

$$
\begin{aligned}
F_X(x)
&=P[N(x)=1\mid N(t)=1]\\
&=\frac{P[N(x)=1]\,P[N(t)-N(x)=0]}{P[N(t)=1]}\\
&=\frac{\lambda x e^{-\lambda x}}{\lambda t e^{-\lambda t}}
\cdot e^{-\lambda(t-x)}\\
&=\frac{x}{t}.
\end{aligned}
$$

Thus

$$
\boxed{
f_X(x)=\frac{1}{t},\qquad 0\le x\le t.
}
$$

More generally, if exactly $n$ events occur in an interval, their arrival times are independent and uniform on that interval. This is what people mean when they say Poisson arrivals occur “at random” in time.

![[Part4.pdf#page=43]]
*Figure: conditioned on one arrival, its time is uniform over the interval. (`Part4.pdf` p. 43)*

---

## 16. Example 9.22: time to the 10th inquiry

Inquiries arrive as a Poisson process with rate $15$ per minute. Find the mean and variance of the time until the 10th inquiry.

In seconds,

$$
\lambda=\frac14.
$$

**Method 1 (inter-arrival times).** Each inter-arrival time is exponential with

$$
E[T]=\frac{1}{\lambda}=4,
\qquad
\operatorname{Var}(T)=\frac{1}{\lambda^2}=16.
$$

The 10th arrival time is the sum of $10$ independent waits:

$$
E[S_{10}]=10(4)=40\ \text{s},
\qquad
\operatorname{Var}(S_{10})=10(16)=160\ \text{s}^2.
$$

**Method 2 ($m$-Erlang).** With $m=10$,

$$
E[S_{10}]=\frac{m}{\lambda}=40,
\qquad
\operatorname{Var}(S_{10})=\frac{m}{\lambda^2}=160.
$$

Both methods agree.

**In plain words.** Waiting for the tenth customer is like waiting for ten separate buses, each with the same average wait and the same uncertainty. The averages add, and because the waits are independent, the uncertainties (variances) add too.

---

## 17. Example 9.23: both customers in the first minute

Customers arrive as a Poisson process. Given that $2$ customers arrive within a $2$-minute period, find the probability that both arrived during the first minute.

**Method 1 (uniform arrival times).** Given $2$ arrivals in $2$ minutes, each arrival time is uniform on $[0,2]$. Each is in the first minute with probability $\tfrac12$, independently, so

$$
P[\text{both in first minute}]=\left(\frac12\right)^2=\frac14.
$$

**Method 2 (conditioning).**

$$
\begin{aligned}
P[N(1)=2\mid N(2)=2]
&=\frac{P[N(1)=2,\ N(2)-N(1)=0]}{P[N(2)=2]}\\
&=\frac{P[N(1)=2]\,P[N(1)=0]}{P[N(2)=2]}\\
&=\frac{\dfrac{(\lambda)^2e^{-\lambda}}{2}\cdot e^{-\lambda}}
{\dfrac{(2\lambda)^2e^{-2\lambda}}{2}}\\
&=\frac14.
\end{aligned}
$$

**In plain words.** If you are told that exactly two raindrops landed on a two-metre strip, you do not know where they landed, but every position on the strip is equally likely. For both to be in the left half, each independent drop must choose the left half, which happens with chance one half for each, so one quarter for both.

---

## 18. Second-order pmf revisited

The joint pmf can also be written as a binomial mixture. For $t_1<t_2$ and $0\le k\le n$,

$$
\begin{aligned}
P[N(t_1)=k,\ N(t_2)=n]
&=\frac{(\lambda t_1)^k e^{-\lambda t_1}}{k!}\\
&\quad\times
\frac{(\lambda(t_2-t_1))^{n-k}}{(n-k)!}
e^{-\lambda(t_2-t_1)}\\
&=\frac{n!}{k!(n-k)!}
\left(\frac{t_1}{t_2}\right)^k
\left(1-\frac{t_1}{t_2}\right)^{n-k}
\cdot
\frac{(\lambda t_2)^n e^{-\lambda t_2}}{n!}.
\end{aligned}
$$

So, conditional on $N(t_2)=n$,

$$
\boxed{
N(t_1)\mid N(t_2)=n
\sim
\text{Binomial}\left(n,\frac{t_1}{t_2}\right).
}
$$

![[Part4.pdf#page=46]]
*Figure: the count by $t_1$ is a binomial thinning of the count by $t_2$. (`Part4.pdf` p. 46)*

**In plain words.** Look only at the $n$ arrivals that happened by the later time. Each one independently fell before the earlier time with probability equal to the fraction of the window that lies before $t_1$. So the earlier count is just a coin-flip count over those $n$ arrivals, with a biased coin whose bias is the fraction of time elapsed.

---

## 19. Common mistakes

1. **Assuming increments overlap freely.** Only non-overlapping increments are independent.
2. **Confusing stationary increments with a stationary process.** The Poisson process has stationary *increments*, but its mean $\lambda t$ grows with time, so the process itself is not stationary.
3. **Forgetting $S_0=0$.** Stationarity of increments is used together with $S_0=0$ to replace $S_n-S_m$ by $S_{n-m}$.
4. **Using $P[N(t_2)=j]$ instead of the increment.** For a joint event, split at the earlier time and use $N(t_2)-N(t_1)$.
5. **Mixing time units.** Convert $\lambda$ to the same unit as the times before computing; $15$ per minute is $1/4$ per second.
6. **Using the exponential mean for the $m$-th arrival.** The mean is $m/\lambda$, not $1/\lambda$.
7. **Thinking inter-arrival times are Poisson.** They are exponential; the *count* is Poisson.
8. **Thinking the Poisson process can have simultaneous events.** In continuous time, the probability of two events at exactly the same instant is zero.

---

## 20. 60-second summary

Sum process:

$$
\boxed{
S_n=\sum_{i=1}^{n}X_i,\qquad S_0=0,\qquad S_n=S_{n-1}+X_n.
}
$$

Binomial counting process:

$$
\boxed{
p_{S_n}(k)=\binom{n}{k}p^k(1-p)^{n-k}.
}
$$

Random walk:

$$
\boxed{
P[S_n=2k-n]=\binom{n}{k}p^k(1-p)^{n-k}.
}
$$

Independent increments:

$$
\boxed{
X(t_2)-X(t_1),\dots,X(t_k)-X(t_{k-1})
\ \text{are independent}.
}
$$

Stationary increments:

$$
\boxed{
X(t+h)-X(t)\ \overset{d}{=}\ X(s+h)-X(s).
}
$$

Joint pmf from increments:

$$
\boxed{
p_{S_m,S_n}(j,k)=p_{S_m}(j)\,p_{S_{n-m}}(k-j).
}
$$

Poisson process:

$$
\boxed{
P[N(t)=k]=\frac{(\lambda t)^k}{k!}e^{-\lambda t}.
}
$$

Poisson increment:

$$
\boxed{
N(t_2)-N(t_1)\sim\text{Poisson}(\lambda(t_2-t_1)).
}
$$

Inter-arrival time:

$$
\boxed{
T\sim\text{Exponential}(\lambda),
\qquad
E[T]=\frac1\lambda,
\qquad
\operatorname{Var}(T)=\frac1{\lambda^2}.
}
$$

Time to the $m$-th event:

$$
\boxed{
S_m\sim m\text{-Erlang},
\qquad
E[S_m]=\frac{m}{\lambda},
\qquad
\operatorname{Var}(S_m)=\frac{m}{\lambda^2}.
}
$$

Conditional count:

$$
\boxed{
N(t_1)\mid N(t_2)=n
\sim
\text{Binomial}\left(n,\frac{t_1}{t_2}\right).
}
$$

Continue with [[lec_23_mean_and_autocorrelation]].
