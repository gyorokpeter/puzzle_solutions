# Breakdown

Example input:
```q
x:"\n"vs"p=0,4 v=3,-3\np=6,3 v=-1,-3\np=10,3 v=-1,2\np=2,0 v=2,-1\np=0,0 v=1,3\np=3,0 v=-2,-2";
x,:"\n"vs"p=7,6 v=-1,-3\np=3,0 v=-1,-2\np=9,3 v=2,3\np=7,3 v=-1,2\np=2,4 v=2,-3\np=9,5 v=-3,-3";
size:11 7;
```

## Part 1
The function takes an additional `size` parameter. This has the value of `11 7` for the example and
`101 103` for the real input.

We split the input on spaces, drop two characters from each part (the `p=` and `v=` substrings),
split on commas and parse into integers:
```q
q)a:"J"$","vs/:/:2_/:/:" "vs/:x
q)a
0 4   3 -3
6  3  -1 -3
10 3  -1 2
2 0   2 -1
0 0   1 3
..
```
We calculate the positions of the bots after 100 steps by multiplying the speed by 100, adding it to
the starting position and modulo'ing with the size:
```q
q)100*a[;1]
300  -300
-100 -300
-100 200
200  -100
100  300
..
q)a[;0]+100*a[;1]
300  -296
-94  -297
-90  203
202  -100
100  300
..
q)b:(a[;0]+100*a[;1])mod\:size
q)b
3 5
5 4
9 0
4 5
1 6
..
```
To find which quadrant each bot is in, we subtract half of the size from the final coordinates, then
use `signum` which collapses them into -1, 0 or 1, and count them in groups:
```q
q)b-\:size div 2
-2 2
0  1
4  -3
-1 2
-4 3
..
q)signum b-\:size div 2
-1 1
0  1
1  -1
-1 1
-1 1
..
q)c:count each group signum b-\:size div 2
q)c
-1 1 | 4
0  1 | 1
1  -1| 3
-1 0 | 2
-1 -1| 1
1  1 | 1
```
We filter the groups that include a zero (these are the bots on the boundary lines) and then take
the products of the remaining counts:
```q
q){x where 0<>prd each x}key c
-1 1
1  -1
-1 -1
1  1
q)c{x where 0<>prd each x}key c
4 3 1 1
q)prd c{x where 0<>prd each x}key c
12
```

## Part 2
*This part cannot be demonstrated on an example input.*

This time we reverse the size as well as the coordinates so that we can put the bot locations into a
matrix:
```q
    size2:reverse size;
    a:reverse each/:"J"$","vs/:/:2_/:/:" "vs/:x;
```
We initialize a step counter and iterate with no terminating condition, incrementing the step
counter by one each time:
```q
    step:0;
    while[1b;
        step+:1;
        ...
    ]
```
Within the iteration, we calculate the new bot positions like in part 1, but using the step counter
instead of hardcoding the number 100:
```q
    newpos:(a[;0]+step*a[;1])mod\:size2
```
We generate a map with the bot locations, by starting from a matrix of spaces and replacing each
coordinate in turn (this technique is explained in [day 12](day12.md)):
```q
    map:.[;;:;"#"]/[size2#" ";newpos]
```
The puzzle makes no attempt to explain what counts as a Christmas tree so this took some guesswork.
I tried to match a sequence of `"#"` characters with various lengths, expecting there to be a
continuous streak of bots in the image. It turns out that matching for at least 8 consecutive
characters is required to get the correct image. If we find a match, we return the step counter.
```q
    if[any map like"*########*";:step]
```
