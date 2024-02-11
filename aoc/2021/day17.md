# Breakdown
Example input:
```q
x:"target area: x=20..30, y=-10..-5"
```

## Common
The idea is to generate the x and y coordinates independently, filter them based on whether they hit
the target area, and then generate every possible pairing and determine if the combination also
hits.

We extract the target coordinates from the input:
```q
q)a:"J"$".."vs/:last each "="vs/:2_" "vs x except",";
q)a
20  30
-10 -5
```
We reject the cases when the area starts left of or above the starting position:
```q
q)if[(a[0;0]<=0) or a[1;1]>=0; '"nyi"];
```
We generate all possible horizontal speeds where the probe won't overshoot the target area on the
first step:
```q
q)xs:1+til a[0;1];
q)xs
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
```
For each speed, we generate all the x coordinates that the probe will hit. This is done by taking
the partial sums counting down from the starting speed to zero - the reverse of what `til`
generates. We also prepend the x coordinate of zero which is the same for all starting speeds.
```q
q)xss:{0,sums reverse 1+til x}each xs;
q)xss
0 1
0 2 3
0 3 5 6
0 4 7 9 10
0 5 9 12 14 15
0 6 11 15 18 20 21
0 7 13 18 22 25 27 28
..
```
We find the indices of which speeds cause at least one coordinate to be within the horizontal bounds
of the target area:
```q
q)xsi:where any each xss within a[0];
q)xsi
5 6 7 8 9 10 11 12 13 14 19 20 21 22 23 24 25 26 27 28 29
```
We use indexing to filter both the speed and coordinate lists:
```q
q)xs2:xs xsi;
q)xs2
6 7 8 9 10 11 12 13 14 15 20 21 22 23 24 25 26 27 28 29 30
q)xss2:xss xsi;
q)xss2
0 6 11 15 18 20 21
0 7 13 18 22 25 27 28
0 8 15 21 26 30 33 35 36
0 9 17 24 30 35 39 42 44 45
0 10 19 27 34 40 45 49 52 54 55
0 11 21 30 38 45 51 56 60 63 65 66
..
```
We generate the vertical speeds. If the initial velocity is positive, the trajectory will have a
symmetric non-negative section before returning to zero, and the first negative value will be one
higher than the starting velocity.
```q
q)ys:a[1;0]+til 2*abs a[1;0];
q)ys
-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9
```
For the y coordinates, we can't use `til` and `sums` like before, since the vertical speed keeps
increasing forever. Instead we use an iterated function that stops once we pass the end of the
target area, keeping track of both the position and speed during iteration.
```q
q)2024.06.02D18:11:43.076925000 radio1: 0/32
yss:{[lim;y]first each{[lim;yv]$[yv[0]<lim;yv;(yv[0]+yv[1];yv[1]-1)]}[lim]\[(0;y)]}[a[1;0]]each ys;
q)yss
0 -10 -21
0 -9 -19
0 -8 -17
0 -7 -15
0 -6 -13
0 -5 -11
0 -4 -9 -15
..
```
We filter the vertical speeds and coordinates the same way as for the horizontal ones:
```q
q)ysi:where any each yss within a[1];
q)ysi
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
q)ys2:ys ysi;
q)ys2
-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9
q)yss2:yss ysi;
q)yss2
0 -10 -21
0 -9 -19
0 -8 -17
0 -7 -15
0 -6 -13
0 -5 -11
0 -4 -9 -15
..
```
Until now we have generated the two coordinates independently, now it is time to combine them. We
will use a function for this that will take two parameters. The first is the target area (only
because q doesn't have nested scopes for variables), the second is a dictionary of the properties
we want to match up. This dictionary will have 4 elements: `xv` and `yv` for the velocities and `xs`
and `ys` for the coordinate lists.
```q
    f:{[a;r]
        ...
        }[a];
```
First we need to make sure that the two coordinate lists are the same length. This is driven by the
length of the y coordinate list. If there are too many x coordinates, we cut back the x coordinate
list. If there are not enough, we repeat the last x coordinate the necessary number of times.
```q
    xs:(min[count each r`xs`ys]#r`xs),(0|count[r`ys]-count[r`xs])#last r`xs;
```
We concatenate the x and y coordinates pairwise to form coordinate pairs:
```q
    pos:xs,'r`ys;
```
We check if any position is within the target area. If not, we return an empty list:
```q
    if[not any all each pos within'\: a; :()];
```
Otherwise we return a one-row table containing the velocities and the highest position reached:
```q
    enlist`xv`yv`pos!(r`xv;r`yv;max pos[;1])
```
This choice of return values is because then we can `raze` together the results of calling the
function with `each`. Misses will return empty lists and hits will return one-row tables, so the
`raze` will return a table with one row for each hit.

We call this function on the cross product of the x and y velocity/coordinate lists. It is easiest
to make two tables with two columns each, one with `xs2` and `xss2`, and one with `ys2` and `yss2`.
This way the `cross` operator will correctly combine the values into a 4-column table, and calling
`f` with `each` on this table will pass in each record as a dictionary.
```q
q)shots:raze f each([]xv:xs2;xs:xss2)cross([]yv:ys2;ys:yss2);
q)shots
xv yv  pos
----------
6  0   0
6  1   1
6  2   3
6  3   6
6  4   10
6  5   15
..
```
The answer to part 1 is the highest `pos` in this table:
```q
q)exec max pos from shots
45
```
The answer to part 2 is the count of this table:
```q
q)count shots
112
```
