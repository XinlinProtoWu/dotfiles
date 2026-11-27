# Striping — spreading data across disks

**What it is.** Splitting a logical unit of data across several physical disks so
that the arms work in parallel.

| Granularity | What is split | Example |
| --- | --- | --- |
| **Bit-level** | bit $i$ of every byte goes to disk $i$ | 8 disks ⇒ each logical sector is $8 \times 512 = 4096$ bytes, 8× access rate |
| **Block-level** | block $i$ of a file goes to disk $(i \bmod n) + 1$ | $n$ disks, each gets every $n$th block |

**Why it exists.** Two different goals, both served by parallelism: *increase
throughput* of many small independent requests (load balancing), and *reduce
response time* of one large request (fan it out, sum the bandwidth).

**Example.** An 8-disk bit-level array with 512-byte physical sectors appears to
the OS as one disk with 4096-byte sectors. A 4 KB read touches all eight arms at
once, so the transfer rate goes up 8× — but losing any one disk loses every 8th
bit of everything, which is why striping alone is RAID 0.

**Where it appears:** [[chap11_mass_storage]] Section 17

**Related:** [[terms/RAID]]
