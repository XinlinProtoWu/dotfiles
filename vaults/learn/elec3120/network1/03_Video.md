# 03 — Video Streaming

> Source: `03-Video.pdf`. Goal: how on-demand video works, why buffering is essential, and how adaptive bitrate streaming chooses quality.

## 1. Two classes of video

| Type | Definition | Examples |
|---|---|---|
| **On-demand** | Pre-recorded content, played when the user requests it | YouTube, Netflix, TikTok |
| **Real-time** | Active communication, played as soon as it reaches the client | Zoom, Skype, video calls |

“Live” streaming (e.g. a news broadcast) sits between the two: it is not interactive, but it is played close to real time. This lecture focuses on **on-demand** video.

---

## 2. Why not just download the whole file?

- The client would wait a long time before playback starts.
- The client would need enough storage for the entire video.
- Better: start playing after downloading only the first few seconds, and keep downloading in the background.

### Progressive download

![[03-Video.pdf#page=17]]
*Figure: progressive download — the server fills a small buffer, and the client reads from the buffer. (`03-Video.pdf` p. 17)*

- The **buffer** stores a small window of upcoming video, not the whole file.
- The client starts playback once enough data is buffered.
- Download and playback proceed concurrently.

---

## 3. The buffer model

Let:

- `C` = rate at which data arrives into the buffer (network/server rate, bits/s)
- `R` = **video bitrate** = rate at which the client reads/plays data (bits/s)
- `b` = buffer occupancy at the moment playback starts (bits)
- `t` = time since playback started

Then:

```text
A(t) = C·t + b        (cumulative data that has arrived)
S(t) = R·t            (cumulative data played)
buffer occupancy = A(t) − S(t)
```

![[03-Video.pdf#page=29]]
*Figure: arrival curve A(t) = C·t + b; b is the buffer occupancy when playback starts. (`03-Video.pdf` p. 29)*

![[03-Video.pdf#page=31]]
*Figure: playback curve S(t) = R·t overlaid on the arrival curve. (`03-Video.pdf` p. 31)*

- If `C > R`, the buffer **grows** over time.
- If `C < R`, the buffer **drains** at rate `R − C`.
- If `C = R`, buffer occupancy stays constant.

### Stall condition

A stall (playback stops) happens when the buffer hits zero. With `C < R`, this occurs at:

```text
C·t + b = R·t   →   t = b / (R − C)
```

To avoid stalling for a video of length `f`, you need enough initial buffer:

```text
b ≥ (R − C)·f
```

![[03-Video.pdf#page=34]]
*Figure: buffer becomes empty at t = f — ideally this is exactly when playback finishes. (`03-Video.pdf` p. 34)*

> [!example] Worked example from the slides
> `C = 6 Mb/s`, `R = 8 Mb/s`, video size = 3 GB = 24,000 Mb.
>
> 1. Playback time: `f = 24,000 / 8 = 3,000 s`.
> 2. Required initial buffer: `b = (R − C)·f = 2 × 3,000 = 6,000 Mb = 750 MB`.
> 3. Pre-download time: `k = b / C = 6,000 / 6 = 1,000 s ≈ 16.7 min`.
>
> This is why a bitrate higher than the network capacity is painful: you need a huge buffer and a long startup wait.

### The mismatch problem

![[03-Video.pdf#page=40]]
*Figure: if R is much larger than C, the buffer drains and playback stalls. (`03-Video.pdf` p. 40)*

- If `R > C`: need a large buffer and long startup; otherwise stall.
- If `R << C`: less buffering, but poor video quality.
- Goal: choose a bitrate close to, but not above, the available capacity.

---

## 4. Multi-bitrate streaming (MBR)

![[03-Video.pdf#page=41]]
*Figure: MBR offers several quality levels so the client can choose R ≤ C. (`03-Video.pdf` p. 41)*

- Encode the same video at multiple quality levels (different bitrates/resolutions).
- The client selects a bitrate `R ≤ N`, where `N` is the network capacity.
  - (The slide uses `C` for the chosen chunk bitrate and `N` for network capacity; don't confuse that `C` with the network arrival rate above.)
- Smaller `R` → less buffer memory and less startup time, but lower quality.
- Larger `R` → better quality, but more buffering and higher stall risk.

![[03-Video.pdf#page=45]]
*Figure: MBR client selects the largest bitrate that fits below network capacity N. (`03-Video.pdf` p. 45)*

---

## 5. Why buffers are essential

### Network variability

![[03-Video.pdf#page=69]]
*Figure: buffers absorb temporary network drops and refill when the network recovers. (`03-Video.pdf` p. 69)*

- Network capacity varies because of new users, link failures/re-routes, Wi-Fi interference, etc.
- A buffer lets playback continue at the **average** available rate:
  - temporary drop → buffer drains a little;
  - temporary increase → buffer refills.
- A high-variance network needs a **larger** buffer than a low-variance network.
- Without a buffer, any temporary drop immediately causes a stall.

> [!note] Why not remove the buffer?
> A tiny buffer would work only if the arrival rate `C` were perfectly constant. In reality, `C` changes because users join/leave, links fail/re-route, and Wi-Fi interferes. The buffer is what buys time during those changes.

### Playback variability (VBR)

![[03-Video.pdf#page=71]]
*Figure: VBR video — action scenes need many more bits than static scenes. (`03-Video.pdf` p. 71)*

- Video is usually encoded at an **average/target bitrate**, but individual segments vary:
  - action scene: every pixel changes → high bitrate;
  - character asleep/static scene: little new data → low bitrate.
- So the playback rate `R[t]` is variable too. Even if average `C = average R`, short-term mismatch requires buffering.

> [!important] Takeaway
> Buffers convert variable network/playback rates into smooth playback. They let you reason about **average rates** instead of every short-term fluctuation.

---

## 6. HTTP chunking

![[03-Video.pdf#page=76]]
*Figure: HTTP chunking — break video into a few seconds per chunk and download chunks over HTTP. (`03-Video.pdf` p. 76)*

- Break the video into small **chunks** (a few seconds each; Netflix chunks are ~4 s).
- Download chunks over HTTP, in order.
- Play chunks back-to-back so it looks like one continuous video.

### Why this won

Late 1990s/early 2000s: custom protocols such as **RTSP** with dedicated media players. They were tightly integrated and highly optimized, but hard to deploy.

HTTP chunking benefits:

- **Browser playback**: no dedicated app required.
- **“Stupid” servers**: servers just serve small files over stateless HTTP.
- **Caching/CDNs**: chunks are cacheable and easy to distribute.
- **Adaptive bitrate**: switching quality mid-stream is easy because each chunk is independent.

> [!note] “Worse is better”
> The simple, backward-compatible, easy-to-scale design beat the tightly integrated, highly optimized design.

---

## 7. Adaptive bitrate (ABR) and DASH

![[03-Video.pdf#page=80]]
*Figure: HTTP streaming with ABR — client adapts bitrate R[t] to changing capacity C[t]. (`03-Video.pdf` p. 80)*

- **ABR**: change the quality/bitrate of the next chunk to match the underlying network capacity.
- The client is in the best position to decide: it knows the current playback rate and the recent download rate.
- ABR must trade off:
  - video quality (higher is better),
  - stall risk (lower bitrate is safer),
  - startup delay,
  - quality switches (frequent switching is annoying).

### DASH

![[03-Video.pdf#page=81]]
*Figure: DASH — client first requests a manifest describing chunks and available bitrates. (`03-Video.pdf` p. 81)*

**Dynamic Adaptive Streaming over HTTP (DASH)**:

1. Client requests a **manifest** (Media Presentation Description, MPD).
2. Manifest lists **representations** (different bitrates/resolutions) and the URLs/segments for each.
3. Client chooses a representation for each chunk and requests it over HTTP.

![[03-Video.pdf#page=83]]
*Figure: MPD lists representations with different bitrates and frame sizes. (`03-Video.pdf` p. 83)*

ABR algorithms may use many inputs: past capacity, loss rate, latency, bandwidth variance, buffer occupancy, etc.

---

## 8. BBA-0: buffer-based ABR

![[03-Video.pdf#page=90]]
*Figure: Te-Yuan Huang's key idea — buffer occupancy alone is enough for ABR. (`03-Video.pdf` p. 90)*

**BBA-n** (Buffer-Based Approach) argues that you only need **one** parameter: the **buffer occupancy** at the receiver.

### BBA-0 rules

| Buffer state | Interpretation | Action |
|---|---|---|
| Nearing empty | Stall soon if no data arrives | Request **lowest** bitrate |
| Nearing full | Network is not the bottleneck; plenty of content | Request **highest** bitrate |
| In between | Neither safe nor rich | Pick a bitrate between min and max |

![[03-Video.pdf#page=103]]
*Figure: BBA-0 bitrate selection with lower reservoir, cushion, and upper reservoir. (`03-Video.pdf` p. 103)*

### Why reservoirs?

- **Upper reservoir**: if the buffer is completely full, you can never actually play at the maximum bitrate — there is no room to pull in more high-bitrate chunks. Leave headroom so `R_max` is usable.
- **Lower reservoir**: if the buffer is “low but not empty” and the network suddenly drops, you stall. Store extra **playtime** at low bitrate to survive a sudden drop.
- **Cushion**: the middle region where bitrate changes gradually.

### Discrete bitrates

![[03-Video.pdf#page=104]]
*Figure: bitrates are discrete; BBA-0 sticks with the current bitrate until the buffer crosses a neighboring boundary. (`03-Video.pdf` p. 104)*

- Real encodings have discrete quality levels.
- To avoid constant switching, use **hysteresis**: keep the current bitrate unless the buffer crosses the boundary for a neighboring bitrate.

### Extensions

BBA-0 ignores variability in `R[t]` (VBR). Later BBA variants add:

- a **startup** phase analogous to TCP slow start,
- handling of **variable bitrate** encoding,
- analysis for sizing the reservoirs.

Stanford's **Puffer** project tested ABR algorithms on real viewers; BBA remains one of the best despite its simplicity.

---

## 9. Summary

- On-demand video starts playing before the whole file is downloaded.
- The core variables are `C` (network rate), `R` (playback bitrate), and `b` (buffer).
- Buffers hide network and playback variability; larger variance needs a larger buffer.
- **HTTP chunking** made Internet video scale: browser playback, simple servers, caching/CDNs, easy ABR.
- **DASH** uses a manifest + chunks + client-side ABR.
- **BBA-0** uses only buffer occupancy, with upper/lower reservoirs and hysteresis.
