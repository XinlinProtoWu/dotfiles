# Open-file table — system-wide and per-process

**What it is.** Two kernel tables that make `open()` cheap:

| Table | One entry per | Holds |
| --- | --- | --- |
| **System-wide open-file table** | *file* currently open by anyone | a copy of the FCB, file-open count, disk location cache |
| **Per-process open-file table** | *open() call* | pointer into the system-wide table, current file offset, access mode, file pointer |

The **file-open count** in the system-wide entry is what lets several processes
share one FCB; the entry is removed only when the last closer drops the count to
zero.

**Why it exists.** Resolving a pathname means walking directories on disk — the
single most expensive thing a file operation can do. Opening once and caching the
FCB turns every later `read()` into a lookup in memory. The per-process table
exists because two processes may have the *same* file open at *different* offsets
— the FCB is shared, the offset is not.

**Example.** Process A and B both `open("db")`. One system-wide entry (count = 2,
one FCB copy) and two per-process entries (A at offset 0, B at offset 8192). A
`fork()` does **not** create a new system-wide entry, and the child *inherits* A's
offset — which is why a shared descriptor's offset is shared, not copied.

**Where it appears:** [[chap14_file_system_implementation]] Sections 3–4 ·
[[chap13_file_system_interface]] Section 3

**Related:** [[terms/FCB]] · [[terms/capability]]
