# Random process

**What it is.** A random process (or stochastic process) is a family of time functions indexed by an outcome: $X(t,\xi)$ maps each outcome $\xi$ of an experiment to a function of the time index $t$. The index set $I$ may be discrete (discrete-time process, written $X_n$) or continuous (continuous-time process, written $X(t)$).

**Why it exists.** A random variable describes one uncertain number. Signals, noise, queues, and stock prices are uncertain *whole waveforms*, so we need an object that assigns a random function rather than a random number. Freezing $t$ gives a random variable; freezing $\xi$ gives one sample path.

**Example.** Choose $\xi$ uniformly on $[0,1]$ and let $X(n,\xi)=b_n$ be the $n$-th binary digit of $\xi$. This is a discrete-time Bernoulli process; the first digit is $0$ exactly when $\xi<1/2$.

**Where it appears:** [[lec_21_definition_of_a_random_process]] Sections 1–6 · [[lec_22_sum_processes_and_isi]] Section 1 · [[lec_25_multiple_random_processes]] Section 8

**Related:** [[terms/iid-process]] · [[terms/isi-process]] · [[terms/autocorrelation]]
