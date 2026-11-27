# Seek time — and the other two halves of disk access time

**What it is.** The three delays you pay every time the disk must fetch a block
that is not already in a buffer:

| Component | What moves | Symbol in these notes |
| --- | --- | --- |
| **Seek time** | the arm slides the heads to the right *cylinder* | $t_{\text{seek}}$ |
| **Rotational latency** | the platter spins the right *sector* under the head | $t_{\text{rot}}$ |
| **Transfer time** | the bits stream out of the sector | $t_{\text{xfer}}$ |

**Why it exists.** A disk is mechanical. Electronics are nanoseconds; a metal arm
is milliseconds. Because seek + rotation dominate by five orders of magnitude,
every trick in Chapter 11 (scheduling, striping, caching, SSDs) is an attempt to
*stop paying* them.

**Example.** A 7200 RPM drive spins $7200/60 = 120$ times per second, so one full
turn takes $1/120\,\text{s} = 8.33\,\text{ms}$. On average the sector is halfway
round, so $t_{\text{rot}} = 4.17\,\text{ms}$. Add a 5 ms average seek and the
4 KB transfer itself ($0.03\,\text{ms}$) is noise:

$$t_{\text{access}} = t_{\text{seek}} + t_{\text{rot}} = 5 + 4.17 = 9.17\,\text{ms}$$

**Where it appears:** [[chap11_mass_storage]] Sections 2–4

**Related:** [[terms/disk-scheduling]] · [[terms/SSD]] · [[terms/logical-block]]
