# 16 — Wireless and Mobile Networks

> Source: `16_Wireless.pdf`. Two halves:
> 1. **Wireless links** — why **Carrier Sense Multiple Access with Collision Detection ([[terms/CSMA|CSMA/CD]])** cannot work over radio, and what replaces it: **Carrier Sense Multiple Access with Collision Avoidance ([[terms/CSMA|CSMA/CA]])** with **Request To Send / Clear To Send ([[terms/RTS-CTS|RTS/CTS]])**. Then 802.11 (Wi-Fi), Bluetooth, 4G/5G.
> 2. **Mobility** — what happens when a device moves between networks, and how its traffic still finds it: **home network, visited network, registration, indirect versus direct routing**.
>
> Continues [[15_Link_Layer]]; the mobility half builds on **Internet Protocol ([[terms/IP]])** addressing ([[10_IP]], [[11_BGP]]).

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Wireless link layer:** [[terms/AP]] · [[terms/BSS]] · [[terms/CSMA]] · [[terms/RTS-CTS]] · [[terms/ACK]] · [[terms/IEEE80211]] · [[terms/modulation]] · [[terms/SNR-BER]] · [[terms/ISM-band]] · [[terms/multiplexing]] · [[terms/ARQ]]

**Cellular:** [[terms/LTE]] · [[terms/HSS]] · [[terms/ISP]]

**Protocols and services:** [[terms/TCP]] · [[terms/UDP]] · [[terms/IP]] · [[terms/NAT]] · [[terms/DHCP]] · [[terms/LAN]] · [[terms/HTTP]] · [[terms/DNS]] · [[terms/VoIP]] · [[terms/SDN]]

**Notation:** [[terms/units]]

## 1. Recap: Carrier Sense Multiple Access with Collision Detection (CSMA/CD) and when it breaks

From [[15_Link_Layer]]:

- **Carrier sense** — listen before you talk.
- **Collision detection** — listen while you talk; abort on interference.
- **Binary exponential backoff** — after the $n$-th collision pick $K \in \{0, 1, \dots, 2^{n}-1\}$, wait $K \times 512$ bit times (capped at $K \le 1023$).

![[16_Wireless.pdf#page=3]]
*Figure: the [[terms/CSMA|CSMA/CD]] state machine, restated. (`16_Wireless.pdf` p. 3)*

![[16_Wireless.pdf#page=4]]
*Figure: the backoff table — the random range doubles per collision up to 1023. (`16_Wireless.pdf` p. 4)*

### Why carrier sense can fail

![[16_Wireless.pdf#page=5]]
*Figure: B and D start sending almost simultaneously; the signal has not arrived yet. (`16_Wireless.pdf` p. 5)*

Signals travel at roughly the **speed of light** ($\approx 1$ foot/ns $\approx 0.3$ m/ns) — **fast, but not infinitely fast**. If `B` and `D` start at almost the same instant, neither has heard the other's signal *yet*, so both conclude the wire is idle.

**Simple example.** A 2.5 km cable, one-way delay $\approx 8\,\mu\text{s}$. `D` begins transmitting at $t = 0$; the signal reaches `B` at $t = 8\,\mu\text{s}$. If `B` senses the carrier at $t = 7\,\mu\text{s}$, it hears silence and starts sending. A collision is now unavoidable — carrier sense was *honest but out of date*.

This is why **collision detection** matters: because both *can* detect the collision, they can abort early instead of wasting the whole frame.

### Collision detection needs a long enough packet

![[16_Wireless.pdf#page=6]]
*Figure: a short frame can finish before the collision reaches the far end — B never senses it. (`16_Wireless.pdf` p. 6)*

If a frame is too **short in time**, the sender finishes transmitting before the collision wave returns, so it believes the transmission succeeded. The packet is then lost silently.

> **Rule: minimum packet transmission time > 2 × maximum propagation delay**

The factor 2 is the **round trip**: the frame must still be in flight when the other end's signal arrives.

### Collision detection needs a short enough wire

![[16_Wireless.pdf#page=7]]
*Figure: with a long wire, A and D collide too late to notice. (`16_Wireless.pdf` p. 7)*

Symmetric constraint: if the wire is too long, distant nodes collide after the sender has already finished. So the product $L \times R$ (wire length times bit rate) is what matters: it decides how many bits fit on the wire.

### Scaling problem — and why switched Ethernet won

| Speed | Effect |
|---|---|
| 10 Mbps | 2.5 km max, 64-byte min frame ⇒ `51.2 µs` slot time: sensible |
| 100 Mbps | same frame is 10× shorter in **time** ⇒ max wire length must shrink 10× |
| 1 Gbps, 10 Gbps, 40 Gbps | 40 Gbps is **4000×** 10 Mbps: the collision domain would have to be a few metres |

![[16_Wireless.pdf#page=8]]
*Figure: Ethernet scaling — shrinking collision domains, or switching. (`16_Wireless.pdf` p. 8)*

The actual engineering fix: **don't share the medium.** Switched Ethernet gives each host a **full-duplex point-to-point** link, so there is only ever one sender **per direction** and collisions cannot happen. CSMA/CD is legacy for shared segments.

> [!important] The lesson
> **Collision detection is a property of a shared medium.** Kill the sharing (switching, full duplex) and the whole problem disappears. Radio cannot be switched this way — so radio needs a different solution.

---

## 2. Why wireless cannot use CSMA/CD

Radio has no wire to confine the signal, so "who can hear whom" is not a clean graph.

### Hidden terminals

![[16_Wireless.pdf#page=11]]
*Figure: A and C are both in range of B, but not of each other. (`16_Wireless.pdf` p. 11)*

`A` and `C` can both reach `B`, but **cannot hear each other**. So:

- `A` senses the medium — quiet (C is far away) — and transmits.
- `C` senses the medium — quiet (A is far away) — and transmits.
- Both signals arrive at `B` **simultaneously** and **collide**.

Carrier sense is **useless** here: it only detects transmitters *near the sender*, while what matters is transmitters near the **receiver**.

**Analogy:** two students whispering from opposite ends of a large hall to the person in the middle. Neither can hear the other, but the person in the middle hears both at once and understands nothing.

### Exposed terminals

![[16_Wireless.pdf#page=12]]
*Figure: C hears B sending to A and wrongly stays quiet — even though C→D would be harmless. (`16_Wireless.pdf` p. 12)*

The opposite error: `B` transmits to `A`; `C` overhears and **defers** even though `C`'s intended receiver `D` is nowhere near `B`. So a transmission that *would have succeeded* never happens. Carrier sense **costs throughput** here.

### The three key points (slide 13)

1. **There is no global notion of collision.** Different receivers hear different signals; different senders reach different receivers.
2. **Collisions happen at the *receiver*, not the sender.** It does not matter whether the sender can hear someone else — only whether the **receiver** is being interfered with.
3. **Therefore the protocol's goal is:** find out whether *the receiver can hear the sender*, and tell senders who *might* interfere with that receiver to shut up.

> [!important] Why "detection" is impossible in radio
> A radio cannot listen on the same frequency it is transmitting on — its own signal drowns everything. So wireless must **avoid** collisions rather than **detect** them. Hence **[[terms/CSMA|CSMA/CA]]**: *Collision Avoidance*, not Detection.

![[16_Wireless.pdf#page=10]]
*Figure: the "Ahhh! Signal interference!" picture — you cannot detect while transmitting. (`16_Wireless.pdf` p. 10)*

### Basic collision avoidance (p. 14)

- **Carrier sense:** if the medium is busy, pick a **random** number of idle time slots to wait before sending.
- **Infer** collisions instead of detecting them: if the receiver's **[[terms/ACK]]** does not arrive, assume a collision.
- On inferred collision, retransmit with **binary exponential backoff** (same idea as Ethernet) to adapt the contention window to load.

**Simple example.** Alice and Bob both want to send. Both hear silence, both pick a random backoff of 3 or 7 slots. Alice picks 3, Bob picks 7 → Alice transmits first and gets an ACK. Bob hears the medium busy, pauses, then continues its countdown when it goes idle.

---

## 3. CSMA/CA with Request To Send / Clear To Send (RTS/CTS)

The ACK-based scheme above still fails for **hidden terminals**: the collision happens at the receiver, and the sender never learns why. The fix is to have the **receiver** speak up *before* the data is sent.

| Step | Frame | Purpose |
|---|---|---|
| 1 | Sender → receiver: **RTS** (Request To Send) | "I want to send for *this long*" |
| 2 | Receiver → all: **CTS** (Clear To Send) | "Go ahead; everyone else be quiet" |
| 3 | Sender → receiver: **data** | The actual payload |
| 4 | Receiver → all: **ACK** (acknowledgement) | "Received; the medium is free again" |

![[16_Wireless.pdf#page=15]]
*Figure: RTS / CTS / data / ACK. If no CTS comes back, the sender infers a collision. (`16_Wireless.pdf` p. 15)*

### Why CTS solves the hidden terminal problem

The crucial detail: **CTS is heard by nodes near the *receiver*, not just near the sender** — and those are exactly the nodes that would have collided.

![[16_Wireless.pdf#page=18]]
*Figure: B→C. A hears the RTS and defers (so C can answer); D hears the CTS and defers for the data. (`16_Wireless.pdf` p. 18)*

```text
1. B sends RTS to C
2. A hears the RTS  → defers, so that C's CTS is not drowned out
3. C replies CTS to B
4. D hears the CTS  → defers, so that the DATA is not drowned out
5. B sends DATA to C
```

`A` is the node near the **sender** (protected by RTS). `D` is the node near the **receiver** (protected by CTS). **Together they cover both interference neighbourhoods** — which is exactly the requirement from slide 13.

![[16_Wireless.pdf#page=16]]
*Figure: a node that hears the RTS but not the CTS may still transmit — presumably its destination is out of the sender's range. (`16_Wireless.pdf` p. 16)*

![[16_Wireless.pdf#page=17]]
*Figure: but that assumption breaks if a CTS is lost — so hearing a CTS means staying quiet until the ACK. (`16_Wireless.pdf` p. 17)*

### The cost

[[terms/RTS-CTS|RTS/CTS]] is a **contention-free** handshake, and handshakes are pure overhead:

- Two extra short frames per data frame.
- Latency before every transmission.
- Gets in the way for small packets.

So real 802.11 uses a **threshold**: RTS/CTS only above a certain frame size (typically ~500–1000 bytes). Small frames just use carrier sense + ACK.

---

## 4. Institute of Electrical and Electronics Engineers (IEEE) 802.11 (Wi-Fi / Wireless Local Area Network (WLAN))

All 802.11 variants use **CSMA/CA**, and come in **infrastructure** (with a base station) and **ad hoc** (hosts only) forms.

![[16_Wireless.pdf#page=20]]
*Figure: the 802.11 family and its rates/ranges. (`16_Wireless.pdf` p. 20)*

| Standard | Year | Max rate | Range | Band |
|---|---|---|---|---|
| 802.11b | 1999 | 11 Mbps | 30 m | 2.4 GHz |
| 802.11g | 2003 | 54 Mbps | 30 m | 2.4 GHz |
| 802.11n (Wi-Fi 4) | 2009 | 600 Mbps | 70 m | 2.4 / 5 GHz |
| 802.11ac (Wi-Fi 5) | 2013 | 3.47 Gbps | 70 m | 2.4 / 5 GHz |
| 802.11ax (Wi-Fi 6) | 2020 | 14 Gbps | 70 m | 2.4 / 5 GHz |
| 802.11be (Wi-Fi 7) | 2025 | ? | ? | 2.4 / 5 / 6 GHz |

Note: rate grows ~1000× while range grows only ~2× — and **higher rates need better signal**, hence shorter effective reach. See rate adaptation (Section 4.6).

### 4.1 Architecture: Basic Service Set (BSS) and access point (AP)

![[16_Wireless.pdf#page=21]]
*Figure: [[terms/BSS]] 1 and BSS 2, each with an access point connected to a switch/router. (`16_Wireless.pdf` p. 21)*

| Term | Meaning |
|---|---|
| **[[terms/AP]]** (access point) | The **base station**; the wired↔wireless bridge |
| **BSS** (Basic Service Set), "cell" | One AP plus its wireless hosts |
| **Infrastructure mode** | Hosts talk via an AP |
| **Ad hoc mode** | Hosts talk directly, no AP |

**Simple example:** your flat's router is the AP for one BSS. A campus floor has many BSSes, all wired to the same switch — which is why walking around campus keeps you connected (Section 4.5).

### 4.2 Channels

![[16_Wireless.pdf#page=22]]
*Figure: the 2.4 GHz band divided into overlapping channels. (`16_Wireless.pdf` p. 22)*

The spectrum is divided into **channels** at different frequencies. The AP admin picks one — but a neighbouring AP may pick the **same or an overlapping** channel, causing interference (this is why apartment Wi-Fi is slow at 2.4 GHz: only channels 1, 6, 11 are non-overlapping).

### 4.3 Association: joining a network

![[16_Wireless.pdf#page=23]]
*Figure: a host must associate with an AP before it can send any [[terms/IP]] traffic. (`16_Wireless.pdf` p. 23)*

1. **Scan** channels, listening for **beacon frames** carrying the AP's network name (**Service Set Identifier ([[terms/BSS|SSID]])**) and **Media Access Control ([[terms/MAC|MAC]])** address.
2. **Select** an AP.
3. **Authenticate** (optionally).
4. **Dynamic Host Configuration Protocol ([[terms/DHCP]])** to get an IP address in the AP's subnet.

Step 4 is why [[13_LAN]]'s DHCP matters here: association is a link-layer event, but you also need a network-layer address.

### 4.4 Passive versus active scanning

![[16_Wireless.pdf#page=24]]
*Figure: passive scanning (wait for beacons) versus active scanning (broadcast a probe). (`16_Wireless.pdf` p. 24)*

| Passive | Active |
|---|---|
| 1. APs send **beacon** frames periodically | 1. Host broadcasts a **Probe Request** |
| 2. Host sends **Association Request** to the chosen AP | 2. APs reply with **Probe Response** |
| 3. AP sends **Association Response** | 3. Host sends **Association Request** |
| | 4. AP sends **Association Response** |

**Trade-off:** passive is quiet but slow (you must wait for a beacon); active is fast but adds probe traffic and reveals your presence.

### 4.5 The 802.11 frame has **four** addresses

![[16_Wireless.pdf#page=25]]
*Figure: the 802.11 MAC frame — note addresses 1, 2, 3, and 4. (`16_Wireless.pdf` p. 25)*

| Field | Size | Meaning |
|---|---|---|
| frame control | 2 | version, type, flags |
| duration | 2 | how long the medium will be busy |
| **address 1** | 6 | **receiver** (wireless host or AP) |
| **address 2** | 6 | **transmitter** (wireless host or AP) |
| **address 3** | 6 | MAC of the **router interface** the AP is attached to |
| seq control | 2 | sequence number |
| **address 4** | 6 | used only in **ad hoc** mode |
| payload | 0–2312 | the actual data |
| **Cyclic Redundancy Check (CRC)** | 4 | error detection |

**Why four addresses?** An Ethernet frame has two (src, dst). But a Wi-Fi frame may have to name: the wireless source, the AP as the *immediate* transmitter, the ultimate wired destination, and the wireless destination.

![[16_Wireless.pdf#page=26]]
*Figure: H1 → R1 goes through the AP: `addr1 = AP`, `addr2 = H1`, `addr3 = R1`. (`16_Wireless.pdf` p. 26)*

```text
H1 sends to R1 (outside the cell):
   802.11 frame:  addr1 = AP   addr2 = H1   addr3 = R1
   ↓ AP re-wraps it in Ethernet:
   802.3 frame:   dst   = R1's MAC          src  = AP's MAC
```

So the AP **rewrites the link-layer header**, just as a router rewrites the Ethernet destination at each hop ([[13_LAN]] Section 4). The IP packet inside is untouched.

### 4.6 Mobility within the same subnet

![[16_Wireless.pdf#page=27]]
*Figure: H1 moves from BSS 1 to BSS 2; its IP address does not change. (`16_Wireless.pdf` p. 27)*

If both APs are in the **same IP subnet**, `H1`'s IP address stays valid after the move. How does the switch know which AP `H1` is now behind? **Self-learning** ([[13_LAN]] Section 8): `H1`'s first frame from the new AP re-teaches the switch its MAC → port mapping.

That is mobility handled entirely **inside** one [[terms/LAN]] — no routing protocol involved. Moving between *subnets* is the hard case (Section 6).

### 4.7 Rate adaptation

![[16_Wireless.pdf#page=28]]
*Figure: SNR versus BER for different modulation schemes; the AP and mobile track an operating point. (`16_Wireless.pdf` p. 28)*

The AP and the mobile **dynamically change the transmission rate** (physical-layer modulation) because the channel changes as you move:

1. As you move away, the **signal-to-noise ratio (SNR)** decreases and the **bit error rate (BER)** increases.
2. When BER gets too high, **switch to a lower rate** — which is more robust (lower BER) but slower.

**Simple example.** Near the AP you get **Quadrature Amplitude Modulation with 256 symbols ([[terms/modulation|QAM256]])** at 8 Mbps with few errors. At the far end of the corridor, QAM256 gives so many errors that retransmissions make it *slower* than **Binary Phase Shift Keying ([[terms/modulation|BPSK]])** at 1 Mbps — so the system drops the rate and ends up faster in practice.

This is a beautiful example of a **cross-layer** decision: the link layer trades rate for reliability based on physical-layer conditions.

### 4.8 Power management

![[16_Wireless.pdf#page=29]]
*Figure: sleeping nodes and beacon frames that list buffered traffic. (`16_Wireless.pdf` p. 29)*

Battery is the scarce resource:

- Node → AP: "I am going to **sleep** until the next beacon."
- The AP then **buffers** frames for it, and knows not to try to deliver.
- The node **wakes up before each beacon**; the beacon lists which mobiles have frames waiting.
- If there is buffered traffic, the node **stays awake**; otherwise it sleeps again.

**Analogy:** telling the post office "I'm away until Monday — hold my mail", then checking the notice board each Monday.

---

## 5. Bluetooth (a personal area network)

![[16_Wireless.pdf#page=32]]
*Figure: a piconet — one master (M), active clients (C), parked devices (P). (`16_Wireless.pdf` p. 32)*

| Property | Value |
|---|---|
| Range | < 10 m diameter |
| Purpose | **Replacing cables** (mouse, keyboard, headphones) |
| Structure | **ad hoc** — no infrastructure |
| Band | 2.4–2.5 GHz **Industrial, Scientific and Medical (ISM)** band, up to 3 Mbps |
| Roles | **master controller** polls clients and grants transmissions |

- **Time Division Multiplexing ([[terms/multiplexing|TDM]]):** 625 microsecond (µs) slots; the master polls clients (so there is never a collision — it is a **taking-turns** protocol, compare [[15_Link_Layer]] Section 9a).
- **Frequency Division Multiplexing ([[terms/multiplexing|FDM]]) / spread spectrum:** 79 frequency channels, hopped in a known pseudo-random order slot-to-slot. Devices outside the piconet only interfere in *some* slots.
- **Parked mode:** clients can sleep (park) and wake later, to save battery.
- **Bootstrapping:** nodes self-assemble ("plug and play") into a **piconet**.

**Simple example.** Your earbuds and phone form a piconet with the phone as master: it decides who transmits in each 625 µs slot, and hops frequencies 1600 times a second so that a microwave oven or a neighbouring piconet only corrupts a fraction of the slots.

---

## 6. Cellular networks: 4G and 5G

![[16_Wireless.pdf#page=36]]
*Figure: the wide-area solution — 4G/5G. (`16_Wireless.pdf` p. 36)*

- Up to hundreds of Mbps; more mobile-broadband devices than fixed ones (5:1 in 2019).
- Standards from the **3rd Generation Partnership Project (3GPP)**; 4G is **Long-Term Evolution ([[terms/LTE]])**.

![[16_Wireless.pdf#page=37]]
*Figure: cellular versus wired Internet — same protocols, different link layer and a first-class notion of mobility. (`16_Wireless.pdf` p. 37)*

| Similar to the wired Internet | Different from the wired Internet |
|---|---|
| Edge/core split (both owned by one carrier) | **Different wireless link layer** |
| It is a network of networks | **Mobility as a first-class service** |
| Uses **Hypertext Transfer Protocol ([[terms/HTTP]])**, **Domain Name System ([[terms/DNS]])**, **Transmission Control Protocol ([[terms/TCP]])**, **User Datagram Protocol ([[terms/UDP]])**, IP, **Network Address Translation ([[terms/NAT]])**, **Software-Defined Networking ([[terms/SDN]])**, data/control plane split, tunnelling | **User identity via SIM card** |
| | Business model: subscription |
| | Strong notion of **home network versus roaming** |
| | Global authentication infrastructure and inter-carrier settlements |

The important conceptual point: cellular is **the same Internet protocols** with a different link layer and **explicit, architecturally-supported mobility**. Wi-Fi has no such support — that is the gap the next section addresses.

---

## 7. Mobility

### 7.1 The spectrum of mobility

![[16_Wireless.pdf#page=38]]
*Figure: the mobility spectrum, from "no mobility" to "moving between providers while connected". (`16_Wireless.pdf` p. 38)*

| Level | Example | Hard? |
|---|---|---|
| Moves between networks, but powers down | Laptop moved between home and office | Easy — new DHCP lease |
| Moves within one AP's coverage | Walking around one room | Trivial — nothing changes |
| Moves among APs in one provider | Walking across campus | Moderate — Section 4.6 (same subnet: free) |
| **Moves among providers, keeping connections alive** | **Driving while on a call** | **The hard case — Section 7** |

### 7.2 The challenge

![[16_Wireless.pdf#page=40]]
*Figure: the client moves from Verizon to AT&T — how does the network know where to forward packets? (`16_Wireless.pdf` p. 40)*

Your **IP address** is both an *identity* and a *location*. If it never changes, packets can always be routed to you — but the topology no longer matches, so routing breaks. If it changes to match the new location, in-flight TCP connections break, because the server is still addressing the old address.

**Simple example.** You are streaming video and your phone moves from Verizon to AT&T. The video server keeps sending to your Verizon address. Unless *something* forwards those packets, the stream dies.

### 7.3 Approach A: let the routers handle it

Routers could advertise a route to the mobile's **permanent IP address** via the usual routing protocols, and update it as the mobile moves.

> "The Internet could do this already with no changes! Routing tables indicate where each mobile is, via **longest prefix match**." (slide 51)

**Why it fails:** every mobile needs its own entry, and mobility events would be **global routing churn**. The Internet's routing system cannot absorb billions of host-level updates — precisely the scalability argument from [[11_BGP]] (**Border Gateway Protocol**) and the flat-addressing failure from `11-BGP.pdf` p. 3. **Not scalable.**

### 7.4 Approach B: let the end systems handle it (the real answer)

Move the functionality to the **edge** — that is the **end-to-end argument** of [[12_Internetworking]] in action. Two variants:

| | Indirect routing | Direct routing |
|---|---|---|
| Correspondent sends to | the mobile's **home** address | the mobile's **care-of** (visited) address |
| Who forwards last hop | home network **tunnels** to the visited network | nobody — it goes straight |
| Transparent to the correspondent? | **yes** | **no** (must learn the care-of address) |
| Efficiency | suffers **triangle routing** | efficient |

### 7.5 Home and visited network — the core vocabulary

The idea is borrowed from daily life (slide 43):

> **How do you find a friend who keeps moving?** You call their **parents** — the "home" — and ask where they are. The home is *"a definitive source of information about you, a place where people can find out where you are."*

![[16_Wireless.pdf#page=44]]
*Figure: cellular home versus visited network, and the SIM card that ties you to a home. (`16_Wireless.pdf` p. 44)*

| Term | Meaning |
|---|---|
| **Home network** | The provider you **subscribe** to (**China Mobile Hong Kong (CMHK)**, **CSL**) |
| **Home Subscriber Server (HSS)** | Stores your identity and service info |
| **Visited network** | Any other network you are roaming in |
| **Subscriber Identity Module (SIM) card / International Mobile Subscriber Identity (IMSI)** | Your **global identity**, including which network is your home |
| **Roaming agreement** | Enables the visited network to serve you |

Note the asymmetry with an **Internet service provider ([[terms/ISP]])** / Wi-Fi setup: **Wi-Fi has no notion of a global "home"** — credentials are just username/password, different per network (with exceptions like **eduroam**). Mobile IP architectures exist for Wi-Fi, but are **not deployed** in practice.

![[16_Wireless.pdf#page=45]]
*Figure: the generic model — permanent IP, IMSI, home gateway, visited gateway, correspondent. (`16_Wireless.pdf` p. 45)*

| | Home network `128.119/16` | Visited network `79.129/16` |
|---|---|---|
| Device address | permanent IP `128.119.40.186` | NAT IP `10.0.0.99` |
| Identity | IMSI `78:4f:43:98:d9:27` | IMSI `78:4f:43:98:d9:27` (same) |

The **IMSI is the same in both places** — that is the identity. The **IP address differs** — that is the location. Two separate namespaces, exactly like MAC versus IP in [[13_LAN]].

### 7.6 Registration: home must learn where you are

![[16_Wireless.pdf#page=46]]
*Figure: after association, the visited mobility manager registers the mobile's location with the home HSS. (`16_Wireless.pdf` p. 46)*

1. Mobile **associates** with the visited network.
2. Visited **mobility manager** registers the mobile's location with the **home HSS**.

End result: the **visited** mobility manager knows about the mobile, and the **home** HSS knows where the mobile is. Now the home can forward.

### 7.7 Indirect routing

![[16_Wireless.pdf#page=47]]
*Figure: the correspondent addresses the home; the home tunnels to the visited gateway. (`16_Wireless.pdf` p. 47)*

```text
1.  Correspondent sends to the PERMANENT (home) address 128.119.40.186
2.  Home gateway receives it, looks up the HSS → visited network
4a. Home gateway TUNNELS the datagram to the visited gateway
    Visited gateway forwards it to the mobile
4b. Reply: either back through the home network (4a) or directly (4b)
```

"**Tunnel**" = wrap the original packet inside a new packet addressed to the visited gateway (encapsulation, compare [[12_Internetworking]]). The mobile's address is never advertised to the outside world.

**Properties (slide 48):**

- **Transparent to the correspondent** — it just uses the home address and never knows the mobile moved.
- Moving among visited networks is **invisible** to the correspondent: the mobile registers in the new visited network, which notifies the home HSS, and datagrams keep being forwarded. **On-going TCP connections survive.**
- **Downside: triangle routing.**

![[16_Wireless.pdf#page=48]]
*Figure: triangle routing — the home is a detour when correspondent and mobile are close together. (`16_Wireless.pdf` p. 48)*

**Simple example.** You are in Hong Kong (home = HK), visiting London. Your friend in London sends you a packet. It goes **London → Hong Kong → London** — a 20,000 km round trip for a 2 km delivery. That is **triangle routing**.

### 7.8 Direct routing

![[16_Wireless.pdf#page=49]]
*Figure: direct routing — the correspondent asks the home HSS for the care-of address, then sends straight there. (`16_Wireless.pdf` p. 49)*

```text
1. Correspondent contacts the home HSS
2. HSS returns the mobile's visited-network (care-of) address
3. Correspondent addresses the datagram directly to the visited network
4. Visited gateway forwards it to the mobile
```

**Properties (slide 50):**

- **Overcomes triangle routing** — the efficient path.
- **Not transparent:** the correspondent must fetch and use the **care-of address**, so it needs new functionality.
- If the mobile changes visited network, this is messy — the correspondent's cached care-of address is stale, and must be re-fetched.

### 7.9 Comparing the two

| | Indirect | Direct |
|---|---|---|
| Path | via home | direct |
| Efficiency | triangle routing | near-optimal |
| Correspondent complexity | **none** | must query HSS and handle care-of |
| Mobility transparency | **full** — connections survive moves | partial; stale care-of addresses |
| Deployed? | yes (cellular, Mobile IP) | used where efficiency matters |

Note the recurring engineering pattern: **transparency and efficiency trade off against each other.** Same story as NAT in [[11_BGP]].

---

## 8. Impact on higher-layer protocols

Logically, wireless should not matter: the best-effort service model is unchanged, and TCP/UDP run over wireless unchanged.

**But performance-wise it matters a lot** (slide 51):

| Problem | Consequence |
|---|---|
| **Bit errors** → discarded packets and link-layer retransmissions | Delay and loss that are *not* congestion |
| **Handover loss** when moving between APs | Packets lost during the transition |
| **TCP misreads loss as congestion** | `cwnd` is cut **unnecessarily** — needless slowdown (see [[07_Congestion_Control]]) |
| Delay impairments | Bad for real-time traffic (**Voice over Internet Protocol ([[terms/VoIP]])**, video) |
| Bandwidth is scarce | Headers and retransmissions are expensive |

> [!important] The classic cross-layer conflict
> TCP's congestion control assumes **loss = congestion**. Wireless breaks that assumption: loss may be pure radio noise, and the correct response is a faster retransmission, not a smaller window. This is the motivation for split-connection TCP, link-layer **Automatic Repeat reQuest ([[terms/ARQ]])**, and modern hybrid approaches.

---

## 9. Summary (p. 52)

**Wireless**

- Wireless link and network characteristics — interference, hidden/exposed terminals.
- Wi-Fi: 802.11 with CSMA/CA + RTS/CTS.
- Cellular: 4G/5G — same Internet, first-class mobility.

**Mobility**

- Principles: home versus visited, registration.
- Practice: indirect routing (transparent, triangle) versus direct routing (efficient, non-transparent).

> [!tip] Exam traps
> - **Collision detection is impossible in radio** — the device's own transmission drowns the received signal. Hence **CA**, not CD.
> - Collisions are a phenomenon at the **receiver**.
> - **Hidden terminal** = carrier sense misses an interferer; **RTS protects nodes near the sender, CTS protects nodes near the receiver** — CTS is what fixes the hidden terminal. **Exposed terminal** (unnecessary deferral) is *not* solved by RTS/CTS and remains wasted capacity.
> - The rule is **min packet time > 2 × max propagation delay** — the **2** is the round trip.
> - **Four** addresses in an 802.11 frame; Ethernet has two.
> - RTS/CTS is **overhead** — used only above a size threshold.
> - **IMSI = identity (constant); IP = location (changes).**
> - **Indirect routing = transparent but triangular. Direct routing = efficient but non-transparent.**
> - Wireless loss is often **not** congestion, so TCP over-reacts.
