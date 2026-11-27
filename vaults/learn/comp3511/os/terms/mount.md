# Mounting — attaching a file system to a name

**What it is.** Attaching a volume's file system at a **mount point** — an
existing directory in the currently visible tree — so that the volume's contents
appear under that name. The OS records each mount in an in-memory **mount table**
(loaded at mount time, discarded at dismount).

**Why it exists.** Names must form one tree even though the data is spread over
many volumes (and remote servers). Without mounting, every path would have to
start with a device name. Mounting also lets several *different* file systems —
ext4, FAT, ISO 9660, NFS — coexist under one root without the user caring.

**Example.** A USB stick with a file `notes.txt` at its root is **invisible** at
`/notes.txt` until it is mounted at `/media/usb`; afterwards it is reachable as
`/media/usb/notes.txt`. Unmount it, and that path stops resolving — the mount
point directory is still there, but empty. A file system cannot be accessed before
it is mounted, just as a file cannot be read before it is opened.

**Where it appears:** [[chap13_file_system_interface]] Sections 9–10 ·
[[chap14_file_system_implementation]] Section 3

**Related:** [[terms/directory-structure]] · [[terms/FCB]]
