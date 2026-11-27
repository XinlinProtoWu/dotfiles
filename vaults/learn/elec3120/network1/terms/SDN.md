# SDN — Software-Defined Networking

**What it is.** An architecture that pulls the **control plane** out of the
switches and puts it in a separate, centralised controller. Switches become simple
forwarders that obey rules they are given.

**Why it appears here.** It is the industrial-scale version of the data-plane /
control-plane split from [[15_Link_Layer]] Section 4: keep the fast path dumb and
hardware, make the decisions software.

**Where it appears:** [[15_Link_Layer]] Section 4 · [[16_Wireless]] Section 6

**Related:** [[terms/link-state]] · [[terms/DV]]
