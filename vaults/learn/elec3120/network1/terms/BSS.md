# BSS — Basic Service Set (and SSID)

**What it is.** One **cell** of a Wi-Fi network: one access point plus the
wireless hosts associated with it. Also called a BSS.

**SSID** (*Service Set Identifier*) is the network's human-readable name, carried
in **beacon frames**. Hosts scan channels, listen for beacons, and pick which BSS
to *associate* with.

**Modes.**

| Mode | Structure |
|---|---|
| **Infrastructure** | hosts talk *via* the AP |
| **Ad hoc** | hosts talk directly, no AP |

**Why it matters.** Association is a **link-layer** event; the host still needs
[[terms/DHCP]] afterwards to get an [[terms/IP]] address. Moving between two BSSes
in the *same* subnet needs nothing else — the switch just re-learns the host's
port, so the IP address stays valid.

**Where it appears:** [[16_Wireless]] Sections 4.1, 4.3, 4.6

**Related:** [[terms/AP]] · [[terms/IEEE80211]] · [[terms/DHCP]]
