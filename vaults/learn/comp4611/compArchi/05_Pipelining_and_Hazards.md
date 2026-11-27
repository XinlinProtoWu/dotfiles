# Topic 5 — Pipelining, Hazards, and Performance

> Source: `COMP4611L5_2026F.pdf` (Lecture 5) + `COMP4611T2_2026F.pdf` (Tutorial 2)

## 1. The idea of pipelining

> **Laundry analogy:** washing/drying/folding 4 loads. Doing them one at a time = 120 min/load.
> Overlapping stages (one load washes while the previous dries) = **4× throughput**, same latency
> per load, no extra machines.

- **Latency** of one instruction = time through all stages (unchanged).
- **Throughput** = instructions per unit time (improved, up to 1 per cycle in steady state).
- Split the single-cycle datapath into 5 stages, insert **pipeline registers** between stages.

## 2. Five-stage pipeline (MIPS)

```
IF → ID → EX → MEM → WB
```

- Each stage = 1 cycle. In steady state (no stalls), **CPI ≈ 1**.
- Latency = 5 cycles; throughput = 1 instruction/cycle.

> 💡 **Pipeline diagram:**
>
> ![[COMP4611L5_2026F.pdf#page=8]]
>
> At t3, three instructions are in flight simultaneously (Lecture 5, p. 8).

### Performance formulas

```
CPI = total cycles / instruction count
Time = #instructions × CPI × clock period
```

- **Minimum clock period** = slowest stage delay (+ pipeline-register overhead).
- **Instruction latency** = stages × clock period.

> 💡 **Example:** stages 200/150/180/160/190 ps + 20 ps overhead:
> clock period = 200 + 20 = **220 ps**; latency = 5 × 220 = **1100 ps**.

## 3. Hazards

A **hazard** stops an instruction from executing in its designated cycle. Three kinds:

1. **Structural** — two instructions need the same resource.
2. **Data** — reads/writes happen in the wrong order.
3. **Control** — next PC not yet known (branches/jumps).

### 3a. Structural hazards

- Example: one memory for instructions AND data → IF and MEM contend.
  Fix: **separate instruction/data memories (caches)**, or stall one stage.
- Register file: **write in first half-cycle, read in second half** → a WB write and an ID read
  can share the same cycle with no conflict (write-then-read register file).

### 3b. Data hazards — the three dependence types

| Name | Pattern | Meaning |
|---|---|---|
| **RAW** (flow) | W then R | true dependence; must preserve |
| **WAR** (anti) | R then W | read must happen before later write |
| **WAW** (output) | W then W | later write must win |

In the simple in-order 5-stage pipeline (read in ID, write in WB, in program order),
**WAR and WAW do NOT occur** — only RAW needs handling.

> 💡 **Example:**
> ```
> I1: add $t0, $t1, $t2   # writes $t0
> I2: sub $t1, $t0, $t3   # reads $t0  → RAW on $t0 (I1→I2)
> I3: add $t0, $t4, $t5   # writes $t0 → WAW on $t0 (I1→I3), no hazard here
> ```
> The hazard-causing dependence is the **RAW from I1 to I2 on `$t0`**.

### Handling RAW — stalling (no forwarding)

Keep the consumer in **ID** until the producer writes the register file in **WB**; hold the
following instruction in **IF** and insert a bubble in EX.

> 💡 **Example:**
> ```
> I1: add $t0, $t1, $t2   IF ID EX MEM WB
> I2: sub $t3, $t0, $t4      IF ID ID ID  EX MEM WB   ← 2 stalls
> I3: (next)                    IF IF IF  ID EX MEM WB ← held in IF
> ```
> I2 reads `$t0` in ID during the *same cycle* I1 writes it in WB (write-first-then-read).

### Handling RAW — forwarding (bypassing)

Send the result to the consumer's ALU input **as soon as it exists**, before WB:

- **MEM-to-EX**: forward the ALU result in `EX/MEM` to the next instruction's EX.
- **WB-to-EX**: forward the result in `MEM/WB` to EX.

> 💡 **Example (ALU→ALU, no stall):**
> ```
> I1: add $t0, $t1, $t2   IF ID EX MEM WB
> I2: sub $t3, $t0, $t4      IF ID EX  MEM WB   ← MEM-to-EX forwards $t0 in cycle 4
> ```

### The load-use stall (forwarding cannot always help)

A **load** produces its data only at the **end of MEM**, so it cannot feed the next instruction's
EX directly → one unavoidable stall, then **WB-to-EX** forwards.

> 💡 **Example:**
> ```
> lw $1, 0($4)     IF ID EX  MEM WB
> add $3, $1, $2      IF ID ID   EX MEM WB   ← 1 load-use stall; WB-to-EX in cycle 5
> ```

## 4. Control hazards

- Branch outcome/target unknown until resolved (EX by default).
- **"Predict not taken"** = keep fetching sequentially; if taken, **flush** the wrong-path
  instructions (turn them into bubbles).
- **Misprediction penalty** = number of flushed instructions = # cycles lost.

> 💡 **Example (resolve in EX):** branch in IF(1) ID(2) EX(3); two following instructions are in
> ID and IF when the branch is resolved at end of cycle 3 → **2-cycle penalty**, both flushed,
> target fetched in cycle 4.

### Early branch resolution (resolve in ID)

Move compare + target add into ID → only **1** instruction flushed → penalty drops 2→1.
Trade-off: longer ID stage → possibly longer clock period (could make things *slower* overall).

## 5. Performance analysis with hazards (Tutorial 2)

```
Average CPI ≈ 1 + (total stall/mispredict cycles) / N
```

> 💡 **Example:** 25% loads (40% cause 1-cycle load-use stall), 11% branches (25% mispredicted,
> flush 2), 2% jumps (flush 1):
> extra cycles = 0.25·0.40·1 + 0.11·0.25·2 + 0.02·1 = 0.10 + 0.055 + 0.02 = 0.175
> → **CPI ≈ 1.175**.

### Early resolution may NOT always win

Resolving in ID reduces CPI but lengthens the cycle. Compare **total time = CPI × period**:

> 💡 **Example:** CPI 1.175→1.1475 but period ×1.05:
> time ratio = (1.1475 × 1.05) / 1.175 = **1.0254** → 2.54% *slower*. Not worth it here.

## 6. Cheat-sheet: reading/writing a pipeline trace

1. Start each instruction in **IF** as early as possible (in-order).
2. A stall holds the waiting instruction in **ID** and the following one in **IF**; older
   instructions keep moving; a **bubble** enters EX.
3. Register file: **write first half, read second half** → ID can read a WB written the *same* cycle.
4. ALU result ready at end of **EX**; load data ready at end of **MEM**; operands needed at **start of EX**.
5. Forwarding: MEM-to-EX and WB-to-EX; if both match, **MEM has priority** (more recent).
