# ECE241 Midterm 2025 — Verilog Questions: Full Solutions & Explanations

Covers only the Verilog questions: **Q8(a)(i), Q8(a)(ii), Q9(a), Q9(b), Q9(c), Q9(d)(ii)**.
Grader notes included where marks were lost on the graded copy (58.1% overall).

---

## Q8(a)(i) — Write Verilog for the full-adder circuit [3 marks]

**The circuit given:** three gates feed two multiplexers:
- `x = b · Cin` (AND), `y = b + Cin` (OR), `z = b ⊕ Cin` (XOR)
- Cout mux (select = a): a = 1 → y, a = 0 → x
- Sum mux (select = a): a = 1 → ~z, a = 0 → z

**Solution:**

```verilog
module FA (a, b, Cin, s, Cout);
    input a, b, Cin;
    output reg s, Cout;          // assigned in an always block → must be reg

    wire x, y, z;
    assign x = b & Cin;          // AND gate
    assign y = b | Cin;          // OR gate
    assign z = b ^ Cin;          // XOR gate

    always @(*) begin            // combinational: sensitive to ALL inputs
        if (a == 1'b1) begin     // mux select a = 1
            Cout = y;
            s = ~z;
        end else begin           // mux select a = 0
            Cout = x;
            s = z;
        end
    end
endmodule
```

**Explanation — why this is a full adder:**

| a | b | Cin | x=bCin | y=b+Cin | z=b⊕Cin | Cout = a?y:x | s = a?~z:z |
|---|---|-----|--------|---------|---------|--------------|------------|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 | 1 | 1 | 0 | 1 |
| 0 | 1 | 0 | 0 | 1 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 | 1 | 0 | 1 | 0 |
| 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 | 1 | 1 | 1 | 0 |
| 1 | 1 | 0 | 0 | 1 | 1 | 1 | 0 |
| 1 | 1 | 1 | 1 | 1 | 0 | 1 | 1 |

Check Cout against the majority function (ab + bCin + aCin): when a = 0 the carry
is exactly b·Cin (both must be 1); when a = 1 the carry is b + Cin (at least one
suffices). Check s = a ⊕ b ⊕ Cin: with z = b ⊕ Cin, a = 0 → s = z, a = 1 → s = ~z. ✓

**Key Verilog points:**
1. **`always @(*)`** — a combinational block must be sensitive to *every* signal it
   reads (`a`, `x`, `y`, `z`). Writing `always @(a)` compiles, but in simulation the
   outputs only re-evaluate when `a` changes — if `b` or `Cin` change while `a` is
   constant, `s`/`Cout` go **stale** (this exact bug is what Q8(a)(ii) probes).
2. `s` and `Cout` are declared `reg` because they are assigned procedurally inside
   an always block; `x, y, z` stay `wire` because they're driven by `assign`.
3. Blocking `=` is the correct assignment inside combinational always blocks.
4. The question required **if-else for the muxes** — a 2-to-1 mux is exactly
   `if (sel) out = in1; else out = in0;`.

> **Grader note:** 3/3 on the graded copy.

---

## Q8(a)(ii) — Is the partner's simulation correct? [3 marks]

**Task:** your lab partner simulated *their* FA code; the waveform sweeps the input
valuations of (a, b, Cin). Decide whether it's correct for all valuations, and if
not, which ones are wrong.

**Method (this is what they're testing):**

1. Write the golden truth table (from the correct circuit above):

| a b Cin | s | Cout |
|---------|---|------|
| 0 0 0 | 0 | 0 |
| 0 0 1 | 1 | 0 |
| 0 1 0 | 1 | 0 |
| **0 1 1** | **0** | **1** |
| 1 0 0 | 1 | 0 |
| 1 0 1 | 0 | 1 |
| 1 1 0 | 0 | 1 |
| 1 1 1 | 1 | 1 |

2. Walk the waveform slot by slot; for each input valuation, read s and Cout and
   compare against the table. Also cross-check x, y, z against b and Cin.

**Conclusion:** the simulation is **not** correct for all valuations. The
mismatch occurs for **a = 0, b = 1, Cin = 1** — where the waveform shows
**s = 1 (should be 0)** and **Cout = 0 (should be 1)**.

**What bug in their code does this?** The a = 0 (else) branch is the one that
misbehaves. Typical culprits, all visible by comparing against the golden table:
- `Cout <= z;` instead of `Cout <= x;` in the else branch (Cout then follows
  b ⊕ Cin instead of b · Cin — wrong exactly when b = Cin = 1 with a = 0, since
  z = 0 but x = 1);
- an inverted sum (`s <= ~z;` in the wrong branch);
- an **incomplete sensitivity list** (e.g. `always @(a)`): outputs only update
  when `a` changes, so valuations applied while `a` stays 0 show *stale* values —
  the signature is outputs that lag one valuation behind.

**The fix:** in the a = 0 branch it must be `s = z; Cout = x;`, and the
sensitivity list must be `@(*)`.

> **Grader note:** 2/3 — full credit for "simulation is incorrect" and for
> identifying the wrong valuation (a=0, b=1, Cin=1); the lost mark was for not
> being specific enough about the code-level cause/fix. Always name the exact
> assignment that's wrong *and* what it should be.

---

## Q9(a) — Verilog → circuit: `TFF` [2 marks]

```verilog
module TFF (A, B, C, Q);
    input A, B, C;
    output reg Q;
    always @(posedge C)
        if (B == 0)
            Q <= 1'b0;
        else if (A == 1)
            Q <= ~Q;
endmodule
```

**Read the code as a priority list** (evaluated at each rising edge of C):

| B | A | action | D must be |
|---|---|--------|-----------|
| 0 | X | clear → Q = 0 | 0 |
| 1 | 1 | toggle → Q = ~Q | ~Q |
| 1 | 0 | *(no else)* → hold | Q |

**Circuit:** a D flip-flop clocked by C, with D driven by a 2-mux tree:

```
              ┌─mux(sel=A)─┐   ┌─mux(sel=B)─┐
 Q ──────────►│ in0        │   │            │
 ~Q ─────────►│ in1        ├──►│ in1        ├──► D
              └────────────┘   │ in0 = 0    │      ┌──────┐
                               └────────────┘   ┌─►│ D  Q ├─┬─► Q
 0 ────────────────────────────┘                │  │      │ └─► ~Q
 C ─────────────────────────────────────────────┘  └──────┘
```

**Explanation.** The missing final `else` means "keep Q" — in hardware that's
feeding Q back into D (no clock gating!). Priority is expressed by nesting: the
`if (B == 0)` is the outer condition, so B's mux is last (closest to D), forcing
0 regardless of A. This is a **T flip-flop (A = T) with synchronous clear (B)**.

> **Grader note:** 2/2. Note the feedback wire from Q (and the inverter for ~Q)
> must actually reach the mux — a toggling FF *always* needs Q routed back.

---

## Q9(b) — Verilog → circuit: `JKFF` [4 marks]

```verilog
module JKFF (J, K, C, Q);
    input J, K, C;
    output reg Q;
    always @(posedge C)
        if (K)
            if (J)  Q <= ~Q;
            else    Q <= 1'b0;
        else
            if (J)  Q <= 1'b1;
endmodule
```

**Truth table from the code** (again: missing final else = hold):

| J | K | Q next | JK-FF name |
|---|---|--------|-----------|
| 0 | 0 | **Q (hold)** | hold |
| 1 | 0 | 1 | set |
| 0 | 1 | 0 | reset |
| 1 | 1 | ~Q | toggle |

This is exactly the classic **JK flip-flop**, whose characteristic equation is:

```
D = J·Q̄ + K̄·Q
```

Check: JK = 00 → D = Q ✓ (hold); JK = 10 → D = Q̄ + Q = 1 ✓; JK = 01 → D = 0 ✓;
JK = 11 → D = Q̄ ✓.

**Circuit (minimal — one 2-to-1 mux!):** write D as a mux on Q:

```
D = Q̄·J + Q·K̄   →   mux(sel = Q, in0 = J, in1 = ~K)
```

```
 J ────────►│ in0          │
            │ mux(sel = Q) ├──► D ──►┌──────┐
 ~K ───────►│ in1          │         │ D  Q ├─┬─► Q (feeds back to sel)
            └──────────────┘      ┌─►│      │ └─► ~Q
 C ───────────────────────────────┘  └──────┘
```

(Equally correct: a 2-mux tree — mux(sel=J){in0: mux(sel=K){in0=Q, in1=0},
in1: mux(sel=K){in0=1, in1=~Q}} — but the characteristic-equation form is
simpler, and the question says "as simple as possible.")

> **Grader note:** 3/4 — "jk = 00 incorrect". The JK = 00 case is **hold**: D must
> equal Q. The drawn circuit got that case wrong (e.g. forcing a constant instead
> of feeding Q back). When in doubt, enumerate all four JK rows and check each
> mux path against the table — the hold case is the one people forget.

---

## Q9(c) — Verilog → circuit: 2-bit register `SR` [4 marks]

```verilog
module SR (W, X, Y, Z, R, C, Q);
    input W, X, Y, Z, C;
    input [1:0] R;
    output reg [1:0] Q;
    always @(posedge C)
        if (!Z)
            Q <= 2'b0;
        else if (Y)
            if (X)
                Q <= R;
            else
                Q <= {W, Q[1]};
endmodule
```

**Behavior (priority Z > Y > X), per clock edge:**

| Z | Y | X | Q next | meaning |
|---|---|---|--------|---------|
| 0 | X | X | `00` | synchronous clear |
| 1 | 0 | X | Q | hold |
| 1 | 1 | 1 | `R[1:0]` | parallel load |
| 1 | 1 | 0 | `{W, Q[1]}` | shift |

**Read the concatenation carefully:** `{W, Q[1]}` is a 2-bit value whose
**left bit goes to Q[1]** and right bit to Q[0]:

```
Q[1] <= W        (W enters the MSB)
Q[0] <= Q[1]     (old MSB shifts down into LSB)
```

**Circuit — two D flip-flops, each with its own mux tree.** Per bit i:
ol
```
                          ┌── mux(sel=X)──┐
        R[i] ────────────►│ in1           │
        shift_i ─────────►│ in0           ├──┐
                          └───────────────┘  │   ┌── mux(sel=Y)──┐
                                             ├──►│ in1           │
        Q[i] (hold) ────────────────────────►│ in0│               ├──┐
                                             │   └───────────────┘  │   ┌── mux(sel=Z)──┐
                                             └──────────────────────┼──►│ in1 (Z=1)     ├─► D_i
                                                                    │   │ in0 (Z=0) = 0 │
                                                                    │   └───────────────┘
        with  shift_1 = W,  shift_0 = Q[1]
```

Both FFs clocked by C. (A 4-to-1 mux with select lines {Z, Y} plus one 2-to-1
mux for X is equally acceptable: inputs Z=0 → 0, Z=1&Y=0 → Q[i], Z=1&Y=1 → the
X-mux output.)

**Explanation.** Mirror the if-else *nesting* with mux *priority*: the
outermost condition (Z) is the mux closest to D. The clear value `2'b0` is a
constant 0 on the Z=0 input. Because there is no final else, the Y = 0 path is
just Q[i] fed back. The only per-bit difference is the shift source: bit 1
takes W, bit 0 takes Q[1].

> **Grader note:** 0/4 — "incorrect logic". The likely confusions: (1) reading
> `{W, Q[1]}` backwards (concatenation is MSB-first — W lands in Q[1], not Q[0]);
> (2) forgetting the hold path (Y = 0 → feed Q[i] back); (3) putting the Z-clear
> at the wrong priority level. Always expand the code into the 4-row table
> above *before* drawing anything.

---

## Q9(d)(ii) — Circuit → Verilog: universal 4-bit register [3 marks]

**The circuit** (from part (d)(i)): four D flip-flops Q₃…Q₀, each fed by a
4-to-1 mux whose select lines are the 2-bit `Op`, giving:

| Op | action per clock edge |
|----|-----------------------|
| 00 | hold (Q keeps its value) |
| 01 | shift right — w enters Q₃, each Qᵢ ← Qᵢ₊₁ |
| 10 | shift left — x enters Q₀, each Qᵢ ← Qᵢ₋₁ |
| 11 | parallel load Q ← R |

**Solution:**

```verilog
module Univ (w, x, R, Op, Clock, Q);
    input w, x, Clock;
    input [1:0] Op;
    input [3:0] R;
    output reg [3:0] Q;

    always @(posedge Clock) begin
        case (Op)
            2'b00: Q <= Q;               // hold (also the default if a case is omitted)
            2'b01: Q <= {w, Q[3:1]};     // right shift: w -> Q3, Q3 -> Q2 -> Q1 -> Q0
            2'b10: Q <= {Q[2:0], x};     // left shift:  Q3 <- Q2 <- Q1 <- Q0 <- x
            2'b11: Q <= R;               // parallel load
        endcase
    end
endmodule
```

(An if-else-if chain on `Op` is equally acceptable; `case` is cleaner for a
4-way mux.)

**Explanation — the concatenations do all the work:**

```
{w, Q[3:1]}  =  { w, Q3, Q2, Q1 }  →  assigned to {Q3, Q2, Q1, Q0}
               so Q3←w, Q2←Q3, Q1←Q2, Q0←Q1     (data moves toward Q0 = "right")

{Q[2:0], x}  =  { Q2, Q1, Q0, x }  →  so Q3←Q2, Q2←Q1, Q1←Q0, Q0←x
                                                   (data moves toward Q3 = "left")
```

Non-blocking `<=` is essential here: every RHS uses the **old** Q, so all four
bits shift together — exactly like the four flip-flops in the circuit.

> **Grader note:** 1/3 — only the `Op = 11: Q <= R` clause earned a mark. The
> mistakes on the graded copy were writing `Q <= w;` and `Q <= x;` for the shift
> cases. Two lessons: (1) a 1-bit signal assigned to a 4-bit reg is
> **zero-extended** (`Q <= w` gives `000w`), which is a *load*, not a shift;
> (2) a shift is always a **concatenation of Q's own bits with the incoming
> serial input**. Also note `Op = 00` (hold) can be omitted entirely — with no
> matching case and no default, Q simply keeps its value, which *is* the hold.

---

## Score summary (Verilog questions)

| Part | Score | Key takeaway |
|---|---|---|
| Q8(a)(i) | 3/3 | structural Verilog: `assign` for gates, if-else for muxes, `always @(*)` |
| Q8(a)(ii) | 2/3 | debug by golden truth table; name the exact wrong assignment |
| Q9(a) | 2/2 | missing else = feed Q back into D; mux priority = if-else nesting |
| Q9(b) | 3/4 | JK: D = J·Q̄ + K̄·Q → one mux, sel = Q; don't forget JK = 00 hold |
| Q9(c) | 0/4 | expand to a table first; `{W, Q[1]}` puts W in the MSB |
| Q9(d)(ii) | 1/3 | shifts = concatenations `{w, Q[3:1]}` / `{Q[2:0], x}`, not `Q <= w` |
| **Total** | **10/19** | |
