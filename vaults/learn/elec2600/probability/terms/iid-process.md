# I.I.D. process

**What it is.** A discrete-time process $X_n$ is independent and identically distributed (i.i.d.) if every finite vector of samples is independent and all samples share one marginal distribution:

$$
F_{X_1,\dots,X_k}(x_1,\dots,x_k)=\prod_{i=1}^{k}F(x_i).
$$

**Why it exists.** It is the simplest nontrivial random process and the building block for sum processes, Bernoulli processes, white noise, and the Poisson construction. Because the joint distribution factorises, one marginal specifies the whole process.

**Example.** White Gaussian noise: $X_n\sim\mathcal N(0,\sigma^2)$ independently. The joint density of $k$ samples is

$$
f(x_1,\dots,x_k)=\frac{1}{(2\pi\sigma^2)^{k/2}}\exp\left(-\frac{1}{2\sigma^2}\sum_{i=1}^{k}x_i^2\right).
$$

**Where it appears:** [[lec_21_definition_of_a_random_process]] Sections 7–8 · [[lec_22_sum_processes_and_isi]] Sections 1–3 · [[lec_23_mean_and_autocorrelation]] Sections 4 and 8 · [[lec_24_stationary_random_processes]] Section 2

**Related:** [[terms/random-process]] · [[terms/isi-process]] · [[terms/autocorrelation]]
