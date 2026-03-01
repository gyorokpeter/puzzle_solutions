# Breakdown
Example input:
```q
x:"\n"vs"depth: 510\ntarget: 10,10"
```

## Common
We use a helper function (`d22genMap` to generate the map. This function takes the depth, target
coordinates, width and height as parameters.
```q
q)d:510
q)tgt:10 10
q)w:16
q)h:16
```
The terms the puzzle uses are confusing (like "erosion level" and "geologic index") so here are just
the calculations, which generally involve using iterated functions with a modulo addition inside:

Iterating a modulo addition from 0:
```q
q)top:({(x+16807)mod 20183}\[w-1;0]+d)mod 20183
q)top
510 17317 13941 10565 7189 3813 437 17244 13868 10492 7116 3740 364 17171 13795 10419
```
Iterating a function to generate rows, the first element derived from the first element of the
previous row and the rest of the elements with another iteration:
```q
q)er:{[d;x]s:(x[0]+48271)mod 20183;s,{[d;x;y](d+x*y)mod 20183}[d]\[s;1_x]}[d]\[h-1;top]
q)er
510   17317 13941 10565 7189  3813  437   17244 13868 10492 7116  3740  364   17171 13795 10419
8415  1805  15997 16556 2443  11306 16580 13835 4692  2637  15395 15894 13588 4578  1413  9150
16320 11113 3307  14906 5736  3747  2496  19740 803   18989 5593  9720  18501 10220 10525 11167
4042  12081 10220 18729 16128 4224  8088  10100 17427 1345  15019 1551  15518 16639 18277 9273
11947 3584  17028 6339  9007  1123  984   8874  5562  13690 6399  15506 892   7993  4017  12516
19852 5003  19334 7560  16171 16026 7171  19148 16178 9271  7802  1420  15804 16668 8855  4837
7574  9741  5431  6648  10660 8758  14815 6065  10517 19727 15189 13446 14470 19803 6171  19163
15479 14439 7764  7651  667   9209  14948 18277 17010 14405 14335 1270  10880 3625  7621  17728
3201  679   4503  582   5227  19681 4690  2439  11835 18067 2699  17313 18194 15899 8240  14859
11106 13225 12835 2770  8089  16798 8881  4910  3503  15506 11845 13715 8791  1344  14786 13729
19011 1354  1537  19570 6971  17785 17120 17698 14611 4501  11552 19823 4481  8440  2861  3061
6733  14459 2510  15971 4923  2211  9705  2270  6811  19027 7544  9375  9062  10403 13751 10766
14638 12414 17281 13019 12022 141   16654 2331  13113 19498 19901 733   2749  19229 1006  13018
2360  12017 3400  3791  2698  17634 14496 4344  6956  19021 5266  5535  18426 1499  14962 9876
10265 16702 12531 14932 1778  9563  8914  11932 7006  13470 10468 15680 545   10145 13840 5074
18170 4262  3414  16283 9262  10012 18435 12596 8010  17075 962   7969  4270  6942  6710  18512
```
Override at the target location:
```q
q)er[tgt 1;tgt 0]:d mod 20183
q)er
510   17317 13941 10565 7189  3813  437   17244 13868 10492 7116  3740  364   17171 13795 10419
8415  1805  15997 16556 2443  11306 16580 13835 4692  2637  15395 15894 13588 4578  1413  9150
16320 11113 3307  14906 5736  3747  2496  19740 803   18989 5593  9720  18501 10220 10525 11167
4042  12081 10220 18729 16128 4224  8088  10100 17427 1345  15019 1551  15518 16639 18277 9273
11947 3584  17028 6339  9007  1123  984   8874  5562  13690 6399  15506 892   7993  4017  12516
19852 5003  19334 7560  16171 16026 7171  19148 16178 9271  7802  1420  15804 16668 8855  4837
7574  9741  5431  6648  10660 8758  14815 6065  10517 19727 15189 13446 14470 19803 6171  19163
15479 14439 7764  7651  667   9209  14948 18277 17010 14405 14335 1270  10880 3625  7621  17728
3201  679   4503  582   5227  19681 4690  2439  11835 18067 2699  17313 18194 15899 8240  14859
11106 13225 12835 2770  8089  16798 8881  4910  3503  15506 11845 13715 8791  1344  14786 13729
19011 1354  1537  19570 6971  17785 17120 17698 14611 4501  510   19823 4481  8440  2861  3061
6733  14459 2510  15971 4923  2211  9705  2270  6811  19027 7544  9375  9062  10403 13751 10766
14638 12414 17281 13019 12022 141   16654 2331  13113 19498 19901 733   2749  19229 1006  13018
2360  12017 3400  3791  2698  17634 14496 4344  6956  19021 5266  5535  18426 1499  14962 9876
10265 16702 12531 14932 1778  9563  8914  11932 7006  13470 10468 15680 545   10145 13840 5074
18170 4262  3414  16283 9262  10012 18435 12596 8010  17075 962   7969  4270  6942  6710  18512
```
The forced value at the target location messes with the recursive formula, since it will be based on
the overridden value rather than the original. Therefore we take the part of the row above the
target from the target's column until the end:
```q
q)bbef:tgt[0]_er tgt[1]-1
q)bbef
11845 13715 8791 1344 14786 13729
```
We generate the rest of the row starting with the target:
```q
q)btop:(d mod 20183),{[d;x;y](d+x*y)mod 20183}[d]\[(d mod 20183);1_bbef]
q)btop
510 11842 19801 11860 12566 15023
```
We take the rest of the column before the target, starting from the row below the target:
```q
q)bleft:first each(tgt[0]-1)_/:(1+tgt[1])_er
q)bleft
19027 19498 19021 13470 17075
```
We use these values to recalculate the rectangle in the matrix between the target and the bottom
right corner:
```q
q)ber:enlist[btop],{[d;x;s]{[d;x;y](d+x*y)mod 20183}[d]\[s;x]}[d]\[btop;bleft]
q)ber
510   11842 19801 11860 12566 15023
16440 17955 3920  10261 11232 8966
1224  18326 7133  8665  3364  8732
11215 3111  10156 4370  7966  9004
16988 11084 9023  13621 1588  9298
534   5747  5564  589   7424  3002
```
We splice this together with the original matrix:
```q
q)er2:(tgt[1]#er),(tgt[0]#/:(tgt[1]_er)),'ber
q)er2
510   17317 13941 10565 7189  3813  437   17244 13868 10492 7116  3740  364   17171 13795 10419
8415  1805  15997 16556 2443  11306 16580 13835 4692  2637  15395 15894 13588 4578  1413  9150
16320 11113 3307  14906 5736  3747  2496  19740 803   18989 5593  9720  18501 10220 10525 11167
4042  12081 10220 18729 16128 4224  8088  10100 17427 1345  15019 1551  15518 16639 18277 9273
11947 3584  17028 6339  9007  1123  984   8874  5562  13690 6399  15506 892   7993  4017  12516
19852 5003  19334 7560  16171 16026 7171  19148 16178 9271  7802  1420  15804 16668 8855  4837
7574  9741  5431  6648  10660 8758  14815 6065  10517 19727 15189 13446 14470 19803 6171  19163
15479 14439 7764  7651  667   9209  14948 18277 17010 14405 14335 1270  10880 3625  7621  17728
3201  679   4503  582   5227  19681 4690  2439  11835 18067 2699  17313 18194 15899 8240  14859
11106 13225 12835 2770  8089  16798 8881  4910  3503  15506 11845 13715 8791  1344  14786 13729
19011 1354  1537  19570 6971  17785 17120 17698 14611 4501  510   11842 19801 11860 12566 15023
6733  14459 2510  15971 4923  2211  9705  2270  6811  19027 16440 17955 3920  10261 11232 8966
14638 12414 17281 13019 12022 141   16654 2331  13113 19498 1224  18326 7133  8665  3364  8732
2360  12017 3400  3791  2698  17634 14496 4344  6956  19021 11215 3111  10156 4370  7966  9004
10265 16702 12531 14932 1778  9563  8914  11932 7006  13470 16988 11084 9023  13621 1588  9298
18170 4262  3414  16283 9262  10012 18435 12596 8010  17075 534   5747  5564  589   7424  3002
```
The return value is this matrix modulo 3:
```q
q)er2 mod 3
0 1 0 2 1 0 2 0 2 1 0 2 1 2 1 0
0 2 1 2 1 2 2 2 0 0 2 0 1 0 0 0
0 1 1 2 0 0 0 0 2 2 1 0 0 2 1 1
1 0 2 0 0 0 0 2 0 1 1 0 2 1 1 0
1 2 0 0 1 1 0 0 0 1 0 2 1 1 0 0
1 2 2 0 1 0 1 2 2 1 2 1 0 0 2 1
2 0 1 0 1 1 1 2 2 2 0 0 1 0 0 2
2 0 0 1 1 2 2 1 0 2 1 1 2 1 1 1
0 1 0 0 1 1 1 0 0 1 2 0 2 2 2 0
0 1 1 1 1 1 1 2 2 2 1 2 1 0 2 1
0 1 1 1 2 1 2 1 1 1 0 1 1 1 2 2
1 2 2 2 0 0 0 2 1 1 0 0 2 1 0 2
1 0 1 2 1 0 1 0 0 1 0 2 2 1 1 2
2 2 1 2 1 0 0 0 2 1 1 0 1 2 1 1
2 1 0 1 2 2 1 1 1 0 2 2 2 1 1 1
2 2 0 2 1 1 0 2 0 2 0 2 2 1 2 2
```
Or using the puzzle's notation:
```q
q)-1".=|"er2 mod 3;
.=.|=.|.|=.|=|=.
.|=|=|||..|.=...
.==|....||=..|==
=.|....|.==.|==.
=|..==...=.|==..
=||.=.=||=|=..|=
|.=.===|||..=..|
|..==||=.|==|===
.=..===..=|.|||.
.======|||=|=.|=
.===|=|===.===||
=|||...|==..|=.|
=.=|=.=..=.||==|
||=|=...|==.=|==
|=.=||===.|||===
||.|==.|.|.||=||
```

## Part 1
We parse the useful numbers out of the input:
```q
q)d:"J"$last" "vs x[0]
q)d
510
q)tgt:"J"$","vs last" "vs x[1]
q)tgt
10 10
```
We set the map width and height to one higher than the target location:
```q
q)w:1+tgt 0
q)h:1+tgt 1
q)w,h
11 11
```
We generate the map using the helper function:
```q
q)map:d22genMap[d;tgt;w;h]
q)map
0 1 0 2 1 0 2 0 2 1 0
0 2 1 2 1 2 2 2 0 0 2
0 1 1 2 0 0 0 0 2 2 1
1 0 2 0 0 0 0 2 0 1 1
1 2 0 0 1 1 0 0 0 1 0
1 2 2 0 1 0 1 2 2 1 2
2 0 1 0 1 1 1 2 2 2 0
2 0 0 1 1 2 2 1 0 2 1
0 1 0 0 1 1 1 0 0 1 2
0 1 1 1 1 1 1 2 2 2 1
0 1 1 1 2 1 2 1 1 1 0
```
The answer is the sum of the matrix:
```q
q)sum sum map
114
```

## Part 2
The path search is a vectorized A\* algorithm. The queue node includes the position and tool,
and switching tools is among the possibilities of expanding a node. Due to the difference of cost
between moving and switching tools, standard BFS can't be used here.

We parse the input and create a map that has 10 extra tiles after the target (this is a guess - it
must be greater than zero such that paths can go beyond the target, but it shouldn't be too large).
```q
q)d:"J"$last" "vs x[0]
q)tgt:"J"$","vs last" "vs x[1]
q)w:10+tgt 0
q)h:10+tgt 1
q)w,h
20 20
q)map:d22genMap[d;tgt;w;h]
q)map
0 1 0 2 1 0 2 0 2 1 0 2 1 2 1 0 2 1 0 1
0 2 1 2 1 2 2 2 0 0 2 0 1 0 0 0 0 1 1 0
0 1 1 2 0 0 0 0 2 2 1 0 0 2 1 1 0 2 2 0
1 0 2 0 0 0 0 2 0 1 1 0 2 1 1 0 0 1 2 1
1 2 0 0 1 1 0 0 0 1 0 2 1 1 0 0 1 1 2 2
1 2 2 0 1 0 1 2 2 1 2 1 0 0 2 1 2 1 2 0
2 0 1 0 1 1 1 2 2 2 0 0 1 0 0 2 2 2 2 1
2 0 0 1 1 2 2 1 0 2 1 1 2 1 1 1 1 2 0 1
0 1 0 0 1 1 1 0 0 1 2 0 2 2 2 0 2 1 0 0
0 1 1 1 1 1 1 2 2 2 1 2 1 0 2 1 2 2 1 2
0 1 1 1 2 1 2 1 1 1 0 1 1 1 2 2 1 0 1 2
1 2 2 2 0 0 0 2 1 1 0 0 2 1 0 2 0 1 0 0
1 0 1 2 1 0 1 0 0 1 0 2 2 1 1 2 2 2 2 1
2 2 1 2 1 0 0 0 2 1 1 0 1 2 1 1 1 1 2 1
2 1 0 1 2 2 1 1 1 0 2 2 2 1 1 1 0 1 0 1
2 2 0 2 1 1 0 2 0 2 0 2 2 1 2 2 1 0 2 2
0 2 0 2 0 0 2 2 2 2 2 1 0 1 0 0 1 2 1 0
0 1 2 2 0 2 1 2 0 0 2 1 2 1 1 1 0 2 1 2
1 0 0 0 2 2 0 1 2 0 0 0 0 0 1 0 2 0 0 2
1 0 2 1 0 1 1 1 0 0 0 0 1 0 0 2 2 1 2 0
```
We create a fully materialized visited array, which has 3 dimensions due to the tool also being part
of the state:
```q
q)visited:(3;w;h)#0b
q)visited
00000000000000000000b 00000000000000000000b 00000000000000000000b 00000000000000000000b 0000000000..
00000000000000000000b 00000000000000000000b 00000000000000000000b 00000000000000000000b 0000000000..
00000000000000000000b 00000000000000000000b 00000000000000000000b 00000000000000000000b 0000000000..
```
We initialize the queue with a single node at the start position with zero time taken:
```q
q)queue:enlist`x`y`tool`time!0 0 1 0
q)queue
x y tool time
-------------
0 0 1    0
```
We iterate as long as ther are items in the queue. Running out of items is an error.
```q
    while[0<count queue;
        ...
    ];
    '"stuck";
```
In the iteration, we get the estimated path lengths from each node by adding the Manhattan distance
to the target, ignoring the needed tool changes:
```q
q)f:exec time+abs[tgt[1]-x]+abs[tgt[0]-y] from queue
q)f
,20
```
We extract the items from the queue where this value is minimal:
```q
q)nxt:select from queue where f=min f
q)nxt
x y tool time
-------------
0 0 1    0
```
We provide for the chance that the path will go off the map. So if there is a node on the right or
bottom edge, we double the width or height, regenerate the map, and also expand the visited array
accordingly:
```q
    if[(exec max x from nxt)>=count[first map]-1; visited:visited,\:(w;h)#0b; w*:2; map:d22genMap[d;tgt;w;h]];
    if[(exec max y from nxt)>=count[map]-1; h*:2; visited:visited,\:\:h#0b; map:d22genMap[d;tgt;w;h]];
```
We check if there are any nodes at the target coordinates with the correct tool:
```q
q)goal:select from nxt where x=tgt[0], y=tgt[1], tool=1
q)goal
x y tool time
-------------
```
If there is one, we return the one with the lowest time:
```q
    if[0<count goal; :exec min time from goal]
```
We delete the selected nodes from the queue:
```q
q)queue:delete from queue where f=min f
q)queue
x y tool time
-------------
```
We mark the selected nodes as visited:
```q
q)visited:.[;;:;1b]/[visited;(;;)'[nxt`tool;nxt`x;nxt`y]]
q)visited
00000000000000000000b 00000000000000000000b 00000000000000000000b 00000000000000000000b 0000000000..
10000000000000000000b 00000000000000000000b 00000000000000000000b 00000000000000000000b 0000000000..
00000000000000000000b 00000000000000000000b 00000000000000000000b 00000000000000000000b 0000000000..
```
We expand each node by performing moves in all four directions as well as switching tools:
```q
    nxt2:raze{[map;node]
        ([]x:node[`x]+0 0 1 -1 0;y:node[`y]+1 -1 0 0 0;tool:(4#node[`tool]),0 1 2 except map[node[`y];node[`x]],node[`tool];time:node[`time]+1 1 1 1 7)
    }[map]each nxt;

q)nxt2
x  y  tool time
---------------
0  1  1    1
0  -1 1    1
1  0  1    1
-1 0  1    1
0  0  2    7
```
We filter out nodes that are off the top or left of the map, have the wrong tool for the target
tile, or are marked as visited:
```q
q)nxt3:select from nxt2 where x>=0, y>=0, tool<>map'[y;x], not .[visited]'[(;;)'[tool;x;y]]
q)nxt3
x y tool time
-------------
0 1 1    1
0 0 2    7
```
We update the queue by adding the new nodes and only keeping those with the shortest time for a
position/tool combination:
```q
q)queue:0!select min time by x,y,tool from queue,nxt3
q)queue
x y tool time
-------------
0 1 1    1
0 0 2    7
```
Eventually we reach the point where we are trying to expand a goal node:
```q
q)goal:select from nxt where x=tgt[0], y=tgt[1], tool=1
q)goal
x  y  tool time
---------------
10 10 1    45
```
The answer is the minimal time from this table:
```q
q)exec min time from goal
45
```
