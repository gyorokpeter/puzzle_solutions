# Breakdown
Example input:
```q
x:"\n"vs"set a 1\nadd a 2\nmul a a\nmod a 5\nsnd a\nset a 0\nrcv a\njgz a -1\nset a 1\njgz a -2"
```

## Common
The VM implementation is in [duet.q](duet.q), and uses [GenArch](../utils/README.md#genarch). Only
the important functions are explained.

### .duet.new
This function creates a new VM state from the input.
```q
q)inp:(trim x except\:"\r")except enlist""
q)inp
"set a 1"
"add a 2"
"mul a a"
"mod a 5"
"snd a"
"set a 0"
"rcv a"
"jgz a -1"
"set a 1"
"jgz a -2"
```
We create the commands by splitting each input line on spaces and converting only the first element
to symbol:
```q
q)cmds:{a:" "vs x;(`$a[0]),1_a}each inp
q)cmds
(`set;,"a";,"1")
(`add;,"a";,"2")
(`mul;,"a";,"a")
(`mod;,"a";,"5")
(`snd;,"a")
(`set;,"a";,"0")
(`rcv;,"a")
(`jgz;,"a";"-1")
(`set;,"a";,"1")
(`jgz;,"a";"-2")
```
We find the registers in use by looking only at the parameters and checking which ones start with a
small letter:
```q
q)raze 1_/:cmds
,"a"
,"1"
,"a"
,"2"
,"a"
,"a"
..
q)first each raze 1_/:cmds
"a1a2aaa5aa0aa-a1a-"
q){x where x within "az"}first each raze 1_/:cmds
"aaaaaaaaaaa"
q)asc distinct`$/:{x where x within "az"}first each raze 1_/:cmds
`s#,`a
q)regs:{x!count[x]#0}asc distinct`$/:{x where x within "az"}first each raze 1_/:cmds
q)regs
a| 0
```
We pack the initial state into a list:
```q
q)(`run;0;cmds;regs;();())
`run
0
((`set;,"a";,"1");(`add;,"a";,"2");(`mul;,"a";,"a");(`mod;,"a";,"5");(`snd;,"a");(`set;,"a";,"0");..
(`s#,`a)!,0
()
()
```

## .duet.getVal
This function is responsible for value lookup. The value is passed in as a string. If it is a
number, the number is returned. Otherwise we assume it's a register so we return the corresponding
register value.
```q
    .duet.getVal:{[reg;val]$[null v:"J"$val;reg[`$val];v]};
```

## .duet.runD
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

For a `snd` instruction, we append the parameter value to the output:
```q
    $[op=`snd; [st[5],:.duet.getVal[reg;param 0]; ip+:1];
```
For a `set` instruction, we update the corresponding value in the register map:
```q
    op=`set; [reg[`$param 0]:.duet.getVal[reg;param 1]; ip+:1];
```
For `add` and `mul`, we perform the necessary operation between the value in the register map and
the parameter:
```q
    op=`add; [reg[`$param 0]+:.duet.getVal[reg;param 1]; ip+:1];
    op=`mul; [reg[`$param 0]*:.duet.getVal[reg;param 1]; ip+:1];
```
Same for `mod`, but this looks different because there is no assign-via-operator version for `mod`.
```q
    op=`mod; [reg[`$param 0]:reg[`$param 0]mod .duet.getVal[reg;param 1]; ip+:1];
```
For `rcv`, we check if there is any input in the input queue. If there is, we put it into the target
register and remove it from the input queue. Otherwise, we update the state to be blocked waiting
for input and return immediately.
```q
    op=`rcv; $[0<count st[4]; 
        [reg[`$param 0]:first st[4]; st[4]:1_st[4]; ip+:1];
        [st[0]:`needInput;st[1]:ip;st[3]:reg; :st]];
```
For `jgz`, we check the condition and update the instruction pointer if true. This is the only
instruction that does anything with the instruction pointer other than incrementing it by one.
```q
    op=`jgz; $[.duet.getVal[reg;param 0]>0; ip+:.duet.getVal[reg;param 1];ip+:1];
```
At the end of the iteration, we set the state to halt and update the modified elements.
```q
    st[0]:`halt;
    st[1]:ip;
    st[3]:reg;
```

## Part 1
We initialize a VM with the input, run it until as far as it goes, then get the last output:
```q
q).duet.new[x]
`run
0
((`set;,"a";,"1");(`add;,"a";,"2");(`mul;,"a";,"a");(`mod;,"a";,"5");(`snd;,"a");(`set;,"a";,"0");..
(`s#,`a)!,0
()
()
q).duet.run .duet.new[x]
`needInput
6
((`set;,"a";,"1");(`add;,"a";,"2");(`mul;,"a";,"a");(`mod;,"a";,"5");(`snd;,"a");(`set;,"a";,"0");..
(`s#,`a)!,0
()
,4
q).duet.getOutput .duet.run .duet.new[x]
,4
q)last .duet.getOutput .duet.run .duet.new[x]
4
```

## Part 2
Example input:
```q
x:"\n"vs"snd 1\nsnd 2\nsnd p\nrcv a\nrcv b\nrcv c\nrcv d"
```
We initialize two copies of the VM. For the second one, we update the `p` register to 1.
```q
q)st0:.duet.new[x]
q)st1:.duet.editRegister[st0;`p;1]
q)st0
`run
0
((`snd;,"1");(`snd;,"2");(`snd;,"p");(`rcv;,"a");(`rcv;,"b");(`rcv;,"c");(`rcv;,"d"))
`s#`a`b`c`d`p!0 0 0 0 0
()
()
q)st1
`run
0
((`snd;,"1");(`snd;,"2");(`snd;,"p");(`rcv;,"a");(`rcv;,"b");(`rcv;,"c");(`rcv;,"d"))
`s#`a`b`c`d`p!0 0 0 0 1
()
()
```
We initialize a counter for the output and a run flag:
```q
q)totalOut1:0
q)run:1b
```
We iterate while the run flag is true:
```q
    while[run;
        ...
    ];
```
In the iteration, we run both VMs until they are in an interrupted state:
```q
q)st0:.duet.run st0
q)st1:.duet.run st1
q)st0
`needInput
3
((`snd;,"1");(`snd;,"2");(`snd;,"p");(`rcv;,"a");(`rcv;,"b");(`rcv;,"c");(`rcv;,"d"))
`s#`a`b`c`d`p!0 0 0 0 0
()
1 2 0
q)st1
`needInput
3
((`snd;,"1");(`snd;,"2");(`snd;,"p");(`rcv;,"a");(`rcv;,"b");(`rcv;,"c");(`rcv;,"d"))
`s#`a`b`c`d`p!0 0 0 0 1
()
1 2 1
```
We fetch the output from both VMs:
```q
q)out0:.duet.getOutput st0
q)out1:.duet.getOutput st1
q)out0
1 2 0
q)out1
1 2 1
```
We update the output counter:
```q
q)totalOut1+:count out1
q)totalOut1
3
```
We clear the output queues and append each output list to the input queue of the opposite VM:
```q
q)st0:.duet.clearOutput st0
q)st1:.duet.clearOutput st1
q)st0:.duet.addInput[st0;out1]
q)st1:.duet.addInput[st1;out0]
q)st0
`needInput
3
((`snd;,"1");(`snd;,"2");(`snd;,"p");(`rcv;,"a");(`rcv;,"b");(`rcv;,"c");(`rcv;,"d"))
`s#`a`b`c`d`p!0 0 0 0 0
1 2 1
()
q)st1
`needInput
3
((`snd;,"1");(`snd;,"2");(`snd;,"p");(`rcv;,"a");(`rcv;,"b");(`rcv;,"c");(`rcv;,"d"))
`s#`a`b`c`d`p!0 0 0 0 1
1 2 0
()
```
We update the run flag based on whether there was any output. (This is the whole reason for using a
run flag, since there is no output before the iteration starts.)
```q
q)run:0<count[out0]+count[out1]
q)run
1b
```
The code of the iteration ends here.

After the iteration, we have the answer in the `totalOut1` variable:
```q
q)totalOut1
3
```
