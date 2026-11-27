# Multiplication
## Master Theorem:
${}T(n)=aT\left( \frac{n}{b}\right) + f(n){}$

### If f(n) was a constant
![[05_Multiplication.pdf#page=19&selection=4,0,6,2|05_Multiplication, page 19]]

#### The lowest level will be reached when ${}\frac{n}{b^i}=1{}$
${}i = \log_{b}n{}$
${}n^{\log_{b}a}\times T(1){}$

![[05_Multiplication.pdf#page=21&selection=0,0,0,4|05_Multiplication, page 21]]

### Summary:
#### Given ${}T(n) = aT\left( \frac{n}{b} \right)+n{}$, Time Complexities:

| a > b                       | a = b                 | a < b           |
| --------------------------- | --------------------- | --------------- |
| ${}\Theta(n^{\log_{b}a}){}$ | ${}\Theta(n\log n){}$ | ${}\Theta(n){}$ |

## Matrix Multiplication

${}\Theta(n^3){}$ Default, but working to improve towards ${}n^2{}$

# Random

## Expectation: 

${}E[X] = \sum_{i}^{}i \cdot Pr[X=i]{}$

*Indicator random variables:* If *X* only takes 0 or 1, ${}E[X] = Pr[X=1]{}$

*Linearity of expectation:* Given two random variables *X* and *Y* (not necessarily independent), ${}E[X+Y]=E[X]+E[Y]{}$

*Remark:* ${}E[XY]=E[X]E[Y]{}$ only when X and Y are independent

## Hash Table with Chaining

*Hash function:* ${}h:U\to[m]{}$, where ${}[m]=\{ 0,1,2,\dots,m-1 \}{}$
*Hash table*:Create an array *T* of size *m*. When processing key *x*, access ${}T[h(x)]{}$
*Collision:* When h(x) = h(y) but ${}x\neq y{}$, then T[i] stores linked list of keys *x* with h(x) = i.

*Theorem:* For any x (exists or not), the expected number of keys colliding with x is ${}\leq \frac{n}{m}{}$.

### Example:
![[06_Random.pdf#page=7&selection=2,0,3,1|06_Random, page 7]]
${}E[X_{ij}=Pr[X_{ij}=1]=\frac{1}{n}{}$
${}X = \sum_{1\leq i<j\leq k}^{}X_{ij}{}$ be the number of pairs of people having the same birthday.
$$
E[X]=E\left[ \sum_{1\leq i<j\leq k}^{}X_{ij} \right]=\binom{k}{2}\left( \frac{1}{2} \right) = \frac{k(k-1)}{2n}
$$
So, when ${}\frac{\frac{k(k-1)}{2n}\geq(k-1)^2}{2n}\geq 1{}$ or ${}k\geq \sqrt{ 2n }+1 \approx 28{}$