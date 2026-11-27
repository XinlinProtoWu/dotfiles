# Topic 4 — Single-Cycle MIPS Microarchitecture

> Source: `COMP4611L4_2026F.pdf` (Lecture 4)

## 1. ISA vs. microarchitecture

- **ISA** = the contract (what instructions do to architectural state).
- **Microarchitecture** = one specific hardware implementation.
- Same ISA can have many microarchitectures (single-cycle, pipelined, out-of-order, …).

Processing one instruction = transforming architectural state: `AS → AS'`.

## 2. Datapath + control

- **Datapath** — elements that move/transform data: functional units (ALU), storage
  (registers, memories), and wires/muxes/decoders.
- **Control logic** — produces **control signals** that tell datapath elements what to do.

Assumptions (single-cycle):

- Memory and register file are fast enough to finish in one cycle.
- Register file: **combinational read**, **synchronous write** (on rising edge).

## 3. The 5 generic instruction steps

```
IF        fetch instruction from instruction memory (PC)
ID/RF     decode + read source registers
EX/AG     ALU operation / compute memory address
MEM       data-memory read (lw) or write (sw)
WB        write result back to register file
```

## 4. State elements

- **PC** — 32-bit register holding the next instruction address.
- **Instruction memory** — address → 32-bit instruction.
- **Register file** — 32×32-bit, **2 read ports + 1 write port**.
- **Data memory** — MemWrite=1 stores; MemRead=1 reads.

## 5. The key control signals

| Signal | 0 (de-asserted) | 1 (asserted) |
|---|---|---|
| **RegDst** | write reg = rt `inst[20:16]` | write reg = rd `inst[15:11]` |
| **ALUSrc** | 2nd ALU input = Read data 2 | 2nd ALU input = sign-extended immediate |
| **MemtoReg** | writeback = ALU result | writeback = memory data |
| **RegWrite** | no register write | write register |
| **MemRead** | — | read data memory |
| **MemWrite** | — | write data memory |
| **Branch** | — | it's a `beq` |
| **PCSrc2** = Branch AND Zero | next PC = PC+4 | next PC = branch target |
| **PCSrc1 (Jump)** | — | next PC = jump target |

Signal equations (each `isX` detects instruction X):

```
RegWrite  = isRTypeALU OR isADDI OR isLW
ALUSrc    = isADDI OR isLW OR isSW
MemtoReg  = isLW
MemWrite  = isSW
MemRead   = isLW
PCSrc1    = isJ
PCSrc2    = isBEQ AND Zero
```

> 💡 **Example — `lw $t0, 12($s1)`:** ALU computes `$s1 + 12` (ALUSrc=1), that becomes the
> data-memory **address**, the memory **read data** is written to `$t0` (MemtoReg=1, RegWrite=1).
> The ALU result is *not* written to the register — the *memory value* is.

## 6. What each instruction type uses

| Instr          | RegDst | ALUSrc | MemtoReg | RegWrite | MemWrite | MemRead | Branch   |
| -------------- | ------ | ------ | -------- | -------- | -------- | ------- | -------- |
| R-type (`add`) | 1      | 0      | 0        | 1        | 0        | 0       | 0        |
| I-ALU (`addi`) | 0      | 1      | 0        | 1        | 0        | 0       | 0        |
| `lw`           | 0      | 1      | 1        | 1        | 0        | 1       | 0        |
| `sw`           | X      | 1      | X        | 0        | 1        | 0       | 0        |
| `beq`          | X      | 0      | X        | 0        | 0        | 0       | 1        |
| `j`            | X      | X      | X        | 0        | 0        | 0       | (Jump=1) |

> 💡 **Why is RegDst a "don't care" for `sw`?** Because `RegWrite = 0`: no register is written,
> so it does not matter whether rt or rd is selected. Same reason MemtoReg is don't-care.

## 7. Branch / jump address computation

- **`j target`**: `PC ← { (PC+4)[31:28], target<<2 }` (keep top 4 bits).
- **`beq rs,rt,imm`**: `target = (PC+4) + sign_extend(imm)<<2`;
  taken iff `rs == rt` (ALU subtracts → **Zero** flag).

> 💡 **Example:** `beq` at `0x00001000`, immediate `-3`, taken:
> target = 0x00001004 + (−3×4) = 0x00001004 − 12 = **0x00000FF8**.

## 8. Single-cycle performance analysis

```
Time = #instructions × CPI × clock period
```

- Single-cycle **CPI = 1** for every instruction.
- The **clock period is set by the slowest instruction** (the critical path).
- Fast instructions waste the rest of the cycle → violates "make the common case fast".

> 💡 **Example (Lecture 4):** Instr-mem 200, Reg-read 100, ALU 200, Data-mem 200, Reg-write 100 ps:

| Instr  | Path            | Total                 |
| ------ | --------------- | --------------------- |
| R-type | IM+RF+ALU+WB    | 600 ps                |
| ADDI   | IM+RF+ALU+WB    | 600 ps                |
| LW     | IM+RF+ALU+DM+WB | **800 ps** ← critical |
| SW     | IM+RF+ALU+DM    | 700 ps                |
| BEQ    | IM+RF+ALU       | 500 ps                |
| J      | IM              | 200 ps                |
>**Every** instruction pays an 800 ps cycle even though only `lw` needs it.
## 9. Why pipelining comes next

Single-cycle cannot reach high frequency and wastes cycles for fast instructions. The fix
(discussed in Topic 5) is to split the datapath into stages and overlap instruction execution.
