# Breakdown

Example input:
```q
x:"\n"vs"...........\n.....###.#.\n.###.##..#.\n..#.#...#..\n....#.#....\n.##..S####.";
x,:"\n"vs".##..#...#.\n.......##..\n.##.#.####.\n.##..##.##.\n...........";
```

## Part 1
The solution uses a function named `d21`, however the only use of this is to be able to run on the example input with less steps.
We find the start position:
```q
q)start:first raze til[count x],/:'where each x="S"
q)start
5 5
```
We replace the start with an empty space:
```q
q)x:.[x;start;:;"."]
q)x
"..........."
".....###.#."
".###.##..#."
"..#.#...#.."
"....#.#...."
".##...####."
".##..#...#."
".......##.."
".##.#.####."
".##..##.##."
"..........."
```
We use BFS to find the reachable points. This is very similar to the earlier examples in the season, the only difference is now we don't keep a visited array and just `distinct` the queue entries.
```q
do[steps;
    nxts:distinct raze queue+/:\:(-1 0;0 1;1 0;0 -1);
    nxts:nxts where all each nxts within'\:(0,count x;0,count x 0);
    nxts:nxts where "."=x ./:nxts;
    queue:nxts;
];
```
At the end the answer is the count of the queue.
```q
count queue
```

## Part 2
When doing the BFS, we only need to keep track of the minimum distance of each tile from the start. Since at each step we can choose to backtrack, and each step flips the parity of the position, we know that for any step count, all tiles whose shortest paths are up to that long and have the same parity are reachable. (There are also wide diagonal paths between the edge midpoints, but I think this is only for decor, as the fact that the edges are unblocked means we can use Manhattan distance along the edges rather than having to take those diagonal paths anyway.)

The solution makes heavy use of the shape of the input, which only applies to the real input, and once again not to the example. There is an unblocked path from the center of the square to the centers of all the edges as well as around the edges, which means it is possible to go from the start to any edge midpoint and corner via Manhattan distance. So the spreading out pattern also has a predictable structure. There are only 9 types of tiles to consider: one in the center, four in each of the cardinal directions, and four in the quadrants enclosed by the cardinal directions. Due to the regularity of the input, every tile of the same type will have the same shortest-distance matrix. The only complication is finding how many of each tile there is, and where the current step number cuts the tile, also adding in the complication of the map having an odd size so the tiles will alternate in parity. There is probably a way to algebraically express this but I chose to simply check every tile in a given radius, and keep expanding the radius until I find that there is no position that can be reached at all in any tiles at that exact radius.

We again start by finding the start position and replacing the start with an empty space:
```q
start:first raze til[count x],/:'where each x="S";
x:.[x;start;:;"."];
```
We wrap the BFS logic in a function that this time creates a matrix of shortest path lengths from a given start points:
```q
spread:{[x;start]
    d:0Nh*x<>x;
    step:0;
    queue:$[0h=type start;start;enlist start];
    while[count queue;
        d:.[;;:;step]/[d;queue];
        nxts:distinct raze queue+/:\:(-1 0;0 1;1 0;0 -1);
        nxts:nxts where all each nxts within'\:(0,count x;0,count x 0);
        nxts:nxts where "."=x ./:nxts;
        nxts:nxts where null d ./:nxts;
        queue:nxts;
        step+:1;
    ];
    d};
```
We generate the path length matrices for all the 9 types of tiles, using `w` as a shorthand for the size of the map:
```q
center:spread[x;start]
top:spread[x;(w-1;w div 2)]
bottom:spread[x;(0;w div 2)]
left:spread[x;(w div 2;w-1)]
right:spread[x;(w div 2;0)]
topLeft:spread[x;(w-1;w-1)]
topRight:spread[x;(w-1;0)]
bottomLeft:spread[x;(0;w-1)]
bottomRight:spread[x;0 0]
```
We use a helper function to find how many positions are reachable in a given number of steps, encapsulating the logic that the parity of the path length must be the same as the step count, and the path cannot be longer than the step count:
```q
cap:{[arr;step]n:raze[arr];sum ((n mod 2)=step mod 2)and n<=step}
```
We use this to precalculate the number of steps for each tile type from 0 to `-1+2*w` steps, as we will be relying on checking these values a lot:
```q
caps:cap/:\:[(center;top;topRight;right;bottomRight;bottom;bottomLeft;left;topLeft);til 2*w]
```
We further add a helper function that takes one row of `caps`, an offset and a step count, and determines how many positions are reachable if the tile is shifted by adding the offset to the position with the path count of 0. If the step count is too low, we return 0, if it is too high, we return an odd- or even-indexed element from the end of the list, and otherwise we index into the list.
```q
lcap:{[w;c;ofs;step]$[step<ofs;0;step<ofs+2*w;c step-ofs;c -2+count[c]+(step-ofs)mod 2]}[w]
```
We do an iteration to check a "ring" for reachable position counts, and once we find a ring that has no reachable positions, we return the total. The starting value of the total is the number of reachable positions in the center tile:
```q
total:lcap[caps 0;0;steps]
```
We initialize the range to 0 and the continuation flag to true:
```q
range:0;
cont:1b;
while[cont; ... ]
```
During each step, we first increment the range (even in the first step, as the range of 0 is checked in the initialization):
```q
range+:1
```
We add up the number of reachable positions at the current range. For orthogonal tiles, there is only one tile of each type that is at this range, but we have to be careful when calculating the offset. The initial offset when we step into the tile is `1+w div 2`, then each increase in the range adds `w` more, but not the first one. So the offset is `(w*range-1)+1+w div 2`.
```q
part:sum lcap[;(w*range-1)+1+w div 2;steps]each caps 1 3 5 7
```
We do the same for the quadrant tiles - this time the number of each type equals the range (it's a diagonal connecting two tiles on the orthogonal lines), so we must multiply the counts by `range`. The offset is `w+1` when we first enter the tile and then an additional `w` for every increase of the range, so overall it's `1+w*range`:
```q
part+:range*sum lcap[;1+w*range;steps]each caps 2 4 6 8
```
We add this partial sum to the total and set the continuation flag to whether the partial sum was nonzero. If it is zero we don't need to check anything since any higher ranges will also return zero.
```q
total+:part
cont:part>0
```
At the end of the iteration, the `total` variable contains the answer.
