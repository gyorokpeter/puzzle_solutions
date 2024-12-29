# Breakdown

Example input:
```q
x:();
x,:enlist"Register A: 729";
x,:enlist"Register B: 0";
x,:enlist"Register C: 0";
x,:enlist"";
x,:enlist"Program: 0,1,5,4,3,0";
```

## Part 1
We represent the VM state as a dictionary with keys for the registers as well as `code`, `ip` and
`out`. 

The "read" operation occurs in multiple instructions so it's useful to extract it into a utility
function:
```q
.d17.read:{[state;param]
    if[param within 0 3;:param];
    if[param within 4 6;:state[`a`b`c param-4]];
    {'x}"unknown param ",string param;
    };
```
We also need a bitwise XOR function:
```q
bitxor:{0b sv (0b vs x)<>0b vs y};
```
The VM simulation happens in the `.d17.step` function. This takes the state as its parameter.

If the `ip` points past the end of the code, the function returns the state unmodified. This is to
make it easy to use with the `/` (over) iterator that keeps iterating until the input no longer
changes.
```q
    if[state[`ip]>=count state[`code];:state];
```
We extract the next instruction from the code and the opcode from the instruction:
```q
    instr:state[`code;0 1+state`ip];
    op:instr 0;
```
Next comes the implementation of the instructions, which are pretty boring:
```q
    $[op=0;
        state[`a]:state[`a]div `long$2 xexp .d17.read[state;instr 1];
      op=1;
        state[`b]:bitxor[state`b;instr 1];
      op=2;
        state[`b]:.d17.read[state;instr 1]mod 8;
      op=3;
        $[0=state`a;state[`ip]+:2;state[`ip]:instr 1];
      op=4;
        state[`b]:bitxor[state`b;state`c];
      op=5;
        state[`out],:.d17.read[state;instr 1]mod 8;
      op=6;
        state[`b]:state[`a]div `long$2 xexp .d17.read[state;instr 1];
      op=7;
        state[`c]:state[`a]div `long$2 xexp .d17.read[state;instr 1];
    {'x}"unknown instruction ",string instr 0];
```
We also update the instruction pointer if the instruction was not a jump. Note that the handler for
`op=3` takes care of updating `ip` even if it doesn't jump.
```q
    if[op<>3;state[`ip]+:2];
```
Another utility function is the parser.

We split the input into groups:
```q
q)a:"\n\n"vs"\n"sv x
q)a
"Register A: 729\nRegister B: 0\nRegister C: 0"
"Program: 0,1,5,4,3,0"
```
In the first group, we split on `": "`:
```q
q)b:": "vs/:"\n"vs a 0
q)b
"Register A" "729"
"Register B" ,"0"
"Register C" ,"0"
```
We parse the register values as integers and take the last character of the register name,
converting it to lowercase:
```q
q)"J"$b[;1]
729 0 0
q)lower last each" "vs/:b[;0]
,"a"
,"b"
,"c"
q)reg:(`$lower last each" "vs/:b[;0])!"J"$b[;1]
q)reg
a| 729
b| 0
c| 0
```
For the code, we take the last element after splitting on `": "`, then split on commas and parse as
integers. We don't generate a disassembly.
```q
q)code:"J"$","vs last": "vs a 1
q)code
0 1 5 4 3 0
```
We complete the state with the code, instruction pointer and empty output:
```q
0 1 5 4 3 0
q)reg,`code`ip`out!(code;0;`long$())
a   | 729
b   | 0
c   | 0
code| 0 1 5 4 3 0
ip  | 0
out | `long$()
```
With these helper functions in hand, we generate the starting state and iterate the step function
until it reaches the terminating state, pick out the output and join it with commas:
```q
q)","sv string .d17.step/[.d17.parse x][`out]
"4,6,3,5,6,3,5,2,1,0"
```

## Part 2
The following brute force implementation runs the VM with every integer until it gets the correct
output. It only works on the example input for part 2.
```q
x2:();
x2,:enlist"Register A: 2024";
x2,:enlist"Register B: 0";
x2,:enlist"Register C: 0";
x2,:enlist"";
x2,:enlist"Program: 0,3,5,4,3,0";

d17p2brute:{state:.d17.parse x;
    i:0;
    while[1b;
        if[0=i mod 1000;-1 string i];
        state[`a]:i;
        state2:{[s]s2:.d17.step s;if[not s2[`out]~count[s2`out]#s2`code;:s];s2}/[state];
        if[state2[`out]~state`code;:i];
        i+:1;
    ]};

q)d17p2brute x2
117440
```

# Whiteboxing
This applies to the real inputs to part 2. From looking at a few inputs, the program seems to have a
similar structure. It fetches 3 bits at the time from the integer input (register A). It first does
an XOR with a mask and fetches another 3 bits at an offset based on the result of the XOR. Then it
XORs the new bits into the result of the previous XOR, and also XORs with a second mask. The result
of this is printed out. There is some variance in the ordering of the instructions, the dummy
parameter to the `bxc` instruction, and most importantly the two masks used for the XOR operations.
The operations are not directly invertible but we can try all possible combinations of bits and keep
track of the constraints that this puts on the more significant bits. After going through the code,
we should keep checking the constraints as if a constant stream of zeroes was still coming in, to
make sure there is no extra garbage printed after the actual code.

Because this requires the real input, there is no demonstration.

We start by parsing the input as with the regular solution:
```q
    state:.d17.parse x;
```
We generate the goal by splitting the code into boolean lists, taking the last 3 elements of each
number, and concatenating the results:
```q
    goal:(raze -3#/:0b vs/:state`code);
```
We find the important operations, which are the XORs holding the masks, having the opcode 1:
```q
    mainOps:{x where 1=first each x}2 cut state`code;
```
We convert the two masks into length 3 boolean lists:
```q
    shiftMask:-3#0b vs mainOps[0;1];
    outMask:-3#0b vs mainOps[1;1];
```
We initialize the queue with a single node containig an empty sequence and an empty constraint list:
```q
    nodes:enlist`seq`constr!(();());
```
We initialize the position counter to 0:
```q
    pos:0;
```
We iterate until the position runs past 9 plus the end of the code. This is necessary to ensure no
garbage is printed after the program consumes the real input bits - the constraints must be matched
assuming that the code is padded with some zeroes.
```q
    while[pos<9+count goal;
        ...
        pos+:3;
    ];
```
Within the iteration, we start by extending each node with either all the possible bit combinations
from 0 to 7, or all zeroes if we are past the end of the code:
```q
    nodes:$[pos>=count goal;
        update seq:(000b,/:seq) from nodes;
        raze{update seq:((-3#/:0b vs/:til 8),'seq)from 8#enlist x}each nodes
    ];
```
If we are still within the code, we add new constraints:
```q
    if[pos<count goal;
        ...
    ];
```
We add a column to the nodes that contains the last 3 bits XORed with the shift mask (`<>` is the
boolean XOR in q):
```q
    nodes:update b1:(3#/:seq)<>\:shiftMask from nodes;;
```
We add another column that contains the result of XORing the first XOR result with the output mask:
```q
    nodes:update b2:b1<>\:outMask from nodes;
```
We add another column with the offset caluclated by combining the current position with the one
calculated from the first XOR:
```q
    nodes:update offset:pos+2 sv/:b1 from nodes;
```
We add another column with the expected values, by XORing the second value with the bits from the
goal:
```q
    nodes:update ex:b2<>\:goal pos+til 3 from nodes;
```
We update the constraint lists by adding a constraint with the calculated offsets and expected
values:
```q
    nodes:update constr:(constr,'enlist each (offset(;)'ex)) from nodes;
```
This ends the constraint update section.

Whether we are still inside the code or not, we check if the constraints still hold. We add a new
column containing the constraints whose offset is less than the current position, meaning we have
all the necessary bits to check them:
```q
    nodes:update toMatch:constr@'where each constr[;;0]<=pos from nodes;
```
We add another column with the extracted the bits to be matched from the sequence:
```q
    nodes:update matchVal:-3#/:/:(neg toMatch[;;0])_\:'seq from nodes;
```
We filter the list to remove the nodes that don't match the constraints:
```q
    nodes:select from nodes where all each matchVal~''toMatch[;;1];
```
Finally we drop all the extra columns and only keep the sequences and constraionts:
```q
    nodes:select seq, constr from nodes
```
This is the end of the iteration.

After the iteration, the `nodes` list will have a couple of different solutions remaining. However
the puzzle makes it clear that the solution is the smallest one, so we convert back the sequences
into integers with `2 sv` and keep the minimal one:
```q
    exec min 2 sv/:seq from nodes
```
