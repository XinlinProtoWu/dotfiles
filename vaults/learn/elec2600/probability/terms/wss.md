# Wide-sense stationarity (WSS)

**What it is.** A process is wide-sense stationary if its mean is constant and its autocorrelation depends only on the time difference:

$$
m_X(t)=m,
\qquad
R_X(t_1,t_2)=R_X(t_1-t_2).
$$

Equivalently, $C_X(t_1,t_2)=C_X(t_1-t_2)$.

**Why it exists.** Full stationarity requires every finite-order distribution to be time-invariant, which is usually impossible to verify. Most engineering tools — power spectra, linear filters, covariance calculations — need only the first two moments. WSS is the tractable condition that supports them.

**Example.** Two interleaved sequences, one used at even times and one at odd times, can have mean $0$ and variance $1$ at every time, with zero covariance at nonzero lag. That process is WSS, but it is not stationary because the marginal distribution alternates between $\{\pm1\}$ and $\{+1/3,-3\}$.

**Where it appears:** [[lec_24_stationary_random_processes]] Sections 6–12

**Related:** [[terms/stationarity]] · [[terms/autocorrelation]] · [[terms/gaussian-process]]
