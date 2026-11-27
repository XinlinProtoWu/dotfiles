## Random Variables
- A random outcome of concern is numerical *X*, a random variable.
- Can be useful to view an RV (*random variable*) as a function that assigns a real number X(${}\zeta{}$) to every outcome ${}\zeta{}$ of an underlying experiment.
- *S*, the underlying sample space, is *Domain* of the random variable
- *${}S_{x}{}$*, the set of all possible values of *X*, is the *Range* of the random variable
>[!Example]
>in a fair die
>${}X = 10i{}$ where ${}i{}$ is the number of dots on the die face
>${}S = \{ 1,2,3,4,5,6 \}{}$
>${}S_{X}=\{ 10,20,30,40,50,60 \}{}$

- #### ${}\zeta{}$ is an outcome, whereas the entire 'outcome space' is denoted by ${}S{}$
- #### ${}X{}$ is the variable, ${}X(\zeta){}$ is the ${}X{}$ value at that specific event

### Equivalent Event:
- Let ${}B \subset \mathbb{R}{}$ be an event for ${}X{}$
- Let ${}A{}$ be set of outcomes of ${}\zeta{}$ that map to ${}B{}$. ${}A=\{ \zeta:X(\zeta) \in B \}{}$
- ${} A{}$ and ${}B{}$ are *equivalent events* so if B occurs A must as well. Events A and B have the same probability

## Discrete Random Variables

- Assumes values from a countable set ${}S_{X} = \{ x_{1},x_{2},x_{3},K \}{}$
- *Finite* if the range is finite.
- Any random variable defined on an experiment with a finite or countable number of outcomes must be discrete.
- Could also arise from *uncountable infinite* number of outcomes
	- Analog to digital conversion

### Different ways to represent probabilities of any event based on a discrete random variable:
1. From the *probability mass function (pmf)*
2. From the *cumulative distribution function(cdf)*
3. From the *characteristic function*

### Probability Mass Function (PMF):

- Let X be a discrete random variable that assumes values from a finite set: ${}S_{X} = \{ x_{1},x_{2},x_{3},K \}{}$
- *PMF*: ${}p_{x}(x) = P[X=x]=P[\{ \zeta:X(\zeta)=x \}]{}$
- Note that ${}p_{x}(x){}$ is only nonzero at values ${}x_{1}, x_{2},x_{3}{}$
	- ${}p_{x}(x_{k})=P[A_{k}]{}$ where ${}A_{k}=\{ \zeta:X(\zeta)=x_{k} \}{}$
![[Part2.pdf#page=17&selection=4,1,4,6|Part2, page 17]]
