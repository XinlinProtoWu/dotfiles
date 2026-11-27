# Golden ratio ($\varphi$)

**What it is.** $\varphi = (1+\sqrt{5})/2 \approx 1.618$, the growth factor of the Fibonacci
numbers: $F(n) = \Theta(\varphi^n)$.

**Why it exists.** It is the standard way this course quotes the cost of a *doubly recursive*
algorithm without a table: any recursion of the form $T(n) = T(n-1) + T(n-2) + \Theta(1)$ grows
like $\varphi^n$, i.e. exponentially, with no polynomial bound at all.

**Example.** The naive Fibonacci/staircase recursion makes $204{,}668{,}309$ calls at $n = 40$,
while $\varphi^{40}/\sqrt{5} \approx 1.65\times10^{8}$ matches $F(40) = 165{,}580{,}141$. The
message is not the constant but the base: exponential in $n$.

**Where it appears:** [[lec_12_dynamic_programming]] Section 1

**Related:** [[terms/dynamic-programming]] · [[terms/memoization]] · [[terms/big-O]]
