# Edit distance

**What it is.** The minimum number of insertions, deletions and substitutions turning $s$ into
$t$. With $\text{edit}[i,j]$ for the prefixes:
$\text{edit}[i,j] = \min(1+\text{edit}[i,j-1],\, 1+\text{edit}[i-1,j],\, I[s_i \ne t_j] + \text{edit}[i-1,j-1])$,
base cases $\text{edit}[0,j] = j$ and $\text{edit}[i,0] = i$.

**Why it exists.** It is the smallest DP whose recurrence has three genuinely different branches,
one per edit operation, and it is the standard test of whether you can translate "an operation"
into "a transition".

**Example.** $s = $ `abode`, $t = $ `blog`: delete `a`, insert `l`, delete `d`, substitute
`e`→`g` gives 4, and the DP table's corner cell is 4. With insert/delete only, the distance
would be $m + n - 2\cdot\text{LCS}(s,t) = 5$.

**Where it appears:** [[lec_13_2d_dynamic_programming]] Section 9

**Related:** [[terms/LCS]] · [[terms/dynamic-programming]]
