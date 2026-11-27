# COMP 3511 — Homework 3 Solutions

---

## 1. Multiple Choices

| MC1 | MC2 | MC3 | MC4 | MC5 | MC6 | MC7 | MC8 | MC9 | MC10 |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|------|
| B   | D   | A   | C   | B   | C   | D   | A   | B   | C    |

**Brief justifications**

1. **B** — On a single CPU, a context switch can interrupt a thread between the load/use/store steps of a shared-data update, so the accesses interleave and produce a race condition.
2. **D** — `S = 0`; T0 runs `A` then `signal(S)`; T1 runs `wait(S)` then `B`. If T1 arrives first it blocks until T0 signals after `A`.
3. **A** — Solaris adaptive mutex: spin only if the owner is running on another CPU; if the owner is **not running**, the waiting thread blocks and sleeps.
4. **C** — `pthread_cond_wait` atomically releases the mutex while waiting and reacquires it before returning.
5. **B** — Second readers–writers (writers-preference): once a writer is waiting, newly arriving readers must wait so they do not delay the waiting writer.
6. **C** — Requiring all resources to be obtained before execution and making no further requests while holding them directly breaks **hold and wait**.
7. **D** — With multiple instances, a cycle means deadlock is *possible* but does not prove deadlock.
8. **A** — Unsafe means deadlock is possible in the future; it does not mean deadlock has already occurred.
9. **B** — The multi-instance detection algorithm selects a process with `Request_i ≤ Work`.
10. **C** — Including the number of prior rollbacks in victim-selection cost prevents the same process from being repeatedly chosen (starvation).

---

## 2. Synchronization

### 2.1 Interleaved updates

`x = 12` initially. T0 performs `+3`; T1 performs `-2`.

**(a)** Possible final values of `x`: **10, 13, 15**.

Reason: the final value is determined by whichever write (`W0` or `W1`) happens last.

- If `W0` is last: T0's read value is either 12 (before `W1`) or 10 (after `W1`), so final value is 15 or 13.
- If `W1` is last: T1's read value is either 12 (before `W0`) or 15 (after `W0`), so final value is 10 or 13.

The value produced by **either serial execution order is 13**:

- T0 then T1: `12 → 15 → 13`
- T1 then T0: `12 → 10 → 13`

**(b)** Interleaving that ends with `x = 10`:

| Step | Statement | Result |
|------|-----------|--------|
| 1 | L0: `r0 = x` | `r0 = 12` |
| 2 | A0: `r0 = r0 + 3` | `r0 = 15` |
| 3 | L1: `r1 = x` | `r1 = 12` (x is still 12) |
| 4 | A1: `r1 = r1 - 2` | `r1 = 10` |
| 5 | W0: `x = r0` | `x = 15` |
| 6 | W1: `x = r1` | `x = 10` |

**Which update is lost:** T0's `+3` update is lost. T1 read the old value 12 before T0's write became visible, computed 10, and then wrote 10 *after* T0 wrote 15, overwriting T0's result.

---

### 2.2 Atomic instructions and waiting

**(a)**

- T0's call: `test_and_set` returns **false** (old value), and sets `lock = true`.
- T1's call (before T0 releases): returns **true** (lock is already true), and sets `lock = true` again.
- After both calls: **`lock = true`**.

**(b)** **No**, this spinlock does **not** guarantee bounded waiting.

Possible pattern: after T0 finishes its critical section and executes `lock = false`, T0 can immediately loop back and execute `test_and_set` again before T1 gets a chance to run. This can repeat indefinitely (e.g., T1 keeps being descheduled), so T1 may spin forever while T0 repeatedly reacquires the lock. The simple `test_and_set` lock gives mutual exclusion but allows starvation.

---

### 2.3 A semaphore with a waiting queue

**(a)**

| Operation | S.value | Waiting queue (front → back) |
|-----------|---------|------------------------------|
| After P0 `wait(S)` | 0  | (empty) |
| After P1 `wait(S)` | -1 | P1 |
| After P2 `wait(S)` | -2 | P1, P2 |
| After P0 `signal(S)` | -1 | P2 |

**(b)** A negative `S.value` means all permits are gone and there are blocked waiters. In this implementation, **`|S.value|` equals the number of processes waiting in the queue**. For example, `S.value = -2` means two processes are blocked on the semaphore.

---

## 3. Classic Synchronization Problems

### 3.1 A bounded job buffer

**(a)** Initial values:

- `mutex = 1`
- `empty = 5`  (8 slots − 3 initial jobs)
- `full = 3`

**(b)**

| Blank | Call | Purpose |
|-------|------|---------|
| B1 | `wait(empty)` | Wait until at least one buffer slot is free before inserting. |
| B2 | `wait(mutex)` | Acquire mutual exclusion on the buffer. |
| B3 | `signal(mutex)` | Release mutual exclusion after removing a job. |
| B4 | `signal(empty)` | Increment the count of free slots after removal. |

Producer / consumer fill-in:

```
Producer                          Consumer
while (true) {                    while (true) {
   item = produce();                 wait(full);
   wait(empty);   // B1              wait(mutex);
   wait(mutex);   // B2              item = remove();
   insert(item);                     signal(mutex); // B3
   signal(mutex);                    signal(empty); // B4
   signal(full);                     consume(item);
}                                 }
```

**(c)** Deadlock sequence (starting from a full buffer, `mutex` free):

1. **Producer:** `wait(mutex)` → producer acquires `mutex`.
2. **Producer:** `wait(empty)` → `empty = 0`, so producer blocks waiting for `empty` (while still holding `mutex`).
3. **Consumer:** `wait(full)` → succeeds because the buffer is full (`full > 0`).
4. **Consumer:** `wait(mutex)` → blocks because `mutex` is held by the producer.

Now:

- Producer waits for **`empty`** (a free slot that only the consumer can create).
- Consumer waits for **`mutex`** (held by the blocked producer).

Neither can proceed → deadlock.

**Correction:** restore the original order in the producer:

```
wait(empty);
wait(mutex);
```

The producer must reserve a slot **before** acquiring the mutex, so it never holds the mutex while waiting for `empty`.

---

### 3.2 Readers and writers

**(a)**

- **R1** blocks on **`rw_mutex`** (the writer holds it).
- **R2** blocks on **`mutex`** (R1 incremented `read_count` to 1 but has not yet executed `signal(mutex)` because it is blocked on `rw_mutex`).
- **`read_count = 1`** at this time.

**(b)** The **second (last) reader to leave** releases `rw_mutex`.

When the first of the two readers leaves, `read_count` drops from 2 to 1, so `read_count == 0` is false and `rw_mutex` is not signaled. When the last reader leaves, `read_count` drops from 1 to 0, the condition `read_count == 0` is true, and it signals `rw_mutex`.

The `read_count` updates must be protected by `mutex` because `read_count++` and `read_count--` are not atomic and the counter is shared among all readers. Without mutual exclusion, concurrent readers could interleave these updates, lose an update, and misjudge when the first/last reader enters/leaves (e.g., never releasing `rw_mutex`).

**(c)** **Yes, the writer can starve.**

This is the **first (readers-preference)** solution. The writer is blocked on `rw_mutex`. As long as readers keep arriving, `read_count` never drops to 0, so the condition `read_count == 0` (which triggers `signal(rw_mutex)`) is never reached. New readers do not wait on `rw_mutex` once a reader already holds it; they only need `mutex`, so they keep entering and reading. Therefore the writer can be delayed indefinitely.

---

## 4. Deadlock and the Banker's Algorithm

Vector order is `(A, B, C, D)`.

Original:

- `Available = (2, 1, 1, 1)`

| Process | Allocation | Max |
|---------|-----------|-----|
| P0 | (1, 0, 1, 0) | (2, 0, 1, 1) |
| P1 | (1, 1, 0, 1) | (2, 3, 1, 2) |
| P2 | (0, 1, 1, 0) | (2, 2, 3, 1) |
| P3 | (1, 0, 0, 1) | (1, 1, 1, 3) |
| P4 | (0, 1, 0, 1) | (2, 2, 2, 1) |

### (a) Need matrix

`Need = Max − Allocation`

| Process | A | B | C | D |
|---------|---|---|---|---|
| P0 | 1 | 0 | 0 | 1 |
| P1 | 1 | 2 | 1 | 1 |
| P2 | 2 | 1 | 2 | 1 |
| P3 | 0 | 1 | 1 | 2 |
| P4 | 2 | 1 | 2 | 0 |

### (b) Is the original state safe?

**Yes.** Safe sequence: **P0 → P2 → P1 → P3 → P4**.

| After completion of | Work |
|---------------------|------|
| Initially | (2, 1, 1, 1) |
| P0 | (3, 1, 2, 1) |
| P2 | (3, 2, 3, 1) |
| P1 | (4, 3, 3, 2) |
| P3 | (5, 3, 3, 3) |
| P4 | (5, 4, 3, 4) |

### (c) P2 requests (1, 0, 1, 0)

**Preliminary checks:**

1. `Request ≤ Need[P2]`: `(1,0,1,0) ≤ (2,1,2,1)` ✔
2. `Request ≤ Available`: `(1,0,1,0) ≤ (2,1,1,1)` ✔

**Tentative state:**

- `Available = (2,1,1,1) − (1,0,1,0) = (1, 1, 0, 1)`
- `Allocation[P2] = (0,1,1,0) + (1,0,1,0) = (1, 1, 2, 0)`
- `Need[P2] = (2,1,2,1) − (1,0,1,0) = (1, 1, 1, 1)`

**Safety test:** safe sequence **P0 → P2 → P1 → P3 → P4**.

| After completion of | Work |
|---------------------|------|
| Initially | (1, 1, 0, 1) |
| P0 | (2, 1, 1, 1) |
| P2 | (3, 2, 3, 1) |
| P1 | (4, 3, 3, 2) |
| P3 | (5, 3, 3, 3) |
| P4 | (5, 4, 3, 4) |

**Conclusion:** the request **can be granted immediately**.

### (d) P1 requests (0, 1, 0, 0)

**Preliminary checks:**

1. `Request ≤ Need[P1]`: `(0,1,0,0) ≤ (1,2,1,1)` ✔
2. `Request ≤ Available`: `(0,1,0,0) ≤ (2,1,1,1)` ✔

**Tentative state:**

- `Available = (2,1,1,1) − (0,1,0,0) = (2, 0, 1, 1)`
- `Allocation[P1] = (1,1,0,1) + (0,1,0,0) = (1, 2, 0, 1)`
- `Need[P1] = (1,2,1,1) − (0,1,0,0) = (1, 1, 1, 1)`

**Safety test (tentative state):**

With `Work = (2, 0, 1, 1)`:

- P0 can finish: `Need[P0] = (1,0,0,1) ≤ Work`.
- After P0: `Work = (2,0,1,1) + (1,0,1,0) = (3, 0, 2, 1)`.

Now every remaining process needs at least one instance of resource **B**, but `Work[B] = 0`:

- P1 needs `(1,1,1,1)` — needs B = 1
- P2 needs `(2,1,2,1)` — needs B = 1
- P3 needs `(0,1,1,2)` — needs B = 1
- P4 needs `(2,1,2,0)` — needs B = 1

No process can finish, so the tentative state is **unsafe**.

**Conclusion:** the request **cannot be granted immediately**. The tentative allocation is **rolled back**: `Available`, `Allocation[P1]`, and `Need[P1]` are restored to the original snapshot, and P1 must wait.
