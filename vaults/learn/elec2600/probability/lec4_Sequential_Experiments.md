- Experiments that have *multiple participants* or are *repetitive* can be seen as a sequence of sub-experiments
- The sub experiments can be identical or non-identical, dependent or independent. The individual sample spaces can be identical or non-identical
### Sample spaces:
- can be represented as the *Cartesian Product* of the individual sample spaces: ${}S_{1} \times S_{2} \times S_{3} \dots S_{n}{}$

### Sequence of Independent Sub Experiments:
- The probability of any event can be computed by exploiting independence
- Let ${}A_{1}, A_{2}, A_{3}, \dots,A_{n}{}$ be events such that ${}A_{k}{}$ concerns only the outcome of the *k*th sub-experiment. If the sub-experiments are independent, we have:
$$
P[A_{1}\cap A_{2}\cap\dots \cap A_{n}]=P[A_{1}]P[A_{2}]\dots P[A_{n}]
$$

### Bernoulli Trials
- Performed once with two possible outcomes
	- *Success*
	- **Failure**
- Binary sample space {success, failure}, {1, 0}, {True, False}

### Binomial Probability Law
- If n *independent Bernouli trials*, the number of successes follows a binomial probability law:
$$
p_{n}(k) = \binom{n}{k}p^k(1-p)^{n-k}
$$
where ${}\binom{n}{k} = \frac{n!}{k!(n-k)!}{}$

### Binomial Theorem
- SInce the number of successes in *n* trials can range from 0 to n

$$
\sum_{k=0}^{n}p_{n}(k) =1
$$
>[!NOTE] PROOF
>
>${}(a+b)^n=\sum_{k=0}^{n}\binom{n}{k}a^kb^{n-k}{}$
>${}a=p{}$ and ${}b=(1-p){}$
>${}(p+1-p)^n=\sum_{k=0}^{n}p^k(1-p)^{n-k}{}$

### Multinomial Probability Law
- Generalized Binomial Theorem
- Suppose *n* independent reps of the sub-experiment are performed
- Suppose ${}B_{1}, B_{2}, \dots, B_{n}{}$ *partition the sample space* S. Let ${}P[B_{j}]=p_{j}{}$, then ${}p_{1} + p_{2} + \dots + p_{M}=1{}$
- let ${}k_{j}{}$ be the number of times that event ${}B_{j}{}$ occurs over the n repeittions
$$
P[(k_{1},k_{2},\dots,k_{M}] = \frac{n!}{k_{1}!k_{2}!\dots k_{M}!}p_{1}^{k_{1}}p_{2}^{k_{2}}\dots p_{m}^{k_{M}}
$$

###  The Geometric Probability Law

#### Use this one when determining how many tries it will take to get the first hit (Including the successful trial)
- Let *M* be the number of trials until first success.
- The probability that ${}M=m{}$ is given by ${}P_{M}(m)=P[A_{1}^cA_{2}^c\dots A_{m}^cA_{m}] = p(1-p)^{m-1}{}$
- ${}P[A_{k}] = p{}$ and ${}P[A_{k}^c] = 1-p{}$

#### Use this one when determining how many fails will be before the first hit (Excluding the successful trial)
- Let *N* be the number of trials **BEFORE** the first success
- ${}N=n{}$ is given by ${}p(n)=P[A_{1}^cA_{2}^c\dots A_{n}^cA_{n+1}]=p(1-p)^n{}$

#### Important Property:
The probability that *more than* K *trials* are required until the first success is 
$$
P[M>K]=p\sum_{m=K+1}^{\infty}(1-p)^{m-1} =p(1-p)^k\sum_{m'=0}^{\infty}(1-p)^{m'}=\frac{p(1-p)^k}{1-(1-p)}=(1-p)^k
$$
#### This is just representing the number of failed consecutive trials.

### Sequence of Dependent Experiments

- For dependent cases: Let ${}S_{n} {}$ be the outcome of the *n*th sub-experiment.
	Since ${}P[A \cap B]= P[A|B]\times P[B]{}$
	${}P[s_{0} \cap s_{1} \cap _{2}] = P[s_{2}|s_{1} \cap s-] \times P[s_{1} \cap s_{0}] = P[s_{2}|s_{1} \cap s_{0}] \times P[s_{1}|s_{0}]\times P[s_{0}]{}$
- In this case, the urn we pick depends only upon the last sub experiment. This means ${}P[s_{2}|s_{1} \cap s_{0}]=P[s_{2}|s_{1}]{}$
- Thus: ${}P[s_{0} \cap s_{1} \cap _{2}]=P[s_{2}|s_{1}] \times P[s_{1}|s_{0}]\times P[s_{0}]{}$
#### More Generally: ${}P[S_{n}|S_{n-1}\cap\dots \cap s_{0}] = P[s_{n}|s_{n-1}]{}$
