# Breakdown
This is a straightforward simulation, much less complex than the VMs from previous years.

Example input:
```q
x:"\n"vs"nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6"
```

## Common

### Input parsing
We break the inpur lines on spaces:
```q
q)a:" "vs/:x
q)a
"nop" "+0"
"acc" "+1"
"jmp" "+4"
"acc" "+3"
"jmp" "-3"
"acc" "-99"
"acc" "+1"
"jmp" "-4"
"acc" "+6"
```
We cast the first elements to symbols and the second ones to integers. Luckily this ignores the plus
signs.
```q
q)ins:"SJ"$/:a
q)ins
`nop 0
`acc 1
`jmp 4
`acc 3
`jmp -3
`acc -99
`acc 1
`jmp -4
`acc 6
```

### Simulation
We start with a state:
```q
q)state:`acc`ip`visited`term`fail!(0;0;count[ins]#0b;0b;0b)
q)state
acc    | 0
ip     | 0
visited| 000000000b
term   | 0b
fail   | 0b
```
The state contains the accumulator, instruction pointer, an indicator for each position whether that
line was visited, a termination flag and a failure flag. It can also contain an optional
`changedIns` element that is the index of the changed instruction for part 2.

The function `d8step` will take the instruction list and state, and return the updated state.

The first step is to check for termination. If the instruction pointer is equal to the instruction
count, we set the termination flag and return the state.
```q
    if[state[`ip]=count ins; state[`term]:1b; :state];
```
We then check if the instruction pointer points inside the code, and return a failed state if not:
```q
    if[not state[`ip] within 0,count[ins]-1; fail:1b; :state];
```
We update the visited flag for the current instruction:
```q
    state[`visited;state`ip]:1b;
```
We fetch the current instruction based on the instruction pointer:
```q
    ci:ins[state`ip];
```
We check if the `changedIns` element is present and if it's equal to the instruction pointer. If so,
we update the fetched instruction by mapping via a dictionary. We don't modify the original
instruction list. If an `acc` instruction is changed, we replace it with an invalid instriction
(`changedAcc`).
```q
    if[`changedIns in key state;if[state[`changedIns]=state[`ip];
        ci[0]:(`nop`jmp`acc!`jmp`nop`changedAcc)ci[0];
    ]];
```
Next we do the actual simulation of the instruction using a multi-way conditional.

If the instruction is a NOP, we simply update the instruction pointer:
```q
    $[ci[0]=`nop; state[`ip]+:1;
```
If it's an `acc` instruction, we update the accumulator and also increment the instruction pointer:
```q
      ci[0]=`acc; [state[`acc]+:ci[1]; state[`ip]+:1];
```
If it's a `jmp` instruction, we update the instruction pointer based on the parameter of the
instruction:
```q
      ci[0]=`jmp; state[`ip]+:ci 1;
```
Otherwise we have an invalid instruction (this is intended in case of the `changedAcc` instruction,
but could happen due to a bug), so we set the failure flag to true.
```q
    state[`fail]:1b];
```
The return value of the function is the updated `state`.
```q
    state
```

## Part 1
We parse the input and initialize the state as before:
```q
q)ins:d8in x
q)state:`acc`ip`visited`term`fail!(0;0;count[ins]#0b;0b;0b)
```
We do a straightforward simulation using a `while` loop, checking if the current instruction is
visited:
```q
    while[not state[`visited][state`ip];
        state:d8step[ins;state];
    ];
```
The answer is the accumulator in the final state:
```q
q)state`acc
5
```

## Part 2
We run multiple simulations in parallel, in the style of a BFS. We parse an input and initialize a
queue with a single state, this time including the `changedIns` element, initialized to null. The
null indicates that we haven't determined which instruction to change yet.
```q
    ins:d8in x;
    queue:enlist `acc`ip`visited`term`fail`changedIns!(0;0;count[ins]#0b;0b;0b;0N);
```
We run the simulations in a `while` loop. Items will drop out of the queue if they reach a fail
state. If we ever reach a state where there are no items in the queue, that is a bug so we throw an
error.
```q
    while[0<count queue;
        ...
    ];
    '"no solution found";

```
The following is the body of the loop.

We delete any states from the queue that have the fail flag set or the instruction pointer points to
an already visited instruction:
```q
    queue:delete from queue where (visited@'ip) or fail;
```
We duplicate the state with the null `changedIns` and in the copy we set `changedIns` to the current
instruction:
```q
        queue,:update changedIns:ip from select from queue where null changedIns;
```
We execute one step for each state in the queue:
```q
        queue:d8step[ins] each queue;
```
We check if there are any success states based on the `term` flag:
```q
        succ:select from queue where term;
```
If there are any, we return the accumulator of the first success state (there should never be more
than one).
```q
        if[0<count succ; :exec first acc from succ];
```

```q
q)exec first acc from succ
8
```
