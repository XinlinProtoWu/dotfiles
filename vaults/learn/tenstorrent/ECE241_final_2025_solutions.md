# ECE241 Final Exam 2025 — Full Solutions & Explanations

Worked solutions for every question, with detailed explanations. Where the graded
copy lost marks, a **"Grader note"** explains what was wrong and why the answer
below is correct.

Notation: `x̄` = NOT x, `·` = AND, `+` = OR, `⊕` = XOR.

---

## Question 1 — Number Representation (8 marks)

### (a) Convert to 10-bit 2's complement (or state if too large)

10-bit 2's complement range: **−512 … +511**.

**i. 345** → fits. Convert by repeated division or by place values:

```
345 = 256 + 64 + 16 + 8 + 1
    = 0101011001₂
```

**Answer: `0101011001`**

**ii. 629** → 629 > 511, outside the maximum positive value.

**Answer: too large to be converted.**

> **Explanation.** An *n*-bit 2's-complement number can represent
> −2ⁿ⁻¹ … 2ⁿ⁻¹−1. For n = 10 that is −512 … +511. Always check the range
> first; if the number fits, just write its ordinary binary value padded
> to n bits (positive numbers look identical in unsigned and 2's complement).

### (b) Convert to 12-bit 2's complement, answer in hex

**i. 278**

```
278 = 256 + 16 + 4 + 2 = 0001 0001 0110₂ = 0x116
```

**Answer: `0x116`**

**ii. −1**

−1 is all ones in any width: `1111 1111 1111`.

**Answer: `0xFFF`**

> **Explanation.** For −1: take +1 = `000…001`, invert all bits → `111…110`,
> add 1 → `111…111`. Group into nibbles (4 bits) to read off hex directly.

### (c) Convert these 8-bit 2's-complement numbers (hex) to decimal

**i. F4**

`F4 = 1111 0100`. MSB = 1 → negative. Magnitude: invert → `0000 1011`, add 1 →
`0000 1100` = 12.

**Answer: −12**

**ii. 18**

`18 = 0001 1000`. MSB = 0 → positive: 16 + 8 = 24.

**Answer: +24**

> **Explanation.** Shortcut for negatives: value = −(2ⁿ − unsigned_value) =
> −(256 − 244) = −12.

### (d) x and y are **unsigned**. Find −x and −y in 2's complement, using as many bits as needed.

**i. x = `00 1101 0110`** (= 214 unsigned)

−214 must fit in n bits: need 2ⁿ⁻¹ ≥ 214 → n − 1 = 8 → **n = 9** (range −256…255).

```
x (9 bits)   = 0 1101 0110
invert       = 1 0010 1001
+1           = 1 0010 1010
```

**Answer: −x = `100101010`** (check: 512 − 214 = 298 = `100101010` ✓)

**ii. y = `100 0110 1011`** (= 1131 unsigned)

Need 2ⁿ⁻¹ ≥ 1131 → n − 1 = 11 (2¹⁰ = 1024 < 1131, 2¹¹ = 2048 ≥ 1131) → **n = 12**.

```
y (12 bits)  = 0100 0110 1011
invert       = 1011 1001 0100
+1           = 1011 1001 0101
```

**Answer: −y = `101110010101`** (= 0xB95; check: 4096 − 1131 = 2965 ✓)

> **Grader note.** −y was computed in 11 bits, but 11-bit 2's complement only
> spans −1024…1023, so −1131 **does not fit** — that is why an extra bit is
> required. The key skill here: negating an *unsigned* number may need **one
> more bit than the original** (and even more if the magnitude exceeds the
> signed range of the original width).

---

## Question 2 — Combinational Logic and CMOS (12 marks)

**Circuit:** XOR(x₀,x₁) and XOR(x₂,x₃) feed an AND; that AND, plus the terms
x₁x₂ and x₀x₃, feed the output OR:

```
f = (x₀ ⊕ x₁)(x₂ ⊕ x₃) + x₁x₂ + x₀x₃
```

Minterms: (x₀⊕x₁)(x₂⊕x₃) → {5,6,9,10}; x₁x₂ → {6,7,14,15}; x₀x₃ → {9,11,13,15}.
So **f = Σm(5,6,7,9,10,11,13,14,15)**.

### (a) K-map of f(x₃,x₂,x₁,x₀)

```
              x₁x₀
x₃x₂     00    01    11    10
  00  |  0     0     0     0
  01  |  0     1     1     1      ← note: m6 (row 01, col 10) is 1
  11  |  0     1     1     1
  10  |  0     1     1     1
```

> **Grader note.** The marked mistake was the cell **m6 = x₃x̄₂x₁x̄₀** (row 01,
> column 10): it must be **1** (for 0110: x₃x₂ = 01 ≠ 00 and x₁x₀ = 10 ≠ 00,
> so both sums are non-zero → f = 1).

### (b) Minimal SoP

Four essential quads (each covers a minterm no other quad can):

| Quad | Cells | Minterm only it covers |
|---|---|---|
| x₂x₀ | 5,7,13,15 | m5 |
| x₁x₂ | 6,7,14,15 | m6 |
| x₀x₃ | 9,11,13,15 | m9 |
| x₁x₃ | 10,11,14,15 | m10 |

```
f = x₂x₀ + x₁x₂ + x₀x₃ + x₁x₃
```

### (c) Minimal PoS

Group the **0s** instead. The 0s are exactly: row x₃x₂ = 00 (whole row) and
column x₁x₀ = 00 (whole column) → only two sum terms:

```
f = (x₃ + x₂)(x₁ + x₀)
```

Sanity check — expanding gives exactly the SoP above:
(x₃ + x₂)(x₁ + x₀) = x₁x₃ + x₁x₂ + x₀x₃ + x₀x₂ ✓

> **Grader note.** The submitted answer tacked an extra (incorrect) factor
> onto (x₃+x₂)(x₁+x₀) — a third factor that wasn't even a sum term. The PoS
> is just those **two** factors. Notice the PoS (2 sums, 4 literals) is much
> cheaper than the SoP (4 products, 8 literals) — always minimize both ways.

### (d) 2-input NOR-only implementation (as few gates as possible)

Start from the PoS — NOR gates naturally build product-of-sums:

```
n1 = (x₃ + x₂)'          = NOR(x₃, x₂)
n2 = (x₁ + x₀)'          = NOR(x₁, x₀)
f  = (n1 + n2)'          = NOR(n1, n2) = (x₃+x₂)(x₁+x₀) ✓
```

**Answer: 3 NOR gates.** (Two NORs form the complemented sums, the third
NORs them together; by De Morgan ((x₃+x₂)' + (x₁+x₀)')' = (x₃+x₂)(x₁+x₀).)

> **Grader note.** The submitted attempt (0/2) tried to build the SoP with
> NORs, which needs many inversions and never reduced. Lesson: **NOR ↔ PoS,
> NAND ↔ SoP.** Pick the form that matches the gate.

### (e) Minimal-transistor CMOS implementation

A CMOS complex gate outputs the **complement of its pull-down conduction
function**: `out = (PDN)'`. So to get **f** at the output, the nMOS pull-down
network must implement **f̄** in SoP form — then `out = (f̄)' = f`, with **no
inverter required**. Get f̄ from the PoS by one De Morgan step:

```
f̄ = [(x₃+x₂)(x₁+x₀)]' = x̄₃x̄₂ + x̄₁x̄₀
```

**Pull-down network (nMOS)** — f̄'s SoP (series = AND, parallel = OR):

```
   out ──┬──[x̄₃]──[x̄₂]──┬── GND        (branch 1: x̄₃ series x̄₂)
         └──[x̄₁]──[x̄₀]──┘              (branch 2: x̄₁ series x̄₀)
```

**Pull-up network (pMOS)** — the dual (same literals, series ↔ parallel):

```
   VDD ──┬──[x̄₃]──┬──+──┬──[x̄₁]──┬── out
         └──[x̄₂]──┘  └──┴──[x̄₀]──┘
```

i.e. (x̄₃ ∥ x̄₂) in series with (x̄₁ ∥ x̄₀). The output is **f** directly.

**Total: 4 nMOS + 4 pMOS = 8 transistors** (complemented inputs x̄ᵢ are given
for free per the question).

**Why this is minimal.** The alternative route — SoP of f in the pull-down —
uses 8 literals (16 transistors) and only produces f̄, needing an inverter on
top (18 total). The PoS route uses 4 literals and produces f in one gate.
**Rule: count literals both ways; implement whichever of f / f̄ is cheaper in
the pull-down, taking the output polarity that comes with it.**

> **Grader note.** "Incorrect output −2": the drawn network did not produce f
> at its output (it was also built from a 3-term expression missing x₀x₃).
> Remember: a bare CMOS gate outputs the complement of its pull-down function,
> so putting f̄ in the pull-down gives f out directly — no inverter stage.

---

## Question 3 — Multiplexer Logic (8 marks)

f = 1 iff A < B, with A = a₁a₀, B = b₁b₀ (2-bit unsigned). f = Σm(1,2,3,6,7,11)
in variables (a₁,a₀,b₁,b₀).

| A | f = 1 when | simplified |
|---|---|---|
| 00 | B ≥ 1 | b₁ + b₀ |
| 01 | B ≥ 2 | b₁ |
| 10 | B = 3 | b₁b₀ |
| 11 | never | 0 |

| B | f = 1 when | simplified |
|---|---|---|
| 00 | never | 0 |
| 01 | A = 0 | ā₁ā₀ |
| 10 | A ≤ 1 | ā₁ |
| 11 | A ≤ 2 | ā₁ + ā₀ = (a₁a₀)' |

### (a) 4-to-1 MUX, select lines a₁a₀

```
I0 (a₁a₀=00) = b₁ + b₀     (OR gate)
I1 (a₁a₀=01) = b₁          (wire)
I2 (a₁a₀=10) = b₁ · b₀     (AND gate)
I3 (a₁a₀=11) = 0           (constant)
```

> **Grader note.** "Input 00 incorrect −0.5": I0 was drawn as a **NOR**. With
> A = 0, f = 1 for B = 1, 2, 3 — the only 0 case is B = 0, so I0 = b₁ + b₀
> (OR), not (b₁ + b₀)'.

### (b) 4-to-1 MUX, select lines b₁b₀

```
I0 (b₁b₀=00) = 0                 (constant)
I1 (b₁b₀=01) = ā₁ā₀ = (a₁+a₀)'   (NOR gate)
I2 (b₁b₀=10) = ā₁                (inverter)
I3 (b₁b₀=11) = ā₁ + ā₀ = (a₁a₀)' (NAND gate)
```

> **Explanation.** Read each cofactor off the truth table: for B = 2, f = 1
> for A = 0 or 1, i.e. whenever a₁ = 0 → ā₁. For B = 3, f fails only for
> A = 3 → (a₁a₀)'.

### (c) 2-to-1 MUXes only (no gates)

Shannon expansion f = ā₁·f(a₁=0) + a₁·f(a₁=1), then expand each cofactor on a₀:

```
MX1: sel = b₀ → in0 = b₁, in1 = 1        gives  b₁ + b₀
MX2: sel = b₁ → in0 = 0,  in1 = b₀       gives  b₁ · b₀
MX3: sel = a₀ → in0 = (b₁+b₀), in1 = b₁  gives  f when a₁ = 0
MX4: sel = a₀ → in0 = (b₁b₀),  in1 = 0   gives  f when a₁ = 1
MX5: sel = a₁ → in0 = MX3, in1 = MX4     gives  f
```

**Answer: 5 two-to-one MUXes.** Any mux used as a "gate" counts: OR =
mux(sel=b, in0=a, in1=1), AND = mux(sel=b, in0=0, in1=a).

---

## Question 4 — Adders and Timing Analysis (16 marks)

Given: t_XOR = 1.0 ns, t_MUX = 2.0 ns (any input → output), FF parameters
t_su = 0.5 ns, t_h = 0.25 ns, t_cQ = 1.5 ns (single values, no min/max range).

Each bit: pᵢ = aᵢ ⊕ bᵢ; carry mux: cᵢ₊₁ = pᵢ ? cᵢ : aᵢ; sum: sᵢ = pᵢ ⊕ cᵢ.

### (a) Longest propagation path

Candidates to c₄:
- a₀ (or b₀) → XOR₁ → mux1 → mux2 → mux3 → mux4 → c₄: 1 + 2·4 = **9 ns**
- c₀ → 4 muxes → c₄: 8 ns
- a₀ → XOR → 3 muxes → XOR → s₃: 1 + 6 + 1 = 8 ns

**Answer: 9 ns — the path from a₀ (or b₀) through the first XOR and all four
carry muxes to c₄.**

> **Grader note.** "Path delay incorrect −1": the answer 8 ns forgot the
> initial **XOR** — the carry chain can't start moving until p₀ = a₀ ⊕ b₀ is
> valid, so the longest path *from an input* includes that 1 ns.

### (b) Minimum clock period, Δ = 0

Registers now sit on all inputs and outputs, so this is a standard
setup-time calculation on the longest register-to-register path:

```
T_min = t_cQ + t_comb(max) + t_su = 1.5 + 9 + 0.5 = 11 ns
```

**Answer: T_min = 11 ns.**

> **Grader note.** Used 8 ns → got 10 ns. Same missing-XOR issue as (a).

### (c) Δ = −2 ns (c₄ flip-flop's clock arrives **2 ns earlier**)

This is negative clock skew at the *capturing* flop. The capture edge happens
2 ns sooner, so the data has 2 ns *less* time — the period must grow by 2 ns:

```
T ≥ t_cQ + t_comb(max) + t_su − Δ = 1.5 + 9 + 0.5 − (−2) = 13 ns
```

(With t_skew = t_capture − t_launch = Δ = −2: T_min = t_cQ + t_comb + t_su − t_skew.)

**Answer: T_min = 13 ns.**

> **Grader note.** Two problems: the 8 ns path again, and the sign of Δ.
> **Negative skew at the capture flop hurts setup** (capture edge earlier →
> tighter budget) — Δ must *increase* T_min: 11 + 2 = 13 ns.

### (d) Hold-time check at the c₄ flip-flop, Δ = −2 ns

Hold constraint: the **earliest** new data at the capture flop's D must arrive
no sooner than t_h *after the capture edge*:

```
t_cQ + t_comb(min) ≥ t_h + Δ
```

Shortest path into the c₄ flop: a₃ (or b₃) flop → mux4 data input → D
(valid when p₃ = 0, i.e. carry = a₃): t_comb(min) = t_MUX = 2 ns.

```
LHS = 1.5 + 2 = 3.5 ns
RHS = 0.25 + (−2) = −1.75 ns
3.5 ≥ −1.75  →  NO hold-time violation
```

**Answer: no violation.** Intuition: the capture clock arriving *early* makes
hold *easier* (the old data only needs to survive until −1.75 ns relative to
the launch edge; the earliest any new data can possibly show up is +3.5 ns).
Skew hurts setup and helps hold, or vice versa — never both.

### (e) 4-bit carry-bypass adder (CBA) — longest path

The block adds: a 3-AND chain computing block-propagate P = p₀p₁p₂p₃ (AND =
1 ns), and a bypass mux (mux5) giving c₄ = P ? c₀ : (rippled carry).

Candidates:
- a₀/b₀ → XOR → mux1 → mux2 → mux3 → mux4 → mux5 → c₄: 1 + 5·2 = **11 ns**
- c₀ → mux1…mux5: 10 ns
- a₀ → XOR → 3 ANDs → mux5: 1 + 3 + 2 = 6 ns
- a₀ → XOR → 3 muxes → XOR → s₃: 8 ns

**Answer: 11 ns — a₀/b₀ through the first XOR, the four ripple-carry muxes,
and the bypass mux, to c₄.**

> **Grader note.** The answer 10 ns (5 muxes only) again dropped the leading
> XOR. The AND-chain path is *shorter* (6 ns) — that's the point of the
> bypass: the select logic is ready long before the carry would ripple.

### (f) 8-bit adder = two CBA blocks

**Part 1 — c₈: 0 → 1.** Previously A = B = 0, c₀ = 0. At t = 0 the inputs
become A = 01010101, B = 10101010, c₀ = 1. Every bit has aᵢ ⊕ bᵢ = 1 → all
propagates are 1 → both blocks bypass.

```
t = 1 ns:  pᵢ = 1 (XORs)
t = 4 ns:  P₁, P₂ = 1 (3-AND chains, in parallel in both blocks)
t = 6 ns:  c₄ = c₀ through bypass mux of block 1 (mux ready at 4, +2 ns)
t = 8 ns:  c₈ = c₄ through bypass mux of block 2
```

(The internal ripple would deliver c₄ at 8 ns and c₈ even later — bypass wins.)

**Answer: 8 ns.** (Correct on the exam ✓)

**Part 2 — c₈: 1 → 0.** Inputs return to A = B = 0, c₀ = 0 at t = 0.
Previously all pᵢ = 1, P₁ = P₂ = 1, so both bypass muxes currently pass c₀/c₄.

```
t = 0:  c₀ → 0 (bypasses still selected: P₁, P₂ still 1)
t = 2:  c₄ = c₀ = 0 through block-1 bypass mux
t = 4:  c₈ = c₄ = 0 through block-2 bypass mux
        (meanwhile pᵢ → 0 at t = 1, P → 0 at t = 4, but the internal
         carries are also all 0, so c₈ just stays 0)
```

**Answer: 4 ns.**

> **Grader note.** "Path/delay incorrect": answering 8 ns assumed the bypass
> *select* had to be re-evaluated first. It doesn't — the selects are **still
> 1** from the previous inputs, so c₀ = 0 shoots straight through two muxes.
> The AND chain only matters when a bypass must *turn on*, not when the input
> carry itself falls.

---

## Question 5 — Finite State Machines (13 marks)

### (a) State-assigned table from the FSM circuit

From the circuit: Y₁ = w (bottom FF), Y₀ = (y₁ ⊕ w)′ = **y₁ XNOR w** (top FF),
z = ȳ₀.

| Present y₁y₀ | Next, w = 0 | Next, w = 1 | z |
|---|---|---|---|
| 00 | 01 | 10 | 1 |
| 01 | 01 | 10 | 0 |
| 10 | 00 | 11 | 1 |
| 11 | 00 | 11 | 0 |

> **Method.** For each present state and each w, evaluate the D-input
> expressions: Y₁ = w directly; Y₀ = 1 whenever y₁ = w (XNOR). z depends only
> on the present y₀ (Moore output through the inverter). (4/4 on the exam ✓)

### (b) One-hot implementation

Assignment: A = 0001 (y₀), B = 0010 (y₁), C = 0100 (y₂), D = 1000 (y₃).
Transitions: A→B (w=0), A→C (w=1); B→B (w=0), B→D (w=1); C→A (w=0), C→D (w=1);
D→A (w=0), D→D (w=1). One-hot rule: each next-state variable is the OR of
"(source state) · (transition condition)" over all arrows **entering** that state:

```
Y₀ = w̄·y₂ + w̄·y₃          (enter A from C or D on w = 0)
Y₁ = w̄·y₀ + w̄·y₁          (enter B from A on w = 0; B self-loop on w = 0)
Y₂ = w·y₀                  (enter C from A on w = 1)
Y₃ = w·y₁ + w·y₂ + w·y₃    (enter D from B, C on w = 1; D self-loop on w = 1)
z  = y₁ + y₃               (z = 1 in states B and D — Moore, no w!)
```

Reset is **not** part of these expressions: Resetn drives the asynchronous
**Set** of the y₀ flop and the **Reset** of y₁, y₂, y₃ (giving 0001).

> **Grader note.** Two errors: (1) "+ Resetn" was added into Y₀ — the reset
> goes to the flip-flops' set/clear pins, never into the next-state logic;
> (2) z was written as wy₃ + w̄y₁ — but this is a **Moore** machine (state
> labels A/0, B/1 …), so z depends only on the state: z = y₁ + y₃.

### (c) Checking the ModelSim simulation (encoding A=00, B=01, C=10, D=11)

**Method:** at every rising clock edge, note (current state, w), compute the
expected next state and z from the state diagram, and compare with what the
waveform does one cycle later. Expected behavior:

| State | w = 0 | w = 1 | z |
|---|---|---|---|
| A (00) | → 01 | → 10 | 0 |
| B (01) | → 01 | → 11 | 1 |
| C (10) | → 00 | → 11 | 0 |
| D (11) | → 00 | → 11 | 1 |

**Answers:**
- **A: no error** — reset enters 00, and A's exits (to 01 on w = 0) are correct.
- **B: no error** — B holds on w = 0 and exits correctly.
- **C: error** — while in C (10) with **w = 0**, the next state must be
  **A (00)**, but the simulation does not go to 00 (the state instead
  advances toward 11 as if w were 1).
- **D: error** — while in D (11) with **w = 1**, the FSM should **remain in
  D** (self-loop), but the simulation shows the state leaving D (dropping to
  00). The self-loop on w = 1 is broken.

> **Grader note.** "State D answer incorrect": answering "no error" for D
> missed the broken w = 1 self-loop. When verifying, check **every** transition
> out of **every** state, not just the ones that look plausible at a glance.

---

## Question 6 — Verilog Analysis (9 marks)

The code: a 25-bit down-counter loaded with 25 000 000; it pulses `ena` for one
cycle when `count == 0` and reloads; a second always block asynchronously
resets LEDR to `10'b0000000001` and, when `ena = 1`, rotates LEDR left by one
(`LEDR <= {LEDR[8:0], LEDR[9]}`).

### (a) Block diagram

```
                 KEY[0] (active-low ASYNC reset)
                  │                │
CLOCK_50 ──┬─────►ck              ▼ck
           │  ┌────────────────┐  ┌──────────────────────────┐
           └─►│ 25-bit down-   │  │ 10-bit rotate-left       │
              │ counter, sync  │  │ register (Q₉ feeds D₀),  │
              │ parallel load  │  │ async load 10'b0000000001│
              │ of 25'd25000000│  │ on reset                 │
              │ (on reset OR   │  │                          │
              │  count == 0)   │  │        ena (enable)      │
              └──────┬─────────┘  └───────▲──────────┬───────┘
                     │ count[24:0]        │          │
                     ▼                    │          ▼
              ┌─────────────┐   ena ──────┘      LEDR[9:0]
              │ count == 0? │──► ena
              └─────────────┘
```

Essential details: the counter's **parallel-load value 25'd25000000**, the
**comparator** producing `ena`, the rotator's **async load of 10'b…0001**, and
`ena` as the rotator's enable.

> **Grader note.** Marks were lost for omitting the counter's parallel load
> of 25 000 000 and the rotator's reset value 10'b0000000001 — these constants
> are part of the circuit's function and must appear in the diagram.

### (b) Behaviour in words

A **single lit LED rotates left across LEDR[9:0], advancing one position every
0.5 s**, wrapping from LEDR[9] back to LEDR[0]. The 50 MHz clock means
25 000 000 cycles = 25 000 000 / 50 000 000 = **0.5 s** between `ena` pulses.
Pressing KEY[0] asynchronously resets the display to only LEDR[0] lit and
reloads the counter.

> **Grader note.** "Missing/wrong timing description": the shift does **not**
> happen every clock cycle — `ena` is high only one cycle out of 25 000 000,
> so the visible rotation rate is one step per 0.5 s (2 steps per second).

---

## Question 7 — Configurable Aspect-Ratio RAM (10 marks)

Two 512×8 RAMs → one RAM that is **1024×8 when mode = 0**, **512×16 when mode = 1**.

**Connections:**

| Signal | RAM₀ (low)           | RAM₁ (high)                                                      |
| ------ | -------------------- | ---------------------------------------------------------------- |
| Addr   | Addr[8:0]            | Addr[8:0]                                                        |
| clock  | clock                | clock                                                            |
| DataIn | DataIn[7:0]          | **mux(sel = mode)**: mode=0 → DataIn[7:0], mode=1 → DataIn[15:8] |
| WE     | WE·(mode + Āddr[9]) | WE·(mode + Addr[9])                                              |

**Outputs:**

```
DataOut[7:0]  = mux(sel = m̄ode·Addr[9]): 0 → RAM₀ out, 1 → RAM₁ out
DataOut[15:8] = RAM₁ out        (only meaningful in mode 1)
```

**Why it works.**
- **mode = 1 (512×16):** both write-enables reduce to WE (both RAMs always
  written together), RAM₀ holds the low byte, RAM₁ the high byte; output is
  simply {RAM₁, RAM₀}. Addr[9] is unused, as specified.
- **mode = 0 (1024×8):** WE₀ = WE·Āddr[9], WE₁ = WE·Addr[9], so Addr[9] acts
  as a chip-select — exactly one RAM is written. The output mux, selected by
  Addr[9] (mode = 0), picks the same RAM's read data; both RAMs receive
  DataIn[7:0] since either could be the target.

> **Grader note.** The lost marks were exactly the WE gating. The one-liner to
> remember: **WE₀ = WE·(mode + Ā₉)** and **WE₁ = WE·(mode + A₉)** — "always
> write both in 16-bit mode; write only the selected bank in 8-bit mode."

---

## Question 8 — Counters and Counter Circuits (10 marks)

### (a) 33% duty cycle, period = 6× clock, from a 3-bit counter with synchronous active-low resetn

Need 6 states with z high for 2 of them. Let the counter run 000→001→…→101 and
then synchronously reset:

```
resetn = (Q₂ · Q̄₁ · Q₀)'      (decode state 5 = 101)
z      = Q₂                    (high in states 100 and 101)
```

Sequence: 0,1,2,3,4,5, 0,… — 6 states → z's period = 6·T_clk; z = 1 for
2 of the 6 cycles → duty = 2/6 = 33%.

> **Grader note.** "Incorrect period (reset formulation)": resetting on the
> 3rd cycle gives a period of 3·T_clk. Because the reset is **synchronous**,
> the state in which resetn = 0 is still counted as a full cycle — so decode
> state **5** (not 2) to get six states 0–5. Taking z = Q₂ then gives exactly
> two high cycles per period.

### (b) 5-bit LFSR in Verilog

From the figure: data shifts Q₄→Q₃→Q₂→Q₁→Q₀, and the new bit entering Q₄ is
**XNOR(Q₀, Q₂)**. Reset is **asynchronous, active-low**, loading 00001.

```verilog
module LFSR(clock, Q, resetn);
    input clock, resetn;
    output reg [4:0] Q;

    always @(posedge clock, negedge resetn)   // async active-low reset
    begin
        if (!resetn)
            Q <= 5'b00001;
        else begin
            Q[0] <= Q[1];
            Q[1] <= Q[2];
            Q[2] <= Q[3];
            Q[3] <= Q[4];
            Q[4] <= ~(Q[0] ^ Q[2]);   // XNOR feedback taps: Q0 and Q2
        end
    end
endmodule
```

> **Grader note.** "Always expression incorrect or missing −1": the sensitivity
> list was `always @(posedge clock)` only. An **asynchronous** reset must
> appear in the sensitivity list — `negedge resetn` — otherwise the reset only
> takes effect on a clock edge (that's a *synchronous* reset, different
> hardware). Note: an XNOR-feedback LFSR locks up in the all-ones state, which
> is why resetting to 00001 (not 11111) matters.

---

## Score / error summary (from the graded copy)

| Q | Score | Main issues flagged |
|---|---|---|
| 1 | 4/8 | −y needs 12 bits; bit-width/range checks |
| 2 | 7/12 | K-map cell m6; extra PoS factor; NOR-only design (0/2); CMOS network must put f̄ in the pull-down so the gate outputs f directly (8 transistors) |
| 3 | 7.5/8 | I0 should be OR, not NOR |
| 4 | 8/16 | longest path = 9 ns (include XOR); T_min = 11 ns, 13 ns with skew; CBA longest = 11 ns; c₈ falls in 4 ns |
| 5 | 10/13 | Resetn ∉ next-state logic; z = y₁ + y₃ (Moore); state D has an error (w = 1 self-loop broken) |
| 6 | 4.5/9 | show the 25 M parallel load and 10'b…01 reset; rotation every 0.5 s, not every cycle |
| 7 | 8/10 | WE₀ = WE·(mode + Ā₉), WE₁ = WE·(mode + A₉) |
| 8 | 7/10 | decode state 5 (synchronous reset) for period 6; add `negedge resetn` to sensitivity list |
| **Total** | **56/86 (65.1%)** | |
