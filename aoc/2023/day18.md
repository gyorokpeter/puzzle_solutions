# Breakdown

Example input:
```q
x:();
x,:enlist"R 6 (#70c710)";
x,:enlist"D 5 (#0dc571)";
x,:enlist"L 2 (#5713f0)";
x,:enlist"D 2 (#d2c081)";
x,:enlist"R 2 (#59c680)";
x,:enlist"D 2 (#411b91)";
x,:enlist"L 5 (#8ceee2)";
x,:enlist"U 2 (#caa173)";
x,:enlist"L 1 (#1b58a2)";
x,:enlist"U 2 (#caa171)";
x,:enlist"R 2 (#7807d2)";
x,:enlist"U 3 (#a77fa3)";
x,:enlist"L 2 (#015232)";
x,:enlist"U 2 (#7a21e3)";
```

## Common
The common logic (`d18`) expects a single argument that is a list of instructions formatted as pairs of symbols (one of ``` `R`L`U`D ```) and numbers.
```q
q)ins
`R 461937
`D 56407
`R 356671
`D 863240
`R 367720
`D 266681
`L 577262
`U 829975
`L 112010
`D 829975
`L 491645
`U 686074
`L 5411
`U 500254
```
We convert the instructions into coordinate deltas:
```q
q)pd:ins[;1]*(`U`R`D`L!(-1 0;0 1;1 0;0 -1))ins[;0]
q)pd
0       461937
56407   0
0       356671
863240  0
0       367720
266681  0
0       -577262
-829975 0
0       -112010
829975  0
0       -491645
-686074 0
0       -5411
-500254 0
```
We calculate the partial sums to find the vertices of the path:
```q
q)path
0       0
0       461937
56407   461937
56407   818608
919647  818608
919647  1186328
1186328 1186328
1186328 609066
356353  609066
356353  497056
1186328 497056
1186328 5411
500254  5411
500254  0
0       0
```
Next we want to draw the path on a matrix, but its size would be too large. Instead we squeeze the coordinates such that their relative order remains the same but their magnitude is reduced to a minimum. It is not enough to just thake the distinct values of the coordinate and number them starting from 0, because once we draw the path on the map we lose the information on where we turn on each corner and whether the area between two parallel edges is inside the path or not. This is similar to the "squeak through" problem of day 10. We can avoid this by inserting extra coordinates in between the ones that actually occur in the path, such as by adding 1 to each coordinate.
```q
squeeze:{distinct asc x,(x+1)}
xm:squeeze path[;1]
ym:squeeze path[;0]
q)xm
`s#0 1 5411 5412 461937 461938 497056 497057 609066 609067 818608 818609 1186..
q)ym
`s#0 1 56407 56408 356353 356354 500254 500255 919647 919648 1186328 1186329
```
Based on these lists of coordinates, we simplify the path:
```q
q)path2
0  0
0  4
2  4
2  10
8  10
8  12
10 12
10 8
4  8
4  6
10 6
10 2
6  2
6  0
0  0
```
We fill in the path such that each move only changes the coordinates by one. Note that the summing must start with `0 0` to properly handle the scenario where the path doesn't start in the top left.
```q
q)path3:sums enlist[0 0],raze{c:max abs x;c#enlist x div c}each 1_deltas path2
q)path3
0 0
0 1
0 2
0 3
0 4
1 4
2 4
2 5
2 6
2 7
2 8
2 9
2 10
3 10
4 10
5 10
6 10
7 10
8 10
8 11
8 12
9 12
..
```
Since this results in the path starting in position `0 0`, we recalibrate the path by subtracting the minimum of each coordinate, so `0 0` becomes top left:
```q
path3:path3-\:min path3
```
We create an empty map with a 1-tile border, so the size is 3 higher than the maximum of the respective coordinate, then we draw the path on the map:
```q
q)map:.[;;:;"#"]/[(3+max path3)#" ";1+path3]
q)map
"               "
" #####         "
" #   #         "
" #   #######   "
" #         #   "
" #     ### #   "
" #     # # #   "
" ###   # # #   "
"   #   # # #   "
"   #   # # ### "
"   #   # #   # "
"   ##### ##### "
"               "
```
We use a BFS to fill the empty space around the edge. This is similar to day 10 but a bit simpler:
```q
queue:enlist 0 0;
while[count queue;
    map:.[;;:;"o"]/[map;queue];
    nxts:distinct raze queue+/:\:(-1 0;0 1;1 0;0 -1);
    nxts:nxts where all each nxts within'\:(0,count[map]-1;0,count[map 0]-1);
    nxts:nxts where" "=map ./:nxts;
    queue:nxts;
]
q)map
"ooooooooooooooo"
"o#####ooooooooo"
"o#   #ooooooooo"
"o#   #######ooo"
"o#         #ooo"
"o#     ### #ooo"
"o#     #o# #ooo"
"o###   #o# #ooo"
"ooo#   #o# #ooo"
"ooo#   #o# ###o"
"ooo#   #o#   #o"
"ooo#####o#####o"
"ooooooooooooooo"
```
We find the coordinates of the dug out tiles by looking for any empty or `#` tiles:
```q
q)tiles:raze til[count map],/:'where each map in" #"
q)tiles
1 1
1 2
1 3
1 4
1 5
2 1
2 2
2 3
2 4
2 5
3 1
3 2
3 3
3 4
3 5
3 6
3 7
3 8
3 9
3 10
3 11
4 1
..
```
These are the squeezed coordinates - to find the area covered by each tile, we have to look up the corresponding value in the deltas of the squeeze map (since we added the empty row on the left and top, the tiles in the result actually start from `1 1`, but this is convenient as the first element of `deltas` is just the first element of the list, which we would have had to skip anyway).
```q
q)deltas[ym][tiles[;0]]*deltas[xm][tiles[;1]]
1 5410 1 456525 1 56406 305156460 56406 25750749150 56406 1 5410 1 456525 1 3..
q)sum deltas[ym][tiles[;0]]*deltas[xm][tiles[;1]]
952408144115
```

## Part 1
To generate the instructions in the format expected by `d18`, we split on `" "` and cast the first elements to symbol and the second to long. We ignore the third elements.
```q
q)"SJ"$/:(" "vs/:x)[;0 1]
`R 6
`D 5
`L 2
`D 2
`R 2
`D 2
`L 5
`U 2
`L 1
`U 2
`R 2
`U 3
`L 2
`U 2
q)d18"SJ"$/:(" "vs/:x)[;0 1]
62
```

## Part 2
To generate the instructions in the format expected by `d18`, we split on `" "`, keep only the last elements, then drop the last and first two characters. We map the last character to a direction and cast the first five characters to bytes (the only type that is parsed as hexadecimal) and put them together using the base-joining feature of `sv`.
```q
q)a:2_/:-1_/:last each" "vs/:x
q)a
"70c710"
"0dc571"
"5713f0"
"d2c081"
"59c680"
"411b91"
"8ceee2"
"caa173"
"1b58a2"
"caa171"
"7807d2"
"a77fa3"
"015232"
"7a21e3"
q)`$/:"RDLU""J"$/:last each a
`R`D`R`D`R`D`L`U`L`D`L`U`L`U
q)"X"$/:/:-1_/:a
0x07000c0701
0x000d0c0507
0x050701030f
0x0d020c0008
0x05090c0608
0x0401010b09
0x080c0e0e0e
0x0c0a0a0107
0x010b05080a
0x0c0a0a0107
0x070800070d
0x0a07070f0a
0x0001050203
0x070a02010e
q)16 sv/:"X"$/:/:-1_/:a
461937 56407 356671 863240 367720 266681 577262 829975 112010 829975 491645 6..
q)(`$/:"RDLU""J"$/:last each a),'16 sv/:"X"$/:/:-1_/:a
`R 461937
`D 56407
`R 356671
`D 863240
`R 367720
`D 266681
`L 577262
`U 829975
`L 112010
`D 829975
`L 491645
`U 686074
`L 5411
`U 500254
q)d18(`$/:"RDLU""J"$/:last each a),'16 sv/:"X"$/:/:-1_/:a
952408144115
```
