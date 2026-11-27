# Priority A — Complete Teaching Guide
### Digital Logic · Computer Architecture · SystemVerilog · Verification Methodology

> This is a self-contained teaching document covering everything in **Priority A** from your Tenstorrent DV-intern prep. It is written to *teach*, not just to list — each topic explains **what it is**, **why it matters**, **how it works**, and **how to answer it in an interview**.

---

# PART 1 — DIGITAL LOGIC DESIGN

---

## 1.1 Combinational vs. Sequential Logic

### What it is
- **Combinational logic**: output depends *only* on current inputs. No memory. Examples: AND/OR/NOT gates, adders, muxes, decoders, ALUs.
- **Sequential logic**: output depends on current inputs *and* past state (it has memory). Examples: flip-flops, registers, counters, FSMs, FIFOs.

### The key mental model
Sequential logic = **combinational logic + storage (flip-flops) + a clock**. A register "captures" the output of combinational logic on a clock edge and holds it stable until the next edge.

```
inputs ──► [combinational logic] ──► [flip-flops] ──► outputs
                 ▲                        │
                 └─────── feedback ◄──────┘
```

### Why verification cares
- Combinational logic is verified by checking the **function** (truth table / input-output relation).
- Sequential logic is verified by checking the **behavior over time** — sequences of cycles, state transitions, and timing. Almost all real bugs are in sequential behavior (state machines, handshakes, FIFOs).

### Interview answer pattern
> "Combinational logic has no state — output is a pure function of inputs. Sequential logic stores state in flip-flops clocked by an edge. A sequential circuit is a cycle: combinational logic between registers, with the clock defining the time boundary."

---

## 1.2 Blocking vs. Non-blocking Assignments (Verilog)

### The rule (and why it exists)
- **`=` (blocking)**: executes immediately, in order, like a normal programming language. Used inside **combinational** logic.
- **`<=` (non-blocking)**: schedules the assignment to happen *at the end of the time step*, all simultaneously. Used inside **sequential** (`always_ff`) logic.

### The classic race example

**Wrong** (uses blocking in sequential logic):
```systemverilog
always_ff @(posedge clk) begin
  a <= b;      // both sample the OLD value of b
  b <= a;      // correct swap — non-blocking
end
```

```systemverilog
always_ff @(posedge clk) begin
  a = b;       // blocking: a gets OLD b
  b = a;       // blocking: b now gets NEW a — NOT a swap!
end
```

The non-blocking version correctly **swaps** `a` and `b` (both read the old values and update simultaneously). The blocking version does *not* swap — it copies `b` into both.

### The deeper reason
- Blocking assignments in a clocked block model **sequential execution**, which depends on statement order and creates **races** between processes.
- Non-blocking assignments model the physical reality of **flip-flops**: all flops capture their D-inputs simultaneously at the clock edge. Order of statements doesn't matter.

### Rules of thumb (memorize)
1. **Combinational** (`always_comb`): use `=` only.
2. **Sequential** (`always_ff`): use `<=` only.
3. **Never mix** blocking and non-blocking in the same block.
4. Never use `<=` in combinational logic (may synthesize to unintended latches/races).

### How you get a race (interview favorite)
Two `always` blocks, one reads a signal while another writes it using blocking assignment in the same time step → the result depends on **simulator scheduling order** (which block runs first). This is nondeterministic and is the source of flaky, seed-dependent simulation.

### Answer pattern
> "Blocking assignments execute immediately in source order, so I use them for combinational logic. Non-blocking assignments schedule all RHS evaluations first and assign at the end of the timestep, which models flip-flops capturing simultaneously — so I use them for sequential logic. Mixing them or using blocking in clocked blocks creates races where results depend on execution order."

---

## 1.3 Latches vs. Flip-Flops

### Definitions
- **Flip-flop (FF)**: edge-triggered. Captures D only at a clock edge. Level of the data doesn't matter between edges.
- **Latch**: level-sensitive. Transparent while enable/clock is high (or low); "freezes" when enable deasserts.

| | Flip-flop | Latch |
|---|---|---|
| Trigger | Clock **edge** | Enable **level** |
| Timing | Setup/hold around edge | Data stable while transparent |
| Synthesis | From `always_ff @(posedge clk)` | From incomplete `always` |
| Use | Standard storage | Time borrowing, low-power, clock gating internals |
| Verification | Simpler | Harder (transparency, timing) |

### Latch inference (classic bug)
A latch is inferred when a combinational `always` block **does not assign every output in every branch** — the signal must "remember" its value, so synthesis inserts a latch.

```systemverilog
// BUG: infers a latch because y is not assigned in the else branch
always_comb begin
  if (en) y = a;   // what is y when en == 0? -> latch!
end
```

```systemverilog
// FIX: give every output a default assignment
always_comb begin
  y = 0;           // default
  if (en) y = a;
end
```

**How to avoid**: assign every output in every branch (or give a default at the top), use `always_comb` (which tools check), and use `case` with a `default`.

### Interview answer
> "A flip-flop samples on a clock edge; a latch is transparent while its enable is asserted. Latches are usually accidental — caused by an incomplete `always` block where an output isn't assigned in some branch. I avoid them by assigning every output in every branch and using `always_comb`, which tools can lint."

---

## 1.4 Timing: Setup/Hold, Clock-to-Q, Metastability

### The three timing parameters
- **Setup time (t_su)**: the data input must be **stable for a window before** the clock edge.
- **Hold time (t_h)**: the data input must remain **stable for a window after** the clock edge.
- **Clock-to-Q (t_cq / t_co)**: the delay from the clock edge until the output is valid.

### Why they exist
A flip-flop's internal storage (a pair of cross-coupled gates) needs time to capture the data reliably. If data changes inside the setup/hold window, the flop may capture neither a clean 0 nor a clean 1.

### Timing violation → metastability
- **Metastability**: a flop output sits at an **illegal intermediate voltage** (neither valid 0 nor 1) and may eventually resolve to either value, **unpredictably**, after an unbounded time.
- It is *not* a logic bug you can simulate away — it's a physical phenomenon. The output resolution time is probabilistic.

### How to fix timing (setup violation)
1. **Pipeline** the path (insert registers to shorten the combinational path).
2. **Retime** (move registers across logic).
3. **Reduce** logic depth / use faster cells.
4. **Relax the constraint** (only if allowed — rarely acceptable).
5. Balance the clock tree / reduce skew.

### Metastability resolution: the synchronizer
A **2-flop (or N-flop) synchronizer** gives a metastable output time to resolve before it's used:

```
async_signal ──► [FF1] ──► [FF2] ──► safe_signal
                  ▲          ▲
                  │clk       │clk
```

- FF1 may go metastable, but FF2 samples it a **full clock period later**, by which time FF1 has (with high probability) resolved.
- Each extra flop reduces the **MTBF** (mean time between failures) exponentially.
- **Key interview point**: a synchronizer **reduces probability** of failure — it does **not** guarantee correctness. And it only works for **single-bit** signals (multi-bit buses need a handshake or async FIFO — see CDC below).

### Answer pattern
> "Setup time is the window before the clock edge where data must be stable; hold time is the window after. Violating them can drive a flop metastable — output stuck at an invalid voltage that resolves unpredictably. I fix setup violations by pipelining or reducing logic depth, and I contain metastability with a two-flop synchronizer, understanding it reduces probability rather than guarantees correctness."

---

## 1.5 Clock Domain Crossing (CDC) Basics

### The problem
A signal generated in one clock domain (`clk_a`) is sampled in another (`clk_b`). Since the two clocks have **no fixed phase relationship**, the signal can change inside the destination flop's setup/hold window → metastability.

### The solutions (by signal type)

**Single-bit, slow (level) signal** → **2-flop synchronizer**.

**Single-bit, fast pulse** → the pulse may be missed. Use:
- A **pulse stretcher** (widen the pulse to ≥ 2 destination clocks), or
- A **toggle/handshake synchronizer** (convert pulse → level change, synchronize, convert back).

**Multi-bit bus** → **never** synchronize each bit independently (bits may resolve on different cycles → corrupted value). Instead use:
- **Handshake** (req/ack with the data held stable), or
- **Asynchronous FIFO** (Gray-coded pointers — see FIFO section).

### The Gray code connection
Gray code changes **only one bit per increment**, so even if a pointer is sampled slightly early/late, it can only be off by one count — safe for FIFO full/empty. This is *why* async FIFOs use Gray-coded pointers.

### Interview answer
> "CDC is dangerous because a signal from an unrelated clock can change during the destination's setup/hold window, causing metastability. For single-bit signals I use a two-flop synchronizer; for multi-bit data I use a handshake or an async FIFO with Gray-coded pointers, because synchronizing each bit separately can produce inconsistent values."

---

## 1.6 FSM Design (Moore vs. Mealy)

### Definitions
- **Moore machine**: outputs depend **only on the current state**.
- **Mealy machine**: outputs depend on **current state AND current inputs**.

### Comparison

| | Moore | Mealy |
|---|---|---|
| Outputs | State only | State + inputs |
| Output timing | Changes at clock edge (registered) | Can change with input (combinational) |
| States needed | Usually more | Usually fewer |
| Output glitches | No (registered) | Possible (combinational path from input) |
| Verification | Cleaner (output is pure state) | Slightly harder (input-dependent) |
| Latency | Output appears one cycle later | Output can respond within the same cycle |

### Example: 2-bit sequence detector (detect "101", overlapping)
- **Mealy**: 3 states (seen "", "1", "10"). On state "10" + input 1 → output 1 *immediately*.
- **Moore**: 4 states (add a "101" state). Output asserted in the "101" state → one cycle later.

### State encoding
- **Binary**: minimal flip-flops (log₂N), but output decode needs more logic and can glitch.
- **One-hot**: N flip-flops, one bit per state. More flops, but simple decode, fast, glitch-free, easy to add/remove states. Best for FPGAs and verification clarity.
- **Gray**: adjacent states differ by one bit → fewer transitions → lower power.
- **Trade-off**: one-hot = area + speed + simplicity; binary = area-efficient but slower decode.

### FSM coding pattern (two- or three-process style)
```systemverilog
// Three always blocks: state reg, next-state logic, output logic
typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;
state_t state, nxt;

always_ff @(posedge clk or negedge rst_n)
  if (!rst_n) state <= IDLE;
  else        state <= nxt;

always_comb begin
  nxt = state;              // default: stay
  case (state)
    IDLE : if (start) nxt = RUN;
    RUN  : if (done)  nxt = DONE;
    DONE : nxt = IDLE;
  endcase
end

always_comb begin
  out = 1'b0;               // default
  case (state)
    DONE : out = 1'b1;      // Moore: output from state only
  endcase
end
```

### Answer pattern
> "Moore outputs depend only on state, so they're glitch-free and change at the clock edge; Mealy outputs also depend on inputs, so they can respond faster but can glitch. For encoding I default to one-hot for clarity and speed, understanding it costs more flip-flops, while binary minimizes flops but needs more decode logic."

---

## 1.7 Counters, Shift Registers, Arbitration

### Counters
- **Binary up/down counter** with enable, load, reset, and a terminal-count output.
- **Gray-code counter**: used in async FIFO pointers (single-bit change).
- **LFSR (linear-feedback shift register)**: pseudo-random sequence generator — used for test patterns and scrambling.

Corner cases: **overflow** (wraps from max to 0), **underflow**, **load-enable conflict** (load and count both asserted — define priority), **reset during count**.

### Shift registers
- **SIPO / PISO / SISO / PIPO** configurations.
- **LFSR** is a shift register with XOR feedback.
- Corner case: reset, shift-enable, parallel-load priority.

### Arbitration
- **Round-robin**: grants rotate so every requester gets a fair turn (no starvation).
- **Priority (fixed)**: highest-priority requester always wins (can starve low priority).
- **Age-based**: priority increases with waiting time.

Corner cases: simultaneous requests, request deasserted before grant, a requester holding the grant for many cycles, priority inversion, starvation.

### Answer pattern
> "An arbiter grants a shared resource to one of several requesters. Round-robin rotates the grant for fairness; fixed priority is simpler but can starve. Key corner cases are simultaneous requests, a request dropping before the grant, and holding the grant too long."

---

## 1.8 FIFO Design (the #1 interview topic)

### What a FIFO is
A **first-in, first-out** buffer with a write port (`wdata`, `winc`) and a read port (`rdata`, `rinc`), plus **full/empty (and often almost-full/almost-empty)** flags. It decouples a producer and consumer that may run at different rates.

### The two-pointer model
- **Write pointer (`wptr`)** — next location to write.
- **Read pointer (`rptr`)** — next location to read.
- FIFO depth N → N entries. Pointers wrap around (modulo N).

### Full/empty — the classic ambiguity
If you use `wptr == rptr` for **both** full and empty, they are **indistinguishable** (a full FIFO and an empty FIFO both have equal pointers). Solutions:

**1. Reserved-slot (simplest, most common in interviews):**
```systemverilog
assign empty = (wptr == rptr);
assign full  = (wptr + 1 == rptr);   // one slot wasted
```
Depth N gives you N−1 usable entries. Easy to reason about, small area cost.

**2. Extra (MSB) bit / Gray-code scheme (used in async FIFOs):**
- Add one extra bit to each pointer (so wptr and rptr are (log₂N + 1) bits).
- Empty: pointers **identical** (all bits equal).
- Full: **top bit differs, lower bits equal** (pointers have wrapped a full circle apart).
- In async FIFOs, pointers are **Gray-coded** and synchronized across domains, and full/empty are compared in the respective domain.

**3. Counter-based:**
- Maintain a separate count of valid entries.
- `full = (count == N)`, `empty = (count == 0)`.
- Simple, but the count must be correct under simultaneous read+write.

### The corner cases (memorize these)
1. **Write when full** → data must not corrupt; either drop (with flag) or block.
2. **Read when empty** → output invalid data; must not advance rptr.
3. **Simultaneous read + write when empty** → count stays 0 → must remain empty. Classic bug: naively computing full/empty from raw pointers can break here.
4. **Simultaneous read + write when full** → count stays N → must remain full.
5. **Almost-full / almost-empty** thresholds (for credit-based flow control).
6. **Pointer wrap** at max depth.
7. **Reset mid-operation** — pointers and count must clear cleanly.

### The simultaneous read+write trap
If you compute full/empty with combinational logic from the pointers, the read/write occurring **in the same cycle** means the pointers are updated **at the end** of the cycle. A naive check `wptr == rptr` before the edge can misflag. The robust approaches:
- Use a **registered count** that accounts for both `winc` and `rinc` in the same cycle.
- Or use the pointer-difference scheme and check *next-state* pointers.

### Async FIFO (cross-domain)
- Write side and read side run on **different clocks**.
- Pointers are **Gray-coded** (single-bit change) and passed through **2-flop synchronizers**.
- Full is computed in the **write domain** (from synchronized rptr); empty in the **read domain** (from synchronized wptr).
- Because Gray pointers can be stale by one count, full/empty may be **conservative** (flag asserted slightly early) — which is safe.

### Verilog sketch (sync FIFO, reserved-slot)
```systemverilog
module fifo #(parameter W=8, D=16) (
  input clk, rst_n,
  input            winc, rinc,
  input  [W-1:0]   wdata,
  output [W-1:0]   rdata,
  output           full, empty
);
  localparam AW = $clog2(D);
  logic [AW-1:0] wptr, rptr;
  logic [W-1:0]  mem [0:D-1];

  assign full  = (wptr + 1 == rptr);
  assign empty = (wptr == rptr);
  assign rdata = mem[rptr];

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) wptr <= 0;
    else if (winc && !full) begin mem[wptr] <= wdata; wptr <= wptr + 1; end

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) rptr <= 0;
    else if (rinc && !empty) rptr <= rptr + 1;
endmodule
```

### Answer pattern
> "A FIFO buffers data between a producer and consumer using write and read pointers. Empty is when the pointers are equal; the trick is distinguishing full from empty. I use the reserved-slot scheme where full is `wptr+1 == rptr`, or the extra-bit/Gray-code scheme for async FIFOs. The key corner cases are writing full, reading empty, and simultaneous read+write at the boundary, plus pointer wrap."

---

## 1.9 Reset: Synchronous vs. Asynchronous

### Synchronous reset
```systemverilog
always_ff @(posedge clk)
  if (rst) q <= 0;   // reset sampled only at clock edge
else q <= d;
```
- **Pros**: clean, no metastability risk, works with any clock, easy timing.
- **Cons**: needs a running clock to reset; uses logic in the datapath (adds area/delay); can't reset a dead-clock circuit.

### Asynchronous reset
```systemverilog
always_ff @(posedge clk or posedge rst)  // or negedge rst_n
  if (rst) q <= 0;
else q <= d;
```
- **Pros**: immediate reset even without clock; can be area-efficient (flop's native async clear).
- **Cons**: **reset deassertion is asynchronous** → if it deasserts near a clock edge, some flops reset and others don't in the same cycle → **metastability**. Also glitches on the reset line can reset the design spuriously.

### The standard fix: reset synchronizer
A **reset synchronizer** deasserts the reset **synchronously** to the clock, giving you the best of both worlds: assert asynchronously, deassert synchronously.

```systemverilog
// deassert reset synchronously to clk
always_ff @(posedge clk or negedge rst_n_in)
  if (!rst_n_in) {rst_n_sync, rst_n} <= 2'b00;
  else           {rst_n_sync, rst_n} <= {1'b1, rst_n_sync};
```

### Answer pattern
> "Synchronous reset is sampled only at the clock edge — clean but it needs a running clock. Asynchronous reset works immediately, but deasserting it near a clock edge can cause some flops to come out of reset on different cycles — metastability. The common industrial solution is a reset synchronizer that asserts asynchronously and deasserts synchronously."

---

## 1.10 Clock Gating & Power Basics

### Clock gating
Stop the clock to a block when it's idle to save dynamic power (since `P_dynamic ∝ C·V²·f` and clock switching is a huge share of dynamic power).

```systemverilog
// gated clock (use the tool/library cell in real silicon)
assign gated_clk = clk & enable;   // naive; can glitch — use a latch-based cell
```

**Correct approach**: use a **latch-based clock gating cell** (an AND gate with a level-sensitive latch) so the gate signal only changes when the clock is low — no glitches. Modern tools infer these automatically from `if (en)` clock-gating styles.

### Power components
- **Dynamic power**: switching power (`C·V²·f`) + short-circuit power. Reduced by clock gating, lower voltage/frequency, less toggling.
- **Static (leakage) power**: flows even when idle; worse at smaller process nodes. Reduced by power gating (switch off supply), high-Vt cells.

### Why DV cares
- Gated clocks can **mask** transactions or create **functional bugs** if the enable is wrong.
- Verification must ensure the design works **with and without** clock gating enabled, and that no block is wrongly gated while active.

### Answer pattern
> "Dynamic power dominates and scales with capacitance, voltage squared, and frequency. Clock gating stops the clock to idle logic, which I implement with a latch-based cell to avoid glitches on the clock. Static/leakage power is addressed with power gating and high-threshold cells."

---

## 1.11 Number Systems, Two's Complement, Overflow

### Two's complement
- Positive numbers: normal binary.
- Negative number −x: **invert all bits of x, add 1** (so `-x = ~x + 1`).
- Range for N bits: **−2^(N−1) to +2^(N−1) − 1**.
- The MSB is the **sign bit**.

### Why two's complement
Addition/subtraction use the **same hardware** as unsigned. No separate sign handling. `-x` is computed by `~x + 1`.

### Overflow
- **Signed overflow** occurs when the result is outside the representable range. Detect: adding two positives gives a negative, or adding two negatives gives a positive.
- **Unsigned overflow** (carry out) occurs when the result exceeds 2^N − 1 (carry out of MSB).
- **Key distinction**: unsigned uses the **carry flag**; signed uses the **overflow flag** (carry into MSB XOR carry out of MSB).

### Sign extension vs. zero extension
- **Sign-extend** when widening a signed number (replicate the MSB).
- **Zero-extend** when widening an unsigned number.

### Answer pattern
> "Two's complement encodes negatives as `~x + 1`, which lets one adder handle both signed and unsigned. Signed overflow happens when the sign of the result is wrong — e.g., two positives summing to a negative — while unsigned overflow is just a carry out of the MSB. When widening, I sign-extend signed values and zero-extend unsigned ones."

---

# PART 2 — COMPUTER ARCHITECTURE

---

## 2.1 The 5-Stage Classic RISC Pipeline

### The five stages
1. **IF — Instruction Fetch**: read instruction from memory (PC).
2. **ID — Instruction Decode / Register Read**: decode opcode, read register operands.
3. **EX — Execute**: ALU operation or address calculation.
4. **MEM — Memory Access**: load/store to data memory.
5. **WB — Write Back**: write result to register file.

### Why pipelining works
Pipelining **overlaps** execution: while one instruction is in EX, the next is in ID, the next in IF. **Throughput** improves (ideally 1 instruction/cycle), even though **latency** per instruction stays the same. The critical path (and thus clock period) is shortened because each stage does less work.

### The three hazard classes
- **Structural hazards**: two instructions need the **same hardware** in the same cycle (e.g., single memory for both instructions and data → the classic "von Neumann bottleneck"). Fixed by **separating** instruction and data caches/memories, or duplicating hardware.
- **Data hazards**: an instruction needs a value **not yet written** by an earlier instruction. Fixed by **forwarding** (bypassing) and **stalls**.
- **Control hazards**: a **branch** changes the PC, but the pipeline has already fetched subsequent instructions. Fixed by **prediction**, **stall/flush**, or **delayed branches**.

### Data hazards and forwarding
```
add x1, x2, x3     // writes x1
sub x4, x1, x5     // reads x1 — RAW hazard
```
- **RAW** (read-after-write) is the real hazard.
- **Forwarding (bypass)**: route the ALU result directly to the next instruction's input, skipping the register-file write-back.
- If the producing instruction's result is only available after MEM (e.g., a load), a **load-use hazard** needs a **one-cycle stall (bubble)** even with forwarding.

Other hazard types (for completeness): **WAR** and **WAW** — only matter in out-of-order machines (see 2.2).

### Control hazards and branches
On a taken branch, the pipeline has already fetched wrong-path instructions. Options:
- **Stall** until the branch is resolved (simple, slow).
- **Predict** not-taken (or predict taken), and **flush** on mispredict.
- **Delayed branch** (compiler fills the branch-delay slot).

### Interview answer
> "A 5-stage RISC pipeline is IF/ID/EX/MEM/WB. It overlaps instruction execution to improve throughput while the critical path shortens. The hazards are structural (resource conflict), data (RAW — fixed by forwarding, with a stall for load-use), and control (branches — fixed by prediction plus a flush on mispredict)."

---

## 2.2 Out-of-Order Execution, ROB, Renaming, Speculation

### Why OoO
In-order machines **stall the whole pipeline** when one instruction waits (e.g., a cache miss). Out-of-order execution lets **independent later instructions proceed**, hiding latency and improving ILP (instruction-level parallelism).

### The key structures
- **Reorder Buffer (ROB)**: a circular buffer that tracks instructions **in program order** and lets them **complete (retire) in order**. It holds results until commit. It enables precise exceptions and speculative recovery.
- **Reservation stations**: hold instructions waiting for operands; when an operand becomes ready, the instruction can issue to a functional unit **out of order**.
- **Physical register file / register renaming**: eliminates **false dependencies** (WAR and WAW) by mapping architectural registers to a larger pool of physical registers. Each new write gets a fresh physical register.
- **Load/store queue**: tracks in-flight memory ops, preserves memory ordering, and detects memory hazards.

### Register renaming (the key concept)
```
r1 = r2 + r3
r1 = r4 + r5     // WAR/WAW on r1 — but these are DIFFERENT logical values
r6 = r1 + r7
```
Renaming gives each `r1` write a **different physical register** (p1, p2), so the two adds don't have to serialize. The second add can issue immediately.

### Speculation
The core **predicts** branch direction and **speculatively executes** down that path. Results are held in the ROB. If the prediction is right, results commit; if wrong, the pipeline **flushes** the speculative state and resumes from the correct path.

### Precise exceptions
Because the ROB retires in order, an exception can be raised **exactly at the right architectural instruction** even though later instructions executed speculatively.

### Interview answer
> "Out-of-order execution lets independent instructions run past a stalled one, hiding latency. The ROB tracks instructions in program order and retires them in order so exceptions are precise and speculation can be rolled back. Reservation stations wake instructions when operands arrive, and register renaming removes false WAR/WAW dependencies by using physical registers."

---

## 2.3 Caches: Organization, Replacement, Policies, Misses

### Why caches
Memory is slow (DRAM ~100s of cycles) relative to the CPU. Caches exploit **temporal locality** (recently used data likely used again) and **spatial locality** (nearby data likely used) to keep hot data close to the core.

### Address decomposition
A cache of `S` sets, `E` ways (associativity), block size `B` bytes:
```
address = [ tag | index | block offset ]
```
- **offset bits** = log₂(B)
- **index bits** = log₂(S)
- **tag bits** = remaining (address width − offset − index)

### Direct-mapped vs. set-associative vs. fully-associative
- **Direct-mapped** (E=1): each block maps to exactly one location. Cheap, fast, but **conflict misses**.
- **Set-associative** (E>1): each block maps to any of E ways in its set. Fewer conflict misses, needs a **replacement policy** and a comparator per way.
- **Fully-associative** (S=1): block can go anywhere. Least conflict misses, but most expensive (compare against all tags in parallel).

### Replacement policies
- **LRU** (least-recently-used) — best but costly.
- **Pseudo-LRU** — approximation.
- **Random** — simple, decent for large associativity.
- **FIFO** — simple, poor.

### Write policies
- **Write-through**: write to cache *and* memory every time. Simple, consistent, but high memory traffic. Usually paired with a **write buffer**.
- **Write-back**: write only to cache; mark the line **dirty**; write to memory only on eviction. Less traffic, but stale memory until eviction (coherence complexity).
- **Write-allocate vs. no-write-allocate**: whether a write miss brings the line into cache.

### The three C's (cache misses)
1. **Compulsory (cold) misses**: first access to a block — unavoidable.
2. **Capacity misses**: cache too small to hold the working set.
3. **Conflict misses**: two blocks map to the same set (fixed by higher associativity).

### Worked example (memorize the math)
Cache: 32 KB, 4-way set-associative, 64-byte blocks, 32-bit address.
- Block offset = log₂(64) = **6 bits**.
- Number of blocks = 32 KB / 64 B = 512 blocks.
- Number of sets = 512 / 4 = 128 sets → index = log₂(128) = **7 bits**.
- Tag = 32 − 7 − 6 = **19 bits**.

### Interview answer
> "A cache address splits into tag, index, and offset. Direct-mapped is cheapest but suffers conflict misses; set-associative trades comparators and a replacement policy for fewer conflicts. Write-through is simple but traffic-heavy; write-back is efficient but needs dirty tracking and coherence handling. Misses are compulsory, capacity, or conflict."

---

## 2.4 Cache Coherence & MESI

### The problem
In a multicore SoC, each core has its own L1 cache. If two cores cache the **same address**, and one writes it, the other core's copy becomes **stale**. Coherence protocols keep all copies consistent.

### MESI states (per cache line)
- **M (Modified)**: line is **dirty** and valid **only in this cache**. Must write back before another core can read.
- **E (Exclusive)**: line is clean and valid **only in this cache** (matches memory). Can be modified silently (no bus traffic).
- **S (Shared)**: line is clean and may be present in **other caches** too. Reads are safe; a write must **invalidate** others.
- **I (Invalid)**: line not valid.

### Key transitions
- **Read miss** → request line → other caches either provide (S) or the line is fetched from memory. If a cache has it in **M**, it **writes back** and supplies the data.
- **Write miss** → **read-for-ownership (RFO)**: invalidate all other copies, get exclusive ownership → **M**.
- **Write hit on S** → must invalidate other copies first (or get ownership) before writing.

### Why "write hit in S requires invalidation"
If a line is Shared and a core writes it, it must **upgrade** to Modified — meaning it must **invalidate** the other copies (or it would violate coherence). This is the classic "S → M requires a transaction."

### Snooping vs. directory
- **Snooping**: all caches watch ("snoop") a shared bus for transactions. Simple, but doesn't scale to large NoCs.
- **Directory-based**: a directory tracks which caches hold each line; coherence messages go only to interested caches. Scales better (used in modern many-core SoCs).

### Interview answer
> "MESI keeps multiple caches coherent: Modified means dirty and exclusive, Exclusive means clean and exclusive, Shared means clean and possibly replicated, Invalid means not present. A write to a Shared line must invalidate other copies first; a write miss issues a read-for-ownership. Snooping watches a shared bus; directories track sharers and scale better."

---

## 2.5 Memory Hierarchy & Memory Controllers

### The hierarchy (speed/cost/capacity trade-off)
```
Registers → L1 cache → L2 cache → (L3/LLC) → Main memory (DRAM) → Storage (SSD/HDD)
```
Each level is larger, slower, and cheaper per bit. The goal: make the **common case** fast by keeping hot data at high levels.

### DRAM basics
- DRAM is organized as **banks → rows → columns**.
- Access: **activate** a row (bring it into the row buffer), then **read/write columns**, then **precharge** (close the row).
- **Row buffer hit** (same row) is fast; **row miss** requires precharge + activate (slow).
- **Address decoding**: the address maps to **channel → rank → bank → row → column**.

### Memory controllers
The memory controller **schedules** DRAM commands (activate/read/write/precharge/refresh) to maximize throughput:
- **Reorder** requests to exploit **row-buffer locality**.
- Handle **refresh** (DRAM cells leak charge — must be periodically refreshed).
- Enforce **fairness/QoS** among requesters.
- Manage **refresh**, **power-down**, and **error correction (ECC)**.

### Address interleaving
Consecutive addresses are **interleaved across banks/channels** so sequential streams hit different banks in parallel — maximizing bandwidth.

### Why verification cares
- Memory controller verification is heavy on **ordering**, **QoS/fairness**, **backpressure**, and **corner cases** (refresh collisions, bank conflicts, reordering correctness).

### Interview answer
> "The memory hierarchy trades capacity for speed at each level. DRAM is banks of rows and columns; access means activate a row, access columns, then precharge. The controller reorders requests to exploit row-buffer locality, manages refresh and fairness, and interleaves addresses across banks to maximize bandwidth."

---

## 2.6 Interconnects: Bus vs. NoC

### Bus
- A **shared** set of wires with an **arbiter** granting access to one master at a time.
- **Pros**: simple, low area, low latency for few masters.
- **Cons**: doesn't scale — contention grows, the bus becomes a bottleneck, and it has a single point of arbitration.

### Network-on-Chip (NoC)
- A **packet-switched network** of routers and links. Data is split into **packets/flits**, routed through the network.
- **Topologies**: mesh, ring, torus, crossbar, tree.
- **Pros**: scales to many cores/blocks, high aggregate bandwidth, supports multiple concurrent transactions.
- **Cons**: complex routing, flow control, deadlock/livelock risks.

### Key concepts
- **Routing**: path selection (deterministic like X-Y, or adaptive).
- **Flow control**: **credits** (a sender can only send if it has credit — the receiver advertises buffer space).
- **Backpressure**: a stalled receiver stalls the sender upstream (via ready/valid or credits).
- **Deadlock**: a cycle of requests where everyone waits on everyone else — prevented by **virtual channels**, deterministic routing, or restrictions on turns.
- **Starvation / livelock**: a packet never gets serviced (starvation) or keeps moving but never arrives (livelock).
- **Ordering & QoS**: some traffic (e.g., control, coherence) needs guaranteed ordering or priority.

### Interview answer
> "A bus is a shared medium with an arbiter — simple but doesn't scale. A NoC packetizes data and routes it through a network of routers, scaling to many blocks with high bandwidth. Key concerns are routing, credit-based flow control, backpressure, and avoiding deadlock via virtual channels or turn restrictions."

---

## 2.7 Virtual Memory, TLB, Page Tables

### Why virtual memory
- **Isolation**: each process sees its own address space.
- **Protection**: the OS controls read/write/execute per page.
- **Abstraction**: programs can use more memory than physically present (via swapping/paging).

### Address translation
```
virtual address = [ virtual page number (VPN) | page offset ]
          │  (TLB / page table lookup)
          ▼
physical address = [ physical page number (PPN) | page offset ]
```

### Page tables
- A **hierarchical** structure (multi-level) mapping VPN → PPN, with **permission bits** (read/write/execute/user) and **present/dirty/accessed** bits.
- **Multi-level** tables save memory (only used portions are allocated).
- The **page table walk** can take many memory accesses — hence the TLB.

### TLB (Translation Lookaside Buffer)
- A **cache of recent translations** (VPN → PPN).
- **TLB hit**: translation in 1 cycle (or a few).
- **TLB miss**: hardware or software **page-table walk** (many cycles). A **page fault** (page not present) traps to the OS.

### Steps of a translation (interview answer)
1. Split VA into VPN + offset.
2. Look up VPN in the **TLB**.
3. On hit → get PPN, form PA = PPN + offset.
4. On miss → walk the **page table** to find the PPN (and check permissions); if not present → **page fault** to OS.
5. Fill the TLB with the new translation.

### TLB miss cost
A TLB miss costs a multi-access page-table walk (potentially hundreds of cycles) — mitigated by **larger TLBs, multi-level TLBs, and page sizes** (huge pages reduce TLB pressure).

### Answer pattern
> "Virtual memory isolates and protects processes by translating virtual addresses to physical ones. The TLB caches recent VPN→PPN translations; a hit gives a fast translation, a miss triggers a page-table walk, and a not-present page faults to the OS. TLB misses are expensive, so page size and TLB capacity matter for performance."

---

# PART 3 — SYSTEMVERILOG / VERILOG

---

## 3.1 `logic` vs. `wire` vs. `reg`; `always_comb/ff/latch`

### The `logic` type (SystemVerilog)
- `logic` is a **4-state** type (0, 1, X, Z) that can be driven by **one** driver (continuous assign, always block, or module output).
- Replaces the old Verilog split: `reg` = procedural, `wire` = structural/net.
- **Rule**: use `logic` everywhere by default; use `wire`/`tri` only when you need **multiple drivers** (e.g., a tri-state bus or a net resolved by multiple assigns).

### `always_comb` vs. `always_ff` vs. `always_latch`
These are SystemVerilog's **explicit intent** blocks (vs. the ambiguous Verilog `always @(*)`):
- **`always_comb`**: combinational logic. Tools **check** that it's truly combinational (no inferred latch, no timing). Executes at time 0 and whenever any input changes. Sensitive to all RHS signals automatically.
- **`always_ff`**: sequential. Must have a clock edge (and optionally async reset). Tools check the sensitivity list.
- **`always_latch`**: explicitly a latch — use rarely and deliberately.

### Why they matter for DV
`always_comb` catches **latch inference** and **incomplete sensitivity lists** at compile time — two of the most common RTL bugs. Using them makes intent clear and reduces X-propagation surprises.

### Answer pattern
> "`logic` is the modern 4-state type I use for nearly everything; I only reach for `wire` when I need multiple drivers. `always_comb`, `always_ff`, and `always_latch` declare intent explicitly and let tools check for latch inference or bad sensitivity lists, which catches RTL bugs early."

---

## 3.2 Blocking vs. Non-blocking (revisited for SV)

Covered in §1.2 — the SV-specific takeaways:

- **`always_comb`** → `=` only.
- **`always_ff`** → `<=` only.
- **Race bugs** come from using `=` in sequential blocks, or reading a signal in one block while another block writes it with `=` in the same timestep.

### A common race bug (delta cycles)
```systemverilog
// Block A
always_comb y = a;

// Block B
always_ff @(posedge clk) a <= b;
```
Because non-blocking assignments update in the **NBA region** (after the active region), and combinational logic evaluates in the **active region**, a signal updated by `<=` is seen by combinational logic **one delta cycle later**. Understanding **scheduling regions** (active → NBA → observed) is the key to debugging "why is my monitor seeing the old value?"

### Scheduling regions (the concept)
- **Active region**: blocking assignments and continuous assigns evaluate.
- **NBA region**: non-blocking assignments update.
- **Observed**: assertions/coverage sample.
This ordering is *why* non-blocking semantics are consistent and race-free for FF modeling.

### Answer pattern
> "Blocking assignments run immediately in the active region; non-blocking assignments are scheduled and update in the NBA region after all active-region evaluation. That ordering is what makes flop modeling deterministic. Races happen when you mix them or use blocking in sequential code, and the symptom is order-dependent simulation results."

---

## 3.3 Parameterization, Generate, Interfaces, Packages, typedef/enum/struct

### Parameters
- **`parameter`** (module-level constants) and **`localparam`** (can't be overridden).
- Make designs configurable: width, depth, counts.
- Override with `#( .WIDTH(32), .DEPTH(64) )`.

### `generate` blocks
- Conditionally or iteratively instantiate hardware.
```systemverilog
generate
  for (genvar i = 0; i < N; i++) begin : gen
    adder #(W) u_add (.a(a[i]), .b(b[i]), .y(y[i]));
  end
  if (USE_ECC) begin : gen_ecc
    ecc u_ecc (...);
  end
endgenerate
```

### Interfaces
- Bundle related signals into a **single named port** — reduces port-list explosion and lets you pass a whole bus as one object.
```systemverilog
interface bus_if(input logic clk);
  logic        valid, ready;
  logic [31:0] data;
  modport master (output valid, data, input ready);
  modport slave  (input valid, data, output ready);
endinterface
```
- **`modport`** defines direction per side.
- **`clocking` blocks** (inside interfaces) define when signals are sampled/driven — essential for race-free TBs.
- **Virtual interfaces** connect the class-based testbench to the static DUT (see UVM).

### Packages
- Share types, constants, functions, and classes across modules/files.
```systemverilog
package my_pkg;
  typedef logic [31:0] addr_t;
  function automatic int log2(input int n); ... endfunction
endpackage
import my_pkg::*;
```

### typedef, enum, struct
```systemverilog
typedef logic [31:0] word_t;                    // type alias
typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;  // enum
typedef struct packed { logic [31:0] addr; logic [3:0] len; } req_t; // struct
```

### Answer pattern
> "I use parameters to make designs configurable, generate loops/ifs for regular or conditional instantiation, and interfaces to bundle bus signals into one port with modports for direction and clocking blocks for sampling. Packages share types and functions, and typedef/enum/struct make code self-documenting."

---

## 3.4 Assertions (SVA)

### The anatomy of an assertion
```systemverilog
assert property (@(posedge clk) disable iff (!rst_n) req |-> ##[1:$] gnt);
```
- **`assert property`**: check that the property holds.
- **`@(posedge clk)`**: clock.
- **`disable iff (!rst_n)`**: ignore while in reset.
- **`req`**: antecedent (trigger).
- **`|->`**: overlapping implication — if `req` is true *this cycle*, check the consequent starting *this cycle*.
- **`|=>`**: non-overlapping — check the consequent starting the **next** cycle.
- **`##[1:$] gnt`**: `gnt` must be true **1 to infinity** cycles later (eventually).
- **`##n`**: exactly n cycles later.

### Sequences and operators
- **`##[m:n]`**: delay range.
- **`$rose(sig)`** / **`$fell(sig)`** / **`$stable(sig)`**: edge detection.
- **`|->` vs `|=>`**: overlapping vs. non-overlapping implication.
- **`throughout`**, **`until`**, **`s_eventually`**, **`s_until`**.
- **Consecutive repetition** `sig[*n]`, **goto repetition** `[->n]`, **non-consecutive** `[=n]`.

### Examples (memorize)
```systemverilog
// request eventually granted
assert property (@(posedge clk) disable iff (!rst_n) req |-> ##[1:$] gnt);

// no grant without request
assert property (@(posedge clk) disable iff (!rst_n) gnt |-> req);

// grant never while in reset / valid stays high until ready
assert property (@(posedge clk) valid |-> valid until ready);

// data must be stable while valid and not ready
assert property (@(posedge clk) disable iff (!rst_n)
                 valid && !ready |=> $stable(data));
```

### Why assertions are powerful in DV
- They **watch continuously** (like a monitor), catching bugs at the **source cycle** — no need to wait for the scoreboard.
- They **localize** the bug (which cycle, which signal).
- They are **reusable in formal** verification.
- They document **intent** right next to the design.

### Answer pattern
> "SVA lets me check temporal behavior: `|->` is overlapping implication, `|=>` is non-overlapping, `##[1:$]` means eventually, and I use `$rose/$fell/$stable` for edges. Assertions catch violations at the exact cycle and are reusable in formal verification."

---

## 3.5 Randomization & Constraints

### The building blocks
- **`rand`**: random, values can repeat.
- **`randc`**: cyclic random — values cycle through all possibilities before repeating (good for coverage).
- **`constraint` block**: restricts legal values.
- **`randomize()`**: solves all constraints and assigns values; returns success/failure.

```systemverilog
class pkt;
  rand bit [31:0] addr;
  rand bit [2:0]  size;
  rand bit         kind;

  constraint c_align { addr[1:0] == 2'b00; }            // 4-byte aligned
  constraint c_range { addr inside {[32'h1000:32'h2000]}; }
  constraint c_size  { size dist { 0 := 3, [1:7] := 1 }; }  // weight 0 by 3:1
  constraint c_kind  { kind == 1 -> size inside {[1:4]}; }  // implication
endclass
```

### Constraint operators
- **`inside {a, [b:c]}`**: membership / range.
- **`dist { value := weight }`**: weighted distribution (`:=` is exact weight, `:/` is relative).
- **`->` (implication)**: if antecedent then consequent.
- **`if/else`**: conditional constraints.
- **`solve X before Y`**: controls the **solving order** (affects distribution, not legality).
- **`unique`**, **`soft`** constraints.
- **`foreach`**: constraints over arrays.

### Why constrained-random (not just random)
Pure random gives **illegal or meaningless** stimulus (misaligned addresses, out-of-range values, impossible combinations). Constraints **shape** the stimulus to the **legal space** while still exploring it broadly — this is the heart of modern DV.

### The `solve...before` nuance
Changing solve order doesn't change *what's legal* — it changes the *probability distribution* of the solutions. Used to bias coverage.

### `randomize()` return value
`if (!pkt.randomize())` → handle **constraint failure** (over-constrained → no solution). Always check the return value; otherwise you run with the previous (possibly stale) values.

### Answer pattern
> "Constrained-random uses `rand`/`randc` with `constraint` blocks to generate legal, interesting stimulus — alignment, ranges, weighted `dist`, and implications. The `randomize()` call solves the constraints and returns success, which I always check. Constraints make random stimulus *legal and meaningful*, unlike pure random."

---

## 3.6 Functional Coverage

### What it is
Functional coverage measures **how much of the intended functionality** has been exercised — expressed by the **verification engineer** as explicit coverage points. It answers "did we test everything we planned?"

### The building blocks
```systemverilog
covergroup cg @(posedge clk);
  cp_op   : coverpoint op {
              bins add = {0};
              bins sub = {1};
              illegal_bins bad = {2, 3};   // values that must never occur
            }
  cp_size : coverpoint size {
              bins small = {[0:3]};
              bins big   = {[4:7]};
            }
  x_opsize: cross cp_op, cp_size;   // cartesian product coverage
endgroup
```
- **`covergroup`**: the coverage model (instantiate it, then `sample()`).
- **`coverpoint`**: a coverage point on an expression/variable.
- **`bins`**: named value buckets; `illegal_bins` flag illegal values; `ignore_bins` exclude values; `wildcard bins` for don't-care patterns.
- **`cross`**: covers combinations of two or more coverpoints.
- **`cover property`**: coverage of an SVA property (e.g., was the property triggered/hit).

### Goal and coverage metrics
- **Goal**: 100% of the **planned** functional coverage (bins hit), plus high **code coverage**.
- **Coverage report**: which bins are hit/missed → identify **coverage holes**.

### Answer pattern
> "Functional coverage captures whether planned scenarios were actually exercised, using covergroups, coverpoints, bins, and crosses. It complements code coverage — code coverage tells you the RTL lines/transitions were hit, while functional coverage tells you the *meaningful scenarios* were hit. Illegal bins catch violations, and misses point to coverage holes."

---

## 3.7 Tasks vs. Functions, Virtual Methods, Classes

### Tasks vs. functions
| | `function` | `task` |
|---|---|---|
| Time | **Cannot** consume time (no `#`, no blocking waits) | **Can** consume time |
| Return | Returns a value | No return value (uses output/ref args) |
| Call | From expressions | Statement-level |
| Use | Pure computation, conversion, utilities | Bus transactions, sequences with timing |

### `automatic` keyword
By default, tasks/functions are **static** (shared storage across calls). Mark them **`automatic`** to get per-call storage (needed for recursion and re-entrancy — critical in class-based TBs and UVM).

### Classes & OOP in SystemVerilog
```systemverilog
class base;
  virtual function void print(); $display("base"); endfunction
endclass

class child extends base;
  virtual function void print(); $display("child"); endfunction
endclass
```
- **`virtual` methods**: dispatch based on the **object's actual type** (dynamic dispatch), enabling **polymorphism**.
- **Inheritance (`extends`)**, **encapsulation**, **polymorphism** — the OOP pillars that power UVM.
- **`super`**: call the parent's method.
- **`pure virtual`**: abstract methods (must be overridden).
- Classes are **dynamic** objects (created with `new()`); they live in the testbench side and access the static DUT through **virtual interfaces**.

### Why OOP matters for DV
UVM is entirely built on classes + virtual methods + the **factory** (which lets you override types via `set_type_override`). Understanding virtual dispatch is essential to understanding UVM.

### Answer pattern
> "Functions can't consume time and return a value; tasks can consume time and are for transactions with timing. I mark them `automatic` for re-entrancy. Classes provide the OOP foundation for UVM — virtual methods give dynamic dispatch, and inheritance/polymorphism enable the factory overrides UVM relies on."

---

# PART 4 — VERIFICATION METHODOLOGY & DEBUG

---

## 4.1 Test Plan Structure

### What a test plan is
A written plan that maps **features → scenarios → checks → coverage goals**. It is derived from the **specification** (architectural and micro-architectural) and is the contract for "what 'done' means."

### The standard structure
1. **Features**: enumerate the block's functionality (from the spec).
2. **Scenarios**: for each feature, list the **stimulus scenarios** (normal, boundary, error, stress, corner).
3. **Checks**: for each scenario, what result is **correct** (expected behavior).
4. **Coverage goals**: which functional coverage bins / code coverage targets must be hit.
5. **Assumptions/exclusions**: waivers, known limitations, out-of-scope items.
6. **Sign-off criteria**: the measurable bar for "verification complete."

### Deriving corner cases from a spec (the skill)
Read the spec and, for each rule, ask: *what is the boundary? what happens at the boundary? what happens beyond it?* Example — a FIFO spec says "depth 16":
- What at 0 entries? 16 entries?
- Read when empty? Write when full? Both same cycle?
- What's the reset value? What if reset arrives mid-transfer?

### Answer pattern
> "A test plan maps features to scenarios to checks to coverage goals, derived from the spec. For each feature I enumerate normal, boundary, error, and stress cases, define expected behavior for each, and set measurable coverage and sign-off criteria. I derive corner cases by probing every boundary and violation of every spec rule."

---

## 4.2 Constrained-Random vs. Directed Testing

### Directed tests
- Hand-written, **specific** stimulus for a specific scenario.
- **Pros**: deterministic, easy to debug, guarantees a known scenario runs.
- **Cons**: doesn't scale — you can't hand-write every case; humans miss corner cases.

### Constrained-random tests
- **Random** stimulus **shaped by constraints** to stay legal and interesting.
- **Pros**: explores a huge space automatically, finds bugs you didn't anticipate, scales to many seeds.
- **Cons**: harder to debug (need to reproduce a specific seed), needs a good scoreboard/coverage to know what you hit.

### The modern flow (CRV + coverage)
1. Write constraints that define the **legal space**.
2. Run **many seeds** to explore the space.
3. Use **functional coverage** to see what was (and wasn't) hit.
4. Add **directed tests** for the **holes** (specific corner cases coverage missed).
5. Iterate until **coverage closure**.

### Why constraining matters (interview point)
Random without constraints produces illegal stimulus (misaligned addresses, impossible opcodes) that either get **dropped** (wasted cycles, false failures) or **mask real behavior**. Constraints make random stimulus **legal and meaningful**.

### Answer pattern
> "Directed tests target one specific scenario and are deterministic, but don't scale. Constrained-random generates legal, varied stimulus across many seeds to explore the space broadly. I combine them: CRV for breadth and coverage, then directed tests to close the specific corner-case holes coverage reveals."

---

## 4.3 Reference Model & Scoreboard

### The roles
- **Reference model (predictor)**: an independent, often simpler (sometimes higher-level, e.g., SystemC or a golden model) implementation of the **expected behavior**.
- **Scoreboard**: compares the DUT's actual outputs against the reference model's predictions and **flags mismatches**.

### The flow
```
stimulus ──► DUT ────────────► actual outputs
   │                             │
   └──► reference model ──► predicted outputs ──► [compare] ──► pass/fail
```

### Out-of-order / pipelined complication
Real designs reorder or pipeline transactions, so outputs may arrive **out of order** or **late**. A naive "compare the nth output to the nth prediction" breaks. Solutions:
- **Tag/ID each transaction** and match by ID.
- Use a **scoreboard data structure** (associative array, queue, or UVM TLM fifo) that **stores predictions and matches by key** when the corresponding output arrives.
- Model the **ordering rules** in the predictor (e.g., "reads may bypass writes to different addresses").
- Account for **in-flight** transactions and **timeouts** (prediction never matched → error).

### In-order vs. out-of-order matching (interview example)
For a **FIFO** (in-order), a simple queue compare works. For an **interconnect** (out-of-order responses), you need **ID-based** matching and a check for **completeness** (all predictions eventually matched) and **duplicates** (same ID twice).

### Answer pattern
> "The reference model computes expected outputs independently; the scoreboard compares them against DUT outputs. For out-of-order designs I tag transactions with IDs and match by key rather than position, tracking in-flight predictions and timing out unmatched ones. I also verify ordering rules explicitly rather than assuming order."

---

## 4.4 Coverage Closure

### Functional vs. code coverage
- **Functional coverage** (you write it): did we hit the **meaningful scenarios**?
- **Code coverage** (tool-generated): did we hit the **RTL structure**?
  - **Line/statement**: every line executed.
  - **Branch**: every `if/else` branch taken.
  - **Condition**: every sub-expression true/false.
  - **Toggle**: every signal toggled 0→1 and 1→0.
  - **FSM**: every state visited and every transition taken.

### Coverage closure process
1. Run the regression, collect coverage.
2. Find **holes** (unhit bins, unexecuted branches).
3. Determine if each hole is:
   - **Reachable but untested** → add a test/constraint to hit it.
   - **Unreachable/dead code** → **waive** it (documented, reviewed).
   - **Illegal** → mark `illegal_bins`.
4. Iterate until closure.

### The "100% code coverage is not enough" argument
Code coverage tells you the **lines ran**, not that the **behavior is correct** or that **meaningful combinations** were tested. Classic example: a bug where two signals must be **simultaneously** asserted in a specific combination. Each line may be covered individually, but the **corner-case combination** is never hit — and the bug ships. **Functional coverage captures the combinations that matter.**

### Answer pattern
> "Code coverage is structural — line, branch, toggle, FSM. Functional coverage is semantic — did we hit the planned scenarios. Closure means reviewing every hole: test the reachable ones, waive the unreachable ones with documentation. 100% code coverage can still miss corner-case *combinations*, which is why functional coverage is the real sign-off driver."

---

## 4.5 Regression Triage (the 3 a.m. failure)

### What a regression is
A **suite of tests** run automatically (nightly, or on every commit via CI) to detect regressions — behavior that used to work but now breaks.

### The triage process (memorize this order)
1. **Reproduce**: re-run the exact failing test with the **same seed, same build, same environment**. Is it deterministic?
2. **Minimize**: reduce the test to the **smallest** reproducing case (shrink stimulus, isolate the transaction/cycle).
3. **Classify**:
   - **Real RTL bug** → file it, work with the designer, find root cause.
   - **Testbench bug** → fix the TB (wrong checker, wrong constraint, wrong reference model).
   - **Environment/infra issue** → tool version, compile issue, resource, flaky race.
   - **X-propagation / race** → uninitialized values, CDC issues, delta-cycle races.
4. **Root-cause**: use waveform dumps, log analysis, and assertions to find the **first** wrong cycle (not the symptom).
5. **Fix & verify**: fix the bug, re-run, and **add a regression test + coverage + assertion** so it can't silently return.
6. **Regress**: re-run the full suite to confirm no new breakage.

### Classifying a failure (the key skill)
- **Deterministic vs. seed-dependent**: re-run the same seed. Same result = deterministic (logic bug). Different result = race/metastability/X/uninitialized.
- **Waveform**: find the **first divergence** from expected — that's usually near the root cause.
- **Assertions**: an assertion firing at the exact cycle is the best localization tool.

### Answer pattern
> "I reproduce with the same seed and environment, minimize to the smallest case, then classify: RTL bug, TB bug, or infra/race issue. I find the first wrong cycle in the waveform or via an assertion, root-cause with the designer, fix it, and add a regression test plus coverage so it can't return. Then I re-run the full suite."

---

## 4.6 Reading Timing Diagrams & Micro-arch Specs → Checks

### The skill
Turn a **timing diagram** (waveforms) and a **micro-architecture spec** (register descriptions, protocol rules) into **checks and tests**.

### Process
1. **Identify the protocol/interface**: what signals, what clock, what's the handshake (e.g., ready/valid)?
2. **Enumerate legal behaviors**: what sequences are allowed?
3. **Enumerate illegal behaviors**: what must never happen?
4. **Encode as checks**: write **SVA** for the illegal behaviors and **scoreboard checks** for the data.
5. **Build stimulus**: drive legal (and boundary-illegal) scenarios.

### Example: AXI-Stream-like ready/valid handshake
From the spec: "When `valid` and `ready` are both high at a clock edge, the data is transferred. `valid` must not deassert until `ready` is high. `data` must be stable while `valid` is high and `ready` is low."

Encode:
```systemverilog
// data must be stable while valid and not ready
assert property (@(posedge clk) disable iff (!rst_n)
                 valid && !ready |=> $stable(data));

// valid must not drop while ready is low (data hasn't transferred)
assert property (@(posedge clk) disable iff (!rst_n)
                 valid && !ready |=> valid);
```

### The corner cases to enumerate (ready/valid)
1. Both ready and valid high → transfer.
2. Valid high, ready low → hold data (no transfer, data must be stable).
3. Valid low, ready high → idle (no transfer).
4. Valid deasserts before ready → legal (transfer not committed), must handle cleanly.
5. Both low → idle.
6. Reset asserted mid-transfer.

### Answer pattern
> "I read the spec to extract the protocol rules, then encode them as assertions and scoreboard checks. For a ready/valid handshake, transfer happens when both are high; data must be stable while valid and not ready; and valid must not drop before a transfer completes. I then build stimulus to hit each corner case."

---

# Quick-Reference: Top 20 Priority A Facts to Recall Cold

1. **Blocking (`=`)** = combinational, immediate, ordered. **Non-blocking (`<=`)** = sequential, simultaneous, models flops.
2. **Latch inference** = incomplete assignment in combinational `always`; fix with defaults + `always_comb`.
3. **Setup/hold** violations → metastability (invalid voltage, probabilistic resolution).
4. **Metastability fix** = 2-flop synchronizer (reduces probability, not a guarantee); multi-bit needs handshake/async FIFO.
5. **FIFO empty** = `wptr == rptr`; **full** = `wptr+1 == rptr` (reserved slot) or extra-bit/Gray scheme.
6. **Async FIFO** uses Gray-coded pointers + 2-flop sync; full computed in write domain, empty in read domain.
7. **Moore** = outputs from state only; **Mealy** = outputs from state + inputs (faster, can glitch).
8. **5-stage pipeline** = IF/ID/EX/MEM/WB; hazards = structural/data/control.
9. **Data hazard fix** = forwarding (bypass); load-use needs a stall.
10. **Cache address** = tag | index | offset (offset = log₂ block, index = log₂ sets).
11. **Misses** = compulsory / capacity / conflict.
12. **MESI** = Modified (dirty+exclusive), Exclusive (clean+exclusive), Shared, Invalid; write to S requires invalidation/RFO.
13. **ROB** retires in order → precise exceptions + speculation rollback; **renaming** removes WAR/WAW.
14. **TLB** = cache of VPN→PPN; miss = page-table walk; absent = page fault.
15. **NoC** = packet-switched, credit-based flow control, backpressure, deadlock via VCs/turn rules.
16. **SVA**: `|->` overlapping, `|=>` non-overlapping, `##[1:$]` eventually, `$rose/$fell/$stable` edges.
17. **Constraints**: `rand`/`randc`, `inside`, `dist :=`, `->` implication, `solve...before`; always check `randomize()` return.
18. **Coverage**: `covergroup`/`coverpoint`/`bins`/`cross`/`illegal_bins`; functional (semantic) vs. code (structural).
19. **Triage order**: reproduce → minimize → classify (RTL/TB/infra/race) → root-cause (first wrong cycle) → fix + add regression/coverage → re-run.
20. **Scoreboard out-of-order** = ID-tagged matching + in-flight tracking + timeouts.
