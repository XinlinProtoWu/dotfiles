## Maximum Subarray
![[04_Subarray.pdf#page=2&selection=47,0,47,5|04_Subarray, page 2]]

#### Stirling's Approximation:
${}\log(n!) = n\log n - n + \Theta(n\log n){}$
### Brute Force:

*Idea:* Calculate V(i, j), for each i<=j and return the max value

```
Vmax <- A[1]
for i<-1 to n do
	for j<-i to n do 
		// Calculate V(i, j)
		V<-0
		for k<-i to j do
			V<-V + A[k]
		if V>Vmax then Vmax<-V
return Vmax
```

Running Time ${}\Theta(n^3){}$

### Data Reuse:

*Idea:*
- Don't need to calculate aeach V(i, j) from scratch.
- Exploit the fact: V(i,j) = V(i, j - 1) + A[j]

```
Vmax <- A[1]
for i<-1 to n do
	V<-0
	for j<-i to n do
		//Calc V(i,j)
		V<-V + A[j]
		if V > Vmax then Vmax <- V;
return Vmax
```

### Divide and Conquer:

*Idea:*
- Cut in half
- Case 1: Entirely in the first half
- Case 2: Entirely in the second half
- Case 3: crosses the cut
- Largest of the three cases is final solution

```
MaxSubarray(A,l,r):
if l=r then return A[l]
m <- [(l+r)/2)]
M1 <- MaxSubarray(A,l,m)
M2 <- MaxSubarray(A,m+1,r)
Lm <- -infinity, Rm <- -infinity
V <- 0
// Find the biggest value on the left side
for i <- m downto l
	V <- V + A[i]
	if V > Lm then Lm <- V
V <- 0
// Find the biggest value on the right side
for i <- m + 1 to r
	V <- V + A[i]
	if V > Rm then Rm <- V
return max(M1, M2, Lm + Rm)
```

#### Summary of this method:
- *GIST:* Find the largest value each array  can produce
	- Split into two subarrays, Left and Right, calculate their largest value respectively
	- Run through the entire array once to find the largest values on the left and right side
	- Compare the cross bridge case and the left and right side
### Kadane's Linear-Time:

```
Vmax <- -infinity, V <- 0
for i <- 1 to n do
	V <- max(V+A[i], A[i])
	if V>Vmax then Vmax <- V
return Vmax
```
#### Besides the Vmax, also find a way to record the indices of start and end:
```
Vmax <- -inifinity
V <- 0
start <- 1
beststart <- 1
bestend <- 1

for i <- 1 to n do
	if V + A[i] < A[i] do
		V <- A[i]
		start <- i
	else 
		V <- V+A[i]
	
	if V > Vmax do
		Vmax <- V
		beststart <- start
		bestend <- i
return Vmax, beststart, bestend
```

### Maximizing Stock Profits

![[04_Subarray.pdf#page=11&selection=8,0,8,3|04_Subarray, page 11]]
- Let m = ((l+r)/2)
- maximize a case 3 p[j] - p[i]
	- find smallest p[i] in p[l, m]
	- find largest p[j] in p[m+1, n]
Such i, j can be found in O(n) time.
- O(n) to find smallest p[i]
- O(n) to find largest p[j]

#### Method 2:
compute the difference from A[i] to A[i+1], get a new array of differences instead, and do exactly the largest sub-array question

```
MaxProfit(a, l, r):
// Base case
if l = r then return a[l]

m <- ((l+r)/2)
M1 <- MaxProfit(a, l ,m)
M2 <- MaxProfit(a, m+1, r)

Lm <- -inf
Rm <- -inf

V <- 0
for i <- m downto l
	V <- V + a[i]
	if V > Lm then Lm <- V

V <- 0
for i <-m+1 to r
	V <- V + a[i]
	if V > Rm then Rm <- V	
return max(M1, M2, Rm+Lm)
```
## Integer and Matrix Multiplicatoin

*Brute force:* ${}\Theta(n^2){}$ multiplications ${}+ \Theta(n^2){}$ additions

### Divide and conquer:
- *Rewrite* ${}a = 2^{n/2}a_{1} + a_{0}, b=2^{n/2}b_{1}+b_{0}{}$
- E.g.: a = 1010*0011*, b = 0110*0001* (n=8)
- ${}a_{1}=1010, a_{0}=0011{}$
- ${}b_{1}=0110, b_{0}=0001{}$

${}a \times b = (2^{n/2}a_{1}+a_{0})\times(2^{n/2}b_{1}+b_{0}){}$

```
Multiply(A,B):
n <- size of A
if n=1 then return A[1] * B[1]
mid <- [n/2]
U <- Multiply(A[mid+1...n], B[mid+1...n]) // a1b1
V <- Multiply(A[mid+1..n], B[1...mid]) // a1b0
W <- Multiply(A[1...mid], B[mid+1...n]) // a0b1
Z <- Multiply(A[1...mid], B[1...mid]) // a0b0
M[1...2n] <- 0
M[1...n] <- Z // a0b0
M[mid+1..] <- M[mid+1..]O+V O+W // + (a1b0 + a0b1) << n/2
M[2mid + 1..] <- M[2mid + 1...] O+U // +a1b1 << n
```
---
> [!Time Analysis]
---
>#### Expansion Method:
>${}T(n) = 2T\left( \frac{n}{2} \right)+n{}$
>${}T(n) = 2 \cdot \left( 2T\left( \frac{n}{4} \right)+\frac{n}{2} \right)+n{}$
>${}T(n) = 2\cdot\left( 2\cdot\left( 2T\left( \frac{n}{8} \right)+\frac{n}{4} \right)+\frac{n}{2} \right)+n{}$
>${}\dots{}$
>${}T(n)=2^kT\left( \frac{n}{2^k} \right)+kn{}$
>Do this expansion until base case ${}\frac{n}{2^k}=1{}$
>${}2^k=n{}$
>${}\log_{2}n = k{}$
>Sub back in
>${}T(n) = 2^{\log_{2}n}T(1)+n\log_{2}n{}$
>${}T(n)=nT(1)+n\log_{2}n{}$
>##### Therefore: ${}T(n) = \Theta(n)+\Theta(n\log n) = \Theta(n\log n){}$
---
>#### Tree Method:
>                         n
>                   cost = n
>                  /       \
>               n/2       n/2           Notice how each level sums up to n cost
>              n/2        n/2
>             /   \       /   \
>           n/4  n/4    n/4  n/4
>           ...
> *Until all the ${}n/2^k = 1{}$*
>- In this case, there are ${}k = \log_{2}n{}$ levels
>- Each level has a cost of n
>- ${}T(n) = n\log_{2}n{}$
>- ${}T(n) = \Theta(n\log n){}$
### Karatsuba Multiplication
- Let ${}a = 2^{n/2}a_{1}+ a_{0}, b= 2^{n/2}b_{1}+b_{0}{}$
- ![[05_Multiplication.pdf#page=12&selection=67,0,67,2|05_Multiplication, page 12]]
- ${}a_{1}b_{0} + a_{0}b_{1} = (a_{1}+a_{0})(b_{1}+b_{0})-a_{1}b_{1}-a_{0}b_{0}{}$
