# Breakdown
Example input:
```q
q)md5 raze x
0x45e9fe40b52d0e45e3bf8c476acc3923
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
This task is uninteresting from a q perspective. It is simply an exercise in comparing numbers and
setting elements in arrays.

The interpreter is implemented in the function `d2`. It takes three parameters: the code as a list
of bytes and the two values to put at addresses 1 and 2.
```q
d2:{[a;n;v]
    ...
    }
```
We start by overwriting the addresses 1 and 2 with the given values and initializing the instruction
pointer to 0:
```q
    a[1 2]:(n;v);
    ip:0;
```
We iterate until the current instruction is 99:
```q
    while[a[ip]<>99;
        ...
    ];
```
The body of the iteration is a single conditional. We check for the two possible instructions at the
instruction pointer. If none of them match, we throw an error (this can only happen due to invalid
input, including running off the end of the input since that results in `0N` being read as the
"instruction").
```q
    $[a[ip]=1; ...
      a[ip]=2; ...
      '"invalid op"
    ];
```
For both instructions, the operation consists of updating the array at address `a[ip+3]` with the
result of either adding or multiplying the numbers at `a[ip+1]` and `a[ip+2]` (there is double
indexing, first to find the memory address and then to read the number from that address), then
incrementing the instruction pointer by 4.
```q
    $[a[ip]=1; [a[a ip+3]:a[a ip+1]+a[a ip+2]; ip+:4];
      a[ip]=2; [a[a ip+3]:a[a ip+1]*a[a ip+2]; ip+:4];
      '"invalid op"
    ];
```
After the iteration, we return the value at index 0 in the array.
```q
    a[0]
```

## Part 1
We split the input on commas using [`vs`](https://code.kx.com/q/ref/vs/) and convert the result to
integers, then call the common function with the updated values set to 12 and 2. (The raze is there
because the conventional input format is a list of strings, so we need to turn it into a single
string. For intcode inputs, the input is a single line, but I allow for some flexibility in breaking
it up into multiple lines, as long as no spaces are added.)
```q
q)a:"J"$","vs raze x; d2[a;12;2]
3562672
```

## Part 2
We generate the list of integers from 0 to 99 usting [`til`](https://code.kx.com/q/ref/til/):
```q
q)til[100]
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 ..
```
We use `/:\:` (the combination of 
[each-left and each-right](https://code.kx.com/q/ref/maps/#each-left-and-each-right)) to call the
interpreter with every pairing of the numbers from 0 to 99:
```q
q)b:til[100]d2[a]/:\:til[100]
q)b
797870  797871  797872  797873  797874  797875  797876  797877  797878  797879  797880  797881  79..
1028270 1028271 1028272 1028273 1028274 1028275 1028276 1028277 1028278 1028279 1028280 1028281 10..
1258670 1258671 1258672 1258673 1258674 1258675 1258676 1258677 1258678 1258679 1258680 1258681 12..
1489070 1489071 1489072 1489073 1489074 1489075 1489076 1489077 1489078 1489079 1489080 1489081 14..
1719470 1719471 1719472 1719473 1719474 1719475 1719476 1719477 1719478 1719479 1719480 1719481 17..
..
```
We use the [2D search](../utils/patterns.md#2d-search) pattern to find the constant given in the
puzzle:
```q
q)c:first raze til[100],/:'where each b=19690720
q)c
82 50
```
The answer is then the first coordinate multipled by 100 and then adding the second coordinate.
```q
q)(100*c[0])+c[1]
8250
```

## Whiteboxing?
There is no point in whiteboxing day 2's program.

It starts by doing some dummy operations on address 3, then it grabs the content of address 1, does
a sequence of operations on it by either adding or multiplying 1, 2, 3, 4 or 5 (these come from
addresses 5, 6, 9, 10, 13 respectively - due to the lack of immediate mode which is introduced on
day 5 they need to be in memory), then finally it adds the number at address 2. Finding out the
order and arguments to these operations is equivalent to making a basic intcode interpreter.
Interestingly there is a dummy multiply instruction after the `HLT`. This is probably to ensure that
the `HLT` instruction actually stops the program. Otherwise the multiplication will overwrite the
answer with zero.
