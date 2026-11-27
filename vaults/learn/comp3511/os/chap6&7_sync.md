# Chapter 6 & 7: Synchronization Tools and Classic Examples

> Summary of **Chapter6_synchronization.pdf** (race conditions, critical-section problem, hardware solutions, mutex locks, semaphores, deadlock/starvation) and **Chapter7_syncExample.pdf** (bounded-buffer, readers-writers, OS/POSIX synchronization examples).

---

# Part I — Chapter 6: Synchronization Tools

## 1. Background: Why Synchronization?

- Processes execute **concurrently** and may be **interrupted at any time**, partially completing execution.
- **Concurrent access to shared data can cause data inconsistency.**
- We need OS mechanisms to ensure **orderly execution of cooperating processes**.

### The Producer–Consumer Illustration

A shared integer `counter` tracks how many buffer slots are occupied (initially 0). The producer does `counter++` after producing; the consumer does `counter--` after consuming.

### Race Condition

`counter++` and `counter--` are **not atomic** — each compiles to 3 machine instructions:

```
counter++ :  register1 = counter;  register1 = register1 + 1;  counter = register1;
counter-- :  register2 = counter;  register2 = register2 - 1;  counter = register2;
```

> **Simple example:** Start with `counter = 5`, and interleave as follows:
>
> | Step | Action | Result |
> |---|---|---|
> | S0 | producer: `register1 = counter` | register1 = 5 |
> | S1 | producer: `register1 = register1 + 1` | register1 = 6 |
> | S2 | consumer: `register2 = counter` | register2 = 5 |
> | S3 | consumer: `register2 = register2 - 1` | register2 = 4 |
> | S4 | producer: `counter = register1` | counter = 6 |
> | S5 | consumer: `counter = register2` | counter = **4** |
>
> One increment and one decrement were performed, but the result is 4 (should be 5). The outcome **depends on the interleaving** — with unlucky context switches the result is **non-deterministic**.

**Definition — Race Condition:** several processes access/manipulate shared data concurrently, and the **outcome depends on the particular order** of execution.

Another kernel example: two processes calling `fork()` concurrently race on `next_available_pid`; without mutual exclusion, **two processes could get the same PID**.

---

## 2. The Critical-Section Problem

- Each of n processes has a **critical section**: a code segment where it may change shared variables, update a table, write a file, etc.
- **Requirement:** when one process is in its critical section, **no other process** may be in *its* critical section (**mutual exclusion**).
- Each process must **ask permission** in an **entry section**, then runs the **critical section**, then an **exit section**, then a **remainder section**.

```
do {
    entry section        // request permission
        critical section
    exit section         // release permission
        remainder section
} while (true);
```

### Requirements for a Valid Solution

1. **Mutual Exclusion** — if Pᵢ is in its critical section, no other process is in theirs.
2. **Progress** — if no process is in its critical section and some want to enter, the choice of who goes next **cannot be postponed indefinitely** (no deadlock on the entry decision).
3. **Bounded Waiting** — after a process requests entry, there is a **bound** on how many times *other* processes may enter before its request is granted (no starvation).

Assume every process runs at nonzero speed; no assumptions about relative speeds.

### Critical Sections in the Kernel

Kernel code has races too: lists of open files, memory-allocation structures, the process table, interrupt handling.

- **Preemptive kernel**: a process can be preempted **while in kernel mode** → not free of race conditions; especially hard on SMP.
- **Non-preemptive kernel**: kernel code runs until it exits kernel mode, blocks, or voluntarily yields → essentially **free of kernel-mode races** (on a single processor).

---

## 3. Synchronization Hardware

- On a **uniprocessor**, you could simply **disable interrupts** so running code can't be preempted — but this is **inefficient on multiprocessors**.
- Modern systems provide special **atomic hardware instructions** (atomic = **non-interruptible**, so no race can occur mid-instruction). These are building blocks for higher-level tools.
  - `test_and_set()` — test a memory word and set it.
  - `compare_and_swap()` — compare a memory word and swap conditionally.

### test_and_set

```c
boolean test_and_set(boolean *target) {
    boolean rv = *target;
    *target = TRUE;
    return rv;
}
```

Mutual-exclusion lock (shared `lock` initialized to FALSE):

```c
do {
    while (test_and_set(&lock))
        ;                          /* busy wait */
    /* critical section */
    lock = false;
    /* remainder section */
} while (true);
```

> **How it works:** The first process to execute `test_and_set` sees `lock == FALSE` (returned), sets it TRUE, and enters. Everyone else keeps getting TRUE back and spins.

### compare_and_swap (CAS)

```c
int compare_and_swap(int *value, int expected, int new_value) {
    int temp = *value;
    if (*value == expected)
        *value = new_value;
    return temp;
}
```

Lock solution (`lock` initialized to 0):

```c
do {
    while (compare_and_swap(&lock, 0, 1) != 0)
        ;                          /* busy wait */
    /* critical section */
    lock = 0;
    /* remainder section */
} while (true);
```

> Only the process that observes `lock == 0` gets to flip it to 1 in one atomic step.

### Bounded Waiting with test_and_set

The simple loops above give mutual exclusion but **not bounded waiting**. A full solution adds a per-process `waiting[]` array: a process leaving its critical section **scans cyclically** (i+1, i+2, …) for the first waiting process and unblocks exactly that one.

- **Mutual exclusion:** only the first process to run `test_and_set` finds `key == false`; only one `waiting[i]` is cleared at a time.
- **Progress:** the exiting process either sets `lock = false` or `waiting[j] = false`, letting someone in.
- **Bounded waiting:** cyclic scan → any waiting process enters within **n − 1 turns**.

### Atomic Variables

CAS is a building block for **atomic variables** (e.g., `atomic_int`) whose updates can't be interrupted. Example — atomic increment:

```c
void increment(atomic_int *v) {
    int temp;
    do {
        temp = *v;
    } while (temp != compare_and_swap(v, temp, temp + 1));
}
```

> **Idea:** read the value, try to CAS it to value+1; if another thread changed it in between (CAS returns the new current value ≠ temp), retry.

---

## 4. Mutex Locks

The simplest software tool the OS provides: **acquire()** before the critical section, **release()** after. Both must be **atomic** (usually built on the hardware instructions above).

```c
acquire() {                      release() {
    while (!available)               available = true;
        ; /* busy wait */        }
    available = false;
}
```

```
do {
    acquire lock
        critical section
    release lock
        remainder section
} while (true);
```

- At most **one thread** holds the lock at a time; wait if locked.
- This design uses **busy waiting** → such a lock is a **spinlock**.
  - **Downside:** wastes CPU cycles while waiting.
  - **Advantage:** **no context switch** needed to wait. When locks are held only **briefly**, spinning is cheaper than sleeping.
  - Spinlocks are natural on **multiprocessors**: one thread spins on its CPU while the holder finishes on another CPU.

---

## 5. Semaphores

- A **semaphore S** is a **non-negative integer variable** — a generalized lock, defined by **Dijkstra** (1960s); the main synchronization primitive of original UNIX.
- Accessed **only** via two **atomic** operations:
  - `wait(S)` — originally `P()` ("proberen", to test)
  - `signal(S)` — originally `V()` ("verhogen", to increment)
- Atomicity guarantees that no two processes execute `wait`/`signal` on the same semaphore simultaneously (**serialization**).

```c
wait(S) {            signal(S) {
    while (S <= 0)       S++;
        ; // busy wait
    S--;
}
```

### Two Kinds

| Type | Range | Use |
| --- | --- | --- |
| **Counting semaphore** | Unrestricted non-negative integers | Control access to a resource with **N instances**; initialize S = N |
| **Binary semaphore** | 0 or 1 only | Behaves like a **mutex lock**; also for ordering constraints |

> **Simple example (ordering):** Force statement `S1` in P1 to run **before** `S2` in P2, using a binary semaphore `synch` initialized to **0**:
>
> ```
> P1:  S1;  signal(synch);
> P2:  wait(synch);  S2;
> ```
>
> If P2 runs first, `wait` blocks it (synch = 0) until P1 signals.

### Implementation Without Busy Waiting

Give each semaphore a **waiting queue**; use `block()` (suspend the caller, put it on the queue) and `wakeup(P)` (move P to the ready queue):

```c
typedef struct {
    int value;
    struct process *list;
} semaphore;

wait(semaphore *S) {            signal(semaphore *S) {
    S->value--;                     S->value++;
    if (S->value < 0) {             if (S->value <= 0) {
        add to S->list;                 remove P from S->list;
        block();                        wakeup(P);
    }                               }
}                               }
```

**Key differences from the busy-wait version:**
- Increment/decrement happen **before** the check.
- **Semaphore values can be negative** here; if negative, **its magnitude = number of processes waiting** on it.

---

## 6. Deadlock and Starvation

- **Deadlock**: two or more processes wait **indefinitely** for an event that only one of the *waiting* processes can cause.

> **Simple example:** Two semaphores S and Q, both initialized to 1:
>
> ```
> P0: wait(S); wait(Q); ... signal(Q); signal(S);
> P1: wait(Q); wait(S); ... signal(S); signal(Q);
> ```
>
> If P0 grabs S and P1 grabs Q, then P0 waits for Q (held by P1) and P1 waits for S (held by P0). Neither `signal` ever runs → **deadlocked**. Extremely hard to debug. (Lesson: acquire resources in a consistent global order.)

- **Starvation**: **indefinite blocking** — a process is never removed from the semaphore queue, e.g., if the queue is served **LIFO** or by priority and the process is always skipped.

---

# Part II — Chapter 7: Classic Synchronization Examples

## 1. Bounded-Buffer Problem (Producer–Consumer done right)

**Setup:** n buffer slots, three semaphores:

| Semaphore | Init | Meaning |
| --- | --- | --- |
| `mutex` | 1 | Mutual exclusion for accessing the buffer |
| `full` | 0 | Number of slots currently **filled** |
| `empty` | n | Number of slots currently **empty** |

**Producer:**

```c
do {
    /* produce an item in next_produced */
    wait(empty);          /* wait for a free slot  */
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
    /* remove an item into next_consumed */
    signal(mutex);
    signal(empty);        /* one more free slot */
    /* consume the item */
} while (true);
```

> **Why two waits?** `empty`/`full` handle the **resource counting** (don't produce into a full buffer / consume from an empty one), while `mutex` protects the **buffer pointers** themselves from races. Note the **order matters**: take the resource semaphore *before* the mutex — reversing them can deadlock (holding the mutex while blocked forever on `empty`).

---

## 2. Readers–Writers Problem

- A shared data set is used by **readers** (read only) and **writers** (read + write).
- **Goal:** allow **multiple readers simultaneously**, but **only one writer** at a time (and no readers while a writer writes).

### First Readers–Writers Problem (readers have priority)

No reader waits unless a **writer already holds** the data. Shared data:

| Variable | Init | Purpose |
| --- | --- | --- |
| `rw_mutex` (semaphore) | 1 | Exclusive access to the data (writers and the *first/last reader*) |
| `mutex` (semaphore) | 1 | Protects `read_count` among readers |
| `read_count` (int) | 0 | How many readers are currently reading |

**Writer:**

```c
do {
    wait(rw_mutex);
    /* writing is performed */
    signal(rw_mutex);
} while (true);
```

**Reader:**

```c
do {
    wait(mutex);
    read_count++;
    if (read_count == 1)
        wait(rw_mutex);       /* first reader locks the data */
    signal(mutex);

    /* reading is performed */

    wait(mutex);
    read_count--;
    if (read_count == 0)
        signal(rw_mutex);     /* last reader unlocks the data */
    signal(mutex);
} while (true);
```

> **How it works:** `rw_mutex` guards the data for writers and for the **first reader in / last reader out**; `mutex` only guards the shared counter `read_count`. Subsequent readers only wait on `mutex`, so they **pile in concurrently** while the first reader holds `rw_mutex`.

### Variations and Trade-offs

| Variation | Policy | Consequence |
| --- | --- | --- |
| **First** (readers-preference) | No reader waits unless a writer is active | Writers may **starve**; data updates can be delayed a long time |
| **Second** (writers-preference) | Once a writer is waiting, **no new readers** may start | Readers may **starve** |

Either version can starve somebody. Kernels address this with **reader–writer locks**: many holders in **read mode**, exactly one in **write mode** (exclusive). Acquiring such a lock requires specifying the **mode** (read or write).

---

## 3. Synchronization in Real Operating Systems

### Solaris
- Uses **adaptive mutexes** for short code segments (a few hundred instructions):
  - Implemented as a spinlock on multiprocessors.
  - If the lock is held by a thread **running on another CPU** → **spin**.
  - If held by a **non-running** thread → **block/sleep** until signaled.
- Uses **condition variables**, and **reader–writer locks** for longer, mostly read-only sections (they're relatively expensive, so used only when worthwhile).

### Windows
- **Uniprocessor**: kernel masks **interrupts** to protect global resources.
- **Multiprocessor**: kernel uses **spinlocks** for short segments, and guarantees a thread is **never preempted while holding a spinlock** (for efficiency).
- **User mode**: **dispatcher objects** — mutexes, semaphores, **events** (≈ condition variables: notify a waiting thread when a condition occurs), and **timers** (notify after a time expires).
- A dispatcher object is either **signaled** (available — a wait succeeds) or **non-signaled** (a thread blocks).

### Linux
- Before kernel **2.6**: disabled interrupts for short critical sections. **2.6+**: **fully preemptive** kernel.
- Provides **semaphores**, **spinlocks** (multiprocessor), **atomic integers** (`atomic_t`; all math ops on them are uninterruptible), and **reader–writer locks**.
- On a **single CPU**, spinlocks are replaced by simply **disabling/enabling kernel preemption**.

```c
atomic_t counter;    /* Linux atomic integer */
int value;
```

---

## 4. POSIX Synchronization (Pthreads API)

POSIX provides **mutex locks**, **semaphores**, and **condition variables** — widely used on UNIX/Linux/macOS.

### POSIX Mutex Locks

```c
pthread_mutex_t mutex;
pthread_mutex_init(&mutex, NULL);     /* create and initialize */

pthread_mutex_lock(&mutex);           /* acquire */
/* critical section */
pthread_mutex_unlock(&mutex);         /* release */
```

### POSIX Condition Variables

A condition variable is always used **together with a mutex** that provides the mutual exclusion:

```c
pthread_mutex_t mutex;
pthread_cond_t  cond_var;
pthread_mutex_init(&mutex, NULL);
pthread_cond_init(&cond_var, NULL);
```

**Thread waiting for condition `a == b`:**

```c
pthread_mutex_lock(&mutex);
while (a != b)
    pthread_cond_wait(&cond_var, &mutex);
/* ... use shared data ... */
pthread_mutex_unlock(&mutex);
```

**Thread signaling:**

```c
pthread_mutex_lock(&mutex);
a = b;                                  /* change the condition */
pthread_cond_signal(&cond_var);
pthread_mutex_unlock(&mutex);
```

**Key mechanics to remember:**
- `pthread_cond_wait(&cond, &mutex)` **atomically releases the mutex and puts the caller to sleep**. If it didn't release the lock, no other thread could acquire the mutex to make the condition true and signal it → deadlock.
- **Hold the mutex when signaling** and when modifying the shared condition — otherwise you introduce race conditions (e.g., a wakeup could be missed).
- Before `pthread_cond_wait()` **returns**, it **reacquires the mutex**, so the waiting thread always owns the lock between its initial lock and final unlock.
- The condition is checked in a **`while` loop** (not `if`) because the thread must re-test after reacquiring the lock.

> **Simple example:** A consumer waits on `cond_var` until `count > 0`. The producer, holding the same mutex, increments `count` and calls `pthread_cond_signal`. The consumer wakes up, **reacquires the mutex**, re-checks `count > 0`, consumes, and unlocks.

---

# Quick Reference

| Tool | Busy wait? | Typical use |
| --- | --- | --- |
| Disable interrupts | — | Short critical sections, single-CPU kernels |
| `test_and_set` / `compare_and_swap` | Yes | Hardware building blocks for everything else |
| Spinlock (mutex w/ busy wait) | Yes | Very short critical sections, multiprocessors |
| Sleeping mutex lock | No (blocks) | General mutual exclusion |
| Binary semaphore | Either | Mutual exclusion **and** execution ordering |
| Counting semaphore | Either | Managing N identical resources |
| Reader–writer lock | Either | Many concurrent readers, exclusive writer |
| Condition variable (+mutex) | No | Wait for an arbitrary **condition**, not just a lock |
