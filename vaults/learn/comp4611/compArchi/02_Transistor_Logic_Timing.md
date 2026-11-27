# Topic 2 — Transistors, Logic, FSMs, and Timing

> Source: `COMP4611L2_2026F.pdf` (Lecture 2) + `COMP4611T1_2026F.pdf` (Tutorial 1, timing part)

## 1. From transistor to gate

- A **MOS transistor** is a voltage-controlled **switch**.
  - **nMOS:** gate = 1 → closed (conducts); gate = 0 → open.
  - **pMOS:** the opposite — gate = 0 → closed; gate = 1 → open.
- **CMOS = complementary MOS** (nMOS + pMOS used together).

### CMOS inverter (NOT gate)

![[COMP4611L2_2026F.pdf#page=10]]

*CMOS inverter structure: VDD → pMOS → Out Y → nMOS → GND (Lecture 2, p. 10; behaviour on
pp. 11–14).*

| A (input) | pMOS | nMOS | Y (output) |
|---|---|---|---|
| 0 | ON (pulls up) | OFF | 1 |
| 1 | OFF | ON (pulls down) | 0 |

- pMOS is good at **pulling up** (toward VDD); nMOS is good at **pulling down** (toward GND).
- Interpret 0V = logic 0, VDD = logic 1 → we get a Boolean NOT: `Y = Ā`.

> 💡 **Example:** the wall switch analogy. A switch makes/breaks a circuit so a lamp
> glows or not. A transistor does the same, but controlled by a *voltage* on the gate.

## 2. Combinational logic building blocks

**Combinational = memoryless**: output depends *only* on the current inputs.

| Block | Function | Simple example |
|---|---|---|
| **Decoder** | n inputs → 2ⁿ outputs; exactly one output = 1 | 2:4 decoder: input `01` → Y₁ = 1, others 0 |
| **Multiplexer (MUX)** | select one of N inputs by log₂N select bits | 2:1 MUX, S=0 → Y=A; S=1 → Y=B |
| **Full adder** | adds aᵢ+bᵢ+cᵢ → sum Sᵢ, carry cᵢ₊₁ | 1+1+1 = 3 → S=1, carry=1 |
| **ALU** | many arithmetic/logic ops, one at a time | add, sub, and, or, slt, sll… |
| **Tri-state buffer** | drives wire when enabled, else floats (Z) | bus sharing: only one driver ON at a time |

### Full adder truth table (1 column of binary addition)

| aᵢ | bᵢ | cᵢ | cᵢ₊₁ (MAJ) | Sᵢ (XOR) |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 | 0 |
| 1 | 1 | 1 | 1 | 1 |

- `S = a ⊕ b ⊕ c` (XOR of the three bits); `C_out = majority(a,b,c)`.
- A **ripple adder** chains N full adders; carry ripples right-to-left.

> 💡 **Example:** add 4-bit `1011 + 1001`:
> bit0: 1+1 → S=0, c=1; bit1: 1+0+1 → S=0, c=1; bit2: 0+0+1 → S=1, c=0; bit3: 1+1 → S=0, c=1.
> Result `10100` (with final carry-out).

## 3. Sequential logic and FSMs

**Sequential = has memory**: output depends on current **and past** inputs.

Storage hierarchy (fast→cheap):

- **Registers** (flip-flops): fast, expensive (tens of transistors/bit)
- **SRAM**: 6+ transistors/bit
- **DRAM**: 1 transistor + 1 capacitor/bit (needs refresh)
- **Flash / disk**: slow, non-volatile, very cheap

### The D flip-flop

- Inputs `CLK`, `D`; output `Q`.
- **On the rising edge of CLK, D is sampled and copied to Q; otherwise Q holds.**
- An *edge-triggered* state element: it captures data on the clock edge.
- A **register** = N parallel D flip-flops sharing one CLK.

### Finite State Machine (FSM) — 5 elements

1. Finite set of **states** (each is a snapshot of the system).
2. Finite set of **inputs**.
3. Finite set of **outputs**.
4. Explicit **state transition** specification.
5. Explicit **output** specification.

- **Synchronous** FSM: state changes only at clock edges.
- **Moore FSM**: outputs depend only on current state.
- **Mealy FSM**: outputs depend on current state **and** inputs.
- Implementation = **next-state logic** (combinational) + **state register** + **output logic** (combinational).

> 💡 **Example — combination lock** with passcode R13→L22→R3:
> states A (locked), B (R13 done), C (R13-L22 done), D (unlocked).
> Any wrong move returns to A. The lock *remembers* past turns — that is state.

## 4. Timing: how fast can a circuit run?

Real gates are **not instant**: outputs change some time after inputs change.

| Symbol | Name | Meaning |
|---|---|---|
| **t_cd** | contamination delay | *minimum* delay — earliest output *starts* changing |
| **t_pd** | propagation delay | *maximum* delay — latest output *finishes* changing |
| **t_ccq** | clock-to-Q contamination | earliest Q changes after clock edge |
| **t_pcq** | clock-to-Q propagation | latest Q settles after clock edge |
| **t_setup** | setup time | D must be stable *before* clock edge |
| **t_hold** | hold time | D must be stable *after* clock edge |
| **T_c** | clock period | length of one cycle |

### Critical path and shortest path

For a circuit, the **critical (longest) path** gives t_pd; the **shortest path** gives t_cd.

> 💡 **Example:** `Y = (A·B) + C`, where each AND has t_pd 2, OR has t_pd 2 (in arbitrary units).
> Longest path A→AND→AND→OR = 2+2+2 = **6**; shortest path C→OR = **2**.

### Sequential timing constraints (two flip-flops R1→R2 through logic)

```
  Setup:  T_c ≥ t_pcq + t_pd + t_setup     (longest path → max frequency)
  Hold:   t_ccq + t_cd ≥ t_hold            (shortest path → min logic delay)
```

- **Setup** determines the *minimum clock period* → `f_max = 1 / T_min`.
- **Hold does NOT depend on T_c** — you cannot fix a hold violation by slowing the clock!
  Fix = add delay/buffers to the *short* path (raise t_cd).

> 💡 **Worked example (Tutorial 1):** t_ccq=30, t_pcq=50, t_setup=60, t_hold=70,
> per-gate t_pd=35, t_cd=25. Longest path = 3 gates.
> - t_pd = 3×35 = 105 ps; t_cd = 25 ps.
> - Setup: T_c ≥ 50 + 105 + 60 = **215 ps** → f_max = 4.65 GHz.
> - Hold: 30 + 25 = 55 ps ≥ 70 ps? **No → hold FAIL.**
> - Fix: add buffers on the short path → t_cd = 2×25 = 50 ps → 30 + 50 = 80 ≥ 70 **PASS**
>   (and f_max is unchanged, because the *long* path was not touched).

### Good timing design principles

1. **Critical-path design** — minimize the maximum logic delay.
2. **Balanced design** — balance delays across different FF-to-FF paths (no bottleneck).
3. **Common-case design** — make the common case fast; don't let rare cases dominate.

## 5. Metastability (what happens if you violate setup/hold)

If D changes right at the clock edge, the flip-flop can enter **metastability**: Q hangs
between 0 and 1, then settles to an *unpredictable* value. → Always meet t_setup/t_hold.
