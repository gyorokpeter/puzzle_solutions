# Breakdown
Example input:
```q
q)x:"\n"vs"<x=-1, y=0, z=2>\n<x=2, y=-10, z=-7>\n<x=4, y=-8, z=8>\n<x=3, y=5, z=-1>"
q)step:10
```

## Common
The input parsing is a bit more involved this time. We drop the first and last character of each
line to get rid of the angle brackets:
```q
q)-1_/:1_/:x
"x=-1, y=0, z=2"
"x=2, y=-10, z=-7"
"x=4, y=-8, z=8"
"x=3, y=5, z=-1"
```
We split on commas:
```q
q)","vs/:-1_/:1_/:x
"x=-1" " y=0"   " z=2"
"x=2"  " y=-10" " z=-7"
"x=4"  " y=-8"  " z=8"
"x=3"  " y=5"   " z=-1"
```
We cut each element on equals signs - this time we need to go two levels deep:
```q
q)"="vs/:/:","vs/:-1_/:1_/:x
,"x" "-1"  " y" ,"0"  " z" ,"2"
,"x" ,"2"  " y" "-10" " z" "-7"
,"x" ,"4"  " y" "-8"  " z" ,"8"
,"x" ,"3"  " y" ,"5"  " z" "-1"
```
We take the last element of each pair to only keep the numbers and not the coordinate labels:
```q
q)last each/:"="vs/:/:","vs/:-1_/:1_/:x
"-1" ,"0"  ,"2"
,"2" "-10" "-7"
,"4" "-8"  ,"8"
,"3" ,"5"  "-1"
```
Finally we cast to integers:
```q
q)p:"J"$last each/:"="vs/:/:","vs/:-1_/:1_/:x
q)p
-1 0   2
2  -10 -7
4  -8  8
3  5   -1
```

We also define a simulation function that takes a pair positions and velocities and calculates the
values of these in the next step:
```q
    d12:{[pv]
        ...
    }
```
For a given state:
```q
q)pv:((2 -1 1;3 -7 -4;1 -7 5;2 2 0);(3 -1 -1;1 3 3;-3 1 -3;-1 -3 1))
```
We generate all the pairwise differences between the positions:
```q
q)pv[0]-\:/:pv[0]
0  0  0  1  -6 -5 -1 -6 4  0  3  -1
-1 6 5   0  0 0   -2 0 9   -1 9 4
1 6 -4   2 0 -9   0 0 0    1 9 -5
0  -3 1  1  -9 -4 -1 -9 5  0  0  0
```
The velocity delta of each coordinate is the signum of the difference. Since `signum` is an atomic
function, we can apply it to this whole 3-dimensional array.
```q
q)signum pv[0]-\:/:pv[0]
0  0  0  1  -1 -1 -1 -1 1  0  1  -1
-1 1 1   0  0 0   -1 0 1   -1 1 1
1 1 -1   1 0 -1   0 0 0    1 1 -1
0  -1 1  1  -1 -1 -1 -1 1  0  0  0
```
We sum together the deltas row-wise (so we need one level of `each`) to get the total velocity
delta:
```q
q)dv:sum each signum pv[0]-\:/:pv[0]
q)dv
0  -1 -1
-3 2  3
3  2  -3
0  -3 1
```
The next state is obtained by adding the velocity and the velocity delta to the position, and then
adding the velocity delta to the velocity:
```q
q)-1 .Q.s1 (pv[0]+pv[1]+dv;pv[1]+dv);
((5 -3 -1;1 -2 2;1 -4 -1;1 -4 2);(3 -2 -2;-2 5 6;0 3 -6;-1 -6 2))
```

## Part 1
Straightforward simulation. The function takes an extra parameter for the number of steps. We
initialize the velocities to zeros by repeating an all-zero list the same number of times as the
number of inputs:
```q
q)v:count[p]#enlist 0 0 0
q)v
0 0 0
0 0 0
0 0 0
0 0 0
```
We call the common simulation function with `/` (over), using the overload that takes an iteration
count:
```q
q)pv:d12/[step;(p;v)]
q)-1 .Q.s1 pv;
((2 1 -3;1 -8 0;3 -6 1;2 0 4);(-3 -2 1;-1 1 3;3 2 -3;1 -1 -1))
```
We calculate the energy by taking the absolute values, summing two levels deep, then taking the
product, then taking the sum:
```q
q)abs pv
2 1 3 1 8 0 3 6 1 2 0 4
3 2 1 1 1 3 3 2 3 1 1 1
q)sum each/:abs pv
6 9 10 6
6 5 8  3
q)prd sum each/:abs pv
36 45 80 18
q)sum prd sum each/:abs pv
179
```

## Part 2
We define a helper function that iterates the simulation function using `\` (scan), using the
overload that repeats until no change. This also stops iterating if the initial value is returned,
which is why this overload is useful here. We are only interested in the number of steps, so we
return the length of the list created by the iteration.
```q
q)d12a:{[p]count d12\[(p;count[p]#0)]}
```
We also need the helper functions for greatest common divisor and least common multiple:
```q
q)gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]}
q)lcm:{(x*y)div gcd[x;y]}
```
For the main simulation, we call the `d12a` function on one coordinate at a time. We can do this
because the coordinates are independent, and calculating the period for all coordinates in one go
would be infeasible.
```q
q)d12a each flip p
18 28 44
```
The overall period is the least common multiple of the individual periods. The `lcm` function above
only works on two numbers at a time, but using it with `/` will reduce the whole list.
```q
q)lcm/[d12a each flip p]
2772
```
