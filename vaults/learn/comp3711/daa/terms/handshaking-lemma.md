# Handshaking lemma

**What it is.** In any undirected graph, $\sum_{v \in V} \deg(v) = 2\lvert E\rvert$; consequently
the number of vertices of **odd** degree is even. For directed graphs,
$\sum_v \deg_{out}(v) = \sum_v \deg_{in}(v) = \lvert E\rvert$.

**Why it exists.** It is the only counting tool available before any algorithm, and it settles
parity questions in one line — "can all degrees be odd?", "what can the missing degree be?",
"do these handshakes add up?".

**Example.** If every vertex has degree 3 then $3\lvert V\rvert = 2\lvert E\rvert$, so
$\lvert V\rvert$ is even. At a party, the number of guests who shook an odd number of hands is
even: model guests as vertices and handshakes as edges.

**Where it appears:** [[lec_15_graph_theory]] Section 3

**Related:** [[terms/graph]] · [[terms/tree]]
