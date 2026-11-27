# 14 — File-System Implementation

> Source: `Chapter14.pdf`. Goal: how the interface of
> [[chap13_file_system_interface]] is actually built — layered software, the
> on-disk and in-memory structures, three block-allocation methods and their
> pointer-cost arithmetic, and four free-space representations. Assumes
> [[chap11_mass_storage]] (blocks, seeks) and [[chap13_file_system_interface]]
> (files, FCBs, directories).

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Blocks and metadata:** [[terms/logical-block]] · [[terms/FCB]] · [[terms/open-file-table]]

**Layout of file contents:** [[terms/file-allocation]] · [[terms/FAT]] · [[terms/free-space-management]]

**Names:** [[terms/directory-structure]] · [[terms/mount]]

---

## 1. Why disks, and why blocks

Two properties of a disk make it the natural home of a file system:

1. **It can be rewritten in place** — read a block, modify it, write it back to the
   same spot. (Flash cannot do this; it must erase a whole erase-block first, which
   is why an SSD needs a flash translation layer.)
2. **It can access any block directly** — so a file may be read sequentially or
   randomly, and switching files costs only a seek plus a rotation.

I/O between memory and disk moves in units of **blocks**, each holding one or more
sectors. Sector sizes run from 32 B to 4096 B, usually 512 B.

**In plain words.** A file system is a filing cabinet that refuses to work in
anything smaller than a whole drawer. You may open any drawer you like, and you
may pull it out, change one folder and push it back — but you cannot change a
single sheet without handling the whole drawer. So every design decision below is
about *which* drawers a file occupies, and *where to write down* that list.

**Example (traced).** A 4 KB block holding eight 512-byte sectors. A 1-byte
`write()` costs a full block read-modify-write: read 4096 B, change 1, write
4096 B. `dd` with a one-byte block size, writing 1000 bytes, therefore touches
1000 blocks — 4 MB of
traffic for 1 KB of data, which is why unbuffered small writes are pathological.

![[Chapter14.pdf#page=4]]
*Figure: the two disk properties that make file systems possible, and the block as the unit of transfer. (`Chapter14.pdf` p. 4)*

---

## 2. The layered file system

| Layer | Given | Does |
| --- | --- | --- |
| **I/O control** (device drivers + interrupt handlers) | "read drive1, cylinder 72, track 2, sector 10 into memory 1060" | emits device-specific controller commands |
| **Basic file system** | "retrieve block 123" | buffers and caches; allocates/frees/replaces buffer space; issues generic read/write of physical blocks |
| **File organisation module** | a logical block number | knows files, their logical blocks and physical blocks; translates logical → physical; manages free space and block allocation |
| **Logical file system** | a pathname | manages metadata — directory structure, FCBs, file protection; turns a name into a file handle |

**Buffers** hold data **in transit** (a memory buffer is allocated *before* the
disk block arrives). **Caches** hold frequently used **metadata**. A **file control
block (FCB)** — called an **inode** in Unix — holds ownership, permissions and
location of the contents.

**In plain words.** Posting a parcel. You give the counter clerk a *name and
address* (logical file system). The sorting office turns that into *which van and
which route* (file organisation). The depot turns the route into *which shelf in
which warehouse* (basic file system). The driver finally turns the shelf into
*steering the truck* (I/O control). Each layer knows only its own two neighbours,
so you can change the roads without re-addressing the parcel — and pay for that
indirection in time on every delivery.

**Example (traced).** `read(fd, buf, 4096)`:

1. Logical: `fd` already points at an in-memory FCB, so no directory walk. Take the
   file offset $o = 8192$ ⇒ logical block $k = 2$ of the file.
2. File organisation: look up the file's allocation entry for block 2 — say it
   maps to physical block 7314; check the free-space map is not consulted (this is
   a read); hand 7314 down.
3. Basic file system: is block 7314 in the buffer cache? If yes, copy it out — the
   disk is never touched. If no, allocate a buffer and issue the read.
4. I/O control: driver computes cylinder/track/sector for 7314 and waits for the
   seek plus rotation (Chapter 11) — about 9 ms, versus about 1 µs for steps 1–3.

Layering cuts complexity; the deck notes it also **adds overhead and can decrease
performance**. That is the honest trade.

![[Chapter14.pdf#page=6]]
*Figure: the layered file system. (`Chapter14.pdf` p. 6)*

> [!note] Many file systems coexist
> CD-ROM: ISO 9660 · Unix: UFS, based on FFS · Windows: FAT, FAT32, NTFS ·
> Linux: 40+ types, including ext2/ext3 · new ones still arriving: ZFS,
> GoogleFS, Oracle ASM, FUSE.

---

## 3. On-disk structures

| Structure | Scope | Holds | UFS name | NTFS name |
| --- | --- | --- | --- | --- |
| **Boot control block** | per volume | how to boot an OS from this volume (may be empty) | boot block | partition boot sector |
| **Volume control block** | per volume | total blocks, free blocks, block size, free-block list, #FCBs, free FCB count | superblock | in the master file table |
| **Directory structure** | per file system | file names → inode numbers | — | master file table |
| **Per-file FCB** | per file | unique id, permissions, size, dates, block pointers | inode | one row in MFT |

**In plain words.** A warehouse has one gatehouse (boot block — how to get in), one
ledger of what space is empty (volume control block), one directory board of what
is stored where (directory structure), and one index card per consignment (FCB).
Lose the ledger and you no longer know what is free; lose the cards and the
consignments are present but unnamed.

**Example (traced).** An ext4 volume: the superblock records, say, 2 621 440 blocks
of 4096 B $\approx 10$ GB, with 1 310 720 free — `df` reads exactly this. The
inode table has a fixed number of inodes; `df -i` shows `IUsed`/`IFree`. Creating a
file therefore needs **two** separate resources: a free inode *and* a free data
block. Running out of inodes while blocks remain is a real failure mode on ext4.

![[Chapter14.pdf#page=10]]
*Figure: on-disk file-system structures and their UFS/NTFS names. (`Chapter14.pdf` p. 10)*

![[Chapter14.pdf#page=11]]
*Figure: a typical file control block (FCB) — the fields an inode carries. (`Chapter14.pdf` p. 11)*

---

## 4. In-memory structures, and the path of an `open()`

Loaded at mount, updated during operation, discarded at dismount:

| Structure | Holds |
| --- | --- |
| **Mount table** | one entry per mounted volume |
| **Directory-structure cache** | recently accessed directory info |
| **System-wide open-file table** | a copy of the FCB of each open file, plus the **file count** |
| **Per-process open-file table** | a pointer into the system-wide table, current offset, access mode |
| **Buffers** | file-system blocks in transit |

The `open()` sequence:

1. `open()` passes a **pathname** to the logical file system.
2. If the file is **already open by another process**, only a new *per-process*
   entry is created, pointing at the existing system-wide entry. The directory is
   not searched.
3. Otherwise, search the directory structure (possibly cached). Create a
   system-wide entry *and* a per-process entry; copy the **FCB into memory**.
4. The per-process entry records the current location (for the next `read`/`write`)
   and the access mode.
5. `open()` **returns a pointer to the per-process entry** — a **file descriptor**
   in Unix, a **file handle** in Windows.

Every subsequent operation uses that pointer, so the directory is never touched
again for this file.

**In plain words.** The first time you ask for a book, the librarian walks to the
catalogue, finds the card, copies it to the desk, and gives you a numbered slip.
Every later request shows the slip; nobody walks to the catalogue again. Two
people reading the same book share the one catalogue card at the desk but each has
their own slip with their own bookmark.

**Example (traced).** 10 000 `read()` calls on one file:

- With `open()` once: 1 directory walk (say 4 disk blocks = 1 seek + rotation
  $\approx 9\,\text{ms}$), then 9999 lookups in the per-process table ($\approx$
  microseconds each). Total directory cost $\approx 9\,\text{ms}$.
- Without caching — reopening each time: $10{,}000 \times 9\,\text{ms} = 90\,\text{s}$
  of pure directory I/O. This is the entire reason `open()` exists as a separate
  call.

![[Chapter14.pdf#page=13]]
*Figure: the structures and steps involved in opening a file. (`Chapter14.pdf` p. 13)*

![[Chapter14.pdf#page=14]]
*Figure: reading a file through the file-descriptor pointer. (`Chapter14.pdf` p. 14)*

### The API the deck lists

| Call | Meaning |
| --- | --- |
| `open(path, flags, mode)` | open, and possibly create (`O_CREAT`); returns a file descriptor |
| `read(fd, buf, count)` | read up to `count` bytes into `buf` |
| `write(fd, buf, count)` | write up to `count` bytes from `buf` |
| `lseek(fd, offset, whence)` | reposition the file offset |
| `close(fd)` | close |
| `dup(fd)` | new descriptor for the **same** open file |
| `cat` | (a program, not a syscall) dump the file to stdout |

**In plain words.** `dup` is worth remembering: it makes a *new slip for the same
book at the same desk card*, so both descriptors share one file offset. That is why
`dup2` is the standard way to wire a pipe into a child's `stdin` — the child ends up
reading from the same open file description the pipe write end is attached to.

**Example (traced).** `fd1 = open("f")` → descriptor 3, offset 0.
`fd2 = dup(fd1)` → descriptor 4, **same** offset. `read(fd1, buf, 100)` moves the
offset to 100; `read(fd2, buf, 100)` now returns bytes **100–199**, not 0–99.
Contrast `fd3 = open("f")` which gets a *new* system-wide entry and its own offset 0.

---

## 5. Directory implementation

| Method | Mechanism | Cost |
| --- | --- | --- |
| **Linear list** | names with pointers to data blocks; scan from the top | simple to program; search is $O(n)$ |
| — sorted / linked list | ordered alphabetically | search still linear in the worst case |
| — **B+ tree** | balanced tree keyed on name | $O(\log n)$, used by NTFS/ext4 `htree` |
| **Hash table** | hash the name to a bucket | near-$O(1)$ search; **collisions**; fixed table size |

Mitigations: cache frequently used directory information in memory.

**In plain words.** A linear list is a shopping list you read from the top every
time — fine for ten items, painful for ten thousand. A hash table is a set of
pigeonholes labelled by the first letter of the name: you go straight to the right
hole, but if too many names start with "S" the hole overflows into a chain, and you
cannot easily add more pigeonholes once the cabinet is built.

**Example (traced).** A directory with 10 000 entries, one 4 KB block holding 64
entries. A linear search averages 5000 entries $= 78$ blocks read ⇒ ~78 seeks. A
hash table with 128 buckets averages $10{,}000/128 = 78$ entries $= 1.2$ blocks ⇒
1 seek. The cost is the fixed bucket count: grow to 1 000 000 files and the
buckets become 7800-entry chains, so the table must be rebuilt.

![[Chapter14.pdf#page=16]]
*Figure: linear-list and hash-table directory implementations. (`Chapter14.pdf` p. 16)*

---

## 6. Allocation 1 — contiguous

Each file occupies a **set of contiguous blocks**. The directory stores only the
**start block** and the **length**.

| | |
| --- | --- |
| **Strength** | best performance; sequential *and* direct access are trivial ($\text{block} = \text{start} + k$) |
| **Weakness 1** | finding a hole big enough is the dynamic storage-allocation problem again |
| **Weakness 2** | growing a file may require moving it |
| **Fragmentation** | **external** — free space exists but in unusable pieces |
| **Fill strategy** | first-fit and best-fit beat worst-fit |
| **Compaction** | may take hours on a big disk; often only offline with the system unmounted |
| **Best for** | files whose size is known at creation (CD-ROM, DVD, write-once media) |
| **Risk** | over-estimating the size ⇒ **internal** fragmentation |

**In plain words.** Book a whole row of seats on a train for your group. Nobody
else can sit between you, so everyone boards fast — but if your group grows by one
you must all move to another carriage, and the gap you left is too small for the
next group that arrives.

**Example (traced).** Disk of 100 blocks. Files allocated in order: A needs 20,
B needs 15, C needs 30, D needs 10 (blocks 0–19, 20–34, 35–64, 65–74). Free:
75–99 (25 blocks). Delete B ⇒ free is 20–34 (15) and 75–99 (25) — 40 free blocks,
but **no contiguous run of 30**. File E needing 30 is refused even though the disk
is 40 % empty: that is external fragmentation. Compaction would slide C and D down
and merge the holes, at the cost of rewriting 40 blocks.

![[Chapter14.pdf#page=18]]
*Figure: contiguous allocation — start + length, and external fragmentation. (`Chapter14.pdf` p. 18)*

### Extent-based variant

Instead of one run per file, a file is a list of **extents**, each a
`(disk pointer, length)` pair. Files (Veritas and most modern systems) use this.

**In plain words.** Instead of one long row of seats, book two shorter rows in
different carriages. You lose a little speed when the train moves between carriages,
but you can always find *somewhere* to sit — which matters because on a big disk a
long contiguous run may simply not exist any more.

**Example (traced).** A 10-block file as one extent = `(100, 10)`: 1 pointer, 1
seek. As three extents `(100, 4) (400, 3) (250, 3)`: 3 pointers, 3 seeks, but it
could be placed on a badly fragmented disk where no 10-run exists. The directory
entry grows from 2 numbers to 6.

![[Chapter14.pdf#page=19]]
*Figure: extent-based allocation — a file is a list of (pointer, length) pairs. (`Chapter14.pdf` p. 19)*

---

## 7. Allocation 2 — linked

Each file is a **linked list of blocks**, scattered anywhere on the disk. The
directory stores the **first and last** block; each block stores a pointer to the
next; the chain ends at a null (end-of-list) pointer.

| | |
| --- | --- |
| **Strengths** | no external fragmentation; **no compaction ever needed**; a file grows as long as any free block exists |
| **Weakness 1** | direct access is terrible — you must walk the chain (only good for sequential) |
| **Weakness 2** | pointer overhead: a 4-byte pointer in a 512-byte block wastes $4/512 = 0.78\%$ |
| **Weakness 3** | reliability — lose or corrupt one pointer and the rest of the file is unreachable |

**In plain words.** A treasure hunt: each clue tells you where the next clue is.
Adding a clue is easy (put it anywhere and point to it) and the hunt never needs
tidying up — but you cannot jump to clue 40, you must walk through 39 first, and if
someone smudges clue 12 the rest of the hunt is lost.

**Example (traced).** Block size 512 B, pointer 4 B ⇒ 508 usable bytes per block;
the deck's $4/512 = 0.78\%$ overhead. For a 100 MB file that is
$100\,\text{MB} \times 0.0078 \approx 0.78\,\text{MB}$ of pure pointers — and
because usable capacity is 508 not 512, the file needs
$\lceil 100 \times 2^{20} / 508 \rceil = 206{,}413$ blocks instead of 204 800.

To read byte $5 \times 508 = 2540$ (block 5 of the file) you must fetch blocks 1,
2, 3, 4, 5 — five seeks instead of one. That is the direct-access penalty.

![[Chapter14.pdf#page=20]]
*Figure: linked allocation — first/last pointer in the directory, next pointer in each block. (`Chapter14.pdf` p. 20)*

![[Chapter14.pdf#page=21]]
*Figure: linked allocation on disk. (`Chapter14.pdf` p. 21)*

---

## 8. Allocation 3 — FAT

**FAT** = File Allocation Table. Linked allocation with the pointers collected into
one table at the start of the volume, one entry per block, indexed by block number.

| Entry | Meaning |
| --- | --- |
| `0` | block free — and this doubles as the free-space map |
| `n` | next block of this file is $n$ |
| special value | end of file |

The directory entry holds only the **first** block. The chain is followed through
the table, and because the table is small it is **cached in memory**, so random
access no longer requires walking the disk.

**In plain words.** The treasure hunt, but all the clues are copied onto one sheet
of paper at the front of the box. Now finding clue 40 is instant — you read the
sheet instead of tramping around — though you still have to fetch actual clue 40
from wherever it was buried. And the sheet's blank lines tell you exactly which
burial plots are unused.

**Example (traced).** The deck's file occupies blocks **217, 618, 339**.

| Block | FAT entry | Meaning |
| --- | --- | --- |
| 217 | 618 | next is 618 |
| 618 | 339 | next is 339 |
| 339 | EOF | last block |

Directory entry: `217`. Reading the 3rd block of the file: `FAT[217] = 618`,
`FAT[618] = 339`, `FAT[339] = EOF` ⇒ block 339 is the 3rd block — and the lookup
cost zero disk I/O. Compare plain linked allocation, where finding block 3 meant
reading blocks 217 and 618 *from disk* first.

Allocating a new block = find the first `0`-valued entry, point the old last entry
at it, write EOF there. Cost: a scan of the FAT in memory, plus one block write.

![[Chapter14.pdf#page=22]]
*Figure: FAT as an important variation on linked allocation. (`Chapter14.pdf` p. 22)*

![[Chapter14.pdf#page=23]]
*Figure: a FAT example — the file consists of blocks 217, 618 and 339. (`Chapter14.pdf` p. 23)*

---

## 9. Allocation 4 — indexed

Bring **all the pointers of one file together into a single index block**. The
directory entry points at the index block; the index block is an array of data-block
addresses.

| | |
| --- | --- |
| **Strengths** | direct access without walking; no external fragmentation (any free block fits) |
| **Weakness 1** | still suffers linked allocation's *performance* problem — data blocks may be spread over the volume (the index block can be cached, the data cannot) |
| **Weakness 2** | wasted space for small files: a 1-block file consumes an entire index block |

**In plain words.** A table of contents at the front of each file. Jumping to
chapter 12 is instant — read the contents page, then go straight there. But a
one-page memo still needs a whole contents page, so short files waste a block each,
and the chapters themselves are still scattered around the library.

**Example (traced).** Block 4096 B, pointer 4 B ⇒ $4096/4 = 1024$ pointers per index
block ⇒ a single index block addresses 1024 data blocks $= 4\,\text{MB}$.

- 1-block file: 1 data block + 1 index block = **2 blocks for 1 block of data**
  (50 % waste). Under linked allocation it would cost 1 block + 4 bytes.
- 1025-block file (4 MB + 1 block): needs **two** index blocks — and now you need a
  way to find the second one. That is the next subsection.

![[Chapter14.pdf#page=24]]
*Figure: indexed allocation — one index block per file, holding pointers to data blocks. (`Chapter14.pdf` p. 24)*

![[Chapter14.pdf#page=25]]
*Figure: an example index table pointing at a file's data blocks. (`Chapter14.pdf` p. 25)*

### When one index block is too small

| Scheme | Mechanism | Consequence |
| --- | --- | --- |
| **Linked** | chain several index blocks together | simple; loses the direct-access advantage at the joints |
| **Multilevel** | a first-level index points at second-level index blocks | $1024^2$ blocks; can go to 3 or 4 levels |
| **Combined** | direct blocks for small files, then single/double/triple indirect | what Unix actually does |

**In plain words.** A library too big for one contents page gets a *contents page
for the contents pages*: page one of the master lists where each chapter's index
is. Two levels of index cover a thousand times more shelves than one.

**Example (traced).** The deck's arithmetic: 4096-byte blocks, 4-byte pointers ⇒
1024 pointers per index block. Two levels ⇒ $1024 \times 1024 = 1{,}048{,}576$
data blocks ⇒ $1{,}048{,}576 \times 4096 = 4\,\text{GB}$. That 4 GB is exactly the
classic 32-bit file-size limit.

![[Chapter14.pdf#page=27]]
*Figure: the multilevel indexing scheme. (`Chapter14.pdf` p. 27)*

### Combined scheme: UNIX UFS

The UFS inode holds 12–15 direct pointers plus single, double and triple indirect
pointers. With 4 KB blocks and 32-bit addresses:

$$1 + 1024 + 1024^2 + 1024^3 \text{ blocks} \approx 4\,\text{TB}$$

The slide's note is a genuinely examinable subtlety: with 32-bit pointers the
*triple* indirect level reaches **more blocks than a 32-bit file offset can
address** — the pointer format limits you before the indexing depth does.

**In plain words.** A filing cabinet with a few drawers you can open directly, then
one index card pointing at a whole tray of drawers, then a card pointing at a tray
of *trays*. Small files never pay for the trays, and huge files never run out.

**Example (traced).** 12 direct + 1 single indirect addresses
$12 + 1024 = 1036$ blocks $= 4{,}243{,}456$ bytes $\approx 4.05\,\text{MB}$. A
4 MB file fits entirely in direct + single indirect with no double indirection. A
1 GB file needs double indirect. The 12 direct pointers exist purely so the
overwhelming majority of files (which are tiny) touch no index block at all.

![[Chapter14.pdf#page=28]]
*Figure: the UNIX UFS combined scheme — direct, single, double, triple indirect. (`Chapter14.pdf` p. 28)*

---

## 10. Comparing the allocation methods

| | Contiguous | Linked | FAT | Indexed |
| --- | --- | --- | --- | --- |
| Directory entry | start, len | first, last | first | index block |
| Sequential | excellent | good | good | good |
| Direct | excellent | terrible | good | excellent |
| External frag. | **yes** | none | none | none |
| Growth | hard | trivial | trivial | trivial |
| Pointer overhead | none | 1 per block | 1 per block (in table) | 1 per block + 1 block/file |
| Small-file waste | internal frag. | 1 pointer | 1 pointer | **1 whole block** |
| Reliability | fine | one bad pointer loses the tail | **table is a single point of failure** | one bad index block loses the file |

> [!important] The trade is always the same three-way choice
> contiguous = fast both ways, hard to grow · linked = easy to grow, bad random
> access · indexed = fast both ways, wasteful on small files and needs a scheme for
> huge ones. Real systems use **combined** indexing because the file-size
> distribution is bimodal: mostly tiny, a few enormous.

---

## 11. Free-space management

The file system keeps a **free-space list**. Four implementations:

| Method | Structure | Best at | Worst at |
| --- | --- | --- | --- |
| **Bit vector / bitmap** | 1 bit per block (`1` = free) | finding the first free block, or $n$ *consecutive* free blocks (word-at-a-time) | needs the whole vector in memory to be efficient; costs space |
| **Linked list** | each free block holds a pointer to the next | costs **zero** extra space | cannot find free extents, and traversing it reads every block — huge I/O |
| **Grouping** | first free block holds addresses of $n$ free blocks; its last entry points at the next group | find many addresses per read | still a linked list underneath |
| **Counting** | each entry is (first block, run length) | tiny when blocks are freed in runs | variable-size records |

**In plain words.** The bitmap is a car park where every space has a light: green
for free, red for taken. You can see at a glance where a long run of spaces is —
but you must keep the whole display panel lit, which costs electricity. The linked
list is a note on each free space saying where the next free space is: costs
nothing, but to find five adjacent spaces you must physically drive to each one.

**Example (traced).** Block size $4\,\text{KB} = 2^{12}$ bytes, disk
$1\,\text{TB} = 2^{40}$ bytes:

$$n = \frac{2^{40}}{2^{12}} = 2^{28}\ \text{blocks}
\qquad
\text{bitmap} = 2^{28}\ \text{bits} = 2^{25}\ \text{bytes} = 32\,\text{MB}$$

32 MB of RAM for a 1 TB volume — fine on a server, not fine on a 64 KB
microcontroller. Worse, it is *proportional to capacity*: a 100 TB volume needs
3.2 GB of bitmap. And the scan to find a free block touches 32 MB of memory, not
the disk, which is why the bitmap must be cached.

Finding 3 consecutive free blocks in a bitmap: scan 64-bit words for a word that is
not zero, then test the low bits. Compare the linked list, where the same query
means reading up to $n$ separate disk blocks.

![[Chapter14.pdf#page=29]]
*Figure: free-space bit map, and the 32 MB bitmap for a 1 TB / 4 KB-block disk. (`Chapter14.pdf` p. 29)*

![[Chapter14.pdf#page=30]]
*Figure: the linked free-space list on disk. (`Chapter14.pdf` p. 30)*

> [!tip] Counting is the extent method in disguise
> A (address, count) free list is exactly the same shape as the extent list used
> for allocation — which is why contiguous allocation and the counting method are
> usually chosen together.

---

## 12. Highlights

- File systems are **layered** — I/O control, basic file system, file organisation
  module, logical file system — to separate "which block" from "which name".
- On disk: boot control block, volume control block (superblock), directory
  structure, per-file FCB (inode). In memory: mount table, directory cache,
  system-wide and per-process open-file tables, buffers.
- `open()` is the expensive step; it returns a per-process pointer (file
  descriptor) so later operations never touch the directory.
- Directory implementation is linear list, hash table, or B+ tree.
- Allocation: **contiguous** (fast, external fragmentation), **linked** (grows
  freely, awful random access), **FAT** (linked + cached table), **indexed**
  (fast random access, wasteful on small files), **combined** (what Unix does).
- Index arithmetic: with 4 KB blocks and 4-byte pointers, 1024 pointers per block;
  two levels reach 4 GB, three levels 4 TB.
- Free space: bitmap (compact, fast multi-block search), linked list (no extra
  space, terrible traversal), grouping, counting.

---

## 13. Exam traps

- *"The bitmap is small because it is one bit per block."* → It is proportional to
  **capacity**: 32 MB per 1 TB at 4 KB blocks. A 100 TB volume needs 3.2 GB.
- *"Linked allocation wastes 0.78 % of a block."* → It wastes 4 bytes **per
  block**, which is 0.78 % of a 512-byte block but only 0.1 % of a 4096-byte
  block; and it also reduces the usable capacity, so files occupy *more* blocks.
- *"FAT needs a pointer inside every data block."* → It does not — that is plain
  linked allocation. FAT moves all pointers into one table, which is precisely why
  random access improves.
- *"Indexed allocation has no space overhead."* → It has **one whole block per
  file** as the index, which is worse than linked allocation for a one-block file.
- *"Two levels of indexing always give 4 GB."* → Only with 4096-byte blocks and
  4-byte pointers. Change the block size and the number changes; the formula is
  $(block/pointer)^2 \times block$.
- *"UFS uses 12 direct pointers because 12 is faster."* → It uses a few direct
  pointers so the majority of files (small) never allocate an index block at all.
- *"Contiguous allocation's problem is internal fragmentation."* → Its main problem
  is **external** fragmentation plus growth. Internal fragmentation appears only
  when the size is over-estimated at creation.
- *"Compaction is cheap."* → It can take hours on a large disk and is often
  restricted to offline, unmounted operation.
- *"A hash-table directory never degrades."* → Its size is fixed, so chains grow
  with the number of files; the table must be rebuilt.
- *"The FCB and the directory entry are the same thing."* → The directory entry
  maps *name → identifier*; the FCB holds the attributes and block pointers keyed by
  that identifier.
- *"`dup()` opens the file a second time."* → `dup()` shares the **same** open file
  description, hence the same offset. Only `open()` creates a new offset.
- *"Layering is free."* → The deck is explicit: layering reduces complexity and
  redundancy but **adds overhead and can decrease performance**.
