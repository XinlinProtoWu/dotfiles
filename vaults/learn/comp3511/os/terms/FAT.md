# FAT — File Allocation Table

**What it is.** Linked allocation with the links pulled *out* of the data blocks
and into one table at the start of the volume. The table has one entry per disk
block, indexed by block number:

| Entry value | Meaning |
| --- | --- |
| `0` | block is free |
| *n* | next block of this file is block *n* |
| end-of-file marker | last block of the file |

Used by MS-DOS (and FAT32 on removable media). The directory entry holds only the
**first** block number; the chain is then followed through the table.

**Why it exists.** Plain linked allocation forces a random seek for every block,
because the next pointer lives *inside* the next block. Putting the whole chain in
one small table lets the entire table be cached in RAM, so following a chain costs
zero disk I/O — and the table's `0` entries double as the free-space map.

**Example.** A file occupying blocks 217, 618, 339 appears as
`FAT[217] = 618`, `FAT[618] = 339`, `FAT[339] = EOF`, and the directory entry is
`217`. Reading byte 8000 (block 2 of the file) needs no disk seek to find the
block: look up `FAT[217]`, then `FAT[618]`, both from RAM — but it does need the
block itself, so the arm still jumps 217 → 618.

**Where it appears:** [[chap14_file_system_implementation]] Section 8

**Related:** [[terms/file-allocation]] · [[terms/free-space-management]] · [[terms/logical-block]]
