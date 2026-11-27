# Logical block — the disk's one-dimensional address space

**What it is.** The OS does *not* see cylinders, tracks and sectors. It sees a
flat array of **logical blocks**, numbered from 0, where a block is the smallest
unit of transfer (classically 512 bytes; 4 KB on modern large-sector drives).
Low-level formatting writes those block boundaries onto the physical media.

**Why it exists.** Physical geometry is device-specific, has defective sectors,
and on zoned devices has a *non-constant* number of sectors per track. Hiding all
of that behind "block $n$" lets the file system, the buffer cache and the page
cache work in one uniform currency.

**Example.** Logical block 0 is the first sector of the first track of the
**outermost** cylinder. The mapping then runs along that track, through the rest
of the tracks in that cylinder, then outward→inward through the remaining
cylinders. So block number ≈ $(c \times H + h) \times S + s$. A defective sector
is hidden by remapping it to a spare sector elsewhere on the platter — the
logical number never changes, which is why a `badblocks` area can exist without
the file system noticing.

**Where it appears:** [[chap11_mass_storage]] Section 7 · [[chap14_file_system_implementation]] Section 1

**Related:** [[terms/seek-time]] · [[terms/disk-scheduling]] · [[terms/FAT]]
