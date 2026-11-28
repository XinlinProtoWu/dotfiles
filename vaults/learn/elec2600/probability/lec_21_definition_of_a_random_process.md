# Lecture 21: Definition of a Random Process

> **Big picture.** A random variable gives one random number. A **random process** gives a whole random *function of time*: every outcome of the experiment selects one complete waveform. Freeze the time and you get a random variable; freeze the outcome and you get one sample path. A process is fully specified by the joint distributions of all its time samples, and an **i.i.d. process** is the simplest case: all samples independent with one common marginal distribution.

---

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. Each is linked at its **first use** below.

**Processes:** [[terms/random-process]] · [[terms/iid-process]]

**Building blocks:** [[terms/random-variable]]

---

## Learning goals

By the end of this lecture you should be able to:

1. Define a random process as a mapping from outcomes to time functions.
2. Distinguish discrete-time from continuous-time processes.
3. Interpret $X(t,\xi)$ as an ensemble, a realization, a random variable, or a number.
4. Express events about a process as equivalent events in the underlying sample space.
5. Specify a process by its first-order, second-order, and $n$-th order distributions.
6. Recognise an i.i.d. process and write its joint density as a product of marginals.
7. Work with the Bernoulli process and white Gaussian noise.

---

## 1. Definition

A **random process** (or **stochastic process**) maps a probability space $S$ to a set of functions. It assigns to every outcome $\xi\in S$ a time function

$$
X(t,\xi),\qquad t\in I,
$$

where $I$ is called the **index set**.

| Index set $I$ | Name | Notation |
|---|---|---|
| Discrete, e.g. $I=\{0,1,2,\dots\}$ | discrete-time random process | $X(n,\xi)$ or $X_n$ |
| Continuous, e.g. $I=\mathbb{R}$ | continuous-time random process | $X(t,\xi)$ or $X(t)$ |

We usually suppress $\xi$ and write $X_n$ or $X(t)$.

![[Part4.pdf#page=3]]
*Figure: the index set and two sample functions of a random process. (`Part4.pdf` p. 3)*

**In plain words.** Think of a factory that makes an infinite strip of graph paper, one strip per outcome. The experiment picks one strip out of the pile, and the whole curve already printed on it is your random process. The only question is whether the curve is drawn at separated ticks (discrete time) or continuously (continuous time).

---

## 2. Four ways to read $X(t,\xi)$

The same symbol means four different things depending on what you hold fixed.

| Fixed | Varying | What you see |
|---|---|---|
| nothing | $t$ and $\xi$ | the whole **ensemble** of functions |
| $\xi$ | $t$ | one **realization**, **sample path**, or **sample function** |
| $t$ | $\xi$ | an ordinary **random variable** |
| $t$ and $\xi$ | nothing | a single **number** |

![[Part4.pdf#page=4]]
*Figure: the ensemble view versus one sample path. (`Part4.pdf` p. 4)*

**In plain words.** A playlist of 100 songs is the ensemble. Choosing song number $\xi$ and listening gives one sample path: the sound-pressure waveform arriving at your left earphone. If you instead ask “how loud is song $\xi$ at exactly two seconds?”, you get one random number; if you also fix which song, you get one measured number.

---

## 3. Discrete-time example: random binary sequence

Let $\xi$ be chosen uniformly from $S=[0,1]$, and let $b_1,b_2,\dots$ be its binary expansion:

$$
\xi=\sum_{n=1}^{\infty}b_n2^{-n}
=\frac{b_1}{2}+\frac{b_2}{4}+\frac{b_3}{8}+\cdots
$$

Define

$$
X(n,\xi)=b_n,\qquad n=1,2,\dots
$$

This is a discrete-time **Bernoulli process** with $p=\tfrac12$.

![[Part4.pdf#page=5]]
*Figure: the binary expansion of $\xi$ and the resulting bit sequence. (`Part4.pdf` p. 5)*

**In plain words.** Pick a random point on a ruler marked from 0 to 1. Write that point in binary, and read the digits one at a time. The first digit tells you which half the point fell in, the second tells you which quarter, and so on. Because the point is uniform, every digit is a fair coin, and digits in different positions do not influence each other.

### Example 9.3 (traced)

Find $P[X(1,\xi)=0]$ and $P[X(1,\xi)=0,\ X(2,\xi)=1]$.

The first bit is 0 exactly when $\xi\in[0,\tfrac12)$:

$$
P[X(1)=0]=P\left[0\le\xi<\frac12\right]=\frac12.
$$

The first two bits are $0,1$ exactly when $\xi\in[\tfrac14,\tfrac12)$:

$$
P[X(1)=0,\ X(2)=1]
=P\left[\frac14\le\xi<\frac12\right]
=\frac14.
$$

![[Part4.pdf#page=11]]
*Figure: each bit fixes one half, then one quarter, of the unit interval. (`Part4.pdf` p. 11)*

In general, any specified sequence of $k$ bits corresponds to an interval of length $2^{-k}$, so its probability is $2^{-k}$.

> [!important] The sample space does the work
> The “experiment” is only the single choice of $\xi$. Every bit, and every event about the whole infinite sequence, is determined by that one number.

---

## 4. Continuous-time examples

### 4.1 Random amplitude sinusoid (Example 9.2a)

Let $\xi$ be uniform on $[-1,1]$ and define

$$
X(t,\xi)=\xi\cos(2\pi t).
$$

Every realization is a sinusoid, but with random amplitude $\xi$.

![[Part4.pdf#page=6]]
*Figure: sinusoids with random amplitudes, all in phase. (`Part4.pdf` p. 6)*

**In plain words.** A singer holds one note and you turn the volume knob before the performance starts; the knob setting is chosen once and then left alone. Every performance has the same rhythm, but a different loudness throughout.

### 4.2 First-order density (Example 9.4a)

For a fixed $t$, $X(t)=\xi\cos(2\pi t)$ is a linear rescaling of a uniform variable, so it is uniform on

$$
\bigl[-\lvert\cos(2\pi t)\rvert,\ \lvert\cos(2\pi t)\rvert\bigr].
$$

Hence, for most $t$,

$$
f_X(x;t)=
\begin{cases}
\dfrac{1}{2\lvert\cos(2\pi t)\rvert},
& -\lvert\cos(2\pi t)\rvert\le x\le \lvert\cos(2\pi t)\rvert,\\[6pt]
0, & \text{otherwise}.
\end{cases}
$$

When $\cos(2\pi t)=0$, the random variable collapses to the constant $0$, so the density is a delta function $\delta(x)$. That happens at

$$
t=0.25,\ 0.75,\ 1.25,\dots
$$

![[Part4.pdf#page=14]]
*Figure: the first-order density narrows as $t$ approaches a zero of the cosine. (`Part4.pdf` p. 14)*

**In plain words.** At a moment when the cosine is near its peak, the unknown amplitude is passed through almost unchanged, so the possible values spread widely. At a moment when the cosine is near zero, every possible amplitude is squashed almost to zero, so the possible values bunch up at zero. The density is just telling you how wide the surviving range of values is.

**Example (traced).** At $t=0.1$,

$$
\cos(0.2\pi)\approx0.8090,
$$

so $X(0.1)$ is uniform on $[-0.8090,0.8090]$ with height

$$
\frac{1}{2(0.8090)}\approx0.618.
$$

At $t=0.2$,

$$
\cos(0.4\pi)\approx0.3090,
$$

height $1/(0.618)\approx1.618$. At $t=0.25$, $\cos(0.5\pi)=0$, so $X(0.25)=0$ with probability one.

### 4.3 Random phase sinusoid (Example 9.2b)

Let $\xi$ be uniform on $[-\pi,\pi]$ and define

$$
X(t,\xi)=\cos(2\pi t+\xi),\qquad -\infty<t<\infty.
$$

All realizations are the same cosine, shifted in phase.

![[Part4.pdf#page=7]]
*Figure: sinusoids with random phase; each realization is a shifted copy. (`Part4.pdf` p. 7)*

**In plain words.** An orchestra starts the same note at slightly different moments. Every player produces the same wave shape, but the starting instant is random, so at any fixed clock time the players are at different points of the wave.

This is the basic model behind **quadrature amplitude modulation (QAM)**, which encodes information in both the amplitude and the phase of a carrier.

![[Part4.pdf#page=8]]
*Figure: QAM constellation — amplitude and phase carry the symbols. (`Part4.pdf` p. 8)*

> [!note] Why these two examples matter
> They are the two simplest ways to randomize a deterministic signal: randomize its **size** (amplitude) or randomize its **timing** (phase). Later lectures use both to compute means and autocorrelations.

---

## 5. Events and equivalent events

Events about a process usually fix the value at one or more instants:

$$
A=\{X(0,\xi)<1\},
$$

$$
B=\{X(0,\xi)>0,\ 1<X(1,\xi)<2\}.
$$

To find $P[A]$ or $P[B]$, translate the event into the corresponding set of outcomes $\xi$ in the original sample space. That set is the **equivalent event**.

**In plain words.** The process is a machine that turns a lottery ticket into a waveform. An event such as “the waveform is below 1 at noon” is really a statement about which lottery tickets could have produced such a waveform. So you colour in those tickets on the lottery list and measure how much of the list they cover.

---

## 6. Specifying a process by its time samples

A random process is **uniquely specified** by the collection of all $n$-th order distributions for every $n$ and every choice of times.

### First order

$$
F_X(x;t)=P[X(t,\xi)\le x],
$$

$$
f_X(x;t)=\frac{d}{dx}F_X(x;t).
$$

### Second order

$$
F_{X(t_1),X(t_2)}(x_1,x_2)
=P[X(t_1)\le x_1,\ X(t_2)\le x_2],
$$

$$
f_{X(t_1),X(t_2)}(x_1,x_2)
=\frac{\partial^2}{\partial x_1\,\partial x_2}
F_{X(t_1),X(t_2)}(x_1,x_2).
$$

### $n$-th order

$$
F_{X(t_1),\dots,X(t_n)}(x_1,\dots,x_n)
=P\left[\bigcap_{i=1}^{n}\{X(t_i)\le x_i\}\right],
$$

$$
f_{X(t_1),\dots,X(t_n)}(x_1,\dots,x_n)
=
\frac{\partial^n}{\partial x_1\cdots\partial x_n}
F_{X(t_1),\dots,X(t_n)}(x_1,\dots,x_n).
$$

For a discrete-valued process, specify the joint pmf instead:

$$
p_{X(t_1),\dots,X(t_n)}(k_1,\dots,k_n)
=P\left[\bigcap_{i=1}^{n}\{X(t_i)=k_i\}\right].
$$

![[Part4.pdf#page=16]]
*Figure: the second-order density is the mixed derivative of the second-order CDF. (`Part4.pdf` p. 16)*

> [!warning] A process is more than its marginals
> Knowing $f_X(x;t)$ for every $t$ does **not** determine the process. You also need the joint behaviour at different times. Two processes can have identical first-order marginals and completely different sample paths.

---

## 7. Independent and identically distributed processes

A discrete-time process $X_n$ is **i.i.d.** if every finite vector of samples is independent and identically distributed. Equivalently, there is one marginal CDF $F(x)$ such that for every $k$,

$$
F_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\prod_{i=1}^{k}F(x_i).
$$

For densities,

$$
f_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\prod_{i=1}^{k}f(x_i).
$$

Thus an i.i.d. process is completely specified by **one** marginal distribution.

![[Part4.pdf#page=17]]
*Figure: the $k$-th order distribution factorises into $k$ copies of one marginal. (`Part4.pdf` p. 17)*

**In plain words.** An i.i.d. process is an infinite row of independent identical experiments. It looks like infinitely many coin tosses, but there is still only one underlying experiment — once the outcome is chosen, the entire infinite sequence is fixed.

---

## 8. Bernoulli process and white Gaussian noise

### 8.1 Bernoulli process

A **Bernoulli random process** is a binary i.i.d. process: at each $n$,

$$
X_n=
\begin{cases}
1, & \text{with probability }p,\\
0, & \text{with probability }q=1-p.
\end{cases}
$$

![[Part4.pdf#page=18]]
*Figure: a Bernoulli process is an infinite sequence of independent coin flips. (`Part4.pdf` p. 18)*

### Example 9.5 (traced)

Given a Bernoulli process, find

$$
P[X_0=1,\ X_1=0,\ X_5=0,\ X_6=1].
$$

By independence,

$$
P[X_0=1,\ X_1=0,\ X_5=0,\ X_6=1]
=p(1-p)(1-p)p
=p^2(1-p)^2.
$$

If $p=\tfrac12$,

$$
p^2(1-p)^2
=\left(\frac12\right)^2\left(\frac12\right)^2
=\frac{1}{16}
=0.0625.
$$

If $p=\tfrac14$,

$$
p^2(1-p)^2
=\left(\frac14\right)^2\left(\frac34\right)^2
=\frac{9}{256}
\approx0.0352.
$$

For $p=\tfrac12$, **every** specified block of $k$ bits has probability $2^{-k}$. For $p\ne\tfrac12$, the probability depends on how many ones and zeros appear.

**In plain words.** For a fair coin, any particular sequence of four tosses is just as likely as any other, so each named sequence has one chance in sixteen. For a biased coin, a sequence with many heads is more likely than one with many tails, so the probability now depends on the *count*, not just the length.

### 8.2 White Gaussian noise (Example 9.6)

Let $X_n$ be i.i.d. Gaussian with zero mean and variance $\sigma^2$. The marginal density is

$$
f_{X_k}(x_k)=\frac{1}{\sqrt{2\pi}\,\sigma}
\exp\left(-\frac{x_k^2}{2\sigma^2}\right).
$$

The joint density of the first two samples is the product:

$$
\begin{aligned}
f_{X_1,X_2}(x_1,x_2)
&=\frac{1}{\sqrt{2\pi}\,\sigma}
\exp\left(-\frac{x_1^2}{2\sigma^2}\right)
\cdot
\frac{1}{\sqrt{2\pi}\,\sigma}
\exp\left(-\frac{x_2^2}{2\sigma^2}\right)\\
&=\frac{1}{2\pi\sigma^2}
\exp\left(-\frac{x_1^2+x_2^2}{2\sigma^2}\right).
\end{aligned}
$$

For the first $k$ samples,

$$
f_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\frac{1}{(2\pi\sigma^2)^{k/2}}
\exp\left(-\frac{x_1^2+\cdots+x_k^2}{2\sigma^2}\right).
$$

![[Part4.pdf#page=21]]
*Figure: a white-noise generator produces independent Gaussian samples. (`Part4.pdf` p. 21)*

**In plain words.** White Gaussian noise is the sound of a very fast sequence of independent bell-curve kicks. Because the kicks do not coordinate, the joint bell curve is perfectly round in every pair of coordinates: knowing one sample tells you nothing about the next.

> [!important] Product structure is the giveaway
> Independence turns a joint density into a product. For a Gaussian i.i.d. process the exponent becomes a sum of squares and the normalising constant becomes a power of $2\pi\sigma^2$.

---

## 9. Common mistakes

1. **Thinking $X(t)$ is a number.** For fixed $t$ it is a random variable; only after fixing both $t$ and $\xi$ is it a number.
2. **Confusing the ensemble with one realization.** One sample path is not the process; the process is the whole family of possible paths.
3. **Assuming first-order marginals specify the process.** They do not; the joint distributions at different times are also needed.
4. **Forgetting the index set.** “Discrete-time” and “continuous-time” refer to $I$, not to whether the values $X(t)$ are discrete.
5. **Writing an i.i.d. joint density as a sum.** Independence multiplies densities, so the joint density is a product.
6. **Believing i.i.d. means the values must be $0$ or $1$.** i.i.d. only says the samples are independent and share one distribution; that distribution can be Bernoulli, Gaussian, uniform, etc.
7. **Treating the binary expansion as infinitely many separate experiments.** There is one experiment (choose $\xi$); the bits are determined by it.

---

## 10. 60-second summary

A random process maps outcomes to time functions:

$$
\boxed{X(t,\xi),\qquad t\in I.}
$$

Fixed $\xi$ gives a **sample path**; fixed $t$ gives a **random variable**; fixed both gives a **number**.

A process is specified by all $n$-th order distributions:

$$
\boxed{
F_{X(t_1),\dots,X(t_n)}(x_1,\dots,x_n)
=P[X(t_1)\le x_1,\dots,X(t_n)\le x_n].
}
$$

An i.i.d. process factors into one marginal:

$$
\boxed{
f_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\prod_{i=1}^{k}f(x_i).
}
$$

Bernoulli process:

$$
\boxed{
P[X_0=x_0,\dots,X_k=x_k]
=p^{\#1}(1-p)^{\#0}.
}
$$

White Gaussian noise:

$$
\boxed{
f_{X_1,\dots,X_k}(x_1,\dots,x_k)
=\frac{1}{(2\pi\sigma^2)^{k/2}}
\exp\left(-\frac{1}{2\sigma^2}\sum_{i=1}^{k}x_i^2\right).
}
$$

Continue with [[lec_22_sum_processes_and_isi]].
