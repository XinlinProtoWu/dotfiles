# LAN — Local Area Network (and WLAN)

**What it is.** One network, under one administrative domain, spanning a room or
a building — as opposed to the Internet, which is a network of networks.

**Why the distinction matters.** *Inside* a LAN, delivery uses **flat** MAC
addresses and needs no routing: a switch floods unknown destinations and learns
where everyone is. *Between* LANs you need a router and a hierarchical IP
address. So the LAN boundary is exactly where the link layer stops and the
network layer begins.

**WLAN** = Wireless LAN (Wi-Fi / IEEE 802.11): the same idea over radio, which is
much harder because the medium cannot be fenced off — see
[[terms/CSMA]] and [[terms/RTS-CTS]].

**Where it appears:** [[13_LAN]] throughout · [[16_Wireless]] · [[16_Wireless]] Section 3

**Related:** [[terms/Ethernet]] · [[terms/MAC]] · [[terms/STP]] · [[terms/AP]]
