# Topic 3 — Von Neumann Model & the MIPS ISA

> Source: `COMP4611L3_2026F.pdf` (Lecture 3, 44 pp)
> Goal: raise the abstraction level from logic gates to a *machine*, and learn the vocabulary
> (ISA) it speaks. Continues from `02_Transistor_Logic_Timing.md`; the ISA learned here is what
> `04_Single_Cycle_Datapath.md` will build hardware for.

## 1. From gates to a computer model

The last two lectures gave us combinational and sequential logic. From those blocks we can build
the four *execution* resources a computer needs:

| Block built from logic | Job |
|---|---|
| Execution units | do arithmetic and logic (ALU) |
| Decision units | compare, decide, choose |
| Memory / storage units | hold programs and data |
| Communication units | move values between the above |

What is still missing is a **model** — a rule for *when* each block fires. The von Neumann model
(1946) supplies that rule.

![[COMP4611L3_2026F.pdf#page=7]]
*Figure: the five components of the von Neumann model — memory, processing unit, input, output, and the control unit that sequences everything. (`COMP4611L3_2026F.pdf` p. 7)*

The five components:

1. **Memory** — holds *both* the program and its data, in one linear array.
2. **Processing unit** — ALU plus a small set of registers (`TEMP` in the diagram).
3. **Input** / 4. **Output** — peripherals: keyboard, mouse, disk, network, monitor, printer.
5. **Control unit** — the sequencer: `PC`/`IP` (address of the next instruction) and `IR` (the
   instruction currently being executed).

Vocabulary that the rest of the course assumes:

| Term | Meaning |
|---|---|
| **Program** | a set of instructions |
| **Instruction** | the smallest piece of specified work a computer carries out |
| **Instruction set** | every instruction a given computer is designed to execute |

> [!important] The point of the model
> A program is just data in memory, and the *control unit* walks through it one instruction at a
> time. Everything else in this course is an attempt to make that walk faster.

---

## 2. Memory: address space and addressability

Memory is *large but slow*: it is the warehouse, not the workbench. Two numbers describe it
completely, and they are constantly confused.

**Address space** = how many uniquely identifiable locations exist.
**Addressability** = how many bits live in each location.

The total capacity is therefore address space × addressability.

| Machine | Address space | Addressability | Capacity |
|---|---|---|---|
| MIPS | $2^{32}$ (32-bit addresses) | 8 bits (byte-addressable) | $2^{32} \times 1\,\text{B} = 4\,\text{GiB}$ |
| x86-64 | up to $2^{48}$ (48-bit addresses) | 8 bits | $2^{48}\,\text{B} = 256\,\text{TiB}$ |

**In plain words.** A street can be numbered either house-by-house or block-by-block. If the town
hall issues one number per *house*, then a 32-bit numbering scheme can name four thousand million
houses, each holding one byte. If instead it issues one number per *block*, the same numbering
scheme names only a quarter as many houses — but each number is the start of a block of four.
MIPS numbers houses one at a time: it is **byte-addressable**, and a *word* (32 bits) is four
consecutive houses.

**Example (traced).** MIPS has $2^{32}$ = 4,294,967,296 addresses and each is one byte, so the
memory holds 4,294,967,296 B = 4 GiB. A MIPS word is 32 bits = 4 B, so the same memory holds
$2^{32}/4 = 2^{30}$ = 1,073,741,824 words, and word $k$ lives at byte address $4k$.

> [!tip] If MIPS were word-addressable
> $2^{32}$ locations × 4 B = $2^{34}$ B = 16 GiB — same number of addresses, four times the
> capacity, and `A[i]` would need no scaling by 4. It is not; every offset you write in MIPS is a
> **byte** offset.

### Reading and writing: MAR and MDR

Two registers sit between the processing unit and memory:

- `MAR` (Memory Address Register) — which location.
- `MDR` (Memory Data Register) — the value passing through.

Read: put the address in `MAR`, then the contents appear in `MDR`.
Write: put the address in `MAR` **and** the data in `MDR`, then assert write-enable, and `MDR` is
stored at `MAR`.

**In plain words.** This is a library counter. You hand the librarian a slip with a shelf number
(`MAR`); she goes and fetches whatever sits there and puts it on the counter (`MDR`). To return a
book you hand over the shelf number *and* the book together, then say "file it". The librarian
never needs to know whether the thing on the shelf is a novel or a shopping list — that is the
next section's problem.

---

## 3. The processing unit: ALU plus a register file

The ALU combines many operations into one unit that performs one of them at a time, selected by
control signals. Its operands must come from somewhere close by.

For `((A+B)*C)/D` the intermediate `A+B` is needed again almost immediately. Round-tripping it
through memory would be far slower than the addition that produced it, so a small, fast store sits
right next to the ALU: the **register file**.

![[COMP4611L3_2026F.pdf#page=15]]
*Figure: registers as fast temporary storage between memory and the ALU. (`COMP4611L3_2026F.pdf` p. 15)*

- MIPS has **32 general-purpose registers**, `$0`–`$31`.
- A register number is therefore **5 bits** wide.
- One register holds one word: **32 bits** in MIPS (register size = word length).

**In plain words.** The warehouse (memory) is cheap and huge but a long walk away; the workbench
(registers) holds only thirty-two labelled trays but is close enough to touch. A carpenter doing a
four-step joint keeps the parts on the tray, not in the storeroom — walking back for each piece
would take longer than the cutting. That is why `((A+B)*C)/D` is a register program, not a memory
program.

**Example (traced).** `((A+B)*C)/D` with `A=$s0, B=$s1, C=$s2, D=$s3`:

```asm
add $t0, $s0, $s1   # t0 = A + B
mul $t0, $t0, $s2   # t0 = (A+B) * C
div $s4, $t0, $s3   # s4 = ((A+B)*C) / D
```

Three ALU operations, **zero** memory accesses. The same program written with memory operands
would need a load after every step: roughly six extra memory accesses per expression evaluation.

### Register conventions (p. 16)

| Name | Number | Usage | Preserved across a call? |
|---|---|---|---|
| `$0` | 0 | constant 0 (writes are discarded) | — |
| `$at` | 1 | assembler temporary | no |
| `$v0`–`$v1` | 2–3 | function return values | no |
| `$a0`–`$a3` | 4–7 | function arguments | no |
| `$t0`–`$t7` | 8–15 | temporaries | **no** (caller-saved) |
| `$s0`–`$s7` | 16–23 | saved variables | **yes** (callee-saved) |
| `$t8`–`$t9` | 24–25 | temporaries | no |
| `$k0`–`$k1` | 26–27 | OS temporaries | no |
| `$gp` | 28 | global pointer | yes |
| `$sp` | 29 | stack pointer (grows **down**) | yes |
| `$fp` | 30 | frame pointer | yes |
| `$ra` | 31 | return address | yes |

Note the numbering is *not* contiguous by role: `$t8`–`$t9` sit at 24–25 because 16–23 were reserved
for `$s0`–`$s7` first.

> [!warning] `$0` is not a register you can write
> A write to `$0` is silently dropped. `move $s0,$s1` is really `add $s0,$s1,$zero`; `clear` is
> `add $s0,$zero,$zero`.

---

## 4. Input, output, and the control unit

Input and output devices ("peripherals") move information in and out: keyboard, mouse, scanner,
disk, network on the way in; monitor, printer, disk, network on the way out. A disk appears in both
lists, which is the first hint that "input" and "output" are roles, not properties of a device.

![[COMP4611L3_2026F.pdf#page=20]]
*Figure: the control unit as the conductor — PC/IP chooses the next instruction, IR holds the current one. (`COMP4611L3_2026F.pdf` p. 20)*

- `IR` (Instruction Register) — the instruction being executed right now.
- `PC` (Program Counter, a.k.a. `IP`) — the **address** of the next instruction to fetch.

The deck's own image for the control unit is an orchestra conductor: the players (ALU, memory,
registers) can all make sound, but nothing is synchronised until someone says who plays when.

> [!important] PC versus IR
> `PC` holds an **address**; `IR` holds an **instruction**. Adding 4 to the PC moves to the next
> instruction only because every MIPS instruction is exactly 4 bytes wide.

---

## 5. Programmer-visible (architectural) state

Everything an assembly programmer can name, and nothing else:

- **Memory** $M[0 \dots N-1]$ — an array indexed by address.
- **Registers** — named in the ISA rather than by address (`$s0`, not `M[17]`).
- **The program counter** — the address of the current/next instruction.

![[COMP4611L3_2026F.pdf#page=21]]
*Figure: the architectural state of a MIPS machine. (`COMP4611L3_2026F.pdf` p. 21)*

An instruction's job is exactly this: transform the architectural state from one snapshot to the
next.

$$AS \;\longrightarrow\; AS'$$

Everything *not* in that list — caches, pipeline registers, the branch predictor, the MAR/MDR —
is **microarchitectural**: invisible to the ISA, and free to change between processor generations
without breaking a single program. This split is the whole reason `07_Out_of_Order_Execution.md`
can exist without a new ISA.

---

## 6. Two properties of von Neumann, and the dataflow alternative

The von Neumann model is also called the **stored-program computer**, and it has two defining
properties:

| Property | Meaning |
|---|---|
| **Stored program** | Instructions sit in the same linear memory as data; a stored value's interpretation depends only on the control signals applied to it |
| **Sequential processing** | One instruction fetched, executed, and completed at a time; the PC advances in order except for control-transfer instructions |

**In plain words.** A recipe book and a bowl of ingredients share the same shelf, and the cook
reads the recipe one line at a time, top to bottom, unless a line says "now jump to step 7". Because
the book and the ingredients are the same kind of object, the cook has to be *told* which lines are
instructions and which are flour — that is what the decode signals do. And because the cook reads
one line at a time, a long line blocks the whole kitchen even when the next line could have been
started.

### The dataflow model

![[COMP4611L3_2026F.pdf#page=25]]
*Figure: dataflow order — an instruction fires as soon as its operands arrive, with no PC. (`COMP4611L3_2026F.pdf` p. 25)*

| | von Neumann | Dataflow |
|---|---|---|
| Order of execution | **control flow** — order given by the PC | **data flow** — order given by operand availability |
| Program counter | yes | **no** |
| Who gets a result | defined by the instruction's destination register | each instruction names its **consumers** |
| Parallelism | sequential by construction | potentially many instructions fire at once |

**In plain words.** In the recipe kitchen the cook reads line 4 and waits for the oven no matter
what, while three helpers stand idle. In the dataflow kitchen nobody holds a recipe: each helper
watches the ingredient trays, and the moment the chopped onions and the oil are both there, that
helper starts frying — regardless of what anyone else is doing. Onion-chopping and sauce-stirring,
which do not feed each other, happen at the same time. It is more parallel by construction, and
much harder to build, which is why the sequential model still dominates after decades.

> [!note] Answer to the deck's question
> "Is this the only way a computer can process programs?" — **No**, but it has been the dominant
> paradigm for decades. Dataflow ideas reappear later in this course as out-of-order execution
> (Topic 7), which recovers dataflow's parallelism *inside* a sequential ISA.

---

## 7. The ISA: the software/hardware interface

An instruction is the most basic unit of processing. Instructions are the *words* of the machine's
language; the **Instruction Set Architecture** is its vocabulary.

- **Machine language** — the computer-readable form: 0s and 1s.
- **Assembly language** — the human-readable form of the same instructions (`add $s0,$s1,$s2`).

![[COMP4611L3_2026F.pdf#page=28]]
*Figure: the ISA as the layer between the programmer's program and the microarchitecture. (`COMP4611L3_2026F.pdf` p. 28)*

The ISA fixes four things. Everything else is implementation.

| ISA specifies | MIPS answer |
|---|---|
| Memory organisation | address space $2^{32}$; addressability 8 bits (byte-addressable) |
| Register set | 32 general-purpose registers, 32 bits each |
| Instruction set | opcodes, data types, addressing modes |
| Instruction length and format | fixed 32-bit instructions, R/I/J/FR formats |

### Three instruction classes

| Class | Purpose | MIPS examples |
|---|---|---|
| **Operate** | run an ALU operation | `add`, `sub`, `and`, `or`, `slt`, `sll`, `srl`, `mult` |
| **Data movement** | move values memory ↔ registers | `lw`, `sw`, `lwc1`, `swc1` |
| **Control flow** | change the order of execution | `beq`, `bne`, `blez`, `bgtz`, `j`, `jal`, `jr` |

The three classes are not a taxonomy for its own sake: each class corresponds to *one different
format* and *one different part of the datapath*, which is exactly what makes the single-cycle
datapath of Topic 4 decodable.

---

## 8. Operate instructions: `add` and the R-type format

High-level `a = b + c;` becomes `add a, b, c`:

- `add` — the **mnemonic**, naming the operation;
- `b`, `c` — the **source** operands;
- `a` — the **destination**;
- semantics: $a \leftarrow b + c$.

We do not have variables, only registers, so `b = $s1`, `c = $s2`, `a = $s0`.

### Encoding it (p. 31)

![[COMP4611L3_2026F.pdf#page=31]]
*Figure: from `add $s0,$s1,$s2` to the 32-bit machine code 0x02328020. (`COMP4611L3_2026F.pdf` p. 31)*

![[COMP4611L3_2026F.pdf#page=32]]
*Figure: R-type field layout — opcode 6, rs 5, rt 5, rd 5, shamt 5, funct 6. (`COMP4611L3_2026F.pdf` p. 32)*

| Field | Width | Meaning | Here |
|---|---|---|---|
| `op` | 6 | 0 marks an R-type (operation comes from `funct`) | 0 |
| `rs` | 5 | first source register | `$s1` = 17 |
| `rt` | 5 | second source register | `$s2` = 18 |
| `rd` | 5 | destination register | `$s0` = 16 |
| `shamt` | 5 | shift amount, for shifts only | 0 |
| `funct` | 6 | which R-type operation | 32 = `add` |

**In plain words.** The 32-bit word is a form with six boxes printed on it. Because every MIPS
instruction is the same width, the hardware never has to look at one instruction to find out how
long the next one is — the boxes are always in the same place. The first box is a coarse label
("this is a register-to-register job"), and the *last* box, not the first, says which job: that is
why there are 64 different R-type operations sharing one opcode, distinguished only by `funct`.

**Example (traced).** `add $s0,$s1,$s2` with `$s1` = 5 and `$s2` = 7:

| Field | Decimal | Binary |
|---|---|---|
| `op` | 0 | `000000` |
| `rs` | 17 | `10001` |
| `rt` | 18 | `10010` |
| `rd` | 16 | `10000` |
| `shamt` | 0 | `00000` |
| `funct` | 32 | `100000` |

Concatenating: `000000 10001 10010 10000 00000 100000`. Grouping into nibbles gives
`0000 0010 0011 0010 1000 0000 0010 0000` = **`0x02328020`**. At run time the `rs`/`rt` boxes select
registers 17 and 18, the ALU produces 12, and 12 is written into register 16.

> [!tip] Reading MIPS machine code by eye
> Check the top 6 bits first. `000000` = R-type, so look at the *bottom* 6 bits for the operation.
> `001000` = `addi`, `100011` = `lw`, `101011` = `sw`, `000100` = `beq`, `000010` = `j`, `000011` = `jal`.

---

## 9. Data movement: `lw`, `sw`, and the I-type format

Operands usually start in memory. A **load** copies memory → register; a **store** copies register
→ memory.

High-level `a = A[i]` becomes `load a, A, i`, where `A` is the **base address** and `i` the
**offset**, with semantics $a \leftarrow \text{Memory}[A + i]$.

The complication is byte addressing: `A[2]` is the *third* word, but its **byte** address is
$2 \times 4 = 8$ bytes past the base.

![[COMP4611L3_2026F.pdf#page=35]]
*Figure: `a = A[2]` compiles to `lw $s3, 8($s0)` because each word is 4 bytes. (`COMP4611L3_2026F.pdf` p. 35)*

**In plain words.** The array is a terrace of identical houses and `A` is the number of the first
one. "The third house" is not address `A + 2` if each house occupies four street numbers — you must
walk past numbers 0, 1, 2, 3 to reach house 1. So the index is a house count while the offset in the
instruction is a street-number count, and the assembler (or you) multiplies by four to convert. Get
this wrong and you read half of one integer and half of the next, which usually still *looks* like
a plausible number.

**Example (traced).** `int A[10]` at base `0x10010000`, with `A[0]=11, A[1]=22, A[2]=33`:

| Element | Word index | Byte offset | Address | Value |
|---|---|---|---|---|
| `A[0]` | 0 | 0 | `0x10010000` | 11 |
| `A[1]` | 1 | 4 | `0x10010004` | 22 |
| `A[2]` | 2 | 8 | `0x10010008` | 33 |

With `$s0 = 0x10010000`, `lw $s3, 8($s0)` puts 33 in `$s3`. The instruction
`lw $s3, 2($s0)` would instead load a 4-byte word starting at `0x10010002` — the top two bytes of
`A[0]` glued to the bottom two bytes of `A[1]`, i.e. a garbage value, not `A[2]`.

### I-type encoding (p. 36)

![[COMP4611L3_2026F.pdf#page=36]]
*Figure: I-type layout — opcode 6, rs 5, rt 5, immediate 16. (`COMP4611L3_2026F.pdf` p. 36)*

| Field | Width | `addi` | `lw` | `sw` | `beq` |
|---|---|---|---|---|---|
| `op` | 6 | 8 | 35 | 43 | 4 |
| `rs` | 5 | source | base address | base address | first compared reg |
| `rt` | 5 | **destination** | **destination** | **source** (value stored) | second compared reg |
| `imm` | 16 | immediate | byte offset | byte offset | branch offset |

Note `rt` changes meaning: destination for `addi`/`lw`, source for `sw`. That is exactly why the
format is not self-describing — the opcode must be decoded first.

**Example (traced).** `lw $s3, 8($s0)`: `op`=35, `rs`=`$s0`=16, `rt`=`$s3`=19, `imm`=8.

| Field | Decimal | Binary |
|---|---|---|
| `op` | 35 | `100011` |
| `rs` | 16 | `10000` |
| `rt` | 19 | `10011` |
| `imm` | 8 | `0000 0000 0000 1000` |

Machine code `100011 10000 10011 0000000000001000` = **`0x8E130008`**.

**Example (traced).** `addi $s0, $s1, 5` (p. 37): `op`=8, `rs`=17, `rt`=16, `imm`=5, giving
`001000 10001 10000 0000000000000101` = **`0x22300005`**. Semantics
$\text{rt} \leftarrow \text{rs} + \text{sign-extend}(\text{imm})$.

> [!warning] The 16-bit immediate is **signed**
> `imm` is sign-extended, so the legal range is $-32768 \dots 32767$, not $0 \dots 65535$. And it
> is a **byte** offset for `lw`/`sw`, so the reachable range from one base register is only
> −32768 … +32767 bytes.

**In plain words.** The immediate box has room for exactly sixteen digits, and the machine refuses
to decide whether they mean "a big positive number" or "a negative one" per instruction — the
convention is fixed: the top digit is a sign. So the largest positive constant you can write
directly is three hundred and twenty-seven sixty-seven; one more and it flips over into a large
negative number, and the program computes nonsense instead of failing. The standard escape is to
build the big constant in two steps, adding the first 32760, then a small remainder on top.

**Example (traced).** `lw $t0, 32768($s0)` is **illegal** — 32768 > 32767. The two-step fix:

```asm
addi $t1, $s0, 32760   # t1 = base + 32760  (32760 ≤ 32767, legal)
lw   $t0, 8($t1)       # t0 = Mem[base + 32768]
```

The same trick covers array accesses beyond the ±32 KB window from one base register: for large
arrays the compiler re-bases (`add $t1,$s0,$t2` with `$t2 = 4*i`) and keeps the offset small.

### Store

`sw $s3, 8($s0)` is `lw` with opcode 43 and the data flowing the other way:
$\text{Memory}[\text{rs} + \text{sign-extend}(\text{imm})] \leftarrow \text{rt}$.
`sw` is I-type for the same reason: it also needs a base register plus an offset.

---

## 10. Control instructions: jumps and branches

A program executes in order, one instruction after another — the PC simply advances by 4. Control
instructions are the sanctioned way to break that:

- **Conditional branches** implement decisions (`if`, `else`, loops' tests): `beq`, `bne`, `blez`, `bgtz`.
- **Jumps** implement loops and function calls: `j`, `jal`, `jr`.

### Unconditional jumps (p. 39)

![[COMP4611L3_2026F.pdf#page=39]]
*Figure: J-type layout and the semantics of `j`, `jal`, and `jr`. (`COMP4611L3_2026F.pdf` p. 39)*

| Instruction | Format | Semantics |
|---|---|---|
| `j target` | J-type (op 2) | $\text{PC} \leftarrow \text{PC}^+[31{:}28] \;\vert\; \text{target} \times 4$ |
| `jal target` | J-type (op 3) | same, **and** `$ra` $\leftarrow$ $\text{PC}^+$ |
| `jr rs` | R-type (funct 8) | $\text{PC} \leftarrow \text{Register}[\text{rs}]$ |

Here $\text{PC}^+ = \text{PC} + 4$, the address of the next sequential instruction.

The J-type `target` is **26 bits**, and it is shifted left by 2 (all instructions are 4-byte
aligned, so the bottom two bits of an address are always 00 and need not be stored). The top four
bits are *copied from the current PC* rather than stored — so a jump can only reach within the same
256 MB region.

**In plain words.** A jump instruction is too short to hold a full 32-bit address, so it holds only
the *low* 26 bits of a word address and borrows the *high* four bits from wherever it happens to be
standing. The consequence is that you can jump anywhere within your own quarter of the address
space but cannot leap to another quarter — a limit that rarely bites in practice, because programs
are small, and that a compiler works around by routing through a register (`jr`), which carries the
full 32 bits.

**Example (traced).** `j Loop` sitting at `0x00400014`, with `Loop` at `0x00400008`:

- target field = `0x00400008 / 4` = `0x00100002` = `0000 0100 0000 0000 0000 0000 0010`.
- next PC top 4 bits = `0x0` (from `0x00400018`).
- rebuilt PC = `0x0 ‖ 0x00100002 ‖ 00` = `0x00400008`. ✓
- `$ra` is untouched by `j`.

For `jal sum` at `0x00400018` with `sum` at `0x00400040`: `$ra` $\leftarrow$ `0x0040001C`, PC
$\leftarrow$ `0x00400040`. The function returns with `jr $ra`.

**In plain words.** The call-leaves-a-bookmark instruction is exactly that: the bookmark is not
the address of the jump but the address of the *next* line, so that when the reader is finished with
the detour it can be dropped back precisely where it left off. The return instruction is "go back to
the bookmark". Forgetting to preserve the bookmark before a second detour is the classic way to
lose it: the inner call overwrites the only copy, and the outer function returns to the wrong
place — usually as a crash much later, far from the real mistake.

### Conditional branches (p. 40)

![[COMP4611L3_2026F.pdf#page=40]]
*Figure: I-type branch format and the four common MIPS branches. (`COMP4611L3_2026F.pdf` p. 40)*

$$\text{B} = \text{PC} + 4 + \text{sign-extend}(\text{offset}) \times 4$$

$$\text{PC} \leftarrow \text{condition} \;?\; B : \text{PC} + 4$$

| Instruction | Opcode | Register fields | Taken when |
|---|---|---|---|
| `beq rs, rt, offset` | 4 (`000100`) | `rs`, `rt` | `Reg[rs] = Reg[rt]` |
| `bne rs, rt, offset` | 5 (`000101`) | `rs`, `rt` | `Reg[rs] ≠ Reg[rt]` |
| `blez rs, offset` | 6 (`000110`) | `rs`; `rt` = 0 | `Reg[rs] ≤ 0` |
| `bgtz rs, offset` | 7 (`000111`) | `rs`; `rt` = 0 | `Reg[rs] > 0` |

The offset is **relative to `PC + 4`**, not to `PC`, and it counts **instructions (words)**, so it is
multiplied by 4 to become a byte offset.

**In plain words.** Two people reading the same book need a way to skip a passage: "skip forward
two pages" only works if both are on the same page. A branch is a *relative* instruction — go
forward or back by a given number of lines from where you are — so the same compiled code works
wherever it is loaded, at the cost of a limited reach. The count is in *lines* (instructions), not
in letters (bytes), which is why the hardware multiplies by four before touching the address.

**Example (traced).** `beq $s3, $s4, L1` at `0x00400024` with `offset` = 2 and `$s3 = $s4`:

- $\text{PC}+4 = 0x00400028$
- byte offset = $2 \times 4 = 8$
- target = $0x00400028 + 8 = \mathbf{0x00400030}$, so PC $\leftarrow$ `0x00400030`.
- If `$s3 ≠ $s4`, PC $\leftarrow$ `0x00400028` (fetch continues in line).

### Translating C to MIPS (from Tutorial 1)

**`if` — invert the condition with a branch.**

```c
if (i == j) f = g + h;
f = f - i;
```
```asm
        bne $s3, $s4, L1     # i != j: skip the body
        add $s0, $s1, $s2    # f = g + h
L1:     sub $s0, $s0, $s3    # f = f - i   (runs either way)
```

**In plain words.** The assembly language has no `if`, only "jump over this bit". So you phrase the
condition as *when to skip*: if the equality is false, hop over the assignment; otherwise fall
through it. Choosing `bne` over `beq` here is not cosmetic — the label at the end of the body is
exactly the place you want to land when the test fails.

**`if`–`else` — branch plus an unconditional jump.**

```c
if (i == j) f = g + h; else f = f - i;
```
```asm
        bne $s3, $s4, Else
        add $s0, $s1, $s2    # then-branch
        j   Done
Else:   sub $s0, $s0, $s3    # else-branch
Done:
```

Without the `j Done`, the then-branch would fall straight into the else-branch and both would run.

**In plain words.** Two roads that must not meet. The conditional branch sends the failing case down
the second road; the plain jump at the end of the first road is what stops the first traveller from
carrying on into the second.

**`while` — test at the top, jump back.**

```c
while (pow != 128) { pow *= 2; x++; }
```
```asm
Loop:   beq $s0, $t0, Done   # exit when pow == 128
        sll $s0, $s0, 1      # pow *= 2   (shift left = multiply by 2)
        addi $s1, $s1, 1     # x++
        j   Loop
Done:
```

**Example (traced).** `$s0 = 8`, `$t0 = 128`, `$s1 = 0`. Iterations: 8 → 16 → 32 → 64 → 128, so
the body runs **4** times, `$s0` ends at 128 and `$s1` at 4. Branch offsets for the loop above,
placed at `0x00400008` (the `slt`/`beq` pair at `0x00400008`/`0x0040000C`, `Done` at `0x00400018`):
`beq` offset = $(0x18 - 0x10)/4 = 2$; `j Loop` target field = $0x00400008/4 = 0x00100002$.

**Function calls.**

- **Caller**: arguments in `$a0`–`$a3`, `jal`, result read from `$v0`.
- **Callee**: result in `$v0`, return via `jr $ra`.
- `$sp` starts high and grows **down**; save/restore any `$s` register you touch.

```asm
diffofsums:
        addi $sp, $sp, -4     # allocate one word
        sw   $s0, 0($sp)      # save $s0 (callee-saved)
        add  $t0, $a0, $a1
        add  $t1, $a2, $a3
        sub  $s0, $t0, $t1
        add  $v0, $s0, $zero  # return value
        lw   $s0, 0($sp)      # restore $s0
        addi $sp, $sp, 4      # deallocate
        jr   $ra
```

> [!warning] `$t` versus `$s` is a contract, not a hint
> A callee may destroy `$t0`–`$t9` without telling anyone; it **must** preserve `$s0`–`$s7`. If you
> keep a loop counter in `$t0` across a call, expect it to come back changed — this is the single
> most common source of "works until I add a `printf`" bugs.

---

## 11. Floating point: coprocessor 1

MIPS has always had floating-point instructions, executed by an **FPU** with its *own* register
file `$f0`–`$f31`. MIPS names the FPU **Coprocessor 1 (CP1)**; on early chips it was a separate
package, later on-die.

The three pieces you need:

| Job | Instruction | Format | Meaning |
|---|---|---|---|
| Memory → FPR | `lwc1 $f2, 8($s0)` | I-type (op 49) | raw bit copy of a word |
| FPR → memory | `swc1 $f2, 8($s0)` | I-type (op 57) | raw bit copy back |
| Compute | `add.s $f0, $f2, $f4` | FR-type | `$f0 ← $f2 + $f4`, single precision |

![[COMP4611L3_2026F.pdf#page=42]]
*Figure: `lwc1` as I-type and `add.s` as FR-type, with `fmt` selecting single or double precision. (`COMP4611L3_2026F.pdf` p. 42)*

FR-type fields: `op` = 17 (`cop1`), `fmt` (16 = `.s`, 17 = `.d`), `ft`, `fs`, `fd`, `funct`
(0 = `add`). Note it is *not* an R-type: the operation lives in `funct` but `fmt` occupies the
`rs` slot, and the register numbers address `$f` registers, not `$` registers.

**In plain words.** A float in memory is just thirty-two bits with a private convention about which
bits mean exponent and which mean fraction. `lwc1` does not know or care about that convention: it
is a photocopier moving the pattern from a memory cell into a floating-point tray. That is why
`lwc1` on an integer word does not convert anything — you get the same bits reinterpreted, which
looks like a tiny denormal number instead of 42. Only `add.s` and friends interpret the pattern.

**Example (traced).** `float X[10]` at `0x10010000`, `X[2] = 3.5`:

- byte address = `0x10010000 + 8` = `0x10010008`.
- `lwc1 $f2, 8($s0)` with `$s0 = 0x10010000` copies the 32 bits `0x40600000` (the IEEE 754 pattern
  for 3.5) into `$f2`. Field values: `op`=49, `rs`=16, `ft`=2, `imm`=8.
- `add.s $f0, $f2, $f4` with `$f4` holding 1.5 gives `$f0` = 5.0 (`0x40A00000`).
- `add.d`/`l.d` would touch **two** consecutive `$f` registers per value; using `.s` on a double
  silently pairs the wrong registers.

> [!warning] `$f` registers are not `$` registers
> `add $s0,$s1,$s2` and `add.s $f0,$f2,$f4` are different register files entirely. There is no
> `move` between them; data crosses via memory (`swc1`/`lw`) or `mfc1`/`mtc1`.

---

## 12. Highlights and exam traps

### What the lecture said we learned (p. 44)

- Basic elements of a computer and the **von Neumann model**: memory, processing unit, I/O, and the
  control unit that sequences them.
- **ISAs** as the software/hardware interface, with MIPS as the worked example: operate, data
  movement, and control instructions.
- The four MIPS instruction formats: **R** (register–register), **I** (immediate / load-store /
  branch), **J** (jump), and **FR** (floating-point register).
- The whole stack this sits in: Problem → Algorithm → Program/Language → System Software →
  **SW/HW Interface (ISA)** → Micro-architecture → Logic → Devices → Electrons.

### Wide view (p. 43)

x86, PDP-11, VAX, IBM 360, CDC 6600, SIMD ISAs (CRAY-1, Connection Machine), VLIW ISAs
(Multiflow, Cydrome, IA-64/EPIC), PowerPC/POWER, and the RISC family (Alpha, MIPS, SPARC, ARM,
RISC-V). The fundamental differences are *how instructions are specified and what they do* — how
complex instructions are, which data types exist, and which addressing modes are offered.

> [!tip] Exam traps
> - **"Address space" vs "addressability."** Address space = how many locations; addressability =
>   bits per location. MIPS: $2^{32}$ locations × 8 bits. Doubling addressability doubles capacity
>   without changing the address space.
> - **Offsets in `lw`/`sw` are bytes, not words.** `A[i]` is at `base + 4i`; `lw $t0, 2($s0)` is not
>   `A[2]` and does not fault — it silently returns a spliced garbage word.
> - **Branch offsets count instructions and are relative to `PC + 4`.** `beq` with offset 2 at
>   `0x00400024` jumps to `0x00400030`; add 4 first, *then* 2 × 4.
> - **J-type stores 26 bits and borrows 4.** `target` = address / 4; the top 4 bits come from
>   `PC + 4`, so a jump cannot leave the current 256 MB region. `jr` has no such limit.
> - **`jal` writes `$ra = PC + 4`**, i.e. the address of the instruction *after* the call — not the
>   call's own address and not the target. Nested calls must spill `$ra` to the stack.
> - **`rt` is not always a destination.** Destination in `addi`/`lw`; *source* in `sw` and in
>   `beq`/`bne`.
> - **The 16-bit immediate is signed.** Range −32768 … 32767. 32768 is invalid, and for `lw`/`sw`
>   the whole offset range is only ±32 KB, so large arrays need re-basing.
> - **R-type ops share opcode 0.** `add` is identified by `funct` = 32, not by the opcode. `addi`
>   (op 8) is a completely different format.
> - **`$0` is hard-wired to zero** and silently discards writes; `$t` registers are caller-saved,
>   `$s` registers are callee-saved.
> - **`lwc1` is a bit copy, not a conversion.** No numeric conversion happens between memory and an
>   FPR; `add.s`/`add.d` set `fmt` (16/17) and address a *separate* `$f` register file.
> - **Sequential processing is a property of the model, not of the ISA.** Out-of-order execution
>   (Topic 7) breaks the *implementation's* sequential order while preserving the ISA result.
> - **Deck typos worth noting.** p. 37's binary for `addi $s0,$s1,5` shows `rt` as `10010` (18),
>   inconsistent with its own field table (`rt` = 16); the correct encoding is `0x22300005`. p. 42's
>   semantics line says `$f2 ← Memory[$s0 + 0]` for `lwc1 $f2, 8($s0)`; the offset is 8.
