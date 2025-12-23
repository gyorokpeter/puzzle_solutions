# Breakdown
Example input:
```q
x:()
x,:enlist"#################"
x,:enlist"#i.G..c...e..H.p#"
x,:enlist"########.########"
x,:enlist"#j.A..b...f..D.o#"
x,:enlist"########@########"
x,:enlist"#k.E..a...g..B.n#"
x,:enlist"########.########"
x,:enlist"#l.F..d...h..C.m#"
x,:enlist"#################"
```

## Overview - Part 1
The solution is broken down into three sub-tasks:
1. BFS to find which key is required to get to which other keys. We start from the robot location
and record any doors encountered (we pass right through). When a key is found, we record which doors
were seen up to that point.
2. BFS to simplify the map. We are only interested in paths between keys (and paths starting from
the robot location). So we start the BFS with every key and the start location in the queue, and
whenever we encounter a key, we record the found path. We don't care about paths leading back to the
start. A huge optimization here is stopping each BFS immediately after finding a key. This way we
will only have path lengths between adjacent keys, but it decreases the branching factor for the
third task.
3. Dijkstra's algorithm to collect all keys. The state is the current key plus the set of keys
collected. We use the data collected from the first two sub-tasks to figure out which keys we can
move to and how long the path is. As expected in q, we use a vector version of Dijkstra's algorithm.
There is no priority queue, instead pruning is done in every iteration by dropping duplicated rows
using group by, only keeping the minimal paths. Sorting the table with `xasc` and
then doing a group by on it is more efficient than the equivalent filtering using `fby`.

## Overview - Part 2
The solution is the same with minor modifications.

The BFS's will each start with all of the robot locations, but they still calculate the same
information. We need to distinguish between each start location, rather than using the generic
symbol `@` which may confuse the algorithms into thinking that they are connected. For the 3rd
sub-task, the state is also changed to not consist of only one character for the "current key" but
a string with each character corresponding to the current key of the respective robot. When
expanding the states, we need to consider moving each robot, therefore there is a doubly-nested
lambda here.

## Common
The function `d18p1` will solve both part 1 and 2 assuming the map is preprocessed to contain the
changes in part 2 (it will actually work with up to 10 starting locations).

We find the starting bot positions using a [2D search](../utils/patterns.md#2d-search):
```q
q)starts:raze til[count x],/:'where each"@"=x
q)starts
4 8
```
We find all keys by checking which characters are between `"a"` and `"b"`:
```q
q)allKeys:{asc x where x within "az"}raze x
q)allKeys
`s#"abcdefghijklmnop"
```
For the first BFS, we use a queue with the vertical and horizontal coordinates and the list of doors
found:
```q
q)queue:([]ci:starts[;0];cj:starts[;1];doors:count[starts]#enlist"")
q)queue
ci cj doors
-----------
4  8  ""
```
We also store the parent of each cell, with the starting positions having a null parent:
```q
q)parent:starts!count[starts]#enlist[(0N;0N)]
q)parent
4 8|
```
We also store which key needs which other keys to get. The initial value maps the space character
(the "null" of the character type) to an empty string. This is a sentinel element to make sure that
element lookup uses the correct types.
```q
q)needKey:enlist[" "]!enlist""
q)needKey
 | ""
```
We do the first iteration as long as there are items in the queue:
```q
    while[0<count queue;
        ...
    ];
```
We expand each node in the queue by generating the neighboring coordinates in all four directions:
```q
q)nxts:raze{update nci:ci+-1 0 1 0,ncj:cj+0 1 0 -1 from 4#enlist x}each queue
q)nxts
ci cj doors nci ncj
-------------------
4  8  ""    3   8
4  8  ""    4   9
4  8  ""    5   8
4  8  ""    4   7
```
We add the tile corresponding to the new position:
```q
q)nxts:update ntile:x'[nci;ncj] from nxts
q)nxts
ci cj doors nci ncj ntile
-------------------------
4  8  ""    3   8   .
4  8  ""    4   9   #
4  8  ""    5   8   .
4  8  ""    4   7   #
```
We filter the nodes to those that don't contain walls in the next position and aren't yet visited
(not in the parent map):
```q
q)nxts:select from nxts where not ntile="#", not (nci,'ncj) in key parent
q)nxts
ci cj doors nci ncj ntile
-------------------------
4  8  ""    3   8   .
4  8  ""    5   8   .
```
We update the `doors` column with any door or key on the next tile. We convert to lowercase to make
the two types of tiles consistent. The inclusion of keys is deliberate, since we are checking which
keys are needed to reach each tile, and if a key blocks the way, that key is "necessary" as it is
not possible to reach the tiles beyond without it. There is no need to distinguish between the key
pickup being deliberate or accidental, and this saves on the number of nodes for the next part.
```q
q)nxts:update doors:asc each distinct each (doors,'lower ntile) from nxts where lower[ntile] within "az"
q)nxts
ci cj doors nci ncj ntile
-------------------------
4  8  ""    3   8   .
4  8  ""    5   8   .
```
We record the parents of the new nodes:
```q
q)parent,:exec (nci,'ncj)!(ci,'cj) from nxts
q)parent
4 8|
3 8| 4 8
5 8| 4 8
```
We also record which keys are needed for which doors encountered on the new nodes:
```q
q)needKey,:exec ntile!doors except' ntile from nxts where ntile within "az"
q)needKey
 | ""
```
We prepare the next state of the queue by re-designating the next coordinates as the current ones:
```q
q)queue:select ci:nci, cj:ncj, doors from nxts
q)queue
ci cj doors
-----------
3  8  ""
5  8  ""
```
This is the end of the code of the first iteration. After the iteration ends, we have a mapping of
which doors need which keys:
```q
q)needKey
 | ""
f| ""
b| ""
g| ""
a| ""
e| ""
c| ""
h| ""
d| ""
o| "df"
j| "ab"
n| "bg"
k| "ae"
p| "eh"
i| "cg"
m| "ch"
l| "df"
```
We prepare the initial state for the second iteration. The starting positions are all the robot
starts plus all the keys' locations:
```q
q)startps:starts,raze til[count x],/:'where each x within "az"
q)startps
4 8
1 1
1 6
1 10
1 15
3 1
3 6
3 10
3 15
5 1
5 6
5 10
5 15
7 1
7 6
7 10
7 15
```
The queue contains the starting positions and the starting entity. We assign the robots the numbers
starting from 0 (still using the `char` type).
```q
q)queue:([]ci:startps[;0];cj:startps[;1]; sc:(raze string til count starts),count[starts]_x ./:startps)
q)queue
ci cj sc
--------
4  8  0
1  1  i
1  6  c
1  10 e
1  15 p
3  1  j
3  6  b
3  10 f
3  15 o
5  1  k
5  6  a
5  10 g
5  15 n
7  1  l
7  6  d
7  10 h
7  15 m
```
The parent map contains the starting positions, once again tagged with the starting entities. The
syntax `(;;)`is a projection of `enlist` that visually indicates that we are creating three-element
lists.
```q
q)parent:(exec (;;)'[ci;cj;sc] from queue)!count[queue]#enlist[0N 0N,enlist" "]
q)parent
4 8  "0"| 0N 0N " "
1 1  "i"| 0N 0N " "
1 6  "c"| 0N 0N " "
1 10 "e"| 0N 0N " "
1 15 "p"| 0N 0N " "
3 1  "j"| 0N 0N " "
3 6  "b"| 0N 0N " "
3 10 "f"| 0N 0N " "
3 15 "o"| 0N 0N " "
5 1  "k"| 0N 0N " "
5 6  "a"| 0N 0N " "
5 10 "g"| 0N 0N " "
5 15 "n"| 0N 0N " "
7 1  "l"| 0N 0N " "
7 6  "d"| 0N 0N " "
7 10 "h"| 0N 0N " "
7 15 "m"| 0N 0N " "
```
We also initialize a path map that will hold the found paths between two entities:
```q
q)paths:([s:"";t:""]path:();plen:`long$())
```
The second iteration also lasts until the queue is empty:
```q
    while[0<count queue;
        ...
    ];
```
We expand the nodes like in the first iteration:
```q
q)nxts:raze{update nci:ci+-1 0 1 0,ncj:cj+0 1 0 -1 from 4#enlist x}each queue
q)nxts
ci cj sc nci ncj
----------------
4  8  0  3   8
4  8  0  4   9
4  8  0  5   8
4  8  0  4   7
1  1  i  0   1
1  1  i  1   2
1  1  i  2   1
1  1  i  1   0
1  6  c  0   6
1  6  c  1   7
1  6  c  2   6
1  6  c  1   5
..
```
We also fetch the next tiles:
```q
q)nxts:update ntile:x'[nci;ncj] from nxts
q)nxts
ci cj sc nci ncj ntile
----------------------
4  8  0  3   8   .
4  8  0  4   9   #
4  8  0  5   8   .
4  8  0  4   7   #
1  1  i  0   1   #
1  1  i  1   2   .
1  1  i  2   1   #
1  1  i  1   0   #
1  6  c  0   6   #
1  6  c  1   7   .
1  6  c  2   6   #
1  6  c  1   5   .
..
```
We filter to non-wall non-visited nodes:
```q
q)nxts:select from nxts where not ntile="#", not (;;)'[nci;ncj;sc] in key parent
q)nxts
ci cj sc nci ncj ntile
----------------------
4  8  0  3   8   .
4  8  0  5   8   .
1  1  i  1   2   .
1  6  c  1   7   .
1  6  c  1   5   .
1  10 e  1   11  .
1  10 e  1   9   .
1  15 p  1   14  .
..
```
We update the parent map with the new nodes:
```q
q)parent,:exec (;;)'[nci;ncj;sc]!(ci,'cj) from nxts
q)parent
4 8  "0"| (0N;0N;" ")
1 1  "i"| (0N;0N;" ")
1 6  "c"| (0N;0N;" ")
1 10 "e"| (0N;0N;" ")
1 15 "p"| (0N;0N;" ")
3 1  "j"| (0N;0N;" ")
3 6  "b"| (0N;0N;" ")
3 10 "f"| (0N;0N;" ")
3 15 "o"| (0N;0N;" ")
5 1  "k"| (0N;0N;" ")
5 6  "a"| (0N;0N;" ")
5 10 "g"| (0N;0N;" ")
5 15 "n"| (0N;0N;" ")
7 1  "l"| (0N;0N;" ")
7 6  "d"| (0N;0N;" ")
7 10 "h"| (0N;0N;" ")
7 15 "m"| (0N;0N;" ")
3 8  "0"| 4 8
5 8  "0"| 4 8
1 2  "i"| 1 1
1 7  "c"| 1 6
1 5  "c"| 1 6
..
```
If any of the new tiles contains a key, we generate the paths by tracing back the parent map:
```q
q)pths:update path:-1_/:/:reverse each -2_/:{[p;x]p[x],-1#x}[parent]\'[(;;)'[nci;ncj;sc]] from select from nxts where ntile within "az"
q)pths
ci cj sc nci ncj ntile path
---------------------------
```
We then put the found paths in the `paths` map after shuffling around the columns:
```q
q)paths:paths upsert select s:sc, t:ntile, plen:count each path, path from pths
q)paths
s t| path plen
---| ---------
```
We generate the new queue, dropping any nodes with keys:
```q
q)queue:select ci:nci, cj:ncj, sc from nxts where not ntile within "az"
q)queue
ci cj sc
--------
3  8  0
5  8  0
1  2  i
1  7  c
1  5  c
1  11 e
1  9  e
1  14 p
..
```
This is the end of the code of the first iteration. After the iteration ends, we have a mapping of
paths between entities:
```q
q)paths
s t| path                       plen
---| -------------------------------
0 f| (3 8;3 9;3 10)             3
0 b| (3 8;3 7;3 6)              3
0 g| (5 8;5 9;5 10)             3
0 a| (5 8;5 7;5 6)              3
c e| (1 7;1 8;1 9;1 10)         4
e c| (1 9;1 8;1 7;1 6)          4
b f| (3 7;3 8;3 9;3 10)         4
f b| (3 9;3 8;3 7;3 6)          4
a g| (5 7;5 8;5 9;5 10)         4
..
```
For the third and final iteration, we initialize a queue containing the entangled positions of the
robots (a string of length 1 for part 1 and 4 for part 2), the set of collected keys (in ascending
order to avoid duplication) and the total path length:
```q
q)queue:([]pos:enlist raze string til count starts;kys:enlist"";tplen:enlist 0)
q)queue
pos  kys tplen
--------------
,"0" ""  0
```
We also create a visited map - however, instead of coordinates, the nodes are the entity names:
```q
q)visited:([]pos:();kys:())
```
The iteration runs until there are no items in the queue, but in this case, running out of items is
a failure, and there is an early exit inside the loop.
```q
    while[0<count queue;
        ...
    ];
```
Since this time we are using a modified Dijkstra's algorithm, we start by finding the current
minimal path length:
```q
q)minl:exec min tplen from queue
q)minl
0
```
If we find any node in the queue that has a path length equal to the minimum and has all the keys,
we return this length:
```q
    if[0<count found:select from queue where tplen=minl, count[allKeys]=count each kys; :exec first tplen from found];
```
We filter the nodes to those where the length is equal to the minimum:
```q
q)toExpand:select from queue where tplen=minl
q)toExpand
pos  kys tplen
--------------
,"0" ""  0
```
We add the nodes to be expanded to the list of visited nodes:
```q
q)visited,:delete tplen from toExpand
q)visited
pos  kys
--------
,"0" ""
```
We expand each of the nodes by calling a function on each node and razing the results:
```q
    nxts:raze{[paths;needKey;e]
        ...
    }[paths;needKey]each toExpand;
```
(`paths` and `needKey` need to be passed in as parameters since q has no concept of nested scope.)

Inside the function, we iterate over the individual robots to expand all the ways they can move:
```q
    raze{[paths;needKey;e;p]
        ...
    }[paths;needKey;e]each til count e`pos
```
Inside the function, we first find which next positions the robot can move by checking the `paths`
map for the neighboring nodes and also checking `needKey` to make sure that the robot has all the
keys needed to enter that particular node:
```q
    nxpos:select t,plen from paths where s=e[`pos;p], all each needKey[t] in e`kys
```
We generate the expanded nodes by updating the position at the correct index to the new position for
that robot, the total path length by adding the length of the path to the chosen next node, and the
key list by adding the key at the target node:
```q
    update npos:.[pos;(::;p);:;nxpos[`t]],tplen+nxpos[`plen], kys:asc each distinct each (kys,'nxpos[`t]) from count[nxpos]#enlist e
```

```q
q)nxts
pos  kys     tplen npos
-----------------------
,"0" `s#,"f" 3     ,"f"
,"0" `s#,"b" 3     ,"b"
,"0" `s#,"g" 3     ,"g"
,"0" `s#,"a" 3     ,"a"
,"0" `s#,"e" 5     ,"e"
,"0" `s#,"c" 5     ,"c"
,"0" `s#,"h" 5     ,"h"
,"0" `s#,"d" 5     ,"d"
```
Once we have the expanded nodes, we drop any already visited ones:
```q
q)nxts:select from nxts where not ([]pos:npos;kys) in visited
q)nxts
pos  kys     tplen npos
-----------------------
,"0" `s#,"f" 3     ,"f"
,"0" `s#,"b" 3     ,"b"
,"0" `s#,"g" 3     ,"g"
,"0" `s#,"a" 3     ,"a"
,"0" `s#,"e" 5     ,"e"
,"0" `s#,"c" 5     ,"c"
,"0" `s#,"h" 5     ,"h"
,"0" `s#,"d" 5     ,"d"
```
To generate the new queue, first we delete the nodes we just expanded (by filtering on the minimum
length like before, as it will match the same rows), and append the modified expanded nodes:
```q
q)queue:(delete from queue where tplen=minl),select pos:npos, kys, tplen from nxts
q)queue
pos  kys     tplen
------------------
,"f" `s#,"f" 3
,"b" `s#,"b" 3
,"g" `s#,"g" 3
,"a" `s#,"a" 3
,"e" `s#,"e" 5
,"c" `s#,"c" 5
,"h" `s#,"h" 5
,"d" `s#,"d" 5
```
We also do a deduplication to keep only the shortest path for every position/keys combination:
```q
q)queue:0!select min tplen by kys,pos from queue
q)queue
kys     pos  tplen
------------------
`s#,"a" ,"a" 3
`s#,"b" ,"b" 3
`s#,"c" ,"c" 5
`s#,"d" ,"d" 5
`s#,"e" ,"e" 5
`s#,"f" ,"f" 3
`s#,"g" ,"g" 3
`s#,"h" ,"h" 5
```
The iteration goes on until we try to expand a node with all the keys, which triggers the early
return:
```q
q)minl:exec min tplen from queue
q)minl
136
q)found:select from queue where tplen=minl, count[allKeys]=count each kys
q)found
kys                   pos  tplen
--------------------------------
`s#"abcdefghijklmnop" ,"i" 136
`s#"abcdefghijklmnop" ,"l" 136
`s#"abcdefghijklmnop" ,"m" 136
`s#"abcdefghijklmnop" ,"p" 136
```

## Part 1
We invoke the above function directly with the input.

## Part 2
We preprocess the input first. Instead of matching for a 3x3-tile pattern, we just match on the
robot position, which will be unique:
```q
q)bpos:first raze til[count x],/:'where each x="@"
q)bpos
4 8
```
We overwrite the input around the matched position as described in the puzzle:
```q
q)x:.[;;:;]/[x;bpos+/:{x cross x} -1 0 1;"@#@###@#@"]
q)x
"#################"
"#i.G..c...e..H.p#"
"########.########"
"#j.A..b@#@f..D.o#"
"#################"
"#k.E..a@#@g..B.n#"
"########.########"
"#l.F..d...h..C.m#"
"#################"
```
We then pass in this modified input to the common function.
