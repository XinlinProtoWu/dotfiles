# Cross-correlation and cross-covariance

**What it is.** For two processes $X(t)$ and $Y(t)$,

$$
R_{XY}(t_1,t_2)=E[X(t_1)Y(t_2)]
$$

is the cross-correlation, and

$$
C_{XY}(t_1,t_2)=R_{XY}(t_1,t_2)-m_X(t_1)m_Y(t_2)
$$

is the cross-covariance. The processes are uncorrelated if $C_{XY}(t_1,t_2)=0$ for all $t_1,t_2$.

**Why it exists.** When a signal is observed through noise, or when two signals are compared, we need to know whether one process at one time carries information about another process at another time. Unlike the autocorrelation, the order matters: $R_{XY}(t_1,t_2)=R_{YX}(t_2,t_1)$.

**Example.** For $X(t)=\cos(2\pi t+\xi)$ and $Y(t)=\sin(2\pi t+\xi)$ with $\xi$ uniform on $[-\pi,\pi]$,

$$
R_{XY}(t_1,t_2)=-\frac12\sin(2\pi(t_1-t_2)).
$$

At zero lag the cross-correlation is zero, even though $X$ and $Y$ are deterministically related.

**Where it appears:** [[lec_25_multiple_random_processes]] Sections 8–11

**Related:** [[terms/autocorrelation]] · [[terms/random-process]] · [[terms/gaussian-process]]
