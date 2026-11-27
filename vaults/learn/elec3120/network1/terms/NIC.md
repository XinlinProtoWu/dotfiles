# NIC — network interface card

**What it is.** The hardware (chip, port, radio) that attaches a host to a
network and carries its MAC address.

**Why it matters here.** One NIC = one MAC address. A laptop with Wi-Fi,
Ethernet and Bluetooth has three NICs and therefore three MAC addresses. This is
why "the MAC address of a device" is ambiguous — it is per interface, not per
device.

**Practical consequence.** Put a NIC into **promiscuous mode** and it accepts
frames not addressed to it. On a shared medium (classic Ethernet, Wi-Fi) that
means you can read everyone's traffic. Use it for debugging, not for evil.

**Where it appears:** [[13_LAN]] Section 8

**Related:** [[terms/MAC]] · [[terms/Ethernet]]
