# ARP — Address Resolution Protocol

**What it is.** The protocol that maps an **IP address to a MAC address** on the
local network.

**Why it exists.** You know the destination's IP address, but Ethernet can only
deliver to a MAC address. Something has to answer "which hardware address owns
this IP?".

**How it works.**

1. Broadcast to `FF:FF:FF:FF:FF:FF`: "who has `34.244.91.1`?"
2. The owner replies **unicast**: "I do — my MAC is `ab:cd:ef:12:34:56`."
3. The asker caches the answer for a while.

**Example.** Every time your laptop sends a packet to its gateway, it needs the
gateway's MAC. It asks once, caches it, and reuses the answer.

**Memory hook.** ARP is the networking equivalent of asking for someone's phone
number: you cannot derive it, you have to ask.

**Where it appears:** [[13_LAN]] Section 5 · [[14_Distance_Vector]] Section 1

**Related:** [[terms/MAC]] · [[terms/IP]] · [[terms/DHCP]] · [[terms/Ethernet]]
