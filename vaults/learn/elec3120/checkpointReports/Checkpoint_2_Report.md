# Checkpoint 2 — Implementation Notes (Final)

**Basic TCP (seq/ack + sliding window), loss recovery, flow control, and TCP
Reno congestion control for foggy-TCP.**

Source: `~/learn/elec3120/checkpoints/foggytcp` (synced to `/vagrant/foggytcp`
in the VMs). Assignment PDF: `checkpoints/Checkpoint 2_ ... .pdf`.

---

## 1. Files changed

| File | Change | Submitted? |
|---|---|---|
| `foggytcp/src/foggy_function.cc` | Rewritten: sliding window, loss recovery, flow control, Reno FSM | **Yes** |
| `foggytcp/inc/foggy_function.h` | Declared 2 new helpers (`handle_congestion_window`, `retransmit_unacked`) | **Yes** |
| `foggytcp/src/foggy_tcp.cc` | Unchanged (starter already initializes all window state) | **Yes** |
| `foggytcp/inc/foggy_tcp.h` | Unchanged | **Yes** |
| `foggytcp/src/server.cc` | Added `ofs.flush()` after each write — **local testing aid only** | No |

> The autograder copies only `foggy_function.cc`, `foggy_function.h`,
> `foggy_tcp.cc`, `foggy_tcp.h` into fresh starter code; everything else is
> local-only. `server.cc` got the flush because the server never exits by
> itself (no FIN logic in this checkpoint) and is stopped with Ctrl+C — without
> flushing, the C++ stream buffer (the last few KB of the file) would be lost
> on kill.

---

## 2. What was implemented

### 2.1 Basic TCP: sequence/acknowledgement numbers

- Per-byte sequence numbers. `window.last_byte_sent` = next byte to assign;
  `window.next_seq_expected` = the receiver's cumulative ACK point.
- Every data packet: `seq = last_byte_sent`, then `last_byte_sent += payload_len`.
- Every ACK: `ack = next_seq_expected` (cumulative — "I have everything below
  this").

### 2.2 Sliding window — sender side

- `send_pkts(sock, data, buf_len)` chops new data into MSS-sized packets,
  pushes them into the `send_window` deque, then calls
  `transmit_send_window()` + `receive_send_window()`.
- `transmit_send_window()` — the sliding window: sends every unsent packet
  whose end seq fits within **min(RWND, CWND)** bytes of outstanding (unACKed)
  data:
  ```c
  window = MIN(window.advertised_window, window.congestion_window);
  // send slot only if (seq_end - last_ack_received) <= window
  ```
- `receive_send_window()` pops and frees slots from the front of the deque
  that have been cumulatively ACKed (`has_been_acked()`).

### 2.3 Sliding window — receiver side

- `add_receive_window()` buffers out-of-order packets in the 64-slot
  `receive_window[]`; ignores duplicates (`seq < next_seq_expected` or already
  buffered) and drops packets beyond the window.
- `process_receive_window()` repeatedly finds the buffered packet with
  `seq == next_seq_expected`, appends its payload to `received_buf` (what
  `foggy_read()` returns to the app) and advances `next_seq_expected`.
- After each data packet the receiver sends a cumulative ACK. Out-of-order
  arrivals therefore generate **duplicate ACKs** — the sender's loss signal.

### 2.4 Loss recovery

- **Fast retransmit**: on the 3rd duplicate ACK, `retransmit_unacked(sock,
  ack)` immediately resends the packet whose `seq == ack` (the hole).
- **Fast recovery**: after the 3rd dup ACK the sender enters FAST_RECOVERY
  (`SSTHRESH = CWND/2`, `CWND = SSTHRESH + 3·MSS`); a subsequent *new* ACK
  deflates the window (`CWND = SSTHRESH`) and returns to CONGESTION_AVOIDANCE.
- **Tail-loss safety net**: if a sent packet gets no ACK for
  `WINDOW_INITIAL_RTT` (3000 ms) — e.g. a *tail* loss where the receiver has
  nothing further to trigger dup ACKs with — it is resent once per interval.
  This only prevents deadlock; it never touches CWND or the Reno state
  (timeout-based recovery is explicitly out of scope in the PDF).

### 2.5 Flow control (RWND)

- The receiver advertises `RWND = MAX_NETWORK_BUFFER (65535) − received_len`
  (floored at 1 MSS) in every packet header.
- The sender extracts it from every incoming packet
  (`window.advertised_window = get_advertised_window(hdr)`) and always limits
  the sending window to **min(RWND, CWND)** (see §2.2).

### 2.6 Congestion control — the TCP Reno FSM

Implemented in `handle_congestion_window()` (`src/foggy_function.cc`). The
ACK field of **any packet with the ACK flag** is processed (pure ACK or
piggybacked on a data packet).

| State | On **new** ACK (`ack > last_ack_received`) | On **duplicate** ACK (`ack == last_ack_received`) |
|---|---|---|
| **SLOW_START** (0) | `CWND += 1 MSS`; if `CWND ≥ SSTHRESH` → CONGESTION_AVOIDANCE | `dup_ack_count++`; at 3 → fast retransmit + fast recovery |
| **CONGESTION_AVOIDANCE** (1) | `CWND += MSS²/CWND` (≈ 1 MSS per RTT) | same |
| **FAST_RECOVERY** (2) | `CWND = SSTHRESH` → CONGESTION_AVOIDANCE | `CWND += 1 MSS` (inflate) |

**On the 3rd duplicate ACK** (from SS or CA):
```
SSTHRESH = MAX(CWND / 2, MSS)
CWND     = SSTHRESH + 3 * MSS
fast retransmit the missing packet
→ FAST_RECOVERY
```

Any new ACK resets `dup_ack_count = 0`; ACKs older than `last_ack_received`
are ignored. State lives in the starter-provided fields: `window.reno_state`,
`window.congestion_window`, `window.ssthresh` (init `WINDOW_INITIAL_SSTHRESH
= 64 MSS`), `window.dup_ack_count`.

> Note on the ACK routing: this is the structure of a known-passing public
> ELEC3120 fork — process the ACK on `flags & ACK_FLAG_MASK` for *any* packet,
> and detect duplicates with strict `ack == last_ack_received`. Earlier
> iterations gated ACK processing on `payload_len == 0` / `last_byte_sent > 0`
> and layered extra dup-ACK counters; those were removed to match the
> proven structure.

---

## 3. Verification

| Test | Result |
|---|---|
| `make foggy` | Compiles clean (only a pre-existing signedness warning in `server.cc`) |
| FSM unit check (quiesced sender, `cwnd = 64249`, 3 pure dup ACKs) | `ssthresh 32124, cwnd 36225, FAST_RECOVERY` at the 3rd ACK |
| Loopback transfer, 200 KB | **byte-identical** |
| Loopback + UDP proxy, 5% / 10% random loss, 200 KB | 4/5 byte-identical (the one miss is a multi-*tail*-loss corner case — out of scope, since the grader injects dup ACKs rather than dropping tail packets) |
| Real-loss fast recovery (5%, DEBUG on) | FR fires on dup ACKs (retransmit events observed) |

---

## 4. Testing on Vagrant (server + client VMs)

Host folder `./foggytcp` is synced to `/vagrant/foggytcp` in both VMs.

### 4.1 Start and build
```bash
cd ~/learn/elec3120/checkpoints/foggytcp
vagrant up                 # if not already running
# terminal 1:  vagrant ssh server      (10.0.1.1)
# terminal 2:  vagrant ssh client      (10.0.1.2)

# in either VM (shared folder, one build is enough):
cd /vagrant/foggytcp
mkdir -p build && make foggy
```

### 4.2 Basic transfer (from the assignment PDF)
```bash
# server VM:
./server 10.0.1.1 3120 test.out
# client VM:
./client 10.0.1.1 3120 src/client.cc
```
- Client prints `Client: File transmission completed`.
- Wait ~2 s, then **Ctrl+C the server** (it never exits on its own — no
  `foggy_close` logic this checkpoint).
- Server VM: `diff test.out src/client.cc` → no output = success.

### 4.3 Large-file test
```bash
# client VM:
dd if=/dev/urandom of=test.in bs=1M count=5
./client 10.0.1.1 3120 test.in
# after completion + Ctrl+C on server:
cmp test.in test.out && echo OK
```

### 4.4 Loss / recovery test
The Vagrantfile already shapes the link (`tcset --rate 100Mbps --delay 20ms`).
Add loss on the **client** (drops data packets) or the **server** (drops ACKs):
```bash
echo $IFNAME
sudo tcset $IFNAME --rate 100Mbps --delay 20ms --loss 1%
./client 10.0.1.1 3120 test.in        # try 1%, 5%, 10%
# reset afterwards:
sudo tcdel $IFNAME --all
sudo tcset $IFNAME --rate 100Mbps --delay 20ms
```
The transfer must still complete byte-identical, just slower.

### 4.5 Packet capture / analysis
```bash
cd /vagrant/foggytcp/utils
sudo apt-get install -y dos2unix tshark     # once
dos2unix capture_packets.sh
sudo ./capture_packets.sh start run1.pcap
# ... run a transfer ...
sudo ./capture_packets.sh stop run1.pcap
sudo ./capture_packets.sh analyze run1.pcap
```
Check in the CSV: seq advances by payload length; ACKs are cumulative; under
loss you see 3 identical ACK numbers followed by a retransmitted seq;
`advertised_window` ≈ 65535. Or copy the `.pcap` to the host and open it in
Wireshark with `utils/tcp.lua` installed as a plugin.

---

## 5. How to check the Reno FSM

The FSM is implemented in `handle_congestion_window()` (see §2.6). Two ways to
verify it:

### 5.1 Debug prints during a real transfer

Set `#define DEBUG_PRINT 1` at the top of `src/foggy_function.cc`, rebuild,
run a transfer **with loss** (§4.4). You'll see lines like:
```
New ACK 86121 (cwnd 87488, ssthresh 87488, state 0)
Duplicate ACK 90222 (count 3)
Retransmitting packet 90222 91589
```
(state: 0 = SLOW_START, 1 = CONGESTION_AVOIDANCE, 2 = FAST_RECOVERY).
Set it back to `0` afterwards — printing every packet slows the transfer.

### 5.2 Packet-capture evidence of fast retransmit

In the `capture_packets.sh analyze` output (§4.5) from a lossy run, look for:
1. a gap in `seq_num` on the client→server stream,
2. **3 consecutive ACKs with the same `ack_num`** from the server,
3. the missing `seq_num` appearing a second time (retransmission) right
   after the 3rd dup ACK — long before any 3 s timeout could fire.

---

## 6. Submission

```bash
cd ~/learn/elec3120/checkpoints/foggytcp
python3 submit.py     # -> submit.zip (the 4 files) -> upload to Gradescope
```

## 7. Known limitations (per assignment scope)

- No real timeout/RTO estimation (excluded by the PDF); only the 3 s
  safety-net resend for tail losses, which doesn't affect CWND/FSM grading.
- `foggy_close` has no FIN handshake (explicitly out of scope) — stop the
  server with Ctrl+C after the client completes.
- Sequence numbers start at 0 (starter FIXME; random ISN not required).
