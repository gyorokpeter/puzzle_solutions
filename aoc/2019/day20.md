# Breakdown
Example input:
```q
x:()
x,:enlist"         A           "
x,:enlist"         A           "
x,:enlist"  #######.#########  "
x,:enlist"  #######.........#  "
x,:enlist"  #######.#######.#  "
x,:enlist"  #######.#######.#  "
x,:enlist"  #######.#######.#  "
x,:enlist"  #####  B    ###.#  "
x,:enlist"BC...##  C    ###.#  "
x,:enlist"  ##.##       ###.#  "
x,:enlist"  ##...DE  F  ###.#  "
x,:enlist"  #####    G  ###.#  "
x,:enlist"  #########.#####.#  "
x,:enlist"DE..#######...###.#  "
x,:enlist"  #.#########.###.#  "
x,:enlist"FG..#########.....#  "
x,:enlist"  ###########.#####  "
x,:enlist"             Z       "
x,:enlist"             Z       "
```

## Common
We start by finding the portal locations, which is not trivial due to the odd layout of the map.
We initialize a table with four columns: label (`lb`), row and column (`ci`, `cj`) and z-direction
(`dk`) (the latter is only relevant for part 2).
```q
q)label:([]lb:`$();ci:`long$();cj:`long$();dk:`long$())
```
We find which characters on the map are letters:
```q
q)ll:x within "AZ"
q)ll
000000000100000000000b
000000000100000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000100000000000b
110000000100000000000b
000000000000000000000b
000000011001000000000b
000000000001000000000b
000000000000000000000b
110000000000000000000b
000000000000000000000b
110000000000000000000b
000000000000000000000b
000000000000010000000b
000000000000010000000b
```
We find which letters are warps for positions above them by shifting the map up first by one tile,
then by two tiles. A warp has a letter in the first two configurations and a dot in the third.
```q
q)lld:ll and (-1_enlist[count[first x]#0b],ll) and ((-2_(2#enlist(count first x)#" "),x)=".")
q)lld
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000100000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000000000000b
000000000000010000000b
```
We use [2D search](../utils/patterns.md#2d-search) to find the warp positions:
```q
q)lbd:raze til[count lld],/:'where each lld
q)lbd
8  9
18 13
```
We add the warps to the table. The position in the table refers to the map tile connected to the
warp, so the positions above need to be shifted two tiles up. The z-direction depends on whether the
warp is found in the top or bottom half of the map.
```q
q)label,:([]lb:`$x ./:/:(-1 0;0 0)+\:/:lbd;ci:lbd[;0]-2;cj:lbd[;1];dk:?[lbd[;0]<count[x]div 2;-1;1])
q)label
lb ci cj dk
-----------
BC 6  9  -1
ZZ 16 13 1
```
We do similar searches for the other three directions. Only the exact mechanics of shifting the map
and the deltas added to the coordinates are different.
```q
q)llu:ll and ((1_ll),enlist[count[first x]#0b]) and (((2_x),2#enlist(count first x)#" ")=".");
q)lbu:raze til[count lld],/:'where each llu
q)label,:([]lb:`$x ./:/:(0 0;1 0)+\:/:lbu;ci:lbu[;0]+2;cj:lbu[;1];dk:?[lbu[;0]<count[x] div 2;1;-1])
q)lll:ll and (0b,/:-1_/:ll) and "."=("  ",/:-2_/:x)
q)lbl:raze til[count lll],/:'where each lll
q)label,:([]lb:`$x ./:/:(0 -1;0 0)+\:/:lbl;ci:lbl[;0];cj:lbl[;1]-2;dk:?[lbl[;1]<count[first x]div 2;-1;1])
q)llr:ll and ((1_/:ll),\:0b) and "."=((2_/:x),\:"  ")
q)lbr:raze til[count llr],/:'where each llr
q)label,:([]lb:`$x ./:/:(0 0;0 1)+\:/:lbr;ci:lbr[;0];cj:lbr[;1]+2;dk:?[lbr[;1]<count[first x]div 2;1;-1])
q)label
lb ci cj dk
-----------
BC 6  9  -1
ZZ 16 13 1
AA 2  9  1
FG 12 11 -1
DE 10 6  -1
BC 8  2  1
DE 13 2  1
FG 15 2  1
```
This table is returned from the common function `d20`.

## Part 1
We use a modified BFS that needs to account for warps being a valid move in addition to the normal
up/left/down/right transitions.

We take the labels from the common function:
```q
q)label:d20 x
```
We extract the start and finish positions by looking for the labels `AA` and `ZZ`:
```q
q)start:exec (first ci;first cj) from label where lb=`AA
q)start
2 9
q)finish:exec (first ci;first cj) from label where lb=`ZZ
q)finish
16 13
```
We create a warp mapping by joining the identically-labeled warps together:
```q
q)warp:raze exec {x!x except/:enlist each x}each cs from select cs:flip(ci;cj) by lb from label
q)warp
2  9 | ()
6  9 | ,8 2
8  2 | ,6 9
10 6 | ,13 2
13 2 | ,10 6
12 11| ,15 2
15 2 | ,12 11
16 13| ()
```
We initialize a parent map with a null entry for the starting position:
```q
q)parent:enlist[start]!enlist 0N 0N
q)parent
2 9|
```
We initialize a queue with the starting position:
```q
q)queue:enlist start
q)queue
2 9
```
We iterate until the queue is empty. However, the queue becoming empty is an error, since it only
occurs if there is no path to the target.
```q
    while[count queue;
        ...
    ];
```
In the iteration, we start by expanding each node in all four directions, plus taking any warps:
```q
q)nxts:(queue+/:\:(-1 0;0 1;1 0;0 -1)),'warp queue
q)nxts
1 9  2 10 3 9  2 8
```
We look up the tile type for each of the possible next positions:
```q
q)nxtt:x ./:/:nxts
q)nxtt
"A#.#"
```
We filter the next positions to only those that have an open space (dot) on the map:
```q
q)nxts:(nxts@'where each "."=nxtt)except\:value parent
q)nxts
3 9
```
We update the parent map with the parents of the next positions:
```q
q)parent[raze nxts]:raze (count each nxts)#'enlist each queue
q)parent
2 9|
3 9| 2 9
```
We set the queue to be the next nodes:
```q
q)queue:raze nxts
q)queue
3 9
```
The next step can be demonstrated after going through the loop several times:
```q
q)queue
15 15
15 14
16 13
```
We check if any of the positions in the queue are the finish position:
```q
q)0<count arrive:where finish~/:queue
1b
q)arrive
,2
```
We return the length of the path by tracing back the path through the parent map:
```q
q)parent\[first queue arrive]
16 13
15 13
14 13
..
3 9
2 9
0N 0N
`long$()
```
The last two entries are garbage, and the first element is the destination itself, so we ignore
them:
```q
q)1_-2_parent\[first queue arrive]
15 13
14 13
13 13
..
4  9
3  9
2  9
q)count 1_-2_parent\[first queue arrive]
23
```

## Part 2
The depth is now part of the state in addition to the two coordinates. However, the same BFS would
be too slow, so we use the same trick as [day 18](day18.md): using simultaneous BFS's to calculate
paths between portals and only store their endpoints and lenghts. There is only one BFS this time as
there is no dependency to keep track of. Once we have the simplified graph we use Dijkstra's
algorithm to find the path from `(AA;0)` to `(ZZ;0)`. Once again portal moves need to be
incorporated into the allowed moves in addition to the edges of the simplified graph. Moves to
negative levels and moves through `ZZ` need to be specifically excluded (`ZZ` is only checked as the
exit condition). (Not excluding `AA` is not a problem because there will be no edge coming out of
the non-existing exit. But in an early version of my code, the lack of an explicit check for `ZZ`
caused the code to cheat by moving through `ZZ` on depth 1 since that caused it to arrive at
`(ZZ;0)`, which triggered the exit condition while it was invalid due to being at the non-existing
end of the `ZZ` portal.)

We start by generating the label map as in part 1:
```q
q)label:d20 x
q)label
lb ci cj dk
-----------
BC 6  9  -1
ZZ 16 13 1
AA 2  9  1
FG 12 11 -1
DE 10 6  -1
BC 8  2  1
DE 13 2  1
FG 15 2  1
```
We initialize a map to hodl the path lengtsh between the labels:
```q
q)paths:([]sl:();tl:();plen:`long$())
q)paths
sl tl plen
----------
```
We initialize the queue. Each entry will contain a starting label and a position:
```q
q)queue:select ls:(lb,'dk),pos:(ci,'cj) from label
q)queue
ls     pos
------------
`BC -1 6  9
`ZZ 1  16 13
`AA 1  2  9
`FG -1 12 11
`DE -1 10 6
`BC 1  8  2
`DE 1  13 2
`FG 1  15 2
```
We initialize a parent map with null positions for the parents of each label:
```q
q)parent:exec (ls,'pos)!count[i]#enlist 0N 0N from queue
q)parent
`BC -1 6  9 |
`ZZ 1  16 13|
`AA 1  2  9 |
`FG -1 12 11|
`DE -1 10 6 |
`BC 1  8  2 |
`DE 1  13 2 |
`FG 1  15 2 |
```
We iterate until the queue is empty (which is not a fail condition this time):
```q
    while[0<count queue;
        ...
    ];
```
In the iteration, we expand the nodes by adding the offsets for the four main directions:
```q
q)nxts:update npos:pos+/:\:(-1 0;0 1;1 0;0 -1) from queue
q)nxts
ls     pos   npos
------------------------------------
`BC -1 6  9  5 9   6 10  7 9   6 8
`ZZ 1  16 13 15 13 16 14 17 13 16 12
`AA 1  2  9  1 9   2 10  3 9   2 8
`FG -1 12 11 11 11 12 12 13 11 12 10
`DE -1 10 6  9  6  10 7  11 6  10 5
`BC 1  8  2  7 2   8 3   9 2   8 1
`DE 1  13 2  12 2  13 3  14 2  13 1
`FG 1  15 2  14 2  15 3  16 2  15 1
```
We manually ungroup the table since the built-in `ungroup` function only works if the columns we
want to exend are all atoms:
```q
q)nxts2:raze{([]ls:count[x`npos]#enlist x`ls;pos:count[x`npos]#enlist x`pos;npos:x`npos)}each nxts
q)nxts2
ls     pos   npos
------------------
`BC -1 6  9  5  9
`BC -1 6  9  6  10
`BC -1 6  9  7  9
`BC -1 6  9  6  8
`ZZ 1  16 13 15 13
`ZZ 1  16 13 16 14
`ZZ 1  16 13 17 13
`ZZ 1  16 13 16 12
`AA 1  2  9  1  9
`AA 1  2  9  2  10
`AA 1  2  9  3  9
`AA 1  2  9  2  8
..
```
We add the tile at the next position as a column to the table:
```q
q)nxts2:update ntile:x ./:npos from nxts2
q)nxts2
ls     pos   npos  ntile
------------------------
`BC -1 6  9  5  9  .
`BC -1 6  9  6  10 #
`BC -1 6  9  7  9  B
`BC -1 6  9  6  8  #
`ZZ 1  16 13 15 13 .
`ZZ 1  16 13 16 14 #
`ZZ 1  16 13 17 13 Z
`ZZ 1  16 13 16 12 #
`AA 1  2  9  1  9  A
`AA 1  2  9  2  10 #
`AA 1  2  9  3  9  .
`AA 1  2  9  2  8  #
..
```
We filter the table to open positions only (`"."` tiles) that don't yet appear in the parent map:
```q
q)nxts2:select from nxts2 where ntile=".", not (ls,'npos) in key parent
q)nxts2
ls     pos   npos  ntile
------------------------
`BC -1 6  9  5  9  .
`ZZ 1  16 13 15 13 .
`AA 1  2  9  3  9  .
`FG -1 12 11 13 11 .
`DE -1 10 6  10 5  .
`BC 1  8  2  8  3  .
`DE 1  13 2  13 3  .
`FG 1  15 2  15 3  .
```
We add the new nodes to the parent map:
```q
q)parent[exec (ls,'npos) from nxts2]:exec pos from nxts2
q)parent
`BC -1 6  9 |
`ZZ 1  16 13|
`AA 1  2  9 |
`FG -1 12 11|
`DE -1 10 6 |
`BC 1  8  2 |
`DE 1  13 2 |
`FG 1  15 2 |
`BC -1 5  9 | 6  9
`ZZ 1  15 13| 16 13
`AA 1  3  9 | 2  9
`FG -1 13 11| 12 11
`DE -1 10 5 | 10 6
`BC 1  8  3 | 8  2
`DE 1  13 3 | 13 2
`FG 1  15 3 | 15 2
```
We check for any paths that arrived at another label. This time the construction of the path is more
fiddly because of the presence of the label in the nodes.
```q
    if[0<count found:select from nxts2 where npos in exec (ci,'cj) from label; 
        paths,:select sl:ls, tl: (exec ((ci,'cj)!(lb,'dk))from label)npos, plen:count each 1_/:-2_/:{[parent;x](2#x),parent[x]}[parent]\'[ls,'npos] from found;
    ];
```
We generate the new queue by only taking the label and position:
```q
q)queue:select ls,pos:npos from nxts2
q)queue
ls     pos
------------
`BC -1 5  9
`ZZ 1  15 13
`AA 1  3  9
`FG -1 13 11
`DE -1 10 5
`BC 1  8  3
`DE 1  13 3
`FG 1  15 3
```
The code of the first iteration ends here. At the end, we have the lengths of the shortest path
between each pair of labels:
```q
q)paths
sl     tl     plen
------------------
`BC -1 `AA 1  4
`AA 1  `BC -1 4
`DE 1  `FG 1  4
`FG 1  `DE 1  4
`ZZ 1  `FG -1 6
`FG -1 `ZZ 1  6
`DE -1 `BC 1  6
`BC 1  `DE -1 6
`ZZ 1  `AA 1  26
`AA 1  `ZZ 1  26
`BC -1 `ZZ 1  28
`ZZ 1  `BC -1 28
`AA 1  `FG -1 30
`FG -1 `AA 1  30
`BC -1 `FG -1 32
`FG -1 `BC -1 32
```
For the second iteration, we initialize a visited array to an empty list:
```q
q)visited:()
```
We initialize the queue with the initial node being on the label `AA`, the direction `1` (outer
edge) and depth `0`:
```q
q)queue:([]lb:enlist`AA;k:1;d:0;plen:0)
q)queue
lb k d plen
-----------
AA 1 0 0
```
We iterate until the queue runs out, but this time that indicates no path found:
```q
    while[count queue;
        ...
    ];
```
In the iteration, we find the shortest path length:
```q
q)minl:exec min plen from queue
q)minl
0
```
We fetch the nodes from the queue with this length:
```q
q)toExpand:select from queue where plen=minl
q)toExpand
lb k d plen
-----------
AA 1 0 0
```
We check if any of the nodes to be expanded is the target node. If so, we return the length.
```q
    if[0<count found:select from toExpand where lb=`ZZ,d=0;
        :minl;
    ];
```
We add the nodes to expand to the visited array:
```q
q)visited,:exec (lb,'k,'d) from toExpand
q)visited
`AA 1 0
```
We expand the nodes by looking up the paths in the `paths` table. This is where checks are done such
as not going down via `ZZ` or up above depth 0.
```q
    nxts:update npos:{[paths;x](exec (tl,'x[2],/:plen) from paths where sl~\:2#x),
        $[(x[2]>0) and (x[1]=1) and x[0]<>`ZZ;enlist(x[0];-1;x[2]-1;1);()],$[x[1]=-1;enlist(x[0];1;x[2]+1;1);()]
        }[paths]each(lb,'k,'d) from toExpand;

q)nxts
lb k d plen npos
-----------------------------------------------
AA 1 0 0    `BC -1 0 4  `ZZ 1  0 26 `FG -1 0 30
```
This time `ungroup` works to flatten the table:
```q
q)nxts2:ungroup nxts
q)nxts2
lb k d plen npos
-----------------------
AA 1 0 0    `BC -1 0 4
AA 1 0 0    `ZZ 1  0 26
AA 1 0 0    `FG -1 0 30
```
We move the updated lengths from the `npos` column into the `plen` column:
```q
q)nxts2:update plen+last each npos, -1_/:npos from nxts2
q)nxts2
lb k d plen npos
--------------------
AA 1 0 4    `BC -1 0
AA 1 0 26   `ZZ 1  0
AA 1 0 30   `FG -1 0
```
We drop any already visited nodes:
```q
q)nxts2:select from nxts2 where not npos in visited
q)nxts2
lb k d plen npos
--------------------
AA 1 0 4    `BC -1 0
AA 1 0 26   `ZZ 1  0
AA 1 0 30   `FG -1 0
```
We drop the original nodes from the queue and add the expanded ones, moving the elements of `npos`
into the corresponding columns:
```q
q)queue:(delete from queue where plen=minl),select lb:npos[;0], k:npos[;1],d:npos[;2],plen from nxts2
q)queue
lb k  d plen
------------
BC -1 0 4
ZZ 1  0 26
FG -1 0 30
```
We deduplicate the queue by taking the nodes with the minimum length for each key. This corresponds
to the "updating the priority queue in place" part of Dijkstra's algorithm in a classical language.
```q
q)queue:0!select first plen by lb,k,d from `plen xasc queue
q)queue
lb k  d plen
------------
BC -1 0 4
FG -1 0 30
ZZ 1  0 26
```
This is the end of the code for the second iteration. Eventually we try to expand the target node,
which will cause the minimum path length to be returned.
```q
q)minl
26
q)toExpand
lb k d plen
-----------
ZZ 1 0 26
q)0<count found:select from toExpand where lb=`ZZ,d=0
1b
q)found
lb k d plen
-----------
ZZ 1 0 26
```
