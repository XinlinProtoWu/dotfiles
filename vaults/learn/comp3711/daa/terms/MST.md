# Minimum spanning tree (MST)

**What it is.** For a connected undirected graph $G = (V,E)$ with weights $w(e)$, a subset
$T \subseteq E$ that is a tree spanning all vertices with $\sum_{e\in T} w(e)$ minimal. $T$ has
exactly $\lvert V\rvert - 1$ edges.

**Why it exists.** It is the cheapest way to connect everything — cables, pipelines, circuits —
and it is the canonical problem where a greedy algorithm is provably optimal, via the cut lemma.

**Example.** Deck's 9-node graph (edges $ab\,4$, $ah\,8$, $bc\,8$, $bh\,11$, $cd\,7$, $cf\,4$,
$ci\,2$, $de\,9$, $df\,14$, $ef\,10$, $hi\,7$, $hg\,1$, $ig\,6$, $gf\,2$) has MST weight
$1+2+2+4+4+7+8+9 = 37$. Because two edges weigh 8, there are **two** different MSTs — Prim's and
Kruskal's picks differ at $a$-vs-$b$ to $h$-vs-$c$.

**Where it appears:** [[lec_17_minimum_spanning_trees]] Sections 1–7

**Related:** [[terms/cut-property]] · [[terms/union-find]] · [[terms/priority-queue]] · [[terms/tree]] · [[terms/greedy-algorithm]]
