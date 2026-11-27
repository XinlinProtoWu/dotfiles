# IP — Internet Protocol (and IPv4)

**What it is.** The **network-layer** protocol of the Internet: a 32-bit address
(**IPv4**) plus best-effort, connectionless delivery of packets between hosts
anywhere on the planet.

**Why it exists.** The link layer only delivers within one LAN. IP provides a
*global, hierarchical* address — a **prefix** identifying the network and a
**suffix** identifying the host — so routers can carry one table entry per
network instead of one per host.

**Example.** `10.79.241.55` is a 32-bit number in four dotted octets:

```text
00001001 01001111 11110001 00110111
    9        79      241       55
```

A `/16` prefix keeps the first 16 bits as the network and the rest as the host.

**Sizes.** IPv4 = $2^{32} \approx 4.2$ billion addresses (hence the 1991 address
crisis → CIDR, NAT, IPv6). IPv6 = 128 bits.

**Where it appears:** [[13_LAN]] Sections 1, 4 · [[14_Distance_Vector]] Section 1 · [[16_Wireless]] Section 7

**Related:** [[terms/MAC]] · [[terms/ARP]] · [[terms/DHCP]] · [[terms/NAT]] · [[11_BGP]] · [[terms/TCP]]
