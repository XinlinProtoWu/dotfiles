# Stationarity

**What it is.** A process is stationary if the joint distribution of any set of samples is unchanged when all sample times are shifted by the same amount:

$$
F_{X(t_1),\dots,X(t_k)}(x_1,\dots,x_k)
=
F_{X(t_1+\Delta),\dots,X(t_k+\Delta)}(x_1,\dots,x_k).
$$

**Why it exists.** It formalises “the statistics do not drift with time.” It allows us to treat a long record as representative, and it forces the mean and variance to be constant and the autocorrelation to depend only on lag. It is weaker than independence: a dependent process can still be stationary.

**Example.** An i.i.d. process is stationary because every finite sample is independent with the same marginal, and shifting the times changes nothing. A random walk is not stationary because its variance $n\sigma^2$ grows with $n$.

**Where it appears:** [[lec_24_stationary_random_processes]] Sections 1–5

**Related:** [[terms/wss]] · [[terms/iid-process]] · [[terms/autocorrelation]]
