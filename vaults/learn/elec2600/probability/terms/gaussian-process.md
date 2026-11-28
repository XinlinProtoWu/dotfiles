# Gaussian random process

**What it is.** A process whose samples at any finite set of times are jointly Gaussian. For sample times $t_1,\dots,t_k$, the density is

$$
f(\mathbf x)=\frac{1}{(2\pi)^{k/2}\lvert C\rvert^{1/2}}
\exp\left[-\frac12(\mathbf x-\mathbf m)^T C^{-1}(\mathbf x-\mathbf m)\right],
$$

where $\mathbf m$ is the mean vector and $C$ is the covariance matrix with entries $C_X(t_i,t_j)$.

**Why it exists.** A Gaussian process is completely specified by its mean and covariance functions. This makes joint densities, conditioning, and linear transformations tractable. It is also the limit of sums of many small independent effects (CLT), so it is the default model for noise.

**Example.** White Gaussian noise has $m_X(n)=0$ and $C_X(n_1,n_2)=\sigma^2\delta(n_1-n_2)$. The covariance matrix for two samples is $\sigma^2I$, so the joint density factors into two independent Gaussian densities.

**Where it appears:** [[lec_23_mean_and_autocorrelation]] Sections 10–11 · [[lec_24_stationary_random_processes]] Sections 9–10

**Related:** [[terms/wiener-process]] · [[terms/autocorrelation]] · [[terms/wss]]
