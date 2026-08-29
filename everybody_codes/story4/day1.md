# Breakdown

## Part 1
Example input:
```q
x:()
x,:enlist"1,2,3,4,5,6,7,8,9"
x,:enlist"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"
```
The solution is an iterated function that appends the next position to a list based on the given
step size.

We [parse the input](../../aoc/utils/patterns.md#input-parsing) by cutting on commas and casting to
integers:
```q
q)n:"J"$","vs/:x
q)n
1 2 3 4 5 6 7 8 9
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
```
The core is an iterated function that takes a partial position list and the next step size.
```q
q)x:0 5 4 2 6 10 15 14 12
q)y:2
```
In the function, we calculate the next element by assuming that we have to step backwards:
```q
q)d:last[x]-y
q)d
10
```
We check if the next position is negative or already in the list, and if so, we switch to stepping
forward:
```q
q)d in x
1b
q)if[(d in x)or d<0;d:last[x]+y]
q)d
14
```
We append the found position to the list, which is also the return value of the function:
```q
q)x,d
0 5 4 2 6 10 15 14 12 14
```
We iterate this function with [`/` (over)](https://code.kx.com/q/ref/accumulators/#binary-application)
using the overload that takes a starting value and a list to iterate over. The accumulator starts
as a list containing the single number 0.
```q
q){d:last[x]-y;if[(d in x)or d<0;d:last[x]+y];x,d}/[enlist 0;1 2 3 4 5 6 7 8 9]
0 1 3 6 2 7 13 20 12 21
```
We further apply this iteration to each line of the input. We can do this by eliding the list from
the `/` application, creating a projection, and then calling the projection with `each`:
```q
q){d:last[x]-y;if[(d in x)or d<0;d:last[x]+y];x,d}/[enlist 0;]each n
0 1 3 6 2 7 13 20 12 21
0 1 3 6 2 7 13 20 12 21 11 22 10 23 9 24 8 25 43 62 42 63 41 18 42 17 43 16 44 15 45
```
To get the answer, we take the last element of each list and sum them:
```q
q)last each{d:last[x]-y;if[(d in x)or d<0;d:last[x]+y];x,d}/[enlist 0;]each n
21 45
q)sum last each{d:last[x]-y;if[(d in x)or d<0;d:last[x]+y];x,d}/[enlist 0;]each n
66
```

## Part 2
Example input:
```q
x:()
x,:enlist"1,1,1,1,1"
x,:enlist"5,1,2,3,4,5,1,2,3,4"
x,:enlist"2,1,1,2,1,1,2,1,1,2,1,1"
x,:enlist"5,1,2,1,2,7,1,2,1,2,7,1,2,1,2"
```
Input parsing is the same as part 1:
```q
q)n:"J"$","vs/:x
q)n
1 1 1 1 1
5 1 2 3 4 5 1 2 3 4
2 1 1 2 1 1 2 1 1 2 1 1
5 1 2 1 2 7 1 2 1 2 7 1 2 1 2
```
The iterated function needs a slight change, which can be demonstrated in this intermediate state:
```q
q)x:0 2 1 3 5 4 6 8 7 9 11 10
q)y:1
```
We still check the backwards jump and switch to a forwards jump if it's not feasible:
```q
q)d:last[x]-y;if[(d in x)or d<0;d:last[x]+y]
q)d
11
```
We now repeatedly check if the resulting destination is in the list and increase it by 1 if so:
```q
q)while[d in x;d+:1]
q)d
12
```
The rest of the solution is the same.
```q
q){d:last[x]-y;if[(d in x)or d<0;d:last[x]+y;while[d in x;d+:1]];x,d}/[enlist 0;]each n
0 1 2 3 4 5
0 5 4 2 6 10 15 14 12 9 13
0 2 1 3 5 4 6 8 7 9 11 10 12
0 5 4 2 1 3 10 9 7 6 8 15 14 12 11 13
q)last each{d:last[x]-y;if[(d in x)or d<0;d:last[x]+y;while[d in x;d+:1]];x,d}/[enlist 0;]each n
5 13 12 13
q)sum last each{d:last[x]-y;if[(d in x)or d<0;d:last[x]+y;while[d in x;d+:1]];x,d}/[enlist 0;]each n
43
```

## Part 3
Once again, the iterated function needs to be expanded to handle the new restrictions. We first get
the arcs that the next arc may intersect, which is done by dropping the last element and cutting the
remaining list into sublists of length 2:
```q
q)2 cut -1_0 5 4 2 6 10 15 14 12
0  5
4  2
6  10
15 14
```
If the original list has an even length, we furthermore have to drop the first element as well.
Instead of adding an `if` statement, we can take the length of the list modulo 2, subtract it from
1, and use the resulting number to indicate how many elements to drop from the front of the list.
```q
q)l:0 5 4 2 6 10 15 14 12
q)2 cut (1-count[l]mod 2)_-1_l
0  5
4  2
6  10
15 14
q)l:0 5 4 2 6 10 15 14
q)2 cut (1-count[l]mod 2)_-1_l
5  4
2  6
10 15
```
We also cache the last element of the original list, and put the endpoints of each arc in ascending
order:
```q
q)l:0 5 4 2 6 10 15 14 12
q)s:3
q)a:last l
q)a
12
q)arc:asc each 2 cut (1-count[l]mod 2)_-1_l
q)arc
0  5
2  4
6  10
14 15
```
An intersection is indicated by the fact that the starting point of an arc being inside one of the
above intervals differs from the ending point being inside them. Since this requires comparing to
the "is `a` within the intervals" list multiple times, we cache this value:
```q
q)aw:a within/:arc
q)aw
0000b
```
Note that `within` requires the ends of the interval to be in ascending order, which is why we had
to use `asc` before.

When we check whether moving back is a valid option, now we have to check three conditions. Instead
of `x and y and z` we can use `any(x;y;z)`. The conditions are: the destination already being in the
list, the destination being negative, and the move causing an intersection. For the latter, we
generate the same `within` list like the above using the destination, then check if it exactly
matches the value we got from `a`.
```q
q)d:a-s
q)d
9
q)d within/:arc
0010b
q)aw~d within/:arc
0b
```
If the two lists don't match, that means we have an intersection, so we negate this condition in the
"can we go here" check.
```q
q)(d in l;d<0;not aw~d within/:arc)
001b
q)any(d in l;d<0;not aw~d within/:arc)
1b
```
We have to add a similar intersection check in the loop that moves forward:
```q
q)d:a+s
q)d
15
q)while[(d in l) or not aw~d within/:arc;d+:1];
q)d
16
```
We still need to add the check for getting stuck, which can happen in the following scenario:
```q
q)l:0 5 4 2 1
q)s:2
```
It is possible to get stuck if the last position is within any of the intervals:
```q
q)a:last l
q)arc:asc each 2 cut (1-count[l]mod 2)_-1_l
q)arc
0 5
2 4
q)aw:a within/:arc
q)aw
10b
```
To avoid the infinite loop in searching for a new destination, we set a limit by looking at the
highest endpoint of an interval that the last position is in:
```q
q)max last each arc where aw
5
```
We also need to handle the case when `a` is not in any of the intervals. Then we just set the limit
to `0W` (infinity).
```q
q)lim:$[sum 0b,aw;max last each arc where aw;0W]
q)lim
5
```
When checking for whether to stop moving forward, we check if the next position is within the limit:
```q
q)d:a+s
q)d
3
q)while[(d<lim)and(d in l) or not aw~d within/:arc;d+:1]
q)d
5
```
Afterwards, we check if we stopped at the limit, which indicates that the move got stuck, so we
return without appending anything to the list.
```q
    if[d>=lim;:l];
```
Wrapping all of this in a function, we iterate it like in the previous parts:
```q
    f:{[l;s] ... };

q)f/[enlist 0;]each n
0 1 2 3 4 5
0 5 4 2 6 10 15 14 12 16 20
0 2 1
0 5 4 2 1
q)last each f/[enlist 0;]each n
5 20 1 1
q)sum last each f/[enlist 0;]each n
27
```

## Bonus: Visualizer
Here is some code to visualize the resulting curves:
```q
    svgBoilerplate:{[width;height;content]
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        ,.h.htac[`svg;(`xmlns`xmlns:xlink`width`height!("http://www.w3.org/2000/svg";"http://www.w3.org/1999/xlink";string width;string height))]
        content};
    fmtl:{[l]linewidth:10*max l;svgBoilerplate[10+linewidth;100;]
        "\n",.h.htac[`line;`x1`y1`x2`y2`stroke!string[(5;50;linewidth+5;50)],enlist"black";""],"\n"
        ,"\n"sv{x:asc x;r:5*abs x[0]-x[1];.h.htac[`path;([d:"M ",string[5+10*x 0]," 50 A ",string[r]," ",string[r]," 0 0 ",string[y]," ",string[5+10*x 1]," 50";
            stroke:"black";fill:"none"]);""]}'[1_(;)':[l];-1_til[count l]mod 2]};
```
Example usage:
```q
q)-1 fmtl 0 5 4 2 6 10 15 14 12 16 20
<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="210" height="100">
<line x1="5" y1="50" x2="205" y2="50" stroke="black"></line>
<path d="M 5 50 A 25 25 0 0 0 55 50" stroke="black" fill="none"></path>
<path d="M 45 50 A 5 5 0 0 1 55 50" stroke="black" fill="none"></path>
<path d="M 25 50 A 10 10 0 0 0 45 50" stroke="black" fill="none"></path>
<path d="M 25 50 A 20 20 0 0 1 65 50" stroke="black" fill="none"></path>
<path d="M 65 50 A 20 20 0 0 0 105 50" stroke="black" fill="none"></path>
<path d="M 105 50 A 25 25 0 0 1 155 50" stroke="black" fill="none"></path>
<path d="M 145 50 A 5 5 0 0 0 155 50" stroke="black" fill="none"></path>
<path d="M 125 50 A 10 10 0 0 1 145 50" stroke="black" fill="none"></path>
<path d="M 125 50 A 20 20 0 0 0 165 50" stroke="black" fill="none"></path>
<path d="M 165 50 A 20 20 0 0 1 205 50" stroke="black" fill="none"></path></svg>
```
<img src="./day1.svg">
