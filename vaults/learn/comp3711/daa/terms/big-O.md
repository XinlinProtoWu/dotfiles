# Asymptotic notation ($O$, $\Theta$, $\Omega$)

**What it is.** $O$ is an upper bound, $\Omega$ a lower bound, $\Theta$ both, each up to constant
factors and for large $n$. $o$ is a strict upper bound. Written
$T(n) = O(f(n))$ when $T(n) \le c f(n)$ for some $c$ and all large $n$.

**Why it exists.** It hides hardware constants so that algorithms can be compared on the thing that
matters — growth — and it makes recurrences summarisable as a single term.

**Example.** $\lvert E\rvert \le \lvert V\rvert^2$, so $\log\lvert E\rvert = O(\log\lvert V\rvert)$;
therefore Prim's $O(\lvert E\rvert\log\lvert E\rvert)$ duplicate-insertion version is
$O(\lvert E\rvert\log\lvert V\rvert)$, the same order as the `Decrease-Key` version. And
$\Theta(\varphi^n)$ for naive Fibonacci is exponential, i.e. not $O(n^k)$ for any $k$.

**Where it appears:** [[lec_17_minimum_spanning_trees]] Section 1 · [[lec_12_dynamic_programming]] Section 1 · every note's cost lines

**Related:** [[terms/golden-ratio]] · [[terms/MST]]
