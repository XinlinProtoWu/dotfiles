# Tutorial 5 — GPU SIMD Utilisation (worked problems)

> Source: `COMP4611T5_2026F.pdf`. Theory: [[09_SIMD_and_GPU]] §7–§8, [[10_GPU_Programming_Performance]] §7.

## 0. The one formula you need

A warp has **32 lanes**. It issues an instruction for **all 32 lanes**, but lanes whose mask bit is
`0` do nothing (they are still *occupied* for that issue).

```
SIMD utilisation U = useful thread-instruction slots / issued warp lane slots
                   = (Σ active lanes over issued instructions) / (32 × #issued instructions)
```

Three counting rules from the tutorial:

1. **Denominator** counts `32` for **every issued instruction**, even if only one lane is active.
2. **An instruction with 0 active lanes is not issued** — it does not appear in the denominator.
3. The **numerator** counts each active thread once per instruction it really executes.

> ⚠️ "Divergence" does **not** automatically lower `U`. If *every* warp is uniform (even if
> different warps take different paths) then `U = 100 %`. What hurts is a warp **splitting
> internally**.

![[COMP4611T5_2026F.pdf#page=3]]

*Q1 accounting: 32 lanes for I1, 8 for I2 → 40 useful of 64 slots (p. 3).*

## 1. Q1 — branch divergence with a repeated pattern

```
for (i = 0; i < N; i++) {
    if (A[i] % 3 == 0) { A[i] = A[i] * B[i]; }   // I1 = test, I2 = multiply
}
```

- 32 threads per warp, 32 lanes, **N is a positive multiple of 32**.
- I1 and I2 have **equal** execution time; count only I1 and I2.
- If **all** threads skip I2, the warp does not issue I2.
- `A` = "24 ones, then 8 zeros", repeating. `B` = "48 zeros, then 64 ones", repeating.

### (a) Number of warps

`N` is a multiple of 32 and each thread does one iteration ⇒

```
#warps = N / 32
```

### (b) Utilisation for this input

`A[i] % 3 == 0` is true **only where `A[i] = 0`** (since 1 % 3 = 1). Each 32-element block of `A` has
exactly **8 zeros**, so in **every** warp exactly 8 threads take the branch:

| Issued instruction | Active lanes | Lane slots |
|---|---|---|
| I1 (test) | **32** (every thread tests) | 32 |
| I2 (multiply) | **8** (only the zeros pass) | 32 |
| **Total** | **40** | **64** |

```
U = (32 + 8) / (32 × 2) = 40/64 = 62.5 %
```

`B` is irrelevant here: it appears only inside `I2`, which is executed by the same 8 threads
regardless of `B`'s value, and it does not change the branch outcome or the instruction count.

> 💡 **Sanity check with N threads:** useful = `N` (I1) + `N/4` (I2, since 8/32 = ¼ of threads) =
> `1.25N`; slots = `2 × 32 × N/32 = 2N` ⇒ `1.25/2 = 62.5 %`. ✔

### (c) Which utilisations are reachable?

Let `m` = number of threads per warp that pass I1 (`0 ≤ m ≤ 32`).

- If `m ≥ 1`: the warp issues **both** instructions ⇒ `U = (32 + m)/64`.
- If `m = 0`: the warp issues **only I1** ⇒ `U = 32/32 = 100 %`.

| `m` | Instructions issued | `U` |
|---|---|---|
| 0 | 1 | **100 %** |
| 32 | 2 | **100 %** |
| 4 | 2 | 36/64 = **56.25 %** |
| 1 | 2 | 33/64 = **51.5625 %** |
| 16 | 2 | 48/64 = 75 % |

- **100 % — possible:** every warp uniform. Either nobody takes the branch (`m = 0`) or everybody
  does (`m = 32`). *Different warps may differ from each other* — that is inter-warp diversity with
  no intra-warp divergence.
- **56.25 % — possible:** exactly **4** threads per warp pass I1 in all warps (e.g. `A[i] % 3 == 0`
  for `i ≡ 28..31 (mod 32)`).
- **50 % — impossible.** With `m ≥ 1` the minimum is `33/64 = 51.5625 %`; with `m = 0` it jumps to
  100 %. There is no `m` giving 32 useful slots out of 64, because one active thread already costs a
  whole I2 issue.

![[COMP4611T5_2026F.pdf#page=4]]

*The reachable `U` values and why 50 % cannot occur (p. 4).*

**Generalisation (useful for the exam):** with 2 counted instructions where one is always executed,

```
U(m) = 100 %                if m = 0
       (32 + m)/64           if 1 ≤ m ≤ 32      ->  ranges over [51.56 %, 100 %]
```

The curve is **discontinuous** at `m = 0` — a small amount of divergence is *worse* than none, but
"a little divergence" can never be as bad as 50 %.

## 2. Q2 — dynamic warp formation, lane-constrained

Three warps `X, Y, Z` run the same conditional multiply. `1` = thread takes the branch (runs I2).
Lanes are numbered left to right.

| Warp | Lane 0 | Lane 1 | Lanes 2–29 | Lane 30 | Lane 31 |
|---|---|---|---|---|---|
| **X** | 1 | 0 | all 0 | 1 | 0 |
| **Y** | 1 | 0 | all 0 | 0 | 1 |
| **Z** | 0 | 1 | all 0 | 0 | 0 |

Rule: threads may **change warp membership** but must **keep their lane position** (their registers
live in that lane's slice of the register file).

### (a) Can all five taken threads fit in one warp?

The five taken threads are: `X@0, X@30, Y@0, Y@31, Z@1`.

Two of them — `X@0` and `Y@0` — are both at **lane 0**. One lane can hold one thread per cycle, so
they **must be in two different warps**. Therefore **no**, 1 issue is impossible; the minimum is
**2**.

A valid regrouping (swap non-taken threads in the same lane so no lane holds two taken threads):

| Warp | Lane 0 | Lane 1 | Lanes 2–29 | Lane 30 | Lane 31 | I2 issues |
|---|---|---|---|---|---|---|
| **X′** | 1 | 1 | 0 | 1 | 1 | 1 |
| **Y′** | 1 | 0 | 0 | 0 | 0 | 1 |
| **Z′** | 0 | 0 | 0 | 0 | 0 | 0 (not issued) |

⇒ **I2 issues drop from 3 to 2** (and `Z′` disappears entirely).

![[COMP4611T5_2026F.pdf#page=6]]

*Lane-constrained merge: `Z@1` and `Y@31` move into `X′`, keeping their lane indices (p. 6).*

> 💡 **Why the lane constraint exists:** merging is done by **swapping register-file slices**
> between warps, not by moving a thread to a different lane. A thread's operands physically sit in
> its lane's registers (Lecture 8, p. 26/34), so a thread that "moves" to another lane would lose its
> state.

### (b) Does this help Q1's `24 ones, 8 zeros` pattern?

**No.** In Q1, in *every* warp the taken threads are exactly lanes **24–31** (the 8 zeros sit at the
end of each 32-element block). Merging cannot move a thread out of lanes 24–31 into lanes 0–23, so
no matter how warps are regrouped:

- each warp still has 8 taken threads at lanes 24–31,
- each warp still needs **one** I2 issue,
- utilisation stays `40/64 = 62.5 %`.

In fact regrouping would be pointless: every warp already has a *ready-made* full set of 8 active
lanes, and you cannot combine two warps' lane-24 threads into one warp (same lane conflict).

> 💡 **Take-away:** dynamic warp formation helps when divergence patterns are **randomized** across
> warps (so different warps are active at *different* lanes). It does nothing when the pattern is
> **lane-aligned and identical** across warps.

## 3. Q3 — a partially filled warp (two-way branch)

```
for (i = 0; i < 1025; i++) {
    if (A[i] < 33) { B[i] = A[i] << 1; }   // I1 test, I2 then-path
    else           { B[i] = A[i] >> 1; }   // I3 else-path
}
```

1025 threads, 32-thread warps, consecutive thread IDs per warp. Count I1, I2, I3 equally; a warp does
**not** issue a path with zero active threads.

**Key invariant:** every thread executes **I1 plus exactly one of I2/I3** ⇒ useful slots =
`2 × #threads = 2050`, always. Only the **denominator** changes.

### (a) Number of warps

```
32 full warps × 32 = 1024 threads, plus 1 thread (id 1024) -> 33 warps
```

The last warp has **1 active lane out of 32** — permanently 31 wasted slots.

### (b) Maximum and minimum utilisation

**Maximum** — every warp's threads all take the *same* path (uniform masks):

| Warp group | Useful slots | Warp instructions issued |
|---|---|---|
| 32 full warps | `1024 × 2 = 2048` | `32 × 2 = 64` |
| Final warp (1 lane) | `1 × 2 = 2` | `2` |
| **Total** | **2050** | **66** |

```
U_max = 2050 / (32 × 66) = 2050/2112 ≈ 97.06 %
```

Even a divergence-free input cannot reach 100 %: the final warp leaves 31 lanes idle in both of its
issues. Example input: `A[i] = 0` for all `i`.

**Minimum** — every *full* warp contains both outcomes, so it issues all three instructions:

| Warp group | Useful slots | Warp instructions issued |
|---|---|---|
| 32 full warps | `1024 × 2 = 2048` | `32 × 3 = 96` |
| Final warp (1 lane, cannot diverge) | `1 × 2 = 2` | `2` |
| **Total** | **2050** | **98** |

```
U_min = 2050 / (32 × 98) = 2050/3136 ≈ 65.37 %
```

Example input: alternate `A[i] = 0, 33, 0, 33, …` (or any split — even `1` thread on one side and
31 on the other gives the same `U`, since a divergent warp always issues **3** instructions
regardless of how lopsided the split is).

![[COMP4611T5_2026F.pdf#page=8]]

*Maximum: uniform warps + a lonely final warp (p. 8).*

![[COMP4611T5_2026F.pdf#page=9]]

*Minimum: every full warp issues all three instructions (p. 9).*

> ⚠️ **Common mistake:** assuming the minimum needs a balanced 16/16 split. It does not — the cost is
> **per issued instruction**, not per active lane, so *any* divergence inside a warp costs a full
> extra issue.

### (c) Utilisation for `A[i] = i`

`A[i] < 33` is true for `i = 0..32` (33 threads), false from `i = 33`.

| Warp | Thread IDs | I1 active | I2 active | I3 active | Issues |
|---|---|---|---|---|---|
| 0 | 0–31 | 32 | 32 | 0 | 2 |
| 1 | 32–63 | 32 | **1** (only id 32) | **31** | **3** |
| 2–31 | 64–1023 | 960 | 0 | 960 | 60 |
| 32 | 1024 | 1 | 0 | 1 | 2 |
| **Total** | 1025 | 1025 | 33 | 992 | **67** |

```
U = (1025 + 33 + 992) / (32 × 67) = 2050/2144 ≈ 95.62 %
```

Only **warp 1** diverges (at the boundary of the condition), and the final warp is incomplete —
`67` of a possible `66 + 1` issues.

![[COMP4611T5_2026F.pdf#page=10]]

*Only the boundary warp diverges; the last warp wastes 31 lanes (p. 10).*

## 4. Recipe for any utilisation question

1. **How many warps?** `ceil(#threads / 32)`; identify the **partial warp** (it caps your maximum
   below 100 %).
2. **Which instructions does each warp issue?** A path is issued iff ≥ 1 lane in that warp takes it.
   A warp that skips a path entirely saves a whole issue.
3. **Numerator** = Σ (threads × instructions that thread really executes). Usually constant!
4. **Denominator** = `32 × Σ issues` over all warps.
5. For "max/min" parts, vary only the **per-warp masks**: uniform ⇒ min issues ⇒ `U_max`;
   every full warp split ⇒ max issues ⇒ `U_min`.
6. For "possible/impossible" parts, tabulate `U(m)` over `m = 0 … 32` and look for gaps — remember
   the **discontinuity at `m = 0`** (path not issued at all).

### Quick self-test

- [ ] Why is `B` irrelevant in Q1?
- [ ] Why is 50 % impossible in Q1 but 56.25 % possible?
- [ ] Why can Q2's five taken threads never fit in one warp?
- [ ] Why doesn't dynamic warp formation help Q1's repeated pattern?
- [ ] Why is Q3's `U_max` only 97.06 % even with zero divergence?
- [ ] Why is a 16/16 split no worse than a 1/31 split in Q3's minimum?
