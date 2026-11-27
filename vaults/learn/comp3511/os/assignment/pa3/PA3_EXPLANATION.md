# PA3: Simplified Memory Management — Walkthrough

This document explains the data layout and the logic behind each of the three
functions you must implement (`mm_malloc`, `mm_free`, `mm_combine_nearby_free`),
so you can rewrite them yourself.

---

## 1. The big picture

We are building a *user-level* heap on top of `mmap`. The OS gives us one big
chunk of memory (`HEAP_SIZE = 8000` bytes). Inside that chunk we place our own
blocks. Each block is:

```
+-----------------+  <-- high addresses (top of heap)
|     data        |   md->size bytes  (the user's memory)
+-----------------+
|    MetaData     |   9 bytes
+-----------------+  <-- block start (low addresses)
```

The heap grows *upward*, so **Block 1 is at the lowest address (`heap_start`)**
and newer blocks are placed at higher addresses.

### MetaData (9 bytes, packed)

```c
struct __attribute__((__packed__)) MetaData {
    size_t size;   // 8 bytes: size of the DATA region only (not counting MetaData)
    char   status; // 1 byte: 'f' = FREE, 'o' = OCCUPIED
};
const size_t meta_data_size = sizeof(struct MetaData); // exactly 9
```

`__packed__` stops gcc from inserting padding, so the struct is **exactly 9 bytes**.

Key facts used everywhere:

- A block's **MetaData lives at `block_start`**.
- A block's **data lives at `block_start + 9`**.
- The **next block starts at `block_start + 9 + md->size`** (MetaData + data).
- `mm_sbrk(0)` returns `heap_current_break`, i.e. the end of all blocks.
- `mm_sbrk(n)` (n > 0) moves the break up by `n` bytes and returns the **old**
  break (the address of the first byte of the new region).

### Traversing the heap (the universal loop)

Every function walks the heap the same way:

```c
void *cur = heap_start;
void *break_point = mm_sbrk(0);
while (cur < break_point) {
    struct MetaData *md = (struct MetaData *)cur;
    // ... inspect/act on md ...
    cur += meta_data_size + md->size;   // move to the next block
}
```

---

## 2. `mm_malloc(size_t size)`

Goal: return a pointer to the **data** region of a block that can hold `size`
bytes. Strategy: **first-fit**, then grow the heap if needed.

### Step A — scan for a first-fit free block

Walk the heap. For each block, if it is `FREE` **and** `md->size >= size`, we
have a candidate. There are two sub-cases.

#### Sub-case 1: the block is big enough to split

Condition:

```c
md->size >= size + meta_data_size + 1
```

Why `+ meta_data_size + 1`? After carving out our requested block, the leftover
must itself be a valid block: it needs its **own MetaData (9 bytes)** plus **at
least 1 byte of data**. If the leftover would be 0 data bytes, we must NOT split
(the PDF explicitly warns about this "zero-size memory" case).

If we can split:

```c
size_t residual_size = md->size - size - meta_data_size;

md->size   = size;            // the lower part becomes our occupied block
md->status = STATUS_OCCUPIED;

struct MetaData *residual = (struct MetaData *)(cur + meta_data_size + size);
residual->size   = residual_size;   // upper part stays free
residual->status = STATUS_FREE;
```

Picture (block had 300 bytes, request 291 — can't split; but request 200 — can):

```
Before (FREE 300):                After split for malloc 200:
+------+--------------------+     +------+----------+------+------------+
| md:9 |   data 300         |     | md:9 | data 200 | md:9 | data 82    |
+------+--------------------+     +------+----------+------+------------+
                                   OCCUPIED          FREE residual
```

#### Sub-case 2: the block is NOT big enough to split

If `md->size >= size` but `md->size < size + 9 + 1`, just take the **whole**
block as-is (internal fragmentation is allowed):

```c
md->status = STATUS_OCCUPIED;
```

Either way, return the **data address** (not the MetaData address):

```c
return cur + meta_data_size;
```

### Step B — no reusable block: grow the heap

If the loop finishes without finding a suitable free block, allocate fresh space:

```c
void *new_block = mm_sbrk(meta_data_size + size);
if (new_block == MAP_FAILED) return NULL;

struct MetaData *md = (struct MetaData *)new_block;
md->size   = size;
md->status = STATUS_OCCUPIED;
return new_block + meta_data_size;
```

`mm_sbrk(9 + size)` moves the break up and returns the old break, which is
exactly where the new block's MetaData starts.

---

## 3. `mm_free(void *p)`

Goal: mark the block that owns data address `p` as FREE. We do **not** shrink the
heap (no negative `mm_sbrk`).

Walk the heap and find the block whose **data region starts exactly at `p`**:

```c
if (cur + meta_data_size == p) {
    md->status = STATUS_FREE;
    return;
}
```

That is the whole function. (You could also compute it directly as
`(struct MetaData *)(p - 9)`, but iterating matches the assignment's described
algorithm and is safer.)

---

## 4. `mm_combine_nearby_free()`

Goal: merge every run of consecutive FREE blocks into one bigger FREE block.

### The merge rule

When block A (FREE) absorbs the immediately following block B (FREE):

```
A->size += meta_data_size + B->size;
```

Why? B's 9-byte MetaData and B's data both become part of A's data now. So A
grows by exactly `9 + B->size`.

### Algorithm

Walk the heap once:

```c
void *cur = heap_start;
void *break_point = mm_sbrk(0);

while (cur < break_point) {
    struct MetaData *md = (struct MetaData *)cur;

    if (md->status == STATUS_FREE) {
        // address of the block immediately after the current merged block
        void *next = cur + meta_data_size + md->size;

        while (next < break_point) {
            struct MetaData *next_md = (struct MetaData *)next;
            if (next_md->status != STATUS_FREE)
                break;                       // stop at first non-free block

            md->size += meta_data_size + next_md->size; // absorb next_md
            next = cur + meta_data_size + md->size;     // recompute next
        }

        cur = next;   // jump past the whole merged run
    } else {
        cur += meta_data_size + md->size;    // occupied: just move on
    }
}
```

Note the two important details:

1. After merging, we **recompute `next`** from the enlarged `md->size`, so a run
   of 3+ free blocks all get merged in one inner loop.
2. `cur = next` skips the entire merged run, because the absorbed blocks no
   longer exist as separate blocks — their memory is now part of `md`'s data.

### Worked example (given1 final state)

Before combining:

```
B1 FREE 300 | B2 FREE 200 | B3 OCCP 100 | B4 FREE 50 | B5 FREE 314
```

- B1 absorbs B2: `300 + 9 + 200 = 509`. Next is B3 (occupied) → stop.
- B3 is occupied → skip.
- B4 absorbs B5: `50 + 9 + 314 = 373`.

After:

```
B1 FREE 509 | B3 OCCP 100 | B4 FREE 373
```

That matches `out_given1.txt`.

---

## 5. Quick checklist to redo it manually

1. **MetaData** = 9 bytes = 8 (`size_t size`) + 1 (`char status`).
2. **data address** = `block + 9`. **next block** = `block + 9 + size`.
3. `mm_malloc`: first-fit scan → split if `md->size >= size + 10`; else occupy
   whole block; else `mm_sbrk(9 + size)` for a new block. Return data address.
4. `mm_free`: scan for block whose data address == `p`, set status `'f'`.
5. `mm_combine_nearby_free`: scan; for each FREE block keep absorbing the next
   FREE block with `md->size += 9 + next->size`.

## 6. How to compile & test

```bash
gcc -std=c99 -o smm smm.c
./smm < testcase_given/given1.txt > /tmp/out1.txt
diff /tmp/out1.txt testcase_given/out_given1.txt    # no output = identical
```
