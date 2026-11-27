# RIP — Routing Information Protocol

**What it is.** A concrete **distance vector** protocol. The metric is **hop
count**, and $\infty$ is fixed at **16** — so any usable path is at most 15 hops.

**Why the cap.** Count to infinity is bounded by the "infinity" value: a small
number makes recovery fast, but declares genuinely long paths unreachable. 15 is
the compromise that matched the Internet's practical diameter.

**Where it appears:** [[14_Distance_Vector]] Sections 1, 9 · [[15_Link_Layer]] Section 1

**Related:** [[terms/DV]] · [[terms/MAX_DIST]] · [[terms/link-state]]
