# Tenstorrent — Digital Verification Intern (AI SoC) — Interview Prep

**Role source:** "Digital Verification Intern - AI SoC.docx" (attached to the Tenstorrent interview invitation email, req #54279).
**Interview date shown in your email:** Oct 15, 2026.
**Team focus:** End-to-end SoC design & verification for cutting-edge **RISC-V** and **AI accelerator** architectures.

---

## 1. What the JD actually tells you they will probe

Read the JD as a checklist of what they'll ask about. Three sections:

**"Who you are" (screening / background signals):**
- Pursuing B.S./M.S./PhD in EE, CE, CS or related, focused on **digital design & verification**.
- Strong understanding of **digital logic design** and **computer architecture** (pipelines, caches, interconnects, memory systems).
- Familiar with **HDLs: Verilog / SystemVerilog**; *interested in learning* **Formal verification, Cocotb, and UVM**.
- Comfortable in **Linux** environments; scripting (**Python, Shell, Perl**) to automate tasks.
- **Detail-oriented debugger** — reasoning about corner cases, working from specs.
- **Collaborative communicator** — documenting work, discussing trade-offs with RTL/architecture/validation teams.

**"What We Need" (the day-to-day, so expect scenario questions):**
- Build/maintain **SystemVerilog/UVM testbenches** (stimulus, checkers, scoreboards) for SoC IP & subsystems.
- Write/refine **verification test plans** from architectural & micro-architectural specs — corner cases + coverage.
- **Constrained-random & directed tests**, run **regressions**, **triage failures**, root-cause with RTL designers.
- Analyze **functional & code coverage**, find gaps, drive **coverage closure**.
- **Automation/infrastructure**: scripts, Makefiles, **CI hooks, dashboards**.
- Partner cross-functionally; align on expected behavior & **sign-off criteria for silicon**.

**"What You Will Learn" (signals the domains they care about):**
- End-to-end SoC DV flow for **RISC-V** + **AI accelerator** designs.
- **SystemVerilog/UVM** methodology (testbench architecture, stimulus, scoreboards/checkers).
- Simulation, regression, and **coverage tools** in large-scale industrial flows.
- Reading **hardware specs, micro-arch docs, timing diagrams** → tests & assertions.
- **High-performance interconnects, memory controllers, accelerators** verified at IP / subsystem / SoC level.

> **Key read:** they explicitly say you only need to be *"interested in learning"* formal/cocotb/UVM — so they don't expect mastery. They weight **fundamentals (logic + architecture)**, **SystemVerilog**, and **debug/corner-case reasoning** more heavily. Be strong on fundamentals and honest about UVM/formal depth.

---

## 2. Technical topics to review (priority-ordered)

### Priority A — likely asked, must be solid
1. **Digital logic design**
   - Combinational vs sequential logic; blocking vs non-blocking assignments; latches vs flip-flops.
   - Setup/hold time, clock-to-Q, timing violations, metastability, synchronizers, CDC basics.
   - FSM design (Moore/Mealy), state encoding, one-hot vs binary.
   - Counters, shift registers, arbitration, FIFO design (and full/empty flag corner cases).
   - Clock gating, reset (sync vs async), power basics.
   - Number systems, two's complement, signed/unsigned overflow.

2. **Computer architecture**
   - 5-stage classic RISC pipeline; hazards (data, control, structural), forwarding, stalls/flushes.
   - Out-of-order execution basics (ROB, reservation stations), speculation, branch prediction.
   - Caches: direct-mapped vs set-associative, replacement, write-through/write-back, MESI/coherence, cache misses (compulsory/capacity/conflict).
   - Memory hierarchy & memory controllers; DRAM basics (row/bank), address decoding.
   - Interconnects: buses vs NoC, arbitration, ordering, QoS.
   - Virtual memory: TLB, page tables, translation (appears in "caches, interconnects, memory systems").

3. **SystemVerilog / Verilog**
   - `always_comb` / `always_ff` / `always_latch`; `logic` vs `wire`/`reg`.
   - Blocking (`=`) vs non-blocking (`<=`) semantics and common race bugs.
   - Parameterization, generate blocks, interfaces, packages, `typedef`, enums, structs.
   - Assertions (SVA): `assert property`, `|->`, `|=>`, sequences, `$rose/$fell/$stable`.
   - Randomization: `rand`/`randc`, `constraint` blocks, `dist`, `solve...before`, `randomize()`.
   - Functional coverage: `covergroup`, `coverpoint`, `cross`, bins, `coverproperty`.
   - Tasks vs functions, virtual methods, classes/objects (needed for UVM).

4. **Verification methodology & debug**
   - **Test plan** structure: features → scenarios → checks → coverage goals; corner cases from a spec.
   - **Constrained-random vs directed** testing; why constraining stimulus matters.
   - **Reference model / scoreboard** (DUT vs model compare), predictors, transactors.
   - **Coverage closure**: functional vs code coverage (line/toggle/branch/FSM), coverage holes, waivers.
   - **Regression triage**: reproducing, minimizing, classifying failures (real bug vs TB bug vs X/race), bisecting.
   - Reading a **timing diagram / micro-arch spec** and turning it into checks.

### Priority B — UVM (they say "interested in learning" — know the architecture)
5. **UVM**
   - Component hierarchy: `uvm_test` → `uvm_env` → agents (driver, monitor, sequencer) → scoreboard.
   - **Sequence / sequence item / sequencer / driver** handshake (`seq_item_port`, `get_next_item`, `item_done`).
   - **`uvm_component` vs `uvm_object`**; phases (build, connect, run, etc.); config DB (`uvm_config_db`).
   - TLM ports/exports/fifos; analysis port for coverage & scoreboard.
   - Factory & `create()` (overrides); virtual interfaces in agents.
   - *(If you've only read about UVM, be able to draw the testbench block diagram from memory.)*

### Priority C — good to have, differentiate yourself
6. **Formal verification** (they list it as a learning area)
   - What formal proves vs simulation; bounded model checking, k-induction.
   - Properties, invariants, assume/assert/cover, reset constraints; SVA reuse in formal.
   - Good targets: arbiters, FIFOs, control FSMs, protocol handshakes.
7. **Cocotb (Python-based verification)**
   - Python testbench driving HDL via VPI/VHPI; coroutines, `Timer`, `RisingEdge`, `dut.signal`.
   - Why teams use it (Python familiarity, reuse, agility) — pair with Python skills below.
8. **Scripting & Linux (explicit JD requirement)**
   - **Python**: file I/O, regex (`re`), `subprocess`, parsing logs, `argparse`, dict comprehensions, generators.
   - **Shell**: `grep`/`awk`/`sed`, pipes, `find`, loops, exit codes; **Makefiles** (targets/prereqs/recipes/variables).
   - **Perl** basics (regex-heavy log parsing) — at least be able to read it.
   - **CI/regression infra**: what a nightly regression + dashboard looks like, GitHub Actions/Jenkins concepts, artifact/triage reports.
   - **Version control**: git (branch, merge, rebase, resolve conflicts) — implied by "code review".
9. **Domain context: RISC-V & AI accelerators**
   - RISC-V ISA basics: RV32I/RV64I, registers, load/store, decode; extension philosophy (open ISA).
   - Tenstorrent context: they build RISC-V CPUs **and** AI accelerators (Tensix cores, NoC-based architecture). Know the general idea of a **systolic array / MAC array / tensor core**, dataflow (weights vs activations), and why accelerator DV is heavy on **coverage + corner cases**.
   - SoC-level: IP block vs subsystem vs full SoC verification; integration, boot flows.

---

## 3. Likely technical interview questions (with what a good answer covers)

### A. Digital logic & RTL
1. Difference between **blocking and non-blocking** assignments — when do you use each, and how do you get a race?
2. Design a **FSM** (e.g., traffic light / protocol handshake / 2-bit sequence detector). Moore vs Mealy — trade-offs?
3. **Setup/hold** time — what happens on violation? How do you fix timing (pipeline, retiming, relax constraints)?
4. Design a **FIFO** — how do you compute full/empty? How do you handle simultaneous read+write at empty/full? (classic corner-case Q)
5. **Synchronous vs asynchronous reset** — pros/cons, and reset synchronizer.
6. Why **clock-domain crossing** is dangerous; give synchronizer options (2-FF, handshake, async FIFO).
7. Latch inference — how does it happen in `always_comb`/`always @(*)` and how to avoid it?
8. Write synthesizable Verilog for a **counter / gray-code counter / pulse generator**.
9. **Power/area/timing trade-offs** of one-hot vs binary FSM encoding.

### B. Computer architecture
10. Walk through a **5-stage pipeline**; where do hazards occur and how are they resolved?
11. Explain **branch prediction** and what happens on a misprediction (penalty, flush).
12. **Cache** question: how many bits for tag/index/offset given size/associativity/block size? (Do the math.)
13. **Cache coherence** — describe **MESI**; what's a cache line state transition on a write miss?
14. Out-of-order execution: **ROB, register renaming, speculation** — why needed?
15. **Virtual memory / TLB**: steps of an address translation; what's a TLB miss cost?
16. Memory ordering / consistency models — why does it matter in a multicore SoC?
17. Interconnect: **bus vs NoC**, arbitration fairness, deadlock/starvation risks.

### C. SystemVerilog / verification method
18. How would you build a **testbench for a FIFO / arbiter / ALU / simple memory**? Draw env → agent → driver/monitor/sequencer → scoreboard.
19. What's a **scoreboard**, and how do you handle **out-of-order** transactions with a predictor?
20. **Constrained random** vs directed — write a small constraint (e.g., random address aligned to 4, avoid reserved ranges, `dist{}` weights).
21. What is **functional coverage** vs **code coverage**? Give a `covergroup` with a `coverpoint` and a `cross`. What's an **illegal bin**?
22. When is **100% code coverage** still not enough? (Corner-case/bug-rate argument.)
23. You see a regression failure at 3 am — how do you **triage** it? (Reproduce → minimize → classify → root-cause → fix → regress.)
24. How do you decide **when verification is done** / what are **sign-off criteria**?
25. Difference between a **monitor** and a **checker**; where do **SVA** assertions fit in?
26. Explain **UVM phases** and the **`uvm_config_db`** flow; how does a sequence get to the driver?
27. What is the **factory override** and why is it useful?

### D. Domains (RISC-V / AI SoC)
28. What makes verifying an **AI accelerator** different from verifying a CPU? (Dataflow, throughput, numerical accuracy, coverage explosion.)
29. How would you verify a **NoC / interconnect**? (Ordering, QoS, backpressure, deadlock, coverage of traffic patterns.)
30. What is **backpressure** and how do you test it? (ready/valid handshake corner cases — very common gap.)
31. Explain the **ready/valid (AXI-Stream-like) handshake** and enumerate its corner cases.

### E. Coding / scripting (often a live exercise)
32. **Python**: parse a simulation log and count/classify `UVM_ERROR` vs `UVM_FATAL` by test; or write a script to sweep seeds and report failing ones.
33. **Shell**: one-liner with `grep`/`awk` to extract `UVM_ERROR` counts per test; write a simple **Makefile** target that runs a test.
34. Write a function to **randomize** values with constraints in Python (or reason about SV constraints).
35. Complexity/algorithm warm-up: dedupe/parse/diff lists, bit manipulation (common in DV tooling).
36. **Git**: resolve a merge conflict; explain rebase vs merge.

### F. Behavioral (the JD stresses collaboration & communication)
37. Tell me about a **hard bug you debugged** — how did you isolate it, and how did you reason about corner cases?
38. Describe a time you worked from an **ambiguous spec** — how did you resolve the ambiguity?
39. Example of **working with others / disagreeing** on a design or expected behavior.
40. How do you **document** your work and communicate status to a team?
41. A time you **automated** something to save time (maps to the "automation & infrastructure" bullet).
42. Why Tenstorrent / why RISC-V & AI accelerators / why verification (vs design)?

---

## 4. High-value "corner case" drills (this JD loves them)

Practice enumerating edge cases out loud — this is what "reasoning about corner cases" means to them:

- **ready/valid handshake**: both sides stalled, source drops valid, receiver not ready then ready, simultaneous transfer + reset.
- **FIFO**: write when full, read when empty, read+write same cycle at boundary, almost-full/almost-empty, reset mid-operation, pointer wrap.
- **Arbiter**: simultaneous requests, priority inversion, starvation, request held for many cycles, request deasserted before grant.
- **Counter**: overflow/underflow, wrap at max, reset during count, load-enable conflict.
- **Cache/memory**: same-address read-after-write, unaligned access, back-to-back hits, eviction during in-flight access.
- **Reset/CDC**: reset asserted in one domain only, signal crossing domains, glitch on async signal.

---

## 5. Prep plan (given the interview is imminent)

**If you have ~1 day:**
1. Drill **digital logic + architecture fundamentals** (Sections A & B) — most likely core questions.
2. Re-read/rewrite your **FIFO and FSM designs** from scratch; be able to explain blocking vs non-blocking and hazards cold.
3. Memorize the **UVM testbench block diagram** and be able to narrate a sequence→driver→monitor→scoreboard flow (even if you've only studied it).
4. Prepare **2–3 STAR stories**: a hard debug, a spec-ambiguity resolution, an automation win.
5. Skim **RISC-V basics** + one paragraph on Tenstorrent's **Tensix/NoC** architecture so you can speak to "why AI SoC."
6. Have 4–5 **questions for them** (below).

**Looking strong / differentiators:** demonstrating formal- or cocotb-curiosity, coverage-closure intuition, and automation mindset (Makefiles/CI) directly matches their "What We Need" list.

---

## 6. Questions to ask them

1. What does the verification flow look like day-to-day — simulator, regression, coverage tools, and where is the DB/dashboard?
2. How much of the intern work is **IP-block** vs **subsystem/SoC** level?
3. Is the team using **UVM** today, and where does **formal** or **cocotb** fit in?
4. How is coverage closure and **sign-off** decided for the blocks I'd work on?
5. What does success look like for an intern in the first 3 months?
6. Which parts of the stack would I touch — RISC-V cores, accelerator (Tensix) blocks, NoC, or memory controllers?

---

## 7. Reusable snippets to recall under pressure

**SVA (assert a request is eventually granted):**
```systemverilog
property p_req_granted;
  @(posedge clk) disable iff (rst_n == 0)
    req |-> ##[1:$] gnt;
endproperty
assert property (p_req_granted);
```

**SVA (no grant without request):**
```systemverilog
assert property (@(posedge clk) disable iff (!rst_n) gnt |-> req);
```

**Constrained-random stimulus:**
```systemverilog
class pkt;
  rand bit [31:0] addr;
  rand bit [2:0]  size;
  constraint c_align { addr[1:0] == 2'b00; }          // 4-byte aligned
  constraint c_range { addr inside {[32'h1000:32'h2000]}; }
  constraint c_size  { size dist { 0 := 3, [1:7] := 1 }; }
endclass
```

**Coverage:**
```systemverilog
covergroup cg @(posedge clk);
  cp_op   : coverpoint op   { bins add = {0}; bins sub = {1}; illegal_bins bad = {2,3}; }
  cp_size : coverpoint size { bins small = {[0:3]}; bins big = {[4:7]}; }
  x_opsize: cross cp_op, cp_size;
endgroup
```

**UVaM-ish flow to narrate:** `uvm_test` builds `uvm_env` → `uvm_env` builds agent(s) + scoreboard + coverage → agent builds sequencer/driver/monitor → test raises a `sequence` on the sequencer → driver pulls items via `seq_item_port.get_next_item()` and drives the virtual interface → monitor samples the bus into a TLM analysis port → scoreboard + coverage subscribe → end-of-test checks and coverage sampling → report.

**FIFO full/empty logic (registered-pointer style):**
```systemverilog
assign empty = (wptr == rptr);
assign full  = (wptr + 1 == rptr);   // one slot reserved (simplest correct scheme)
```
(Be ready to also discuss the "extra bit / counter" scheme and the simultaneous read+write corner case.)

---

*Prepared from the JD attached to your Tenstorrent interview invitation. Most content above is standard DV-interview domain knowledge; the "RISC-V / Tensix / NoC" pointers are general role context — confirm company-specific details during the interview.*
