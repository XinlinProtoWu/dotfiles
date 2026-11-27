# Topic 8 — Speculative Execution & Tomasulo with a Reorder Buffer

> Source: `COMP4611L7_2026F.pdf` (Lecture 7)
> Builds on [[07_Out_of_Order_Execution]] (Tomasulo). Next: [[09_SIMD_and_GPU]].

## 1. The problem speculation solves

Tomasulo lets a *ready* instruction execute while an *earlier* one waits for operands. But a
**branch** is different from a data dependence: until it resolves, we do not know *which
instructions should execute at all*.

```
I1: DIV  F10, F12, F14     # slow (many cycles)
I2: BEQ  F10, F16, Target  # needs F10 -> resolves late
I3: ADD  F0, F2, F4        # is it even supposed to run?
Target: SUB F6, F8, F18
```

With plain Tomasulo, `I2` sits in its reservation station waiting for `F10`, and `I3` cannot be
issued because program order is blocked — we lose the very parallelism Tomasulo was built for.

**Speculative execution:** *predict* the branch outcome (here "not taken"), and start executing
instructions along the predicted path **before the control dependence is resolved**. If the
prediction is right, we saved the wait. If it is wrong, we must undo the work.

> 💡 **Everyday example:** a cook starts boiling water for pasta before checking whether the guests
> actually want pasta. If they do — big time saving. If they don't, the water is thrown out, but
> *nothing else in the kitchen changed*. Speculation is only safe if the wasted work is
> **discardable**.

### Why "just flush it" is not enough

![[COMP4611L7_2026F.pdf#page=4]]

*Prediction wrong: `I3` already wrote `F0 = 5`; the old value `20` is gone (Lecture 7, p. 4).*

```
Cycle  7: I3 writes 2 + 3 = 5 into F0   (F0 was 20)
Cycle 10: I2 takes the branch -> I3 should never have run
```

Flushing the wrong-path instruction from the pipeline **cannot restore `F0 = 20`**, because the
register file was already overwritten. Architectural state is *destructive*; the pipeline is not.

**Fix:** never let a speculative instruction touch architectural state. Keep its result
**temporary** and only make it permanent when we are sure the instruction is on the correct path.

![[COMP4611L7_2026F.pdf#page=5]]

*`F0` keeps 20; `I3`'s 5 lives in temporary storage until we know it is needed (p. 5).*

## 2. Write Result vs. Commit — the key distinction

| | **Write Result** | **Commit** |
|---|---|---|
| What happens | result is stored + broadcast on the CDB so *waiting instructions* can use it | the result is written into the **architectural register file / memory** |
| Order | **out of order** | **in program order** |
| Purpose | break RAW dependences fast | make state permanent → enables undo |

> 💡 **Example:** `I3` finishes first. Its 5 is broadcast (so a later `ADD F20,F0,F22` on the
> predicted path can already use 5), but `F0` is still 20. If `I2` turns out taken, we throw the
> temporary 5 away; `F0` was never touched.

To hold completed-but-not-committed results **and** to know the program order, we need a buffer:
the **Reorder Buffer (ROB)**.

## 3. The Reorder Buffer (ROB)

![[COMP4611L7_2026F.pdf#page=8]]

*ROB as a circular queue: Issue at the tail, Commit at the head (p. 8).*

![[COMP4611L7_2026F.pdf#page=9]]

*Tomasulo + ROB: the CDB feeds the ROB as well as waiting RS operands; Commit drains the ROB head
into the register file (p. 9).*

The ROB is a **circular queue (FIFO)**:

- Instructions get entries **in program order** at **Issue** (tail).
- They keep the entry until **Commit** (head).
- Therefore the head is always the *oldest uncommitted* instruction → committing from the head is
  automatically **in program order**.
- Results may arrive out of order (any entry can become ready); the head simply **waits** for its
  own result. A ready entry behind the head cannot commit early — that is the whole point.

> 💡 **Analogy:** supermarket checkout. Items (results) are scanned as fast as the cashier can, but
> customers are *served* strictly in queue order. A customer with a price-check issue blocks the
> queue even if everyone behind is ready to pay.

### ROB entry fields

| Field | Meaning | Example |
|---|---|---|
| **Instruction type** | operation, e.g. arithmetic / branch / store | `ADD` |
| **Destination** | architectural register (or memory address for a store) to update at Commit | `F0` |
| **Value** | result written at Write Result | `5` |
| **Ready** | `Yes` once the result is in the ROB | `Yes` |

![[COMP4611L7_2026F.pdf#page=10]]

*A ready ROB entry waiting for its turn to commit (p. 10).*

### Why the result tag becomes the ROB entry number

In plain Tomasulo the tag is a **reservation-station ID**. That breaks down here:

```
I3: ADD F0, F2, F4        # uses Add1 and ROB entry #3
after Write Result:
   Add1 = Free        <- RS is reused by the NEXT instruction
   ROB[#3] still holds I3's value 5 until Commit
```

If we kept using `Add1` as the tag, a *later* instruction reusing station `Add1` would broadcast
under the same tag → waiting instructions would grab the **wrong value**.

**Rule: the tag of a result is its ROB entry number.** The ROB entry lives from Issue to Commit,
which is exactly the lifetime of the value's name.

![[COMP4611L7_2026F.pdf#page=11]]

*RS freed after Write Result, but the ROB entry (and its tag) persists (p. 11).*

## 4. Issue: allocating an entry and grabbing operands

At **Issue** an instruction needs **both** a free RS of the right type **and** a free ROB entry.
Two lookups happen per source operand:

```
I1: mul.d $f0, $f2, $f4        $f2 = 2, $f4 = 3, $f0 = 0, $f8 = 10
I2: mul.d $f6, $f0, $f8
```

1. `RegisterStat[$f0] = #1` → the current value of `$f0` is **not** in the register file; it is
   being produced by the instruction in ROB entry **#1**. So `I2`'s `Qj = #1`, `Vj = empty`.
2. `RegisterStat[$f8] = 0` → the register file value is current → `Vk = 10`, `Qk = 0`.

| RS | Instr | Busy | Op | Vj | Vk | Qj | Qk | Dest |
|---|---|---|---|---|---|---|---|---|
| Mult1 | I1 | Yes | MUL | 2 | 3 | 0 | 0 | #1 |
| Mult2 | I2 | Yes | MUL | empty | 10 | #1 | 0 | #2 |

| Register | RegisterStat |
|---|---|
| `$f0` | #1 |
| `$f6` | #2 |

Two extra subtleties introduced by the ROB:

- **`ROB[b].Dest ← fd`** must be recorded, because the register file update is deferred to Commit.
- **If the producing ROB entry is already `Ready`** (it finished but has not committed), copy
  `ROB[t].Value` into `Vj` and set `Qj = 0` immediately. The value is known — the *name* is what
  is still in flight.

> ⚠️ Same ordering trap as plain Tomasulo: read `RegisterStat[fs]/[ft]` **before** writing
> `RegisterStat[fd]`, otherwise an instruction becomes its own producer.

## 5. Pseudocode (memorise this structure)

```
Issue (in program order)                     Write Result (WB, out of order)
r = free RS of right type; b = free ROB entry When execution done and CDB free:
RS[r].Busy = Yes; RS[r].Op = op                b = RS[r].Dest
RS[r].Dest = b                                 broadcast (b, result)
ROB[b].Instruction = op                        ROB[b].Value = result
ROB[b].Dest = fd; ROB[b].Value = empty         ROB[b].Ready = Yes
ROB[b].Ready = No                              for each busy RS s:
for (f, V, Q) in (fs,Vj,Qj), (ft,Vk,Qk):          if s.Qj == b: s.Vj = result; s.Qj = 0
  t = RegisterStat[f]                             if s.Qk == b: s.Vk = result; s.Qk = 0
  if t == 0:        V = Regs[f];        Q = 0  free RS r
  elif ROB[t].Ready: V = ROB[t].Value;  Q = 0
  else:             V = empty;          Q = t
RegisterStat[fd] = b                         Commit (in program order)
                                             if ROB not empty and ROB[Head].Ready:
Execute (out of order)                         d = ROB[Head].Dest
if Qj == 0 and Qk == 0 and FU accepts:         Regs[d] = ROB[Head].Value
   start execution with Vj, Vk                 if RegisterStat[d] == Head:
                                                  RegisterStat[d] = 0
                                               free ROB[Head]; Head++
```

Note the **two** places `RegisterStat` is cleared: in **WB** no longer (unlike plain Tomasulo — the
register is *not* written there), only in **Commit**, and only if the committing entry is still the
latest writer of that register.

## 6. Worked example (no branch)

```
I1: mul.d $f0,  $f2, $f4      $f0=0  $f2=2  $f4=3  $f6=0  $f8=10  $f10=0
I2: mul.d $f6,  $f0, $f8
I3: add.d $f10, $f2, $f4
```

Hardware: pipelined MUL `M1–M3`, pipelined ADD `A1–A2`, 4 ROB entries, one Issue / one WB / one
Commit per cycle, CDB value usable next cycle.

| Instruction / cycle | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| I1 (`mul.d $f0`) | IF | Issue | M1 | M2 | M3 | WB | C | | | | | |
| I2 (`mul.d $f6`) | | IF | Issue | Wait | Wait | Wait | M1 | M2 | M3 | WB | C | |
| I3 (`add.d $f10`) | | | IF | Issue | A1 | A2 | WB | | | | | C |

- **Cycle 5:** `I3` starts `A1` **before** `I2`, because it has both operands and a free adder.
  `I2` is still waiting (`Qj = #1`).
- **Cycle 6:** `I1` WB → CDB `(#1, 6)`. `Mult2.Qj` matches → `Vj = 6, Qj = 0`.
  `ROB[#1].Ready = Yes`. `$f0` **stays 0**.
- **Cycle 7:** `I1` commits → `$f0 = 6`. `I3` WB → `ROB[#3] = 5, Ready`. `I3` is ready but **cannot
  commit** — head is `#2`.
- **Cycle 10:** `I2` WB → `(#2, 60)` → `ROB[#2].Ready`. `$f6` still 0.
- **Cycles 11–12:** `I2` commits (`$f6 = 60`), then `I3` commits (`$f10 = 5`).

**Execution order: I1, I3, I2. Commit order: I1, I2, I3.** Architectural state ends identical to a
sequential run — but the machine used idle hardware.

![[COMP4611L7_2026F.pdf#page=15]]

*End of cycle 5 — `I3` executing, `I2` waiting on tag `#1` (p. 15).*

![[COMP4611L7_2026F.pdf#page=18]]

*End of cycle 10 — `ROB[#3]` ready since cycle 7 but still blocked behind `#2` (p. 18).*

> 💡 **Reading the tables:** the RS table is about *execution* (operands ready?), the ROB is about
> *state* (committed?). A ready ROB entry means the value exists; it does **not** mean the
> architectural register has it.

## 7. Branch misprediction recovery

Back to the opening example, now with a ROB. Predict **not taken**; `F0 = 20` initially.

![[COMP4611L7_2026F.pdf#page=23]]

*Cycle 7: `I3` computed 5 into `ROB[#3]`; `F0` is still 20 (p. 23).*

| Cycle | What happens |
|---|---|
| 7 | `I3` WB → `ROB[#3] = {Dest F0, Value 5, Ready}`. `RegisterStat[F0] = #3`. **`F0` = 20.** |
| 10 | `I1` commits (`F10 = 4`). `I2` executes the branch in `EX` → **taken** (F10 == F16). |
| 11 | `I2` WB, then reaches head. `I3` sits ready behind it. |
| 12 | `I2` **commits** (a branch's "commit" confirms the path). Prediction was wrong → **flush**: free `ROB[#2]`, `ROB[#3]`, and reset `RegisterStat[F0] = #3 → 0`. **`F0` stays 20.** Fetch resumes at `Target`. |

![[COMP4611L7_2026F.pdf#page=25]]

*Cycle 12: `I3` leaves the ROB without ever committing; `F0` is untouched (p. 25).*

**Why this works:** the wrong-path instruction's *only* effect on architectural state would have
been at Commit, and it was flushed before that. Architectural state is therefore **precise**: it
always equals the state of some sequential prefix of the program.

### Recovery details worth knowing

- **What must be cleaned up:** all ROB entries younger than the mispredicted branch, all RS entries
  belonging to them, the fetch/rename state, and any `RegisterStat` entries pointing at flushed
  ROB entries (set them to 0 so later issues read the register file).
- **What must *not* be undone:** commits of *older* instructions (`I1` here) are already
  architectural and stay.
- **The branch must not "commit" its wrong-path effects either** — only its own architectural
  effect (the PC redirect) applies.
- **Cost of the simple scheme:** the misprediction is only discovered when the branch reaches the
  **head** of the ROB — i.e. after all older instructions commit. That is correct but slow.
  Real machines resolve the branch in `EX`, then **squash early** using checkpoints of the
  rename/`RegisterStat` state, keeping the ROB for the rare cases that need the full walk-back.
- **Stores** must not write memory at WB — they sit in the ROB/store buffer and write at Commit.
  Same reason: memory is architectural.

> 💡 **Speed-up example:** a 20-cycle branch resolution predicted correctly lets ~20 cycles of work
> proceed. With 95 % accuracy and a 15-cycle penalty on the 5 % mispredicts, average cost =
> `0.95·0 + 0.05·15 = 0.75` cycles/instruction of wasted work — far better than stalling every
> branch.

## 8. Real machines and summary

![[COMP4611L7_2026F.pdf#page=26]]

*Intel Pentium Pro (1995) and Skylake (224 ROB entries) — same idea, 20 years apart (p. 26).*

The canonical **out-of-order (OOO) core** loop:

```
in-order fetch/decode/issue  ->  out-of-order execute  ->  in-order commit
```

| Mechanism | Solves | Cost |
|---|---|---|
| Reservation stations + CDB | RAW (true) dependences | tag matching hardware |
| Renaming / `RegisterStat` | WAR, WAW (name) dependences | register-status table |
| ROB + Commit | precise state, **undo of speculation** | ROB storage, commit port, in-order commit bottleneck |

### Key takeaways

1. Speculation = execute before the control dependence resolves; it requires **undo**.
2. Undo is impossible if speculative results reach the register file → keep them **temporary**.
3. **Write Result** (out of order, feeds consumers) and **Commit** (in order, feeds
   architectural state) are separate events.
4. The ROB is a circular FIFO giving (a) temporary result storage, (b) program order, (c) the
   result **tag**.
5. A misprediction is repaired by **flushing younger ROB entries** at Commit; older commits stay.
6. Issue/execute/commit order: **in order / out of order / in order**.

### Exam-style checklist

- [ ] Explain why `I3`'s write to `F0` cannot be undone by flushing.
- [ ] Draw the ROB with head/tail and say which end Issue and Commit use.
- [ ] State the four ROB entry fields and what `Ready` means.
- [ ] Explain *why the tag is the ROB entry number*, not the RS ID.
- [ ] Given a cycle table, fill ROB `Value/Ready`, `RegisterStat`, and register values.
- [ ] Explain the recovery steps after a mispredicted branch and why `F0` survives.
- [ ] Contrast "Write Result" and "Commit" in one sentence each.
