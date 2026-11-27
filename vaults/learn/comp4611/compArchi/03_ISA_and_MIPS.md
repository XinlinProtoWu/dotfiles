# Topic 3 — Von Neumann Model & the MIPS ISA

> Source: `COMP4611L3_2026F.pdf` (Lecture 3) + `COMP4611T1_2026F.pdf` (Tutorial 1, MIPS part)

## 1. The von Neumann model

A **program** = a set of **instructions**; the **instruction set** = everything the machine can do.

Five components:

1. **Memory** — stores program *and* data (addressable locations).
2. **Processing unit** — ALU + register file.
3. **Input** / 4. **Output** — peripherals.
5. **Control unit** — PC (next instruction) + IR (current instruction).

Two key properties:

- **Stored program** — instructions live in the same linear memory as data.
- **Sequential processing** — one instruction at a time; PC advances in order unless a control
  instruction changes it.

> 📌 Terms:
> - **Address space** = total number of locations (MIPS: 2³² with 32-bit addresses).
> - **Addressability** = bits per location (MIPS is **byte-addressable**, 8 bits).
> - **Word** = natural ALU operand size (MIPS word = 32 bits = 4 bytes).
> - **MAR / MDR** — Memory Address / Data registers used for loads and stores.

> 💡 **Byte vs. word addressing example:** element `A[i]` in a 32-bit integer array lives at
> byte address `base + 4×i` (4 bytes per element). So `A[2]` is at offset **8**, not 2.

### The dataflow model (contrast)

- von Neumann: instruction fires when the **PC reaches it** (control-flow order).
- Dataflow: instruction fires when its **operands are ready** (no PC). Inherently parallel.

## 2. Programmer-visible (architectural) state

- **Memory** M[0..N-1]
- **Registers** (named in the ISA; 32 general-purpose in MIPS)
- **Program counter (PC)**

Instructions transform this state: `AS → AS'`.

## 3. MIPS register file

| Name | Number | Use |
|---|---|---|
| `$0` / `$zero` | 0 | constant 0 |
| `$v0–$v1` | 2–3 | function return values |
| `$a0–$a3` | 4–7 | function arguments |
| `$t0–$t9` | 8–15, 24–25 | **temporaries (caller/not preserved)** |
| `$s0–$s7` | 16–23 | **saved (callee-preserved)** |
| `$k0–$k1` | 26–27 | OS |
| `$gp` | 28 | global pointer |
| `$sp` | 29 | stack pointer (grows **down**) |
| `$fp` | 30 | frame pointer |
| `$ra` | 31 | return address |

## 4. Three instruction classes

1. **Operate** — ALU work (`add`, `sub`, `and`, `or`, `slt`, `sll`, `srl`, …).
2. **Data movement** — memory ↔ registers (`lw`, `sw`, `lwc1`, …).
3. **Control** — change execution order (`beq`, `bne`, `j`, `jal`, `jr`, …).

## 5. MIPS instruction formats

### R-type (register–register)

![[COMP4611L3_2026F.pdf#page=32]]

*R-type field layout (Lecture 3, p. 32).*

`add $s0,$s1,$s2` → opcode 0, rs=$s1(17), rt=$s2(18), rd=$s0(16), shamt 0, funct 32
→ `000000 10001 10010 10000 00000 100000` = **0x02328020**. Semantics `rd ← rs + rt`.

### I-type (immediate / load-store / branch)

![[COMP4611L3_2026F.pdf#page=36]]

*I-type field layout (Lecture 3, p. 36).*

- `addi $s0,$s1,5`: `rt ← rs + sign_extend(imm)`. (opcode 8)
- `lw $s3, 8($s0)`: `rt ← Mem[rs + sign_extend(imm)]`. (opcode 35)
- `sw $s3, 8($s0)`: `Mem[rs + sign_extend(imm)] ← rt`. (opcode 43)
- `beq rs, rt, offset`: `if rs == rt: PC ← (PC+4) + sign_extend(imm)×4`.

### J-type (jump)

![[COMP4611L3_2026F.pdf#page=39]]

*J-type field layout + `j`/`jal`/`jr` semantics (Lecture 3, p. 39).*

- `j target`: `PC ← { (PC+4)[31:28], target, 00 }` (top 4 bits kept, ×4 alignment).
- `jal` also sets `$ra = PC + 4`.

### Floating point (coprocessor 1)

- `lwc1 $f2, 8($s0)` → raw **bit copy** from memory into `$f2` (no numeric conversion!).
- `add.s $f0,$f2,$f4` → FR-type, single-precision add.

> 💡 **Branch target example:** `beq` at `0x00400024`, immediate `+2`:
> target = (0x00400024+4) + 2×4 = `0x00400030`. The immediate counts *instructions* (words),
> so it is scaled by 4 to get the *byte* offset.

> ⚠️ **Immediate range:** a 16-bit immediate is **sign-extended**, so it covers
> −32768 … +32767. `lw $t0, 32768($s0)` is **illegal** (32768 exceeds 32767).
> Fix: `addi $t1,$s0,32760` then `lw $t0,8($t1)`.

## 6. Control flow in MIPS (Tutorial 1)

### if: invert the condition with a branch

```c
if (i == j) f = g + h;
f = f - i;
```
```asm
bne $s3, $s4, L1      # if i != j skip the "then" body
add $s0, $s1, $s2     # f = g + h
L1: sub $s0, $s0, $s3 # f = f - i
```

### if-else: branch + unconditional jump

```c
if (i == j) f = g + h; else f = f - i;
```
```asm
bne $s3, $s4, Else
add $s0, $s1, $s2     # if body
j   Done
Else: sub $s0, $s0, $s3
Done:
```

### while / for: loop test at top, jump back

```c
while (pow != 128) { pow *= 2; x++; }
```
```asm
while: beq $s0, $t0, done   # exit when pow == 128
       sll $s0, $s0, 1      # pow *= 2
       addi $s1, $s1, 1     # x++
       j    while
done:
```

## 7. Function calls and the stack (Tutorial 1)

Conventions:

- **Caller** passes args in `$a0–$a3`, calls `jal`, reads result from `$v0`.
- **Callee** returns result in `$v0`, returns via `jr $ra`.
- `jal target` = jump and link: `$ra ← PC+4`, then jump.
- **Stack** = LIFO region, `$sp` grows **down**. Use it to save/restore registers.

```asm
diffofsums:
  addi $sp, $sp, -4    # allocate 1 word
  sw   $s0, 0($sp)     # save $s0 (callee-saved)
  add  $t0, $a0, $a1
  add  $t1, $a2, $a3
  sub  $s0, $t0, $t1
  add  $v0, $s0, $zero # return value
  lw   $s0, 0($sp)     # restore $s0
  addi $sp, $sp, 4     # deallocate
  jr   $ra
```

> ⚠️ **Register convention:** `$t0–$t9` are *not preserved* (a callee may trash them);
> `$s0–$s7` are *preserved* (a callee must save them before use and restore before return).
