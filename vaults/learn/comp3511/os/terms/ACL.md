# Access-control list (ACL)

**What it is.** One **column** of the access matrix, stored with the object: an
ordered list of `<domain, rights-set>` pairs naming every domain that has any
right on it. Empty entries simply are not stored.

**Why it exists.** The access matrix is *sparse* — almost every cell is empty — and
most objects are touched by very few domains. Storing a column per object means
you pay only for the rights that exist, and the check "may this process print on
this printer?" is a scan of that printer's short list.

**Example.** A file's ACL might read
`alice: {read, write}`, `bob: {read}`, `group:staff: {read}`. Asking "may bob
write?" searches the list, finds bob with only `read`, and denies. A *default
set* of rights can be added to the same object so that unlisted domains still get
a baseline (that is what the `o` bits of `chmod` and `umask` do).

**Where it appears:** [[chap17_protection]] Section 10 (Option 2) ·
[[chap13_file_system_interface]] Section 13

**Related:** [[terms/capability]] · [[terms/access-matrix]] · [[terms/protection-domain]]
