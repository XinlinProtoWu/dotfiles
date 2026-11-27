# COMP 3511 — Operating Systems: lecture index

Hub for the lecture notes in this folder. Every row links to one deck's notes;
the deck itself is embedded page-by-page inside each note, so the PDFs never need
to be opened separately.

> [!tip] How these notes are built
> Every note follows the same shape: `## 0. Terms` (links into `terms/`),
> numbered sections that motivate → define → **explain in plain words** → trace
> with real numbers → embed the deck's own figure → flag the trap, then a
> **Highlights** summary and a **Exam traps** list. Diagrams are always the PDF
> page, never redrawn.

## Notes by chapter

| Chapter | Note | Deck | Pages | Core content |
| --- | --- | --- | --- | --- |
| 3–4 | [[chap3processCont'd_to_chap4Threads]] | `Chapter3.pdf` | — | processes → threads |
| 5 | [[chap5_scheduling]] | `Chp5_summary.pdf` | — | FCFS, SJF/SRTF, RR, priority, MLFQ, real-time |
| 6–7 | [[chap6&7_sync]] | `Chapter6_synchronization.pdf`, `Chapter7_syncExample.pdf` | — | race conditions, semaphores, monitors |
| **11** | [[chap11_mass_storage]] | `Chapter11.pdf` | 4–26 | disk geometry, access time, disk scheduling, RAID |
| **13** | [[chap13_file_system_interface]] | `Chapter13.pdf` | 4–32 | files, access methods, directories, mounting, protection |
| **14** | [[chap14_file_system_implementation]] | `Chapter14.pdf` | 4–31 | layering, on-disk structures, allocation, free space |
| **17** | [[chap17_protection]] | `Chapter17.pdf` | 4–25 | rings, domains, access matrix, ACL/capability |

Other material in this folder: [[COMP3511_Exam_Review]] (chapters 1–6 + labs),
[[COMP3511_Exam_CheatSheet]], and `labs/`, `hmrk/`, `assignment/`.

## Dependency chain

```
assembly of the storage half
chap11  disk hardware, seek time, scheduling, RAID
   |
   v
chap13  the user-visible contract: files, names, directories, mounting, sharing
   |
   v
chap14  how that contract is implemented: layers, FCB, allocation, free space
   |
   v
chap17  who is allowed to do any of it: rings, domains, access matrix
```

Chapter 13 must come before 14 (it defines what 14 implements). Chapter 17 is
independent of 13/14 conceptually, but uses the file-permission triple from
Chapter 13 as its worked example. Chapter 11 must come first: without
`seek time` and `block`, Chapter 14's allocation trade-offs have no cost model.

## Formula sheet

| Formula | Meaning | Note |
| --- | --- | --- |
| $t_{\text{rot}} = \dfrac{60}{\text{RPM}}$ s | one full rotation | [[chap11_mass_storage]] |
| $t_{\text{rot,avg}} = \tfrac12 \dfrac{60}{\text{RPM}}$ | average rotational latency | [[chap11_mass_storage]] |
| $t_{\text{access}} = t_{\text{seek}} + t_{\text{rot,avg}}$ | average access time | [[chap11_mass_storage]] |
| $t_{\text{I/O}} = t_{\text{access}} + \dfrac{\text{bytes}}{v} + t_{\text{ctrl}}$ | average I/O time | [[chap11_mass_storage]] |
| $\text{MTTF}_{\text{array}} = \dfrac{\text{MTTF}_{\text{disk}}}{N}$ | array failure rate | [[chap11_mass_storage]] |
| $\text{MTTDL} = \dfrac{\text{MTTF}^2}{2\,\text{MTTR}}$ | mirrored-array data loss | [[chap11_mass_storage]] |
| $b \to (c,h,s) = \left(\left\lfloor \dfrac{b}{SH}\right\rfloor,\ \left\lfloor \dfrac{b}{S}\right\rfloor \bmod H,\ b \bmod S\right)$ | logical → physical block | [[chap11_mass_storage]] |
| $\text{pointers per block} = \dfrac{\text{block size}}{\text{pointer size}}$ | index arity | [[chap14_file_system_implementation]] |
| $\text{max file} = \left(\dfrac{\text{block}}{\text{pointer}}\right)^{L} \times \text{block}$ | $L$ levels of indexing | [[chap14_file_system_implementation]] |
| $\text{bitmap bits} = \dfrac{\text{disk size}}{\text{block size}}$ | free-space bitmap size | [[chap14_file_system_implementation]] |
| $\text{mode} = 64a + 8b + c$ with $a,b,c \in \{0..7\}$ | `chmod` octal | [[chap13_file_system_interface]] |
| $j < i \Rightarrow D_i \subseteq D_j$ | ring containment | [[chap17_protection]] |

### The six scheduling numbers to memorise

Queue `98, 183, 37, 122, 14, 124, 65, 67`, head at 53, cylinders 0–199:

| Algorithm | Movement |
| --- | --- |
| FCFS | 640 |
| SSTF | 236 |
| SCAN (downward first) | 236 |
| LOOK (downward first) | **208** |
| C-SCAN (upward first) | 382 |
| C-LOOK (upward first) | 322 |

## Exam traps collected

The highest-value lines from all four notes, grouped by theme.

**Disk timing**

- Transfer rate ≠ achieved bandwidth. A "1 Gb/s" drive gives $3.5\,\text{Mb/s}$ on
  random 4 KB reads.
- Average rotational latency is **half** a rotation, not a whole one.
- The random-vs-sequential gap is the whole reason file layout matters.

**Disk scheduling**

- SSTF starves far requests; that is why SCAN exists.
- The six totals above assume specific **initial directions** — SCAN 236 and
  C-SCAN 382 are not comparable without stating them (upward-first SCAN is 331).
- C-SCAN's unserviced return trip **is counted** (199 of 382).
- The p.19 slide's "308 for LOOK" is a typo; LOOK is **208**.

**RAID**

- RAID 0 has *no* redundancy; it is less reliable than one disk.
- RAID 5 survives one failure; two is RAID 6.
- RAID 1+0 tolerates more than RAID 0+1: in 0+1 one disk kills a whole stripe.
- MTTDL is quadratic in MTTF, so better disks help disproportionately.

**File interface**

- Name ≠ identifier (inode number). Renaming never moves a byte.
- File offset is per **process**, so `fork()` shares it and `open()` does not.
- Deleting a directory in a tree deletes the **whole subtree**.
- The Unix triple is nine bits for exactly three audiences — not an ACL.
- Mode bits are checked owner → group → other, first match wins.

**File implementation**

- The free-space bitmap is proportional to **capacity**: 32 MB per 1 TB.
- Indexed allocation costs **one whole block per file**, worse than linked for tiny
  files.
- $\left(\dfrac{\text{block}}{\text{pointer}}\right)^{L} \times \text{block}$ is only 4 GB with 4 KB blocks and 4-byte pointers.
- `dup()` shares the offset; `open()` creates a new one.
- Layering costs performance — the deck says so explicitly.

**Protection**

- Ring 0 is innermost and most privileged; larger ring numbers have *fewer* rights.
- Domains are unordered; rings are a total order.
- `copy` acts on columns; `control` and `transfer` act on rows. `transfer` grants
  no rights.
- Capability revocation is hard; ACL revocation is easy.
- Real systems use ACLs for policy and capabilities for speed.

## Terms

Every technical term in the four new notes has one definition file under `terms/`,
shared across chapters and backlinked to the notes that use it.

**Storage and disks:** [[terms/seek-time]] · [[terms/disk-scheduling]] ·
[[terms/logical-block]] · [[terms/RAID]] · [[terms/striping]] · [[terms/SSD]]

**File systems:** [[terms/FCB]] · [[terms/open-file-table]] ·
[[terms/file-allocation]] · [[terms/FAT]] · [[terms/free-space-management]] ·
[[terms/directory-structure]] · [[terms/mount]]

**Protection:** [[terms/least-privilege]] · [[terms/protection-domain]] ·
[[terms/access-matrix]] · [[terms/ACL]] · [[terms/capability]]
