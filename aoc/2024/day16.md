# Breakdown

Example input:
```q
x:();
x,:enlist"###############";
x,:enlist"#.......#....E#";
x,:enlist"#.#.###.#.###.#";
x,:enlist"#.....#.#...#.#";
x,:enlist"#.###.#####.#.#";
x,:enlist"#.#.#.......#.#";
x,:enlist"#.#.#####.###.#";
x,:enlist"#...........#.#";
x,:enlist"###.#.#####.#.#";
x,:enlist"#...#.....#.#.#";
x,:enlist"#.#.#.###.#.#.#";
x,:enlist"#.....#...#.#.#";
x,:enlist"#.###.#.#.#.#.#";
x,:enlist"#S..#.....#...#";
x,:enlist"###############";
```

## Common
We have to use Dijkstra's algorithm for this, as the cost of turning and moving are different, so it
is possible to end up in the same situation with a different total score. Unfortunately q does
terribly at such algorithms where repeated insertion and removal at arbitrary positions in a list is
necessary, as the only way to do it is to reconstruct the list with the elements added/deleted.

We find the start and end positions using the [2D search](../utils/patterns.md#2d-search) technique,
then replace these with empty spaces on the map:
```q
q)start:first raze til[count x],/:'where each x="S"
q)end:first raze til[count x],/:'where each x="E"
q)map:.[;;:;"."]/[x;(start;end)]
q)start
13 1
q)end
1 13
q)map
"###############"
"#.......#.....#"
"#.#.###.#.###.#"
"#.....#.#...#.#"
"#.###.#####.#.#"
"#.#.#.......#.#"
"#.#.#####.###.#"
"#...........#.#"
"###.#.#####.#.#"
"#...#.....#.#.#"
"#.#.#.###.#.#.#"
"#.....#...#.#.#"
"#.###.#.#.#.#.#"
"#...#.....#...#"
"###############"
```
We initialize the queue with the starting position, the direction pointing right (1), the score at
0, and the path only consisting of the starting position:
```q
q)queue:([]pos:enlist start;dir:1;score:0;path:enlist enlist start)
q)queue
pos  dir score path
-------------------
13 1 1   0     13 1
```
We also initialize some variables: the visited list, the tiles covered by any path and the best
score (only used for part 2).
```q
q)visited:();
q)tiles:();
q)best:0W;
```
We iterate while there are items in the queue. If we run out of items, there is no solution (e.g.
fabricated input with the `S` and `E` separated by a wall).
```q
    while[count queue;
        ...
    ];
    {'x}"no solution"
```
The iteration is demonstrated in an intermediate state:
```q
q)queue
pos  dir score path
------------------------------------
13 1 2   1000  (13 1;13 1)
13 1 0   1000  (13 1;13 1)
13 2 2   1001  (13 1;13 2;13 2)
13 2 0   1001  (13 1;13 2;13 2)
13 3 2   1002  (13 1;13 2;13 3;13 3)
13 3 0   1002  (13 1;13 2;13 3;13 3)
```
We start by finding the nodes to expand. In Dijkstra's algorithm, these are the
nodes with the lowest path length (score):
```q
q)nxts:select from queue where score=min score
q)nxts
pos  dir score path
------------------------
13 1 2   1000  13 1 13 1
13 1 0   1000  13 1 13 1
```
The end-of-iteration checks come at this point - see further down for details.

We delete the expanded node(s) from the queue:
```q
q)queue:delete from queue where score=min score
q)queue
pos  dir score path
------------------------------------
13 2 2   1001  (13 1;13 2;13 2)
13 2 0   1001  (13 1;13 2;13 2)
13 3 2   1002  (13 1;13 2;13 3;13 3)
13 3 0   1002  (13 1;13 2;13 3;13 3)
```
We add the expanded nodes to the visited list:
```q
q)visited,:exec (pos,'dir) from nxts
q)visited
13 1 1
13 2 1
13 3 1
13 1 2
13 1 0
```
We expand the nodes by adding a "move forward" node and a "turn left" and "turn right" node. These
have the path and score updated as necessary.
```q
    nxts:raze{
        update path:(path,'enlist each pos) from ([]pos:enlist x[`pos]+(-1 0;0 1;1 0;0 -1)x`dir;
            dir:x`dir;score:1+x`score;path:enlist x`path),
        ([]pos:2#enlist x[`pos];dir:(x[`dir]+1 -1)mod 4;score:1000+x`score;path:2#enlist x`path)
    }each nxts;

q)nxts
pos  dir score path
-----------------------------
14 1 2   1001  13 1 13 1 14 1
13 1 3   2000  13 1 13 1 13 1
13 1 1   2000  13 1 13 1 13 1
12 1 0   1001  13 1 13 1 12 1
13 1 1   2000  13 1 13 1 13 1
13 1 3   2000  13 1 13 1 13 1
```
We delete any attempts to move into already visited states:
```q
q)nxts:delete from nxts where (pos,'dir) in visited
q)nxts
pos  dir score path
-----------------------------
14 1 2   1001  13 1 13 1 14 1
13 1 3   2000  13 1 13 1 13 1
12 1 0   1001  13 1 13 1 12 1
13 1 3   2000  13 1 13 1 13 1
```
We also delete attempts to move into a wall:
```q
q)nxts:delete from nxts where "#"=map ./:pos
q)nxts
pos  dir score path
-----------------------------
13 1 3   2000  13 1 13 1 13 1
12 1 0   1001  13 1 13 1 12 1
13 1 3   2000  13 1 13 1 13 1
```
We update the queue by selecting the nodes with minimal scores. Note that we *do not* deduplicate
the nodes because we need to hold onto the paths for part 2.
```q
q)queue:select from queue,nxts where score=(min;score)fby ([]pos;dir)
q)queue
pos  dir score path
------------------------------------
13 2 2   1001  (13 1;13 2;13 2)
13 2 0   1001  (13 1;13 2;13 2)
13 3 2   1002  (13 1;13 2;13 3;13 3)
13 3 0   1002  (13 1;13 2;13 3;13 3)
13 1 3   2000  (13 1;13 1;13 1)
12 1 0   1001  (13 1;13 1;12 1)
13 1 3   2000  (13 1;13 1;13 1)
```
The end-of-iteration check (see above for when it is done) looks for the end position in the nodes
to be expanded:
```q
q)end in exec pos from nxts
1b
q)nxts
pos  dir score path
--------------------------------------------------------------------------------------------------..
1 13 0   7036  13 1  13 1  12 1  11 1  11 1  11 2  11 3  11 4  11 5  11 5  10 5  9  5  8  5  7  5 ..
1 13 0   7036  13 1  13 1  12 1  11 1  10 1  9  1  9  1  9  2  9  3  9  3  8  3  7  3  7  3  7  4 ..
1 13 0   7036  13 1  13 1  12 1  11 1  11 1  11 2  11 3  11 3  10 3  9  3  8  3  7  3  7  3  7  4 ..
```
If we are in this state, we filter to only those nodes that have the end position. This is necessary
because in the real input it may occur that when we reach this state, there are other nodes in the
queue with the exact same score but not in the finish position.
```q
q)good:select from nxts where pos~\:end
```
We find the best score from the nodes:
```q
q)best:exec min score from good
q)best
7036
```
This is the answer for part 1.

We extract the distinct path tiles from the good nodes:
```q
q)tiles:distinct raze exec path from good;
q)tiles
13 1
12 1
11 1
11 2
11 3
..
```
The following can be used to visualize the paths on the map:
```q
q)-1 .[;;:;"O"]/[map;tiles];
###############
#.......#....O#
#.#.###.#.###O#
#.....#.#...#O#
#.###.#####.#O#
#.#.#.......#O#
#.#.#####.###O#
#..OOOOOOOOO#O#
###O#O#####O#O#
#OOO#O....#O#O#
#O#O#O###.#O#O#
#OOOOO#...#O#O#
#O###.#.#.#O#O#
#O..#.....#OOO#
###############
```
The count of the tiles is the answer to part 2:
```q
q)count tiles
45
```
