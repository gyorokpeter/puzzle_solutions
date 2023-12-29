# Breakdown

Example input:
```q
x:();
x,:enlist"#.#####################";
x,:enlist"#.......#########...###";
x,:enlist"#######.#########.#.###";
x,:enlist"###.....#.>.>.###.#.###";
x,:enlist"###v#####.#v#.###.#.###";
x,:enlist"###.>...#.#.#.....#...#";
x,:enlist"###v###.#.#.#########.#";
x,:enlist"###...#.#.#.......#...#";
x,:enlist"#####.#.#.#######.#.###";
x,:enlist"#.....#.#.#.......#...#";
x,:enlist"#.#####.#.#.#########v#";
x,:enlist"#.#...#...#...###...>.#";
x,:enlist"#.#.#v#######v###.###v#";
x,:enlist"#...#.>.#...>.>.#.###.#";
x,:enlist"#####v#.#.###v#.#.###.#";
x,:enlist"#.....#...#...#.#.#...#";
x,:enlist"#.#########.###.#.#.###";
x,:enlist"#...###...#...#...#.###";
x,:enlist"###.###.#.###v#####v###";
x,:enlist"#...#...#.#.>.>.#.>.###";
x,:enlist"#.###.###.#.###.#.#v###";
x,:enlist"#.....###...###...#...#";
x,:enlist"#####################.#";
```

## Part 1
It turns out that the input doesn't have any way to return to a point we already visited (as long as we don't consider outright backtracking as an option - this is in contrast to day 21). So the paths can be found using BFS.

We initialize the step counter and put the starting node in the queue:
```q
lens:();
step:0
queue:enlist`pos`d!(0,first where"."=x 0;2)
```
We iterate until the queue is empty:
```q
while[count queue; ... step+:1];
```
We start by looking for finished states - those where the row number equals to the row count minus 1:
```q
if[count finished:select from queue where pos[;0]=count[x]-1; ... ];
```
If we find any, we add them to the list of path lengths ad delete them from the queue:
```q
lens,:count[finished]#step
queue:delete from queue where pos[;0]=count[x]-1
```
To generate the next nodes, we examine the current tile type under the current positions in the queue:
```q
 nxts:update t:x ./:pos from queue
```
We need to expand the nodes, but since `pos` is a list, we can't use `ungroup`. Instead we store the original row index in a temporary column (`j:i`) as well as add the next direction column. The next direction is forced if the position is on an arrow:
```q
nxts:update j:i, nd:enlist each(".^>v<"!0N 0 1 2 3)t from nxts
```
If the position is on an empty tile, there are 3 possibilities for the next direction, using modulo 4 arithmetic to wrap around between north and west:
```q
nxts:update nd:(d+count[i]#enlist -1 0 1)mod 4 from nxts where t="."
```
We do the ungrouping in two parts: first we do an actual `ungroup` on the columns of the table other than `pos`, then we left-join a smaller table containing only `j` and `pos`. After this `j` can be deleted.
```q
nxts:delete j from(ungroup delete pos from nxts)lj 1!select j,pos from nxts
```
We update the position according the current direction:
```q
nxts:update pos+(-1 0;0 1;1 0;0 -1)nd from nxts
```
We check the tile under the position again:
```q
nxts:update t:x ./:pos from nxts
```
We drop any states where we are standing on a `"#"` or nothing (which is not the same as `"."` - we get a space character if we index out of range, which is an easy way to filter out states that try to go off the map):
```q
nxts:delete from nxts where t in " #"
```
We also delete any states where we just moved onto an arrow pointing in the opposite direction, since we decided that backtracking should be blocked:
```q
nxts:delete from nxts where t="v<^>"nd
```
Finally we update the queue with the current positions and directions:
```q
queue:select pos,d:nd from nxts
```
At the end of the iteration, `lens` contains all possible path lengths, just like how they are provided for the example input, but we are only interested in the last one of them which is the longest.

## Part 2
This time the removal of the arrows means paths can curve back on themselves. This creates a large number of potential paths (the real input has around 34 branching points). So first we abstract the map into a graph that only takes the branching points into account, then we do a BFS to find the longest path on this derived graph. This is the most time and space intensive solution in this season.

We replace the arrows in the input with open spaces:
```q
q)x:ssr[;"[<>v^]";"."]each x
q)x
"#.#####################"
"#.......#########...###"
"#######.#########.#.###"
"###.....#.....###.#.###"
"###.#####.#.#.###.#.###"
"###.....#.#.#.....#...#"
"###.###.#.#.#########.#"
"###...#.#.#.......#...#"
"#####.#.#.#######.#.###"
"#.....#.#.#.......#...#"
"#.#####.#.#.#########.#"
"#.#...#...#...###.....#"
"#.#.#.#######.###.###.#"
"#...#...#.......#.###.#"
"#####.#.#.###.#.#.###.#"
"#.....#...#...#.#.#...#"
"#.#########.###.#.#.###"
"#...###...#...#...#.###"
"###.###.#.###.#####.###"
"#...#...#.#.....#...###"
"#.###.###.#.###.#.#.###"
"#.....###...###...#...#"
"#####################.#"
```
We determine the "points of interest" by overlaying the map shifted in all 4 directions, and looking for points where there are at least 2 open spaces in the stack. We also need to filter to positions that are actually open spaces in the original map. The start and finish points are also points of interest.
```q
poi:raze til[count x],/:'where each 2<(x=".")*sum"."=
    (("#",/:-1_/:x);(1_/:x,\:"#");(1#x),-1_x;(1_x),-1#x);
poi:(enlist 0,first where x[0]="."),poi,enlist (count[x]-1),first where last[x]=".";
q)poi
0  1
3  11
5  3
11 21
13 5
13 13
19 13
19 19
22 21
```
For the first stage, we initialize an empty connectivity map, a step counter and the queue to contain states from all points of interest in all 4 directions each (we will filter out the invalid ones anyway).
```q
conn:til[count poi]!count[poi]#enlist()
step:0
queue:([]start:til count poi;pos:poi)cross([]d:til 4)
```
We iterate until the queue is empty:
```q
while[count queue; ... step+:1];
```
If we are not on the initial step, we check if any states is on any point of interest (we need to check for `step>0` because on step 0 all states are over these positions):
```q
if[step>0;
    finish:select from queue where pos in poi;
    if[count finish;
        ...
    ];
];
```
If we have any finishing states, we look up which points of interest they are over, add them to the connectivity map and remove them from the queue:
```q
if[count finish;
    newc:exec((poi?pos),'step) by start from finish;
    conn[key newc]:conn[key newc],'value newc;
    queue:delete from queue where pos in poi;
];
```
We expand the nodes similar to part 1, except there is no need to check the arrows this time:
```q
nxts:update j:i, nd:(d+count[i]#enlist -1 0 1)mod 4 from queue
nxts:delete j from(ungroup delete pos from nxts)lj 1!select j,pos from nxts
nxts:update pos+(-1 0;0 1;1 0;0 -1)nd from nxts
nxts:update t:x ./:pos from nxts
nxts:delete from nxts where t in " #"
queue:distinct select start, pos,d:nd from nxts
```
After this iteration we have a weighted connectivity map:
```q
q)conn
0| ,2 15
1| (2 22;5 24;3 30)
2| (0 15;1 22;4 22)
3| (7 10;5 18;1 30)
4| (5 12;2 22;6 38)
5| (6 10;4 12;3 18;1 24)
6| (5 10;7 10;4 38)
7| (8 5;6 10;3 10)
8| ,7 5
```
For the second stage, we initialize a queue with a single state that starts from PoI 0, has a path length of 0, and the list of visited PoIs as a list containing 0 only:
```q
queue:enlist`node`len`p!(0;0;enlist 0);
maxlen:0;
```
We iterate until the queue is empty:
```q
while[count queue; ... ]
```
We check for finished states, which need to be in the last PoI:
```q
finish:select from queue where node=count[poi]-1;
if[count finish; ... ];
```
If we find any, we update the maximum length if necessary and remove the states from the queue:
```q
if[count finish;
    maxlen|:exec max len from finish;
    queue:delete from queue where node=count[poi]-1;
];
```
When expanding the nodes, we need to add a temporary `j` column again, this time because `p` is a list. We also look up the next nodes in the connectivity map:
```q
nxts:update j:i, nn:conn node from queue
```
We do the two-phased ungroup like in part 1:
```q
nxts:(ungroup delete p from nxts) lj 1!select j,p from nxts
```
We delete any states where we are trying to move onto a PoI that is already in the list of visited PoIs:
```q
nxts:delete from nxts where nn[;0] in'p
```
We update the current node, path length and visited PoIs based on the properties of the next node:
```q
nxts:update node:nn[;0], len+nn[;1], p:(p,'nn[;0]) from nxts
```
We update the queue with only the necessary columns:
```q
queue:select node,len,p from nxts
```
This would normally be the end of the iteration, and the `maxlen` variable contains the length of the longest path. However, on the real input this uses so much memory that the interpreter runs out of the 32-bit address space, leading to a `wsfull` error. Luckily it is possible to help it by adding a little nudge, by resetting the `nxts` variable to an empty list and invoking the garbage collector:
```q
nxts:()
.Q.gc[]
```
This makes it pass without hitting the address space limit.

If this was not enough, the algorithm would have to be reformulated to be more depth-first, eliminating batches of nodes before the list length blows up. A real BFS using recursive functions is not common practice in q, since nested function calls tend to be be very slow and there is an unusually strict limit on the depth of the call stack.
