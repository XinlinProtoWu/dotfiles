# Topic 6 — Pipeline with Multicycle Operations

> Source: `COMP4611L5_2026F.pdf` (Lecture 5, last part) + `COMP4611T3_2026F.pdf` (Tutorial 3)

## 1. Why multicycle execution units?

Integer ALU ops take 1 EX cycle, but **FP add / multiply / divide** take longer. Forcing them
into one cycle would force a slow clock. Solution: give each unit its own **longer, pipelined**
execution path.

```
ADD:  A1 A2 A3 A4          (4 EX cycles)
MUL:  M1 M2 M3 M4 M5 M6 M7 (7 EX cycles)
DIV:  24 cycles, NOT pipelined (one op at a time)
```

- **Execution latency** = cycles a unit takes to produce a result (4 for ADD, 7 for MUL).
- **Initiation interval** = cycles between starting two ops on the *same* unit.
  - Pipelined unit: interval = **1** (can start a new op every cycle).
  - Non-pipelined unit: interval = latency (e.g., 4, or 24 for DIV).

> 💡 **Example:** three independent multiplies, M1 starts cycle 1, 7-cycle pipelined multiplier:
> M2 starts cycle 2 → finishes end of cycle 8; M3 starts cycle 3 → finishes end of **cycle 9**.

## 2. New / more severe hazards

Because different operations take different-length paths, they can **collide at the end** of the
pipeline in ways the simple 5-stage pipeline never sees.

| Hazard | Cause | Fix |
|---|---|---|
| **Structural (write port)** | two FP results want WB in the same cycle but there is one FP write port | stall one instruction in ID |
| **WAW** | a short younger op writes a register before an older long op | stall the younger op so writes stay in program order |
| **Long RAW** | consumer waits many cycles for a slow producer | forward as soon as ready, but still stall until then |

> 💡 **Write-port conflict:** `mul.d $f0,…` (7 cycles) and `add.d $f6,…` (4 cycles) started 3
> cycles apart both reach WB in cycle 11 → stall the add 1 cycle so it writes in cycle 12.

> 💡 **WAW:** `mul.d $f0,…` (writes $f0 at cycle 11) then `add.d $f0,…` would write $f0 at
> cycle 9 — *wrong order*. Stall the add 3 cycles so its WB lands at cycle 12 (after the mul).
> Program order requires the *later* instruction's value to survive.

## 3. Timing rules used in the exercises (Tutorial 3)

- IF, ID, MEM, WB take 1 cycle each.
- A result is ready **after the final EX cycle**; MEM/WB can forward it to the **first EX stage**.
- Hazards are checked **in ID**; a stall also holds IF.
- **One FP register-file write port** → at most one FP write per cycle.
- Writes to the same register must follow **program order**.

## 4. Worked example — full multicycle trace

```
I1: mul.d $f0, $f2, $f4
I2: add.d $f0, $f6, $f8
I3: mul.d $f10,$f12,$f14
I4: add.d $f16,$f0, $f18
I5: add.d $f20,$f16,$f10
```

Trace (ADD = A1–A4, MUL = M1–M7, each column = one cycle):

![[COMP4611T3_2026F.pdf#page=21]]

*Completed trace, Tutorial 3, p. 21 — the step-by-step build-up is on pp. 16–22.*

Why each instruction waited:

- **I2** stalls cycles 4–6: **WAW** — it writes `$f0` and must wait until I1 writes `$f0` in
  cycle 11, so I2's WB moves to cycle 12.
- **I3** holds in IF because I2 holds in ID (in-order stall).
- **I4** stalls 9–10 (RAW on `$f0`, waiting for I2's result) and cycle 11 (avoid I3's WB slot —
  write-port structural hazard).
- **I5** stalls 13–15 (RAW on `$f10` and `$f16`; `$f16` is the later of the two).

## 5. Key insight → out-of-order execution

In an in-order pipeline, a stalled instruction in ID **blocks** later *independent* instructions
even if a unit is free.

Fix: **split ID** into *issue* + an **instruction buffer**:

```
IF → Issue (decode, in order) → Instruction buffer (wait for operands) → EX (when ready)
```

Now an independent instruction (e.g., `sub`) can begin execution *before* an earlier dependent
one (e.g., `add` waiting on a slow `div`). Instructions **issue in order, execute out of order** —
the first step toward **Tomasulo's algorithm** (next lecture).

> 💡 **Example:** `div.d $f0,…` (24 cycles), `add.d $f10,$f0,…` (waits), `sub.d $f12,…`
> (independent). In-order: sub is stuck behind add. Out-of-order: sub uses the free FP adder
> while add waits in the buffer.
