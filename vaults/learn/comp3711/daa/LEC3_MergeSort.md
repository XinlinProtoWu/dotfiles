[[03_Mergesort.pdf#page=2&selection=0,8,0,14|Tower of Hanoi]]
```
moveTower(n, peg1, peg2, peg3):
if n=1 then
	move the only disc from peg1 to peg3
	 return
else
	moveTower(n-1, peg1, peg3, peg2)
	 move the only disc from peg1 to peg3
	 moveTower(n-1, peg2, peg1, peg3)
```
**STEPS towards recursion**
- Write a base f(1) case
- Assume f(n-1) works
- Show f(n) works with f(n-1)

```
moveTower(n, start, aux, target){
	if n=1 then
		move from start to target
	else
		moveTower(n-1, start, target, aux)
		move from start to target
		moveTower(n-1, aux, start, target)
}
```

**T(n) be the number of steps needed for n discs**
	- move n-1: *T(n-1)*
	- move 1: *1*
	- move n-1: *T(n-1*
**T(n) = 2T (n-1) + 1, n>1**
**T(1) = 1**

Solve:
T(n) = 2 *T(n-1)* + 1
	 = 2 (2 *T(n-2)* + 1) + 1
	 = 2 (2 (2 *T(n-3)* + 1) + 1) + 1
	 ...
	 = 2<sup>i</sup> T(n-i) + 2<sup>i-1</sup> ... + 2 + 1
	where i = n -1
*Geometric series:* T(n) = 2<sup>n-1</sup>T(1) + 2<sup>n-2</sup> + ... + 2 + 1 = **2<sup>n</sup> - 1**

**Mergesort**
- [[03_Mergesort.pdf#page=6&selection=0,0,0,9|03_Mergesort, page 6]]
```
Mergesort(A, l, r):

	if l = r then return
	m <- ((l+r)/2)
	Mergesort(A, l, m)
	Mergesort(A, m+1, r)
	Merge(A, l, m, r)
	
Merge (A, l, m, r):

	L <- A[l...m]
	R <- A[m+1...r]
	ldx <- 1
	rdx <- 1
	for k <- l to r:
		if ldx = L.size() && rdx != R.size() then
			A[k] <- R[rdx]
			rdx <- rdx+1
		else if rdx = R.size() && ldx != L.size() then
			A[k] <- L[ldx]
			ldx <- ldx+1
		else if L[ldx] <= R[rdx] then
			A[k] = L[ldx]
			ldx <- ldx+1
		else
			A[k] <- R[rdx]
			rdx <- rdx+1 

```
*Mergesort runs in time ${}\theta{}$(n log n)*

