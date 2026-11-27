# COMP4611 Homework 2 — Solutions

Design and Analysis of Computer Architectures · Fall 2026 · Lectures 4 & 5

---

## Part A — Single Choice Questions (3 pts each)

| Question | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|----------|---|---|---|---|---|---|---|---|---|----|
| Answer   | B | D | A | C | D | B | D | C | A | B  |

### Explanations

**Q1 — B.** Both machines *correctly implement the same ISA*, so after running the same program
from the same initial state they must reach the **same architectural state** — identical final
register and memory values. Everything else differs by design: execution time (A), number of
in-flight instructions (C, 1 vs. up to 5), and internal control signals (D) are microarchitectural.

**Q2 — D.** For `lw $t0, 12($s1)`: `ALUSrc = 1` selects the sign-extended immediate, so the ALU
adds **12 to the contents of `$s1`** to form the memory address; then `MemtoReg = 1` routes the
**memory read data** to the writeback, and `RegWrite = 1` writes it into **`$t0`** (rt). Option C is
wrong because the *ALU result* (the address) is not what gets written.

**Q3 — A.** For `sw`, `RegWrite = 0`, so the register file is not written at all. The destination
register number selected by RegDst therefore has **no effect** → don't care.

**Q4 — C.** Branch target = (PC+4) + sign_extend(imm)×4 = 0x00001004 + (−3×4)
= 0x00001004 − 0xC = **0x00000FF8**.

**Q5 — D.** Compute each instruction's total path (instr-mem → reg-read → ALU → [data-mem] → [writeback]):

- `add`: 200 + 100 + 150 + 100 = 550 ps
- `lw`: 200 + 100 + 150 + 250 + 100 = **800 ps** ← critical path
- `sw`: 200 + 100 + 150 + 250 = 700 ps (no writeback)
- `beq`: 200 + 100 + 150 = 450 ps

Minimum period = slowest instruction = **800 ps**.

**Q6 — B.** Minimum clock period = slowest stage + overhead = max(200,150,180,160,190) + 20
= 200 + 20 = **220 ps**. One instruction passes through 5 stages → latency = 5 × 220 = **1100 ps**.

**Q7 — D.** I1 writes `$t0`; I2 reads `$t0` → **RAW** (read-after-write) dependence, the one that
requires forwarding/stalling. The `$t1` and `$t0` WAR/WAW relations are not hazards in this
in-order pipeline (reads happen in ID, writes in WB, in program order).

**Q8 — C.** `sub` needs the value loaded by `lw`. A load produces data only at the **end of MEM**,
so it cannot be forwarded by MEM-to-EX (which carries only the previous ALU result). `sub` must
stall **1 cycle** (a load-use stall), after which **WB-to-EX** supplies the loaded value. (Option A
ignores that `lw` is the most recent writer of `$t0`, not `add`.)

**Q9 — A.** IF (instruction fetch) and the load's MEM both want the single shared memory in the
same cycle → they **contend** (structural hazard). The register file writes in the first half-cycle
and reads in the second, so ID **can read** the `$t0` just written by WB in that same cycle.

**Q10 — B.** Pipelined multiplier: new multiply starts every cycle, each takes 7 cycles.
M1 starts cycle 1 → ends cycle 7; M2 starts cycle 2 → ends cycle 8; M3 starts cycle 3 →
ends **cycle 9**.

---

## Question 11 — Datapath and performance (30 pts)

Initial: `$s0 = 0x10010000`, `$s1 = 3`, `$s2 = 10`; `Mem[0x10010000] = 7`, `Mem[0x10010004] = 0`.

```
0x00400000  lw   $t0, 0($s0)     # $t0 = Mem[0x10010000] = 7
0x00400004  add  $t1, $t0, $s1   # $t1 = 7 + 3 = 10
0x00400008  sw   $t1, 4($s0)     # Mem[0x10010004] = 10
0x0040000C  beq  $t1, $s2, 2     # 10 == 10 → taken
```

### (a) Signal values [6 pts]

Signals: **A** = first ALU input (Read data 1 = rs), **B** = second ALU input (ALUSrc mux output),
**C** = ALU result, **D** = register-file writeback data (MemtoReg mux output).

| | A | B | C | D |
|---|---|---|---|---|
| `lw` | **0x10010000** | **0** | **0x10010000** | **7** |
| `add` | — | — | **10** | **10** |

- `lw`: A = `$s0` = 0x10010000; B = sign-extended immediate 0; C = A+B = 0x10010000 (the address);
  D = memory read data at that address = **7**.
- `add`: C = `$t0 + $s1` = 7 + 3 = **10**; D = C (MemtoReg = 0) = **10**.

### (b) Control table [8 pts]

| Instruction | RegWrite | ALUSrc | MemtoReg | MemWrite |
|---|---|---|---|---|
| `lw` | 1 | 1 | 1 | 0 |
| `add` | 1 | 0 | 0 | 0 |
| `sw` | 0 | 1 | X | 1 |
| `beq` | 0 | 0 | X | 0 |

- `sw`: RegWrite = 0 → MemtoReg is don't-care; ALUSrc = 1 to add the offset; MemWrite = 1.
- `beq`: ALU compares the two registers → ALUSrc = 0; no write → RegWrite = 0, MemtoReg = X.

### (c) Branch analysis [4 pts]

```
Branch = 1        Zero = 1        PCSrc2 = 1
```

- `Branch` is asserted because this is a `beq`.
- `Zero = 1` because the ALU computes `$t1 − $s2 = 10 − 10 = 0`.
- `PCSrc2 = Branch AND Zero = 1 AND 1 = 1`.

Branch target:

```
target = (PC + 4) + sign_extend(imm) × 4
       = (0x0040000C + 4) + 2 × 4
       = 0x00400010 + 8
       = 0x00400018
```

**Branch taken? Yes.** **Next PC = 0x00400018.**

### (d) Single-cycle timing [6 pts]

Delays: instr-mem 200, reg-read 100, ALU 200, data-mem 250, writeback 100 ps.

**(i)** Greatest delay = **`lw`**.

Critical path: **instruction memory → register-file read → ALU → data memory → register-file writeback**

```
total = 200 + 100 + 200 + 250 + 100 = 850 ps
```

**(ii)** Minimum clock period = **850 ps** (must fit the slowest instruction, `lw`).

`add` occupies a full cycle anyway because the single-cycle machine uses **one fixed clock
period for every instruction** — the period is set by the worst-case (critical) path, so even a
600 ps `add` must wait out the full 850 ps cycle. The clock cannot be lengthened/shortened per
instruction.

**(iii)** Total time = 4 instructions × 850 ps = **3400 ps**.

### (e) Pipeline comparison [6 pts]

Stage delays: IF = 200, ID = 100, EX = 200, MEM = 250, WB = 100 ps; zero overhead.

**(i)** Slowest stage = **MEM** (250 ps). Pipeline clock period = **250 ps**.

**(ii)** 20 instructions, 5 stages, starts empty, no stalls:
first completes at end of cycle 5, then 1 more per cycle →
cycles = 5 + (20 − 1) = **24**.

Total pipeline time = 24 × 250 = **6000 ps**.

**(iii)** Single-cycle total = 20 × 850 = **17000 ps**.

Speedup = 17000 / 6000 = **2.83**.

---

## Question 12 — Pipeline hazards and forwarding (40 pts)

```
I1: add $t0, $t1, $t2
I2: sub $t3, $t0, $t4
I3: lw  $t5, 0($s0)
I4: add $t6, $t5, $t7
```

### (a) RAW dependencies [6 pts]

| Producing instruction | Consuming instruction | Register |
|---|---|---|
| **I1 (add)** | **I2 (sub)** | **$t0** |
| **I3 (lw)** | **I4 (add)** | **$t5** |

### (b) No forwarding [12 pts]

**(i)** Timing grid (write-first-then-read register file):

| Cycle | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| I1 add | IF | ID | EX | MEM | WB | | | | | | | |
| I2 sub | | IF | ID | ID | ID | EX | MEM | WB | | | | |
| I3 lw | | | IF | IF | IF | ID | EX | MEM | WB | | | |
| I4 add | | | | | | IF | ID | ID | ID | EX | MEM | WB |

- I2 reads `$t0` in ID during cycle 5 (same cycle I1 writes it in WB).
- I3 is held in IF (cycles 4–5) while I2 stalls in ID.
- I4 reads `$t5` in ID during cycle 9 (same cycle I3 writes it in WB).

**(ii)** Stalls:

| Instruction | Number of stall cycles | Cycle when ID reads the producer's result |
|---|---|---|
| **I2** | **2** | **5** |
| **I4** | **2** | **9** |

**(iii)** Total cycles without forwarding = **12** (I4 finishes WB in cycle 12).

### (c) With MEM-to-EX and WB-to-EX forwarding [14 pts]

**(i)** Timing grid:

| Cycle | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|
| I1 add | IF | ID | EX | MEM | WB | | | | |
| I2 sub | | IF | ID | EX | MEM | WB | | | |
| I3 lw | | | IF | ID | EX | MEM | WB | | |
| I4 add | | | | IF | ID | ID | EX | MEM | WB |

**(ii)** Forwarding paths:

| Dependency from (a) | Forwarding path | Cycle |
|---|---|---|
| I1 → I2 on `$t0` | **MEM-to-EX** | **4** |
| I3 → I4 on `$t5` | **WB-to-EX** | **7** |

- Cycle 4: I1's ALU result sits in `EX/MEM` and is forwarded to I2's EX input.
- Cycle 7: I3's loaded value sits in `MEM/WB` and is forwarded to I4's EX input.

**(iii)** Stall cycles = **1**.

Explanation: I2's `$t0` is produced by `add` at the end of EX (cycle 3), so MEM-to-EX supplies it
in cycle 4 with **no stall**. I4's `$t5` is produced by `lw` only at the end of MEM (cycle 6), but I4
needs it at the start of EX in cycle 6 — that is one cycle too early — so I4 stalls **1 cycle**, then
WB-to-EX supplies `$t5` in cycle 7. (This is the classic load-use stall.)

**(iv)** Total cycles with forwarding = **9** (I4 finishes WB in cycle 9).

### (d) Branch example [8 pts]

```
B:  beq $s1, $s2, T      $s1 = $s2 = 5
S1: addi $t0, $t0, 1
S2: sw   $t3, 0($s0)
T:  sub  $t4, $t5, $t6
```

Predict not taken; resolve at end of EX; no delay slot; pipeline starts empty.

**(i)** **Taken? Yes** ($s1 == $s2 == 5). Decision available at the end of **cycle 3**
(B: IF(1) ID(2) EX(3)).

**(ii)** Flushed instructions:
**S1** in stage **ID**; **S2** in stage **IF**.
(At end of cycle 3, S1 is in ID and S2 is in IF on the mispredicted path.)

**(iii)** T begins IF in cycle **4** (target fetched the cycle after the taken branch is resolved).

**(iv)** After T completes: `$t0` = **7**; memory word at `$s0` = **0**.

- S1 (`addi $t0,$t0,1`) and S2 (`sw $t3,0($s0)`) are **flushed**, so neither `$t0` nor memory changes.
- T (`sub $t4,$t5,$t6`) writes only `$t4`, leaving `$t0` and memory untouched.
