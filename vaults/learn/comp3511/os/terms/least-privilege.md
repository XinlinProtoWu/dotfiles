# Least privilege — and mechanism versus policy

**What it is.** Two separate guiding principles of protection:

| Principle | Statement |
| --- | --- |
| **Least privilege** | Every program, user and system component is given **just enough** privilege to do its job, and no more. |
| **Mechanism / policy separation** | The *mechanism* says **how** a check is enforced; the *policy* says **what** the answer should be. |

**Why it exists.** More privilege means more ways to be attacked — least privilege
shrinks the blast radius of a bug or a compromised account. Mechanism/policy
separation means a site can change *who* may do *what* without rewriting the
kernel, so the same OS ships to a hospital and a bank with only different policy
data.

**Example.** A log-writing daemon that only ever appends to `/var/log/app.log`
should hold an *append* right on that one file — not read, not execute, not
`/var/log`, not `/`. If the daemon is compromised, the attacker can only corrupt
one log. Likewise the access matrix is pure mechanism: it can enforce any policy,
from "everyone reads everything" to "nobody reads anything", without a code
change.

**Where it appears:** [[chap17_protection]] Sections 1–2

**Related:** [[terms/protection-domain]] · [[terms/access-matrix]] · [[terms/ACL]]
