# 17 — Protection

> Source: `Chapter17.pdf`. Goal: the mechanism by which an OS decides *whether* a
> process in a domain may invoke an operation on an object — protection rings,
> domains, the access matrix, and the four ways of implementing it. Protection is
> the enforcer; [[chap13_file_system_interface]] Section 9 supplied one policy for
> files.

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Principles:** [[terms/least-privilege]]

**Who may do what:** [[terms/protection-domain]] · [[terms/access-matrix]]

**Implementations:** [[terms/ACL]] · [[terms/capability]]

**Related:** [[terms/FCB]] · [[terms/open-file-table]]

---

## 1. Goals of protection

A computer system is a collection of **objects**, each with a unique name and a
well-defined set of operations:

| Kind | Examples |
| --- | --- |
| **Hardware objects** | CPU, memory segments, printers, disks, tape |
| **Software objects** | files, programs, semaphores |

> **The protection problem:** ensure every object is accessed *correctly* and only
> by those processes *allowed* to access it.

The critical distinction:

| | **Mechanism** | **Policy** |
| --- | --- | --- |
| Answers | *how* is it done | *what* should be done |
| Example | "the kernel checks the mode bits before `write`" | "only `staff` may write this file" |
| Changes how often | rarely | all the time, per site, per user |

Separation matters for **flexibility**: policies change from place to place and
from time to time, and without separation *every* policy change would require
changing the mechanism — i.e. rebuilding the kernel.

**In plain words.** A lock is a mechanism; who gets a key is a policy. You buy one
kind of lock and issue different keys to different tenants, instead of
re-engineering the door every time a tenant moves out.

**Example (traced).** Linux's `rwx` bits are a mechanism; `/etc/sudoers` and file
ownership are policy. A hospital and a bank can run the *same* kernel binary, with
completely different policy data, and neither requires a code change. Conversely,
if the mode bits were hard-wired to "owner-only", the OS could never serve a
shared server at all.

![[Chapter17.pdf#page=4]]
*Figure: objects, operations, and the mechanism/policy separation. (`Chapter17.pdf` p. 4)*

---

## 2. The principle of least privilege

> Programs, users and systems should be given **just enough** privileges to
> perform their tasks.

More privileges ⇒ a higher chance of attack and a larger blast radius if something
is exploited.

**In plain words.** Give the cleaner a key to the rooms they clean, not to the safe.
If the cleaner is careless, the damage is a spilled bucket, not a missing payroll.
Every extra permission you hand out is an extra way in for whoever compromises
that account.

**Example (traced).** A web server serving read-only pages needs
`read` + `execute` on `/var/www` and nothing else — no `write`, no access to `/etc`,
no root. If the server is exploited through a bug in a page handler, the attacker
gets exactly `r-x` on one directory tree: they cannot modify the pages, cannot read
the password file, cannot persist. Under a naive "run as root" deployment the same
bug is total compromise of the machine.

**Example (counterexample).** `/usr/bin/passwd` must write `/etc/shadow`, which
normal users must not read. Plain least privilege cannot express this, so the
system adds a *narrow, auditable* exception — the setuid bit — that grants exactly
one elevated operation instead of running the user as root.

![[Chapter17.pdf#page=5]]
*Figure: the principle of least privilege and its file-permission consequence. (`Chapter17.pdf` p. 5)*

---

## 3. Protection rings

An extension of the user/kernel bit into several **levels** of privilege, enforced
by **hardware**.

$$\text{if } j < i \text{ then } D_i \subseteq D_j$$

Ring 0, the innermost, holds the full set of privileges; outer rings hold
progressively less. Movement between rings is only possible through a controlled
**gate** — the `syscall` instruction, a trap, or an interrupt.

| Ring | Content | Privilege |
| --- | --- | --- |
| 0 | kernel | everything |
| 1, 2 | OS services, drivers (in principle) | reduced |
| 3 | user applications | least |

Modern additions the deck names:

- **Hypervisor ring** (Intel VT-x) — virtual machine managers, which create and run
  VMs and therefore need *more* capability than the guest kernels they host.
- **ARM TrustZone (TZ)** — a most-privileged execution environment for
  cryptographic functions: it has exclusive access to hardware-backed crypto (the
  NFC Secure Element, an on-chip key), which makes storage of passwords and
  secrets safer than in the general-purpose kernel.

**In plain words.** A building with concentric security zones: the lobby (user
mode), the staff corridor (ring 1), the server room (ring 0), and a sealed vault
inside the server room that even the server administrator cannot open (TrustZone).
You get *inward* only through a door with a guard, which is the `syscall`
instruction — and the guard is what makes the arrangement meaningful rather than
decorative.

**Example (traced).** $j < i \Rightarrow D_i \subseteq D_j$ with rings 0, 1, 2, 3. Take $i = 3$,
$j = 0$: $0 < 3$, so $D_3 \subseteq D_0$ — the user domain's rights are a *subset*
of the kernel's. But take $i=1$, $j=2$: $2 \not< 1$, so no containment holds, and a
ring-2 component cannot reach ring 1's rights. The relation is a total order, which
is exactly the limitation domains (Section 4) remove.

![[Chapter17.pdf#page=6]]
*Figure: protection rings and the subset relation. (`Chapter17.pdf` p. 6)*

![[Chapter17.pdf#page=8]]
*Figure: ARM CPU architecture — where TrustZone sits relative to the kernel. (`Chapter17.pdf` p. 8)*

---

## 4. Domain of protection

Rings force a **hierarchy** — every ring is contained in every inner ring. A
**domain** is the generalisation: a set of rights that need *not* be ordered. Two
sibling domains can be incomparable, which rings cannot express.

A **domain** is a collection of **access rights**, each an ordered pair

$$\langle \text{object-name}, \text{rights-set} \rangle$$

where the rights-set is a subset of all valid operations on that object.

**In plain words.** Think of a keyring rather than a ladder. A ladder says anyone on
floor 3 may do everything floor 2 allows — strictly less as you go out. A keyring
says this person may open the archive and the loading bay but not the manager's
office, and the manager may open the office and the loading bay but not the archive.
Neither keyring contains the other; both are perfectly reasonable.

**Example (traced).** Domain $D$ holds $\langle \text{file } F, \{read, write\} \rangle$. A process in $D$ may read and write $F$ and may do **nothing else** to it — not append, not execute, not delete. Add $\langle \text{printer } O_4, \{\text{print}\} \rangle$ and it may print to $O_4$ but not to $O_5$. That is the
whole content of the domain: two pairs.

Domains may **share** rights — if $\langle O_4, \{\text{print}\} \rangle$ appears
in both $D_2$ and $D_3$, a process in either may print $O_4$. This sharing is what
the access matrix makes explicit.

**Process-to-domain association** is either:

- **static** — the set of resources is fixed for the process's whole lifetime, or
- **dynamic** — a **domain switch** mechanism lets the process move between domains
  at different stages of execution.

**In plain words.** Static is a person with one badge, forever. Dynamic is a person
who shows their badge at the door and gets a different badge for the room they are
entering — which is what a syscall actually does when it crosses from user mode
into kernel mode.

![[Chapter17.pdf#page=10]]
*Figure: access rights as $\langle \text{object}, \text{rights} \rangle$ pairs, and static versus dynamic domain association. (`Chapter17.pdf` p. 10)*

### Three ways to realise a domain

| Realisation | Domain = | Switch happens when |
| --- | --- | --- |
| **Per user** | the set of objects that user's identity may touch | the user changes |
| **Per process** | the set the process's identity may touch | one process sends a message to another and waits |
| **Per procedure** | the local variables defined in the procedure (procedure = the domain) | a procedure call is made |

**In plain words.** Per-user is a membership card; per-process is a visitor badge
valid while you are in the building; per-procedure is the rule that a voucher is
only valid at the till that issued it — the rights exist only inside the block of
code that was given them, and vanish the moment it returns.

**Example (traced).** Per-procedure protection is how a compiler or a WebAssembly
sandbox gives a function access to one buffer and nothing else: on call, the
domain gains $\langle \text{buf}, \{read,write\} \rangle$; on return, the domain is
the caller's again. A bug inside the function can only damage `buf`.

![[Chapter17.pdf#page=11]]
*Figure: domains realised per user, per process, per procedure. (`Chapter17.pdf` p. 11)*

---

## 5. The access matrix

Rows = **domains**, columns = **objects**, cell = the rights a process in domain
$D_i$ may invoke on object $O_j$.

$$\text{Access}[i][j] = \text{set of operations permitted to domain } i \text{ on object } j$$

The matrix is a **mechanism** that can express a wide range of **policies**:

- Mechanism: implement the matrix and ensure the semantics hold — a process in
  $D_i$ can access only what row $i$ says.
- Policy: decide *which* rights go into cell $(i,j)$ and *which domain* each
  process executes in.

The check on every operation is one line:

> if a process in $D_i$ tries to do `op` on $O_j$, then `op` must be in
> $\text{Access}[i][j]$.

The **creator** of an object may define its column. When a user creates $O_j$, the
column $O_j$ is added with initialisation entries of the creator's choosing.

**In plain words.** A seating plan for a wedding: rows are guests, columns are
tables, and each cell says what that guest may do at that table — sit, pour wine,
cut the cake. The plan does not care *why*; it only answers the question. Guests
can be moved between tables without reprinting the plan's rules, because the rules
are data, not code.

**Example (traced).** Four domains $D_1..D_4$ and four objects $F_1..F_3$, a
printer $O_4$ (from the deck's structure):

| | $F_1$ | $F_2$ | $F_3$ | $O_4$ |
| --- | --- | --- | --- | --- |
| $D_1$ | `read, write` | | | |
| $D_2$ | | `read` | | `print` |
| $D_3$ | | | `read` | `print` |
| $D_4$ | | `write` | | |

A process in $D_2$ asking to print $O_4$ finds `print` in cell $(2, O_4)$ ⇒
allowed. Asking to read $F_3$ finds an **empty** cell ⇒ denied — and "empty" is
the common case, which is why the sparse structure of Section 6 matters.

![[Chapter17.pdf#page=13]]
*Figure: the access matrix — domains as rows, objects as columns. (`Chapter17.pdf` p. 13)*

---

## 6. Making the matrix dynamic: four special rights

A static matrix cannot express delegation, revocation, or a process changing its own
privilege. Four operations fix that. Three are ordinary rights stored in a cell; one
is a right over a domain.

| Right | Written as | Held in | Grants |
| --- | --- | --- | --- |
| **owner** | — | cell $(i, O_j)$ | add/delete **any** right in **column** $j$ |
| **copy** | `*` | cell $(i, O_j)$ | copy this right to another domain, **only within column** $j$ |
| **control** | — | cell $(i, D_j)$ | add/delete rights in **row** $j$ — i.e. modify another domain |
| **transfer** | — | cell $(i, D_j)$ | **switch** from $D_i$ into $D_j$ |

Note the geometry: **owner and copy act on columns** (objects); **control and
transfer act on rows** (domains). That is why the matrix must contain *domains as
objects* for control and transfer to make sense — the deck's "matrix with domains as
objects".

**In plain words.** Owner is "it's my house, I say who visits". Copy is "I may give
you a key, but only *this* key — I cannot fabricate the key to the safe because I
do not have one". Transfer is "I may swap places with you" — and swapping *into* a
more powerful role needs that role to list you under transfer.

**Example (traced).** Cell $(1, F_1)$ = `read*`. Domain $D_1$ may grant `read` on
$F_1$ to $D_4$ ⇒ cell $(4,F_1)$ becomes `read`. But $D_1$ may **not** grant `write`
on $F_1$ unless $(1,F_1)$ also contains `write*`, and may not grant anything on
$F_2$ at all, because copy never leaves its column.

Now cell $(1, D_2)$ = `control`: $D_1$ may add any right to **row 2**, e.g. write
`read` into $(2,F_3)$. And cell $(3, D_1)$ = `transfer` means a process in $D_3$
may switch into $D_1$ — the mechanism by which a restricted process temporarily
executes with more privilege.

> [!warning] Confusing copy with control is the classic exam error
> `copy` grants the right to another *domain*, on the *same object*.
> `control` grants the right to change another *domain's whole row*.
> `transfer` does not change any rights at all — it moves the *process*.

Dynamic protection also needs **revocation**: when rights to a shared object are
withdrawn, every copy that was made from them must be found and removed. That is
easy for a global table and for ACLs (delete an entry), but hard for capabilities
(Section 10) because copies are held inside processes you do not control.

![[Chapter17.pdf#page=15]]
*Figure: dynamic protection — owner, copy (`*`), control, transfer. (`Chapter17.pdf` p. 15)*

![[Chapter17.pdf#page=16]]
*Figure: the access matrix with domains as objects — where control and transfer live. (`Chapter17.pdf` p. 16)*

![[Chapter17.pdf#page=17]]
*Figure: an access matrix with copy rights. (`Chapter17.pdf` p. 17)*

![[Chapter17.pdf#page=18]]
*Figure: an access matrix with owner rights. (`Chapter17.pdf` p. 18)*

---

## 7. Implementation 1 — global table

Store ordered triples $\langle \text{domain}, \text{object}, \text{rights-set} \rangle$ in one table. An operation `M` on $O_j$ from $D_i$ searches the table for
$\langle D_i, O_j, R_k \rangle$ and allows it if $M \in R_k$.

| Strength | Weakness |
| --- | --- |
| Simple | the table can be huge and may **not fit in main memory** — needs I/O / virtual memory |
| | **cannot group objects**: "everyone may read $O_j$" needs one entry per domain |

**In plain words.** One long receipt listing every purchase anyone ever made. To
check whether you may read a particular book you search the whole receipt. It works,
but the receipt is longer than the library.

**Example (traced).** 1000 domains × 5000 objects, of which 5 % of cells are
non-empty $= 250{,}000$ triples. At ~32 bytes each that is 8 MB — fits. Now 100 000
users × 1 000 000 files at 1 % density $= 10^{9}$ triples $\approx 32\,\text{GB}$:
the table *is* the bottleneck, so each lookup may page.

![[Chapter17.pdf#page=20]]
*Figure: the global table implementation of the access matrix. (`Chapter17.pdf` p. 20)*

---

## 8. Implementation 2 — access lists (columns)

Store each **column** with its object: an ordered list of $\langle \text{domain}, \text{rights-set} \rangle$ for every domain with non-empty rights. Empty entries are
simply discarded.

| | |
| --- | --- |
| **Strength** | corresponds directly to how users think — you specify the list when you create the object |
| **Strength** | empty cells cost nothing |
| **Weakness** | deciding **everything a domain may do** requires a search of *every* object's list |
| **Weakness** | every access must be checked, requiring a search of that object's list |
| **Extension** | a **default** rights-set can be added so unlisted domains still get a baseline |

**In plain words.** A guest list on the door of each room. Checking one person
against one room is instant. But "what rooms may this person enter?" means walking
the whole building reading every door. That is the exact mirror image of the global
table.

**Example (traced).** The deck's own picture: object $F_1$ has the access list
`Domain 1 = Read, Write`, `Domain 2 = Read`, `Domain 3 = Read`. A process in
$D_2$ asks to write $F_1$: search the $F_1$ list, find $D_2$ with `Read` only ⇒
**denied**. A process in $D_4$ (not listed) asks to read: no entry ⇒ denied,
*unless* a default set applies.

This is what Unix mode bits and Windows ACLs are: an ACL is literally a column.

![[Chapter17.pdf#page=22]]
*Figure: access lists for objects — each column stored with its object. (`Chapter17.pdf` p. 22)*

---

## 9. Implementation 3 — capability lists (rows)

Store each **row** with its domain: a list of $\langle \text{object}, \text{rights} \rangle$. The object is represented by its name or address — that token **is** the
capability.

To do operation `M` on $O_j$, the process requests `M` **and supplies the
capability for $O_j$** as a parameter. **Possession of the capability is proof of
access** — the matrix is not consulted.

The list is a **protected object** owned by the OS, never directly accessible to a
process running in that domain. Otherwise a process could forge a capability, and
the entire scheme collapses.

| | |
| --- | --- |
| **Strength** | localises everything a process needs in one place — cheap "what may I do?" |
| **Strength** | capabilities can be freely passed between domains (they *are* the key) |
| **Weakness** | revocation is inefficient — copies live inside processes you do not control |

**In plain words.** A ring of physical keys in your pocket. The guard does not check
a list; he checks that you are holding a key that fits. That makes every door fast,
and it makes lending someone a key trivial — but when you change the locks on a
borrowed key, you have to chase down every copy that was made.

**Example (traced).** A Unix file descriptor is a capability. `open("f")` returns
descriptor 3; `read(3, …)` re-checks nothing — no path lookup, no ACL scan —
because holding descriptor 3 is the proof. `dup(3)` makes a second capability to
the same open file. Passing the descriptor over a `socket` is a genuine capability
transfer. And the danger is exactly the promised one: if a process could *guess*
the number 4 belonging to another file, protection fails — which is why
descriptors are per-process table indices, not global addresses.

![[Chapter17.pdf#page=23]]
*Figure: capability lists for domains. (`Chapter17.pdf` p. 23)*

---

## 10. Implementation 4 — lock and key

A compromise between access lists and capability lists.

| Side | Stored | Form |
| --- | --- | --- |
| **Object** | a list of unique bit patterns, its **locks** | $(L, \alpha)$ where $\alpha$ is an access attribute |
| **Domain** | a list of unique bit patterns, its **keys** | $K$ |

> A process in a domain may access an object **iff** the domain holds a key that
> matches one of the object's locks.

As with capabilities, the OS manages the lists on the domain's behalf; users may
not examine or modify keys or locks directly.

**In plain words.** Each door carries several different tumbler patterns, each
pattern licensing a different act (open, clean, empty the till). Each person carries
a ring of cut keys. You open a door if *any* key you hold matches *any* pattern on
it. Nobody has to keep a list of names — and the lock can be re-pinned without
reissuing anybody's keys.

**Example (traced).** Object $F_1$ has locks $(L_7, \text{read})$,
$(L_9, \text{write})$. Domain $D_2$ holds keys $\{L_3, L_7\}$. Matching $L_7$ gives
`read` ⇒ $D_2$ may read $F_1$ and may not write it (no key matches $L_9$).
Revoking all write access to $F_1$ means changing lock $L_9$ to a new pattern —
one operation on one object, and no search through domains (though any domain that
should have been told now silently loses access).

![[Chapter17.pdf#page=24]]
*Figure: the lock-key scheme — locks on objects, keys on domains. (`Chapter17.pdf` p. 24)*

---

## 11. Comparing the four implementations

| Technique | Grouping of objects | Grouping of domains | Query "may I act on this object?" | Query "what may this process do?" | Revocation |
| --- | --- | --- | --- | --- | --- |
| **Global table** | poor | poor | table search | table search | easy |
| **Access list** | **good** (one list per object) | poor | one list scan | scan every object | **easy** (edit/delete entry) |
| **Capability list** | poor | **good** | instant (have the token?) | one list scan | **hard** (copies are loose) |
| **Lock-key** | good | good | key/lock match | key/lock match | easy (change the lock) |

The deck's conclusions:

- **Global table** — simple, but large; no grouping.
- **Access list** — matches how users think; the object's list is written at
  creation; but computing *all* of a domain's rights is difficult, and every access
  requires a search.
- **Capability list** — good at localising a process's information; **revocation is
  inefficient**.
- **Lock-key** — effective and flexible depending on key length; keys pass freely
  between domains; revocation is easy.
- **Most systems use a combination of access lists and capabilities.**

**In plain words.** ACLs answer "who may open this door"; capabilities answer "which
doors may this person open". Real systems need both: the ACL is what an
administrator edits, and the descriptor (capability) is what the running program
carries so it does not re-ask on every read. Use one for policy and the other for
speed.

**Example (traced).** Unix, again: the file's mode bits/ACL are the *access list*
(edited by `chmod`/`setfacl`, checked once at `open()`); the returned descriptor is
the *capability* (checked on nothing thereafter). Windows is the same shape with
richer ACLs. That is why "most systems use a combination" is not a hedge — it is a
description of every mainstream OS.

![[Chapter17.pdf#page=25]]
*Figure: comparison of the four implementation techniques. (`Chapter17.pdf` p. 25)*

---

## 12. Highlights

- Protection ensures each object is accessed correctly and only by permitted
  processes; **mechanisms** (how) are separated from **policies** (what) so policy
  can change without new code.
- **Least privilege**: just enough rights for the task, no more — this shrinks the
  damage a bug or a compromised account can do.
- **Protection rings** are hardware-enforced domains in a strict hierarchy,
  $j < i \Rightarrow D_i \subseteq D_j$, entered only through gates (`syscall`,
  trap, interrupt); modern additions are the hypervisor ring and ARM TrustZone.
- A **domain** generalises rings to an unordered set of
  $\langle\text{object}, \text{rights}\rangle$ rights, associated per user, per
  process, or per procedure, statically or dynamically.
- The **access matrix** (domains × objects) is the general model; `owner`, `copy`,
  `control` and `transfer` make it dynamic. Owner/copy act on columns;
  control/transfer act on rows.
- Implementations: **global table** (simple, huge), **access lists** (columns, easy
  revocation), **capability lists** (rows, fast checks, hard revocation),
  **lock-key** (both, easy revocation). Real systems combine ACLs with
  capabilities.

---

## 13. Exam traps

- *"Protection and security are the same."* → Protection is the internal mechanism
  that controls access by processes; security is the broader concern (authentication,
  external attack). This chapter is protection.
- *"Mechanism and policy are the same thing."* → Mechanism = how the check is
  enforced; policy = what the answer should be. The whole point of separating them
  is that policy changes often and mechanism should not.
- *"Least privilege means giving users the fewest permissions that still let them
  work."* → It applies to **programs and system components** too, and the target is
  *exactly* what the task needs — not the minimum that keeps a human happy.
- *"Ring 3 has more privilege than ring 0 because it is a bigger number."* → Ring 0
  is innermost and most privileged; $j < i \Rightarrow D_i \subseteq D_j$.
- *"Rings and domains are the same."* → Rings are a **total order** with subset
  containment; domains are an arbitrary set of rights and need not be comparable.
- *"A domain is a user."* → A domain may be per user, but also per process or even
  per procedure. A single user's process can move through several domains.
- *"`copy` lets a domain copy a file."* → It lets a domain copy an *access right to
  another domain*, and only inside the same column (same object).
- *"`control` and `transfer` both let a domain change privilege."* → `control`
  changes another domain's *rights* (a row of the matrix); `transfer` changes which
  domain the *process* runs in. `transfer` grants no rights at all.
- *"A capability is checked against the access matrix on every use."* → No. Holding
  the capability **is** the authorisation; the matrix is not consulted.
- *"Capabilities are easy to revoke because they are just integers."* → They are hard
  to revoke precisely because they have been copied into processes you do not
  control. ACLs are the easy-revocation choice.
- *"The lock-key scheme is just an ACL."* → It stores bit patterns on both sides and
  matches them; the object does not name the domains, which is what makes revocation
  a one-place lock change.
- *"A global table scales because it is simple."* → It can exceed main memory and
  it cannot group objects, so "everyone may read $X$" costs one row per domain.
