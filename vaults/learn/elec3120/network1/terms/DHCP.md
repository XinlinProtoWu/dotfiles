# DHCP — Dynamic Host Configuration Protocol

**What it is.** The protocol a host uses to **rent** an IP address, and to learn
the gateway and netmask it needs in order to use that address.

**Why it exists.** MAC addresses are burned in at the factory; IP addresses must
be assigned per network. Doing that by hand does not scale, and it breaks when a
laptop moves between networks.

**How it works.**

1. **DHCP DISCOVER** — client broadcasts "can I have an address, please?" to
   `FF:FF:FF:FF:FF:FF` (it has no address of its own yet, so it must broadcast).
2. **DHCP OFFER** — a server answers with an address.
3. Request + ACK complete the lease.

**The host also receives:**

```text
your IP      = 34.244.91.91
your gateway = 34.244.91.1
your netmask = 255.255.255.0   → "34.244.91.* is local; everything else goes to the gateway"
```

**Security note.** DHCP has **no authentication** — anyone on the LAN can answer.
The lecture's response to "isn't that insecure?" is simply "yes".

**Where it appears:** [[13_LAN]] Section 7 · [[16_Wireless]] Section 4.3

**Related:** [[terms/ARP]] · [[terms/IP]] · [[terms/LAN]] · [[terms/NAT]]
