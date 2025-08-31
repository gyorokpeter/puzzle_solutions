# Breakdown
Example input:
```q
x:()
x,:enlist"sesenwnenenewseeswwswswwnenewsewsw"
x,:enlist"neeenesenwnwwswnenewnwwsewnenwseswesw"
x,:enlist"seswneswswsenwwnwse"
x,:enlist"nwnwneseeswswnenewneswwnewseswneseene"
x,:enlist"swweswneswnenwsewnwneneseenw"
x,:enlist"eesenwseswswnenwswnwnwsewwnwsene"
x,:enlist"sewnenenenesenwsewnenwwwse"
x,:enlist"wenwwweseeeweswwwnwwe"
x,:enlist"wsweesenenewnwwnwsenewsenwwsesesenwne"
x,:enlist"neeswseenwwswnwswswnw"
x,:enlist"nenwswwsewswnenenewsenwsenwnesesenew"
x,:enlist"enewnwewneswsewnwswenweswnenwsenwsw"
x,:enlist"sweneswneswneneenwnewenewwneswswnese"
x,:enlist"swwesenesewenwneswnwwneseswwne"
x,:enlist"enesenwswwswneneswsenwnewswseenwsese"
x,:enlist"wnwnesenesenenwwnenwsewesewsesesew"
x,:enlist"nenewswnwewswnenesenwnesewesw"
x,:enlist"eneswnwswnwsenenwnwnwwseeswneewsenese"
x,:enlist"neswnwewnwnwseenwseesewsenwsweewe"
x,:enlist"wseweeenwnesenwwwswnew"
```

## Common
To represent a hexagonal grid we use the standard coordinate system but with the y axis tilted to
the left, so positive y becomes `"nw"` and negative y becomes `"se"`.

We use `ssr` to replace the direction indicators with numbers ranging from 0 to 5 for easier
handling. Using `ssr` with `over` and lists of replacements is a common pattern. Note that the
two-letter directions come first to avoid chopping them in half by replacing the single-letter ones.
```q
q)ssr/[;("ne";"nw";"sw";"se";"e";"w");"124503"]each x
"55211135043443113534"
"1001522341132353125404"
"5414452325"
"221504411314313541501"
..
```
Since this is still in characters, we convert them to integers. Note that `"J"$` would convert the
whole strings, so we need to use it with `/:` (each-right) to convert the individual characters -
twice, because the list has a depth of 2.
```q
"353000215233413"
q)ins:"J"$/:/:ssr/[;("ne";"nw";"sw";"se";"e";"w");"124503"]each x
q)ins
5 5 2 1 1 1 3 5 0 4 3 4 4 3 1 1 3 5 3 4
1 0 0 1 5 2 2 3 4 1 1 3 2 3 5 3 1 2 5 4 0 4
5 4 1 4 4 5 2 3 2 5
2 2 1 5 0 4 4 1 1 3 1 4 3 1 3 5 4 1 5 0 1
..
```
We assign a pair of integers representing the deltas of the x and y coordinates for each direction.
To trace the path, we index into this list with the instructions and sum the deltas, resulting in
the final coordinates.
```q
q)(1 0;1 1;0 1;-1 0;-1 -1;0 -1)ins
(0 -1;0 -1;0 1;1 1;1 1;1 1;-1 0;0 -1;1 0;-1 -1;-1 0;-1 -1;-1 -1;-1 0;1 1;1 1;-1 0;0 -1;-1 0;-1 -1)
(1 1;1 0;1 0;1 1;0 -1;0 1;0 1;-1 0;-1 -1;1 1;1 1;-1 0;0 1;-1 0;0 -1;-1 0;1 1;0 1;0 -1;-1 -1;1 0;-1..
(0 -1;-1 -1;1 1;-1 -1;-1 -1;0 -1;0 1;-1 0;0 1;0 -1)
(0 1;0 1;1 1;0 -1;1 0;-1 -1;-1 -1;1 1;1 1;-1 0;1 1;-1 -1;-1 0;1 1;-1 0;0 -1;-1 -1;1 1;0 -1;1 0
..
q)sum each(1 0;1 1;0 1;-1 0;-1 -1;0 -1)ins
-3 -2
1  3
-3 -3
2  2
..
```
To find which tile is touched an odd number of times, we group the final tile coordinates and find
which groups have element counts that give 1 modulo 2.
```q
q)count each group sum each(1 0;1 1;0 1;-1 0;-1 -1;0 -1)ins
-3 -2| 1
1  3 | 2
-3 -3| 1
2  2 | 2
1  2 | 2
-1 0 | 2
..
q)where 1=(count each group sum each(1 0;1 1;0 1;-1 0;-1 -1;0 -1)ins)mod 2
-3 -2
-3 -3
-2 0
0  1
-2 -1
..
```

## Part 1
We count the number of tiles returned by the above (wrapped in the function `d24`).
```q
q)count d24 x
10
```

## Part 2
We store the tiles from the common function:
```q
q)c:d24 x
q)c
-3 -2
-3 -3
-2 0
0  1
..
```
We perform an iteration similar to day 17.

Inside the iteration, we first generate the neighbors for each tile by adding the deltas to each of
the coordinate pairs:
```q
q)(1 0;1 1;0 1;-1 0;-1 -1;0 -1)+/:\:c
-2 -2 -2 -3 -1 0  1  1  -1 -1 4  3  1  -2 1  0  3  0  0  1
-2 -1 -2 -2 -1 1  1  2  -1 0  4  4  1  -1 1  1  3  1  0  2
-3 -1 -3 -2 -2 1  0  2  -2 0  3  4  0  -1 0  1  2  1  -1 2
-4 -2 -4 -3 -3 0  -1 1  -3 -1 2  3  -1 -2 -1 0  1  0  -2 1
-4 -3 -4 -4 -3 -1 -1 0  -3 -2 2  2  -1 -3 -1 -1 1  -1 -2 0
-3 -3 -3 -4 -2 -1 0  0  -2 -2 3  2  0  -3 0  -1 2  -1 -1 0
q)nb:raze(1 0;1 1;0 1;-1 0;-1 -1;0 -1)+/:\:c
q)nb
-2 -2
-2 -3
-1 0
1  1
-1 -1
..
```
We group the coordinates and count them to find the neighbor counts:
```q
q)nbs:count each group nb
q)nbs
-2 -2| 3
-2 -3| 1
-1 0 | 5
1  1 | 2
-1 -1| 2
..
```
We keep the coordinates where the neighbor count is 1 or 2, and where the neighbor count is 2 if
it was not in the original set of coordinates:
```q
q)c inter where nbs within 1 2
-3 -2
-3 -3
-2 0
0  1
-2 -1
0  0
-1 1
q)(where 2=nbs) except c
1  1
-1 -1
1  0
1  -1
0  2
-2 1
0  -1
-4 -3
q)(c inter where nbs within 1 2) union ((where 2=nbs) except c)
-3 -2
-3 -3
-2 0
0  1
-2 -1
..
```
We iterate this 100 times to get the final set of coordinates:
```q
    st:{[c]
        ...
    }/[100;c];
```
After the iteration, we have the final coordinate list. We count it to get the answer.
```q
q)(c inter where nbs within 1 2) union ((where 2=nbs) except c)
-3 -2
-3 -3
-2 0
0  1
-2 -1
0  0
-1 1
1  1
-1 -1
1  0
1  -1
0  2
-2 1
0  -1
-4 -3
q)st
6   -21
3   -22
-20 -4
-32 -16
-10 -6
..
q)count st
2208
```
