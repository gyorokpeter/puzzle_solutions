# Breakdown

Example input (note that any `\` needs to be escaped if defining this way):
```q
x:"\n"vs".|...\\....\n|.-.\\.....\n.....|-...\n........|.\n..........";
x,:"\n"vs".........\\\n..../.\\\\..\n.-.-/..|..\n.|....-|.\\\n..//.|....";
```

## Common
We define a direction map that tells what direction(s) the beam will travel if it arrives on a particular kind of tile from a particular direction, with 0=north, 1=east, 2=south and 3=west.
```q
.d16.dmap:enlist[()]!enlist[()];
.d16.dmap[(0;".")]:enlist 0;
.d16.dmap[(0;"|")]:enlist 0;
.d16.dmap[(0;"-")]:1 3;
.d16.dmap[(0;"/")]:enlist 1;
.d16.dmap[(0;"\\")]:enlist 3;
.d16.dmap[(1;".")]:enlist 1;
.d16.dmap[(1;"|")]:0 2;
.d16.dmap[(1;"-")]:enlist 1;
.d16.dmap[(1;"/")]:enlist 0;
.d16.dmap[(1;"\\")]:enlist 2;
.d16.dmap[(2;".")]:enlist 2;
.d16.dmap[(2;"|")]:enlist 2;
.d16.dmap[(2;"-")]:1 3;
.d16.dmap[(2;"/")]:enlist 3;
.d16.dmap[(2;"\\")]:enlist 1;
.d16.dmap[(3;".")]:enlist 3;
.d16.dmap[(3;"|")]:0 2;
.d16.dmap[(3;"-")]:enlist 3;
.d16.dmap[(3;"/")]:enlist 2;
.d16.dmap[(3;"\\")]:enlist 0;
```
The common logic (`.d16.light`) takes the map (`x`) and the starting position and direction (`start`). It uses BFS to find all the energized tiles.

We initialize a 3-dimensional matrix for visited positions, since the direction counts as part of the position:
```q
emap:4#enlist x<>x
```
We initialize the queue to contain only the start position:
```q
queue:enlist start
```
We iterate until the queue is empty:
```q
while[count queue; ... ]
```
We update the visited array for the positions in the queue:
```q
emap:.[;;:;1b]/[emap;queue[;2 0 1]]
```
We expand the nodes in the queue by adding the next direction, looking it up in the direction map:
```q
nxts:raze queue,/:'.d16.dmap queue[;2],'x ./:queue[;0 1]
```
We update the position by moving in the next direction:
```q
nxts[;0 1]:nxts[;0 1]+'(-1 0;0 1;1 0;0 -1)nxts[;3]
```
We filter out nodes that would go off the map:
```q
nxts:nxts where all each nxts[;0 1]within'\:(0,count[x]-1;0,count[x 0]-1)
```
We filter out already visited nodes:
```q
nxts:nxts where not emap ./:nxts[;3 0 1]
```
We update the queue, moving the "next" direction into the "current" direction:
```q
queue:nxts[;0 1 3]
```
At the end of the iteration, the number of energized tiles can be read out from the visited array. However we have four layers (one for each direction) and we should not count duplicates, so the first operation is `any`, which collapses the four layers into one where each element is true only if there was at least one true value in that position. Then we can sum this matrix.
```q
sum sum any emap
```

## Part 1
We call the common logic with the start position `0 0 1` (top left, going east).
```q
q).d16.light[x;0 0 1]
46i
```

## Part 2
We generate all possible starting positions and call the common logic on each, picking the maximum of the results.
```q
q)starts:(til[count x]cross(0 1;(count[x 0]-1;3))),(til[count x 0]cross(0 2;(count[x]-1;0)))[;1 0 2];
q)starts
0 0 1
0 9 3
1 0 1
1 9 3
2 0 1
2 9 3
3 0 1
3 9 3
4 0 1
4 9 3
5 0 1
5 9 3
6 0 1
6 9 3
7 0 1
7 9 3
8 0 1
8 9 3
9 0 1
9 9 3
0 0 2
9 0 0
..
q).d16.light[x]each starts
46 5 10 7 49 45 18 11 10 10 13 6 22 9 45 47 46 13 30 48 10 10 45 45 23 47 51 ..
q)max .d16.light[x]each starts
51i
```
