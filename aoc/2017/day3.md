# Breakdown
For this day the ideas for getting to the solution are more interesting than the code.

## Part 1
The spiral consists of concentric squares, each having 8 numbers more than the previous. Therefore,
it is possible to determine which square the number is in using the formula
```q
    sq:1+(-1+floor sqrt[-1+x])div 2
```
and the first number in that square is:
```q
    fst:2+ 4*(sq*(sq-1))
```
The number 1 is a special case as it doesn't follow the same rule as the rest of the numbers.

Each square has 4 "legs" of the spiral. The first leg starts at the first number of the spiral that
is in the given square, and each leg goes until the next corner, so the last number of the last leg
finishes the square. The length of each leg is twice the ordinal number of the square, so we can
`div` and `mod` by this number to find which leg our number is in and what is its position in the
leg.
```q
    side:(x-fst)div 2*sq;
    pos:(x-fst)mod 2*sq;
```
Each leg has a different formula for the coordinates of the numbers, so the final coordinates are
returned by a conditional statement:
```q
    $[side=0;(sq;(sq-(1+pos)));
      side=1;(sq-(1+pos);neg sq);
      side=2;(neg sq;(1+pos)-sq);
      side=3;((1+pos)-sq;sq);
        "???"]
```
Since we chose the number 1 as the origin, the Manhattan distance is the sum of the absolute values
of the coordinates.

Putting it all together:
```q
.d3.spiralPos:{
    if[x=1; :0 0];
    sq:1+(-1+floor sqrt[-1+x])div 2;
    fst:2+ 4*(sq*(sq-1));
    side:(x-fst)div 2*sq;
    pos:(x-fst)mod 2*sq;
    $[side=0;(sq;(sq-(1+pos)));
      side=1;(sq-(1+pos);neg sq);
      side=2;(neg sq;(1+pos)-sq);
      side=3;((1+pos)-sq;sq);
        "???"]
    };
```
Some examples:
```q
q).d3.spiralPos 1
0 0
q).d3.spiralPos 12
2 -1
q).d3.spiralPos 23
0 2
q).d3.spiralPos 1024
-15 -16
q)sum abs .d3.spiralPos 1
0
q)sum abs .d3.spiralPos 12
3
q)sum abs .d3.spiralPos 23
2
q)sum abs .d3.spiralPos 1024
31
```

## Part 2
To find our number in the spiral, we generate the numbers in the spiral leg by leg. We need to keep
the last 5 legs since each number may refer to numbers that far back. However, it's OK to keep all
legs since the numbers grow exponentially, so there won't be too many of them (every time we turn a
corner, the next number has the sum of the previous two numers in it, and since each number itself
has the previous number in it, the number after the corner is at least twice the second previous
number).

The central number 1 and the legs of the first square don't exhibit the same pattern as the later
squares, so the numbers in these legs are hardcoded. (For `n`=1, it's just lucky that the algorithm
actually returns the correct value.)

We express the numbers in each leg as a closed formula based on the numbers in previous legs. The
2nd and 3rd legs of each square behave in the same way, but small modifications are required for the
first and the last leg. For all legs other than the first, the number backwards from the first
number is already filled in, so this number ("head") will be in all of the numbers. And for the last
leg, the last two numbers will include the first number of the first leg - for all other legs, there
is a blank space in the corresponding position.

The numbers have the elements of the 4th previous leg either 1, 2 or 3 times in them. Furthermore,
for legs other than the first, the last number of the 5th previous leg is also included - for the
first leg, this place is occupied by head, which is already in the sum, so we fill that position
with zero.

Since the number of times each element needs to be added up depends on the position, we use matrix
multiplication to express the calculation. We use some q magic to build up the matrix:
```q
    ({3&0|2+x-/:\:x}til c)-\:(1,(c-1)#0)
```
For c=6, this would return a matrix like this:
```q
1 1 0 0 0 0
2 2 1 0 0 0
2 3 2 1 0 0
2 3 3 2 1 0
2 3 3 3 2 1
2 3 3 3 3 2
```
Which is the coefficients of each number in the adjacent row/column. As a q quirk we need to cast
the matrix to float before calling the `mmu` operation, but then we can convert the result back to
long. We do a while loop to build new legs until we get one where the largest number is greater than
the number we are looking for, then search for the first larger number in the last calculated leg.

Breakdown of building the matrix:
```q
q)c:6
```
We start with the list of numbers up to c:
```q
q)til c
0 1 2 3 4 5
```
The `/:\:` iterator combination is the "multiplication table" mode. In this case we use it with the
subtraction operator:
```q
q)x-/:\:x
0 -1 -2 -3 -4 -5
1 0  -1 -2 -3 -4
2 1  0  -1 -2 -3
3 2  1  0  -1 -2
4 3  2  1  0  -1
5 4  3  2  1  0
```
We shift the zeros up a bit by adding 2:
```q
q)2+x-/:\:x
2 1 0 -1 -2 -3
3 2 1 0  -1 -2
4 3 2 1  0  -1
5 4 3 2  1  0
6 5 4 3  2  1
7 6 5 4  3  2
```
We clamp the numbers to 0..3 using the `&` "select minimum" and `|` "select maximum" operators:
```q
q)0|2+x-/:\:x
2 1 0 0 0 0
3 2 1 0 0 0
4 3 2 1 0 0
5 4 3 2 1 0
6 5 4 3 2 1
7 6 5 4 3 2
q)3&0|2+x-/:\:x
2 1 0 0 0 0
3 2 1 0 0 0
3 3 2 1 0 0
3 3 3 2 1 0
3 3 3 3 2 1
3 3 3 3 3 2
```
We still need to subtract 1 from the first column. This can be done by subtracting the vector
`1 0 0 0 0 0` from the first row. Obviously, the length of the vector depends on `c`.
```q
q)(1,(c-1)#0)
1 0 0 0 0 0
```
The normal subtract operator would subtract the vector from each column, rather than each row. We
use the `\:` iterator to guide it in the right direction.
```q
q)({3&0|2+x-/:\:x}til c)-(1,(c-1)#0)
1 0 -1 -1 -1 -1
3 2 1  0  0  0
3 3 2  1  0  0
3 3 3  2  1  0
3 3 3  3  2  1
3 3 3  3  3  2
q)({3&0|2+x-/:\:x}til c)-\:(1,(c-1)#0)
1 1 0 0 0 0
2 2 1 0 0 0
2 3 2 1 0 0
2 3 3 2 1 0
2 3 3 3 2 1
2 3 3 3 3 2
```

Putting it all together:
```q
d3p2:{
    r:enlist enlist 1;
    n:0;
    while[max[last r]<=x;
        n+:1;
        pr:0^$[1<>n mod 4;last[r[n-5]];last r n-1],r[n-4],$[0=n mod 4;first[r n-3];0];
        c:count[pr];
        head:$[1=n mod 4;0;sum (-2+ 1=n mod 4)#r n-1];
        row:head+`long$(`float$({3&0|2+x-/:\:x}til c)-\:(1,(c-1)#0)) mmu `float$pr;
        if[n=2; row:4 5];
        if[n=3; row:10 11];
        if[n=4; row:23 25];
        r,:enlist row;
    ];
    row:last r;
    first row where row>x};
```
Examples:
```q
q)d3p2 1
2
q)d3p2 2
4
q)d3p2 5
10
q)d3p2 10
11
q)d3p2 11
23
q)d3p2 23
25
q)d3p2 25
26
q)d3p2 26
54
```
