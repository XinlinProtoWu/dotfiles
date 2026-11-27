# MAC address — Media Access Control address

**What it is.** A 48-bit hardware identifier burned into a network interface by
its manufacturer, written as six hexadecimal pairs: `34:f3:e4:ae:66:44`.
The address space is $2^{48} = 281{,}474{,}976{,}710{,}656$.

**Why it exists.** Inside one LAN you must name *a port on this wire*, not a
host's position in the Internet. A MAC address is **flat** (it encodes no
location) and **permanent** (it does not change when the device moves). That is
the opposite of an IP address, which is hierarchical and changes with location.

**Example.** A laptop keeps MAC `ab:cd:ef:12:34:f3` whether it is at HKUST or in
a café, while its IP address changes every time. That is why the two schemes
coexist: MAC = *who you are*, IP = *where you are*.

**Where it appears:** [[13_LAN]] Sections 2, 4 · [[14_Distance_Vector]] Section 1 · [[16_Wireless]] Section 4.5

**Related:** [[terms/Ethernet]] · [[terms/ARP]] · [[terms/IP]] · [[terms/NIC]]
