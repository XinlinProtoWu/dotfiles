*Hierachy of storage:
- Registers
	- Costs 10s of Transistors
- Static RAM
	- Costs 6+ transistors
- Dynamic RAM
	- Only one transistor per bit
- SSD
- HDD
-  Etc.

*Finite State Machine:
- A discrete-time model of a stateful system
- each state represents a snapshot of the system at a given time

	5 elements:
	- Finite Number of States
	- Finite number of inputs
	- Finite number of outputs
	- Explicit spec of all state transitions
	- Explicit spec of what determines each external output

*Synchronous State Changes:* At the start of a clock cycle, state changes

*Rising Edge Triggered Flip Flop*
- Two inputs, CLK, D
- Function:
	- The flip flop samples D on the rising edge of CLK
	- when clk rises from 0-1, D passes to Q
	- Otherwise, Q holds the same value

*D Flip Flop Based Reg
- Multiple Parallel D flip-flops, each of which storing 1 bit
- All driven by the same clk

*Moore FSM:* Outputs depend only on the current state
*Mealy FSM:* Outputs depend on the current state and the inputs

*Reduce a Mealy into Moore:* Write truth table and write each output as a boolean expression of its states

*Delays*
- *Contamination Delay (t<sub>cd</sub> ):* Shortest path, delay until Y starts changing
- *Propagation Delay (t<sub>pd</sub>):*  Critical (longest) path, delay until Y finishes changing



