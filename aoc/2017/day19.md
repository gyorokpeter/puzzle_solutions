# Breakdown
Example input:
```q
x:();
x,:enlist"     |          "
x,:enlist"     |  +--+    "
x,:enlist"     A  |  C    "
x,:enlist" F---|----E|--+ "
x,:enlist"     |  |  |  D "
x,:enlist"     +B-+  +--+ "
```

## Common
The same function will solve both parts and return the answers as a two-element list.

We define the deltas of the four cardinal directions and initialize the starting direction to down
(which is element 2 in the list).
```q
q)dir:2
q)dirsteps:(-1 0;0 1;1 0;0 -1)
```
We find the first (should be only) non-empty character in the first row of the input and set it as
the starting position, combined with a 0 indicating the top row:
```q
q)pos:(0;first where x[0]<>" ")
q)pos
0 5
```
We initialize a step counter to 1 and a list to collect the letters to empty:
```q
q)steps:1
q)letters:""
```
We perform an iteration. There is no end condition at the start, as there will be a return statement
in the middle.
```q
    while[1b;
        ...
    ];
```
In the iteration, we calculate the next position by adding the delta for the current direction to
the curent position:
```q
q)nxtp:pos+dirsteps dir
q)nxtp
1 5
```
The following part is best demonstrated in a later iteration:
```q
q)pos
5 5
q)steps
6
```
We check if the map has a space under the next position. Since indexing out of bounds results in a
type-correct null value and this value for char is the space character, we don't need a separate
bounds check.
```q
q)x . nxtp
" "

    if[" "=x . nxtp;
        ...
    ];
```
If the condition is true, it means we have to turn instead of continuing straight. We generate the
possible next directions by adding and subracting 1 to the current one, making sure to wrap around:
```q
q)nxtdirs:(dir+1 -1)mod 4
q)nxtdirs
3 1
```
We find the next positions by adding the deltas of the next directions to the current position:
```q
q)nxtps:pos+/:dirsteps nxtdirs
q)nxtps
5 4
5 6
```
We check the map at these coordinates and keep the direction where we find a non-empty value:
```q
q)x ./: nxtps
" B"
q)nxtdirs where " "<>x ./: nxtps
,1
q)dir:first nxtdirs where " "<>x ./: nxtps
q)dir
1
```
As a special case, if there is no non-empty next position, that means we have reached the end of the
line. Taking the first element of the empty `where ...` will then result in a null. So we check for
this and return the accumulated letters and the step counter, which is the terminating condition for
the loop.
```q
    if[null dir; :(letters;steps)];
```
Otherwise, we update the next position based on the new direction:
```q
q)nxtp:pos+dirsteps dir
q)nxtp
5 6
```
The check for turning ends here.

The following part is best demonstrated in a later iteration:
```q
q)pos
1 5
q)steps
2
```
We check if the map contains a letter at the current position:
```q
q)(ch:x . nxtp) within "AZ"
1b
q)ch
"A"
```
If so, we append the letter to the list:
```q
q)letters,:ch
q)letters
,"A"
```
The check for finding letters ends here.

Finally, we update the current position to the next one and increase the step counter:
```q
q)pos:nxtp
q)steps+:1
q)pos
2 5
q)steps
3
```
The code of the iteration ends here.

The return statement in the middle will return the answers to both parts:
```q
q)(letters;steps)
"ABCDEF"
38
```

## Part 1
We call the common function and index the result with 0.
```q
q).d19.followPath[x][0]
"ABCDEF"
```

## Part 2
We call the common function and index the result with 1.
```q
q).d19.followPath[x][1]
38
```