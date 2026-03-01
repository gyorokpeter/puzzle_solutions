# Breakdown
Example input:
```q
q)md5"\n"sv x
0x0f829a01fdc67ea5781cb7c26afebc4a
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
The VM implementation is in [chronal.q](chronal.q), and uses [GenArch](../utils/README.md#genarch).
Most of that file is irrelevant to the solution.

A direct solution is not feasible.

## Whiteboxing

### Part 1
By looking at the code, we can see that on instruction 28, the value of register 0 is checked
against another register. If they match, the program exits. So putting the correct number in
register 0 results in the fastest exit. We can simulate the VM until instruction 28 (using the
breakpoint feature like in [day 19](day19.md) and find out what number is being compared to.
```q
q)st:.chronal.runD[.chronal.new x;1b;28;0b]
q)st
`break
28
((`seti;123;0;2);(`bani;2;456;2);(`eqri;2;72;2);(`addr;2;4;4);(`seti;0;0;4);(`seti;0;8;2);(`bori;2..
0 1 13970209 1 28 1
4
q).chronal.getRegisters[st]st[2;28;1]
13970209
```

### Part 2
It turns out that the program continues to check numbers and eventually loops around. To run for the
longest time, we have to put in the number that is the last before the repetition. Due to the
inefficient method used in the code, it is better to reimplement the formula that matches the logic
of the program.

We figure out the IP register by looking for the directive with a `#` at the beginning:
```q
q)ipr:"J"$last" "vs x first where x like "#*"
q)ipr
4
```
We split up the lines on spaces to get the parts of the instructions, and convert them to symbol and
long depending on their position:
```q
q)ins:"SJJJ"$/:" "vs/:x where not x like "#*"
q)ins
`seti 123     0        2
`bani 2       456      2
`eqri 2       72       2
`addr 2       4        4
..
```
We extract a constant that is used in calculations:
```q
q)c:ins[7;1]
q)c
2238642
```
We initialize an accumulator variable:
```q
q)a:65536
```
We initialize a list of seen numbers to tell if the numbers started cycling:
```q
q)seen:()
```
We perform an iteration with no upfront exit condition. There is a return statement in the middle.
```q
    while[1b;
        ...
    ];
```
We calculate the next number in the sequence by mimicking the operations in the input program:
```q
    cont:1b;
    while[cont;
        b:(((b+(a mod 256))mod 16777216)*65899)mod 16777216;
        cont:a>=256;
        a:a div 256;
    ];
    a:.chronal.bitor[b;65536];

q)a
13970209
q)b
13970209
```
We check if the resulting number was already seen. If yes, we return the last seen number (the one
before it loops back):
```q
    if[b in seen; :last seen];
```
Otherwise, we append the number to the seen list and continue the iteration:
```q
q)seen,:b
```
Eventually we reach the state when an already seen number is generated:
```q
q)seen
13970209 9646979 15549307 10554385 15257648 2750969 13784709 12564012 16516693 8374362 13333377 18..
q)b
6823672
q)b in seen
1b
```
The last seen number is the answer:
```q
q)last seen
6267260
```
