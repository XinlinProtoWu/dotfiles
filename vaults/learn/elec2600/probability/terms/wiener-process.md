# Wiener process

**What it is.** The Wiener process $W(t)$ is the continuous-time Gaussian i.s.i. process with

$$
m_W(t)=0,
\qquad
C_W(t_1,t_2)=\sigma^2\min(t_1,t_2).
$$

In particular, $\operatorname{Var}[W(t)]=\sigma^2t$.

**Why it exists.** It is the continuous-time limit of a random walk with step size shrinking like $1/\sqrt m$ and is the standard model for Brownian motion, diffusive transport, and slowly wandering quantities. It is also the canonical example of a Gaussian process whose covariance is not a function of lag, so the process is not stationary.

**Example.** Let $\sigma^2=2$. Then $W(2)\sim\mathcal N(0,4)$ and the pair $(W(2),W(5))$ has covariance matrix

$$
C=\begin{bmatrix}4&4\\4&10\end{bmatrix},
\qquad
\lvert C\rvert=24.
$$

**Where it appears:** [[lec_23_mean_and_autocorrelation]] Section 11 · [[lec_25_multiple_random_processes]] Sections 6–7

**Related:** [[terms/gaussian-process]] · [[terms/isi-process]] · [[terms/poisson-process]]
