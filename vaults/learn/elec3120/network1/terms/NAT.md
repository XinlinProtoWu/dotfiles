# NAT — Network Address Translation

**What it is.** A box that rewrites the **source address and port** of outgoing
packets to its own public IP, and rewrites the destination back on the way in.

**Why it exists.** A port field is 16 bits, so one public IP can distinguish
$2^{16} = 65{,}536$ simultaneous connections by port number. Many private hosts
can therefore share one public address.

**Example.** Client `10.2.2.2:1000` sends to `198.2.4.5:80`. The NAT rewrites it
to `243.4.4.4:5000` and records the row `(10.2.2.2, 1000, 5000)`. The reply to
`243.4.4.4:5000` is looked up in that row and delivered to `10.2.2.2:1000`.

**Why the port must change.** The NAT port is the *lookup key* on the public side,
so it must be unique across **all** internal hosts — while an internal port only
has to be unique on one host. Two different scopes, therefore two different
numbers.

**Where it appears:** [[11_BGP]] Section 6 · [[16_Wireless]] Section 7.5

**Related:** [[terms/IP]] · [[terms/DHCP]] · [[terms/TCP]] · [[terms/UDP]]
