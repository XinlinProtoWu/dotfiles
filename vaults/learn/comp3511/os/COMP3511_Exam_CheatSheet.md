## 1. Chapter 1 — OS Fundamentals

| Term | Meaning |
| --- | --- |
| **OS** | Manages hardware and provides an environment for programs; intermediary between users/apps and hardware. |
| **Kernel** | Core OS always in memory, runs in kernel mode. |
| **Multiprogramming** | Keep several jobs in memory so CPU always has work. |
| **Multitasking** | Rapid CPU switching for interactive response. |
| **Protection** | Control access to hardware/software resources. |
| **Virtualization** | VMM/hypervisor runs OSes as virtual machines. |

**Von Neumann:** CPU (ALU, registers, control unit with PC/IR), memory (instructions + data), I/O, buses. Cycle: **fetch → decode → execute**.

**Interrupts:**

- **Interrupt:** asynchronous hardware event; transfers control to handler.
- **Trap/exception:** synchronous software-generated event (divide-by-zero, illegal access, system call).
- **Maskable** interrupt can be disabled; **non-maskable** cannot.
- **Interrupt vector:** table of handler addresses; priorities allow higher-priority interrupts to preempt lower ones.
- System calls enter kernel via **trap**.

**DMA:** device controller/DMA controller transfers blocks directly between device and memory, bypassing CPU; interrupts CPU when done. Avoids byte-by-byte **programmed I/O**.

**Storage hierarchy:** registers → cache → main memory → SSD/disk → tertiary.  
**Locality:** temporal (recently used again) and spatial (nearby used soon).  
**Buffer** may hold the only copy; **cache** holds a copy of data stored elsewhere.

$$
T_{\text{avg}} = hT_{\text{hit}} + (1-h)T_{\text{miss}}
$$

**Multiprocessor:** UMA = uniform memory access; NUMA = some memory faster; SMP = symmetric multiprocessing; multicore = multiple cores per chip.

**Dual mode:** user mode (mode bit 1) vs kernel mode (mode bit 0). Privileged instructions only in kernel mode. Timer prevents user monopolisation. System call transitions user → kernel → user. VMM machine switch saves/restores entire machine state.

---

## 2. Chapter 2 — OS Structures

**User services:** UI, program execution, I/O, file system, communication, error detection.  
**System services:** resource allocation, logging/accounting, protection/security.

**Interfaces:** CLI/shell (fetch–interpret–execute), GUI, touchscreen.

**System call vs API:**

- **System call** = programming interface to OS service; identified by number.
- **API** = functions programmers call (e.g., POSIX/libc); API hides system-call details and gives portability.
- Parameter passing: **registers**, **block/table in memory** (address in register), or **stack**.

**System-call types:** process control, file management, device management, information maintenance, communication, protection.

**Linker:** combines object files → executable. **Loader:** loads executable into memory.

**Policy vs mechanism:** policy = *what* to do; mechanism = *how* to do it.

| Structure | Key points |
| --- | --- |
| **Monolithic** | Entire kernel in one address space. Fast, but hard to debug/maintain. Linux is monolithic but modular. |
| **Layered** | Layers of abstraction, layer 0 = hardware. Simple, but overhead. |
| **Microkernel** | Minimal kernel; services in user space via message passing. Extensible/reliable, but slower. |
| **Modular** | Core kernel + loadable kernel modules (LKMs), e.g., drivers/filesystems. Flexible, dynamic. |
| **Hybrid** | Combines approaches (Windows/macOS). |

---

## 3. Chapter 3 — Processes

**Process** = executing program + address space + resources. **Program** = passive file on disk.

**Process parts:** text/code, data (global/static), heap (`malloc`), stack (locals/params/return addresses), PC/registers.

**States:** New → Ready → Running → Waiting → Ready → … → Terminated.  
Running → Ready on preemption; Running → Waiting on I/O/event.

**PCB fields:** state, PC, CPU registers, scheduling info, memory info, accounting, I/O status. Linux PCB = `struct task_struct`.

**Schedulers:**

| Scheduler | Role |
| --- | --- |
| **Long-term/job** | Disk/job queue → memory; controls degree of multiprogramming; good I/O/CPU mix. |
| **Short-term/CPU** | Ready queue → CPU; runs every few milliseconds. |
| **Medium-term** | Swapping: remove processes from memory to disk and back. |

**Context switch:** save old process state/PCB, load new state. Pure overhead; hardware-dependent.

**`fork()`:** child is almost exact copy; both continue after `fork()`. Returns **0** in child, **child PID > 0** in parent, **-1** on error. Linux uses copy-on-write. Each successful fork doubles process count.

**`exec()`:** replaces current program; on success **never returns**; -1 on failure. Variants: `l` list, `v` vector, `p` PATH, `e` environment.

**`wait(&status)`:** parent waits/reaps child; returns child PID or -1. `exit(0)` = normal.

| Term | Meaning |
| --- | --- |
| **Zombie** | Terminated but parent has not `wait()`ed; PCB/PID remains. |
| **Orphan** | Parent died first; adopted by `init`/`systemd`. |

**IPC models:**

| Model | Key points |
| --- | --- |
| **Shared memory** | Fast; processes read/write common region; synchronisation needed. |
| **Message passing** | Explicit `send`/`receive`; OS mediates; direct or indirect (mailbox). |

**Buffering:** zero capacity = sender waits (rendezvous); bounded = wait if full; unbounded = sender never waits.

**Pipes:**

- **Anonymous pipe:** `pipe(fd[2])`; `fd[0]` read, `fd[1]` write; unidirectional; related processes; disappears on exit; blocking I/O; close unused ends.
- **FIFO/named pipe:** `mkfifo(path, mode)`; persists as file; unrelated processes; blocking `open()` unless `O_NONBLOCK`; read data is consumed; not for broadcast. Use **two FIFOs** for two-way communication.

**Client–server:** socket endpoint = IP + port; connection identified by 4-tuple (src IP, src port, dst IP, dst port). **RPC** calls remote procedure like a local one.

---

## 4. Chapter 4 — Threads

**Thread** = unit of execution. Own: thread ID, PC, registers, stack. Shared: code, data, heap, open files, address space. Each thread has a **TCB**.

**Benefits:** responsiveness, resource sharing, economy, scalability.

**Concurrency** = interleaved progress on one CPU. **Parallelism** = simultaneous progress on multiple cores.  
**Data parallelism** = same operation on split data; **task parallelism** = different tasks on different cores.

| Model | Mapping | Key point |
| --- | --- | --- |
| **Many-to-One** | Many user → one kernel thread | Cheap, but one blocking call blocks all; no parallelism. |
| **One-to-One** | One user → one kernel thread | Max concurrency/parallelism; more overhead. |
| **Many-to-Many** | Many user → fewer/equal kernel threads | Good concurrency with less overhead; dynamic. |

**User threads:** library-managed, invisible to kernel. **Kernel threads:** OS-managed/scheduled.  
**LWP:** virtual processor bridging user and kernel threads; OS schedules kernel threads, not user threads.

**Threading issues:**

- `fork()` may duplicate all threads or only calling thread; `exec()` replaces all threads.
- **Signals:** synchronous (same process caused it) vs asynchronous (external event).
- **Cancellation:** asynchronous (immediate, unsafe) vs deferred (cleanup first, preferred).
- **TLS:** per-thread data.

**Linux:** no fundamental process/thread distinction; both are **tasks**. `clone()` flags decide sharing (address space, files, etc.). Share address space → thread-like; don't share → process-like.

---

## 5. Chapter 5 — CPU Scheduling

Processes alternate **CPU bursts** and **I/O bursts**. **Dispatcher** performs context switch, user-mode switch, jump; **dispatch latency** should be small.

| Policy | Scheduling occurs |
| --- | --- |
| **Non-preemptive** | Only when running process terminates/blocks/yields. |
| **Preemptive** | Involuntarily: timer/quantum expiry, higher-priority arrival, I/O completion. |

**Criteria:** CPU utilisation ↑, throughput ↑, turnaround ↓, waiting ↓, response ↓.

| Algorithm | Key points |
| --- | --- |
| **FCFS** | Arrival order; non-preemptive; **convoy effect** → long average wait. |
| **SJF** | Shortest next burst; non-preemptive; **optimal average waiting time**; burst unknown. |
| **SRTF** | Preemptive SJF; preempt if new burst < running remaining time. |
| **RR** | FCFS + quantum $q$; unfinished job goes to tail. Large $q$ → FCFS; small $q$ → overhead. |
| **Priority** | Highest priority first; starvation; fix with **aging**. |
| **MLQ** | Separate fixed queues; no movement between queues. |
| **MLFQ** | Processes move between queues; favours short/interactive jobs. |
| **RM** | Static priority; shorter period = higher priority; optimal static-priority real-time. |
| **EDF** | Dynamic priority; earliest deadline first; preemptive. |

**Prediction:**

$$
\tau_{n+1} = \alpha t_n + (1-\alpha)\tau_n
$$

**Metrics:**

$$
\text{turnaround} = \text{completion} - \text{arrival}
$$

$$
\text{waiting} = \text{turnaround} - \text{CPU burst}
$$

$$
\text{response} = \text{first run} - \text{arrival}
$$

**MLFQ textbook rules (Q0=4 ms, Q1=8 ms additional, Q2=FCFS):**

- New job → Q0 tail; Q0 jobs never preempted.
- Finish within quantum → leave; otherwise demote to next queue tail.
- Q1 runs only when Q0 empty; Q2 only when Q0/Q1 empty.
- New Q0 arrival preempts Q1/Q2; preempted job returns to **head**, keeps remaining quantum.
- Q1 cannot preempt Q2; only new Q0 arrivals cause preemption.

**PA2 MLFQ:** $N=1..4$, last queue FCFS. Per-queue quantum; demotion gives fresh quantum. New arrivals → Q0. Higher-priority non-empty queue runs. Lower-queue process preempted by new arrival stays at **front**, keeps remaining slice. Q0 not preempted by new arrivals. Merge consecutive same-process Gantt intervals.

**Thread scheduling:** **PCS** = thread library schedules user threads within one process; **SCS** = OS schedules all kernel threads onto CPUs.

**Multiprocessor:** asymmetric = master schedules; SMP = self-scheduling (common or per-CPU queues). **Push/pull migration** for load balancing. **Affinity:** hard (fixed subset) vs soft (OS tries); **NUMA** favours nearby memory.

**Evaluation:** analytical, queueing models (**Little's law** $n=\lambda W$), simulation.

---

## 6. Chapter 6 — Synchronization

**Race condition:** outcome depends on execution order/interleaving.  
Example: `counter++` = load, add, store; `counter--` similarly; interleaving can lose an update.

**Critical section:** code accessing shared data. Structure: entry → critical section → exit → remainder.

**Three requirements:**

1. **Mutual exclusion:** at most one process in its critical section.
2. **Progress:** if no one is in CS and some want in, one enters without indefinite delay.
3. **Bounded waiting:** after requesting, a process waits for a bounded number of other entries.

**Peterson’s algorithm (2 processes, software, busy wait):** shared `flag[2]`, `turn`.

```c
/* process i, j = 1-i */
flag[i] = true;
turn = j;
while (flag[j] && turn == j) ;
/* critical section */
flag[i] = false;
```

Satisfies all three requirements for two processes; complex and busy-waits.

**Hardware:**

- `test_and_set(&lock)`: returns old value, sets lock true.
- `compare_and_swap(&value, expected, new)`: swaps if current == expected.
- Both atomic; used to build locks. Simple spinlocks give mutual exclusion but not necessarily bounded waiting.
- **Atomic variables** (e.g., `atomic_int`) use CAS retry loops.

**Mutex lock:** `acquire()` / `release()`, both atomic. At most one holder. Busy-wait version = **spinlock**: wastes CPU but avoids context switch; good for short critical sections/multiprocessors.

**Semaphore $S$:** integer, atomic `wait(S)` / `signal(S)` (originally P/V).

- **Counting semaphore:** N resources; initialise to N.
- **Binary semaphore:** 0/1; can act like mutex, also used for ordering.
- Ordering: binary `synch = 0`; P1 does `S1; signal(synch);`; P2 does `wait(synch); S2;`.
- Blocking implementation: `wait` decrements first; if negative, block/enqueue. `signal` increments; if ≤ 0, wake one. Negative value magnitude = number waiting.

**Deadlock:** processes wait indefinitely for events only other waiters can cause. Example: P0 holds S waits Q; P1 holds Q waits S.  
**Starvation:** indefinite postponement (e.g., LIFO/priority semaphore queue).

**Mutex vs binary semaphore:** binary semaphore initialized to 1 can act as mutex, but semaphores can be initialized to 0 for ordering and lack mutex ownership semantics.

**Condition variable:** wait for a condition/event; always with a mutex.

- `pthread_cond_wait(&cond, &mutex)` **atomically releases mutex and sleeps**; returns after reacquiring mutex.
- Use `while (!condition)`, not `if` (re-check after wakeup).
- Hold mutex when changing condition and signalling.
- `signal` wakes one; `broadcast` wakes all.

**Bounded buffer:** `mutex=1`, `full=0`, `empty=n`.

```c
/* producer */                 /* consumer */
wait(empty);                   wait(full);
wait(mutex);                   wait(mutex);
/* add item */                 /* remove item */
signal(mutex);                 signal(mutex);
signal(full);                  signal(empty);
```

Resource semaphore **before** mutex; reversing can deadlock.

**Readers–writers:** `rw_mutex=1`, `mutex=1`, `read_count=0`.

```c
/* reader */                         /* writer */
wait(mutex);                         wait(rw_mutex);
read_count++;                        /* write */
if (read_count == 1)                 signal(rw_mutex);
    wait(rw_mutex);
signal(mutex);
/* read */
wait(mutex);
read_count--;
if (read_count == 0)
    signal(rw_mutex);
signal(mutex);
```

First reader locks data; last reader unlocks. `mutex` protects only `read_count`. Readers-preference can starve writers; writer-preference can starve readers.

---

## 7. Lab/API Essentials

### Compile

```bash
gcc source.c -o program
gcc -g source.c -o program        # debug info for gdb
gcc source.c -o program -lpthread # Pthreads
gcc -std=c99 -o mlfq mlfq.c
```

### Key system calls

```c
pid_t fork(void);                 // child 0, parent child PID, -1 error
pid_t wait(int *status);          // child PID or -1
int pipe(int fd[2]);              // fd[0] read, fd[1] write; 0/-1
int dup(int oldfd);               // lowest unused new fd
int dup2(int oldfd, int newfd);   // newfd becomes copy of oldfd
int open(const char *path, int flags, mode_t mode);
ssize_t read(int fd, void *buf, size_t count);   // 0=EOF, -1=error
ssize_t write(int fd, const void *buf, size_t count);
int close(int fd);
int mkfifo(const char *path, mode_t mode);
int access(const char *path, int mode);          // F_OK/R_OK/W_OK/X_OK
int chdir(const char *path);
int execlp(const char *file, const char *arg, ...); // no return on success
int execvp(const char *file, char *const argv[]);
```

### Process/pipe template

```c
pid_t pid = fork();
if (pid == 0) {
    /* child: close unused pipe ends, dup2, execvp */
    exit(0);
} else if (pid > 0) {
    /* parent: close unused ends, wait(NULL) */
}
```

### Redirect stdout

```c
int fd = open(path, O_CREAT | O_WRONLY | O_TRUNC, 0600);
dup2(fd, 1);
close(fd);
```

### `ls | wc -l`

```c
pipe(fd); pid = fork();
if (pid == 0) { close(1); dup2(fd[1],1); close(fd[0]); execlp("ls","ls",NULL); }
else          { close(0); dup2(fd[0],0); close(fd[1]); wait(0);
                execlp("wc","wc","-l",NULL); }
```

### Pthreads

```c
pthread_t tid;
pthread_create(&tid, NULL, fn, arg);
pthread_join(tid, NULL);
pthread_exit(0);
```

```c
pthread_mutex_t m;
pthread_mutex_init(&m, NULL);
pthread_mutex_lock(&m);
/* critical section */
pthread_mutex_unlock(&m);

sem_t s;
sem_init(&s, 0, value);   // pshared=0 for threads
sem_wait(&s);
sem_post(&s);

while (!condition)
    pthread_cond_wait(&cond, &mutex);
pthread_cond_signal(&cond);
```

### PA1 essentials

- Features: exit, custom SIGINT (`SIGINT` = 2), `cd` via `chdir`, `<`/`>` redirection via `open`+`dup2`, up to 8-stage pipes.
- Cannot use `system()` or `popen()`.
- External commands: `fork` → child `execvp`; parent `wait`.
- Pipelines: create N−1 pipes, fork each segment, connect stdin/stdout with `dup2`, close unused ends, wait for all.
- Built-ins (`cd`, `exit`) run in shell process.

### PA2 essentials

- N-level feedback queue; last queue FCFS.
- Input: `queue_num`, `time_quantum`, `process_table`.
- Output: parsed values + Gantt chart.
- Admit arrivals to Q0; run highest-priority non-empty queue; cap by quantum and next arrival; finish → remove, full quantum → demote, preempted → stay front with remaining slice.
- Merge consecutive same-process Gantt intervals.
- Test with `diff`; no hard-coding.

---

## 8. Last-Minute Must-Knows

- **Fork:** child gets copy; 0 in child, PID in parent.
- **Threads share memory; processes do not.**
- **`exec` replaces program and never returns on success.**
- **Pipe:** `fd[0]` read, `fd[1]` write; close unused ends.
- **`dup2(old,new)`** closes `new` if open, then duplicates.
- **Zombie** = terminated, not reaped; **orphan** = parent gone.
- **SJF** optimal average waiting (non-preemptive); **RR** good response; **FCFS** convoy effect.
- **MLFQ:** new Q0 arrival preempts lower queues; Q0 not preempted; preempted job keeps remaining quantum.
- **CS requirements:** mutual exclusion, progress, bounded waiting.
- **Peterson:** two processes, busy wait.
- **Mutex** = ownership; **binary semaphore** ≠ mutex.
- **Semaphore:** counting = N resources; binary = mutex/ordering.
- **Bounded buffer:** `wait(empty/full)` before `wait(mutex)`.
- **Readers–writers:** first reader locks, last unlocks; `mutex` protects `read_count`.
- **Condition variable:** always with mutex; `while` loop; `wait` releases then reacquires mutex.
- **Deadlock** = circular indefinite waiting; **starvation** = indefinite postponement.
