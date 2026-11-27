## Expected Value of randos:

- ${}m_{X} = E[X] = \sum_{x \in S_{X}}^{}xp_{x}(x)=\sum_{k}^{}x_{k}p_{X}(x_{k}){}$
- The expected value is defined if the sum above converges absolutely

>[!Todo]
>Why do we take the abs of ${}x_{k}{}$

- *If we view ${}p_{x}(x){}$ as distribution of mass on the points ${}x_{1},x_{2},x_{3},\dots{}$ then expected value is the center of mass of the distribution*

---

## Relative Frequency Interpretation

**The big idea:** ${}E[X]{}$ is the *long-run average* of ${}X{}$ — repeat the experiment many times, record the value of ${}X{}$ each time, and average the numbers you got.

### 1. Relative frequency
Run the experiment ${}n{}$ times. Define:
- ${}x(j)={}$ value of ${}X{}$ on the ${}j{}$-th trial
- ${}N_{k}(n)={}$ number of trials in which the value ${}x_{k}{}$ was observed

The **relative frequency** of value ${}x_{k}{}$ is the proportion of trials that produced it:

$$f_{k}(n) = \frac{N_{k}(n)}{n}$$

It is just "count ÷ total", so ${}0 \le f_k(n) \le 1{}$ and ${}\sum_k f_k(n) = 1{}$.

### 2. The same average, computed two ways
The sample average of the ${}n{}$ observations is:

$$\bar{X}_n = \frac{x(1) + x(2) + \dots + x(n)}{n}$$

**Way 1 — in order:** add the observations as they come, then divide by ${}n{}$.

**Way 2 — grouped:** add up "value × number of times that value happened", then divide by ${}n{}$:

$$\bar{X}_n = \frac{x_1 N_1(n) + x_2 N_2(n) + \dots}{n} = x_1\frac{N_1(n)}{n} + x_2\frac{N_2(n)}{n} + \dots = \sum_k x_k f_k(n)$$

Both give exactly the same number. Way 2 just reorganizes the sum by value.

### 3. Relative frequency → probability
As ${}n{}$ grows, each relative frequency settles down to the true probability of that value:

$$\lim_{n\to\infty} f_k(n) = p_X(x_k)$$

This is the relative-frequency interpretation of probability itself: a probability is the limiting proportion of times an outcome occurs.

### 4. Conclusion
$$\bar{X}_n = \sum_k x_k f_k(n) \;\xrightarrow{\,n\to\infty\,}\; \sum_k x_k p_X(x_k) = E[X]$$

So ${}E[X]{}$ is the **long-run average** of ${}X{}$.

### Worked example: 3 fair coin tosses, ${}X ={}$ number of heads
Suppose we actually perform the experiment 8 times:

| Trial ${}j{}$ | Outcome | ${}x(j){}$ |
|---|---|---|
| 1 | TTH | 1 |
| 2 | HHH | 3 |
| 3 | HTT | 1 |
| 4 | THH | 2 |
| 5 | TTT | 0 |
| 6 | HTH | 2 |
| 7 | HHT | 2 |
| 8 | THT | 1 |

**Way 1 (in order):**
$$\bar{X}_8 = \frac{1+3+1+2+0+2+2+1}{8} = \frac{12}{8} = 1.5$$

**Way 2 (grouped):**

| Value ${}x_k{}$ | Count ${}N_k{}$ | Relative frequency ${}f_k = N_k/n{}$ |
|---|---|---|
| 0 | 1 | ${}1/8{}$ |
| 1 | 3 | ${}3/8{}$ |
| 2 | 3 | ${}3/8{}$ |
| 3 | 1 | ${}1/8{}$ |

$$\bar{X}_8 = 0\cdot\tfrac18 + 1\cdot\tfrac38 + 2\cdot\tfrac38 + 3\cdot\tfrac18 = \frac{12}{8} = 1.5$$

Here the relative frequencies happen to equal the pmf exactly (a small-sample coincidence). In general they only *approach* it as ${}n\to\infty{}$, giving ${}E[X] = 1.5{}$.

>[!note] Key insight
>- ${}E[X] = 1.5{}$ even though you can **never** observe 1.5 heads. The expected value is an average, not a "most likely" or "possible" value.
>- ${}f_{k}(n){}$ is how often ${}x_{k}{}$ was observed. When this drags to infinity, the result **converges towards the probability**.

## Expected Value of Functions of a RV

- ${}Z = g(X){}$
- ${}E[Z] = \sum_{k}^{}z_{k}p_{Z}(z_{k}){}$
- ${}p_{Z}(z_{j})=\sum_{x_{k}:g(x_{k})=z_{j}}p_{x}(x_{k})^{}{}$
#### ${}E[Z] = E[g(X)] = \sum_{k}^{}g(x_{k})p_{X}(x_{k}){}$

![[Part2.pdf#page=43&selection=4,0,4,7|Part2, page 43]]
## Variance:

- A measure of how much the values of random variable generally differ from the mean
- *D:* difference between value of random variable and its mean ${}D = X- E[X]{}$
- *Variance* (often denoted as ${}s^2{}$) is defined as the expected value of the squared difference
	- ${}VAR[X] = E[D^2] = E[(X-E[X])^2]{}$
- *Standard Deviation* is square root of the variance
	- ${}STD[X] = \sqrt{ VAR[X] }{}$
	- STD has the same units as X.

### Useful formula:
- #### ${}VAR[X] = E[X^2]-(E[X])^2{}$
- ${}VAR[c] = 0{}$
- ${}VAR[X + c] = VAR[X]{}$
- ${}VAR[cX] = c^2VAR[X]{}$

## Moments of a random variable

- Constants that summarize different information about the *pmf*.
- Under some conditions, **knowing all the moments is equivalent to knowing the pmf**
- the *${}n^{th}{}$ moment* of a random variable X is defined as ${}E[X^n]=\sum_{k}^{}x_{k}^np_{X}(x_{k}){}$
- the *${}n^{th}{}$ central moment* of a random variable X is defined as ${}E[(X-E[X])^n]=\sum_{k}^{}(x_{k}-E[X])^np_{X}(x_{k}){}$

### Important:
- *Mean*: ${}1^{st}{}$ moment, ${}E[X]{}$
- *Variance*: ${}2^{nd}{}$ central moment, ${}E[(X-E[X])^2]{}$

${}E[X] = \frac{1}{8} \times 0 + \frac{3}{8}\times 1+\frac{3}{8}\times 2+\frac{1}{8}\times 3{}$
${}E[X^2]=\sum_{k}^{}x_{k}^2p_{X}(x_{k}){}$
${}=\frac{3}{8}+4\times \frac{3}{8}+\frac{9}{8}{}$
