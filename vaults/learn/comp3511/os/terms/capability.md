# Capability — a row of the access matrix as a token

**What it is.** One **row** of the access matrix, stored with the domain: for each
object, the operations that domain may perform. The object is represented by a
name or address — that pointer *is* a **capability**. Operations name the
capability as a parameter; **possession of the capability is proof of access**.

**Why it exists.** It is the mirror image of an ACL and optimises the opposite
workload. An ACL answers "who may touch this object?" in one cheap lookup; a
capability answers "what may this process touch?" in one cheap lookup. A
capability also *forwards* freely — you can hand a file descriptor to another
process and it simply works.

**Example.** A Unix file descriptor is a capability: `open("f")` returns a small
integer descriptor, and `read(fd, …)` never re-checks the path or the ACL. `dup()`
makes a second capability for the same open file; passing the fd through a
`socket` is a classic capability transfer. The catch is why the capability list
is a protected object maintained by the kernel: if a user could forge an fd
number into a capability for someone else's file, the whole scheme collapses.

**Where it appears:** [[chap17_protection]] Section 10 (Option 3) ·
[[chap14_file_system_implementation]] Section 3 (file descriptor)

**Related:** [[terms/ACL]] · [[terms/access-matrix]] · [[terms/open-file-table]]
