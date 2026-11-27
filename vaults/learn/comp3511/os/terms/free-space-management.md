# Free-space management — bit vectors, linked lists, grouping, counting

**What it is.** The file system's record of which blocks are free. Four standard
representations:

| Method | Structure | Strength | Weakness |
| --- | --- | --- | --- |
| **Bit vector / bitmap** | 1 bit per block, `1` = free, `0` = used | easy to find first free *or* $n$ consecutive free blocks (word-at-a-time scan) | must be in memory to be efficient; costs extra space |
| **Linked list** | each free block stores a pointer to the next | no extra space at all | cannot find the *next free block* address, and traversing it reads every block — huge I/O |
| **Grouping** | first free block holds addresses of $n$ free blocks, last of which points at the next group | find many free addresses in one read | a linked list internally |
| **Counting** | each entry is (first block, run length) | tiny when blocks are allocated in runs | variable-length records |

**Why it exists.** Allocation and free-space tracking are two halves of the same
problem: you cannot allocate a block without knowing one is free, and you cannot
free one without recording it.

**Example.** A 1 TB disk with 4 KB blocks has
$2^{40}/2^{12} = 2^{28}$ blocks, so the bitmap is $2^{28}$ bits $= 32\,\text{MB}$.
That fits in memory easily — but note it is *proportional to disk size*, which is
why `df` on a huge volume shows metadata overhead.

**Where it appears:** [[chap14_file_system_implementation]] Sections 11–12

**Related:** [[terms/FAT]] · [[terms/file-allocation]]
