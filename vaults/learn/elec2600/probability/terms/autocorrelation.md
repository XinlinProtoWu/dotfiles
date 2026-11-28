# Autocorrelation and autocovariance

**What it is.** For a random process $X(t)$,

$$
R_X(t_1,t_2)=E[X(t_1)X(t_2)]
$$

is the autocorrelation, and

$$
C_X(t_1,t_2)=E[(X(t_1)-m_X(t_1))(X(t_2)-m_X(t_2))]
=R_X(t_1,t_2)-m_X(t_1)m_X(t_2)
$$

is the autocovariance. Setting $t_1=t_2$ gives the variance: $C_X(t,t)=\operatorname{Var}[X(t)]$.

**Why it exists.** The mean and variance describe one instant. The autocorrelation describes how strongly the process at one time is tied to itself at another time — whether it has memory, how fast it changes, and how much power it carries. For WSS processes it becomes a function of the lag alone.

**Example.** For a WSS random-phase sinusoid $X(t)=\cos(2\pi t+\xi)$ with $\xi$ uniform on $[-\pi,\pi]$,

$$
R_X(\tau)=\frac12\cos(2\pi\tau).
$$

At zero lag this is $1/2$, the average power; at a lag of a quarter period it is zero.

**Where it appears:** [[lec_23_mean_and_autocorrelation]] Sections 5–9 · [[lec_24_stationary_random_processes]] Sections 5 and 11 · [[lec_25_multiple_random_processes]] Section 9

**Related:** [[terms/cross-correlation]] · [[terms/wss]] · [[terms/gaussian-process]]
