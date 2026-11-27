*Application Program Interface*
- Specifies a set of functions, including the params passed ot the functoin and return values it may expect
- Each system call has a specific ID
	- Catches function calls in API
	- Invokes necessary system call within OS
	- Returns status and return values, if any

*Methods of passing params:*
- Pass into *Registers*
- Pass as block in *Memory*, specify address of block in a reg
- Params placed onto the *Stack* and popped by the OS


## Architecture Vocab:
- *NUMA:* Non-uniform Memory Access
- *UMA:* Uniform Memory Access
- *SMP:* Symmetric Multi Processing. Runs with multiple processors connected to a main memory. Though, each processor has their own registers and local cache.

---

## Caches:

### Hit time formula:

**${}T_{avg} = H_{ratio} \cdot T_{hit} + M_{ratio}\cdot T_{miss}{}$**

### Temporal Locality: duh, what gets used will prob get used again

### Spatial Locality: Duhhhh, the things beside the thing getting used is probably going to be used soon

