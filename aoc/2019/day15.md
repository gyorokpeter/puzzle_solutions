# Breakdown
Example input:
```q
q)md5 raze x
0x04fa9a33609965d6c451ddf8055fd7f1
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common

## Part 1
The core of the solution is a vector BFS. It is different from regular BFS in that it processes an
entire level in one go. We use the BFS in 3 ways:
* During map exploration to find an unexplored tile. We keep the path and follow it with the robot.
We repeat until no path is returned, which is when the map is complete.
* After the map is discovered, to find a path from the origin to the oxygen source.
* To find the longest path from the oxygen source. To do this there is a specific parameter that
causes the function to return the number of iterations instead of an empty path. It is easy to make
an off-by-one error on this one.

### .d15.findDest
This function implements the BFS. It takes four parameters:
* `grid` is the grid to search, with `0` indicating walls, `1` indicating passable tiles, and `0N`
indicating undiscovered tiles.
* `cursor` is the starting position (row and column).
* `target` is the type of tile to search for.
* `rettype` is 1 to return the maximum path length, anything else to return the path to the target.

We initialize the queue with the cursor:
```q
    queue:enlist cursor;
```
We initialize a parent map with a dummy element (this is to make sure that out-of-bounds indexing
returns the correct type):
```q
    parent:enlist[0N 0N]!enlist 0N 0N;
```
We initialize the iteration count to zero:
```q
    iter:0;
```
We iterate until the queue is empty. This can happen if the target is not found. If it is found,
we exit inside the loop.
```q
    while[0<count queue;
        ...
    ];
```
Inside the iteration, we increase the iteration counter:
```q
    iter+:1;
```
We find the next positions by adding all four cardinal directions to the queue elements:
```q
    nxts:queue+/:\:(-1 0;0 1;1 0;0 -1);
```
We look up the tile at each potential next position:
```q
    nxtt:grid ./:/:nxts;
```
We filter the next positions to only the passable tiles and also discard any already visited
positions based on the parent map:
```q
    nxts:(nxts@'where each 0<>nxtt)except\:value parent;
```
We update the parent map by putting in the queue nodes mapped to the corresponding next nodes:
```q
    parent[raze nxts]:raze (count each nxts)#'enlist each queue;
```
We update the queue to contain only the next nodes:
```q
    queue:raze nxts;
```
We check if the target tile is in the queue:
```q
    if[0<count arrive:where target=grid ./:queue;
        ...
    ];
```
If it is, we find the first such tile:
```q
    foundTarget:queue first arrive;
```
Then we iterate the parent map to trace the path backwards using the `\` (scan) iterator, stopping
when the output no longer changes (this happens on hitting the dummy initial node). We reverse the
path to make it go forward, then drop the first two elements which are useless for the path, and
return the resulting path.
```q
    :2_reverse parent\[foundTarget];
```
If the iteration finishes without returning, it means we haven't found the target tile. We return
either the iteration count minus 1, or an emtpy path, depending on the `rettype` parameter:
```q
    $[rettype=1;iter-1;()]
```

### .d15.buildMap
This function builds the map, given the intcode VM initial state.

We initialize the map to a 3x3 matrix with the center marked as a known empty tile and the rest as
unknown tiles:
```q
q)grid:3 3#0N
q)grid[1;1]:1
q)grid

 1

```
We initialize a `cursor` variable (the bot's current location) and the origin. They both start at
the middle tile (coordinates `1 1`). The origin does need to be stored because that can change
during the exploration as well.
```q
q)cursor:origin:1 1
```
We initialize a variable to indicate whether the iteration should continue, as well as a path that
needs to be traced, which is initially empty:
```q
q)run:1b
q)dest:()
```
We iterate as long as the `run` variable is true:
```q
    while[run;
        ...
    ];
```
In the iteration, if the current path is empty, we try to generate a new one by calling the
pathfinding function, looking for unexplored (`0N`) tiles:
```q
q)if[0=count dest; dest:.d15.findDest[grid;cursor;0N;0]]
q)dest
0 1
```
We check if the path is empty. If it is, we are done with the iteration.
```q
    if[0=count dest; run:0b];
```
The rest of the iteration code only needs to be executed if we are still running the iteration:
```q
    if[run;
        ...
    ];
```
We find the delta between the next position in the path and the cursor position:
```q
q)delta:dest[0]-cursor
q)delta
-1 0
```
We use a lookup list to convert this to a direction understood by the bot:
```q
q)(-1 0;1 0;0 -1;0 1)?delta:dest[0]-cursor
0
q)dir:1+(-1 0;1 0;0 -1;0 1)?delta:dest[0]-cursor
q)dir
1
```
We delete the first element of the path:
```q
q)dest:1_dest
q)dest
```
We run the interpreter, providing the calculated direction as input:
```q
q)a:.intcode.runI[a;enlist dir]
q)out:.intcode.getOutput a
q)out
,1
```
If the intcode program has terminated, we mark the iteration to be stopped:
```q
q)run:not .intcode.isTerminated a
q)run
1b
```
We update the grid at the next tile of the path with the output from the program:
```q
q)grid:.[grid;cursor+delta;:;first out]
q)grid
 1
 1

```
If the output indicates that the tile is passable (not zero), we update the current tile position:
```q
q)if[0<>first out; cursor+:delta]
q)cursor
0 1
```
If the current position is at the edge of the known grid, we expand the grid by adding a row or
column of unknown tiles. If this results in adding a row at the top or the column at the left, we
also need to update the current position, the origin and all of the positions in the path.
```q
q)if[0=cursor[0]; grid:enlist[(count first grid)#0N],grid;cursor+:1 0;origin+:1 0;dest:dest+\:1 0];
q)if[0=cursor[1]; grid:0N,/:grid;cursor+:0 1;origin+:0 1;dest:dest+\:0 1];
q)if[cursor[0]=count[grid]-1; grid,:enlist count[first grid]#0N];
q)if[cursor[1]=count[first grid]-1; grid:grid,\:0N];
q)grid

 1
 1

```
It is useful to have a debug display, where we replace the numbers with visualization characters and
also mark the current position:
```q
q)-1 count[first grid]#"=";-1 disp;
===

 *
 .

```
This is the end of the iteration block.

After the iteration, we have a full grid:
```q
q)-1 count[first grid]#"=";-1 disp;
=========================================
 ########### ##################### #####
#...........#.....................#.....#
#.#.#.#######.###########.#####.#.###.#.#
#.#.#.#.......#.#.......#...#...#...#.#.#
#.#.#.#.#######.#.#####.#.###.#####.###.#
#.#.#.#...#.....#.#...#.#.#...#...#.....#
 ##.#####.#.#.###.#.###.###.###.#.#####.#
#...#.....#.#.#...#.......#.....#.#x#...#
#.###.#######.#.#########.#######.#.#.##
#.#...#.......#.......#.#.........#.....#
#.#.###.#####.#####.#.#.#.##############
#.#.#.....#...#...#.#.#...#.....#...#...#
#.#.#.###.#.###.#.#.#.#####.###.#.#.#.#.#
#...#.#...#...#.#.#.#.........#.#.#.#.#.#
#.#####.#####.#.#.## ##########.#.#.#.#.#
#.......#...#.#.#...#...#...#...#.#...#.#
 ########.###.#.###.#.#.#.#.#.###.#####.#
#.#...........#.#.....#...#.#.........#.#
#.#.###########.#.#### ####.###.#######.#
#...#.......#.#.#.#...#...#...#.#.......#
#.###.#####.#.#.###.#.#.#.###.#.#.######
#...#...#.....#.....#*#.#...#.#.#.......#
 ##.#.#.#####.#########.#####.#####.###.#
#...#.#...#.#.#.......#.....#.....#.#...#
#.###.###.#.#.#.#####.#####.#####.#.#.##
#.#...#...#.#...#.#...#.......#...#.#...#
#.#####.###.#####.#.###.#####.#.#######.#
#.......#...#...#...#...#.....#.........#
 ########.#.#.#.#.#####.#.#### #########
#.........#.#.#.#.#...#.#...#.#...#.....#
#.###.#####.#.#.#.#.#.#.###.#.#.#.#.#.##
#...#.....#...#.#.#.#...#.#.#.#.#.#.#...#
 ##.#####.#####.#.#.#####.#.#.#.#.#.###.#
#.#.#...#...#...#.#.#.....#.#.#.#...#...#
#.#.#.#.###.#####.#.#.#####.#.#.#####.##
#.#.#.#.....#.....#.#...#...#.#.#...#...#
#.#.#.###.###.#####.###.#.###.#.###.###.#
#...#...#.#...#.....#...#...#.......#...#
#.#####.###.###.#####.#####.#########.#.#
#.....#.........#.....................#.#
 ##### ######### ##################### #
```
We return the grid and the updated origin position.
```q
    .d15.buildMap:{[a]
        ...
    (grid;origin)};
```

## Part 1
We initialize the intcode VM:
```q
q)a:.intcode.new x
```
We use the function above to generate the map:
```q
q)go:.d15.buildMap[a]
```
We call the pathfinding function again, this time passing in the map and updated origin position,
as well as the target tile type of `2` and the "path" output mode:
```q
q).d15.findDest[go 0;go 1;2;0]
20 21
19 21
19 20
19 19
20 19
..
```
The answer is the count of the path:
```q
q)count .d15.findDest[go 0;go 1;2;0]
232
```

## Part 2
Continuing from part 1, we find the tile with the value `2` using a
[2D search](../utils/patterns.md#2d-search):
```q
q)grid:go 0
q)origin:first raze til[count grid],/:'where each grid=2
q)origin
7 35
```
We call the pathfinding function with the generator as the origin, looking for the value `3`, which
is never in the grid, so this will keep searching until all the possible paths are exhausted. We
also pass in the "length" return mode, which will give us the length of the longest path.
```q
q).d15.findDest[grid;origin;3;1]
320
```

## Whiteboxing
The intcode program contains the representation of the map, however a BFS is still requried to get
the answer for both parts. The map is encoded with the resolution vertically halved. The code has
explicit returns to ensure that the borders are walls, any tile with both coordinates even are
walls, and any tile with both coordinates odd are open. This way only the odd indices of the even
rows and the even indices of the odd rows need to be stored, thus allowing for the vertical size
reduction. Furthermore, teach tile has a single corresponding number, but not in a straightforward
binary way (e.g. 0=wall, 1=empty), but they are seemingly random numbers, and whether there is a
wall on a tile is indicated by the number being higher or lower than a fixed threshold value.

### .d15.buildMapWhitebox
We extract the 39*20 numbers making up the condensed map:
```q
q)a:"J"$","vs raze x
q)(39*20)#252_a
4 23 34 36 20 5 93 36 72 13 75 47 14 34 44 15 61 24 50 12 76 22 40 17 13 24 59 32 99 35 33..
```
We compare it to the threshold (which is at address 212) and cut to rows of length 39:
```q
q)0+39 cut a[212]>(39*20)#252_a
1 1 1 1 1 1 0 1 0 1 0 0 1 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1
1 0 1 0 1 0 1 1 0 1 0 1 0 0 1 0 1 1 0 1 0 1 1 0 1 1 0 0 1 1 0 0 0 1 1 0 0 0 1
..
```
(The `0+` is there to cast to long. It is shorter than writing ``` `long$```.)

The following process is done on each row:

We cut the row into lists of two elements:
```q
q)r0:1 1 1 1 1 1 0 1 0 1 0 0 1 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1
q)r:2 cut r0
q)r
1 1
1 1
1 1
0 1
0 1
0 0
1 1
0 1
0 1
0 1
0 1
0 1
1 1
0 1
0 1
1 1
1 0
0 1
1 1
,1
```
The first element of each small list will correspond to the bottom row, while the second element of
each small list will correspond to the top row.
```q
q)(r[;1];r[;0])
1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 1
1 1 1 0 0 0 1 0 0 0 0 0 1 0 0 1 1 0 1 1
```
To put in the hardcoded elements, we have to prepend a `1` (empty tile) to each element in the top
row, and append a `0` (wall) to each element in the bottom row:
```q
q).Q.s1 (1,/:r[;1];r[;0],\:0)
"((1 1;1 1;1 1;1 1;1 1;1 0;1 1;1 1;1 1;1 1;1 1;1 1;1 1;1 1;1 1;1 1;1 0;1 1;1 1;1 0N);(1 0;1 0;1 0;..
```
This is still nested one level too deep so we raze each row:
```q
q)raze each(1,/:r[;1];r[;0],\:0)
1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1
1 0 1 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 1 0 1 0
```
There is an extra null at the end of the first row. This got there because the two rows are of
unequal length but when indexing the pairs it didn't cause an error (there is no "out of bounds
error" in q). So we need to cut off the last elements:
```q
q)(-1_/:raze each(1,/:r[;1];r[;0],\:0))
1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1
1 0 1 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 1 0 1
```
Then we add the first and last zeros to the rows:
```q
q)0,/:(-1_/:raze each(1,/:r[;1];r[;0],\:0)),\:0
0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0
0 1 0 1 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 1 0 1 0
```
The processing for a single row is complete, we can wrap it in a function and apply it to the whole
grid:
```q
q){[r0]r:2 cut r0;0,/:(-1_/:raze each(1,/:r[;1];r[;0],\:0)),\:0}each 0+39 cut a[212]>(39*20)#252_a
0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0 0 1 ..
0 1 0 1 0 1 0 1 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1 0 1 0 1 0 0 1 ..
..
```
We need to raze to get the final grid shape:
```q
q)raze{[r0]r:2 cut r0;0,/:(-1_/:raze each(1,/:r[;1];r[;0],\:0)),\:0}each 0+39 cut a[212]>(39*20)#252_a
0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0
0 1 0 1 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 1 0 1 0
..
```
And we also need a full-wall row at the top:
```
q)grid:enlist[41#0],raze{[r0]r:2 cut r0;0,/:(-1_/:raze each(1,/:r[;1];r[;0],\:0)),\:0}each 0+39 cut a[212]>(39*20)#252_a
q)grid
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0
0 1 0 1 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 1 0 1 0
```
The only thing that is missing is the oxygen generator. We add it by extracting the coordinates from
the intcode:
```
q)grid[a 153;a 146]:2
```
At this point the grid is exactly the same as what the search using the intcode would generate.

### Parts 1 and 2
The solutions for part 1 and 2 are the same except plugging in the grid found by the above function.
For part 1, the origin coordinates are also fixed as `21 21` (this seems to be static between
inputs).
```q
q)grid:.d15.buildMapWhitebox[a]
q)count .d15.findDest[grid;21 21;2;0]
232
q)grid:.d15.buildMapWhitebox[a]
q)origin:first raze til[count grid],/:'where each grid=2
q).d15.findDest[grid;origin;3;1]
320
```
