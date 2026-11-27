## Analysis of Randomized Quicksort: Binary Tree

- Assume all elements are *distinct*, relabel everything from small to large as ${}z_{1},z_{2},\dots,z_{n}{}$. Measure the running time based on the *Average number* of comparisons performed.
- Create a *binary tree*, the root of the tree is first pivot. All items to the left(right) of the root will be in left(right) subtree
![[07_Quicksort.pdf#page=11&selection=2,0,2,4|07_Quicksort, page 11]]

#### Two items will only be compared if one was the ancestor of the other
-  Meaning: if ${}z_{i}{}$ is the first pivot chosen among ${}\{ z_{i},z_{i+1},\dots,z_{j} \}{}$
	- or, if ${}z_{j}{}$ is the first pivot chosen among ${}\{ z_{i},z_{i+1},\dots,z_{j} \}{}$

- Otherwise, if another element ${}z_{k}{}$ was chosen as a pivot, ${}z_{i}, z_{j}{}$ will not be compared as they will both go to different subtrees rooted at ${}z_{k}{}$

>[!TODO]
>![[07_Quicksort.pdf#page=13&selection=0,0,0,7|07_Quicksort, page 13]]
>Find out what this means

## Randomized Selection:

1. Choose a Pivot x from ${}A[l\dots r]{}$
2. Partition A at x
3. x will be the k = m - l + 1'th smallest item

```
If (i = k)
	X is the actual solution
	
If (i < k)
	i-th element of A[l...r] is the i-th element of A[l...m-1]
	Solve recursively

If (i > k)
		i-th elemen tof A[l...r] is the j = (i - k)-th element of A[m+1...n].
	Solve recursively
```

### Pseudo code:
```
Select(A, l, r, i):
if l = r then return A[l]
randomly choose an element in A[l...r] as pivot and swap it with A[r]
m <- Partition(A,l,r) //Pivot position in A[p..r] after partition
k <- m-l+1 //Relative position of pivot in A[p..r]
if i = k then return A[l]
else if i < k then return Select(A, l, m-1, i)
else return Select(A, m+1, r, i-k)

First call: Select(A,1,n,i)
```

### Analysis of randomized selection:

- If pivot ${}x{}$ fallse within the 25%-75% range, then either everything below 25% or above 75% gets thrown away, then we say it is a good pivot.,
	- Pr[good pivot] = ${}\frac{1}{2}{}$
	- Each good pivot reduces size of array by at least ${}\frac{1}{4}{}$

#### The expected running time of randomized selection is ${}\Theta(n){}$
- After i good pivots, total # of items left to process is ${}\leq \left( \frac{3}{4} \right)^{i}n{}$ (throwing away 1/4 of remaining items i times)
- Let ${}Y_{i}={}$ the running time of ${}i^{th}{}$ stage
- ${}X_{i}={}$ #${}_{i}{}$ of pivots (recursive calls) in i-th stage
- ${}Y_{i}\leq X_{i}\left( \frac{3}{4} \right)^{i}n{}$
- ${}E[X_{i}] = 2(waitingTime){}$ so ${}E[Y_{i}] \leq E\left[ X_{i}\left( \frac{3}{4} \right)^{i}n \right]=2\left( \frac{3}{4} \right)^{i}n{}$
- So, waiting time is ${}O(n){}$

>[!TODO]
>EXPECTATION? why is it 2x waiting time

### D&C sorting and selecting

```
Search(A1, A2, start1, end1, start2, end2, k):
if (k = 1) then return min(A1[1], A2[1])

if (A1[start1+k/2-1] < A2[start2 + k/2-1]):
	Elmininate the first k/2 elements of A1
	return Search(A1, A2, start1+k/2, end1, start2, end2, k/2)
	
else if (A1[start1+k/2 -1] >= A2[start2 + k/2 -1]):
	Elmininate the first k/2 elements of A2
	return Search(A1, A2, start1, end1, start2+k/2, end2, k/2)

```
- Cost: ${}\Theta(\log k){}$
>[!TODO]
>Again. WTF does this mean

