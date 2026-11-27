# Huffman coding (and optimal 2-way merge)

**What it is.** Build an optimal prefix code from character frequencies: put all characters in a
min-priority queue keyed by frequency, and repeat $n-1$ times — extract the two smallest, make them
siblings under a new node whose frequency is their sum, insert it back. The final queue element is
the root. $O(n\log n)$.

**Why it exists.** It is *the* greedy algorithm where the greedy choice operates on a
**structure**, not a sequence: the two rarest characters become the deepest sibling pair, and that
choice can be proved optimal (full-tree lemma → swap lemma → deepest-siblings lemma → merge
identity → induction). The same algorithm solves **optimal 2-way merge**, where merging lists of
sizes $a,b$ costs $a+b$ comparisons: merge the two smallest repeatedly.

**Example.** Frequencies $f{=}5, e{=}9, c{=}12, b{=}13, d{=}16, a{=}45$ merge as
$5{+}9{=}14$, $12{+}13{=}25$, $14{+}16{=}30$, $25{+}30{=}55$, $45{+}55{=}100$, giving
$a{=}0$, $c{=}100$, $b{=}101$, $d{=}111$, $f{=}1100$, $e{=}1101$ and cost 224 instead of 300.
Merge sizes 30, 20, 10: smallest-two-first costs 30 then 60, total 90; largest-first costs 110.

**Where it appears:** [[lec_10-11_greedy]] Sections 12, 13, 14

**Related:** [[terms/prefix-code]] · [[terms/weighted-external-path-length]] · [[terms/priority-queue]] · [[terms/greedy-algorithm]]
