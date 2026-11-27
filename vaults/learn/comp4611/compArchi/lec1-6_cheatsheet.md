# COMP4611 Cheat Sheet — Timing, Performance, Forwarding, Tomasulo

> Covers Lectures 2 & 5 (Tutorials 1 & 2) plus Lecture 6 (Tomasulo).

---

## 1. Setup & Hold Time Requirements

### Timing parameter definitions

| Symbol | Meaning |
|---|---|
| `t_pd` | propagation delay (max) — latest output *finishes* changing |
| `t_cd` | contamination delay (min) — earliest output *starts* changing |
| `t_pcq` | clock-to-Q propagation (max) — latest Q after clock edge |
| `t_ccq` | clock-to-Q contamination (min) — earliest Q after clock edge |
| `t_setup` | D must be stable **before** the clock edge |
| `t_hold` | D must be stable **after** the clock edge |
| `T_c` | clock period |

### The two constraints (FF → logic → FF)

```
Setup:   T_c  ≥  t_pcq + t_pd + t_setup     (longest/critical path)
Hold:    t_ccq + t_cd  ≥  t_hold           (shortest path)
```

- **Setup** → minimum clock period → `f_max = 1 / T_min`
- **Hold is independent of T_c** — you *cannot* fix a hold violation by slowing the clock. Fix = add buffers to the short path (raise `t_cd`).

### Worked example (Tutorial 1)

Given: `t_ccq=30, t_pcq=50, t_setup=60, t_hold=70`, per-gate `t_pd=35, t_cd=25`, longest path = 3 gates.

```
t_pd = 3 × 35 = 105 ps      t_cd = 25 ps (shortest path = 1 gate)

Setup:  T_c ≥ 50 + 105 + 60 = 215 ps  →  f_max ≈ 4.65 GHz
Hold:   30 + 25 = 55 ps  ≥  70?  NO → HOLD FAILS
Fix:    add a buffer → t_cd = 2 × 25 = 50 → 30 + 50 = 80 ≥ 70 ✓ PASS
```

---

## 2. CPI & Time Formulas

### Core formulas

```
CPI  =  total cycles / instruction count

Time =  #instructions × CPI × clock period (T_c)

T_min       =  slowest stage delay + pipeline-register overhead
Latency     =  #stages × T_c
Average CPI ≈  1 + (stall cycles + mispredict cycles) / N

Misprediction penalty = # flushed instructions
```

### Worked example (Tutorial 2)

Instruction mix: 25% loads (40% of which cause a 1-cycle load-use stall), 11% branches (25% mispredicted, flush 2), 2% jumps (flush 1).

```
extra cycles = (0.25 × 0.40 × 1)   ← load-use stalls
             + (0.11 × 0.25 × 2)   ← branch mispredicts
             + (0.02 × 1)          ← jumps
             = 0.10 + 0.055 + 0.02
             = 0.175

Average CPI ≈ 1 + 0.175 = 1.175
```

**Early-branch-resolution trap:** resolving in ID lowers CPI but lengthens the cycle. Compare total time:

```
CPI 1.175 → 1.1475, but T_c ×1.05:
time ratio = (1.1475 × 1.05) / 1.175 = 1.0254  → 2.54% SLOWER
```

So lower CPI ≠ always faster — always check `CPI × T_c`.

---

## 3. Data Forwarding Rules

**Key timing facts:**

- ALU result ready at **end of EX**; load data ready at **end of MEM**; operands needed at **start of EX** (or MEM for a store's data).
- Register file: **write first half, read second half** of the cycle.

### The three paths

| Path | Source register | Destination | When used |
|---|---|---|---|
| **MEM → EX** | `EX/MEM` | consumer's EX input | producer is an ALU op **in MEM stage**, consumer needs it now in EX — the ALU→ALU case, **0 stalls** |
| **WB → EX** | `MEM/WB` | consumer's EX input | producer **in WB stage** (one instruction in between), or a **load** after 1 stall — **1 stall for load-use** |
| **WB → MEM** | `MEM/WB` | store's MEM data input | a `sw` needs its data in MEM, and the producer (often a **load**) is in WB |

*(Bonus: `EX/MEM → MEM` also exists — an ALU result forwarded to a store's data input one stage later.)*

### Matching conditions (forwarding-unit logic)

For a consumer's operand `Rs` (or `Rt`) in EX:

```
if EX/MEM.RegWrite  and  EX/MEM.Rd ≠ 0  and  EX/MEM.Rd == ID/EX.Rs:
        forward from EX/MEM            → MEM-to-EX path
elif MEM/WB.RegWrite and MEM/WB.Rd ≠ 0 and MEM/WB.Rd == ID/EX.Rs:
        forward from MEM/WB            → WB-to-EX path
```

For a store's data `Rt` in MEM:

```
if EX/MEM.Rd == ID/EX.Rt:  forward from EX/MEM   (ALU producer)
if MEM/WB.Rd == ID/EX.Rt:  forward from MEM/WB   (load producer)
```

**Priority rule:** if both `EX/MEM` and `MEM/WB` match, **`EX/MEM` wins** (it's the more recent value).

### Examples

```
ALU → ALU (0 stalls, MEM→EX):
add $t0,$t1,$t2   IF ID EX MEM WB
sub $t3,$t0,$t4      IF ID EX  MEM WB   ← forward in cycle 4

Load → use (1 stall, then WB→EX):
lw  $1,0($4)      IF ID EX  MEM WB
add $3,$1,$2         IF ID ID  EX MEM WB  ← stall, forward in cycle 5

Load → store (0 stalls, WB→MEM):
lw  $1,0($4)      IF ID EX MEM WB
sw  $1,0($5)         IF ID EX MEM WB      ← forward data in cycle 5
```

---

## 4. Tomasulo Pseudocode

```
Issue (in program order):
    r = a free reservation station of the right type
    RS[r].Op   = op
    RS[r].Busy = Yes

    RS[r].Qj = RegisterStat[fs]
    if RS[r].Qj == 0:  RS[r].Vj = Regs[fs]
    RS[r].Qk = RegisterStat[ft]
    if RS[r].Qk == 0:  RS[r].Vk = Regs[ft]

    RegisterStat[fd] = r          # LAST — after reading sources!

Execute (out of order):
    if RS[r].Qj == 0 and RS[r].Qk == 0 and unit free:
        start execution using Vj, Vk

Write Result (WB, out of order):
    broadcast (r, result) on the CDB

    for each busy station s:                     # RAW: deliver to waiters
        if RS[s].Qj == r:  RS[s].Vj = result;  RS[s].Qj = 0
        if RS[s].Qk == r:  RS[s].Vk = result;  RS[s].Qk = 0

    for each register f:                         # WAW: write only if youngest
        if RegisterStat[f] == r:
            Regs[f] = result
            RegisterStat[f] = 0

    RS[r].Busy = No
```

### Reminders

- `Q == 0` → value in `V` is ready; `Q == tag` → wait for that producer.
- Issue in order; Execute + WB out of order.
- `RegisterStat` holds only the **youngest** writer → WAW is automatic.
- Operands **captured at issue** → WAR is automatic.
- One **CDB broadcast per cycle**; one WB can feed many stations at once.
- At Issue: write `RegisterStat[fd]` **last** or you get a self-dependency deadlock.
