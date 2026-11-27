# Weighted external path length

**What it is.** For a binary tree with leaves $a_1,\dots,a_n$ carrying weights $f(a_i)$ and depth
$d(a_i)$, the quantity $B(T) = \sum_i f(a_i)d(a_i)$. For a prefix code it is the total encoded
length (in bits); for a merge tree it is the total comparison count.

**Why it exists.** It converts "find the cheapest code" into "find the cheapest tree", which is
what lets a greedy algorithm operate on trees at all. It also gives the two identities used in the
optimality proofs: swapping leaves changes $B$ by
$(f(x)-f(b))(d(b)-d(x))$, and merging two sibling leaves changes it by exactly $f(x)+f(y)$.

**Example.** Frequencies $a{=}45, b{=}13, c{=}12, d{=}16, e{=}9, f{=}5$: a fixed-length tree has
$B(T) = (45+13+12+16+9+5)\cdot 3 = 300$, the Huffman tree has
$45\cdot1 + (13+12+16)\cdot3 + (9+5)\cdot4 = 224$.

**Where it appears:** [[lec_10-11_greedy]] Sections 11, 13, 14

**Related:** [[terms/huffman-coding]] · [[terms/prefix-code]]
