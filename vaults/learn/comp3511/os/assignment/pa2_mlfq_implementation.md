# PA2 MLFQ — Implementation Notes

## Files

- `pa2/skeleton_code.c` — original skeleton, completed in place.
- `pa2/mlfq.c` — submission copy of the completed program.
- `pa2/__MACOSX`, `pa2/pa2_given_io` — provided materials, unchanged.

The parser and printing helpers from the skeleton were kept unchanged. Only the
body of `mlfq()` was implemented.

## What was implemented in `mlfq()`

### Data structures

Inside `mlfq()`:

- `queues[MAX_NUM_QUEUE][UPPER_BOUND_NUM_PROCESS]` — each of the N queues is a
  simple FIFO array. Queue `q` holds process indices in
  `queues[q][queue_head[q] .. queue_tail[q]-1]`.
- `queue_head[]`, `queue_tail[]` — head/tail indices for each queue.
- `slice_left[]` — remaining time slice of each process in its current queue.
- `process_table[i].remain_time` — remaining CPU burst of process `i`.

### Initialization

- Every queue starts empty (`head = tail = 0`).
- Every process has `remain_time = burst_time` and `slice_left = 0`.

### Main scheduling loop

The loop repeats until all processes finish:

1. **Admit arrivals**
   - All processes whose `arrival_time <= current_time` are admitted.
   - They are appended to queue 0 (highest priority).
   - Their `slice_left` is set to `time_quantum[0]`.

2. **Pick the highest-priority non-empty queue**
   - Queues are scanned from index `0` upward, so queue 0 has the highest
     priority and the last queue (FCFS) has the lowest priority.

3. **Run the process at the front of the selected queue**
   - The run length is initially the process's `remain_time`.
   - If the queue is not the last queue, the run length is capped by the
     process's remaining time slice.
   - If the queue is not queue 0 and another process will arrive later, the
     run length is capped so the CPU stops exactly at that next arrival time
     (new arrivals preempt lower-priority queues).
   - Queue 0 is never preempted by a new arrival; new arrivals simply wait at
     the back of queue 0.

4. **Record the Gantt chart interval**
   - The interval `(process_name, run_length)` is appended to the chart.
   - If the previous chart item is the same process, the two intervals are
     merged into one (the CPU ran that process continuously).

5. **Update state**
   - `current_time += run`
   - `remain_time -= run`
   - For non-last queues, `slice_left -= run`

6. **Handle completion / demotion / preemption**
   - If `remain_time == 0`: the process finishes and is removed from its queue.
   - Else if the queue is not the last queue and `slice_left == 0`: the process
     used its full time slice, so it is removed from the current queue and
     appended to the next lower queue with a fresh
     `slice_left = time_quantum[next_queue]`.
   - Otherwise: the process was preempted by a new arrival. It stays at the
     front of its current queue and keeps its partially used time slice.

### Queue-specific behavior

- **Queue 0 .. N-2**: round-robin with time quantum `time_quantum[q]`.
  A full time slice demotes the process to queue `q+1`.
- **Queue N-1**: FCFS. Its quantum (`1000` in the inputs) is treated as
  effectively infinite, so a process runs until completion unless it is
  preempted by a later arrival in a higher-priority queue.
- **Preemption**: only a queue-0 arrival can preempt a process running in
  queue `q > 0`. The preempted process remains at the front of its queue and
  does not lose the partially consumed time slice.
- **Consecutive same-name Gantt intervals are merged**, which matches the
  expected output for cases such as `in05.txt` where a process continues after
  being demoted without any other process running in between.

## Verification

The program was compiled with:

```sh
gcc -std=c99 -o mlfq mlfq.c
```

All provided test cases pass exactly (`diff` reports no differences):

```text
in01.txt  OK
in02.txt  OK
in03.txt  OK
in04.txt  OK
in05.txt  OK
in06.txt  OK
in07.txt  OK
in08.txt  OK
```

In addition, the implementation was compared against an independent
unit-by-unit reference simulator on 2000 randomly generated valid inputs and
produced identical Gantt charts for all of them.
