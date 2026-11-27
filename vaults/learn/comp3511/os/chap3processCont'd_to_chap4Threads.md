# Chapter 3 (cont'd) → Chapter 4: Threads

> These notes continue **Chapter 3** right after **Dual Mode** and then cover **Chapter 4 (Threads)**.

---

# Chapter 3 (cont'd)

## Operations on Processes

Once an OS has multiple processes running, it needs ways to **create** and **destroy** them dynamically.

### Process Creation

A process can create other processes *during its own execution* using a **system call**.

- **Parent process** — the process that creates another process.
- **Child process** — the newly created process.

When a process is created, the OS must:

1. **Create a new PCB** (allocate the data structure and a unique **PID**).
2. **Allocate memory** for the new process.
3. **Copy data from the parent** (code, data, etc.) — this is the expensive part.
4. **Copy I/O state**, including any open files.

Once created, the child runs **concurrently** with the parent and other processes. It can keep running the parent's program, or load a **different** program with the `exec()` system call.

> **Simple example (concept):** a shell (parent) runs the `ls` command by creating a child process, then the child calls `exec()` to replace itself with the `ls` program.

---

### The `fork()` System Call (Unix/Linux)

`fork()` is the Unix/Linux system call that **creates a new process**.

**How it works:**

- It takes **no parameters**.
- It **duplicates the parent's entire address space** (code + data) into the child. This is the "odd" historical design — it's a full copy, but it made creation fast back when processes were small.
- **Two processes** (parent and child) both resume executing at the **next instruction after `fork()`**, because the child copied the parent's **program counter** too.

**Return values of `fork()`** (this is how you tell who is who):

| Return value | Meaning |
| --- | --- |
| **negative** | `fork()` **failed** — no child was created |
| **0** | You are in the **child** process |
| **positive** (the child's PID) | You are in the **parent** process |

> **Simple example (C):**
> ```c
> pid_t pid = fork();
>
> if (pid < 0) {
>     // fork failed
>     printf("fork failed\n");
> } else if (pid == 0) {
>     // This branch runs in the CHILD
>     printf("I am the child\n");
> } else {
>     // This branch runs in the PARENT (pid is the child's PID)
>     printf("I am the parent, child PID = %d\n", pid);
> }
> ```
>
> After `fork()`, **both** the parent and child execute the code after `fork()`. They run **concurrently** — either one can run first (the CPU scheduler decides), and their executions can be interleaved.

If the child wants to run a **different** program, it calls `exec()` (or `execlp()`) to load a new program into its address space, replacing the copied one.

---

### Process Termination

When a process finishes, the OS must **deallocate (reclaim) all its resources**.

Two special situations come up:

#### Zombie Process

- A process has **terminated**, but its **parent hasn't called `wait()`** yet.
- Its entry stays in the **process table** (with its exit status) so the parent can later collect it.
- A zombie **uses no CPU/memory**, but it still holds a PID and a process-table slot.

> **Analogy:** A student has finished an exam (terminated) but hasn't been picked up by their parent yet — they're still "on the roster" (process table) until the parent signs them out (`wait()`).

#### Orphan Process

- A process's **parent terminates** before calling `wait()`.
- The child is now an "orphan," but it may still be running.
- In Unix/Linux, the **`init` (PID 1)** or **`systemd`** process adopts the orphan and periodically calls `wait()` to collect its exit status and release its PID/PCB.

> **Analogy:** If a parent leaves a kid at school, a guardian (`init`) steps in to pick them up later.

**Summary flow:** every process briefly becomes a *zombie* before fully terminating. The parent's `wait()` cleans it up; if the parent dies first, `init`/`systemd` takes over.

---

## Interprocess Communication (IPC)

Processes can be **independent** or **cooperating**. Cooperating processes exchange data through **IPC**.

Benefits of cooperation: **information sharing, computation speedup, modularity, convenience**.

### Two Basic Modes of IPC

#### 1. Shared Memory

- Processes **share a region of memory**.
- Communication is **implicit** — process A writes to a shared variable, process B reads it. There is no explicit "message" sent.

> **Analogy:** Two people reading/writing on the **same whiteboard**. Whoever writes, the other can see it — no need to "hand" anything over.

#### 2. Message Passing

- Processes **send explicit messages** to each other.
- Communication happens via **`send()` and `receive()`** system calls.
- The OS (kernel) mediates the messages.

> **Analogy:** Two people passing **notes** to each other through a messenger (the OS).

**Direct vs. Indirect communication:**

- **Direct** — sender must know the receiver's **identity** (send directly to a named process).
- **Indirect** — messages go to a **mailbox**; sender and receiver don't need to know each other's identity.

**Message queue capacity** (where messages wait):

| Type | Capacity | Behavior |
| --- | --- | --- |
| **Zero capacity** | 0 messages queued | Sender must **wait** for receiver (rendezvous) |
| **Bounded capacity** | finite | Sender waits only if the queue is **full** |
| **Unbounded capacity** | infinite | Sender **never** waits |

---

## Pipes

A **pipe** is a concrete way for two processes to communicate in a **producer → consumer** fashion.

### Ordinary (Anonymous) Pipes

- **Unidirectional** — data flows one way, from the **write end** (`fd[1]`) to the **read end** (`fd[0]`).
- Created with `pipe(int fd[])`.
- Unix treats a pipe like a **special file**, so you can use `read()` and `write()` on it.
- Can **only** be accessed by the process that created it (typically a parent communicating with its child).
- The pipe **disappears** when the processes using it terminate.

> **Simple example:** `ls | grep x`
>
> The shell runs both commands and connects the **output of `ls`** to the **input of `grep`**. `ls` (producer) writes a list of files; `grep` (consumer) reads that list and prints only lines containing "x".

### Named Pipes (FIFOs)

- **More powerful** than ordinary pipes.
- **Bidirectional** and **does not require a parent–child relationship**.
- Multiple processes can read from and write to it.
- Created with `mkfifo()` in Unix; appears as a **regular file** in the filesystem.
- **Persists** after the processes terminate — it must be **explicitly deleted**.

> **Analogy:** an ordinary pipe is a temporary straw between two connected processes; a named pipe is a permanent mailbox in the filesystem that anyone can drop into or pick up from.

*(Windows also has **anonymous** pipes ≈ Unix ordinary pipes, and **named** pipes.)*

---

## Client–Server Communication

Communication in a client–server system has two key features:

1. The **server is always running** with a **well-known address**, waiting for clients.
2. **Only clients initiate** contact with the server.

Two mechanisms:

### Sockets

- A **socket** is an **endpoint** of communication.
- A connection = a **pair of sockets**, one at each end.
- Each endpoint is identified by an **IP address** (the host) + a **port number** (the specific process/application).

> The **4-tuple** uniquely identifies a connection over the Internet:
> **(source IP, source port, destination IP, destination port)**

> **Analogy:** An IP address is like a **building address**; the port number is like a specific **apartment number** inside it.

### Remote Procedure Calls (RPC)

- A way to **call a function that runs on a remote machine** as if it were local.
- The client "calls" a procedure, the call is packaged and sent to the server, which executes it and returns the result.

> **Analogy:** Ordering at a restaurant — you (client) call a "procedure" like "make me a pizza," the kitchen (server) does the work, and you get the result back, without you cooking it yourself.

---

# Chapter 4: Threads

## Motivation & Benefits of Threads

### What is a Thread?

A **thread** is a **flow of control within a process** — the basic **unit of execution** that the CPU schedules.

Each thread has its **own**:

- **Thread ID**
- **Program counter** (PC)
- **Register set**
- **Stack**

But threads **share** (with other threads in the same process):

- **Code** (text)
- **Data**
- **Heap**
- **Open files**

> **Key idea:** A process has an **address space** + one or more **threads**. A thread = "execution unit"; the address space = "the stuff being shared."

Each thread is represented in the OS by a **Thread Control Block (TCB)** containing its state and scheduling/accounting info. If a process has multiple threads, **the process itself has no single state** — only each thread does.

### Why Threads? (The Main Motivation)

A process may need to do **multiple tasks at once**. Creating a **separate process** for each task is expensive because:

- Code/data get **duplicated** across processes (redundancy).
- **Context switching** between processes is costly.
- **IPC** between processes is slow.

A **multithreaded process** lets related tasks share code, data, and files — much cheaper.

> **Simple examples:**
> - **Web browser** — one thread displays images/text while another retrieves data from the network.
> - **Word processor** — one thread displays text, one reads keyboard input, one spell-checks in the background.

### Four Benefits of Multithreading

1. **Responsiveness** — one thread can keep the UI interactive while another blocks (e.g., waiting for I/O).
2. **Resource sharing** — threads automatically share the process's memory/files (no IPC needed).
3. **Economy** — creating a thread is **cheaper** than creating a process; context switching between threads is also cheaper.
4. **Scalability** — threads can run **in parallel** on multiple CPU cores.

---

## Concurrency vs. Parallelism

- **Concurrency** — multiple threads **make progress over a single CPU** by interleaving (one at a time, switching fast).
- **Parallelism** — multiple threads make progress **simultaneously on different CPU cores**.

> **Simple example:**
> - **Concurrency** = one barista making two drinks by switching back and forth.
> - **Parallelism** = two baristas each making a drink at the same time.

On a **single-core** system, only **concurrency** is possible. **Parallelism** requires **multicore** or multi-processor systems.

### Multicore Systems

- **Multiple cores on one chip** are more efficient than multiple single-core chips because:
  - On-chip communication is **faster** than between-chip communication.
  - One multicore chip uses **less power** (important for laptops/mobile).

### Data Parallelism vs. Task Parallelism

- **Data parallelism** — split the **same data** across cores; each core runs the **same operation** on its subset.
- **Task parallelism** — distribute **different tasks (unique operations)** across cores.

> **Simple example:**
> - **Data parallelism:** 4 cores each add up a quarter of a huge array of numbers.
> - **Task parallelism:** one core decodes audio while another renders graphics while another handles physics.

Real applications usually use **both**.

---

## Multithreading Models

There are **two kinds** of threads:

- **User threads** — managed by a **thread library** in user space, **invisible to the kernel**.
- **Kernel threads** — **supported and managed by the OS** (all modern OSes support them).

User threads must be **mapped** onto kernel threads so the OS can schedule them. Three common mappings:

### 1. Many-to-One

- **Many** user threads → **one** kernel thread.
- Thread management is done by the thread library (user space), so it's fast and cheap.
- The OS sees the process as **single-threaded**.
- ❌ If **one** thread makes a blocking system call, the **whole process blocks**.
- ❌ Threads **cannot run in parallel** on multicore systems.

> **Analogy:** One checkout lane (kernel thread) serving many customers (user threads) — if the first customer stalls, everyone behind waits.

### 2. One-to-One

- **Each** user thread → **one** kernel thread.
- ✅ **Maximum concurrency** — if one thread blocks, another can run.
- ✅ Allows **parallel** execution on multiple cores.
- ❌ Creating each user thread requires a **kernel thread** (more overhead), so systems limit the total number of threads.

> **Analogy:** Every customer gets their **own checkout lane**.

### 3. Many-to-Many

- **Many** user threads → a **smaller or equal** number of kernel threads.
- ✅ **Better concurrency** than many-to-one; **less overhead** than one-to-one.
- ✅ The number of user threads is **not limited** by the number of kernel threads.
- The kernel and thread library cooperate to **dynamically adjust** the number of kernel threads.

> **Analogy:** A **pool of checkout lanes** (kernel threads) shared by many customers (user threads) — lanes can be added/removed as needed.

### Lightweight Process (LWP)

- An **intermediate data structure** between user threads and kernel threads.
- To the thread library, an LWP looks like a **virtual processor** on which a user thread can run.
- Each **LWP is attached to one kernel thread**; the OS schedules **kernel threads** on the CPU.
- If a kernel thread blocks (e.g., waiting for I/O), its LWP blocks too.

> **Important note:** The OS (CPU scheduler) only schedules **kernel threads**, not user threads. The TCB is associated with the **kernel thread**, not the user thread.

---

## Threading Issues

### `fork()` and `exec()` in a Multithreaded Program

- `fork()` called by a thread creates a new process that either:
  1. **Duplicates all threads** of the parent, **or**
  2. **Duplicates only the calling thread**.
- `exec()` **replaces the entire process, including all threads**.
- **Optimization:** if `exec()` is called right after `fork()`, there's **no need** to duplicate all threads — just the calling thread is enough.

> **Why:** creating a **thread** is much simpler than creating a **process** — only a new TCB and stack are needed (the process data structure stays the same).

### Signals

A **signal** notifies a process that an event has occurred.

- **Synchronous signal** — delivered to the **same process** that caused it (e.g., **division by zero**, **illegal memory access**).
- **Asynchronous signal** — generated by an event **external** to the running process (e.g., a **timer expiring**, or the `kill` command).
- Handled by a **default handler** or a **user-defined handler** (which overrides the default).

### Thread Cancellation

Two ways to terminate a thread:

- **Asynchronous cancellation** — stops the thread **immediately**, even mid-critical-update. ❌ The OS may not reclaim all resources.
- **Deferred cancellation** — tells the thread to terminate, but **lets it clean up first** (orderly). ✅ **Preferred** in most cases.

> **Analogy:** Asynchronous = pulling the plug immediately; deferred = asking someone to "finish what you're doing, then shut down."

---

## Linux: Processes vs. Threads (`clone()`)

- **Unlike most OSes, Linux does NOT distinguish between processes and threads** — it calls both a **task**.
- Linux's **`clone()`** system call creates a task that can behave **more like a process or more like a thread**, depending on **which resources it shares** with the parent.
- Unlike `fork()` (which makes a full copy), `clone()` can create a task that **shares the parent's address space**.
- **Flags** determine the **extent of sharing**.
- `clone()` requires loading a **new function** (`*fn`) to execute.

> **Simple idea:**
> - `fork()` = full copy → behaves like a **process**.
> - `clone()` with sharing flags = shares address space → behaves like a **thread**.

---

## Quick Recap / Cheat Sheet

| Concept | One-liner |
| --- | --- |
| **Parent / Child** | The creating process / the created process |
| **`fork()`** | Duplicates the parent's address space; returns 0 to child, child-PID to parent |
| **`exec()`** | Replaces a process's program with a new one |
| **Zombie** | Terminated but parent hasn't `wait()`ed yet |
| **Orphan** | Parent died first; adopted by `init`/`systemd` |
| **Shared memory** | Implicit communication via a common region |
| **Message passing** | Explicit `send()`/`receive()` messages |
| **Ordinary pipe** | Unidirectional, parent–child, disappears on exit |
| **Named pipe (FIFO)** | Bidirectional, persists in filesystem |
| **Socket** | Endpoint = IP + port |
| **Thread** | Unit of execution; own PC/registers/stack, shares code/data/heap/files |
| **Concurrency** | Interleaved progress on one CPU |
| **Parallelism** | Simultaneous progress on multiple cores |
| **Many-to-One** | Cheap but blocks whole process on a blocking call |
| **One-to-One** | Max concurrency, more overhead |
| **Many-to-Many** | Balanced; dynamic kernel-thread count |
| **LWP** | Virtual processor bridging user and kernel threads |
| **`clone()`** | Linux's flexible process/thread creator |
