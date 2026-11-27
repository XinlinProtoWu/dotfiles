# COMP4611 Homework 1 — Solutions

Design and Analysis of Computer Architectures · Fall 2026

---

## Part A — Single Choice Questions (3 pts each)

| Question | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|----------|---|---|---|---|---|---|---|---|---|----|
| Answer   | C | C | D | B | C | A | B | B | A | D  |

### Explanations

**Q1 — C.** In the switch model of a CMOS inverter, the pMOS conducts (ON) when its gate is at logic 0 and the nMOS conducts (ON) when its gate is at logic 1. With the input held at 0: pMOS **ON**, nMOS **OFF**, so the output is pulled up to VDD → output = **1**.

**Q2 — C.** An enabled 2:4 decoder asserts exactly one active-high output per input combination: Y₁ corresponds to A1A0 = 01 and Y₂ to A1A0 = 10. OR-ing them gives Z = Y₁ + Y₂ = A1'A0 + A1A0' = **A1 XOR A0**.

**Q3 — D.** MUX 1 (select = A) outputs B when A = 0 and ¬B when A = 1, so M = A ⊕ B. MUX 2 (select = E) has constant 0 on input 0 and M on input 1, so Y = E · M = E · (A ⊕ B). Y = 1 requires E = 1 and A ≠ B, i.e. EAB = **101 and 110**.

**Q4 — B.** On a shared bus, **at most one output driver may be enabled** at any time; every other driver must be in the high-impedance state Z (an output in Z drives *nothing* — it does not drive 0). Two enabled drivers could drive opposite values and create a short (contention).

**Q5 — C.** Start in S0 and apply x = 1, 0, 1 at successive rising edges:
- Edge 1 (x = 1): S0 → S1
- Edge 2 (x = 0): S1 → S0
- Edge 3 (x = 1): S0 → S1

Final state **S1**, and the output for S1 is **y = 0**.

**Q6 — A.** A rising-edge-triggered D flip-flop only samples D at the rising edge. Since D = 1 meets setup and hold at the next rising edge, **Q stays 0 until that edge, then becomes 1 after the clock-to-Q delay**. Mid-cycle changes of D have no effect on Q.

**Q7 — B.** `lw $t0, 4($s0)` loads the word at byte address $s0 + 4 = 0x10010004, so $t0 = 9. `add $t1, $t0, $t0` gives $t1 = 18. A load does not modify memory, so the word at 0x10010004 is still **9** → **9, 18, 9**.

**Q8 — B.** Byte-addressable with 12-bit addresses: 2¹² = **4096 bytes** (option D describes bits/words, not the byte address space).

**Q9 — A.** 0xFFF8 has sign bit (bit 15) = 1, so sign extension replicates 1s into the upper 16 bits: **0xFFFFFFF8** (value −8).

**Q10 — D.** `lwc1 $f2, 8($s0)` is a raw **bit copy** of the 32-bit word at byte address $s0 + 8 into floating-point register $f2. The FPU later *interprets* those bits as a float; the load itself performs **no numeric conversion**.

---

## Question 11 — MIPS Program and Encoding (30 pts)

C code: `if (A[2] != b) { A[2] = A[2] + b; }  result = A[2];`  with base(A) in `$s0`, `b` in `$s1`, result in `$s2`.

### (a) Offsets [4 pts]

Both blanks are **8**:

```
lw $t0, 8($s0)        sw $t0, 8($s0)
```

**Why:** A is an array of 32-bit (4-byte) integers and memory is byte-addressable, so each element occupies 4 bytes. Element `A[i]` lives at byte address `base + 4·i`. For i = 2: byte offset = 2 × 4 = **8** — i.e. the array *index* must be scaled by the element size (4) to get the *byte* offset.

### (b) Trace [8 pts]

| Case | Executed instruction addresses in order | Final $s2 | Final A[2] |
|------|------------------------------------------|-----------|------------|
| I    | 0x00400020, 0x00400024, 0x00400028, 0x0040002C, 0x00400030 | **12** | **12** |
| II   | 0x00400020, 0x00400024, 0x00400030 | **7** | **7** |

**Case I** (A[2] = 5, b = 7): `lw` → $t0 = 5. `beq` compares 5 ≠ 7 → **not taken**, so execution falls through. `add` → $t0 = 12; `sw` → A[2] = 12; final `add` → $s2 = 12.

**Case II** (A[2] = 7, b = 7): `lw` → $t0 = 7. `beq` compares 7 = 7 → **taken**, so the next instruction executed is at the branch target `done` = 0x00400030, skipping the `add` and `sw`. $s2 = 7 and A[2] is unchanged (still 7). Note: whether or not the branch is taken, $s2 ends up equal to the final A[2] — which is exactly what the C code requires.

### (c) Encoding [10 pts]

**(i) `lw $t0, 8($s0)` at 0x00400020 — I-format** [4 pts]

| Field | opcode | rs | rt | immediate |
|-------|--------|----|----|-----------|
| Value (decimal) | 35 | 16 ($s0) | 8 ($t0) | 8 |
| Bits | 100011 | 10000 | 01000 | 0000 0000 0000 1000 |

Machine code: `1000 1110 0000 1000 0000 0000 0000 1000` = **0x8E080008**

**(ii) `add $t0, $t0, $s1` at 0x00400028 — R-format** [4 pts]

| Field | opcode | rs | rt | rd | shamt | funct |
|-------|--------|----|----|----|-------|-------|
| Value (decimal) | 0 | 8 ($t0) | 17 ($s1) | 8 ($t0) | 0 | 32 |
| Bits | 000000 | 01000 | 10001 | 01000 | 00000 | 100000 |

Machine code: `0000 0001 0001 0001 0100 0000 0010 0000` = **0x01114020**

**(iii) `beq $t0, $s1, done` immediate** [2 pts]

target = (PC + 4) + sign‑extend(imm) × 4, with PC = 0x00400024 and target = 0x00400030:

imm = (target − (PC + 4)) / 4 = (0x00400030 − 0x00400028) / 4 = 8 / 4 = **+2**

(Intuition: the branch skips exactly 2 instructions — the `add` and the `sw` — and the PC has already advanced past the `beq` itself when the offset is applied.)

### (d) Four-instruction version [4 pts]

```
lw   $s2, 8($s0)
beq  $s2, $s1, done
add  $s2, $s2, $s1
sw   $s2, 8($s0)
done:
```

The loaded value lives in $s2 from the start; if the branch is taken, $s2 already holds A[2]; otherwise it is updated and stored back. The final copy `add $s2, $t0, $zero` is no longer needed. $s0 and $s1 are never written.

### (e) Large offset [4 pts]

**(i)** A[8192] is at byte offset 8192 × 4 = **32768**. The 16-bit immediate of `lw` is **sign-extended**, so its range is −32768 … +32767. Since 32768 > 32767, the offset **cannot** be encoded — `lw $t0, 32768($s0)` is **not** possible as a single machine instruction.

**(ii)** Split the address computation so each immediate fits in 16 bits:

```
addi $t1, $s0, 32760      # $t1 = &A[8192] − 8  (32760 ≤ 32767, keeps word alignment)
lw   $t0, 8($t1)          # $t0 = Mem[$t1 + 8] = A[8192]
```

$s0 is preserved; only the temporary $t1 is modified.

---

## Question 12 — Timing of Two-Bit Adders (40 pts)

Gate delays: XOR = 50/20 ps (max/min), AND = 30/10 ps, OR = 40/15 ps.
Registers: t_pcq = 30, t_ccq = 15, t_setup = 30, t_hold = 30 ps; T_clk = 175 ps.

### (a) Figure 1 (ordinary adder) — output latencies [12 pts]

| Output | One maximum-delay path | Latency (ps) |
|--------|------------------------|--------------|
| S₀ | A₀ → XOR → S₀ | 1 × 50 = 50 |
| S₁ | A₁ → XOR → XOR → S₁ | 50 + 50 = **100** |
| C₂ | A₁ → XOR → AND → OR → C₂ | 50 + 30 + 40 = **120** |

**Key observation for S₁:** S₁ = (A₁ ⊕ B₁) ⊕ c₁. The path through the carry (A₀ → AND → XOR = 30 + 50 = 80 ps) is *not* the longest — the path through **two XOR gates** (A₁ or B₁ → XOR → XOR = 100 ps) is longer, because an XOR (50 ps) costs more than an AND (30 ps).

- **Critical path:** A₁ (or B₁) → XOR → AND → OR → C₂, with **t_pd = 120 ps**. (The propagate signal p₁ = A₁ ⊕ B₁ must be computed before it can be ANDed with the carry-in c₁, then ORed with the generate term A₁B₁.)
- **Shortest path:** A₀ (or B₀) → XOR → S₀ with minimum delays, **t_cd = 20 ps**.

### (b) Figure 1 — setup check [8 pts]

T_min = t_pcq + t_pd + t_setup = 30 + 120 + 30 = **180 ps**
f_max = 1000 / 180 = **5.556 GHz**

Current period T_clk = 175 ps < T_min = 180 ps → **setup FAIL**.
(The data launched at one edge can arrive at the capture register as late as 30 + 120 = 150 ps, but the register needs it stable by 175 − 30 = 145 ps — it misses by 5 ps.)

### (c) Figure 2 (optimized adder) — output latencies [12 pts]

The high-bit XOR in the **carry branch** is replaced by an OR (legal because when A₁ = B₁ = 1 the generate term A₁B₁ = 1 forces C₂ = 1 anyway, so the OR's "wrong" value of p₁ in that case is masked). The sum XORs are untouched.

| Output | One maximum-delay path | Latency (ps) |
|--------|------------------------|--------------|
| S₀ | A₀ → XOR → S₀ | 1 × 50 = **50** |
| S₁ | A₁ → XOR → XOR → S₁ | 50 + 50 = **100** |
| C₂ | A₁ → OR → AND → OR → C₂ | 40 + 30 + 40 = **110** |

(C₂ candidates: A₁ → OR → AND → OR = 110; A₀ → AND → AND → OR = 30+30+40 = 100; A₁ → AND → OR = 30+40 = 70. The OR path wins.)

- **Critical path:** A₁ (or B₁) → OR → AND → OR → C₂, with **t_pd = 110 ps**.
- T_min = t_pcq + t_pd + t_setup = 30 + 110 + 30 = **170 ps**
- f_max = 1000 / 170 = **5.882 GHz**
- T_clk = 175 ps ≥ 170 ps → **setup PASS**.

The swap saves 10 ps of t_pd (OR = 40 ps vs XOR = 50 ps), which is exactly enough to make the 175 ps clock legal.

### (d) Hold checks [8 pts]

**(i) Hold at t_hold = 30 ps.** [4 pts]

The shortest path in Figure 1 is A₀ → XOR → S₀, t_cd = 20 ps. In Figure 2 this path is **unchanged** (the change is only in the carry branch, whose shortest alternative — A₁ → AND → OR = 10 + 15 = 25 ps — is still longer than 20 ps). So **t_cd = 20 ps for both adders**.

Earliest arrival = t_ccq + t_cd = 15 + 20 = **35 ps**.

Hold check: 35 ps ≥ t_hold = 30 ps → **hold PASS for both adders**.

**Overall verdict at 175 ps:**
- Ordinary adder (Fig 1): setup FAIL, hold PASS → **overall FAIL**
- Optimized adder (Fig 2): setup PASS, hold PASS → **overall PASS**

**(ii) Hold raised to 40 ps.** [4 pts]

Earliest arrival is still 15 + 20 = 35 ps < t_hold = 40 ps → **hold FAIL for both adders**.

**Can increasing the clock period fix it? No.** The hold condition t_ccq + t_cd ≥ t_hold contains **no clock-period term**: the hold race is between the launching edge and the *same* edge at the capture register — newly launched data rushes through the shortest logic path and can overwrite the captured value too soon after the edge. Slowing the clock only changes when the *next* edge arrives, which is irrelevant to this race. The fix must increase the contamination delay (e.g. insert buffers / add delay on the short path) or use registers with larger t_ccq — not change T_clk. (Contrast with setup violations, which *can* be fixed by a longer period, since the setup inequality does contain T_clk.)
