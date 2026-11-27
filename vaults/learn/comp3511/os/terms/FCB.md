# FCB — File Control Block (inode)

**What it is.** The per-file record holding everything about a file *except* its
name (the name lives in the directory entry) and its contents (which live in data
blocks). In UFS/Unix it is the **inode** (index node); NTFS stores one row per
file in the master file table.

Typical fields: unique identifier, owner (UID), permissions, size, timestamps,
type, link count, and the block pointers / extent list.

**Why it exists.** A file's metadata is consulted on *every* operation, but the
metadata must be separable from the data so the data blocks can be scattered and
so directories can hold several names for one file (hard links). Splitting name
from FCB is exactly what makes links and sharing possible.

**Example.** `ls -l` reads the directory to get `name -> inode number`, then
reads the inode to get mode, owner, size and mtime (Section 13 of
[[chap13_file_system_interface]]). Renaming a file
with `mv` inside the same directory only rewrites a directory entry — the inode
and all its data blocks are untouched, which is why same-directory `mv` is
instant regardless of file size.

**Where it appears:** [[chap14_file_system_implementation]] Sections 2, 3 ·
[[chap13_file_system_interface]] Section 6

**Related:** [[terms/open-file-table]] · [[terms/directory-structure]] · [[terms/file-allocation]]
