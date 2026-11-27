# COMP 3511 — Operating Systems  
## Final Exam Review: Chapters 1–6 + Lab/PA Notes

> **Sources used:** lecture notes for Chapters 1–6 (including the combined Chapter 6/7 synchronization notes), Chapter 2/3/6 PDFs, Chapter 3/4/5 summaries, and the `.pptx` lab notes for Labs 1–6 under `labs/`.
>
> **How to use this document:** It is organised as an open-book index. The tables, formulas, code templates, and “exam traps” are the parts to print or tab first.

---

# 0. Exam Format and Rules

> **Reference: Chapter 1.**

- **Open-book, open-notes exam.** You may bring **any printed materials**.
- The exam booklet is **double-sided**, so bring your **own rough-work sheets**.
- There may be questions related to **PA1/PA2** or **coding questions using APIs discussed in labs**. Printing the lab notes is recommended.
- An **electronic calculator** is allowed.
- **No other electronic devices** are permitted. You **cannot** use a mobile phone or tablet as a calculator, even if it is offline.
- Answer **all questions in the space provided** in the examination booklet.
- Write neatly, legibly, and concisely. Use rough sheets if needed to organise your thoughts.
- Read each question carefully. For coding questions, state assumptions and keep the code short and correct.

### Practical preparation checklist

- Print/tab: **lab API cheat sheet**, **fork/pipe/dup examples**, **Pthreads + mutex + semaphore + condition-variable templates**, **MLFQ rules**, **scheduling formulas**.
- Bring: calculator, rough sheets, pens/pencils, printed notes.
- Do not rely on searching electronic files during the exam.

---

# 1. Chapter 1 — Introduction and OS Fundamentals

## 1.1 Basic definitions

| Term | Meaning |
| --- | --- |
| **Operating system (OS)** | A program that manages computer hardware and provides an environment for programs to execute. It acts as an intermediary between users/applications and hardware. |
| **Kernel** | The core part of the OS that is always resident in memory and runs in kernel mode. |
| **System programs** | Programs shipped with the OS that provide utilities/services (shell, compiler, file manager, etc.). |
| **Resource allocator** | The OS allocates CPU, memory, I/O devices, and files among competing processes. |
| **Control program** | The OS controls execution of programs and operation of I/O devices. |

**User goals of an OS:** convenient, easy to use, reliable, safe, fast.  
**System goals:** easy to design/implement/maintain, flexible, reliable, error-free, efficient.

## 1.2 Computer-system organisation

**Von Neumann architecture:**

- **CPU**: contains the **ALU** (arithmetic/logic unit), **registers**, and a **control unit**.
- **Control unit**: contains the **program counter (PC)** and **instruction register (IR)**.
- **Memory**: stores both **instructions and data**, plus caches.
- **I/O devices**, **buses**, and **device controllers**.
- **Secondary storage** (disk/SSD) for persistent data.

**Instruction cycle:** fetch → decode → execute → repeat.

- The **PC** holds the address of the next instruction to fetch.
- The **IR** holds the instruction currently being decoded/executed.

## 1.3 Interrupts, traps, and exceptions

| Concept | Meaning |
| --- | --- |
| **Interrupt** | A hardware signal that transfers control to an interrupt handler so the CPU can respond to an asynchronous event (e.g., device completion, timer). |
| **Trap / exception** | A **software-generated interrupt** caused by an error or a user request. Examples: divide-by-zero, illegal memory access, privileged instruction in user mode, system call. |
| **Maskable interrupt** | Can be temporarily disabled by the CPU during critical processing. Used by device controllers. |
| **Non-maskable interrupt** | Cannot be disabled; used for severe events such as memory errors or power failure. |
| **Interrupt vector** | A table containing the addresses of interrupt handlers, indexed by interrupt number. |
| **Interrupt priority** | Lets a high-priority interrupt preempt a low-priority interrupt handler. |

- A **system call** enters the kernel via a **trap**.
- Traps usually have **lower priority** than device interrupts.
- Interrupts allow the CPU to overlap computation with I/O.

## 1.4 I/O and DMA

- Each **device controller** controls one device and has a **local buffer**.
- The controller moves data between the device and its local buffer, then interrupts the CPU.
- **Programmed I/O**: CPU repeatedly checks device status and moves data one byte at a time. Wasteful for fast devices/large transfers.
- **DMA (Direct Memory Access)**: a DMA controller transfers a block directly between device and main memory, bypassing the CPU; it interrupts the CPU when finished.

**Typical DMA steps:**

1. OS writes a DMA command block into memory: source, destination, read/write mode, byte count.
2. OS writes the command-block location to the DMA controller.
3. DMA controller operates the memory bus directly.
4. Data is transferred without CPU involvement.
5. When complete, DMA controller interrupts the CPU.
6. CPU handles completion.

## 1.5 Storage hierarchy and caching

**Storage hierarchy (fast/small/expensive → slow/large/cheap):**

1. CPU registers
2. Cache (L1/L2/L3)
3. Main memory (RAM)
4. SSD / disk
5. Tertiary storage (tape, optical, etc.)

**Cache average access time:**

$$
T_{\text{avg}} = h \cdot T_{\text{hit}} + (1-h)\cdot T_{\text{miss}}
$$

where $h$ is the hit ratio. Equivalently, using miss ratio $m = 1-h$:

$$
T_{\text{avg}} = h T_{\text{hit}} + m T_{\text{miss}}
$$

**Locality:**

- **Temporal locality:** an item used recently is likely to be used again soon.
- **Spatial locality:** items near a recently used item are likely to be used soon.

**Buffer vs cache:**

- **Buffer** may hold the **only existing copy** of data temporarily.
- **Cache** holds a **copy** of data that resides elsewhere, on faster storage.

## 1.6 Multiprocessor and multicore systems

| Term | Meaning |
| --- | --- |
| **UMA** | Uniform Memory Access: all CPUs access main memory with roughly equal latency. |
| **NUMA** | Non-Uniform Memory Access: a CPU accesses some memory faster than other memory. |
| **SMP** | Symmetric Multiprocessing: multiple processors share main memory; each has its own registers/cache; all run OS code. |
| **Multicore** | Multiple cores on one chip; faster on-chip communication and lower power than multiple separate chips. |

## 1.7 Dual-mode operation and protection

- Hardware provides a **mode bit**:
  - **User mode:** mode bit = 1.
  - **Kernel mode:** mode bit = 0.
- Certain instructions are **privileged** and can execute only in kernel mode: I/O control, timer management, interrupt management, etc.
- If a user program attempts a privileged instruction, hardware treats it as illegal and **traps** to the OS.
- **Timer** prevents a user program from monopolising the CPU; the OS sets it before giving control to user code.
- Mode transitions:
  - **System call:** user → kernel → user.
  - **Interrupt:** asynchronous external event → kernel handler.
  - **Trap/exception:** synchronous internal event → kernel handler.

**Virtualization:** a **VMM/hypervisor** runs operating systems as virtual machines. A **machine switch** between VMs saves/restores the entire machine state, including privileged hardware state.

## 1.8 Important OS terms

| Term | Meaning |
| --- | --- |
| **Multiprogramming** | Keep several jobs in memory so the CPU always has something to execute. |
| **Multitasking** | Extension of multiprogramming: CPU scheduling switches rapidly between processes for fast response. |
| **Multiprocessing** | Multiple CPUs/cores execute processes simultaneously. |
| **Protection** | Control access to hardware/software resources. |
| **Security** | Defend the system from external/internal attacks; authentication, authorization. |
| **Virtualization** | Abstract hardware into multiple execution environments (virtual machines). |

## 1.9 Chapter 1 exam traps

- **Interrupt ≠ trap:** interrupts are asynchronous/hardware; traps/exceptions are synchronous/software-generated.
- **DMA does not eliminate interrupts**; it reduces CPU involvement and interrupts once per block.
- **Cache hit ratio formula** uses hit time and miss time; do not confuse hit ratio with miss ratio.
- **Dual mode protects the OS from user programs**, and user programs from each other.
- **System call is not a normal function call**; it crosses the user/kernel boundary via a trap.

---

# 2. Chapter 2 — Operating-System Structures

## 2.1 OS services

**Services helpful to users:**

1. **User interface** — CLI, GUI, touchscreen.
2. **Program execution** — load, run, terminate normally or abnormally.
3. **I/O operations** — file/device I/O.
4. **File-system manipulation** — create/read/write/delete/search files/directories, permissions.
5. **Communications** — shared memory or message passing, local or networked.
6. **Error detection** — CPU/memory/I/O/user errors; debugging facilities.

**Services for efficient system operation:**

1. **Resource allocation** — CPU cycles, memory, file storage, I/O devices.
2. **Logging/accounting** — track resource usage.
3. **Protection and security** — controlled access; authentication; defend against invalid access.

## 2.2 User interfaces

| Interface | Description |
| --- | --- |
| **CLI / command interpreter / shell** | Fetches a command, interprets it, executes it. Examples: bash, csh, ksh. |
| **GUI** | Desktop metaphor with icons, windows, mouse/keyboard. |
| **Touchscreen** | Gestures, virtual keyboard, voice commands. |

A shell’s main loop: **prompt → read command → parse → execute → wait → repeat**.

## 2.3 System calls and APIs

- **System call:** programming interface to OS services.
- **API:** a set of functions available to programmers, including parameters and return values.
- Applications normally call an **API** (e.g., POSIX/libc), which invokes the actual system call.
- **Why use APIs instead of direct system calls?**
  1. **Portability** — same API across systems.
  2. **Hides complex details** of the underlying system call.

**System-call interface:**

- Each system call has a **number/ID**.
- The interface maintains a table indexed by these numbers.
- It intercepts API calls, invokes the correct system call, and returns status/values.

**Three ways to pass parameters to the OS:**

1. **Registers** — parameters placed directly in registers.
2. **Block/table in memory** — address of the block passed in a register.
3. **Stack** — parameters pushed onto the stack and popped by the OS.

## 2.4 Types of system calls

| Type | Examples |
| --- | --- |
| **Process control** | create, terminate, end, abort, load, execute, allocate/free memory, wait |
| **File management** | create, open, close, read, write, delete, seek, get/set attributes |
| **Device management** | request/release device, read/write device, get/set attributes |
| **Information maintenance** | get/set time/date, process/file/device attributes |
| **Communications** | send/receive messages, create/delete connections, shared memory |
| **Protection** | get/set permissions, allow/deny access |

## 2.5 System programs, linker, loader

- **System programs** provide utilities: file management, status information, programming support (compilers, assemblers, debuggers), program loading/execution, communications, background services.
- **Linker:** combines relocatable object modules into a single executable.
- **Loader:** loads the executable into memory and makes it eligible to run.

**Build pipeline:**

```
source .c ──compiler──> object .o ──linker──> executable ──loader──> process in memory
```

## 2.6 OS design and implementation

- **Policy:** *what* will be done (e.g., which process gets CPU next, how long a time quantum).
- **Mechanism:** *how* it is done (e.g., timer interrupt, context-switch code).
- Separating policy and mechanism gives flexibility.

## 2.7 OS structures

| Structure | Description | Pros | Cons |
| --- | --- | --- | --- |
| **Monolithic** | Entire kernel in one static binary, one address space. | Fast: little overhead in system-call interface. | Hard to debug/maintain/secure; everything coupled. |
| **Layered** | OS divided into layers; layer 0 = hardware, layer N = user interface; each layer uses lower layers. | Abstraction, modularity, easier debugging. | Extra overhead crossing layers; hard to define layers cleanly. |
| **Microkernel** | Minimal kernel: basic process/memory management + communication (message passing); most services run in user space. | Extensible, small kernel, adaptable, reliable/secure. | Performance overhead from message passing/user-kernel switches. |
| **Modular** | Core kernel + **loadable kernel modules (LKMs)** linked at boot or runtime. | Dynamic, flexible, no recompilation; good performance. | Module interfaces must be designed carefully. |
| **Hybrid** | Combines multiple approaches. | Balances performance/flexibility. | More complex. |

**Examples:**

- **Linux:** monolithic kernel, but supports **loadable kernel modules**; applications use **glibc** to reach the system-call interface.
- **Solaris:** modular approach.
- **Windows/macOS:** hybrid structures.

## 2.8 Chapter 2 exam traps

- **API ≠ system call.** API is what the programmer calls; system call is the kernel entry.
- **Linker vs loader:** linker combines object files; loader puts the executable into memory.
- **Policy vs mechanism:** policy decides *what*; mechanism decides *how*.
- **Microkernel is not necessarily faster** — it is more reliable/extensible but often slower due to message passing.
- **Monolithic is not the same as “no modules”** — Linux is monolithic but modular.

---

# 3. Chapter 3 — Processes

## 3.1 Process concept

- **Process** = an instance of an executing program; consists of an **address space** and one or more **threads of control**.
- **Program** = passive entity stored on disk (executable).
- **Process** = active entity with a program counter, registers, and associated resources.
- One program can have multiple processes.
- A process can be an execution environment for another program (e.g., JVM).

**Parts of a process:**

| Part | Contents |
| --- | --- |
| **Text section** | Program code. |
| **Data section** | Global/static variables (initialized and uninitialized). |
| **Heap** | Dynamically allocated memory (`malloc`/`free`). |
| **Stack** | Function parameters, return addresses, local variables. |
| **Program counter / registers** | Current execution state. |

**Memory layout:** typically text, initialized data, uninitialized data (BSS), heap (grows upward), stack (grows downward), plus `argc`/`argv`.

## 3.2 Process states and transitions

| State | Meaning |
| --- | --- |
| **New** | Process is being created; resources being allocated. |
| **Ready** | Waiting to be assigned to a CPU core. |
| **Running** | Instructions are being executed. |
| **Waiting** | Waiting for an event (I/O completion, signal, etc.). |
| **Terminated** | Finished execution; resources being deallocated. |

**Transitions:**

- New → Ready: admitted.
- Ready → Running: scheduler dispatches.
- Running → Waiting: process requests I/O or waits for an event.
- Waiting → Ready: event completes.
- Running → Ready: preemption/time quantum expires.
- Running → Terminated: exit.

Only **one** process/thread per CPU core can be **Running** at a time.

## 3.3 Process Control Block (PCB)

The PCB stores per-process information:

- Process state
- Program counter
- CPU registers (accumulators, index registers, stack pointers, general registers, condition codes)
- CPU scheduling information (priority, queue pointers, scheduling parameters)
- Memory-management information (memory allocated, page/segment tables)
- Accounting information (CPU used, elapsed time, time limits)
- I/O status information (allocated devices, open files)

In Linux, the PCB is `struct task_struct`; all processes are kept in a circular doubly linked **task list**.

## 3.4 Process scheduling concepts

- **Process scheduler:** selects a process from available processes for execution on a CPU core.
- **Degree of multiprogramming:** number of processes currently in memory.
- **I/O-bound process:** many short CPU bursts; spends more time doing I/O.
- **CPU-bound process:** few long CPU bursts; spends more time computing.
- **Ready queue:** processes ready and waiting for CPU.
- **Wait queue(s):** processes waiting for events.

| Scheduler | Role | Frequency |
| --- | --- | --- |
| **Long-term / job scheduler** | Selects processes from disk/job queue into memory; controls degree of multiprogramming; aims for good I/O/CPU mix. | Seconds/minutes; absent on many personal computers. |
| **Short-term / CPU scheduler** | Selects a process from the ready queue and allocates a CPU core. | Milliseconds; must be fast. |
| **Medium-term scheduler** | Removes processes from memory to disk (**swapping**) and brings them back later. | Used when memory pressure/degree of multiprogramming must be reduced. |

## 3.5 Context switch

- A **context switch** occurs when the CPU switches from one process to another.
- The OS saves the old process’s context (registers, PC, stack pointer, etc.) in its PCB and loads the new process’s saved context.
- **Context-switch time is overhead:** the CPU does no useful user work during the switch.
- Switch time depends on hardware, number of registers, memory speed, and special instructions.
- Switching between **threads** of the same process is generally cheaper than switching between processes because the address space does not change.

## 3.6 Process creation and termination

### `fork()`

- Creates a new child process that is an **almost exact copy** of the parent.
- Child gets a **copy** of the parent’s address space (Linux uses **copy-on-write**).
- Both parent and child continue at the instruction **after** `fork()`.
- The child inherits open files and I/O state.

**Return values:**

| Return value | Meaning |
| --- | --- |
| **< 0** | `fork()` failed; no child created. |
| **0** | Returned in the **child**. |
| **> 0** | Returned in the **parent**; value is the child’s PID. |

```c
pid_t pid = fork();

if (pid < 0) {
    perror("fork");
} else if (pid == 0) {
    /* child */
} else {
    /* parent; pid is child's PID */
}
```

**Fork counting:** each successful `fork()` doubles the number of processes. For example, two unconditional forks create $2^2 = 4$ processes.

### `exec()` family

- Replaces the current process’s program with a new program.
- On success, **does not return**; on failure, returns **-1**.
- The PID stays the same; the address space is replaced.
- Common variants:

| Variant | Meaning |
| --- | --- |
| `execl`, `execle` | Arguments listed one by one (`l` = list), terminated by `NULL`. |
| `execv`, `execve` | Arguments passed as an array (`v` = vector). |
| `execlp`, `execvp`, `execvpe` | `p` = search `PATH`; `e` = pass environment. |

```c
execlp("ls", "ls", "-l", "-h", NULL);
/* never returns unless error */
```

```c
char *args[] = { "ls", "-l", "-h", NULL };
execvp("ls", args);
```

### `wait()`

- Parent waits for a child to terminate and collects its exit status.
- Returns the child PID on success, -1 on error.
- `wait(NULL)` ignores the status.

```c
int status;
pid_t child = wait(&status);
```

The raw status is encoded; for portable code use `WIFEXITED(status)` and `WEXITSTATUS(status)`. In the lab examples, `exit(0)` gives status 0.

### Process termination: zombies and orphans

| Term | Meaning |
| --- | --- |
| **Zombie** | Process has terminated, but parent has not called `wait()` yet. Its PCB/PID remains in the process table. It uses no CPU/memory but occupies a table entry. |
| **Orphan** | Parent terminated before calling `wait()`. The child keeps running; `init` (PID 1) or `systemd` adopts and eventually reaps it. |

A process briefly becomes a zombie before its parent reaps it. If the parent never reaps it, it stays a zombie until the parent exits (then `init` reaps it).

## 3.7 Interprocess Communication (IPC)

- **Independent process:** cannot affect or be affected by other processes.
- **Cooperating process:** can affect/be affected; needs IPC.
- Benefits of cooperation: information sharing, computation speedup, modularity, convenience.

### Two basic IPC models

| Model | How it works | Pros/cons |
| --- | --- | --- |
| **Shared memory** | Processes share a region of memory; communication is implicit (write/read shared variables). | Fast after setup; must handle synchronisation explicitly. |
| **Message passing** | Processes exchange explicit messages via `send()`/`receive()`; the OS mediates. | Simpler for distributed systems; overhead of system calls/copying. |

**Direct vs indirect communication:**

- **Direct:** sender names the receiver (and vice versa).
- **Indirect:** messages go to a **mailbox/port**; sender/receiver need not know each other’s identity.

**Buffering / queue capacity:**

| Capacity | Behaviour |
| --- | --- |
| **Zero capacity** | No queue; sender must wait for receiver (rendezvous). |
| **Bounded capacity** | Finite queue; sender waits only if full. |
| **Unbounded capacity** | Infinite queue; sender never waits. |

## 3.8 Pipes

### Ordinary/anonymous pipes

- Created by `pipe(int fd[2])`.
- **Unidirectional:** `fd[0]` = read end, `fd[1]` = write end.
- Typically used between a parent and child created by `fork()`.
- Treated like a special file; use `read()`/`write()`.
- Disappears when the communicating processes terminate.
- **Blocking I/O:** `read()` blocks if no data; `write()` can block if the pipe is full.
- A pipe has a finite buffer; writes larger than `PIPE_BUF` may not be atomic.

```c
int fd[2];
pipe(fd);
pid_t pid = fork();

if (pid == 0) {          /* child writes */
    close(fd[0]);
    write(fd[1], "hello", 6);
    close(fd[1]);
} else {                 /* parent reads */
    close(fd[1]);
    char buf[10] = {0};
    read(fd[0], buf, 6);
    printf("%s\n", buf);
    close(fd[0]);
}
```

**Important:** close unused ends. Otherwise `read()` may block forever because a writer still exists.

### Named pipes / FIFOs

- Created with `mkfifo(const char *path, mode_t mode)`; appears as a file in the filesystem.
- Does **not** require a parent–child relationship.
- Persists until explicitly removed.
- Opened with `open()` and used with `read()`/`write()`/`close()`.
- **Blocking by default:** `open()` blocks until the other end is opened; `open(..., O_NONBLOCK)` makes it non-blocking.
- Once data is read from a FIFO, it is **discarded**; it is not a regular file that multiple readers can re-read.
- A FIFO should **not** be used for broadcasting to multiple readers; only one reader gets each item.
- **Bidirectional nuance:** a FIFO can technically be opened `O_RDWR`, but standard FIFO communication is **one-way per direction**. Do **not** use a single FIFO for request/response: a process may read its own message. Use **two FIFOs** or **two pipes** for two-way communication.

## 3.9 Client–server communication

- **Server** runs continuously at a well-known address; **clients** initiate contact.

### Sockets

- A **socket** is an endpoint of communication.
- A connection is a pair of sockets.
- Endpoint = **IP address + port number**.
- A connection is uniquely identified by the **4-tuple**: (source IP, source port, destination IP, destination port).

### RPC (Remote Procedure Call)

- Client calls a procedure that runs on a remote machine, as if it were local.
- The call is packaged/marshalled, sent to the server, executed, and the result returned.

## 3.10 Chapter 3 exam traps

- **`fork()` returns twice** (once in parent, once in child), not once.
- **Child’s variables are copies**; changes do not affect the parent after `fork()`.
- **`exec()` replaces the program**, so code after a successful `exec` does not run.
- **`wait()` is needed to reap children**; otherwise zombies remain.
- **Orphan ≠ zombie:** orphan has no parent; zombie has a parent that has not waited.
- **Pipe ends:** `fd[0]` is read, `fd[1]` is write. Closing unused ends prevents hangs.
- **Named pipe is not a broadcast medium**, and a single FIFO is not reliable for two-way communication.

---

# 4. Chapter 4 — Threads

## 4.1 What is a thread?

- A **thread** is a flow of control within a process; the basic unit of execution scheduled by the CPU.
- Each thread has its **own**:
  - Thread ID
  - Program counter
  - Register set
  - Stack
- Threads in the same process **share**:
  - Code/text
  - Data
  - Heap
  - Open files and I/O state
  - Address space
- Each thread is represented by a **Thread Control Block (TCB)** containing its state and scheduling/accounting information.
- If a process has multiple threads, the process itself has no single state; each thread has a state.

## 4.2 Why threads? Benefits

1. **Responsiveness** — one thread can keep the UI responsive while another blocks on I/O.
2. **Resource sharing** — threads share memory/files automatically; no IPC needed.
3. **Economy** — thread creation and context switching are cheaper than for processes.
4. **Scalability** — threads can run in parallel on multiple cores.

## 4.3 Concurrency vs parallelism

| Concept | Meaning |
| --- | --- |
| **Concurrency** | Multiple threads make progress over a single CPU by interleaving. |
| **Parallelism** | Multiple threads make progress simultaneously on different CPU cores. |

- Single-core system: only concurrency.
- Multicore/multiprocessor: parallelism possible.

**Data parallelism:** split the same data across cores; each core runs the same operation on its subset.  
**Task parallelism:** distribute different tasks/operations across cores.

## 4.4 Multithreading models

| Model | Mapping | Pros | Cons |
| --- | --- | --- | --- |
| **Many-to-One** | Many user threads → one kernel thread | Cheap/fast thread management in user space | One blocking system call blocks the whole process; no parallelism |
| **One-to-One** | Each user thread → one kernel thread | Maximum concurrency; parallel on multicore | More overhead; OS limits number of threads |
| **Many-to-Many** | Many user threads → smaller/equal number of kernel threads | Good concurrency with less overhead; user threads not limited by kernel threads | More complex; kernel/library cooperate dynamically |

**User threads:** managed by a thread library in user space; invisible to the kernel.  
**Kernel threads:** supported/managed by the OS; scheduled by the OS.

### Lightweight Process (LWP)

- Intermediate structure between user threads and kernel threads.
- To the thread library, an LWP looks like a **virtual processor** on which a user thread can run.
- Each LWP is attached to one kernel thread.
- If the kernel thread blocks, its LWP blocks.
- **The OS schedules kernel threads, not user threads.** The TCB is associated with the kernel thread in this model.

## 4.5 Threading issues

### `fork()` and `exec()` in multithreaded programs

- `fork()` may:
  1. Duplicate **all** threads of the parent, or
  2. Duplicate **only the calling thread**.
- `exec()` replaces the entire process, including all threads.
- If `exec()` is called immediately after `fork()`, duplicating only the calling thread is sufficient.

### Signals

- **Synchronous signal:** delivered to the same process that caused it (e.g., divide-by-zero, illegal memory access).
- **Asynchronous signal:** generated by an external event (e.g., timer expiry, `kill`).
- Handled by a **default handler** or a **user-defined handler** that overrides it.
- In multithreaded programs, you must decide which thread receives/handles a signal.

### Thread cancellation

| Type | Meaning | Issue |
| --- | --- | --- |
| **Asynchronous cancellation** | Stop the target thread immediately. | May leave resources/locks in an inconsistent state. |
| **Deferred cancellation** | Target checks a cancellation point and terminates cleanly. | Preferred; allows cleanup. |

### Thread-local storage (TLS)

- Some data should be **per-thread**, not shared (e.g., `errno`, thread-specific buffers).
- TLS gives each thread its own copy of a variable.

## 4.6 Linux: processes vs threads and `clone()`

- Linux does not fundamentally distinguish processes and threads; it calls both **tasks**.
- `clone()` creates a task with configurable sharing:
  - Share address space → behaves like a thread.
  - Do not share address space → behaves like a process.
- **Flags** determine what is shared: address space, file descriptors, signal handlers, etc.
- `clone()` also specifies a function (`*fn`) for the new task to execute.
- `fork()` is essentially a `clone()` with minimal sharing; threads use `clone()` with `CLONE_VM`, etc.

## 4.7 Chapter 4 exam traps

- **Threads share memory; processes do not.** This is the key difference for output/race questions.
- **Each thread has its own stack and registers**, but shares code/data/heap.
- **Many-to-One** cannot run threads in parallel; one blocking call blocks all.
- **One-to-One** gives parallelism but more overhead.
- **`fork()` in a multithreaded process** may duplicate only the calling thread; the child does not automatically have all parent threads.
- **`exec()` kills all threads** because it replaces the whole process image.
- **User-level threads are invisible to the OS scheduler.**

---

# 5. Chapter 5 — CPU Scheduling

## 5.1 Basics

- A process alternates between **CPU bursts** and **I/O bursts**.
- **CPU scheduling** selects a process from the ready queue.
- **Dispatcher** gives CPU control to the selected process: context switch, switch to user mode, jump to the right program location.
- **Dispatch latency:** time taken by the dispatcher; should be small.

**Preemptive vs non-preemptive:**

| Policy | When scheduling occurs |
| --- | --- |
| **Non-preemptive** | Only when the running process voluntarily gives up CPU (terminates, blocks for I/O, yields). |
| **Preemptive** | CPU can be taken away involuntarily: timer interrupt/quantum expiry, higher-priority arrival, I/O completion. |

## 5.2 Scheduling criteria

| Criterion | Definition | Goal |
| --- | --- | --- |
| **CPU utilisation** | Fraction of time CPU is busy. | High |
| **Throughput** | Number of jobs completed per unit time. | High |
| **Turnaround time** | Arrival → completion = ready-queue waiting + CPU execution (+ I/O). | Low |
| **Waiting time** | Total time spent waiting in the ready queue (not executing, not doing I/O). | Low |
| **Response time** | Arrival → first response (first CPU run / first quantum end in RR). | Low |

- Criteria often conflict.
- **RR** gives good response time but may worsen turnaround/waiting compared with FCFS. There is no universal winner.

## 5.3 Scheduling algorithms

### FCFS (First-Come, First-Served)

- Non-preemptive; schedule by arrival order.
- Simple, but suffers from the **convoy effect**: short jobs wait behind a long job.

**Example:** P1 burst 24, P2 burst 3, P3 burst 3, all arrive at 0.

- FCFS order P1→P2→P3: waiting times 0, 24, 27; average = **17**.
- Order P2→P3→P1: waiting times 0, 3, 6; average = **3**.

### SJF (Shortest Job First)

- Non-preemptive; pick the process with the **shortest next CPU burst**.
- **Optimal** for minimum average waiting time (non-preemptive).
- Problem: next burst length is unknown; it is mainly a theoretical yardstick.
- **SRTF (Shortest Remaining Time First)** = preemptive SJF: a newly arriving process preempts if its burst is shorter than the running process’s remaining time.

**Example (SRTF):** P1 arrives t=0, burst 8; P2 arrives t=1, burst 4.

- At t=1, P2 (4) < P1 remaining (7), so P2 preempts and runs 1–5.
- P1 resumes 5–13.
- Waiting: P1 = 1, P2 = 0; average = **0.5**.

### Exponential averaging (predicting next burst)

$$
\tau_{n+1} = \alpha t_n + (1-\alpha)\tau_n
$$

- $t_n$ = actual length of the $n$-th CPU burst.
- $\tau_n$ = previous estimate.
- $\alpha \in [0,1]$ controls how much weight is given to recent bursts.
- Expanding shows the estimate depends on all past bursts, with recent bursts weighted more.

**Example:** $\alpha=0.5$, $\tau_n=10$, $t_n=6$ → $\tau_{n+1}=0.5(6)+0.5(10)=8$.

### Round-Robin (RR)

- FCFS order + preemption; each process gets at most one **time quantum** $q$.
- If a process does not finish, it goes to the **tail** of the ready queue.
- Fair; good response time.
- Quantum choice:
  - $q$ very large (≥ all bursts) → RR degenerates to FCFS.
  - $q$ very small → processor sharing, but context-switch overhead dominates.

**Example:** P1, P2, P3 bursts 24, 3, 3; $q=4$.

```
P1(0-4), P2(4-7), P3(7-10), P1(10-14), P1(14-18), ...
```

P2 and P3 finish quickly instead of waiting behind P1.

### Priority scheduling

- Each process has a priority; CPU goes to the highest-priority process.
- Equal priority → FCFS (possibly with RR).
- SJF/SRTF are special cases: priority = inverse of predicted next CPU burst.
- **Starvation:** low-priority processes may wait indefinitely.
- **Aging:** gradually increase the priority of waiting processes so they eventually run.

### Multilevel Queue (MLQ)

- Ready queue is partitioned into separate queues (e.g., foreground/interactive vs background/batch).
- Queues have priority; higher-priority queues are served first.
- Each queue may use its own algorithm (RR for interactive, FCFS for batch).
- CPU time may be divided by priority or fixed percentage.
- A process is **permanently assigned** to one queue; no movement.

### Multilevel Feedback Queue (MLFQ)

- Like MLQ, but processes **can move between queues**.
- Used to favour short/interactive jobs without knowing burst lengths in advance.
- Parameters:
  - Number of queues
  - Initial queue for a new process
  - Scheduling algorithm per queue
  - Policy for moving processes between queues

**Textbook 3-queue example:**

| Queue | Algorithm | Quantum |
| --- | --- | --- |
| Q0 (highest) | RR/FCFS order | 4 ms |
| Q1 | RR/FCFS order | 8 ms additional |
| Q2 (lowest) | FCFS | run to completion |

**Rules:**

1. New job enters **Q0** at the tail. It gets up to 4 ms. If it finishes, it leaves; otherwise it goes to the **tail of Q1**. Q0 jobs are **never preempted**.
2. A Q1 job runs only when Q0 is empty, for up to **8 additional ms**. If its burst ≤ 4 + 8 = 12 ms, it finishes; otherwise it goes to the **tail of Q2**.
3. A Q2 job runs only when Q0 and Q1 are empty.
4. A new arrival to **Q0 preempts** a running Q1/Q2 job. The preempted job returns to the **head** of its queue and keeps its remaining quantum. Q1 jobs cannot preempt Q2 jobs; only a new Q0 arrival causes preemption.

**Example:** Job A burst 20 arrives t=0.

- Q0: 0–4 (remaining 16) → Q1.
- Q1: 4–12 (remaining 12) → Q2.
- Q2: 12–32, finishes.

If job B arrives at t=6 (into Q0) while A runs in Q1, B preempts A; B runs its Q0 quantum, then A resumes at the **head of Q1 with 6 ms of its 8 ms quantum left**.

**PA2 MLFQ variant:**

- $N = 1,2,3,4$ queues; last queue is **FCFS** (given a large quantum such as 1000).
- `time_quantum[]` gives the quantum **per queue**; each demotion gives a fresh quantum for the next queue.
- Arrivals are admitted at their arrival time and appended to **Q0**.
- The scheduler picks the highest-priority non-empty queue.
- A process in a lower queue can be preempted by a **new arrival**; it stays at the **front** of its queue and keeps its remaining slice.
- Queue 0 is not preempted by new arrivals; they wait behind existing Q0 jobs.
- If a process finishes, remove it; if it used its full quantum, demote it; otherwise it was preempted and keeps its remaining slice.
- Consecutive Gantt-chart intervals for the same process are merged.

**PA2 sample (Q0=2, Q1=4, Q2=FCFS):**

Processes: P1(0,7), P2(1,1), P3(4,1), P4(6,3).

```
P1 0-2 | P2 2-3 | P1 3-4 | P3 4-5 | P1 5-6 | P4 6-8 | P1 8-10 | P4 10-11 | P1 11-12
```

## 5.4 Real-time scheduling

| Algorithm | Priority | Characteristics |
| --- | --- | --- |
| **Rate-Monotonic (RM)** | Static | For periodic tasks; shorter period → higher priority. Optimal among static-priority algorithms. |
| **Earliest-Deadline-First (EDF)** | Dynamic | Task with earliest deadline gets highest priority; preemptive; tasks need not be periodic or have constant bursts. |

- **Soft real-time:** real-time tasks get priority, but no hard guarantee.
- **Hard real-time:** system must guarantee deadlines.

**Example:** Task A period 50, deadline 100; Task B period 80, deadline 80. Both ready: RM picks A (shorter period), EDF picks B (earlier deadline).

## 5.5 Thread scheduling

- The OS schedules **kernel-level threads** onto CPUs.
- **User-level threads** are managed by the thread library and mapped to kernel threads/LWPs.

| Scope | Who schedules | What competes |
| --- | --- | --- |
| **PCS** (Process-Contention Scope) | Thread library | User threads of the **same process** on available LWPs; programmer-set priorities. |
| **SCS** (System-Contention Scope) | Kernel/OS | **All kernel threads** in the system onto CPUs; ordinary CPU scheduling. |

## 5.6 Multiprocessor scheduling

| Type | Description |
| --- | --- |
| **Asymmetric multiprocessing** | One master processor handles all scheduling/I/O/system activities; others run user code. Simple, no shared-kernel-data races. |
| **SMP** | Each processor self-schedules from a common ready queue or per-processor queues. Need to avoid two CPUs picking the same process and avoid lost processes. |

**Multicore / two-level scheduling:**

1. OS schedules software (kernel) threads onto **logical CPUs**.
2. Each core decides which **hardware thread** runs on the physical core.

**Load balancing:**

- **Push migration:** periodic task moves processes from overloaded to less-loaded processors.
- **Pull migration:** an idle processor pulls a waiting task from a busy processor.
- Real systems often use both.

**Processor affinity:**

- Migrating a process invalidates/repopulates caches → expensive.
- **Hard affinity:** process is fixed to a subset of processors (guaranteed).
- **Soft affinity:** OS tries to keep the process on the same processor, but does not guarantee it.
- **NUMA:** CPU accesses some memory faster; affinity to both processor and memory matters.

## 5.7 Algorithm evaluation

| Method | Description |
| --- | --- |
| **Analytical** | Mathematical analysis; requires exact input known in advance. |
| **Queueing models** | Use mathematical distributions; e.g., **Little’s formula**: $n = \lambda W$, where $n$ = average number waiting, $\lambda$ = arrival rate, $W$ = average waiting time. |
| **Simulation** | Imitate the algorithm on a representative workload/benchmarks and measure. |

## 5.8 Formula and comparison sheet

| Formula / fact | Expression |
| --- | --- |
| Turnaround time | completion − arrival |
| Waiting time | turnaround − CPU burst (assuming no I/O) |
| Response time | first-run time − arrival |
| Exponential average | $\tau_{n+1} = \alpha t_n + (1-\alpha)\tau_n$ |
| Little’s formula | $n = \lambda W$ |
| SJF | Optimal average waiting time (non-preemptive) |
| SRTF | Preemptive SJF; optimal average waiting time among preemptive algorithms |
| RR large quantum | Degenerates to FCFS |
| RR small quantum | Processor sharing; context-switch overhead grows |
| Priority problem | Starvation; fix with aging |

## 5.9 Chapter 5 exam traps

- **Waiting time ≠ turnaround time.** Waiting excludes CPU execution; turnaround includes it.
- **Response time is not completion time**; it is time to first response.
- **SJF is optimal only for average waiting time** (non-preemptive), not for response time.
- **SRTF can preempt only on new arrivals** in the standard model; processes already in the ready queue have longer bursts than the running process’s remaining time.
- **FCFS convoy effect** can make average waiting time very large.
- **RR quantum too small** → context-switch overhead; too large → FCFS.
- **MLFQ:** new Q0 arrival preempts lower queues; Q0 itself is not preempted by new arrivals; preempted job keeps remaining quantum.
- **PA2 uses per-queue quanta**, not the textbook “8 additional ms” rule.
- **Aging** solves starvation, not deadlock.

---

# 6. Chapter 6 — Synchronization Tools

## 6.1 Why synchronization?

- Concurrent processes/threads may be interrupted at any time, partially completing execution.
- Concurrent access to shared data can cause **data inconsistency**.
- We need mechanisms to ensure **orderly execution** of cooperating processes.

**Producer–consumer illustration:** shared `counter` tracks occupied buffer slots.

```c
counter++;   /* producer */
counter--;   /* consumer */
```

Each is not atomic:

```c
counter++:  register1 = counter;
            register1 = register1 + 1;
            counter = register1;

counter--:  register2 = counter;
            register2 = register2 - 1;
            counter = register2;
```

### Race condition

A **race condition** is an undesirable situation where several processes access/manipulate shared data concurrently, and the **outcome depends on the particular order** of execution.

**Classic interleaving:** start `counter = 5`.

| Step | Action | Result |
| --- | --- | --- |
| S0 | producer: `register1 = counter` | register1 = 5 |
| S1 | producer: `register1 = register1 + 1` | register1 = 6 |
| S2 | consumer: `register2 = counter` | register2 = 5 |
| S3 | consumer: `register2 = register2 - 1` | register2 = 4 |
| S4 | producer: `counter = register1` | counter = 6 |
| S5 | consumer: `counter = register2` | counter = **4** |

One increment and one decrement were performed, but the result is 4 (should be 5). The outcome is **non-deterministic**.

Another kernel example: two processes calling `fork()` concurrently race on `next_available_pid`; without mutual exclusion, two processes could get the same PID.

## 6.2 Critical-section problem

- Each of $n$ processes has a **critical section**: code that may change shared variables, update a table, write a file, etc.
- When one process is in its critical section, no other process may be in **its** critical section.
- Each process must request permission in an **entry section**, execute the **critical section**, then an **exit section**, then a **remainder section**.

```c
do {
    /* entry section */
        /* critical section */
    /* exit section */
        /* remainder section */
} while (true);
```

### Requirements for a valid solution

1. **Mutual exclusion:** if $P_i$ is in its critical section, no other process is in its critical section.
2. **Progress:** if no process is in its critical section and some want to enter, the choice of who goes next cannot be postponed indefinitely.
3. **Bounded waiting:** after a process requests entry, there is a bound on how many times other processes may enter before its request is granted.

Assume every process runs at nonzero speed; no assumptions about relative speeds.

### Critical sections in the kernel

- Kernel data structures (open-file list, memory allocation structures, process table, interrupt handling) are also subject to races.
- **Preemptive kernel:** a process can be preempted in kernel mode → not free of races; harder on SMP.
- **Non-preemptive kernel:** kernel code runs until it exits kernel mode, blocks, or voluntarily yields → essentially free of kernel-mode races on a single processor.

## 6.3 Peterson’s algorithm (software solution, 2 processes)

Peterson’s solution is restricted to **two processes** that alternate between critical and remainder sections. It uses two shared variables:

- `flag[2]`: `flag[i] = true` means $P_i$ wants to enter.
- `turn`: whose turn it is (0 or 1).

Assume loads/stores of a single variable are atomic.

**Standard version for process $P_i$** (let $j = 1-i$):

```c
do {
    flag[i] = true;
    turn = j;
    while (flag[j] && turn == j)
        ;                    /* busy wait */
    /* critical section */
    flag[i] = false;
    /* remainder section */
} while (true);
```

**For P0** ($i=0, j=1$):

```c
flag[0] = true;
turn = 1;
while (flag[1] && turn == 1) ;
/* critical section */
flag[0] = false;
```

**For P1** ($i=1, j=0$):

```c
flag[1] = true;
turn = 0;
while (flag[0] && turn == 0) ;
/* critical section */
flag[1] = false;
```

> **Note:** Some lab slides show the flag indices reversed. For the exam, write the standard version above: **each process sets its own flag**, and sets `turn` to the other process. That is the version whose proof works.

**Proof sketch:**

- **Mutual exclusion:** If both are trying, both set their flags true, but `turn` can be only 0 or 1, so one is forced to wait. A process enters only if either the other is not interested (`flag[j] == false`) or it is its turn (`turn == i`).
- **Progress:** If no one is in the critical section and one wants to enter, it can enter unless the other is also trying; then `turn` decides one of them.
- **Bounded waiting:** A process waits at most one entry by the other; after the other exits, it sets its flag false or sets `turn` to the waiting process.

**Drawbacks:** complex for only two processes, different code per thread, busy waiting wastes CPU.

## 6.4 Synchronization hardware

- On a **uniprocessor**, disabling interrupts can protect a critical section, but this is inefficient and unsuitable for multiprocessors.
- Modern systems provide **atomic hardware instructions** (non-interruptible):
  - `test_and_set()`
  - `compare_and_swap()`
- These are building blocks for higher-level synchronization.

### `test_and_set`

```c
boolean test_and_set(boolean *target) {
    boolean rv = *target;
    *target = TRUE;
    return rv;
}
```

Mutual-exclusion lock (`lock` initially `FALSE`):

```c
do {
    while (test_and_set(&lock))
        ;                       /* busy wait */
    /* critical section */
    lock = false;
    /* remainder section */
} while (true);
```

The first process to execute `test_and_set` sees `FALSE`, sets it `TRUE`, and enters. Others keep getting `TRUE` and spin.

### `compare_and_swap` (CAS)

```c
int compare_and_swap(int *value, int expected, int new_value) {
    int temp = *value;
    if (*value == expected)
        *value = new_value;
    return temp;
}
```

Lock solution (`lock` initially 0):

```c
do {
    while (compare_and_swap(&lock, 0, 1) != 0)
        ;                       /* busy wait */
    /* critical section */
    lock = 0;
    /* remainder section */
} while (true);
```

Only the process that observes `lock == 0` flips it to 1 in one atomic step.

### Bounded waiting with `test_and_set`

The simple spinlocks give mutual exclusion but **not bounded waiting**. A full solution uses a `waiting[]` array:

```c
do {
    waiting[i] = true;
    key = true;
    while (waiting[i] && key)
        key = test_and_set(&lock);
    waiting[i] = false;
    /* critical section */
    j = (i + 1) % n;
    while ((j != i) && !waiting[j])
        j = (j + 1) % n;
    if (j == i)
        lock = false;           /* no one waiting */
    else
        waiting[j] = false;     /* unblock process j */
    /* remainder section */
} while (true);
```

- **Mutual exclusion:** only the first process to run `test_and_set` finds `key == false`; only one `waiting[i]` is cleared at a time.
- **Progress:** exiting process either sets `lock = false` or `waiting[j] = false`, letting someone in.
- **Bounded waiting:** cyclic scan → any waiting process enters within $n-1$ turns.

### Atomic variables

CAS is used to build **atomic variables** (e.g., `atomic_int`) whose updates cannot be interrupted.

```c
void increment(atomic_int *v) {
    int temp;
    do {
        temp = *v;
    } while (temp != compare_and_swap(v, temp, temp + 1));
}
```

Idea: read the value, try to CAS it to `value + 1`; if another thread changed it in between, retry.

## 6.5 Mutex locks

- The simplest OS-provided synchronization tool: **acquire()** before the critical section, **release()** after.
- Both operations must be **atomic**.

```c
acquire() {
    while (!available)
        ;                       /* busy wait */
    available = false;
}

release() {
    available = true;
}
```

```c
do {
    acquire();
        /* critical section */
    release();
        /* remainder section */
} while (true);
```

- At most one thread holds the lock at a time.
- This design uses **busy waiting** → it is a **spinlock**.
- **Downside:** wastes CPU cycles while waiting.
- **Advantage:** no context switch is needed to wait; good if locks are held briefly.
- Spinlocks are natural on **multiprocessors**: one thread spins on its CPU while the holder finishes on another CPU.

**POSIX mutex API (Pthreads):**

```c
pthread_mutex_t mutex;
pthread_mutex_init(&mutex, NULL);
pthread_mutex_lock(&mutex);
    /* critical section */
pthread_mutex_unlock(&mutex);
pthread_mutex_destroy(&mutex);
```

## 6.6 Semaphores

- A **semaphore $S$** is a non-negative integer variable; a generalized lock.
- Defined by Dijkstra in the 1960s; main synchronization primitive of original UNIX.
- Accessed only via two **atomic** operations:
  - `wait(S)` — originally `P()` (“proberen”, to test)
  - `signal(S)` — originally `V()` (“verhogen”, to increment)
- Atomicity guarantees no two processes execute `wait`/`signal` on the same semaphore simultaneously (**serialization**).

**Busy-wait definition:**

```c
wait(S) {
    while (S <= 0)
        ;                       /* busy wait */
    S--;
}

signal(S) {
    S++;
}
```

### Two kinds of semaphores

| Type | Range | Use |
| --- | --- | --- |
| **Counting semaphore** | Unrestricted non-negative integers | Control access to a resource with $N$ instances; initialize $S = N$. |
| **Binary semaphore** | 0 or 1 | Behaves like a mutex lock; also used for ordering constraints. |

> A **binary semaphore initialized to 1** can act like a mutex, but it is **not equivalent** to a mutex because it can also be initialized to 0 for ordering and can be used differently. A mutex has ownership semantics; a semaphore does not.

### Ordering example

Force $S_1$ in $P_1$ to run before $S_2$ in $P_2$:

```c
/* binary semaphore synch initialized to 0 */
P1:  S1;
     signal(synch);

P2:  wait(synch);
     S2;
```

If P2 runs first, `wait` blocks (synch = 0) until P1 signals.

### Implementation without busy waiting

Each semaphore has a **waiting queue**. `block()` suspends the caller and puts it on the queue; `wakeup(P)` moves P to the ready queue.

```c
typedef struct {
    int value;
    struct process *list;
} semaphore;

wait(semaphore *S) {
    S->value--;
    if (S->value < 0) {
        add this process to S->list;
        block();
    }
}

signal(semaphore *S) {
    S->value++;
    if (S->value <= 0) {
        remove a process P from S->list;
        wakeup(P);
    }
}
```

**Differences from busy-wait version:**

- Increment/decrement happen **before** the check.
- Semaphore values can be **negative**.
- If negative, its magnitude = number of processes waiting on it.

**POSIX semaphore API** (`semaphore.h`):

```c
sem_t sem;
sem_init(&sem, 0, value);   /* pshared=0: threads in same process */
sem_wait(&sem);
sem_post(&sem);
sem_destroy(&sem);
```

| Initial value | Behaviour | Use |
| --- | --- | --- |
| 1 | One permit; others wait | Mutual exclusion (acts as mutex) |
| 0 | No permit; `wait` blocks until `post` | Ordering |
| N | N permits | Manage N identical resources |

## 6.7 Deadlock and starvation

- **Deadlock:** two or more processes wait indefinitely for an event that only one of the waiting processes can cause.

**Example:** semaphores S and Q initialized to 1.

```c
P0: wait(S); wait(Q); ... signal(Q); signal(S);
P1: wait(Q); wait(S); ... signal(S); signal(Q);
```

If P0 grabs S and P1 grabs Q, P0 waits for Q (held by P1), P1 waits for S (held by P0). Neither `signal` runs → **deadlock**.

- **Starvation:** indefinite blocking — a process is never removed from the semaphore queue, e.g., if the queue is LIFO or priority-based and the process is always skipped.

## 6.8 Condition variables

A **condition variable** lets a thread wait for an arbitrary condition/event, always used together with a mutex.

**POSIX API:**

```c
pthread_mutex_t mutex;
pthread_cond_t cond_var;
pthread_mutex_init(&mutex, NULL);
pthread_cond_init(&cond_var, NULL);

/* waiting */
pthread_mutex_lock(&mutex);
while (!condition) {
    pthread_cond_wait(&cond_var, &mutex);
}
/* use shared data */
pthread_mutex_unlock(&mutex);

/* signalling */
pthread_mutex_lock(&mutex);
/* change condition */
pthread_cond_signal(&cond_var);   /* or pthread_cond_broadcast */
pthread_mutex_unlock(&mutex);
```

**Key mechanics:**

- `pthread_cond_wait(&cond, &mutex)` **atomically releases the mutex and sleeps**. If it did not release the mutex, no other thread could acquire the mutex to make the condition true and signal it → deadlock.
- When it returns, it **reacquires the mutex**, so the waiting thread owns the lock again.
- Check the condition in a **`while` loop**, not `if`, because the thread must re-test after waking (spurious wakeups / another thread may consume the condition).
- Hold the mutex when **changing** the shared condition and when **signalling** to avoid lost wakeups.
- `pthread_cond_signal` wakes one waiter; `pthread_cond_broadcast` wakes all.

**Simple producer/consumer pattern:**

```c
/* producer */
pthread_mutex_lock(&mutex);
ready = 1;
pthread_cond_signal(&cond);
pthread_mutex_unlock(&mutex);

/* consumer */
pthread_mutex_lock(&mutex);
while (!ready)
    pthread_cond_wait(&cond, &mutex);
pthread_mutex_unlock(&mutex);
```

## 6.9 Classic synchronization problems

### Bounded-buffer problem (producer–consumer)

- $n$ buffer slots.
- Semaphores:

| Semaphore | Initial value | Meaning |
| --- | --- | --- |
| `mutex` | 1 | Mutual exclusion for buffer access |
| `full` | 0 | Number of filled slots |
| `empty` | n | Number of empty slots |

**Producer:**

```c
do {
    /* produce item in next_produced */
    wait(empty);          /* wait for free slot */
    wait(mutex);          /* enter critical section */
    /* add next_produced to buffer */
    signal(mutex);
    signal(full);         /* one more full slot */
} while (true);
```

**Consumer:**

```c
do {
    wait(full);           /* wait for an item */
    wait(mutex);
    /* remove item into next_consumed */
    signal(mutex);
    signal(empty);        /* one more free slot */
    /* consume item */
} while (true);
```

**Important:** take the resource semaphore (`empty`/`full`) **before** the `mutex`. Reversing the order can deadlock: a producer could hold `mutex` and block forever on `empty`, preventing the consumer from entering to free a slot.

### Readers–writers problem

- Shared data used by **readers** (read only) and **writers** (read + write).
- Goal: allow multiple readers simultaneously, but only one writer at a time, and no readers while a writer writes.

**First readers–writers problem (readers have priority):**

Shared data:

| Variable | Initial | Purpose |
| --- | --- | --- |
| `rw_mutex` | 1 | Exclusive access to data for writers and first/last reader |
| `mutex` | 1 | Protects `read_count` |
| `read_count` | 0 | Number of active readers |

**Writer:**

```c
do {
    wait(rw_mutex);
    /* writing */
    signal(rw_mutex);
} while (true);
```

**Reader:**

```c
do {
    wait(mutex);
    read_count++;
    if (read_count == 1)
        wait(rw_mutex);       /* first reader locks data */
    signal(mutex);

    /* reading */

    wait(mutex);
    read_count--;
    if (read_count == 0)
        signal(rw_mutex);     /* last reader unlocks data */
    signal(mutex);
} while (true);
```

- `rw_mutex` guards the data for writers and for the **first reader in / last reader out**.
- `mutex` only guards `read_count`.
- Subsequent readers pile in concurrently while the first reader holds `rw_mutex`.
- **Reader-preference:** writers may starve.
- **Writer-preference:** once a writer is waiting, no new readers start; readers may starve.
- Kernels provide **reader–writer locks**: many read-mode holders, exactly one write-mode holder.

## 6.10 Chapter 6 exam traps

- **Race condition ≠ deadlock.** Race condition is about timing/order causing wrong data; deadlock is indefinite waiting.
- **Mutual exclusion, progress, bounded waiting** are three separate requirements.
- **Peterson’s algorithm is only for two processes** and uses busy waiting.
- **`test_and_set`/CAS** provide mutual exclusion but not necessarily bounded waiting.
- **Spinlock** wastes CPU but avoids context-switch cost; good for short critical sections/multiprocessors.
- **Semaphore value can be negative** in the blocking implementation; magnitude = number waiting.
- **Binary semaphore ≠ mutex** (ordering vs ownership).
- **Bounded buffer:** resource semaphore before mutex; otherwise deadlock.
- **Condition variable:** always used with a mutex; `while` loop; `pthread_cond_wait` releases then reacquires the mutex.
- **Readers–writers:** first reader locks `rw_mutex`; last reader unlocks it; `mutex` protects only `read_count`.
- **Starvation vs deadlock:** starvation is indefinite postponement; deadlock is circular waiting where no progress is possible.

---

# 7. Lab and PA Reference

## 7.1 Lab 1 — Linux environment

Useful commands:

| Command | Purpose |
| --- | --- |
| `pwd` | Print working directory. |
| `ls`, `ls -l`, `ls -a` | List files. |
| `cd <dir>`, `cd ..`, `cd ~` | Change directory. |
| `mkdir`, `rmdir` | Create/remove directory. |
| `rm`, `rm -r` | Remove file/directory. |
| `cp`, `mv` | Copy/move/rename. |
| `cat`, `less`, `more` | View files. |
| `grep <pattern> <file>` | Search text. |
| `chmod` | Change permissions. |
| `man <command>` | Manual page. |
| `ps`, `kill` | List/signal processes. |
| `diff file1 file2` | Compare files. |
| `ssh user@host` | Remote login. |
| `scp`, `sftp` | File transfer. |
| `du -ah`, `df -h` | Disk usage. |

Lab environment: CS Lab 2 Linux machine (`csl2wkXX.cse.ust.hk`), accessed via SSH. Test final code there because grader uses the same environment.

## 7.2 Lab 2 — C, compilation, make, gdb

### C essentials

- All C data types have fixed bit sizes.
- **Pointers:** a pointer stores an address; `*` dereferences; `&` takes an address.
- Function arguments are passed **by value**; to modify a caller’s variable, pass its address.
- `struct` groups related fields.
- Dynamic memory: `malloc(sizeof(...))`, `free(ptr)`. Check for `NULL`.
- Strings are NUL-terminated `char` arrays.
- `printf` formats: `%d` int, `%c` char, `%f` float, `%e` scientific, `%s` string, `%p` pointer, `%zu` `size_t`.
- `scanf("%d", &x)` requires the address.
- File I/O: `fopen`, `fscanf`, `fprintf`, `fclose`.

### Compilation

```bash
gcc source.c -o program
gcc -g source.c -o program          # debugging info
gcc source.c -o program -lm         # link math library
gcc pthread_demo.c -lpthread -o pthread_demo
gcc -pedantic -Wall -Wextra -std=c99 -o myshell myshell.c
```

### Makefile

```make
all: hello io_console

hello: hello.c
	gcc -o hello hello.c

io_console: io_console.c
	gcc -o io_console io_console.c

clean:
	rm -f hello io_console
```

- **Tabs**, not spaces, must precede commands.
- `make` builds the first target by default; `make clean` removes outputs.

### GDB

```bash
gcc -g buggy.c -o buggy
gdb ./buggy
```

| GDB command | Purpose |
| --- | --- |
| `list` / `l` | Show source. |
| `break <line>` / `b` | Set breakpoint. |
| `run` / `r` | Run program. |
| `print <var>` / `p` | Print variable. |
| `next` / `n` | Execute next line, step over function calls. |
| `step` / `s` | Step into function calls. |
| `continue` / `c` | Continue to next breakpoint. |
| `quit` / `q` | Quit. |

## 7.3 Lab 3 — Linux processes, pipes, and `exec`

### Process-related system calls

| Call | Signature / return | Notes |
| --- | --- | --- |
| `getpid()` | `pid_t getpid(void)` | Current process ID. |
| `getppid()` | `pid_t getppid(void)` | Parent process ID. |
| `sleep()` | `unsigned int sleep(unsigned int seconds)` | Suspend for seconds. |
| `fork()` | `pid_t fork(void)` | Child gets 0, parent gets child PID, -1 on error. |
| `wait()` | `pid_t wait(int *status)` | Wait for a child; returns child PID or -1. |
| `signal()` | `sighandler_t signal(int signum, sighandler_t handler)` | Install handler; `SIGINT` = 2. |
| `exit()` | `void exit(int status)` | Terminate process; flush/close. |

**Zombie/orphan lab examples:**

- Zombie: child exits, parent sleeps before `wait()` → child remains zombie until parent waits.
- Orphan: parent exits first; child is adopted by `init`/`systemd`.

**Exit status:**

- Normal: `exit(0)`.
- Error: `exit(1)`.
- Fatal: divide-by-zero, segfault, killed by signal.
- Parent gets status via `wait(&status)`.

### File-related system calls

| Call | Signature | Notes |
| --- | --- | --- |
| `open()` | `int open(const char *path, int flags, mode_t mode)` | Returns fd ≥ 0, -1 on error. Flags: `O_RDONLY`, `O_WRONLY`, `O_RDWR`, `O_CREAT`, `O_TRUNC`, `O_APPEND`, `O_NONBLOCK`. |
| `read()` | `ssize_t read(int fd, void *buf, size_t count)` | Returns bytes read; 0 = EOF; -1 error. Does **not** add NUL. |
| `write()` | `ssize_t write(int fd, const void *buf, size_t count)` | Returns bytes written; may be less than requested; -1 error. |
| `close()` | `int close(int fd)` | 0 success, -1 error. Unread pipe data discarded when all fds close. |

Example file write/read:

```c
int fd = open("hello.txt", O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR);
write(fd, "hello\n", 6);
close(fd);

fd = open("hello.txt", O_RDONLY, S_IRUSR | S_IWUSR);
char buffer[10];
read(fd, buffer, 6);
printf("%s", buffer);
close(fd);
```

### Pipes

```c
int pfds[2];
pipe(pfds);          /* pfds[0] read, pfds[1] write */
```

- `pipe()` returns 0 on success, -1 on error.
- Data is received in the order sent.
- OS enforces mutual exclusion for pipe access.
- Processes sharing an anonymous pipe must be related (typically parent/child).
- `read`/`write` are **blocking** by default.

### `dup` and `dup2`

```c
int dup(int oldfd);
int dup2(int oldfd, int newfd);
```

- `dup(oldfd)` returns a new fd: the **lowest-numbered unused** descriptor.
- `dup2(oldfd, newfd)` makes `newfd` refer to the same open file as `oldfd`; if `newfd` was open, it is closed first.
- Default fds: 0 = stdin, 1 = stdout, 2 = stderr.

**Redirect stdout to a file:**

```c
int fd = open("output.txt", O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR);
close(1);
dup(fd);             /* stdout now refers to output.txt */
printf("Hello World!\n");
fflush(stdout);
close(fd);
```

Using `dup2` is clearer:

```c
int fd = open("output.txt", O_CREAT | O_WRONLY | O_TRUNC, 0600);
dup2(fd, 1);
close(fd);
```

### `exec` family

Six variants: `execl`, `execlp`, `execle`, `execv`, `execvp`, `execvpe`.

- Replace the current process image with a new program.
- On success, **do not return**; on error, return -1.

```c
execlp("ls", "ls", "-l", "-h", NULL);
```

```c
char *args[] = { "ls", "-l", "-h", NULL };
execvp("ls", args);
```

### Shell pipeline: `ls | wc -l`

```c
int pfds[2];
pipe(pfds);
pid_t pid = fork();

if (pid == 0) {             /* child: ls writes into pipe */
    close(1);               /* close stdout */
    dup2(pfds[1], 1);       /* stdout = pipe write end */
    close(pfds[0]);
    execlp("ls", "ls", NULL);
} else {                    /* parent: wc reads from pipe */
    close(0);               /* close stdin */
    dup2(pfds[0], 0);       /* stdin = pipe read end */
    close(pfds[1]);
    wait(0);
    execlp("wc", "wc", "-l", NULL);
}
```

**Why `dup2` is preferred:** it specifies the target descriptor, so it is readable and avoids accidentally using the wrong lowest-numbered fd.

### Two-pipe bidirectional communication (lab exam blank)

```c
int p2c[2], c2p[2];
pipe(p2c);
pipe(c2p);

pid_t pid = fork();
if (pid == 0) {                       /* child */
    const char msg[] = "Child";
    close(c2p[0]);
    write(c2p[1], msg, 6);            /* includes '\0' */
    close(p2c[1]);
    read(p2c[0], buffer, 7);
    printf("Child received the message: %s\n", buffer);
} else {                              /* parent */
    const char msg[] = "Parent";
    close(c2p[1]);
    read(c2p[0], buffer, 6);
    close(p2c[0]);
    write(p2c[1], msg, 7);
    printf("Parent received the message: %s\n", buffer);
}
```

- `p2c` = parent-to-child; `c2p` = child-to-parent.
- Close unused ends before blocking I/O.
- `write(..., 6)` writes 5 characters plus the NUL terminator; `read(..., 6)` reads them; the destination buffer must be large enough and initialized.

## 7.4 Lab 4 — FIFOs and Pthreads

### Named pipe / FIFO

```c
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

if (access(FIFO_NAME, F_OK) == -1) {
    mkfifo(FIFO_NAME, 0777);
}

int fd = open(FIFO_NAME, O_WRONLY);   /* producer */
write(fd, buffer, BUFFER_SIZE);
close(fd);

int fd2 = open(FIFO_NAME, O_RDONLY);  /* consumer */
read(fd2, buffer, BUFFER_SIZE);
close(fd2);
```

| API | Notes |
| --- | --- |
| `mkfifo(path, mode)` | Creates FIFO; 0 success, -1 error. |
| `access(path, mode)` | `F_OK` existence; `R_OK`/`W_OK`/`X_OK`; 0 if allowed, -1 otherwise. |
| `open(path, flags)` | Blocking until both ends open, unless `O_NONBLOCK`. |
| `read`/`write` | Same as file I/O; blocking. |
| `close` | When all fds close, unread pipe data is discarded. |

**FIFO properties:**

- Appears as a file; persists until deleted.
- No parent-child relationship required.
- Data read is consumed; cannot be re-read.
- Not suitable for broadcasting: one item goes to one reader.
- Atomicity: reads/writes up to `PIPE_BUF` are atomic; larger transfers may interleave.
- Use `O_NONBLOCK` to avoid blocking on `open`.
- For two-way communication, use **two FIFOs** (one per direction), not one FIFO.

### Pthreads

```c
#include <pthread.h>

void *runner(void *param);   /* thread function */

int main() {
    pthread_t tid;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_create(&tid, &attr, runner, arg);
    pthread_join(tid, NULL);
    return 0;
}

void *runner(void *param) {
    /* ... */
    pthread_exit(0);
}
```

| API | Notes |
| --- | --- |
| `pthread_create(&tid, &attr, start_routine, arg)` | Create thread. `arg` is a `void *`. |
| `pthread_join(tid, NULL)` | Wait for thread to finish. |
| `pthread_exit(0)` | Terminate calling thread. |
| `pthread_attr_init(&attr)` | Default attributes. |

Compile with `-lpthread`:

```bash
gcc pthread_demo.c -lpthread -o pthread_demo
```

**Threads share memory:** a global/`counter` modified by a thread is visible to the main thread after `pthread_join`. Processes created by `fork()` have separate address spaces, so a child’s modifications are not visible to the parent.

**Pthreads lab exam example:**

```c
int counter = 0;
pthread_create(&thread, NULL, child, &counter);
pthread_join(thread, NULL);
printf("%d\n", counter);   /* 1: shared memory */
counter = 0;
pid_t pid = fork();
if (pid) wait(NULL);
else { child(&counter); exit(0); }
printf("%d\n", counter);   /* 0: separate process memory */
```

Output: **1, then 0**.

## 7.5 Lab 5 / PA2 — MLFQ simulator

**PA2 input:**

```
queue_num = N
time_quantum = q0 q1 ... qN-1
process_table_size = M
process_table =
P1 arrival burst
...
```

- $N = 1$ to 4; last queue is FCFS (large quantum, e.g., 1000).
- At most 10 processes.
- Process table sorted by arrival time; first arrival is 0; no equal arrival times.
- CPU not idle for the entire schedule; at most 300 Gantt steps.
- Empty lines and lines beginning with `#` are ignored.

**PA2 output:**

1. Parsed values.
2. Final Gantt chart.

Example Gantt representation:

```
P1 P2 P1 P3 P1 P4 P1 P4 P1
0  2  3  4  5  6  8  10 11 12
```

**PA2 MLFQ algorithm:**

1. Admit all processes with `arrival_time <= current_time` into Q0; set their remaining slice to `time_quantum[0]`.
2. Pick the highest-priority non-empty queue.
3. Run the front process for:
   - its remaining time, capped by its remaining quantum (for non-last queues), and
   - capped so the CPU stops exactly at the next arrival time (new arrivals can preempt lower-priority queues).
4. Record/merge the Gantt interval.
5. Update current time, remaining time, and remaining slice.
6. If finished → remove. Else if quantum exhausted and not last queue → demote to next queue with a fresh quantum. Else → preempted; stay at front and keep remaining slice.

**Important PA2 details:**

- Queue 0 is **not** preempted by new arrivals; new Q0 arrivals wait at the back.
- A process in Q1/Q2/Q3 is preempted by a new arrival; it stays at the **front** of its queue and does **not** lose its partially used quantum.
- Last queue is FCFS and runs until completion unless preempted by a higher-priority arrival.
- Consecutive same-process Gantt intervals are merged.

**Lab 5 sample Gantt (Q0=2, Q1=4, Q2=FCFS):**

```
P1(0-2), P2(2-3), P1(3-4), P3(4-5), P1(5-6),
P4(6-8), P1(8-10), P4(10-11), P1(11-12)
```

## 7.6 Lab 6 — Synchronization review

### Peterson’s algorithm (lab exam style)

- Two processes, shared `flag[2]` and `turn`.
- Each process sets **its own** flag true, sets `turn` to the other, spins while the other’s flag is true and it is the other’s turn.
- Provides mutual exclusion, progress, bounded waiting; uses busy waiting.

### Mutex, semaphore, condition variable — when to use what

| Primitive | Use when |
| --- | --- |
| **Mutex lock** | Protect one shared resource/critical section; lock → access → unlock. |
| **Semaphore** | Manage N resources (counting) or enforce ordering (binary initialized to 0). |
| **Condition variable** | Wait for an arbitrary condition/event; always paired with a mutex. |

### Lab 6 sample questions and answers

**Q: Is a binary semaphore equivalent to a mutex lock?**  
**A: No.** A binary semaphore initialized to 1 can be used as a mutex, but it can also be initialized to 0 for ordering and does not have mutex ownership semantics.

**Q: Three threads must enter in order T1, T2, T3, T1, T2, T3, ... What are initial values of S1, S2, S3?**  
**A: S1 = 1, S2 = 0, S3 = 0.**  
Each thread does `wait(Si); critical section; signal(S_{i+1})`, with T3 signaling S1.

**Q: Three processes P0, P1, P2 must enter in order P0, P1, P2, P0, ... Fill blanks.**  
**A:** `S0=1, S1=0, S2=0`; P0: `wait(S0); CS; signal(S1)`; P1: `wait(S1); CS; signal(S2)`; P2: `wait(S2); CS; signal(S0)`.

**Q: Two threads each increment a shared `counter` 5000 times under a mutex. Final value?**  
**A: 10,000**, because the mutex serializes the increments.

**Q: Semaphores S0=1, S1=S2=S3=0; P0 prints '1' and releases S1,S2,S3; P1 waits S1 then releases S0; P2 waits S2, releases S0, waits S3, releases S0. How many times is '1' printed?**  
**A: 4.** P0 prints once, releases 3 permits; P1 and P2 together return 4 permits to S0 (P1 returns 1; P2 returns 2), so P0 can print 4 times total.

**Q: Readers–writers blanks (POSIX mutex):**

```c
pthread_mutex_lock(&mutex);
read_count++;
if (read_count == 1)
    pthread_mutex_lock(&rw_mutex);
pthread_mutex_unlock(&mutex);

/* reading */

pthread_mutex_lock(&mutex);
read_count--;
if (read_count == 0)
    pthread_mutex_unlock(&rw_mutex);
pthread_mutex_unlock(&mutex);
```

## 7.7 API cheat sheet

### Process / file / pipe

```c
pid_t fork(void);
pid_t wait(int *status);
pid_t getpid(void);
pid_t getppid(void);
unsigned int sleep(unsigned int seconds);

int pipe(int fd[2]);
int dup(int oldfd);
int dup2(int oldfd, int newfd);

int open(const char *path, int flags, mode_t mode);
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
int close(int fd);

int mkfifo(const char *path, mode_t mode);
int access(const char *path, int mode);
int chdir(const char *path);

int execl(const char *path, const char *arg, ...);
int execlp(const char *file, const char *arg, ...);
int execv(const char *path, char *const argv[]);
int execvp(const char *file, char *const argv[]);
```

### Pthreads / synchronization

```c
int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine)(void *), void *arg);
int pthread_join(pthread_t thread, void **retval);
void pthread_exit(void *retval);

int pthread_mutex_init(pthread_mutex_t *mutex,
                       const pthread_mutexattr_t *attr);
int pthread_mutex_lock(pthread_mutex_t *mutex);
int pthread_mutex_unlock(pthread_mutex_t *mutex);
int pthread_mutex_destroy(pthread_mutex_t *mutex);

int sem_init(sem_t *sem, int pshared, unsigned int value);
int sem_wait(sem_t *sem);
int sem_post(sem_t *sem);
int sem_destroy(sem_t *sem);

int pthread_cond_init(pthread_cond_t *cond,
                      const pthread_condattr_t *attr);
int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
int pthread_cond_signal(pthread_cond_t *cond);
int pthread_cond_broadcast(pthread_cond_t *cond);
int pthread_cond_destroy(pthread_cond_t *cond);
```

## 7.8 Code patterns to memorise

### Fork + wait

```c
pid_t pid = fork();
if (pid < 0) {
    perror("fork");
    exit(1);
} else if (pid == 0) {
    /* child work */
    exit(0);
} else {
    wait(NULL);          /* parent reaps child */
}
```

### Redirect stdin/stdout

```c
/* input redirection */
int in = open(input_path, O_RDONLY);
dup2(in, 0);
close(in);

/* output redirection */
int out = open(output_path, O_CREAT | O_WRONLY | O_TRUNC, 0600);
dup2(out, 1);
close(out);
```

### One pipe / two processes

```c
int fd[2];
pipe(fd);
pid_t pid = fork();

if (pid == 0) {
    close(fd[0]);
    write(fd[1], buf, n);
    close(fd[1]);
    exit(0);
} else {
    close(fd[1]);
    read(fd[0], buf, n);
    close(fd[0]);
    wait(NULL);
}
```

### Multi-stage pipeline (conceptual loop)

For `cmd0 | cmd1 | ... | cmd_{k-1}`:

1. Create `k-1` pipes.
2. For each segment `i`, `fork()`.
3. Child:
   - If not first, `dup2(prev_read, 0)`.
   - If not last, `dup2(pipe[i][1], 1)`.
   - Close all unused pipe fds.
   - `execvp(argv[i][0], argv[i])`.
4. Parent closes the ends it no longer needs; keeps the read end for the next stage.
5. After forking all, parent closes remaining fds and `wait()`s for all children.

### Pthreads with mutex

```c
void *add(void *arg) {
    pthread_mutex_t *m = (pthread_mutex_t *)arg;
    for (int i = 0; i < TOTAL; i++) {
        pthread_mutex_lock(m);
        ++counter;
        pthread_mutex_unlock(m);
    }
    return NULL;
}

int main() {
    pthread_t t1, t2;
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);

    pthread_create(&t1, NULL, add, &mutex);
    pthread_create(&t2, NULL, add, &mutex);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    pthread_mutex_destroy(&mutex);
}
```

### Semaphore ordering

```c
sem_t s1, s2, s3;
sem_init(&s1, 0, 1);
sem_init(&s2, 0, 0);
sem_init(&s3, 0, 0);

/* T1 */ sem_wait(&s1); /* CS */ sem_post(&s2);
/* T2 */ sem_wait(&s2); /* CS */ sem_post(&s3);
/* T3 */ sem_wait(&s3); /* CS */ sem_post(&s1);
```

## 7.9 PA1 and PA2 exam connections

### PA1 — Simplified Linux Shell

Features to remember:

1. **Exit command** — print start/end with same PID; return control to system shell.
2. **Custom Ctrl-C / SIGINT** — install handler with `signal(SIGINT, handler)`; print termination message; signal number 2.
3. **`cd`** — cannot use `exec*`; use `chdir(path)`; handle errors (`-1`).
4. **Redirection** — handle `< input` and `> output` using `open` + `dup2`; at most one of each; no command has both redirection and pipe.
5. **Multi-level pipes** — up to 8 segments; create pipes, fork each command, connect stdin/stdout with `dup2`, close unused ends, `execvp`, parent waits.

**Command patterns:**

```
command
command < input
command > output
command < input > output
command > output < input
command1 | command2 | ...
```

**Restrictions:** cannot use `system()` or `popen()`. Use `fork`, `execvp`, `pipe`, `dup/dup2`, `open/read/write/close`, `wait`, `chdir`, `signal`.

**Shell process logic:**

- Parent shell repeatedly prompts/parses.
- For built-ins (`cd`, `exit`), execute in the shell process.
- For external commands, `fork()` a child, set up redirection/pipes, `execvp()` in child, parent `wait()`s.
- For pipelines, create N children and N-1 pipes; parent must close unused pipe ends and wait for all children.

### PA2 — MLFQ

- Simulates N-level feedback queue; last level FCFS.
- Input via stdin redirection, output via stdout redirection; test with `diff`.
- Key rules and PA2-specific details are in Section 7.5.
- Gantt chart must merge consecutive intervals of the same process.
- Test in CS Lab 2 environment; use `gcc -std=c99`.
- Do not hard-code given test cases.

---

# 8. Exam-Style Practice Questions

## 8.1 Fork and threads

**Q1.** How many processes are created by:

```c
for (int i = 0; i < 3; i++)
    fork();
```

**Answer:** $2^3 = 8$ processes total (the original plus 7 children).

**Q2.** After `fork()`, the child changes a global variable `x`. Does the parent see the change?  
**Answer:** No. The child has a copy of the address space. (Linux uses copy-on-write, but logically separate.)

**Q3.** In a multithreaded process, thread A writes a global variable. Thread B reads it after a `pthread_join`. Does B see the new value?  
**Answer:** Yes, assuming proper synchronization/join; threads share the address space.

**Q4.** What is the output of the lab Pthreads example?

```c
int counter = 0;
pthread_create(&thread, NULL, child, &counter);
pthread_join(thread, NULL);
printf("%d\n", counter);   /* 1 */
counter = 0;
pid_t pid = fork();
if (pid) wait(NULL);
else { child(&counter); exit(0); }
printf("%d\n", counter);   /* 0 */
```

**Answer:** `1` then `0`. Threads share memory; processes have separate memory.

## 8.2 Scheduling

**Q5.** Processes P1 (burst 10, arrival 0), P2 (burst 2, arrival 1), P3 (burst 4, arrival 3). Compute average waiting time under non-preemptive SJF.

**Answer:**

- t=0: only P1 → run 0–10.
- t=10: P2 (2) and P3 (4) available; SJF picks P2 10–12; then P3 12–16.
- Waiting: P1=0, P2=10−1=9, P3=12−3=9.
- Average = (0+9+9)/3 = **6**.

**Q6.** For the same processes, compute average waiting time under RR with q=2.

**Answer:**

- 0–2: P1 (remaining 8)
- 2–4: P2 (finishes at 4; P2 arrived at 1, first run at 2 → waited 1)
- 4–6: P3 (remaining 2; P3 arrived at 3, waited 3–4 = 1 so far)
- 6–8: P1 (remaining 6)
- 8–10: P3 (finishes at 10; waited 6–8 = 2 more, total wait 3)
- 10–12: P1 (remaining 4)
- 12–14: P1 (remaining 2)
- 14–16: P1 (finishes)
- P1 waiting = total turnaround 16 − burst 10 = 6 (runs 0–2, 6–8, 10–16; waits 2–6 and 8–10).
- Average = (6 + 1 + 3)/3 = **10/3 ≈ 3.33**.

**Q7.** Why is SJF optimal?  
**Answer:** It always runs the shortest job first among available jobs, minimizing the sum of waiting times for a fixed set of non-preemptive jobs. It is not optimal for response time or fairness.

**Q8.** What is the convoy effect?  
**Answer:** Under FCFS, one long CPU-bound process makes many short I/O-bound processes wait, increasing average waiting time.

## 8.3 Synchronization

**Q9.** Does Peterson’s algorithm satisfy all three critical-section requirements?  
**Answer:** Yes, for two processes: mutual exclusion, progress, and bounded waiting. It uses busy waiting.

**Q10.** What is wrong with this bounded-buffer producer?

```c
wait(mutex);
wait(empty);
/* add item */
signal(mutex);
signal(full);
```

**Answer:** The order is reversed. The producer holds `mutex` while waiting for `empty`. If the buffer is full, it blocks, and the consumer cannot acquire `mutex` to remove an item → **deadlock**. Correct order: `wait(empty); wait(mutex); ... signal(mutex); signal(full);`.

**Q11.** Binary semaphore vs mutex?  
**Answer:** A binary semaphore initialized to 1 can provide mutual exclusion, but it is not equivalent to a mutex: semaphores can be initialized to 0 for ordering, can be posted by a different thread, and do not have ownership. Mutexes are specifically for mutual exclusion and ownership.

**Q12.** Condition variable: why `while` instead of `if`?

```c
while (!condition)
    pthread_cond_wait(&cond, &mutex);
```

**Answer:** After waking, the thread must re-check the condition because another thread may have consumed it, or the wakeup may be spurious. `if` would allow the thread to proceed incorrectly.

**Q13.** Why does `pthread_cond_wait` release the mutex?  
**Answer:** If it did not, no other thread could acquire the mutex to change the condition and signal, causing deadlock. It releases the mutex atomically and reacquires it before returning.

**Q14.** Readers–writers: what is the role of each mutex?

**Answer:**

- `rw_mutex`: protects the shared data; writers hold it exclusively; first reader locks it, last reader unlocks it.
- `mutex`: protects the shared `read_count`.
- Multiple readers can read concurrently because they only briefly hold `mutex`.

## 8.4 Lab coding

**Q15.** Fill in the two-pipe blanks for bidirectional parent/child communication.

**Answer:**

```c
pipe(p2c);
pipe(c2p);

/* child */
close(c2p[0]);
write(c2p[1], msg, 6);
close(p2c[1]);
read(p2c[0], buffer, 7);

/* parent */
close(c2p[1]);
read(c2p[0], buffer, 6);
close(p2c[0]);
write(p2c[1], msg, 7);
```

**Q16.** How do you implement `ls | wc -l`?

**Answer:**

- Child: `close(1); dup2(pipefd[1], 1); close(pipefd[0]); execlp("ls","ls",NULL);`
- Parent: `close(0); dup2(pipefd[0], 0); close(pipefd[1]); wait(0); execlp("wc","wc","-l",NULL);`

**Q17.** How do you redirect stdout to `out.txt` before `execvp`?

**Answer:**

```c
int fd = open("out.txt", O_CREAT | O_WRONLY | O_TRUNC, 0600);
dup2(fd, 1);
close(fd);
execvp(cmd, args);
```

**Q18.** How do you wait for a child and get its exit status?

**Answer:**

```c
int status;
pid_t pid = wait(&status);
if (pid > 0 && WIFEXITED(status))
    printf("exit code = %d\n", WEXITSTATUS(status));
```

**Q19.** What does `dup2(oldfd, newfd)` do if `newfd` is already open?  
**Answer:** It closes `newfd` first, then makes `newfd` a copy of `oldfd`.

**Q20.** Why does a FIFO `open()` sometimes block?  
**Answer:** FIFO opens block until the other end is opened (reader waits for writer, or writer waits for reader), unless `O_NONBLOCK` is used.

---

# 9. Last-Minute Revision Sheet

## Must-know definitions

- **Process** = program in execution + address space + resources.
- **Thread** = unit of execution; own PC/registers/stack; shares code/data/heap/files.
- **PCB** = process state, PC, registers, scheduling, memory, accounting, I/O info.
- **Context switch** = save old state, load new state; pure overhead.
- **Race condition** = outcome depends on interleaving.
- **Critical section** = code accessing shared data; needs mutual exclusion.
- **Mutual exclusion / progress / bounded waiting** = three CS requirements.
- **Deadlock** = circular indefinite waiting; **starvation** = indefinite postponement.
- **Semaphore** = integer with atomic `wait`/`signal`; counting or binary.
- **Mutex** = lock with acquire/release; ownership.
- **Condition variable** = wait for a condition; always with a mutex.
- **Spinlock** = busy-waiting lock; good for short critical sections/multiprocessors.

## Must-know formulas

$$
T_{\text{avg}} = hT_{\text{hit}} + (1-h)T_{\text{miss}}
$$

$$
\tau_{n+1} = \alpha t_n + (1-\alpha)\tau_n
$$

$$
\text{turnaround} = \text{completion} - \text{arrival}
$$

$$
\text{waiting} = \text{turnaround} - \text{CPU burst}
$$

$$
\text{response} = \text{first run} - \text{arrival}
$$

$$
\text{Little's law: } n = \lambda W
$$

## Must-know code patterns

```c
/* fork */
pid_t pid = fork();
if (pid == 0) { /* child */ }
else if (pid > 0) { wait(NULL); }

/* pipe */
pipe(fd);                 /* fd[0] read, fd[1] write */

/* redirect stdout */
dup2(fd, 1);

/* pthread */
pthread_create(&tid, NULL, fn, arg);
pthread_join(tid, NULL);

/* mutex */
pthread_mutex_lock(&m);
/* critical section */
pthread_mutex_unlock(&m);

/* semaphore */
sem_wait(&s);
/* critical section */
sem_post(&s);

/* condition variable */
while (!condition)
    pthread_cond_wait(&cond, &mutex);
```

## Must-know MLFQ rules

- New process → Q0.
- Q0 not preempted by new arrivals.
- New arrival in Q0 **does** preempt lower queues.
- Preempted process keeps its remaining quantum and stays at the **front** of its queue.
- Full quantum in a non-last queue → demote to next queue with a fresh quantum.
- Last queue = FCFS.
- PA2: per-queue quantum; merge consecutive same-process Gantt intervals.

## Final exam strategy

1. **Read the whole question first.** Identify whether it asks for scheduling, synchronisation, fork output, or code.
2. **Write down knowns:** arrival/burst times, semaphore initial values, process/thread relationships.
3. **For scheduling:** draw the Gantt chart; then compute waiting/turnaround/response from the chart.
4. **For fork/thread output:** draw the process/thread tree; remember child memory is copied, thread memory is shared.
5. **For synchronisation:** check mutual exclusion, progress, bounded waiting; check wait/signal order for deadlock.
6. **For code:** close unused pipe ends, check return values, use `dup2`, and `wait()` for children.
7. **State assumptions** if the question is ambiguous; keep answers concise and legible.

---

*End of review.*
