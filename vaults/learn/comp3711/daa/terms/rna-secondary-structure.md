# RNA secondary structure

**What it is.** A set of base pairs on a strand $b_1 \dots b_n$ that is (i) Watson–Crick (A–U, C–G),
(ii) free of sharp turns ($(b_i,b_j)$ needs $i < j-4$), and (iii) non-crossing
(no $i < k < j < l$). Maximising the number of pairs is the standard proxy for minimum free
energy. DP: $M[i,j] = \max\bigl(M[i,j-1],\, \max_k\{1 + M[i,k-1] + M[k+1,j-1]\}\bigr)$ over
complementary $k$ with $i \le k \le j-5$, and $M[i,j] = 0$ when $i \ge j-4$; $O(n^3)$.

**Why it exists.** It is the case where the **non-crossing constraint is what makes DP possible**:
removing a pair $(k,j)$ leaves two independent intervals, and crossing pairs would leave three
interleaved pieces that no two-index state can describe.

**Example.** $B = $ `AUGUGGCCAU`: optimum 3 pairs, nested — (1,10) A–U, (2,9) U–A, (3,8) G–C.

**Where it appears:** [[lec_14_dp_over_intervals]] Section 10

**Related:** [[terms/interval-dp]] · [[terms/dynamic-programming]]
