# AP — access point

**What it is.** The **base station** of a wireless LAN: the bridge between the
radio side (802.11 frames) and the wired side (Ethernet frames).

**Why it matters.** An AP is a *link-layer* device that rewrites headers, not a
router: it strips the 802.11 header and re-wraps the payload in Ethernet. The IP
packet inside never changes — the same per-hop rewriting as
[[terms/MAC]] destinations in a wired LAN.

**Example.** Your phone sends a Wi-Fi frame with `addr1 = AP`, `addr2 = phone`,
`addr3 = router`. The AP re-wraps it as an Ethernet frame with
source = the AP's MAC, destination = the router's MAC.

**Where it appears:** [[16_Wireless]] Sections 4.1, 4.5 · [[16_Wireless]] Section 4.7

**Related:** [[terms/BSS]] · [[terms/IEEE80211]] · [[terms/LAN]]
