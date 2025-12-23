# Breakdown
Example input:
```q
q)md5 raze x
0x6bd7ac1b01784747d81dba96334c67b7
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
The intcode interpreter (this time called the `intcode` function) is a vast expansion of the one
from day 2. It now takes two parameters: the code (`a`) and the input. It returns the output from
the `OUT` instructions.
```q
intcode:{[a;input]
    ...
    output};
```
During initialization, we no longer overwrite positions in the input. However, now we initialize an
output list and a tape pointer (`tp`) that points to the next input position. Additionally instead
of checking the next instruction code in the loop condition, we introduce a boolean `run` variable.
```q
    output:();
    ip:0;
    tp:0;
    run:1b;
    while[run;
        ...
    ];
```
In the loop, we find the next opcode by `mod`ding the number at `ip` by 100:
```q
    op:a[ip] mod 100;
```
We find the number of arguments by mapping a hardcoded dictionary onto the opcode:
```q
    argc:(1 2 3 4 5 6 7 8 99!3 3 1 1 2 2 3 3 0)op;
```
We check for a null argument count (this happens if `op` is not among the keys of the dictionary).
This indicates an unknown instruction, which can happen due to a bug or invalid input.
```q
    if[null argc; '"invalid op ",string[op]];
```
We find the argument modes by dividing the operation by 100, 1000 and 10000 respectively and
`mod`ding the results by 10:
```q
    argm:argc#(a[ip] div 100 1000 10000)mod 10;
```
We pull the correct number of arguments out of the code based on the argument count:
```q
    argv0:a[ip+1+til argc];
```
We resolve the argument values such that the memory addresses are replaced by the corresponding
value from the memory array. Since this depends on the addressing mode, we use a [vector
conditional](https://code.kx.com/q/ref/vector-conditional/) to choose between the two values.
```q
    argv:?[argm=1;argv0;a argv0];
```
Now comes the handling of the individual instructions, in a branch statement as in day 2. The major
difference is that we now use `argv` instead of always reading from memory. For writing
instructions, `argv0` must be used instead, since that contains the address to write to, which was
resolved in `argv`, losing the information. The increment to `ip` is now also based on the argument
count.
```q
    $[op=1; [a[argv0 2]:argv[0]+argv[1]; ip+:1+argc];
      op=2; [a[argv0 2]:argv[0]*argv[1]; ip+:1+argc];
      ...
    ]
```
For the `IN` instruction, we increment the tape pointer.
```q
      op=3; [a[argv0 0]:input[tp]; tp+:1; ip+:1+argc];
```
For the `OUT` instruction, we append the argument to the output list.
```q
      op=4; [output,:argv 0; ip+:1+argc];
```
For the `JNZ` and `JZ` instructions, we use nested conditionals to update the `ip` based on the
condition:
```q
      op=5; $[argv[0]<>0; ip:argv 1; ip+:1+argc];
      op=6; $[argv[0]=0; ip:argv 1; ip+:1+argc];
```
The `LT` and `EQ` instructions work much like `ADD` and `MUL`:
```q
      op=7; [a[argv0 2]:0+argv[0]<argv[1]; ip+:1+argc];
      op=8; [a[argv0 2]:0+argv[0]=argv[1]; ip+:1+argc];
```
`HLT` now halts the program by switching the `run` variable to false:
```q
      op=99; run:0b;
```
There is a default case for an invalid opcode:
```q
      '"invalid op"
```
This ends the iteration. At the end, the `output` variable will contain all the outputs from the
intcode program.

## Part 1
We parse the input as on day 2 and invoke the intcode interpreter with an input tape containing the
single number 1:
```q
q)a:"J"$","vs raze x; intcode[a;enlist 1]
0 0 0 0 0 0 0 0 0 12234644
```
Technically this is not the puzzle answer, but it is useful to see the zeros to confirm that
everything passed. The transformation to get the answer is trivial (use `last` on the result).

## Part 2
We pass in the single number 5:
```q
q)a:"J"$","vs raze x; intcode[a;enlist 5]
,3508186
```
Once again this is not the actual answer but the transformation is trivial (use `first` or index
with `0`).

## Whiteboxing
### Part 1
The answer is calculated in the form `{y+8*x}/[5 6 5 2 7 6 2 4]` (with different numbers for each
input). The numbers can be found by pattern matching the code. The answer is calculated in `[223]`,
with each "digit" stored in `[224]` just before the addition. Therefore there will be a total of 8
`ADD [223],[224],[223]` and `ADD [224],[223],[223]` instructions that build up the answer. The
output must be `[223]` so first we search for every `223` in the input:
```q
q)ind:where a=223
q)ind
23 25 32 33 62 63 70 71 88 89 95 97 110 111 117 119 132 133 139 141 154 155 1..
```
Then we also fetch the two previous numbers for each found index:
```q
q)a(ind:where a=223)-\:1 2
1002 224
8    223
224  1
223  224
8    102
223  8
224  1
223  224
..
```
The two read arguments can either be `223,224` or `224,223`. We can avoid matching two possibilites
by putting each row in ascending order, so the ones we are looking for will be `223,224`:
```q
q)asc each a(ind:where a=223)-\:1 2
224 1002
8   223
1   224
223 224
8   102
8   223
1   224
223 224
...
```
Then we find which rows exactly match the list `223 224`. There will be exactly 8 of those.
```q
q)223 224~/:asc each a(ind:where a=223)-\:1 2
00010001000100010001000100010001000000000000000000000000000000000000000000000..
q)ind where 223 224~/:asc each a(ind:where a=223)-\:1 2
33 71 97 119 141 163 197 219
```
Now we have to check the previous instruction for the number that gets added. It will be either an
`ADD x,[224],[224]` or an `ADD [224],x,[224]` instruction. So from the initial `223` we found, we
have to step either 5 or 6 steps back to find our digits:
```q
q)-5 -6+/:ind where 223 224~/:asc each a(ind:where a=223)-\:1 2
28  27
66  65
92  91
114 113
136 135
158 157
192 191
214 213
q)a -5 -6+/:ind where 223 224~/:asc each a(ind:where a=223)-\:1 2
5   224
6   224
224 5
2   224
224 7
224 6
2   224
4   224
```
We now have to drop the `224`s to keep only the useful digits.
```q
q)(a -5 -6+/:ind where 223 224~/:asc each a(ind:where a=223)-\:1 2)except\:224
5
6
5
2
7
6
2
4
```
But they are still in single-element lists so we raze them:
```q
q)raze(a -5 -6+/:ind where 223 224~/:asc each a(ind:where a=223)-\:1 2)except\:224
5 6 5 2 7 6 2 4
```
Finally we put them together into the answer. We use the `/` iterator here since this is only a
repetition of multiply by 8 and add the next digit. This step can be expressed using the function
`{y+8*x}`. Let's see what we happens if we use this with `/` on the digits:
```q
q){y+8*x}/[raze(a -5 -6+/:ind where 223 224~/:asc each a(ind:where a=223)-\:1 2)except\:224]
12234644
```
Which is exactly the answer produced by running the full program.

### Part 2
This time the answer is built up from 24 binary digits. The code seems to check various
parameter combinations for the `LT` and `EQ` instructions. There are 32 possible checks:
`LT` vs `EQ`, two addressing modes for each argument, and two possible numerical values of each
argument. The latter is either `226` or `677`. `[226]` contains `677` and `[677]` contains `226`.
Of the 32 checks, only 24 are present in a seemingly random combination and order. Furthermore,
after each check there is either a `JZ` or `JNZ` instruction. So depending on this we have to invert
the result of the check to get the corresponding digit. Since there are only a handful of
possibilites, we can make a lookup table:
```q
q)t:enlist[`long$()]!enlist 0N;
q)t[7 226 226]:0;t[7 226 677]:0;t[7 677 226]:1;t[7 677 677]:0;
q)t[107 226 226]:1;t[107 226 677]:0;t[107 677 226]:0;t[107 677 677]:0;
q)t[1007 226 226]:0;t[1007 226 677]:0;t[1007 677 226]:0;t[1007 677 677]:1;
q)t[1107 226 226]:0;t[1107 226 677]:1;t[1107 677 226]:0;t[1107 677 677]:0;
q)t[8 226 226]:1;t[8 226 677]:0;t[8 677 226]:0;t[8 677 677]:1;
q)t[108 226 226]:0;t[108 226 677]:1;t[108 677 226]:1;t[108 677 677]:0;
q)t[1008 226 226]:0;t[1008 226 677]:1;t[1008 677 226]:1;t[1008 677 677]:0;
q)t[1108 226 226]:1;t[1108 226 677]:0;t[1108 677 226]:0;t[1108 677 677]:1;
```
Just like before, we use pattern matching to find the interesting instructions. We start by
searching for `224`, where the result of the comparison is stored:
```q
q)ind:where a=224
q)ind
15 18 19 21 27 29 31 53 56 57 59 65 67 69 79 82 83 85 92 93 96..
```
Using the same method as above, we filter out where the previous two numbers are `226` or `667` (in
any combination):
```q
q)(a(ind:where a=224)-\:1 2)
69    43
-483  101
224   -483
4     224
1001  223
5     224
1     224
39    93
-98   101
224   -98
4     224
1001  223
6     224
..
q)(a(ind:where a=224)-\:1 2) in 226 677
..
00b
00b
00b
11b
00b
11b
00b
11b
..
11b
00b
11b
00b
11b
00b
11b
00b
11b
..
q)all each (a(ind:where a=224)-\:1 2) in 226 677
00000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010b
q)ind2:ind where all each (a(ind:where a=224)-\:1 2) in 226 677
q)ind2
317 332 347 362 377 392 407 422 437 452 467 482 497 512 527 542 557 572 587 602 617 632 647 662
```
Then we look back to the last 3 numbers, including the instruction:
```q
q)a -3 -2 -1+/:ind2
1007 226 226
1007 226 677
108  677 677
1007 677 677
8    677 226
7    226 226
..
```
We use the lookup table to cheat at finding the solution:
```q
q)t a -3 -2 -1+/:ind2
0 0 0 1 0 0 1 0 1 0 1 0 1 0 0 1 0 0 1 0 1 0 0 0
```
Then we look ahead to find whether there is a `JNZ` or `JZ` at the relevant point:
```q
q)a 5+ind2
1006 1006 1005 1006 1006 1005 1005 1005 1006 1006 1005 1006 1005 1005 1005 1006 1005 1005 1005 100..
q)(1005=a 5+ind2)
001001110010111011110010b
```
We invert the result where this doesn't match up with the previous result (in the second result true
means a `JNZ`, therefore we skip adding the digit if the comparison was true).
```q
q)(t a -3 -2 -1+/:ind2)<>(1005=a 5+ind2)(t a -3 -2 -1+/:ind2)<>(1005=a 5+ind2)
001101011000011111011010b
```
Finally we add up the digits like before, using 2 as the multiplier this time:
```q
q){y+2*x}/[(t a -3 -2 -1+/:ind2)<>(1005=a 5+ind2)]
3508186
```
