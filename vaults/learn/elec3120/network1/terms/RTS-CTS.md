# RTS / CTS — Request To Send / Clear To Send

**What it is.** A two-frame handshake used by 802.11 (CSMA/CA) to reserve the
medium *before* sending data.

```text
1. sender   -> receiver : RTS   ("I want to send for this long")
2. receiver -> everyone : CTS   ("go ahead; everyone else be quiet")
3. sender   -> receiver : DATA
4. receiver -> everyone : ACK   ("received; the medium is free again")
```

**Why it exists: the hidden terminal problem.** Two nodes can both reach the
receiver but not each other, so carrier sense tells *both* that the medium is
idle and they collide **at the receiver**.

**Why CTS is the important half.** RTS is heard by nodes near the **sender**;
CTS is heard by nodes near the **receiver** — which are exactly the nodes that
would have collided. Between them the two frames cover both interference
neighbourhoods.

**The cost.** Two extra frames per data frame, plus latency. So real 802.11 uses
a size **threshold**: only large frames bother with RTS/CTS.

**What it does *not* fix.** The **exposed terminal** problem: a node that
overhears a nearby transmission defers even though its own receiver is out of
range, so capacity is wasted. RTS/CTS cannot help there.

**Where it appears:** [[16_Wireless]] Section 3

**Related:** [[terms/CSMA]] · [[terms/ACK]] · [[terms/BSS]]
