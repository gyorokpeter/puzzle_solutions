# Utilities

## GenArch

GenArch stands for Generic Architecture. I came up with the idea after Advent of Code 2019, which heavily featured the Intcode interpreter. Originally I made a debugger for Intcode specifically, but knowing that future AoC seasons will probably feature more VM-based challenges, I took the time to extract the arch-independent functionality and made the actual VM logic pluggable.

Debugger features:
* Disassembly
* Single-step and breakpoints
* Memory/register editing
* Blame highlight: inputs and outputs to the current instruction are highlighted in the memory or register view. If the current instruction is a jump, the target is highlighted in the disassembly including whether the jump is taken or not.
* Trace: records the VM state after every instruction, allowing forward and backward navigation, essentially "running backwards".
* Lineage: after recording a trace, follows the origins of a data value, listing which instruction calculated it and how, as far as possible.
* Memory and output history listing

To use, load an arch definition and navigate to /genarch on the HTTP interface.

An arch consists of functions in a given namespace (e.g. ```.intcode```) and is registered by calling .genarch.register with the bare namespace name (e.g. ```.genarch.register`intcode```).

An assortment of functions must exist in the namespace to make it a valid arch. The most important ones are:
* ```new[src]```: create an initial state from source code. This will typically parse the code and set the instruction pointer, registers, memory etc. to zero or empty as appropriate. The result is a state object that can be passed into the other functions.
* ```runD[st;d;bp;step]```: runs the VM. ```st``` is the state to start from. ```d``` is a boolean telling whether the next two arguments should be observed or not. ```bp``` is the list of breakpoints. ```step``` is a boolean telling whether single-step execution is on. The function should keep running the code until a breaking condition occurs. A breaking condition could be executing a halt instruction, running off the end of the program, or executing an input instruction with an empty input queue. Due to performance reasons, some of the debugging functionality needs to be in this function - initially I intended this to always do a single-step such that GenArch could take care of all the debugging stuff like breakpoints and single-step, however this turned out to be very slow, even a / iterator with the single-step function as its body and the isTerminated check as its condition would result in doubled runtime. So the d parameter enables debug mode, and in this mode, runD should also stop if hitting a breakpoint, or after any instruction if step mode is also on. Even the check for the value of ```d``` carries a minuscule performance penalty, which is visible with unoptimized Assembunny. However I accepted this as a compromise.
* ```run[st]```: a shortcut for running in non-debug mode, the simplest version is equivalent to ```runD[st;0b;();0b]```.
* ```disasmOne[st;ip;hints]```: disassemble a single instruction. ```st``` is the state and ```ip``` is the address to disassemble. ```hints``` is a dictionary that may contain: ```cutPoints``` that indicate where the disassembly must be cut (this ensures that e.g. the instruction pointer is not in the middle of a multi-address instruction), and ```memLabels```, a mapping from memory addresses to their labels. The function must return ```((ip;machineCode;opcode;args);nextIp)```.
* ```analyzeEffects[st]```: analyze the effects of the current instruction. It must return a dictionary which can have the following keys:
 * ```effInstr```: the actual instruction, e.g. this could have the register names or memory addresses replaced by their contents, inputs and outputs separated (e.g. an INC A could be INC 5 => A).
 * ```memRead```: the list of input operands (not just memory): a long is a memory address, a symbol in the form `r.a is a register, and `i.X.Y is the Y-th (1-based) immediate operand of the instruction at ip=X.
 * ```memWrite```: the list of output operands like above. These two are used by the lineage checker.
 * ```jumpTarget```: if the current instruction is a jump, this should be the absolute jump target address.
 * ```jumpTaken```: if the current instruction is a jump, this should a boolean indicating whether the jump is taken.

Boring functions - these are needed for the debugger to work, but they are often very simple, they are needed because their effects can be arch-dependent:

* ```resume[st]```: should set the state into the "running" mode, this is called before runD
* ```isRunning[st]```: should return whether the state is "running". Currently only used once in the trace function, I may remove it later.
* ```isTerminated[st]```: should return whether the state is terminated. Mainly used for disabling the continue/next/... GUI elements, and is also a stop condition for trace.
* ```needsInput[st]```: should return whether the state is stopped due to an input instruction being executed with no input in the input queue. A stop condition for trace.
* ```getIp[st]```: should return the instruction pointer.
* ```getRegisters[st]```: should return the registers either as a list or a dictionary. (can be empty if the arch doesn't have any registers)
* ```getImmediate[st;ip;slot]```: get an immediate value, this will be called by the lineage tracer using the ip and slot values taken from the i.X.Y elements returned in the memRead/memWrite hints
* ```getStackPointer[st]```: should return he stack pointer or 0N if not applicable. The element under the stack pointer is highlighted in bold in the memory view.
* ```getInput[st]```: should return the input queue, either as longs or chars. :: if none.
* ```addInput[st;input]```: should append the given input to the input queue. The input is always given as a string - the arch is responsible for parsing it.
* ```getOutput[st]```: should return the output queue, either as longs or chars. :: if none.
* ```clearOutput[st]```: should clear the output queue.
* ```getStack[st]```: should return the stack, or (::) if none. This has nothing to do with the stack pointer, which should be used if the stack is in main memory instead.
* ```getMemory[st]```: should return the memory, or () if none.
* ```ipValid[st;ip]```: should return whether the instruction pointer is valid (e.g. it's within the bounds of the program).
* ```editMemory[st;addr;val]```: should update the memory at address ```addr``` to value ```val```.
* ```editRegister[st;r;v]```: should update the register with name/index ```r``` to value ```v```.
Editing functions should return the modified state after applying the edit operation. It is OK to throw an exception if the thing they are supposed to edit (input, output, registers, memory) doesn't exist in the arch.

For the list of archs implemented, see test/genarchLoadAll.q which loads all the arch files.
