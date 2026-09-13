# Breakdown
Example input:
```q
x:()
x,:enlist"p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>"
x,:enlist"p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>"
x,:enlist"p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>"
x,:enlist"p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>"
```

## Common
The common function parses the input and performs the simulation, with an option for annihilation
that is only enabled for part 2.

We split the input on commas:
```q
q)", "vs/:x
"p=<-6,0,0>" "v=< 3,0,0>" "a=< 0,0,0>"
"p=<-4,0,0>" "v=< 2,0,0>" "a=< 0,0,0>"
"p=<-2,0,0>" "v=< 1,0,0>" "a=< 0,0,0>"
"p=< 3,0,0>" "v=<-1,0,0>" "a=< 0,0,0>"
```
We remove the first 3 and last characters from each of the substrings to keep only the numbers.
Since there are two levels of nesting, this requires using the `/:` (each right) iterator twice.
```q
q)-1_/:/:3_/:/:", "vs/:x
"-6,0,0" " 3,0,0" " 0,0,0"
"-4,0,0" " 2,0,0" " 0,0,0"
"-2,0,0" " 1,0,0" " 0,0,0"
" 3,0,0" "-1,0,0" " 0,0,0"
```
We cut the substrings on commas again and convert to integers:
```q
q)","vs/:/:-1_/:/:3_/:/:", "vs/:x
"-6" ,"0" ,"0" " 3" ,"0" ,"0" " 0" ,"0" ,"0"
"-4" ,"0" ,"0" " 2" ,"0" ,"0" " 0" ,"0" ,"0"
"-2" ,"0" ,"0" " 1" ,"0" ,"0" " 0" ,"0" ,"0"
" 3" ,"0" ,"0" "-1" ,"0" ,"0" " 0" ,"0" ,"0"
q)pd:"J"$","vs/:/:-1_/:/:3_/:/:", "vs/:x
q)pd
-6 0 0 3  0 0 0  0 0
-4 0 0 2  0 0 0  0 0
-2 0 0 1  0 0 0  0 0
3  0 0 -1 0 0 0  0 0
```
We calculate the final positions of the particles using an iterated function. The function takes the
number of the part (because it can't see the `part` variable in the outer function, it has to be
explicitly forwarded) and the current state as `x`:
```q
q)part:1
q)x:pd
```
In the iterated function, we update the speeds by adding the accelerations, then we update the
positions by adding the speeds:
```q
q)x[;1]+:x[;2]
q)x
-6 0 0 3  0 0 0  0 0
-4 0 0 2  0 0 0  0 0
-2 0 0 1  0 0 0  0 0
3  0 0 -1 0 0 0  0 0
q)x[;0]+:x[;1]
q)x
-3 0 0 3  0 0 0  0 0
-2 0 0 2  0 0 0  0 0
-1 0 0 1  0 0 0  0 0
2  0 0 -1 0 0 0  0 0
```
If we are in part 2, we also have to calculate the eliminations. This is best demonstrated in a
later state:
```q
q)part:2
q)x:((0 0 0;3 0 0;0 0 0);(0 0 0;2 0 0;0 0 0);(0 0 0;1 0 0;0 0 0);(1 0 0;-1 0 0;0 0 0))
```
We find the overlapping particles by grouping the positions:
```q
q)group x[;0]
0 0 0| 0 1 2
1 0 0| ,3
```
The particles that are *not* eliminated are those in single-element groups:
```q
q)1=count each group x[;0]
0 0 0| 0
1 0 0| 1
q)where 1=count each group x[;0]
1 0 0
```
We need the indices to filter the original list. We can get them by indexing the grouping with the
keys returned by `where`. To avoid having to repeat the `group` call, we can store its result in a
variable or use a nested function.
```q
q)group[x[;0]]where 1=count each group x[;0]
3
q){x where 1=count each x}group x[;0]
3
```
This result is a list of lists, so we `raze` it to get a flat list of indices, then we index into
`x` to get the filtered particle list:
```q
q)x:x raze{x where 1=count each x}group x[;0]
q)x
1  0 0 -1 0 0 0  0 0
```
The code of the iterated function ends here.

We call this function, binding the `part` parameter and applying the `/` (over) iterator with an
iteration count and starting value:
```q
    {[part;x]x[;1]+:x[;2];x[;0]+:x[;1];if[2=part;x:x raze{x where 1=count each x}group x[;0]];x}[part]/[50000;pd]
```
This is the return value of the common function.

## Part 1
We call the common function:
```q
q)pd2:d20[1;x]
q)pd2
149994 0 0 3      0 0 0      0 0
99996 0 0  2     0 0  0     0 0
49998 0 0  1     0 0  0     0 0
-49997 0 0 -1     0 0 0      0 0
```
We find the distance of each particle from the origin, which is the sum of the absolute values of
the positions:
```q
q)abs pd2[;0]
149994 0 0
99996  0 0
49998  0 0
49997  0 0
q)sum each abs pd2[;0]
149994 99996 49998 49997
```
To find the closest one, we find the minimum of the list and find the index of the first element
that is equal to the minimum:
```q
q)min sum each abs pd2[;0]
49997
q)first where{x=min x}sum each abs pd2[;0]
3
```

## Part 2
We return the number of elements in the result of the common function:
```q
q)count d20[2;x]
1
```
