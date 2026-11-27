# Protection domain — and protection rings

**What it is.** A **domain** is a set of *access rights*, each an ordered pair
`<object-name, rights-set>`. A process executing in a domain may perform exactly
the operations listed for the objects in that domain, and nothing else.

**Rings** are a hierarchy of domains implemented in hardware:

| Ring | Content | Privilege |
| --- | --- | --- |
| 0 (innermost) | kernel | full set |
| 1, 2 | OS services, drivers | reduced |
| 3 (outermost) | user applications | least |

For rings $D_i$ and $D_j$, if $j < i$ then $D_i \subseteq D_j$ — inner rings hold
a *superset* of the outer ring's rights. Moving inward is only possible through a
controlled **gate**: a `syscall` instruction, a trap, or an interrupt.

**Why it exists.** A single user/kernel bit is too coarse. You want a driver that
can touch its device but not the scheduler; a hypervisor that outranks the guest
kernels it runs; a TrustZone (ARM) environment that outranks the kernel to
protect keys. Domains let you place each component exactly where its rights allow.

A domain is more general than a ring because it need not be ordered — two sibling
domains may be incomparable.

**Example.** UFS mode `761` on a file gives the owner `rwx`, the group `rw-`, and
everybody else `--x`. That is three domains defined not by ring but by *user
identity*: same process, different rights depending on who it runs as.

**Where it appears:** [[chap17_protection]] Sections 3–5

**Related:** [[terms/access-matrix]] · [[terms/least-privilege]] · [[terms/ACL]]
