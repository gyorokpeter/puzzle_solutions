# Breakdown
Example input is too long to copy here in full.
```q
x:enlist"on x=-20..26,y=-36..17,z=-47..7"
x,:enlist"on x=-20..33,y=-21..23,z=-26..28"
..
x,:enlist"on x=-54112..-39298,y=-85059..-49293,z=-27449..7877"
x,:enlist"on x=967..23432,y=45373..81175,z=27513..53682"
```

## Part 1
We split the input lines into words:
```q
q)a:" "vs/:x
q)a
"on"  "x=-20..26,y=-36..17,z=-47..7"
"on"  "x=-20..33,y=-21..23,z=-26..28"
"on"  "x=-22..28,y=-29..23,z=-38..16"
..
```
We determine which instruction is "on" by looking at the first word:
```q
q)on:a[;0] like "on"
q)on
1111111111010101010111b
```
We find the positions in the commands by splitting on ",", then on "..":
```q
q)pos:"I"$".."vs/:/:last each/:"="vs/:/:","vs/:last each a
q)pos
-20 26        -36 17        -47 7
-20 33        -21 23        -26 28
-22 28        -29 23        -38 16
...
```
We initialize an array of 101*101*101 booleans to store the state of the cubes:
```q
q)state:101 101 101#0b
```
We shift the positions by 50 such that all valid positions will be from 0 to 101:
```q
q)pos+:50
q)pos
30 76         14 67         3  57
30 83         29 73         24 78
28 78         21 73         12 66
..
```
The instructions will be processed by an iterated function. The function takes three parameters: the
state of the cubes, the type of instruction and the coordinates:
```q
    {[state;on1;pos1]
```
Example for the first iteration:
```q
q)on1:on 0
q)on1
1b
q)pos1:pos 0
q)pos1
30 76
14 67
3  57
```
We take advantage of the fact that q's indexing at depth essentially does "volume indexing": if we
provide a list of indices in each dimension, it will refer to the cross product of those
coordinates.

We generate the affected indices in each dimension:
```q
q)pos1[;1]-pos1[;0]
46 53 54
q)til each 1+pos1[;1]-pos1[;0]
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 ..
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 ..
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 ..
q)ind:pos1[;0]+til each 1+pos1[;1]-pos1[;0]
q)ind
30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62..
14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46..
3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 ..
```
We perform bounds checks to avoid following the instructions from part 2:
```q
    if[any 100<first each ind; :state];
    if[any 0>last each ind; :state];
```
We update the state using [functional amend](https://code.kx.com/q/ref/amend/) and return the
result:
```q
    .[state;ind;:;on1]
```
We iterate this function using `/` (over):
```q
    state:{ ... }/[state;on;pos];
```
After the iteration, we sum all the elements, which requires three calls to `sum`, one for each
dimension:
```q
q)sum sum sum state
590784i
```

## Part 2
**NOTE: this explanation uses the part 2 example from the website**

Input parsing is similar to above:
```q
q)a:" "vs/:x
q)on:a[;0] like "on"
q)pos:"J"$".."vs/:/:last each/:"="vs/:/:","vs/:last each a
q)pos
-5  47         -31 22         -19 33
-44 5          -27 21         -14 35
-49 -1         -11 42         -10 38
..
```
We convert the positions and on/off states to a table. For the end positions we add 1, as many
operations on coordinates are easier if we store the first position after the range rather than the
last position inside it.
```q
q)st:update x2+1, y2+1, z2+1, on from flip`x1`x2`y1`y2`z1`z2!flip raze each pos
q)st
x1      x2     y1      y2     z1      z2     on
-----------------------------------------------
-5      48     -31     23     -19     34     1
-44     6      -27     22     -14     36     1
-49     0      -11     43     -10     39     1
..
```
We generate the distinct set of coordinates on each axis and store them as a list, then update the
table to only store the indices into these lists:
```q
q)xs:exec asc distinct (x1,x2) from st
q)ys:exec asc distinct (y1,y2) from st
q)zs:exec asc distinct (z1,z2) from st
q)xs
`s#-120100 -111166 -110886 -101086 -98497 -98156 -95822 -93533 -89813 -84341 -83015 -77139 -72682 ..
q)ys
`s#-124565 -120233 -108474 -99403 -98693 -89994 -81338 -75520 -72160 -71714 -71013 -65301 -63569 ..
q)zs
`s#-121762 -112280 -105357 -104985 -103788 -99005 -96624 -95368 -91405 -90671 -81239 -75335 -58782..
q)st:update x1:xs?x1, x2:xs?x2, y1:ys?y1, y2:ys?y2, z1:zs?z1, z2:zs?z2 from st
q)st
x1 x2  y1 y2  z1 z2  on
-----------------------
61 69  50 57  44 57  1
54 63  51 56  46 58  1
53 62  52 59  48 59  1
..
```
Next comes the main part of the algorithm, we start with an empty list of cuboids and then add each
one from the list one by one, splitting them whenever they would intersect, such that in the end we
have a list of non-intersecting cuboids. This is done in an iterated function:
```q
    st:{[st1;row] ... st1}/[delete from st;st];
```
The first iteration is not interesting since it only adds a single element to the table, but the
second one is:
```q
q)st1:1#st
q)row:st 1
q)st1
x1 x2 y1 y2 z1 z2 on
--------------------
61 69 50 57 44 57 1
q)row
x1| 54
x2| 63
y1| 51
y2| 56
z1| 46
z2| 58
on| 1b
```
We add a temporary column to the table to indicate which cuboids intersect with the new one we are
trying to add:
```q
q)st1:update intersect:not(x1>=row`x2) or (x2<=row`x1) or (y1>=row`y2) or (y2<=row`y1) or (z1>=row`z2) or (z2<=row`z1) from st1
q)st1
x1 x2 y1 y2 z1 z2 on intersect
------------------------------
61 69 50 57 44 57 1  1
```
We split the table into an intersecting and a non-intersecting part:
```q
q)sti:delete intersect from select from st1 where intersect
q)stn:delete intersect from select from st1 where not intersect
q)sti
x1 x2 y1 y2 z1 z2 on
--------------------
61 69 50 57 44 57 1
q)stn
x1 x2 y1 y2 z1 z2 on
--------------------
```
We find all the possible cut points along all 3 coordinates. These include the coordinates from all
intersecting cuboids as well as the new one:
```q
q)xs1:asc distinct exec (x1,x2,row`x1`x2) from sti
q)ys1:asc distinct exec (y1,y2,row`y1`y2) from sti
q)zs1:asc distinct exec (z1,z2,row`z1`z2) from sti
q)xs1
`s#54 61 63 69
q)ys1
`s#50 51 56 57
q)zs1
`s#44 46 57 58
```
We do the actual splitting in an iterated function. The function takes a the lists of coordinates
on all 3 axes as well as the cuboid we are trying to split:
```q
    splitOn:{[xs1;ys1;zs1;row1]
        ...
    }
```
Here is a demonstration of the `splitOn` function on the example row from `st1`:
```q
q)row1:first st1
q)row1
x1       | 61
x2       | 69
y1       | 50
y2       | 57
z1       | 44
z2       | 57
on       | 1b
intersect| 1b
```
We filter the cut coordinates based on which ones overlap with the coordinates of the cuboid:
```q
q)nxs:xs1 where (xs1>=row1[`x1]) and xs1<=row1[`x2]
q)nys:ys1 where (ys1>=row1[`y1]) and ys1<=row1[`y2]
q)nzs:zs1 where (zs1>=row1[`z1]) and zs1<=row1[`z2]
q)nxs
61 63 69
q)nys
50 51 56 57
q)nzs
44 46 57
```
We generate the coordinates of the smaller cuboids by pairing up the cut coordinates with the next
one in the list:
```q
q)axs:(-1_nxs),'1_nxs
q)ays:(-1_nys),'1_nys
q)azs:(-1_nzs),'1_nzs
q)axs
61 63
63 69
q)ays
50 51
51 56
56 57
q)azs
44 46
46 57
```
We format these coordinates into tables:
```q
q)xt:flip`x1`x2!flip axs
q)yt:flip`y1`y2!flip ays
q)zt:flip`z1`z2!flip azs
q)xt
x1 x2
-----
61 63
63 69
q)yt
y1 y2
-----
50 51
51 56
56 57
q)zt
z1 z2
-----
44 46
46 57
```
We generate the cross product of these tables to get the result of the split, filling back the `on`
field:
```q
q)update on:row1`on from (xt cross yt)cross zt
x1 x2 y1 y2 z1 z2 on
--------------------
61 63 50 51 44 46 1
61 63 50 51 46 57 1
61 63 51 56 44 46 1
61 63 51 56 46 57 1
61 63 56 57 44 46 1
61 63 56 57 46 57 1
63 69 50 51 44 46 1
63 69 50 51 46 57 1
63 69 51 56 44 46 1
63 69 51 56 46 57 1
63 69 56 57 44 46 1
63 69 56 57 46 57 1
```
This is the result of `splitOn`.

We apply `splitOn` to all the existing cuboids as well as the new one, and just prepend the
non-intersecting ones as they don't need splitting:
```q
q)st1:stn,raze splitOn[xs1;ys1;zs1] each sti,row
q)st1
x1 x2 y1 y2 z1 z2 on
--------------------
61 63 50 51 44 46 1
61 63 50 51 46 57 1
61 63 51 56 44 46 1
...
```
At this point we can apply the `off` operations. The splitting ensures that any cuboids that need
to be turned off exactly align with the coordinates of the (also split up) `off` cuboid. We can do
this by grouping the table by the coordinates and checking the last state, and disregarding those
rows where this value is `off`.
```q
q)select last on by x1,x2,y1,y2,z1,z2 from st1
x1 x2 y1 y2 z1 z2| on
-----------------| --
54 61 51 56 46 57| 1
54 61 51 56 57 58| 1
61 63 50 51 44 46| 1
..
q)st1:select from (0!select last on by x1,x2,y1,y2,z1,z2 from st1) where on
q)st1
x1 x2 y1 y2 z1 z2 on
--------------------
54 61 51 56 46 57 1
54 61 51 56 57 58 1
61 63 50 51 44 46 1
..
```
This ends the main iteration function.

After the iteration we end up with a huge list of cuboids, each of which is `on`:
```q
q)st
x1 x2 y1  y2  z1  z2  on
------------------------
0  1  20  27  61  63  1
0  1  20  27  63  65  1
0  1  20  27  65  67  1
..
```
To get the final answer, we map these back to the original coordinates and multiply the sizes in the
three dimensions together, followed by summing them:
```q
q)exec sum(xs[x2]-xs[x1])*(ys[y2]-ys[y1])*(zs[z2]-zs[z1]) from st
2758514936282235
```
