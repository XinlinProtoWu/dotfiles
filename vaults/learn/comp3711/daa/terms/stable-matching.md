# Stable matching

**What it is.** Given $n$ men and $n$ women with complete strict preference lists, a **perfect
matching** pairs everyone once. It is **stable** if there is no unmatched pair $m$–$w$ such that
$m$ prefers $w$ to his partner and $w$ prefers $m$ to her partner. Such a pair is a blocking pair.

**Why it exists.** It models two-sided assignment where participants can defect: residency
matching, school admission, JUPAS, ad auctions. A perfect matching is easy; a stable one is not
obvious, and Gale–Shapley proves one always exists for a bipartite instance.

**Example.** With lists $X:A,B,C$; $Y:B,A,C$; $Z:A,B,C$ and $A:Y,X,Z$; $B:X,Y,Z$; $C:X,Y,Z$, the
matching $X\text{–}A$, $Y\text{–}B$, $Z\text{–}C$ is stable, and so is
$X\text{–}B$, $Y\text{–}A$, $Z\text{–}C$.

**Where it appears:** [[lec_20_stable_matching]] Sections 1–2, 10

**Related:** [[terms/Gale-Shapley]] · [[terms/bipartite]] · [[terms/bipartite-matching]]
