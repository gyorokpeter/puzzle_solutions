# Breakdown

Example input:
```q
x:();
x,:enlist"....#.....";
x,:enlist".........#";
x,:enlist"..........";
x,:enlist"..#.......";
x,:enlist".......#..";
x,:enlist"..........";
x,:enlist".#..^.....";
x,:enlist"........#.";
x,:enlist"#.........";
x,:enlist"......#...";
```

## Part 1
We cache the width and height of the field:
```q
    w:count first x; h:count x;
```
We find the guard's starting position with the [2D search](../utils/patterns.md#2d-search)
technique:
```q
q)pos:first raze til[h],/:'where each"^"=x;
q)pos
6 4
```
We replace the tile at the guard's position with a blank tile:
```q
q)a:x; a[pos 0;pos 1]:"."
q)a
"....#....."
".........#"
".........."
"..#......."
".......#.."
".........."
".#........"
"........#."
"#........."
"......#..."
```
We initialize the current direction to 0 (up), and the list of visited positions with the starting
position:
```q
    dir:0;
    visited:enlist pos;
```
We perform an iteration while the position is within the bounds of the field:
```q
    while[all pos within'(1,h-2;1,w-2);
        ...
    ];
```
We find the coordinate offset based on the current position and add it to the current position to
find the next one:
```q
    nxt:pos+(-1 0;0 1;1 0;0 -1)dir;
```
We check if the next position is an obstacle. If it is, we increase the direction, wrapping around
from 3 to 0 (so this is an addition modulo 4). If it is not, we update the visited list and replace
the current position with the next one.
```q
    $["#"=a . nxt;dir:(dir+1)mod 4;
        [pos:nxt;visited,:enlist pos]];
```
Once the iteration stops, we take the distinct visited positions and return their count.
```q
q)visited
6 4
5 4
4 4
3 4
2 4
..
q)count visited
45
q)count distinct visited
41
```

## Part 2
The first few steps are the same as part 1:
```q
    w:count first x; h:count x;
    pos:first raze til[h],/:'where each"^"=x;
    a:x; a[pos 0;pos 1]:".";
```
This time we will process multiple positions in parallel. The first position is the case of placing
no obstacles. At each step we branch off another position to place an obstacle (if there is none
already in the facing direction). The visited list will only track the no-placement path, but this
is necessary otherwise the iteration might try to place an obstacle at a position the guard already
passed through, which would make the solution invalid. We also initialize a step counter.
```q
    visited:enlist pos;
    step:0;
```
We initialize a queue with the following fields: the current position, the facing direction and the
coordinates of the placed obstacle (two nulls if not placed yet):
```q
    queue:([]enlist pos;dir:0;obstacle:enlist 0N 0N)
```
We iterate as long as there are items in the queue. However, since the paths will loop, this will
never terminate. Instead we will interrupt the iteration in the middle once the step counter passes
`w*h`. This should give every non-looping path time to step off the map. However if the iteration
ever ends early, that would indicate no looping paths so we return zero (this can occur when
experimenting with custom test cases with no way to make a loop).
```q
    while[count queue;
        step+:1;
        ...
    ];
    0
```
To demonstrate the iteration, we use an intermediate state:
```q
q)queue
pos dir obstacle
----------------
5 8 2
8 2 3   3 4
9 4 2   1 5
8 5 2   1 6
7 6 2   1 7
3 5 3   1 8
1 5 3   2 8
2 6 3   3 8
3 7 3   4 8
4 8 3   5 8
```
We calculate the next position from the current position and direction, adding it as a new column
to the queue:
```q
q)queue:update nxt:pos+(-1 0;0 1;1 0;0 -1)dir from queue
q)queue
pos dir obstacle nxt
---------------------
5 8 2            6  8
8 2 3   3 4      8  1
9 4 2   1 5      10 4
8 5 2   1 6      9  5
7 6 2   1 7      8  6
3 5 3   1 8      3  4
1 5 3   2 8      1  4
2 6 3   3 8      2  5
3 7 3   4 8      3  6
4 8 3   5 8      4  7
```
We look up the tile on the map corresponding to the next position:
```q
q)queue:update tile:a ./:nxt from queue
q)queue
pos dir obstacle nxt  tile
--------------------------
5 8 2            6  8 .
8 2 3   3 4      8  1 .
9 4 2   1 5      10 4
8 5 2   1 6      9  5 .
7 6 2   1 7      8  6 .
3 5 3   1 8      3  4 .
1 5 3   2 8      1  4 .
2 6 3   3 8      2  5 .
3 7 3   4 8      3  6 .
4 8 3   5 8      4  7 #
```
We delete any positions with a blank tile (as opposed to a `"."` tile). This will only occur for
positions off the map.
```q
q)queue:delete from queue where tile=" "
q)queue
pos dir obstacle nxt tile
-------------------------
5 8 2            6 8 .
8 2 3   3 4      8 1 .
8 5 2   1 6      9 5 .
7 6 2   1 7      8 6 .
3 5 3   1 8      3 4 .
1 5 3   2 8      1 4 .
2 6 3   3 8      2 5 .
3 7 3   4 8      3 6 .
4 8 3   5 8      4 7 #
```
We find which positions "bumped" into an obstacle by comparing the tile to `"#"`:
```q
q)queue:update bump:(tile="#") or nxt~'obstacle from queue
q)queue
pos dir obstacle nxt tile bump
------------------------------
5 8 2            6 8 .    0
8 2 3   3 4      8 1 .    0
8 5 2   1 6      9 5 .    0
7 6 2   1 7      8 6 .    0
3 5 3   1 8      3 4 .    0
1 5 3   2 8      1 4 .    0
2 6 3   3 8      2 5 .    0
3 7 3   4 8      3 6 .    0
4 8 3   5 8      4 7 #    1
```
For each bumped position, we update the direction:
```q
q)queue:update dir:(dir+1)mod 4 from queue where bump
q)queue
pos dir obstacle nxt tile bump
------------------------------
5 8 2            6 8 .    0
8 2 3   3 4      8 1 .    0
8 5 2   1 6      9 5 .    0
7 6 2   1 7      8 6 .    0
3 5 3   1 8      3 4 .    0
1 5 3   2 8      1 4 .    0
2 6 3   3 8      2 5 .    0
3 7 3   4 8      3 6 .    0
4 8 0   5 8      4 7 #    1
```
We check if we need to add a new item to the queue by placing an obstacle if the next position is
empty and it is not already a visited position:
```q
q)place:select from queue where tile=".", null first each obstacle, not nxt in visited
q)place
pos dir obstacle nxt tile bump
------------------------------
5 8 2            6 8 .    0
```
We place the obstacle and update the direction:
```q
q)place:update dir:(dir+1)mod 4, obstacle:nxt from place
q)place
pos dir obstacle nxt tile bump
------------------------------
5 8 3   6 8      6 8 .    0
```
We advance the position of the non-bumped states. This must be done after the `place` state is split
off while it still had the old position.
```q
q)queue:update pos:nxt from queue where not bump
q)queue
pos dir obstacle nxt tile bump
------------------------------
6 8 2            6 8 .    0
8 1 3   3 4      8 1 .    0
9 5 2   1 6      9 5 .    0
8 6 2   1 7      8 6 .    0
3 4 3   1 8      3 4 .    0
1 4 3   2 8      1 4 .    0
2 5 3   3 8      2 5 .    0
3 6 3   4 8      3 6 .    0
4 8 0   5 8      4 7 #    1
```
We join the newly placed state to the queue and drop the temporary columns:
```q
q)queue:delete nxt,tile,bump from queue,place
q)queue
pos dir obstacle
----------------
6 8 2
8 1 3   3 4
9 5 2   1 6
8 6 2   1 7
3 4 3   1 8
1 4 3   2 8
2 5 3   3 8
3 6 3   4 8
4 8 0   5 8
5 8 3   6 8
```
We put the obstacle-less position into the visited list:
```q
q)visited,:exec pos from queue where null first each obstacle
q)visited
6 4
5 4
..
5 8
6 8
```
If the step counter reaches `w*h`, we return the number of distinct obstacle positions:
```q
    if[step>w*h;
        :count exec distinct obstacle from queue;
    ];
```
In the example, this happens in the following state:
```q
q)step
101
q)queue
pos dir obstacle
----------------
3 8 2   6 3
6 4 3   7 6
6 8 3   8 3
8 2 3   8 1
8 6 3   7 7
7 3 1   9 7
q)count exec distinct obstacle from queue
6
```
