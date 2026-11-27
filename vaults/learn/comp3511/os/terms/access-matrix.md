# Access matrix — protecting domains against objects

**What it is.** A matrix with **domains as rows**, **objects as columns**, and each
cell `access(i,j)` holding the set of rights a process in domain $D_i$ may invoke
on object $O_j$. The matrix is a *mechanism*; the *policy* decides which rights
get written into which cells.

Special rights that make the matrix dynamic:

| Right | Held on | Meaning |
| --- | --- | --- |
| **owner** | object $O_j$ | may add or delete any right in column $j$ |
| **copy** (written `*`) | object $O_j$ | may copy the right to another domain — but only within column $j$ |
| **control** | domain $D_j$ | may add or delete rights in row $j$ |
| **transfer** | domain $D_j$ | may switch from this domain into $D_j$ |

**Why it exists.** Without copy/owner/control/transfer, adding one right means
rebuilding the whole table. These four operations are the minimum needed to
delegate, revoke, and change privilege at run time.

**Example.** Domain $D_1$ holds `<file F1, {read, write}>`. If the cell holds
`write*` (copy right), then $D_1$ can grant another domain write access to F1 —
but it can never grant access to *read* F1 unless it held `read*`, because copy
only works inside the column.

**Where it appears:** [[chap17_protection]] Sections 6–9

**Related:** [[terms/ACL]] · [[terms/capability]] · [[terms/protection-domain]]
