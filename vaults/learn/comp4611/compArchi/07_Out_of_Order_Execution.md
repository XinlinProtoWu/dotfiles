# Topic 7 — Out-of-Order Execution

> Source: `COMP4611L6_2026F.pdf` (Lecture 6) + `COMP4611T4_2026F.pdf` (Tutorial 4, Tomasulo example)

## 1. Why out-of-order execution?

In an in-order pipeline (Topic 6), when an instruction stalls in **ID**, it *also* holds up every
later instruction — even ones whose operands are ready and whose unit is free. That wastes cycles.

> 💡 **Example:**
> ```
> div.d $f0, $f2, $f4     # 24-cycle DIV, slow producer
> add.d $f10,$f0, $f8     # waits for $f0 (RAW)
> sub.d $f12,$f8, $f14    # independent! operands ready, adder free
> ```
> In-order: `add` sits in ID waiting for `div`; `sub` sits behind it in IF. The FP adder is **idle**
> for many cycles.
> **Idea:** let `sub` start *before* `add* — it does not depend on `div`.

The fix is to **split ID into two steps**:

```
IF → Issue (decode, in program order) → Instruction buffer (wait for operands) → EX (when ready)
```

Instructions **issue in order** but may **execute out of order**. The hardware still respects data
dependences, so the program result is unchanged.

> 💡 **Example (same program, out of order):**
> ```
> div.d $f0,…   IF IS  DIV………………
> add.d $f10,…     IF IS  wait wait …   ← waits in buffer for $f0
> sub.d $f12,…        IF IS  A1 A2 A3 A4 MEM WB   ← runs before add!
> ```
> The `sub` uses the otherwise-idle adder while `add` waits.

**Motivation:** tolerate long-latency operations (DIV/MUL) by letting *independent* instructions
make progress.

## 2. Data dependences — true vs name

| Type             | Pattern  | Meaning                                       | Kind                |
| ---------------- | -------- | --------------------------------------------- | ------------------- |
| **RAW** (flow)   | W then R | consumer needs producer's value               | **true** dependence |
| **WAR** (anti)   | R then W | earlier instr reads before later instr writes | **name** dependence |
| **WAW** (output) | W then W | later write must survive                      | **name** dependence |

- **RAW** is a *true* dependence — the data really flows from one instruction to another. It can
  only be handled with forwarding and (when needed) stalls.
- **WAR / WAW** are *name* dependences — they exist only because two instructions **reuse the same
  register name** for different values. They can be removed by giving each value a fresh name.

### Why WAR appears only with out-of-order execution

In the simple in-order 5-stage pipeline, reads (ID) and writes (WB) stay in program order, so WAR
and WAW can't happen. But with **multicycle units + out-of-order start**, a later write can finish
*before* an earlier read.

> 💡 **WAR example:**
> ```
> div.d $f0, $f2, $f4    # produces 4 (slow)
> mul.d $f6, $f0, $f8    # reads $f8 (old value = 10) + $f0
> add.d $f8, $f10,$f14   # writes $f8 = 12 (fast, runs first)
> ```
> `mul` is supposed to read the *old* `$f8` = 10, but `add` writes 12 first → `mul` computes
> `4 × 12 = 48` instead of `4 × 10 = 40`. ❌

## 3. Register renaming — remove WAR/WAW

Give each *value* its own name using spare physical registers (in hardware, or conceptually).

> 💡 **WAR fixed by renaming:**
> ```
> Original                        After renaming
> div.d $f0, $f2, $f4             div.d $f0,     $f2, $f4
> mul.d $f6, $f0, $f8             mul.d $f6, $f0, $f8.old   ← reads renamed copy
> add.d $f8, $f10,$f14            add.d $f8, $f10,$f14      ← writes real $f8
> ```
> Now `add` writes `$f8` while `mul` reads `$f8.old` — no conflict. `mul` still gets 10. ✅

> 💡 **WAW fixed by renaming:**
> ```
> div.d $f8, $f2, $f4             div.d $f8.old, $f2, $f4   # slow, writes renamed copy
> add.d $f8, $f10,$f14            add.d $f8,     $f10,$f14  # fast, writes real $f8
> ```
> `add` writes `$f8` first; the later-finishing `div` writes `$f8.old` and can't overwrite `add`'s
> result. Program order says `add`'s value must survive. ✅

**Key idea:** RAW is a true dependence — keep it (via operand tracking). WAR/WAW are just name
collisions — break them by renaming.

## 4. Tomasulo's algorithm — dynamic scheduling + renaming in hardware

Invented by Robert Tomasulo for the **IBM 360/91** FP unit (1967). Combines:

1. **Track operand availability** → preserve true (RAW) dependences.
2. **Rename in hardware** → eliminate WAR/WAW.

### The three pieces of hardware

![[COMP4611L6_2026F.pdf#page=18]]

*Tomasulo organization (Lecture 6, p. 18).*

- **Reservation stations (RS):** instruction buffers near each unit. Each holds one waiting
  instruction and its operand info.
- **RegisterStat (register status table):** for each register, records the **tag** (RS ID) of the
  pending instruction that will write it. `0` = register file holds the current value.
- **Common Data Bus (CDB):** one bus that broadcasts `(tag, value)` of every completed result to
  all RS entries and the register file. One broadcast per cycle.

### Reservation station fields

| Field | Meaning |
|---|---|
| `Busy` | is this station occupied? |
| `Op` | the operation (e.g., ADD, MUL) |
| `Vj`, `Vk` | source values, if ready |
| `Qj`, `Qk` | producer's tag (RS ID) for a not-yet-ready source; `0` = ready |

> 💡 **Reading the table:**
> ```
> Name   Busy  Op    Vj    Vk    Qj      Qk
> Mult2  Yes   MUL   —     10    Mult1   0
> ```
> MUL's second operand `$f8` = 10 is ready (`Vk=10, Qk=0`). Its first operand is still being
> produced by the instruction in station **Mult1** (`Qj=Mult1`), so `Vj` is empty.

### The four stages

| Stage | When | What happens |
|---|---|---|
| **IF** | in program order | fetch next instruction |
| **Issue** | in program order | decode; wait for a free RS; capture source values (or tags); record own tag in `RegisterStat[dest]` |
| **Execute** | out of order | start when `Qj==0` and `Qk==0` and a unit is free |
| **Write Result (WB)** | out of order | broadcast `(tag, value)` on CDB; release the RS |

> ⚠️ **Order matters inside Issue:** read `RegisterStat[fs]/[ft]` **before** overwriting
> `RegisterStat[fd]`. Reversing the two makes an instruction depend on itself → permanent wait
> (see §6.1).

### How the CDB delivers a result

When a result `(tag, value)` is broadcast:

- **To RS entries:** every busy RS compares its `Qj`/`Qk` against `tag`. On a match, copy `value`
  into `Vj`/`Vk` and clear that `Q` to 0.
- **To the register file:** compare `tag` against `RegisterStat[dest]`. On a **match**, write the
  register and clear its entry to 0. On **no match**, leave the register alone.

> 💡 **RAW handled:** I2's `Qj=Mult1`; when `(Mult1, 4)` arrives, I2 gets `Vj=4, Qj=0` — its
> operand is now ready.
> 💡 **WAW handled:** `RegisterStat[$f0]=Add1` (the *younger* `add`), so when the older `(Mult1,4)`
> arrives, it **does not match** → `$f0` keeps the `add`'s value. The later write wins. ✅

## 5. Worked example 1 — two writers to `$f0` (Lecture 6)

Program and initial values:

```
I1: mul.d $f0, $f2, $f4      $f0=0  $f2=2  $f4=3  $f6=0  $f8=10
I2: mul.d $f6, $f0, $f8
I3: add.d $f0, $f2, $f4
I4: add.d $f8, $f2, $f4
```

Hardware: 2-stage ADD (`A1–A2`), 3-stage MUL (`M1–M3`), 3 ADD stations + 2 MUL stations. Issue and
CDB each handle one item per cycle.

- **Cyc 1:** I1 fetched.
- **Cyc 2:** I1 **issues** into `Mult1` with ready operands (`Vj=2, Vk=3`); `RegisterStat[$f0]=Mult1`.
- **Cyc 3:** I2 issues into `Mult2`: `$f0` not ready → `Qj=Mult1`; `$f8` ready → `Vk=10`.
  `RegisterStat[$f6]=Mult2`. I1 starts `M1`.
- **Cyc 4:** I3 issues into `Add1` (ready `Vj=2, Vk=3`); I3 is now the latest writer →
  `RegisterStat[$f0]=Add1` (replaces `Mult1`). I2 waits.
- **Cyc 5:** I3 starts `A1` (out of order, before I2!). I4 issues into `Add2`;
  `RegisterStat[$f8]=Add2`.
- **Cyc 6:** I1 broadcasts `(Mult1, 6)` on CDB → I2's `Qj` matches → `Vj=6, Qj=0`. Register file:
  `RegisterStat[$f0]=Add1 ≠ Mult1` → `$f0` **not** written (WAW avoided!). I3 in `A2`.
- **Cyc 7:** I2 starts `M1` with saved operands 6 and 10. I3 broadcasts `(Add1, 5)` → matches
  `RegisterStat[$f0]` → write `$f0=5`, clear entry. I4 in `A2`.
- **Cyc 8:** I4 broadcasts `(Add2, 5)` → write `$f8=5`. I2 keeps its *saved* `Vk=10` (WAR avoided!).
- **Cyc 9:** I2 finishes `M3`, waits for CDB.
- **Cyc 10:** I2 broadcasts `(Mult2, 60)` → write `$f6=60`. Done.

Final registers: `$f0=5, $f8=5, $f6=60` — exactly the in-order program result. ✅

> 💡 **What each hazard became:**
> - **RAW** I1→I2: handled by tag matching (`Qj=Mult1` → receive 6).
> - **WAW** I1 vs I3 on `$f0`: I3's tag in `RegisterStat` wins; I1's late write is ignored.
> - **WAR** I2 vs I4 on `$f8`: I2 captured `$f8=10` at issue; I4's later write of 5 does not disturb
>   it.

## 6. Worked example 2 — three writers to one register (Tutorial 4)

Same hardware, but the program reuses `$f10` three times, so a **WAW chain** and two **WAR**
collisions land in one trace.

```
I1: mul.d $f10, $f2,  $f4      $f2 = 3,  $f4 = 4,  $f8 = 10,  $f6 = $f10 = 0
I2: mul.d $f10, $f10, $f4
I3: add.d $f6,  $f10, $f8
I4: add.d $f10, $f2,  $f4
I5: add.d $f8,  $f2,  $f4
```

| Resource | Configuration |
|---|---|
| ADD pipeline | `A1–A2`, one new instruction per cycle |
| MUL pipeline | `M1–M3`, one new instruction per cycle |
| Reservation stations | `Add1–Add3`, `Mult1–Mult2` |
| IF / Issue | one instruction each per cycle |
| CDB | one `(tag, value)` broadcast per cycle |

Rules in force: issue in program order; EX starts as soon as operands are ready *and* the unit
accepts; **new operands and released RS entries are usable in the next cycle**; WB writes a register
only on a `RegisterStat` tag match.

Program-order (sequential) values: I1 → `$f10 = 12`, I2 → `$f10 = 48`, I3 → `$f6 = 48 + 10 = 58`,
I4 → `$f10 = 7`, I5 → `$f8 = 7`. **I3 must see I2's 48**, not I4's later 7 — that is the whole
point of the exercise.

### 6.1 The trap at Issue: read `RegisterStat` before you overwrite it

At the issue of I2, `RegisterStat[$f10] = Mult1` and the free station is `Mult2`.

![[COMP4611T4_2026F.pdf#page=10]]

| Update order | First | Second | I2 ends up waiting for |
|---|---|---|---|
| **correct** | `Mult2.Qj ← Mult1` | `RegisterStat[$f10] ← Mult2` | I1 (`Mult1`) ✅ |
| reversed | `RegisterStat[$f10] ← Mult2` | `Mult2.Qj ← Mult2` | **itself** ❌ |

> ⚠️ With the reversed order I2 needs its own result before it can start EX → it waits forever.
> So `RegisterStat[fd]` is the **last** field written at Issue, after every `Qj/Qk/Vj/Vk` has been
> read from the *old* table.

### 6.2 Cycle-by-cycle trace

![[COMP4611T4_2026F.pdf#page=20]]

| Instruction / cycle | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| I1 | IF | Issue | M1 | M2 | M3 | WB | | | | | | | |
| I2 | | IF | Issue | Wait | Wait | Wait | M1 | M2 | M3 | WB | | | |
| I3 | | | IF | Issue | Wait | Wait | Wait | Wait | Wait | Wait | A1 | A2 | WB |
| I4 | | | | IF | Issue | A1 | A2 | WB | | | | | |
| I5 | | | | | IF | Issue | A1 | A2 | WB | | | | |

**End of cycle 6** (I1 has broadcast, I5 has just issued):

| RS | Inst | Busy | Op | Vj | Vk | Qj | Qk |
|---|---|---|---|---|---|---|---|
| Mult1 | – | No | – | – | – | – | – |
| Mult2 | I2 | Yes | MUL | 12 | 4 | 0 | 0 |
| Add1 | I3 | Yes | ADD | – | 10 | Mult2 | 0 |
| Add2 | I4 | Yes | ADD | 3 | 4 | 0 | 0 |
| Add3 | I5 | Yes | ADD | 3 | 4 | 0 | 0 |

Regs `$f2=3  $f4=4  $f6=0  $f8=10  $f10=0` · `RegisterStat = 0, 0, Add1, Add3, Add2`

**End of cycle 10** (12, 7, 7 and 48 have all been delivered):

| RS | Inst | Busy | Op | Vj | Vk | Qj | Qk |
|---|---|---|---|---|---|---|---|
| Mult1 | – | No | – | – | – | – | – |
| Mult2 | – | No | – | – | – | – | – |
| Add1 | I3 | Yes | ADD | 48 | 10 | 0 | 0 |
| Add2 | – | No | – | – | – | – | – |
| Add3 | – | No | – | – | – | – | – |

Regs `$f2=3  $f4=4  $f6=0  $f8=7  $f10=7` · `RegisterStat = 0, 0, Add1, 0, 0`

End of cycle 13: `$f6 = 58, $f8 = 7, $f10 = 7`, all stations free and all `RegisterStat` 0.

What happens, cycle by cycle:

- **Cyc 2 — I1 issues → `Mult1`** with ready operands (`Vj=3, Vk=4`); `RegisterStat[$f10] = Mult1`.
- **Cyc 3 — I2 issues → `Mult2`**: its first source `$f10` is still tagged `Mult1` → `Qj = Mult1`,
  `Vk = 4`; *then* `RegisterStat[$f10] = Mult2`. I1 starts `M1`.
- **Cyc 4 — I3 issues → `Add1`**: `$f10` is now tagged `Mult2` (I2, *not* I1) → `Qj = Mult2`;
  `$f8 = 10` → `Vk = 10, Qk = 0`. `RegisterStat[$f6] = Add1`.
- **Cyc 5 — I4 issues → `Add2`** with everything ready, and `RegisterStat[$f10] = Add2`.
  Now **three writers of `$f10` are live** (`Mult1`, `Mult2`, `Add2`), yet only the youngest
  (`Add2`) is in the status table — the older tags survive only inside `Qj` fields.
- **Cyc 6 —** I1 WB: broadcast `(Mult1, 12)` → `Mult2.Vj = 12, Qj = 0`. Since
  `RegisterStat[$f10] = Add2 ≠ Mult1` → **`$f10` is not written** (WAW). `Mult1` freed. In the
  *same* cycle **I4 starts `A1`** — before I2 and I3, which issued earlier — and I5 issues into
  `Add3` (`Vj=3, Vk=4`), `RegisterStat[$f8] = Add3`.
- **Cyc 7–8 —** I2 runs `M1, M2`; I4 runs `A2` then **WB at 8**: `(Add2, 7)` matches
  `RegisterStat[$f10]` → write `$f10 = 7`, clear the entry. I5 starts `A1` at 7.
- **Cyc 9 —** I5 WB: `(Add3, 7)` → `$f8 = 7`. `Add1` still holds its **saved** `Vk = 10` (WAR
  avoided: I3 keeps the *old* `$f8`, not 7).
- **Cyc 10 —** I2 WB: `(Mult2, 48)` → `Add1.Qj` matches, so `Vj = 48, Qj = 0`.
  `RegisterStat[$f10] = 0 ≠ Mult2` → **`$f10` stays 7** (WAW). `Mult2` freed; `Add1` is the only
  busy station and now has both operands.
- **Cyc 11–13 —** I3 runs `A1, A2` with `48 + 10 = 58` (re-reading `$f8` now would give `48 + 7 = 55`
  ❌ — captured operands are never refreshed), then WB `(Add1, 58)` → `$f6 = 58`.

### 6.3 What each dependence became

| Dependence | Instances here | Mechanism |
|---|---|---|
| **RAW** (true) | I1→I2 on `$f10` (12); I2→I3 on `$f10` (48) | `Qj/Qk` tag match on the CDB |
| **WAW** (name) | I1, I2 and I4 all write `$f10` | `RegisterStat[$f10]` holds the *youngest* tag (`Add2`); the older broadcasts 12 and 48 don't match → dropped |
| **WAR** (name) | I2/I3 read old `$f10` while I4 writes it; I5 reads old `$f8` while I4 writes it | operands captured into `Vj/Vk` at issue → later writes can't perturb them |

- Completion order is **I4 (8) → I5 (9) → I2 (10) → I3 (13)** — nothing like program order, yet the
  final state matches the sequential program.
- `$f6 = 58` works *only* because I3 latched the `Mult2` tag back in cycle 4, long before I4
  overwrote `$f10`.

### 6.4 The same program on an in-order pipeline (contrast)

![[COMP4611T4_2026F.pdf#page=27]]

- **Pipeline:** EX starts in program order `I1 → I2 → I3 → I4 → I5`; I4 is ready at cycle 6 but must
  sit in IF until I3 leaves ID (cycle 9), starting `A1` only in cycle 10. Head-of-line blocking.
- **Tomasulo:** EX order `I1 → I4 → {I2, I5} → I3`; I4 starts `A1` in cycle 6, I5 in cycle 7.
- End state is identical; Tomasulo just gets there with less waiting (last WB at cycle 13 vs 14).

## 7. Pseudocode (core of Tomasulo)

```
Issue (in program order):
  r = a free RS of the right type
  RS[r].Op = op;  RS[r].Busy = Yes
  RS[r].Qj = RegisterStat[fs]
  if RS[r].Qj == 0: RS[r].Vj = Regs[fs]
  RS[r].Qk = RegisterStat[ft]
  if RS[r].Qk == 0: RS[r].Vk = Regs[ft]
  RegisterStat[fd] = r

Execute (out of order):
  if Qj == 0 and Qk == 0 and unit available:
      start execution with Vj, Vk

Write Result (WB):
  broadcast (r, result)
  for each busy RS s:
      if RS[s].Qj == r: RS[s].Vj = result; RS[s].Qj = 0
      if RS[s].Qk == r: RS[s].Vk = result; RS[s].Qk = 0
  for each register f:
      if RegisterStat[f] == r: Regs[f] = result; RegisterStat[f] = 0
  RS[r].Busy = No   # release the station
```

## 8. Memory dependences (why they're hard)

Out-of-order **loads/stores** are much harder than register dependences:

- Register names are visible in the instruction; **memory addresses are computed at runtime**.
- Memory has far more locations than registers.
- Memory can be shared across threads/processors.

Consequences:

1. **Renaming memory addresses is difficult.**
2. Dependence vs independence of loads/stores can only be decided **after** their addresses are
   known (i.e., after partial execution).
3. When one load/store has its address, there may be older/younger accesses with **unknown**
   addresses still in flight.

> 💡 **Idea:** `lw $1, 0($2)` and `sw $3, 0($4)` — are they to the same address? You can't tell
> until `$2` and `$4` are computed. In-order execution sidesteps this by accessing memory in program
> order; out-of-order machines need load/store queues and disambiguation logic (beyond scope of this
> course — see textbook §3.5, §3.9 for memory ordering and aliasing prediction).

## 9. Trade-offs of out-of-order execution

| Pros | Cons |
|---|---|
| **Latency tolerance:** independent instructions run during long operations | **More complexity** → possibly longer critical path → slower clock |
| **Irregular parallelism:** dynamically finds parallelism that static compilers can't easily exploit in irregular code | **More hardware** (RS, tags, CDB, rename tables) |

Remember: total program time = **#instructions × CPI × clock cycle time**. OoO lowers CPI but can
raise clock cycle time — the net effect must be positive.

## 10. Cheat-sheet

1. **RAW** = true dependence (keep it, via operand tags). **WAR/WAW** = name dependences (kill them
   by renaming).
2. Issue = in program order; Execute + WB = out of order.
3. `Q` field = tag of the pending producer; `0` means the value `V` is ready.
4. WB writes a register **only if** the broadcast tag matches `RegisterStat[dest]` → enforces the
   later-write-wins rule (WAW).
5. Source operands are **captured at issue** → a later write can't change them (WAR).
6. The CDB is one result per cycle; results can feed **several** waiting stations at once.
7. At Issue, fill `Qj/Qk/Vj/Vk` from `RegisterStat` **first**, write `RegisterStat[fd]` **last** —
   otherwise an instruction can end up waiting for itself (§6.1).
8. The status table holds only the **youngest** writer's tag; older results that arrive late are
   dropped at WB. That single rule gives WAW for free.
9. One register can be written by many stations in flight — the trace in §6 has three writers to
   `$f10` and still finishes correctly.

> Next: [[08_Speculative_Execution_ROB]] — a branch cannot be fixed by flushing once the register
> file has been written; add a ROB to keep results temporary and commit in program order.
