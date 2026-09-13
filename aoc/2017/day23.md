# Breakdown
Example input:
```q
q)md5 "\n"sv x
0xb25f25ae722a6246869ddfb06f300ea4
```

## Part 1
The VM implementation is in [arch1.q](arch1.q), and uses [GenArch](../utils/README.md#genarch). Only
the important functions are explained.

### .arch1.new
This function creates a new VM state from the input.
```q
q)inp:(trim x except\:"\r")except enlist""
q)inp
"set b 79"
"set c b"
"jnz a 2"
"jnz 1 5"
"mul b 100"
..
```
We create the commands by splitting each input line on spaces and converting only the first element
to symbol:
```q
q)cmds:{a:" "vs x;(`$a[0]),1_a}each inp
q)cmds
`set ,"b" "79"
`set ,"c" ,"b"
`jnz ,"a" ,"2"
`jnz ,"1" ,"5"
`mul ,"b" "100"
..
```
We find the registers in use by looking only at the parameters and checking which ones start with a
small letter:
```q
q)regs:{x!count[x]#0}asc distinct`$/:{x where x within "az"}first each first each raze 1_/:cmds
q)regs
a| 0
b| 0
c| 0
d| 0
e| 0
f| 0
g| 0
h| 0
```
We pack the initial state into a list. There is no input and output, but there is a separate field
for the count of `mul` instructions executed.
```q
q)(`run;0;cmds;regs;0)
`run
0
((`set;,"b";"79");(`set;,"c";,"b");(`jnz;,"a";,"2");(`jnz;,"1";,"5");(`mul;,"b";"100");(`sub;,"b";..
`s#`a`b`c`d`e`f`g`h!0 0 0 0 0 0 0 0
0
```

## .arch1.getVal
This function is responsible for value lookup. The value is passed in as a string. If it is a
number, the number is returned. Otherwise we assume it's a register so we return the corresponding
register value.
```q
    .arch1.getVal:{[reg;val]$[null v:"J"$val;reg[`$val];v]};
```

## .arch1.runD
This function contains the core VM logic. The extra parameters are to support debugging in the
GenArch web UI.

We extract the instruction pointer and the register map from the state:
```q
    ip:st[1];
    reg:st[3];
```
We iterate as long as the instruction pointer points to a valid instruction:
```q
    while[ip within (0;count[st 2]-1);
        ...
    ];
```
In the iteration, we fetch the next instruction and split it into opcode and parameters:
```q
    ni:st[2;ip];
    op:first ni;
    param:1_ni;
```
We perform a multi-way branch on the opcode.

For a `set` instruction, we update the corresponding value in the register map:
```q
    op=`set; [reg[`$param 0]:.arch1.getVal[reg;param 1]; ip+:1];
```
For `sub` and `mul`, we perform the necessary operation between the value in the register map and
the parameter. For `mul` we additionally update the "mul counter" in the state.
```q
    op=`sub; [reg[`$param 0]-:.arch1.getVal[reg;param 1]; ip+:1];
    op=`mul; [reg[`$param 0]*:.arch1.getVal[reg;param 1]; ip+:1; st[4]+:1;];
```
For `jnz`, we check the condition and update the instruction pointer if true. This is the only
instruction that does anything with the instruction pointer other than incrementing it by one.
```q
    op=`jnz; $[.arch1.getVal[reg;param 0]<>0; ip+:.arch1.getVal[reg;param 1];ip+:1];
```
At the end of the iteration, we set the state to halt and update the modified elements.
```q
    st[0]:`halt;
    st[1]:ip;
    st[3]:reg;
```

## Part 1
We initialize a VM with the input, run it until as far as it goes, then get the mul counter:
```q
q).arch1.new[x]
`run
0
((`set;,"b";"79");(`set;,"c";,"b");(`jnz;,"a";,"2");(`jnz;,"1";,"5");(`mul;,"b";"100");(`sub;,"b";..
`s#`a`b`c`d`e`f`g`h!0 0 0 0 0 0 0 0
0
q).arch1.run .arch1.new[x]
`halt
32
((`set;,"b";"79");(`set;,"c";,"b");(`jnz;,"a";,"2");(`jnz;,"1";,"5");(`mul;,"b";"100");(`sub;,"b";..
`s#`a`b`c`d`e`f`g`h!0 79 79 79 79 1 0 0
5929
q).arch1.getMulCount .arch1.run .arch1.new[x]
5929
```

## Part 2
It is infeasible to run the program to completion without adding manual hacks to the VM to make it
faster - or we can just compute what the program does without actually running the VM.

The program calculates the number of non-prime numbers in a certain range. The range is based on a
number in the first instruction plus a few constants:
```q
q)startval:100000+100*"J"$last" "vs first x
q)startval
107900
q)nums:startval+til[1001]*17
q)nums
107900 107917 107934 107951 107968 107985 108002 108019 108036 108053 108070 108087 108104 108121 ..
```
We cache the original count of the list:
```q
q)cnt:count nums
q)cnt
1001
```
We discard the non-prime numbers using a rudimentary loop:
```q
    d:2;
    while[d<startval;
        nums:nums where 0<>nums mod d;
        d+:1;
    ];
```
After the iteration, we have the primes left in the `nums` variable:
```q
q)nums
107951 108223 108359 108461 108529 108631 108869 108971 109073 109141 109379 109481 109583 110059 ..
q)count nums
94
```
The answer is the original list count minus the number of primes:
```q
q)cnt-count nums
907
```
