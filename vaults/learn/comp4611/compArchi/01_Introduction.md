# Topic 1 — Introduction to Computer Architecture

> Source: `COMP4611L1_2026F.pdf` (Lecture 1)

## What this course is about

Computer architecture = **the science and art of designing computing platforms** (hardware,
the SW/HW interface, system software, and the programming model) **to meet design goals**.

Typical design goals that pull a design in different directions:

- Highest performance on workload X/Y/Z
- Longest battery life at a given size/cost
- Best performance-per-cost across all workloads
- Reliability, programmability, security, energy, …

> ⚠️ **Key idea — trade-offs.** A supercomputer and a smartphone solve different problems,
> but they share the same fundamental principles. Every design choice is a trade-off.

## Levels of transformation (the abstraction stack)

![[COMP4611L1_2026F.pdf#page=17]]

*Problem → Algorithm → Program/Language → System SW → ISA → Microarchitecture → Logic →
Devices → Electrons (Lecture 1, p. 17).*

- **ISA (Instruction Set Architecture)** — the *contract* between software and hardware:
  what the programmer assumes the hardware guarantees.
- **Microarchitecture** — one particular *implementation* of the ISA (many are possible).
- **Abstraction** — a higher layer only needs the interface of the layer below, not its internals.

> 💡 **Why look beneath abstractions?** When something is slow, wrong, or power-hungry, the
> cause is often in a layer you cannot see if you only use the interface.

## History: why architecture matters *now*

- **Moore's Law era (≈1970–2005):** transistors doubled per unit area every 18–24 months
  **and** Dennard scaling let clock speeds rise. Result ≈ 2× performance every 18 months with
  *no new ideas needed* — "code not fast enough? just wait 2 years."
- **End of easy gains (≈2005):** Dennard scaling ended; clocks stuck at ~2.5–3.5 GHz.
  More transistors no longer mean faster single threads.
- **Post-Moore era:** performance now comes from **microarchitectural innovation** and
  **Domain-Specific Architectures (DSAs)**.

### General-purpose vs. domain-specific vs. special-purpose

| | General-purpose CPU | DSA (GPU, FPGA) | ASIC |
|---|---|---|---|
| Example | Apple M1 | Nvidia GPU, Xilinx FPGA | Cerebras WSE-2 |
| Flexibility | Run any program | Run a *domain* of programs | One fixed function |
| Efficiency | Lowest per-task | Middle | Highest |
| Programmability | Easiest | Harder | Hardest |

- A **DSA** is *not* an ASIC: it still runs software, but it is tailored to a whole domain
  (e.g., graphics, ML) rather than one program.

## Simple example — why a specialized unit helps

Imagine you must do the same operation `a×b+c` (a *multiply-add*) 1 billion times:

- A general CPU executes `mul` then `add` as **two separate instructions**.
- A **DSA/GPU** has a single *fused multiply-add* (FMA) unit → half the instructions,
  half the power, higher throughput.

That single hardware/ISA decision (offering FMA) is an architecture choice that crosses the
ISA/microarchitecture boundary to serve the ML domain.

## What the architect does (four directions)

- **Look backward** — learn from past designs and their trade-offs.
- **Look forward** — dream up new designs and evaluate them.
- **Look up** — understand the important problems/applications.
- **Look down** — understand device/circuit technology and its future.

## Takeaways

1. Design starts from **workloads + goals**; performance/energy/cost/reliability require explicit trade-offs.
2. Understanding the layers *below* your own lets you make better **cross-layer** decisions.
3. Post-Moore, architecture (not process scaling) is the main lever for performance.
