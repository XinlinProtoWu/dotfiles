# Chapter 5: CPU Scheduling

> Summary of **Chp5_summary.pdf** — CPU scheduling concepts, algorithms (FCFS, SJF/SRTF, RR, Priority, Multilevel Queues, MLFQ, Real-Time), thread & multiprocessor scheduling, and algorithm evaluation.

---

## 1. Why CPU Scheduling?

CPU scheduling is the basis of **multiprogramming**: by switching the CPU among processes/threads, the CPU stays productive instead of idling during I/O.

- A process's lifetime is a sequence of **CPU bursts** (computing) and **I/O bursts** (waiting for I/O).
- **CPU scheduling** = the task of selecting a process from the **ready queue**.
- The **dispatcher** gives CPU control to the selected process: it performs a **context switch**, switches to **user mode**, and jumps to the right place in the program.
- **Dispatch latency** = the time the dispatcher takes; it should be as small as possible.

> **Simple example:** Process A is computing when it requests disk I/O. Instead of letting the CPU idle, the scheduler picks process B from the ready queue, and the dispatcher switches the CPU to B. When A's I/O finishes, A goes back to the ready queue.

### Preemptive vs Non-preemptive

| Policy | When scheduling happens |
| --- | --- |
| **Non-preemptive** | Only when the running process **voluntarily** gives up the CPU: it terminates, or finishes its CPU burst (e.g., waits for I/O). |
| **Preemptive** | The CPU can be taken away **involuntarily**, e.g., a timer interrupt (RR quantum expires) or a higher-priority process joins the ready queue (new arrival, or I/O completion moving a process from waiting → ready). |

> **Simple example:** In a non-preemptive system, a process with a 100 ms burst blocks all others for 100 ms. In a preemptive RR system with a 10 ms quantum, the timer fires at t=10 and forces a switch.

---

## 2. Scheduling Criteria (often conflicting)

| Criterion | Definition |
| --- | --- |
| **CPU utilization** | Fraction of time the CPU is busy. Want it **high**. |
| **Throughput** | Number of jobs completed per unit time. Favors **short** jobs. |
| **Turnaround time** | Time from arrival to completion = waiting on ready queue + CPU execution (+ I/O in general). Want it **low**. |
| **Waiting time** | Total time a process spends **waiting on the ready queue** (not executing, not doing I/O). |
| **Response time** | Time from arrival until the **first** response (first time on CPU, or end of first quantum in RR). Most relevant for **interactive** jobs. |

> **Simple example:** A process arrives at t=0, waits 5 ms, then runs 3 ms on the CPU. Waiting time = 5 ms, turnaround = 5 + 3 = 8 ms, response time = 5 ms (it got its first response when it first ran).

- RR gives **short response time** but may give **worse** overall turnaround/waiting than FCFS. There is **no clear winner** between FCFS and RR in general — it depends on burst times, arrival patterns, and quantum size.

---

## 3. FCFS (First-Come, First-Served)

- Schedule purely by **arrival order** on the ready queue.
- **Non-preemptive**: once a process gets the CPU, it runs to the end of its CPU burst.

**Main problem — the Convoy Effect:** short processes get stuck behind one long process → excessively long **average waiting time**.

> **Simple example:** P1 (burst 24 ms) arrives first, then P2 and P3 (burst 3 ms each).
> FCFS order P1→P2→P3: waiting times are 0, 24, 27 → average = **17 ms**.
> If order were P2→P3→P1: waiting times are 0, 3, 6 → average = **3 ms**. The long job "conveys" everyone behind it.

---

## 4. SJF and SRTF

### SJF (Shortest Job First)
- Pick the process with the **shortest next CPU burst**.
- **Optimal (non-preemptive)**: gives the **minimum average waiting time** for a given set of processes.

### SRTF (Shortest Remaining Time First)
- The **preemptive** version of SJF: a newly arriving process (new→ready, or waiting→ready) preempts the running process if its burst is **shorter than the remaining time** of the running one.
- Note: processes already on the ready queue all have bursts **longer** than the running process's remaining time (that's the SJF part); only **new arrivals** can cause preemption.

**Practical problem:** the next CPU burst length is unknown and hard to predict, so SJF/SRTF are mainly used as a **yardstick** to compare other algorithms.

> **Simple example (SRTF):** P1 arrives at t=0 with burst 8; P2 arrives at t=1 with burst 4.
> At t=1, P2 (4) < P1 remaining (7) → P2 preempts, runs 1–5. Then P1 resumes 5–13.
> Waiting: P1 = 1, P2 = 0 → average 0.5 ms.

### Predicting the Next CPU Burst — Exponential Averaging

The next burst τₙ₊₁ is estimated from the last **actual** burst tₙ and the last **estimate** τₙ:

$$\tau_{n+1} = \alpha \, t_n + (1 - \alpha)\, \tau_n$$

- Expanding shows the estimate depends on **all past bursts** and the **initial estimate**, with **recent bursts weighted more** (weights decay by a factor of (1−α)).

> **Simple example:** α = 0.5, previous estimate τₙ = 10, actual burst tₙ = 6.
> τₙ₊₁ = 0.5×6 + 0.5×10 = **8**. If α = 0, we ignore new data (τ stays 10); if α = 1, we only trust the latest burst (τ = 6).

---

## 5. Round-Robin (RR)

- **FCFS order + preemption**: each process gets the CPU for at most one **time quantum** q.
- A process finishing its quantum unfinished rejoins the **tail** of the ready queue (FCFS order).
- Gives each process a **fair share** of CPU and **good response time** (ignoring context-switch cost).

**Choosing the quantum:**
- q very large (≥ all bursts) → RR **degenerates to FCFS**.
- q very small → **processor sharing**: n processes each appear to run on their own CPU at 1/n speed (if context-switch cost is negligible). But too small → context-switch overhead dominates.

> **Simple example:** P1, P2, P3 arrive at t=0 with bursts 24, 3, 3; q = 4.
> Gantt: P1(0–4), P2(4–7), P3(7–10), P1(10–14), P1(14–18), ... — P2 and P3 finish quickly instead of waiting 24 ms behind P1.

---

## 6. Priority Scheduling

- Each process has a **priority**; the CPU goes to the **highest-priority** process.
- Equal priorities → scheduled in **FCFS order** (possibly with RR).
- **SJF/SRTF are special cases**: priority = inverse of predicted next CPU burst.

**Problem — Starvation:** low-priority processes may wait **indefinitely** if higher-priority processes keep arriving.

**Solution — Aging:** gradually **increase** the priority of processes that have waited a long time, so they eventually run. (In practice, a timer is started when a process joins the ready queue.)

> **Simple example:** Low-priority batch job L waits while interactive high-priority jobs keep arriving. With aging, every 10 minutes of waiting bumps L's priority by 1, so eventually L outranks everything and runs.

---

## 7. Multilevel Queue Scheduling

- The ready queue is **partitioned** into separate queues (e.g., foreground/interactive vs background/batch), arranged by **priority**.
- The scheduler serves higher-priority queues first; each queue may use **its own algorithm** (e.g., RR for interactive, FCFS for batch).
- CPU time is divided among queues by **priority** or by **fixed percentage** (time slice).
- A process is **permanently assigned** to one queue — **no movement** between queues.
- Priority scheduling with RR is easily implemented this way.

---

## 8. Multilevel Feedback Queue (MLFQ)

- Like multilevel queue, but processes **can move between queues** — used to favor short/interactive jobs without knowing burst lengths in advance.
- **Parameters to specify:** number of queues; initial queue for a new process; scheduling algorithm per queue; policy for moving processes between queues.

### The Textbook 3-Queue Example (slides 5.32–5.34)

| Queue | Algorithm | Quantum |
| --- | --- | --- |
| Q0 (highest) | RR (FCFS order) | 4 ms |
| Q1 | RR (FCFS order) | 8 ms |
| Q2 (lowest) | FCFS | — (runs to completion) |

**Rules:**
1. A **new** job always enters **Q0** (tail). When it runs, it gets up to 4 ms. If its burst ≤ 4 ms it finishes and leaves; otherwise the timer expires and it moves to the **tail of Q1**. Q0 jobs are **never preempted**.
2. A Q1 job runs (FCFS order) **only when Q0 is empty**, for up to **8 additional ms**. If its burst ≤ 4 + 8 = 12 ms it finishes; otherwise it moves to the **tail of Q2**. (So any job with burst ≤ 12 ms never sees Q2.)
3. A Q2 job runs (FCFS) **only when Q0 and Q1 are both empty**.
4. A **new arrival to Q0 preempts** a running Q1 or Q2 job. The preempted job returns to the **head** of its queue and keeps its **remaining** quantum (Q1: total still 8 ms; it can be interrupted many times but never gets more than 8 ms total). Note Q1 jobs can never preempt Q2 jobs — the only preemption is triggered by **new arrivals into Q0**.

> **Simple example:** Job A (burst 20 ms) arrives at t=0.
> - Runs Q0: 0–4 (rem 16) → drops to Q1.
> - Runs Q1: 4–12 (rem 12) → drops to Q2.
> - Runs Q2: 12–32, finishes.
> If job B arrives at t=6 (into Q0) while A runs in Q1, B preempts A; B runs its 4 ms Q0 quantum, then A **resumes at the head of Q1 with 6 ms of its 8 ms quantum left**.

**Why it works well:** short jobs finish in Q0 quickly; long jobs sink to lower queues but still get CPU when nothing else is ready; interactive jobs stay responsive.

---

## 9. Real-Time Scheduling

- **Soft real-time**: real-time tasks get **priority** over non-real-time ones (no guarantee).
- **Hard real-time**: the system must **guarantee** timing (deadlines met).

### Rate-Monotonic (RM)
- For **periodic** tasks with **constant** processing time per period.
- **Static priority** + preemption: **shorter period → higher priority** (higher *rate*).
- **Optimal** among static-priority algorithms.

### Earliest-Deadline-First (EDF)
- **Dynamic priority**: the task with the **earliest deadline** gets the highest priority; also preemptive.
- Tasks need **not** be periodic and bursts need **not** be constant; a task just **announces its deadline** when it becomes runnable.

> **Simple example:** Task A: period 50, deadline 100 for its current instance. Task B: period 80, deadline 80 for its current instance. At a decision point both are ready: **RM** picks A (shorter period), **EDF** picks B (earlier deadline). They can disagree!

---

## 10. Thread Scheduling

- The OS schedules **kernel-level threads** onto CPUs. **User-level threads** are invisible to the OS — the thread library manages them, mapping them onto kernel threads (directly or via an **LWP — lightweight process**).

| Scope | Who schedules | What competes |
| --- | --- | --- |
| **PCS** (Process-Contention Scope) | The **thread library** schedules user threads onto available **LWPs** within one process (many-to-many / many-to-one models) | User threads of the **same process**; priority set by the programmer; library does not adjust it |
| **SCS** (System-Contention Scope) | The **kernel/OS** schedules kernel threads onto **CPUs** | **All kernel threads in the system** — this is ordinary CPU scheduling |

---

## 11. Multiprocessor Scheduling

- **Asymmetric multiprocessing**: one **master** processor handles all scheduling, I/O, and system activities; others run only user code. Simple — only one processor touches kernel data structures, no sharing issues.
- **SMP (Symmetric Multiprocessing)**: every processor **self-schedules** from a **common** ready queue or **per-processor** queues. Must avoid two processors picking the same process, and avoid losing processes.

### Multicore & Two-Level Scheduling
- A chip holds multiple **cores**; each core may have multiple **hardware threads**, each appearing to the OS as a **logical CPU**.
- Two scheduling levels: (1) OS schedules software (kernel) threads onto **logical CPUs** (normal CPU scheduling); (2) each core decides which **hardware thread** runs on the physical core.

### Load Balancing
- **Push migration**: a periodic task checks processor loads and moves processes **from** overloaded **to** idle/less-loaded processors.
- **Pull migration**: an **idle processor** pulls a waiting task from a busy one.
- Real systems commonly use **both**.

### Processor Affinity
- Migrating a process forces its **cache to be invalidated and repopulated** — expensive.
- **Processor affinity**: a process "prefers" the processor it's currently on.
  - **Hard affinity**: a system call lets a process **fix** a subset of processors it may run on (guaranteed).
  - **Soft affinity**: the OS **tries** to keep a process on the same processor but **does not guarantee** it.
- **NUMA** (Non-Uniform Memory Access): a CPU accesses some memory faster than other memory → affinity to **both** processor and memory matters.
- On multicore systems, load balancing must be weighed against the **cache-invalidation cost** of moving threads between cores.

> **Simple example:** A thread with hard affinity {CPU0, CPU1} waits on CPU0's queue. Even if CPU2 is idle, the OS **may not** migrate the thread to CPU2 — hard affinity is a hard constraint.

---

## 12. Algorithm Evaluation

- **Analytical methods**: mathematical analysis of performance — needs exact input known in advance.
- **Queueing models**: capture performance with mathematical distributions (e.g., **Little's formula**: average number waiting = arrival rate × average waiting time, `n = λ × W`) — but only for a few known distributions.
- **Simulation**: imitate the algorithm on a representative workload (benchmarks) and measure — approximates real system performance.
