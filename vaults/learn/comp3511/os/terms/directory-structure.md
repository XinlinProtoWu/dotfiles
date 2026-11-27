# Directory structure — single-level to general graph

**What it is.** How directory entries are organised into a namespace.

| Structure | Shape | Naming | Grouping | Notes |
| --- | --- | --- | --- | --- |
| **Single-level** | one directory for everybody | ✗ collisions | ✗ | simplest, unusable multi-user |
| **Two-level** | one directory per user (UFD) + master (MFD) | ✓ across users | ✗ | path = `/user/file` |
| **Tree** | arbitrary depth, one parent per node | ✓ | ✓ | absolute vs relative paths, current directory |
| **Acyclic graph** | tree + shared subtrees/files (links) | ✓ + aliases | ✓ | dangling links, must prevent cycles |
| **General graph** | cycles allowed | ✓ | ✓ | needs cycle detection or garbage collection |

**Why it exists.** Three forces pull in different directions: **efficiency**
(find a file fast), **naming** (two users may want `report.txt`; one file may want
two names) and **grouping** (all of one project's files together). Each step down
the table buys capability at the cost of bookkeeping.

**Example.** In a tree, deleting the directory `mail` in `/spell/mail/prog`
deletes the whole subtree underneath it — one `rmdir` can discard hundreds of
files. In a general graph the same delete may orphan a file that another path
still points at, so the system must either reference-count each object or run a
cycle/GC pass.

**Where it appears:** [[chap13_file_system_interface]] Sections 5–8

**Related:** [[terms/FCB]] · [[terms/mount]] · [[terms/ACL]]
