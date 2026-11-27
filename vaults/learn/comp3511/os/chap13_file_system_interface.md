# 13 — File-System Interface

> Source: `Chapter13.pdf`. Goal: the *user-visible* contract of a file system —
> what a file is, which operations it supports, how names are organised into
> directories, how a volume is attached to that tree, and how access is
> controlled. The *implementation* behind this contract is
> [[chap14_file_system_implementation]]. Builds on [[chap11_mass_storage]].

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Files and access:** [[terms/FCB]] · [[terms/open-file-table]] · [[terms/logical-block]]

**Names and volumes:** [[terms/directory-structure]] · [[terms/mount]]

**Sharing and protection:** [[terms/ACL]] · [[terms/protection-domain]] · [[terms/least-privilege]]

---

## 1. What a file is

> A file is a **named collection of related information** recorded on secondary
> storage — a contiguous logical address space.

It is a sequence of bits, bytes, lines or records, and *the meaning is defined by
the creator and the user*, not by the OS. That last clause is the whole design
philosophy: the OS supplies the bytes, the application supplies the interpretation.

### File types

| Kind | Contents | Example |
| --- | --- | --- |
| **Ordinary** | user information | text file, executable, database |
| **Directory** | list of names plus related information | `/usr/bin` |
| **Special (device)** | represents a physical device | disk, terminal, printer, tape |
| — character special | handled **character by character** | terminal, printer |
| — block special | handled **in blocks** | disk, tape |

**In plain words.** The OS is a filing clerk who hands you folders and does not
care what is inside them. One folder holds letters, one holds a list of other
folders, and one is not a folder at all but a key to the stationery cupboard —
the clerk hands you the key and steps aside. Because the clerk does not read the
contents, *you* have to agree with your colleagues on what the bytes mean.

**Example (traced).** `/dev/sda` is a block special file; reading it yields the
raw bytes of the disk in blocks. `/dev/tty` is a character special file; reading
it yields whatever characters the user types next. Both are "files" in the
directory — the same `open()`/`read()`/`close()` calls work on both — but the
kernel routes them to completely different drivers.

![[Chapter13.pdf#page=4]]
*Figure: file concept and the three kinds of file. (`Chapter13.pdf` p. 4)*

---

## 2. File attributes

Metadata, not contents:

| Attribute | Meaning |
| --- | --- |
| **Name** | human-readable form |
| **Identifier** | unique tag (number) that names the file *inside* the file system |
| **Type** | needed where the system distinguishes types |
| **Location** | pointer to where the file lives on the device |
| **Size** | current size |
| **Protection** | who may read / write / execute |
| **Time, date, user id** | for protection, security, usage monitoring |

Attributes live in a **directory structure on disk**; the part in use is cached in
main memory. Variants add **extended attributes** (e.g. a file checksum).

**In plain words.** Name and identifier are two different things, and mixing them
up is the classic beginner error: the name is what *you* type, the identifier is
what the *file system* chases. You can rename a file without moving a byte,
because only the name changed; and you can have two names for one file, because
both names point at one identifier.

**Example (traced).** On a Unix file system a file called `report.txt` has, say,
inode number `418572`. `ls -i` shows the number; `stat` shows the attributes.
`mv report.txt final.txt` rewrites one directory entry, leaving inode `418572` and
all its data blocks untouched — which is why a 4 GB `mv` inside the same directory
returns instantly.

![[Chapter13.pdf#page=5]]
*Figure: the file attribute table. (`Chapter13.pdf` p. 5)*

---

## 3. File operations, and the kernel tables behind them

A file is an **abstract data type**: it exposes operations, not fields.

| Operation | Effect |
| --- | --- |
| `create` | make a new file |
| `write` | write at the **write pointer** |
| `read` | read at the **read pointer** |
| `reposition` (`seek`) | move the pointer |
| `delete` | remove |
| `truncate` | keep the file, discard its contents |
| `open(Fi)` | find `Fi` in the directory structure on disk, bring its entry into memory |
| `close(Fi)` | write the in-memory entry back to the on-disk directory structure |

These are not abstract: each one mutates several kernel data structures. Open
files are tracked by

| Structure | Purpose |
| --- | --- |
| **System-wide open-file table** | one entry per open *file* |
| **Per-process open-file table** | one entry per `open()` in this process |
| **File pointer** | last read/write location, **per process** |
| **File-open count** | how many processes have it open; entry is removed at zero |
| **Disk location** | cache of the data-access information |
| **Access rights** | per-process access mode |

**In plain words.** Opening a file is a library check-out. The catalogue (the
directory) is searched once, the book is put on a shelf behind the desk that
everybody can read from (the system-wide table), and each borrower gets a slip
saying where in the book they personally have got to (the per-process table). The
librarian counts how many slips are out so the book can go back to the stacks once
everyone has finished with it.

**Example (traced).** Process A opens `db` → one system-wide entry, count = 1, plus
A's private entry with offset 0. Process B opens the same file → *no* new
system-wide entry, count = 2, plus B's private entry with offset 0. A reads 4 KB:
A's offset becomes 4096, B's stays 0. If B now `fork()`s, the child *inherits B's
descriptor*, so parent and child share the offset — a subsequent read in the parent
moves the child's position too, which is why concurrent readers of a shared
descriptor must synchronise.

![[Chapter13.pdf#page=8]]
*Figure: the structures used to manage open files. (`Chapter13.pdf` p. 8)*

### Type by name

The OS usually infers type from the **name extension**, which is a *convention*,
not a guarantee — nothing stops you naming a shell script `photo.jpg`.

![[Chapter13.pdf#page=9]]
*Figure: common file extensions and the type each implies. (`Chapter13.pdf` p. 9)*

---

## 4. Access methods

| Method | Primitives | Suits |
| --- | --- | --- |
| **Sequential** | `read next`, `write next`, `reset`, (optionally `rewrite` at the end) | compilers, editors, logs — anything processed once through |
| **Direct (relative)** | `read n`, `write n`, `position to n`, `read next`, `rewrite n`; $n$ = relative block number | databases, anything needing random access |
| **Index** | search an index, follow it to the block | large files keyed on a field |

Indexed access is built **on top of** direct access: keep an index in memory, look
up the key, then use direct access to reach the block. IBM's **ISAM** is the
classic: a small master index points at blocks of a secondary index, and the file
is kept sorted on a defined key. VMS offers "index and relative" files.

**In plain words.** Sequential access is a cassette tape: only forwards. Direct
access is a book with page numbers: you can jump straight to page 300. Indexed
access is the book's *index at the back*: you look up "photosynthesis" in the
index and it tells you page 300 — so you get the book's random access with the
index doing the searching for you.

**Example (traced).** A compiler reading a 2 MB source file is pure sequential:
$N$ reads of consecutive blocks, which the disk can service with one seek and then
no movement at all (Section 4 of [[chap11_mass_storage]]). A database doing
a `SELECT` on one `id` value in a 2 GB table needs direct access, or better an index:
scan the in-memory index for `8871 → block 4711`, then one direct read. Without
the index the same query is a 2 GB sequential scan — 50 000× more I/O.

![[Chapter13.pdf#page=10]]
*Figure: sequential and direct access primitives. (`Chapter13.pdf` p. 10)*

![[Chapter13.pdf#page=11]]
*Figure: the index access method, and ISAM. (`Chapter13.pdf` p. 11)*

---

## 5. Directories: what they must be good at

A directory is "a collection of nodes containing information about all files".
Both directories and files reside on disk.

Operations on a directory: **search, create a file, delete a file, list, rename,
traverse the file system.**

Three competing goals:

| Goal | Meaning |
| --- | --- |
| **Efficiency** | locating a file quickly |
| **Naming** | convenient to users: two users may reuse a name; one file may have several names |
| **Grouping** | logical grouping by property (all Java programs, all games, my COMP3511) |

**In plain words.** A directory is a noticeboard. You want to *find* your notice
fast (efficiency), you want to be allowed to pin a notice called "notes" even
though someone else already did (naming), and you want all the notices for one
event kept together (grouping). A single board for the whole building fails the
last two goals; that is why the next four sections are all about adding structure.

![[Chapter13.pdf#page=12]]
*Figure: a directory as a collection of nodes pointing at files. (`Chapter13.pdf` p. 12)*

### Where directories sit on the disk

| Term | Meaning |
| --- | --- |
| **Partition** (minidisk, slice) | a subdivision of a disk |
| **Volume** | a partition (or disk) that contains a file system |
| **Device directory / volume table of contents** | per-volume record of the file system's own info |
| **raw** | a partition used with *no* file system at all |

Volumes may be RAID-protected. Many special-purpose file systems coexist with
general-purpose ones in the same OS.

**In plain words.** A disk is a filing cabinet; a partition is one drawer; a volume
is a drawer that has been *labelled and indexed*. Using a drawer "raw" means
throwing loose papers into it with no index at all — some databases do exactly
that on purpose, because they would rather build their own index than use the
file system's.

**Example (traced).** `lsblk` on a Linux box shows `/dev/nvme0n1` with partitions
`nvme0n1p1` (an EFI system partition, formatted FAT), `nvme0n1p2` (formatted ext4,
mounted at `/`), `nvme0n1p3` (formatted ext4, mounted at `/home`), and maybe
`nvme0n1p4` used raw by a database. Four partitions, three file systems, one raw.

![[Chapter13.pdf#page=14]]
*Figure: a typical file-system organisation — partitions, volumes, file systems. (`Chapter13.pdf` p. 14)*

---

## 6. Directory structures, in order of increasing power

### Single-level

One directory for all users.

**In plain words.** Everybody pins notices on one board in the lobby. Since there
is only one board, two people cannot both pin a notice called "notes" — one has to
rename theirs — and there is no way to keep the accounts team's notices away from
the engineering team's.

**Example (traced).** Alice creates `/report.tex`; Bob tries and the system
refuses or silently overwrites. Both give up and start writing
`alice_report.tex`, `bob_report.tex` — the naming problem leaking into the
users' data. Every operation is a **linear scan** of one ever-growing list.

- Naming problem: **yes**. Grouping problem: **yes**.

![[Chapter13.pdf#page=17]]
*Figure: single-level directory, showing the naming and grouping problems. (`Chapter13.pdf` p. 17)*

### Two-level

One directory per user (UFD) under a master directory (MFD).

**In plain words.** Give every person their own board in the corridor, with a
master board in the lobby listing whose is whose. Now `/alice/notes` and
`/bob/notes` can coexist peacefully. But you still cannot say "these notes and
those drafts belong together" — each person has one flat board.

**Example (traced).** Path names become `/user1/cat`. Searching is more efficient
because you only scan one user's list. Still no grouping capability inside a user.

- Naming: **solved** (same name under different users). Grouping: **still absent**.

![[Chapter13.pdf#page=18]]
*Figure: two-level directory — one directory per user. (`Chapter13.pdf` p. 18)*

### Tree

Arbitrary depth, exactly one parent per node.

**In plain words.** Boards inside boards: the lobby board points at corridor boards,
each corridor board points at room boards. Now names are unique along a path and
you can group freely. The price is that you must know *where you are* — you either
walk from the lobby (an absolute path) or from the board in front of you (a
relative path).

**Example (traced).** `cd /spell/mail/prog` sets the **current (working)
directory**. Then `mkdir count` creates `/spell/mail/prog/count` — relative to the
current directory, not to the root. And `rmdir /spell/mail` deletes **the entire
subtree** rooted at `mail`: `prog`, `copy`, `prt`, `exp`, `count` and everything
under them, in one operation. That is the tree's sharp edge.

- Efficient searching: **yes**. Grouping: **yes**.

![[Chapter13.pdf#page=19]]
*Figure: tree-structured directories. (`Chapter13.pdf` p. 19)*

![[Chapter13.pdf#page=21]]
*Figure: working directory, relative/absolute paths, and deleting a subtree. (`Chapter13.pdf` p. 21)*

### Acyclic graph

A tree plus **links** (aliases): a file or subdirectory reachable by more than one
path, with no cycles.

**In plain words.** You can pin a card on two boards pointing at the same folder —
useful, but now "delete this card" is ambiguous. Do you delete the folder or only
the card? If you delete the folder, the other board's card now points at nothing.

**Example (traced).** `ln /spell/mail/prog /work/prog` gives the directory two
names. Problems to solve:

- **Dangling pointers** — a link whose target was deleted points at nothing, or
  worse, at a *reused* inode (a wrong file).
- **Double traversal** — a recursive `du` or backup must not walk the shared
  subtree twice; you need reference counts or a visited set.
- **Cycles must be prevented** — an acyclic graph must actually stay acyclic,
  which costs bookkeeping on every link creation.

![[Chapter13.pdf#page=23]]
*Figure: acyclic-graph directories — links, aliasing and dangling pointers. (`Chapter13.pdf` p. 23)*

### General graph

Cycles allowed. Two ways to keep it sane:

1. **Allow links to files only**, never to subdirectories — simple, but sometimes
   inconvenient.
2. **Run cycle detection on every new link** — correct, but time-consuming.

**In plain words.** Now a corridor board can point back at the lobby. You can walk
in circles forever, so any "visit everything once" operation needs either a
visited list or garbage collection. This is why real systems restrict links to
files: a hard link to a *directory* is genuinely dangerous, and most OSes forbid
it.

**Example (traced).** The Unix rule: `ln dir1 dir2` (a hard link to a directory)
is refused; only root, and only historically, could do it. Symbolic links to
directories are allowed but are just *paths*, so a loop such as
`/a/link -> /a` makes `find` print a warning and gives up unless you pass
`-L`/`-follow` knowingly.

![[Chapter13.pdf#page=24]]
*Figure: general graph directory — cycles are possible. (`Chapter13.pdf` p. 24)*

> [!important] The four structures in one line each
> single-level: no naming, no grouping · two-level: naming only · tree: naming
> and grouping · graph: naming, grouping and **sharing**, at the cost of dangling
> pointers and cycles.

---

## 7. Mounting

A file system must be **mounted** before it can be accessed — "just like a file
must be opened before it is used". A volume is mounted **at a mount point**, an
existing directory.

**In plain words.** Mounting is plugging a new shelf unit into the library's
labelling scheme: you declare "this shelf belongs under the sign that says
`/users`", and from then on every book on it is findable by a path that starts
there. Before you do that, the books are physically present but have no address
anyone can walk to.

**Example (traced).** A USB stick whose root contains `notes.txt` is invisible at
`/notes.txt`. Mount it at `/media/usb` and it becomes `/media/usb/notes.txt`.
Unmount and the path stops resolving; the `/media/usb` directory itself survives
(empty). Note the mount point's *original* contents are hidden while a volume is
mounted over it — a classic "where did my files go?" trap.

![[Chapter13.pdf#page=26]]
*Figure: an unmounted file system and the mount point where it will be attached (p. 27 is the same figure once the volume is mounted at `/users`). (`Chapter13.pdf` p. 26)*

---

## 8. File sharing

Sharing is desirable, and is done **through a protection scheme**. In a
distributed system, sharing crosses the network — **NFS** (Network File System) is
the common method.

Multi-user sharing needs identities:

| Concept | Purpose |
| --- | --- |
| **User ID (UID)** | identifies a user → per-user permissions |
| **Group ID (GID)** | users in groups → group access rights |
| **Owner** | of a file or directory |
| **Group** | of a file or directory |

**In plain words.** "Sharing" is meaningless without "with whom". The system needs
a name for *you* before it can decide whether to say yes, so a user ID is not a
convenience — it is the thing the permission check is indexed by.

**Example (traced).** A file owned by `alice` with group `staff`. Bob is in
`staff` and is not Alice, so when he opens it the kernel evaluates the *group*
triple of the mode bits, not the owner triple and not the public triple.

![[Chapter13.pdf#page=28]]
*Figure: file sharing — UIDs, GIDs, owner, group, and NFS. (`Chapter13.pdf` p. 28)*

---

## 9. Protection: the six access types

The owner should control **what can be done** and **by whom**. The types of
access the deck lists are:

**read · write · execute · append · delete · list**

**In plain words.** These are six genuinely different questions, and conflating
them is a real security bug. "Append" is not "write": a mailbox you may only append
to is safe, while a mailbox you may *rewrite* lets you destroy yesterday's
messages. "List" is not "read": a directory you may list but not read tells an
attacker the file names without leaking one byte of contents.

**Example (traced).** A drop-box directory with mode `733` — owner `rwx`, group
`-wx`, public `-wx`: anybody may create a file and anybody may overwrite one, but
nobody may *list* it, so you cannot discover the names of the other submissions.
That is append-without-list, which is exactly what an anonymous FTP upload
directory does.

![[Chapter13.pdf#page=29]]
*Figure: the types of access the owner controls. (`Chapter13.pdf` p. 29)*

---

## 10. Access lists and groups: the Unix triple

Unix compresses the whole access matrix row for a file into **nine bits**: three
classes × three operations.

| Class | Bits | Example value | Binary |
| --- | --- | --- | --- |
| **owner** | `rwx` | 7 | `111` |
| **group** | `rwx` | 6 | `110` |
| **public (other)** | `rwx` | 1 | `001` |

$$7 \to 111\ (rwx), \quad 6 \to 110\ (rw\text{-}), \quad 1 \to 001\ (\text{-}\text{-}x)$$

Commands: `chmod 761 game` sets the mode; `chgrp G game` attaches the group `G`;
the manager creates `G` and adds users to it.

**In plain words.** Think of the nine bits as three little switches per audience:
may they read, may they write, may they run it. `761` says "the owner can do all
three, colleagues can read and write but not run it, and everyone else may only
run it" — a game that other people may play but not copy.

**Example (traced).** `chmod 761 game` gives owner `rwx`, group `rw-`, other `--x`.

- Owner `alice` runs it: owner triple `rwx` ⇒ **allowed**.
- Bob, in group `G`, runs it: group triple `rw-` has no `x` ⇒ **denied**.
- Carol, not in `G`, runs it: other triple `--x` ⇒ **allowed**.
- Carol tries to read it (copy the binary): other triple has no `r` ⇒ **denied**.

That last line is the design intent: others may *execute* the game but may not
*copy* it. (Real copy protection needs more than mode bits, but this is the shape.)
Note the order of evaluation: owner first, then group, then other — *first match
wins*, so the owner is never affected by the group bits.

![[Chapter13.pdf#page=30]]
*Figure: access lists and groups — the `rwx` triple, `chmod 761`, `chgrp`. (`Chapter13.pdf` p. 30)*

> [!warning] Nine bits cannot express a general access list
> The Unix triple is an *approximation* of an ACL that assumes exactly three
> audiences. Need one extra person to read a file and nobody else? You cannot say
> it with nine bits — you must create a group, or use POSIX ACLs
> (`getfacl`/`setfacl`), or on Windows edit the object's ACL directly
> (p. 31). Full arbitrary ACLs and capabilities are [[chap17_protection]].

![[Chapter13.pdf#page=31]]
*Figure: Windows 10 access-control list management — an arbitrary per-object ACL. (`Chapter13.pdf` p. 31)*

![[Chapter13.pdf#page=32]]
*Figure: a sample UNIX directory listing — mode, links, owner, group, size, date. (`Chapter13.pdf` p. 32)*

---

## 11. Highlights

- A file is a **named** logical address space whose *meaning* is the
  application's business; ordinary, directory and special (character/block) files
  are all reached through the same operations.
- Attributes (name vs identifier, type, location, size, protection, times) live on
  disk in the directory and are cached in memory.
- Opening a file is the expensive step; the system-wide and per-process open-file
  tables exist so every later read/write is a memory lookup.
- Access methods run sequential → direct → indexed, with the index built on top of
  direct access.
- Directory structures run single-level → two-level → tree → acyclic graph →
  general graph, each buying naming, grouping or sharing at the cost of
  bookkeeping.
- A volume must be **mounted** at a directory before its names resolve.
- Protection is a triple (owner/group/other) × (read/write/execute) on Unix, which
  is a nine-bit approximation of the general access matrix.

---

## 12. Exam traps

- *"Name and identifier are the same."* → The name is user-visible and lives in a
  directory entry; the identifier (inode number) is what the file system chases.
  Renaming changes only the name.
- *"`close()` deletes the file."* → It writes the in-memory directory entry back
  and drops one reference; the file survives, and the count only reaches zero when
  the *last* process closes it.
- *"The file pointer is per file."* → It is **per process**, held in the
  per-process open-file table. Two processes reading the same file each have their
  own offset.
- *"`rmdir` on a directory deletes only that directory."* → In a tree it deletes
  the **entire subtree** rooted there.
- *"A link is a copy."* → A hard link is another *name* for the same inode — one
  set of data blocks. A symbolic link is a file *containing a path*, and can
  dangle.
- *"Cycles in a general-graph directory are harmless."* → They break recursive
  traversal and require cycle detection or garbage collection; most systems forbid
  hard links to directories for exactly this reason.
- *"Mounting copies the files."* → It attaches a name to a volume; the data never
  moves. The mount point's previous contents are merely hidden.
- *"`chmod 761` lets the owner's group write but not read, so it can't corrupt
  anything."* → Write without read is legal and dangerous: a process can overwrite
  bytes it cannot see.
- *"Unix permissions are an ACL."* → They are nine bits covering exactly three
  audiences; a real ACL is an arbitrary list of (domain, rights) pairs.
- *"Mode bits are checked in the order read-write-execute."* → They are checked
  **owner, then group, then other**, first match wins — so tightening the group
  bits does nothing for the owner.
- *"'.jpg' means it is an image."* → The extension is a naming convention; the OS
  generally does not enforce it.
