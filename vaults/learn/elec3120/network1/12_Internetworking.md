# 12 — Internetworking and Layering

> Source: `12-Internet.pdf`. Goal: the Internet’s layered architecture, how encapsulation works, why IP is the “narrow waist,” and the end-to-end argument for deciding **where** functionality belongs.

## 1. What is a network architecture?

A **network architecture** is the design of a computer network: its physical components, how they are organized and configured, its operational principles, and its protocols.

Think of it like:

- the architecture of a house — from nails and boards up to “dining room”;
- the architecture of a computer — from transistors up to an operating system;
- the architecture of the Internet — from electrons, light, and radio up to Netflix or Google search.

![[12-Internet.pdf#page=4]]
*Figure: architecture spans from physical components to high-level services. (`12-Internet.pdf` p. 4)*

---

## 2. The Internet model: five layers

![[12-Internet.pdf#page=5]]
*Figure: the five-layer Internet model. (`12-Internet.pdf` p. 5)*

There are two ways to read the stack:

- **Bottom-up:** each layer provides an **API** to the layer above.
- **Top-down:** each layer **encapsulates** data from the layer above.

![[12-Internet.pdf#page=6]]
*Figure: bottom-up = APIs; top-down = encapsulation. (`12-Internet.pdf` p. 6)*

| Layer | Main job | Data unit | Examples |
|---|---|---|---|
| **Application** | Provide the actual service | message / byte stream | HTTP, DNS, video streaming |
| **Transport** | End-to-end connection, reliability, ordering, multiplexing | segment | TCP, UDP |
| **Network** | Global addressing and routing | packet | IP, ICMP |
| **Data Link** | Local delivery on one link; framing, addressing, medium access, error detection | frame | Ethernet, Wi-Fi, PPP |
| **Physical** | Transmit raw bits over a medium | bits | copper, fiber, radio |

### Physical layer

The physical layer transmits raw bits over electricity, light, radio, or any other medium. It provides an API to the layer above: **1s and 0s**.

![[12-Internet.pdf#page=9]]
*Figure: the physical layer hides the medium; upper layers only see bits. (`12-Internet.pdf` p. 9)*

### Data link layer

The data link layer:

- turns bits into **packets/frames**;
- labels senders and receivers;
- lets everyone on the link talk to everyone else;
- prevents multiple senders from transmitting at once;
- detects and prevents errors from corruption.

![[12-Internet.pdf#page=13]]
*Figure: what the data link layer handles. (`12-Internet.pdf` p. 13)*

There are many link-layer protocols, but the layer above just sees **uncorrupted packets**.

![[12-Internet.pdf#page=12]]
*Figure: the link layer turns bits into packets. (`12-Internet.pdf` p. 12)*

### Network layer

The network layer is **IP** — there is only one network layer in the Internet model.

- It still delivers packets, just with different headers.
- It provides **globally routable packets**.
- It is deliberately **best effort**: no guarantee of delivery or ordering.

### Transport layer

IP gives no guarantees: packets can arrive out of order or be lost. The **transport layer** runs in the end hosts and can compensate:

- establish a connection between endpoints;
- retransmit lost data;
- put packets back in order.

But it does **not have to**. There are two common choices:

| Protocol | Service |
|---|---|
| **TCP** | Reliable, in-order **byte stream** |
| **UDP** | No guarantees |

![[12-Internet.pdf#page=25]]
*Figure: TCP vs. UDP — choose the transport that fits the application. (`12-Internet.pdf` p. 25)*

> [!example] Why both TCP and UDP?
>
> A file download wants every byte, in order → **TCP**.
> A live video call would rather skip a late frame than wait for a retransmission → **UDP** (plus application-level handling).

### Application layer

The application layer is **your application**: HTTP servers, browsers, Netflix, games, DNS clients, etc.

### The narrow waist

The Internet model has:

- **many** physical-layer technologies,
- **many** link-layer technologies,
- **one** network layer: IP,
- **many** applications.

![[12-Internet.pdf#page=21]]
*Figure: IP is the “narrow waist” between many lower layers and many applications. (`12-Internet.pdf` p. 21)*

This design means everyone must agree on IP, but lower layers can vary and applications can evolve independently.

> [!example] One waist, many technologies
>
> Wi-Fi, Ethernet, and fiber all carry IP. HTTP, DNS, video, and games all run over IP. A new link technology only needs to carry IP; a new app only needs to use IP.

---

## 3. Encapsulation: a packet’s journey

Top-down, each layer adds its own header:

```text
Application:  GET index.html
Transport:    [connection ID][GET index.html]
Network:      [src/dst IP][connection ID][GET index.html]
Link:         [src/dst link addr][src/dst IP][connection ID][GET index.html]
Physical:     01010101001000000100111111010101…
```

![[12-Internet.pdf#page=35]]
*Figure: application data is passed down the stack. (`12-Internet.pdf` p. 35)*

Step by step:

1. **Application** sends a chunk of data (a byte stream) to transport.
2. **Transport** chops it into pieces and adds a connection ID + header.
3. **Network** adds source and destination IP addresses.
4. **Link** adds a link-layer header, e.g. Ethernet source/destination.
5. **Physical** sends the bits.

The receiver reverses the process:

6. Strip the link-layer header.
7. Strip the IP header.
8. Strip the transport header, potentially reorder packets.
9. The application reads the data.

![[12-Internet.pdf#page=40]]
*Figure: the link-layer header is stripped at the receiver. (`12-Internet.pdf` p. 40)*

![[12-Internet.pdf#page=44]]
*Figure: the application finally reads the original data. (`12-Internet.pdf` p. 44)*

> [!example] Wireshark view
>
> One captured packet shows several nested headers: Ethernet → IP → TCP → HTTP. Each layer only reads its own header and passes the payload upward.

---

## 4. The OSI model

In 1983 the ITU proposed the **OSI model** with **seven** layers:

```text
Application
Presentation
Session
Transport
Network / Internet
Data Link
Physical
```

![[12-Internet.pdf#page=30]]
*Figure: the seven-layer OSI model. (`12-Internet.pdf` p. 30)*

In practice, the **Session** and **Presentation** layers did not work out and are no longer discussed. The Internet model uses five layers.

![[12-Internet.pdf#page=31]]
*Figure: OSI with session/presentation removed. (`12-Internet.pdf` p. 31)*

> [!note] Mapping OSI to the Internet model
>
> OSI application + presentation + session → Internet **application**
> OSI transport → **transport**
> OSI network → **network (IP)**
> OSI data link → **data link**
> OSI physical → **physical**

---

## 5. The end-to-end argument

### 5.1 The “careful file transfer” thought experiment

Host A transfers a file to host B:

1. A’s file-transfer program asks the file system to read the file from disk.
2. The file system returns fixed-size blocks.
3. The transfer program asks the communication system to send the file, splitting it into packets.
4. The network moves the packets.
5. B’s communication program removes the packets and hands the data to B’s file-transfer program.
6. B’s file-transfer program asks B’s file system to write the data to disk.

![[12-Internet.pdf#page=49]]
*Figure: careful file transfer — disk, file system, transfer program, and network. (`12-Internet.pdf` p. 49)*

### 5.2 What could go wrong?

Later, the file is corrupted. Possible causes:

- the disk hardware read/write is faulty;
- file-system, transfer, or network software has a buffering/copy bug;
- the CPU or memory has a transient error;
- the network drops, corrupts, or duplicates packets;
- either host crashes partway through the transaction.

![[12-Internet.pdf#page=62]]
*Figure: possible causes of corruption span endpoints and the network. (`12-Internet.pdf` p. 62)*

Even a **perfectly reliable network** does not solve the problem, because disk, memory, software, and crash failures remain at the endpoints.

![[12-Internet.pdf#page=69]]
*Figure: a reliable network alone does not guarantee a correct file. (`12-Internet.pdf` p. 69)*

### 5.3 End-to-end check and retry

The robust solution is to check at the endpoints:

1. A reads the file **and its checksum** from disk.
2. A verifies the file + checksum.
3. A sends **the file and the checksum**.
4. B writes the file + checksum to disk.
5. B reads the file back and verifies it again.
6. If anything does not match, B asks A to **resend the whole file**.

![[12-Internet.pdf#page=71]]
*Figure: end-to-end check and retry. (`12-Internet.pdf` p. 71)*

![[12-Internet.pdf#page=76]]
*Figure: B writes and reads back the file to verify the final stored bytes. (`12-Internet.pdf` p. 76)*

This catches all the failure modes above because the **final bytes at the endpoint** are verified, regardless of where the error occurred.

### 5.4 The basic argument

> If a function can be completely and correctly implemented with the knowledge and help of the application at the endpoints, then providing that function as a feature of the communication system is not necessary (and cannot be complete without endpoint help).
>
> Sometimes an **incomplete** version at a lower layer is still useful as a **performance enhancement**.

![[12-Internet.pdf#page=67]]
*Figure: the end-to-end argument. (`12-Internet.pdf` p. 67)*

> [!example] Encryption
>
> Only the endpoints know the keys. The network can encrypt individual links, but it cannot provide true end-to-end confidentiality without the endpoints’ keys. Endpoint encryption is the complete solution; link encryption is at most a performance/coverage enhancement.

### 5.5 The strong end-to-end argument

The **strong** version says: putting non-essential functionality at lower layers is not just wasteful — it is **harmful**.

Why?

- It consumes bandwidth and adds latency.
- It constrains how applications can be designed.
- Applications may not want the lower layer’s version of the feature.

![[12-Internet.pdf#page=85]]
*Figure: extra lower-layer functionality can be actively harmful. (`12-Internet.pdf` p. 85)*

![[12-Internet.pdf#page=86]]
*Figure: redundant reliability costs bandwidth and adds latency. (`12-Internet.pdf` p. 86)*

> [!example] A reliable network plus end-to-end retry
>
> If the network already retransmits, and the application also retransmits, the system does extra work twice. The lower-layer reliability may also increase latency and reduce effective bandwidth — and the application still needs its own check for endpoint failures.

### 5.6 The performance exception

If most loss really happens in one lower layer, a redundant lower-layer mechanism may be worth it as a **performance optimization**.

![[12-Internet.pdf#page=82]]
*Figure: if 90% of loss is in the network, lower-layer recovery may still be worth implementing. (`12-Internet.pdf` p. 82)*

The rule is not “never implement anything below.” It is:

- **Correctness** belongs at the endpoints.
- **Performance optimizations** may be duplicated lower down, if they are incomplete but helpful.

### 5.7 Other end-to-end candidates

The same reasoning applies to:

- **encryption** — only endpoints have the keys;
- **first-in-first-out ordering** — the application knows the true order;
- **duplicate message suppression** — only the application knows what counts as a duplicate;
- **multi-message transactions** — only the application knows the transaction boundaries.

![[12-Internet.pdf#page=80]]
*Figure: other places where the end-to-end argument applies. (`12-Internet.pdf` p. 80)*

---

## 6. Firewalls: a deliberate tension

A firewall is a middlebox that inspects traffic and enforces policy. It can protect users, but it also constrains applications.

![[12-Internet.pdf#page=90]]
*Figure: a firewall allows only web and email, blocking a new application. (`12-Internet.pdf` p. 90)*

> [!example] The firewall trade-off
>
> An administrator says: *“Only allow web and email.”*
> A user has a cool new app that uses a different port/protocol → it is blocked.
>
> This is exactly the strong end-to-end warning: functionality placed in the network constrains what applications can do.

---

## 7. Takeaways

- The Internet model has five layers: **application, transport, network, data link, physical**.
- Bottom-up, each layer is an **API**; top-down, each layer **encapsulates** the layer above.
- **IP is the narrow waist**: many link technologies below, many applications above, one network layer in the middle.
- IP is **best effort**; reliability and ordering are optional transport-layer services (TCP) or application responsibilities.
- The **end-to-end argument** says: implement correctness at the endpoints when possible.
- An **incomplete** lower-layer version may be justified as a **performance enhancement**, but not as a replacement for endpoint correctness.
- The **strong** version warns that unnecessary lower-layer functionality is harmful because it constrains applications.
- Firewalls illustrate the tension between network-level policy and application flexibility.

> [!warning] Exam traps
> - Encapsulation adds headers; it is not encryption.
> - The network layer is **IP**; TCP/UDP are transport, not network.
> - IP does **not** guarantee delivery, ordering, or integrity.
> - OSI’s **session** and **presentation** layers are not part of the Internet model.
> - End-to-end correctness is not the same as “the network must never drop a packet.”
> - A lower-layer mechanism can be a **performance optimization** even when it is not a complete correctness solution.
> - The end-to-end argument does **not** forbid all in-network functions; it asks where the *complete* function must live.
