# SSD — Solid-State Disk

**What it is.** Non-volatile memory (flash, or battery-backed DRAM) packaged with
a controller so it looks like a block device: SLC vs MLC flash cells, no platters.

**Why it exists.** A magnetic disk is <1 ms fast only if you never move the arm.
Flash has **no seek time and no rotational latency**, so the random-access penalty
that drove all of Chapter 11's scheduling disappears.

| Property | HDD | SSD |
| --- | --- | --- |
| Moving parts | yes (arm, spindle) | none |
| Random vs sequential | huge gap | small gap |
| Power | higher | lower |
| Cost per MB | low | high |
| Capacity | larger | smaller |
| Lifespan | mechanical wear-out | limited write/erase cycles |
| Bus bottleneck | disk is the limit | the interface can be the limit |

**Example.** The 15 000 RPM disk of Section 4 delivers $0.68\,\text{MB/s}$ on
random 4 KB reads but $125\,\text{MB/s}$ sequentially. An SSD's random and
sequential rates are within a factor of a few — which is why SSDs are often
attached straight to the PCIe bus rather than behind a disk-oriented interface.

**Where it appears:** [[chap11_mass_storage]] Section 5

**Related:** [[terms/seek-time]] · [[terms/RAID]]
