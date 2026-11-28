# Exponential distribution

**What it is.** A non-negative continuous random variable $T$ is exponential with rate $\lambda>0$ if

$$
f_T(t)=\lambda e^{-\lambda t},\qquad t\ge0,
$$

with

$$
F_T(t)=1-e^{-\lambda t},
\qquad
E[T]=\frac1\lambda,
\qquad
\operatorname{Var}(T)=\frac1{\lambda^2}.
$$

**Why it exists.** It is the waiting time between events in a Poisson process, and it is the continuous distribution with the memoryless property:

$$
P[T>s+t\mid T>s]=P[T>t].
$$

**Example.** Inquiries arrive as a Poisson process at rate $15$ per minute, so $\lambda=1/4$ per second. Each inter-arrival time has mean $4$ seconds and variance $16$ seconds squared. The time to the 10th inquiry has mean $10(4)=40$ seconds and variance $10(16)=160$ seconds squared.

**Where it appears:** [[lec_22_sum_processes_and_isi]] Sections 15–16

**Related:** [[terms/poisson-process]] · [[terms/isi-process]]
