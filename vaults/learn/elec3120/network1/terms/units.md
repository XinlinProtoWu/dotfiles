# Units used in these notes

| Unit | Means | Watch out for |
|---|---|---|
| **bps / kbps / Mbps / Gbps** | bits per second | **bits**, not bytes — multiply by 8 when converting from MB |
| **B / KB / MB** | bytes | the slides use decimal MB, so $500\,\text{MB} = 4000\,\text{Mbit}$ |
| **ms / µs** | millisecond / microsecond | $1\,\mu\text{s} = 10^{-6}\,\text{s}$ |
| **GHz** | gigahertz, $10^9$ cycles per second | 2.4 GHz / 5 GHz / 6 GHz are the Wi-Fi bands |
| **bit time** | the time to transmit one bit at the link rate | at 10 Mbps one bit time $= 0.1\,\mu\text{s}$, so 512 bit times $= 51.2\,\mu\text{s}$ |

**The most common exam error** is mixing bits and bytes in a bandwidth-delay
product or a transfer-time calculation.

**Where it appears:** throughout [[15_Link_Layer]] and [[16_Wireless]]
