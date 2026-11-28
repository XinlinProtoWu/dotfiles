# Random variable

**What it is.** A random variable is a function that assigns a real number to each outcome of an experiment. Its distribution is described by a CDF $F_X(x)=P[X\le x]$, a pmf (discrete), or a pdf (continuous).

**Why it exists.** It is the basic object that turns outcomes into numbers we can average, compare, and combine. A random process extends the idea by assigning a whole function of time to each outcome; freezing the time in a random process gives a random variable.

**Example.** Roll a fair die and let $X$ be the result. Then $P[X=k]=1/6$ for $k=1,\dots,6$, and $E[X]=3.5$. In the random-step process, $X(t)=u(t-T)$ is a random variable for each fixed $t$, taking only the values $0$ and $1$.

**Where it appears:** [[lec_21_definition_of_a_random_process]] Sections 1–2 · [[lec_25_multiple_random_processes]] Section 1

**Related:** [[terms/random-process]] · [[terms/iid-process]]
