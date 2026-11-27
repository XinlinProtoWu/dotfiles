# Palindrome (substring vs subsequence)

**What it is.** A string that reads the same forwards and backwards (`radar`, `ACCA`). Two different
DP problems hide under the name:

| | State | Recurrence | Cost |
|---|---|---|---|
| palindromic **substring** (contiguous) | $p[i,j]$ = is $X[i..j]$ a palindrome? | true iff $x_i = x_j$ **and** $p[i+1,j-1]$ | $O(n^2)$ |
| palindromic **subsequence** (may skip) | $dp[i,j]$ = longest length | $dp[i+1,j-1]+2$ if $x_i = x_j$, else $\max(dp[i+1,j], dp[i,j-1])$ | $O(n^2)$ |

**Why it exists.** The two differ by one clause — whether a mismatch is fatal — yet one is a
predicate and the other a maximisation, and swapping the recurrences is the classic error. The
predicate version is also the cleanest first example of a diagonal fill.

**Example.** `BABBCCCB` has $p[4,8]$ true (`BCCCB`, length 5); `ACBBCABA` has a palindromic
subsequence of length 6 (`ACBBCA`) even though its longest palindromic substring is only `BB`/`CCC`.

**Warning.** Longest common *subsequence* with $\text{rev}(X)$ gives the right palindromic
subsequence **length** but not necessarily a palindrome; for substrings the trick is simply wrong
(`abcdba`: true answer 1, LCS-with-reverse answer 2).

**Where it appears:** [[lec_14_dp_over_intervals]] Sections 1–4

**Related:** [[terms/interval-dp]] · [[terms/LCS]] · [[terms/longest-common-substring]]
