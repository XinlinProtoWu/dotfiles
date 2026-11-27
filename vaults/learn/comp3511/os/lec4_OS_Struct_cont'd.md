## Monolithic Structure:
![[Chapter2.pdf#page=40&selection=17,0,17,2|Chapter2, page 40]]
- *Kernel* here contains everything between system-call interface and above hardware
- *Monolithic Structure:* Places all functionality of the kernel into a single static binary file that runs in a single address space
*Cons:
- Everything is mushed into one. Difficult to debug.
*Pros:*
- Performance advantage due to little overhead in the system-call interface.

## Linux:
![[Chapter2.pdf#page=42&selection=13,0,13,3|Chapter2, page 42]]
- *Monolithic* in that it also runs in kernel mode in one address space
- Applications use *glibc* library to communicate with system call interface to the kernel

## Layered Approach:
- Divides on OS into layers, each built on top of lower layers. Layer 0 being the hardware, and layer N being user interface
- Each layer consists of data structures and functions that can be triggered by *higher levels*

### Abstraction:
- Lower levels hide details from higher levels, acting as a *black box*, providing *output* when given *input*
- Great for *simplicity*, could *negatively impact* performance due to a greater overhead

## Microkernel:
- Remove *non-essentials* from the kernel and implement them as system or user-level *programs* in *separate address space*
- Provides minimal *process* and *memory management*, in addition to a *communication facility*
>[!NOTE] ### Communication Facility:
>- Provides communication between programs and various services running in *user address space* through *message passing*
>- ![[Chapter2.pdf#page=47&selection=13,0,13,3|Chapter2, page 47]]

*Pro:*
- Expandability as services can be added *without* touching the kernel
- Much smaller kernel for ease of modification
- Ease of *Adaptability* to new hardware
- Less code running on kernel leads to higher *reliability* and *security*
*Cons:*
- Worse performance due to greater overhead and user space and kernel space comms.
- Comms between two user-level services must happen through copying from one address space to another

## Modular Approach:
Modern OS use *loadable kernel modules (LKMs)*
>[!NOTE] LKM
>- Kernel has a set of core components
>- Additional services linked via modules, either at boot time or during runtime
>- Have a *core* component, with other additional services implemented and added *dynamically* while the kernel is running
>	- No requirement of recompilation when additional content is simply linked.
>- LKMs are typically *device drivers* and *file systems*.

### Solaris Approach:
![[Chapter2.pdf#page=51&selection=11,0,11,7|Chapter2, page 51]]

