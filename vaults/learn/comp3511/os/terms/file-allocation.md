# File allocation methods — contiguous, linked, indexed

**What it is.** The rule that says which disk blocks belong to which file.

| Method | Directory holds | Direct access | External fragmentation | Growth |
| --- | --- | --- | --- | --- |
| **Contiguous** | start block, length | excellent (one add) | yes, badly | hard: must fit a bigger hole |
| **Linked** | first and last block | terrible (follow the chain) | none | easy: grab any free block |
| **FAT** | first block (chain in a table) | good — the chain is in RAM | none | easy |
| **Indexed** | index block number | excellent (one indirection) | none | easy, one block at a time |
| **Extent** | a list of (start, length) | good | some, but far less | good |

**Why it exists.** There is a three-way tension between *fast sequential access*
(favours contiguous), *cheap growth* (favours linked) and *fast random access*
(favours indexed). No single scheme wins, which is why real file systems use a
**combined** scheme: a few direct pointers, then single, double and triple
indirect index blocks.

**Example.** UFS with 4 KB blocks and 32-bit (4-byte) pointers fits
$4096/4 = 1024$ pointers per index block. Double indirect therefore reaches
$1024 \times 1024 = 1{,}048{,}576$ data blocks $= 4\,\text{GB}$ — the size limit
of a classic 32-bit file system. Triple indirect reaches $4\,\text{TB}$.

**Where it appears:** [[chap14_file_system_implementation]] Sections 6–10

**Related:** [[terms/FAT]] · [[terms/FCB]] · [[terms/free-space-management]]
