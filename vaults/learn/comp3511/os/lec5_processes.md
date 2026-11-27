## Four Fundamental OS Concepts

- #### Process
	- An instance of an executing program is a *process* - consists of an *address space* and one or more *threads* of control
- #### Thread
	- A single unique executing context; Describes program state - captured by *program counter*, *registers*, *exectuion flags*, and *stacks*
- #### Address Space
	- A program executes in its own *address space* that is distinct from the address space of another program and different from memory allocated for this *process* - logical/virtual address.
- #### Dual Mode Operation
	- User programs and OS (kernel) programs run in different modes
	- Only the operating system is allowed to access certain resources
	- The OS and the hardware are protected from user programs
	- User programs are protected and isolated from one another

---
## Process:

- Each execution of a program is called a *process*
- Process execution progress in a *sequential* manner - von Neumann architecture
- Process contains:
	- Program code (*text section*)
	- Current activities or state (*program counter*)
	- *Stack:* temporary data such as function parameters, return addresses, and local variables
	- *Data Section:* Contains global variables
	- *Heap:* containing dynamically allocated memory during run time
- *Program* vs *Process*:
	- Program: *passive* entity stored on the disk (executable)
	- Process: *active* entity with a program counter specifying the next instruction to fetch, as well as a set of associated resources including address space.
- A process has a life cycle, from program execution to termination

### Program to Process:

- When a program is loaded into main memory, it becomes a process.
- Program executes in an *address space*
![[Chapter3.pdf#page=6&selection=15,30,15,34|Chapter3, page 6]]
 
- One program can have multiple *processes*
- A process can be an execution environment for other programs.

### Program into Memory
- Load code and data into memory **or** into the address space of the process
- Memory allocated for the program's *runtime stack*.
- OS may allocate memory for the program's *heap* and free it after use.
- OS will also do other initialization tasks necessary, for example on UNIX the default three are *input*, *output*, and *error*.
![[Chapter3.pdf#page=8&selection=15,0,15,3|Chapter3, page 8]]

### Process States:

1. *New:* Process being created
2. *Ready:* Waiting to be assigned to a CPU core
3. *Running:* Instructions being fetched and executed
4. *Waiting:* Waiting for some events to occur
5. *Terminated:* Finishes execution and deallocates resources
![[Chapter3.pdf#page=9&selection=58,0,58,10|Chapter3, page 9]]

### Process Control Block

- *Process State*
- *Program Counter:* location of instruction to be fetched next
- *CPU registers:* accumulators, index registers, stack pointers, and general purpose registers + any condition-code information
- *CPU scheduling information:* priorities, pointers to scheduling queue, scheduling params
- *Memory management information:* Memory allocated to the process
- *Accounting information:* CPU used, clock time elapsed since start, time limits
- *I/O status information:* I/O devices allocated to process

### Thread

- An entity within a process, is the smallest unit of execution that the CPU and schedule independently
- Shares *address space* with its parent process. Each thread has its own *state*
![[Chapter3.pdf#page=12&selection=11,0,11,6|Chapter3, page 12]]
### Process Representation in Linux:
- Linux Kernel stores list of processes in a circular doubly linked list (*tasklist*). Each element is of type struct *task_struct*

---
## Process Scheduling:

*Main goal:* Always have something running so the CPU power is not wasted.

- *Process scheduler:* A mechanism that selects a process for execution on one CPU core
- For a system with **1** CPU core, there will never be multiple process/thread running on the CPU at once
- *Degree of multiprogramming:* The number of processes currently in memory, determines *resource consumption*
- Process categories:
	- *I/O-bound process:* Deals with I/O way more than computation, requires *short* but many CPU bursts.
	- *CPU-bound process:* Deals more with computations, few *long* CPU bursts

### Scheduling Queues:

- *Ready queue:* list of processes ready and waiting to be executed
- *Wait queue:* list of processes waiting for an event
![[Chapter3.pdf#page=16&selection=15,2,15,8|Chapter3, page 16]]

### Long vs Short-term Schedulers:

- *Long-term (job) scheduler:* 
	- Assigns processes from *disk* to *memory*
	- Does not exist on personal computers because consumers just want processes to instantly start
	- Dictates the *degree of multi-programming*
	- Strives to achieve a good mix of I/O-bound and CPU-bound processes
- *Short-term (CPU) scheduler:*
	- Selects a process from the ready queue to be executed next and allocates it a *CPU* core.
	- Invoked in *milliseconds* unlike long-term schedulers (minutes, seconds)

#### The Middle Child: Medium Term Scheduler

- Added when degree of multi-programming is to be reduced.
- Removes a process from memory to the disk temporarily (*Swap space*)

---
## Context Switch:
- When *context switch* occurs when CPU switches from one process to another
![[Chapter3.pdf#page=19&selection=17,0,17,7|Chapter3, page 19]]

- OS must *save the state* of the old process and load the *saved state* from another process via a *context switch*
- *Context:* Registers, program counter, and stack pointer
- *Context-switch time is an OVERHEAD:* meaning the CPU does no work during it
---
## I/O

- Each *Device controller* is responsible for a particular device
- Each device controller has a local buffer
	- Moves data between peripherals and local buffer storage
	- So are *I/O operations*
- CPU moves data from/to main memory to/from local buffers, typically for slow devices such as keyboard and mouse.
- *Interrupts:* Informs operation completion

### Direct Memory Access

- *Programmed IO:* Is when CPU does dumb things to move data from slow devices, like loop polling, stops them from doing useful things with their speed.
- To avoid programmed I/O, direct memory access controller is used, bypasses the CPU to transfer data between I/O device and memory.
- *DMA* dumps one block at a time

Steps of a DMA:
1. Device driver is told to transfer disk data to buffer
2. Device driver tells disk controller to transfer bytes from disk to buffer
3. Disk controller initiates DMA transfer
4. Disk controller sends each byte to DMA controller
5. DMA controller transfers bytes to buffer, increasing memory address and decreasing until bytes become 0
6. When byte hits 0, DMA interrupts CPU to signal transfer completion

---
## Dual Mode Opps:

- Has *User mode* and *Kernel mode* to protect the user programs from doing stupid shit
- Has a *MODE BIT* to indicate what mode
- Some *privileged* instructions are only executed in the kernel mode
- *TRAP:* if user tries to to use privileged instruction, this state will be thrown
- *Virtual Machine Manager (VMM):* is in control of the system when a virtualization is happening
	- Much like a process switch, a *Machine switch* must be done for a virtualization, so all stuffs has to be saved
