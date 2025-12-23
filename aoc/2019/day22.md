# Breakdown
Example input:
```q
c:10
x:()
x,:enlist"deal into new stack"
x,:enlist"cut -2"
x,:enlist"deal with increment 7"
x,:enlist"cut 8"
x,:enlist"cut -4"
x,:enlist"deal with increment 7"
x,:enlist"cut 3"
x,:enlist"deal with increment 9"
x,:enlist"deal with increment 3"
x,:enlist"cut -1"
```

## Part 1
The function takes an extra `c` parameter for the number of cards.

A helper function `.d22.shuffle` is used to perform the actual shuffle.

First we compile each instruction into a function that generates the next permutation of
cards from the previous one:
```q
    b:{[c;x]
        ...
    {'"unknown:",x}[x]]}[c]each x;
```
For "deal into new stack" this is just `reverse`:
```q
    $[x~"deal into new stack";reverse;
        ...
```
For "cut" we swap the beginning and end, noting that different logic is needed for negative offsets:
```q
        ...
      x like "cut*";
        [d:"J"$last" "vs x;$[d>0;{[d;x](d _x),d#x}[d];{[d;x](d#x),d _x}[d]]];
        ...
```
For "deal with increment" we generate a sequence of positions and `mod` it by the card count to find
where each card ends up, then use `iasc` to get the permutation. We memoize the offsets for each
increment in a global variable `.d22.incr`.
```q
    .d22.incr:enlist[0N]!enlist[0#0];
    ...
        ...
      x like "deal with increment*";
        [d:"J"$last" "vs x;if[not d in key .d22.incr; .d22.incr[d]:iasc (d*til c)mod c];@[;.d22.incr[d]]];
        ...
```
Finally we apply the list of functions to the initial permutation.
```q
q)b
|:
{[d;x](d#x),d _x}[-2]
@[;0 3 6 9 2 5 8 1 4 7]
{[d;x](d _x),d#x}[8]
{[d;x](d#x),d _x}[-4]
@[;0 3 6 9 2 5 8 1 4 7]
{[d;x](d _x),d#x}[3]
@[;0 9 8 7 6 5 4 3 2 1]
@[;0 7 4 1 8 5 2 9 6 3]
{[d;x](d#x),d _x}[-1]
q){y x}/[deck;b]
9 2 5 8 1 4 7 0 3 6
```
To get the answer, we find 2019 in the result (only applies to real input).
```q
q)x:read0`:day22.in
q)md5 raze x
0xc0cf43c4f6b5aaa74a7c8003f64b71ba
q)c:10007
q).d22.shuffle[c;x]
5100 9077 3047 7024 994 4971 8948 2918 6895 865 4842 8819 2789 6766 736 4713 8690 2660 6637 607 45..
q).d22.shuffle[c;x]?2019
5472
```

## Part 2
```q
q)c:119315717514047
q)iters:101741582076661
```
Solution stolen and q-ified from:

https://github.com/mcpower/adventofcode/blob/501b66084b0060e0375fc3d78460fb549bc7dfab/2019/22/a-improved.py

Helper functions:

Modular addition
```q
madd:{[a;b;m](a+b)mod m};
```
Modular multiplication
```q
mmul:{[a;b;m]
    b:b mod m;
    r:0;
    while[b>0;
        if[1=b mod 2;r:madd[r;a;m]];
        b:b div 2;
        a:madd[a;a;m];
    ];
    r};
```
Modular exponentiation
```q
mexp:{[a;b;m]
    r:1;
    while[b>0;
        if[1=b mod 2;r:mmul[r;a;m]];
        b:b div 2;
        a:mmul[a;a;m];
    ];
    r};
```
Modular inverse
```q
minv:{[a;m]
    mexp[a;m-2;m]};

```
First we compile each instruction into a function that produces the next value of two variables,
`increment_mul` and `offset_diff`.
```q
    b:{[c;x]$[
        ...
      {'"unknown:",x}[x]]}[c]each x;
```
For "deal into new stack", this is `<incomprehensible high-level math>`.
```q
    $[x~"deal into new stack";{[c;x]x[1]:mmul[x[1];-1;c];x[0]:madd[x[0];x[1];c];x}[c];
        ...
```
For "cut", this is `<incomprehensible high-level math>`.
```q
        ...
      x like "cut*";
        [d:"J"$last" "vs x;{[c;d;x]x[0]:madd[x[0];mmul[x[1];d;c];c];x}[c;d]];
        ...
```
For "deal with increment", this is `<incomprehensible high-level math>`.
```q
        ...
      x like "deal with increment*";
        [d:"J"$last" "vs x;{[c;d;x]x[1]:mmul[x[1];minv[d;c];c];x}[c;d]];
        ...
```
We call the sequence with starting values of 0 and 1 for the two variables:
```q
q)cycle:{y x}/[0 1;b]
q)cycle
99057861072899 93340218727699
```
We extract the two variables from the result:
```q
q)offsetDiff:cycle 0
q)incrementMul:cycle 1
q)offsetDiff
99057861072899
q)incrementMul
93340218727699
```
We calculate... something:
```q
q)increment:mexp[incrementMul;iters;c]
q)increment
9561292483734
```
We calculate... something:
```q
q)offset:mmul[cycle 0;mmul[madd[1;neg increment;c];minv[madd[1;neg incrementMul;c];c];c];c]
q)offset
79922020928540
```
We calculate... something to find the card we are looking for:
```q
q)card:madd[offset;mmul[increment;2020;c];c]
q)card
64586600795606
```
