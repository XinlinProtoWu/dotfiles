
## Decision tree model for searching
![[09_Linearsort.pdf#page=3&selection=0,0,0,3|09_Linearsort, page 3]]

- Any algo for finding location of a given element in a sorted array of size *n* must have running time ${}\Omega (\log n){}$ in the decision tree model.
	- Proof:
		- The algo must have at least ${}n+1{}$ outputs, one for each element and one to report search failures
		- The decision tree has at least ${}n+1{}$ leaves
		- Any binary tree with ${}n + 1{}$ leaves must have height ${}\Omega(\log(n+1)) = \Omega(\log n){}$
- *Height* of a decision tree is the *worst case* running time
	-  A binary tree with N leaves must have **height** ${}\geq \log n{}$
	- Meaning, any algo for finding location of a given element in a sorted array of size *n* must have running time ${}\Omega(\log n){}$

## Decision tree for sorting

![[09_Linearsort.pdf#page=9&selection=0,0,0,3|09_Linearsort, page 9]]

- Any algo for sorting *n* elements must have running time ${}\Omega(n\log n){}$ in the decision-tree model
	- A sorting algo has a least ${}n!{}$ different outputs (one for each possible permutation on n items) 
	- The height of the decision tree is at least ${}\log(n!) = \Omega(n\log n){}$

## Linear time sorting:

- Notice how all comparison based sorting has lower bound ${}n\log n{}$
- To achieve linear time, no comparisons can be used

### Counting sort:
```
Input: A[1...n] each is integer in range {0, 1, ... k}
Output: B[1...n] sorted
CountingSort(A, B):
	let C[0...k] be a new array
	for i <- 0 to k
		C[i] <- 0
	for j <- 1 to n
		C[A[j]] <- C[A[j]] + 1
		// C[i] now contains number of i's
	for i <- 1 to k
		C[i] <- C[i] + C[i - 1]
		// C[i] now contains the number of elements <= i
	for j <- n downto 1
		B[C[A[j]]] <- A[j]
		C[A[j]] <- C[A[j]] -1 // C[A[j]] actually refers to the index of the element in the sorted array
```
## Radix sort
- Sorts integers by *digits*
	- From *least significant digit* to *most significant digit*

```
RadixSort(A, d): 
// A[1...n] is the array to sort 
// d is the maximum number of digits among all elements 
exp <- 1 
for i <- 1 to d 
	CountingSortByDigit(A, exp) 
	exp <- exp * 10
	

CountingSort(A, exp):
	n <- A.size()
	let B[1...n] be a new array
	let C[0...9] be a new array
	for i <- 0 to 9
		C[i] <- 0
	for j <- 1 to n
		digit <- (A[j]/exp) mod 10
		C[digit] <- C[digit] + 1
	for i <- 1 to 9
		C[i] <- C[i] + C[i - 1]
	for j <- n do1wnto 1
		digit <- (A[j]/exp) mod 10
		B[C[digit]] <- A[j]
		C[digit] <- C[digit] -1 
	for i <- 1 to n
		A[i] <- B[i] // Copy it back for next digit iteration
```