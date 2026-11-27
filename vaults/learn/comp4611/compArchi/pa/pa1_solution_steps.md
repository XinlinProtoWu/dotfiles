# COMP4611 PA1 — Pipeline Hazards: Solution Walkthrough

This document records, step by step, how the assignment was completed and explains
the reasoning behind each part of the implementation. The only file that was
edited is `comp4611_pipeline/src/hazards.c`.

---

## 0. What the assignment asks for

From `pa1.pdf` / `README.md`, we must implement four functions in `src/hazards.c`:

| Function | Role | Return value |
|---|---|---|
| `check_raw_hazard` | Data (RAW) hazard | extra **ID** stall cycles |
| `check_waw_hazard` | Write-after-write hazard | extra **ID** stall cycles |
| `check_wb_hazard` | Shared writeback-port collision | extra **ID** stall cycles |
| `check_control_hazard` | Branch IF stall | extra **IF** (fetch) stall cycles |

The simulator, parser, and `Scoreboard` bookkeeping are already provided in
`framework/`. We only derive the correct minimum stall count for each function.

### Shared timing model (from the handout)

- ID completes in cycle `c`.
- EX starts in `c + 1` and lasts `L` cycles, where `L` is the opcode's EX latency.
- MEM occupies one cycle, WB occupies one cycle.
- Therefore **WB cycle = c + L + 2**.

EX latencies:

| Op | L |
|---|---:|
| `ADD`, `SUB`, `ADDI`, `LW`, `SW`, `FADD`/`ADD.D`, `FSUB`/`SUB.D`, `FMUL`/`MUL.D`, `FDIV`/`DIV.D`, `FLD`/`L.D`, `FST`/`S.D`, `BEQ`, `BNE` | — |
| `ADD`, `SUB`, `ADDI`, `LW`, `SW`, `FLD`, `FST`, `BEQ`, `BNE` | 1 |
| `FADD`, `FSUB` | 4 |
| `FMUL` | 7 |
| `FDIV` | 24 |

The `Scoreboard` stores, for each register `r`:

- `writers[r].writer_op` — opcode of the latest scheduled writer.
- `writers[r].write_cycle` — that writer's WB cycle (`0` means "initial value ready").
- `wb_reserved[c]` — `true` if some earlier instruction is scheduled to WB in cycle `c`.

Register conventions:

- `-1` = no operand in that position (ignore).
- `0` = R0 (constant zero; reads/writes create no dependency).
- `1..31` = R1..R31, `32..63` = F0..F31. F0 is a **normal writable** register.

---

## 1. `check_raw_hazard` (data hazard)

### Goal

Return the minimum extra ID stall so that **both** source operands are available
at the point they are actually consumed:

- Ordinary operands (including branch operands) are needed at the start of the
  consumer's first EX cycle = `c + 1`.
- For `SW`/`FST`, `src1` is the **base** (needed in EX at `c + 1`) and `src2` is
  the **data** (needed in MEM at `c + L + 1 = c + 2`).

### Without forwarding

Sources are read from the register file in ID. WB writes before ID reads in the
same cycle, so a source with scheduled WB cycle `W` is available in ID cycle `c`
when `W <= c`. Hence the earliest usable ID cycle is simply `W` (or `cycle` if
already later).

### With forwarding (all three paths enabled)

- **MEM→EX**: an *arithmetic* producer in MEM supplies its EX result to a consumer
  beginning EX. Producer `mem_cycle = W - 1`; consumer EX = `c + 1`. Equality gives
  `c = W - 2`. (Loads cannot use this path — their result appears at end of MEM.)
- **WB→EX**: any producer in WB supplies its value (including loaded data) to a
  consumer beginning EX. `W = c + 1`, so `c = W - 1`.
- **WB→MEM**: a producer in WB supplies a store's data operand in MEM. Store MEM
  = `c + 2`, so `W = c + 2`, giving `c = W - 2`.

Therefore the earliest ID completion cycle for one source is:

| Source kind | Producer kind | Earliest ID cycle |
|---|---|---|
| ordinary EX operand | arithmetic (`ADD`, `FADD`, …) | `W - 2` |
| ordinary EX operand | load (`LW`, `FLD`) | `W - 1` |
| store data (`src2` of `SW`/`FST`) | either | `W - 2` |

Take the **maximum** (later) of the two source limits and return `limit - cycle`.

### Implementation

```c
static int source_limit(int cycle, int reg, bool is_store_data,
                        bool forwarding, const Scoreboard *state)
{
    if (reg <= 0) return cycle;               /* -1 absent, 0 = R0 */
    const RegisterWriter *w = &state->writers[reg];
    if (w->write_cycle == 0) return cycle;    /* initial value ready */

    int limit = w->write_cycle;               /* no forwarding: RF read at ID */
    if (forwarding) {
        if (is_store_data)      limit = w->write_cycle - 2;
        else if (is_load(w->writer_op)) limit = w->write_cycle - 1;
        else                    limit = w->write_cycle - 2;
    }
    return limit > cycle ? limit : cycle;
}

int check_raw_hazard(int cycle, Op inst, int src1, int src2, int dst,
                     bool forwarding, const Scoreboard *state)
{
    (void)dst;
    int earliest = source_limit(cycle, src1, false, forwarding, state);
    int second   = source_limit(cycle, src2, is_store(inst), forwarding, state);
    if (second > earliest) earliest = second;
    return earliest - cycle;
}
```

### Verification with the handout example

`ADD R1, R2, R3` then `ADD R4, R1, R5`, no forwarding. The first `ADD` records
`W = 5` for R1. The second `ADD` is checked at cycle 3 with `src1 = R1`:

- no forwarding → limit = `W = 5` → stall = `5 - 3 = 2`. ✅ (matches handout table)

---

## 2. `check_waw_hazard` (write-after-write)

### Goal

The destination must be written **strictly after** its previous writer. So the
new WB cycle must satisfy `c + L + 2 > W`, where `W = writers[dst].write_cycle`.

- If `dst <= 0` (R0 or no destination), return `0`.
- If `write_cycle == 0` (no prior writer), return `0`.

Solve the inequality:

```
c + L + 2 > W
c        > W - L - 2
c        >= W - L - 1     (integers)
```

Minimum stall = `(W - L - 1) - cycle` if positive, otherwise `0`.

### Implementation

```c
int check_waw_hazard(int cycle, Op inst, int src1, int src2, int dst,
                     bool forwarding, const Scoreboard *state)
{
    (void)src1; (void)src2; (void)forwarding;
    if (dst <= 0) return 0;
    const RegisterWriter *w = &state->writers[dst];
    if (w->write_cycle == 0) return 0;

    int needed = w->write_cycle - ex_latency(inst) - 1;
    return needed > cycle ? needed - cycle : 0;
}
```

Example (`04_waw.asm`): `MUL.D F0,...` (L=7, WB=11) followed by `ADD.D F0,...`
(L=4). The `ADD.D` reaches ID at cycle 3 with `W = 11`:

```
needed = 11 - 4 - 1 = 6   →  stall = 6 - 3 = 3   ✅ (three WAW stalls)
```

---

## 3. `check_wb_hazard` (writeback-port collision)

### Goal

Every instruction passes through the shared WB path. Find the first free WB slot
at or after the candidate WB cycle (`c + L + 2`), and return how many extra
cycles that costs. Only `state->wb_reserved` matters here.

### Implementation

```c
int check_wb_hazard(int cycle, Op inst, int src1, int src2, int dst,
                    bool forwarding, const Scoreboard *state)
{
    (void)src1; (void)src2; (void)dst; (void)forwarding;
    int wb = cycle + ex_latency(inst) + 2;
    int slot = wb;
    while (state->wb_reserved[slot]) ++slot;
    return slot - wb;
}
```

Example (`05_wb_collision.asm`): a `MUL.D` reserves WB 11, then later an
`ADD.D` (L=4) would reach WB at 11 as well, so it is delayed by one cycle.

---

## 4. `check_control_hazard` (branch fetch stall)

### Goal

A branch resolves at the **end of its EX** cycle. The branch EX latency is 1, so:

- branch ID completes at `branch_id_cycle`;
- branch EX starts at `branch_id_cycle + 1` and resolves at the end of it;
- the next instruction may be fetched from cycle `branch_id_cycle + 2`.

Return the number of IF stalls needed before the current fetch attempt
(`cycle`) is allowed:

```
stall = max(0, branch_id_cycle + 2 - cycle)
```

`branch_id_cycle == -1` means no branch is pending → `0`.

### Implementation

```c
int check_control_hazard(int cycle, int branch_id_cycle)
{
    if (branch_id_cycle < 0) return 0;
    int resume = branch_id_cycle + 2;
    return resume > cycle ? resume - cycle : 0;
}
```

Example from the handout: branch ID completes in cycle 2; next IF attempt at
cycle 2 → `check_control_hazard(2, 2) = 2` (fetch stalls in cycles 2–3, resumes
in cycle 4). ✅

---

## 5. Build and test results

Run from the project root `comp4611_pipeline/`:

```sh
make clean && make          # builds ./sim with -Wall -Wextra -Wpedantic -Werror
make score                  # per-function public stall-score percentage
make test                   # strict unit checks + public pipeline regressions
```

Observed output:

```
make score
raw: 100.00% | exact 76, over 0, under 0, invalid 0; ...
waw: 100.00% | exact 55, ...
wb: 100.00% | exact 58, ...
control: 100.00% | exact 27, ...
```

```
make test
raw: 42/42 passed
waw: 29/29 passed
wb: 32/32 passed
control: 18/18 passed
121/121 unit cases passed
...
32/32 passed   (pipeline regression tests)
```

All four functions achieve **100%** on the public stall-score metric, all
121 strict unit cases pass (including the "leave input records unchanged"
checks), and all 32 public program regressions pass.

---

## 6. Summary of the key formulas

Let `c` = candidate ID completion cycle passed to the function, `L` = EX latency,
`W` = recorded writer WB cycle.

| Check | Condition to satisfy | Stall returned |
|---|---|---|
| RAW (no fwd) | `c >= W` per source | `max(0, W - cycle)` (per source; take later) |
| RAW (fwd, EX operand, arithmetic producer) | `c >= W - 2` | `max(0, W - 2 - cycle)` |
| RAW (fwd, EX operand, load producer) | `c >= W - 1` | `max(0, W - 1 - cycle)` |
| RAW (fwd, store data) | `c >= W - 2` | `max(0, W - 2 - cycle)` |
| WAW | `c + L + 2 > W` | `max(0, W - L - 1 - cycle)` |
| WB collision | `wb_reserved[c+L+2] == false` | first free slot − `(c+L+2)` |
| Control | `cycle >= branch_id_cycle + 2` | `max(0, branch_id_cycle + 2 - cycle)` |

---

## 7. Notes for submission

- Only `src/hazards.c` is submitted.
- The opening comment of `hazards.c` must contain your **name** and **ITSC email**
  (currently placeholders `YOUR NAME` / `YOUR_EMAIL@connect.ust.hk` — replace them
  before submitting).
- `hazards.c` must not modify the `const Scoreboard *state`; the implementation
  above only reads it, which the strict checker verifies.
