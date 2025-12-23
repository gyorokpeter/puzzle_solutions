# Breakdown
Example input:
```q
q)md5 raze x
0xb7b2ac18d7614fa134bbe960f4cab9c9
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
The intcode interpreter is based on the on the one for [day 7](day7.md). After this day it is
considered "prod-ready" and will be used as a helper from the days that need it from [intcode.q](intcode.q).

The following changes are made to the interpreter:

There is a new variable as part of the VM state called `mo` (memory offset). This needs to be
initialized in both the cold boot and resume cases, and also saved in the `IN` instruction on pause.
```q
    $[a[0]~`pause;
        [ip:a[1];tp:a[2];mo:a[3];input:a[5],input;a:a[4]];
        [ip:0;tp:0;mo:0]
    ];
    ..
      op=3;[$[tp>=count input; :(`pause;ip;0;mo;a;0#input;output)
```
When calculating the arguments, a new variable is calculated in the `arga` variable that contains
the resolved memory addresses. This is not defined for immediate mode, copies the memory address
for position mode and resolves the offset for relative mode.
```q
    arga:?[2>argm;argv0;argv0+mo]
```
This is used in place of `argv0` for writing operations.

We expand the memory if necessary. To do this, we first find the maximum memory address accessed by
the current instruction:
```q
    mm:max 0,arga where 1<>argm
```
If this address is higher than the current maximum, we append enough zeros to the end of the memory
array to make the address valid.
```q
    if[mm>=count a; a,:(1+mm-count a)#0]
```
Finally there is a case in the instruction handlers for the new `ARB` instruction:
```q
      op=9; [mo+:argv 0; ip+:1+argc]
```
This is also reflected in the opcode argument count map:
```q
    argc:(1 2 3 4 5 6 7 8 9 99!3 3 1 1 2 2 3 3 1 0)op
```

## Part 1
We call the interpreter, passing in a single number 1 as input:
```q
q)a:"J"$","vs raze x
q)intcode[a;enlist 1]
,2870072642
```
This can be post-processed by calling `first` if it only contains a single number.

## Part 2
We call the interpreter, passing in a single number 2 as input:
```q
q)a:"J"$","vs raze x
q)intcode[a;enlist 2]
,58534
```
This can be post-processed by calling `first` if it only contains a single number.

## Whiteboxing

### Part 1
Similar to day 5, this part constructs a check code from a series of 32 binary digits. A series of
checks is carried out, and if the check passes, either 1 is added to the check code, or not, while
failing the test causes the opposite digit to be added. Then the check code is multiplied by 2.
This is always done by a `MUL [64],2,[64]` instruction (intcode: `1002 64 2 64`). Therefore if we
look for this sequence of numbers, we can find where the check code is being built up. There is no
multiplication after the 32nd check, instead there is an `OUT [64]` instruction that prints the
finished check code. Therefore the location of this instruction is also a place where we need to
check. We can use the following heuristics to figure out where to add digits:
* Immediately before the `MUL` instruction, there may be an `ADD` instruction. This counts as adding
  a digit *unless* there is a jump 3 instructions above that jumps directly on the `MUL`, in which
  case no digit is added.
* There may be an `ADD` instruction exactly 3 instructions above the `MUL`. This always adds a
  digit.
Translated into code:

We look for the correct MUL sequence:
```q
q)ind:where a=1002
q)ind:ind where a[ind+\:til 4]~\:1002 64 2 64
q)ind
207 229 251 277 303 325 343 369 391 413 439 457 475 501 519 545 571 593 615 641 667 685 707 725 75..
```
We also look for the `OUT [64]` sequence:
```q
q)ind2:where a=4
q)ind2:ind2 where a[ind2+\:til 2]~\:4 64
q)ind2
,901
q)ind,:ind2
```
Then we use the heuristics to find some key numbers in the code and determine each digit:
```q
q)one:(((1001=a[ind-4]) and a[ind-7]<>ind) or a[ind-9]=1001)
q)one
10101011000100011101010101000010b
```
We add up the digits using the same method as in day 5:
```
q){y+2*x}/[one]
2870072642
```

### Part 2
The intcode program calculates the 26th element of [A097333](https://oeis.org/A097333) using an inefficient
recursive algorithm. The result of this is always 21305. Then it adds a number that differs from
input to input but is always at the same location. Therefore a very trivial whiteboxing of this part
is:
```q
q)21305+a 917
58534
```
For the sake of completeness, here is how to calculate the required element of the sequence in an
iterative way:
```q
q)last last {1_x,sum x[0 2]}\[26;1 0 1]
21305
```
