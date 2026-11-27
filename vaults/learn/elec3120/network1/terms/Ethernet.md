# Ethernet and its frame

**What it is.** The dominant wired link-layer technology. It carries a **frame**
(never "package"): a preamble, a start delimiter, two MAC addresses, a type
field, a payload, and a checksum.

| Field | Size | Job |
|---|---|---|
| Preamble | 7 B | `10101010` repeated — synchronises the receiver's clock |
| **SFD** (Start Frame Delimiter) | 1 B | `10101011` — "the frame starts now" |
| Destination MAC | 6 B | the only field a switch reads |
| Source MAC | 6 B | so the receiver can reply |
| **EtherType** | 2 B | which upper-layer protocol is inside (`0x0800` = IPv4) |
| Payload | 46–1500 B | the IP packet, padded if short |
| **FCS** (Frame Check Sequence) | 4 B | a **CRC** (Cyclic Redundancy Check) — detect corruption |

**Why the preamble.** The receiver must lock onto the sender's bit timing before
it can distinguish `1` from `0`. The alternating pattern is the cheapest possible
clock signal; the unique SFD then marks the boundary.

**The broadcast address.** `FF:FF:FF:FF:FF:FF` (48 bits, all ones) means
*everyone on this LAN*. It is how ARP and DHCP reach hosts they have never met.

**Minimum frame size.** 64 bytes (46-byte payload). The frame must stay "in
flight" long enough to notice a collision — see [[terms/CSMA]].

**Where it appears:** [[13_LAN]] Sections 3, 6 · [[14_Distance_Vector]] Section 1 · [[16_Wireless]] Section 4.5

**Related:** [[terms/MAC]] · [[terms/CSMA]] · [[terms/LAN]]
