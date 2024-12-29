# Breakdown

Example input:
```q
x:();
x,:enlist"RRRRIICCFF";
x,:enlist"RRRRIICCCF";
x,:enlist"VVRRRCCFFF";
x,:enlist"VVRCCCJFFF";
x,:enlist"VVVVCJJCFE";
x,:enlist"VVIVCCJJEE";
x,:enlist"VVIIICJJEE";
x,:enlist"MIIIIIJJEE";
x,:enlist"MIIISIJEEE";
x,:enlist"MMMISSJEEE";
```

## Common
The two parts use the same logic for finding the list of coordinates covered by each region.

We initialize a "visited" matrix by comparing the input to itself with inequality. This is a simple
way to create a boolean matrix with the same dimensions as an existing object.
```q
q)visited:x<>x
q)visited
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
```
We also initialize the output variable `regions` to an empty list:
```q
q)regions:()
```
We iterate as long as there are unvisited coordinates. We find those using the
[2D search](../utils/patterns.md#2d-search) technique:
```q
q)raze til[count x],/:'where each not visited
0 0
0 1
0 2
0 3
0 4
0 5
..
```
The iteration continues while the count of this is not zero (we don't need the `0<>` check in an
`if`). We also assign this to the variable `p` in the middle of the check to be able to reuse it in
the iteration.
```q
    while[count p:raze til[count x],/:'where each not visited;
        ...
    ];
```
During the iteration, we initialize the list of positions to the empty list:
```q
q)pos:()
```
We fetch the tile at the starting position we are examining:
```q
q)t:x . first p
q)t
"R"
```
We initialize the queue to consist of only the starting position. This time since the position is in
a list, we can take a shortcut and take a 1-long slice of this list, since that will be of the
correct shape.
```q
q)queue:1#p;
q)queue
0 0
```
We do a nested iteration while there are positions in the queue:
```q
    while[count queue;
        ...
    ];
```
We add the positions from the queue to the region under construction:
```q
q)pos,:queue
q)pos
0 0
```
We get the next coordinates for each position in the queue by adding the offsets of the four
cardinal directions:
```q
q)nxts:raze pos+/:\:(-1 0;0 1;1 0;0 -1)
q)nxts
-1 0
0  1
1  0
0  -1
```
We filter the list to only keep positions with the correct type of tile:
```q
q)nxts:nxts where t=x ./:nxts
q)nxts
0 1
1 0
```
We filter to exclude already seen positions, and also use `distinct` to ensure we only visit each
position once:
```q
q)queue:distinct nxts except pos
q)queue
0 1
1 0
```
At the end of the inner iteration, we have a list of positions that constitute the current region:
```q
q)pos
0 0
0 1
1 0
0 2
1 1
0 3
1 2
..
```
We add this list as a single element to the list of regions:
```q
q)regions,:enlist pos
q)regions
0 0 0 1 1 0 0 2 1 1 0 3 1 2 1 3 2 2 2 3 3 2 2 4
```
We also update the visited matrix to mark off the region. There is no built-in operation to update
an arbitrary set of positions in a matrix (indexed assignment can only update a whole cuboid-shaped
region at once), but it can be done using `/` (over) with
[functional amend](https://code.kx.com/q/ref/amend/), starting with the original matrix, iterating 
over the coordinates and setting the values to `1b`.
```q
q)visited:.[;;:;1b]/[visited;pos]
q)visited
1111000000b
1111000000b
0011100000b
0010000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
0000000000b
```
At the end of the outer iteration, we end up with a list of regions:
```q
q)regions
(0 0;0 1;1 0;0 2;1 1;0 3;1 2;1 3;2 2;2 3;3 2;2 4)
(0 4;0 5;1 4;1 5)
(0 6;0 7;1 6;1 7;2 6;1 8;2 5;3 5;3 4;4 4;3 3;5 4;5 5;6 5)
(0 8;0 9;1 9;2 9;3 9;2 8;3 8;2 7;4 8;3 7)
(2 0;2 1;3 0;3 1;4 0;4 1;5 0;4 2;5 1;6 0;4 3;6 1;5 3)
..
```
This is the return value of the helper function `.d12.getRegions`.

## Part 1
We get the regions using the helper function:
```q
q)r:.d12.getRegions x
```
The area is the count of each region:
```q
q)area:count each r
q)area
12 4 14 10 13 11 1 13 14 5 3
```
To find the perimeter, we add all four cardinal directions to each coordinate in each region. We
then remove any of the resulting coordinates that are in the region. The remaining coordinates
correspond to the sides of the tiles that don't have another tile of the same region in some
direction. The same coordinate can appear multiple times among the remaining coordinates, however
this is correct as each coordinate needs to be counted for each direction we reached it.

See [day 4](day4.md) for a hint on how to figure out the exact combination of iterators that make
this work.
```q
q)perim:count each (raze each r+/:\:\:(-1 0;0 1;1 0;0 -1)) except'r
q)perim
18 8 28 18 20 20 4 18 22 12 8
```
The result is the sum of the areas multiplied by the perimeters.
```q
q)area*perim
216 32 392 180 260 220 4 234 308 60 24
q)sum area*perim
1930
```

## Part 2
We once again get the regions and the area as in part 1:
```q
q)r:.d12.getRegions x
q)area:count each r
```
To find the number of sides, we once again step in each direction from the region tiles and ignore
the coordinates that are still inside the region. Then we group the coordinates along the coordinate
that was not modified (the vertical one if we moved horizontally and vice versa), and find how many
sequences are in each group. For easier readability, I have split this up to do it one direction at
a time. It would be possible to write an expression that calculates all four directions at once, but
it would get very messy due to the extra levels of nesting and the requirement to handle horiziontal
sides differently from vertical ones.

For the top sides, we add `-1 0` to the coordinates and exclude those that are in the region:
```q
q)x:(r+\:\:-1 0)except'r
q)x
(-1 0;-1 1;-1 2;-1 3;1 4)
(-1 4;-1 5)
(-1 6;-1 7;0 8;1 5;2 4;2 3;4 5)
(-1 8;-1 9;1 8;1 7)
(1 0;1 1;3 2;3 3)
..
```
We sort the coordinates, which results in a lexicographical sorting, so the tiles with the same
horizontal coordinate end up next to each other and form neat sequences along the vertical
coordinate:
```q
q)asc each x
`s#(-1 0;-1 1;-1 2;-1 3;1 4)
`s#(-1 4;-1 5)
`s#(-1 6;-1 7;0 8;1 5;2 3;2 4;4 5)
`s#(-1 8;-1 9;1 7;1 8)
`s#(1 0;1 1;3 2;3 3)
..
```
We group by the first coordinate (since we are looking at the top sides, it's the first coordinate
that is the same between positions along the same edge):
```q
q)group each x[;;0]
-1 1!(0 1 2 3;,4)
(,-1)!,0 1
-1 0 1 2 4!(0 1;,2;,3;4 5;,6)
-1 1!(0 1;2 3)
1 3!(0 1;2 3)
..
```
However this is just a list of indices. What we are interested in are the values along the second
coordinate, so we use the `@` (index) operator with `'` (each) to pairwise index into the second
coordinates. For complex cases of indexing like this, it's worth remembering that the shape of the
result is the shape of the index, and the values are the values in the index replaced by the items
in the corresponding positions in the thing being indexed. Since we are indexing with a dictionary,
the result will be a dictionary as well.
```q
q){x[;;1]@'group each x[;;0]}asc each x
-1 1!(0 1 2 3;,4)
(,-1)!,4 5
-1 0 1 2 4!(6 7;,8;,5;3 4;,5)
-1 1!(8 9;7 8)
1 3!(0 1;2 3)
..
```
We now want to find sequences in the coordinates. One way to do this is to use `deltas` on the
coordinates, as any side will have differences of 1 between its consecutive tiles, and only the
first tile will have a difference that is not 1. However `deltas` just copies the first element into
the result, which can be confusing if it happens to have a coordinate value of 1. We can work around
this by adding a dummy element with the value e.g. -10 (it just has to be some distance before the
lowest possible coordinate), calling `deltas` and then removing the copied dummy element. This way
the first side in each row will have a difference that is 10 higher than its position, but that
doesn't matter as long as it's not 1 (which is guaranteed if we choose a number like -10).
```q
q)-10,/:/:{x[;;1]@'group each x[;;0]}asc each x
-1 1!(-10 0 1 2 3;-10 4)
(,-1)!,-10 4 5
-1 0 1 2 4!(-10 6 7;-10 8;-10 5;-10 3 4;-10 5)
-1 1!(-10 8 9;-10 7 8)
1 3!(-10 0 1;-10 2 3)
q)deltas each/:-10,/:/:{x[;;1]@'group each x[;;0]}asc each x
-1 1!(-10 10 1 1 1;-10 14)
(,-1)!,-10 14 1
-1 0 1 2 4!(-10 16 1;-10 18;-10 15;-10 13 1;-10 15)
-1 1!(-10 18 1;-10 17 1)
1 3!(-10 10 1;-10 12 1)
q)1_/:/:deltas each/:-10,/:/:{x[;;1]@'group each x[;;0]}asc each x
-1 1!(10 1 1 1;,14)
(,-1)!,14 1
-1 0 1 2 4!(16 1;,18;,15;13 1;,15)
-1 1!(18 1;17 1)
1 3!(10 1;12 1)
2 3 4!(,16;,15;,17)
(,3)!,,17
3 4 7!(,19;,18;,17)
4 5 6!(,12;13 1;11 4)
6 8!(,10;11 1)
7 8!(,14;,15)
```
We compare these differences to 1 and sum the booleans to get the number of sides:
```q
q)1<>/:1_/:/:deltas each/:-10,/:/:{x[;;1]@'group each x[;;0]}asc each x
-1 1!(1000b;,1b)
(,-1)!,10b
-1 0 1 2 4!(10b;,1b;,1b;10b;,1b)
-1 1!(10b;10b)
1 3!(10b;10b)
q)sum each/:1<>/:1_/:/:deltas each/:-10,/:/:{x[;;1]@'group each x[;;0]}asc each x
-1 1!1 1i
(,-1)!,1i
-1 0 1 2 4!1 1 1 1 1i
-1 1!1 1i
1 3!1 1i
q)sum each sum each/:1<>/:1_/:/:deltas each/:-10,/:/:{x[;;1]@'group each x[;;0]}asc each x
2 1 5 2 2 3 1 3 4 2 2i
```
This is the return value of the helper function `.d12.sides`.

We can now call this function for all 4 sides. The above example was for the top side:
```q
q)sidesTop:.d12.sides (r+\:\:-1 0)except'r
q)sidesTop
2 1 5 2 2 3 1 3 4 2 2i
```
The bottom sides work the same way, simply by swapping -1 for 1:
```q
q)sidesBottom:.d12.sides (r+\:\:1 0)except'r
q)sidesBottom
3 1 6 4 3 3 1 1 4 1 1i
```
The left and right sides are only more complicated because we need to swap the coordinates to make
`.d12.sides` work correctly. This is done by reversing the coordinates.
```q
q)sidesLeft:.d12.sides reverse each/:(r+\:\:0 -1)except'r
q)sidesLeft
2 1 5 4 2 3 1 3 4 1 1i
q)sidesRight:.d12.sides reverse each/:(r+\:\:0 1)except'r
q)sidesRight
3 1 6 2 3 3 1 1 4 2 2i
```
To get the answer, we sum these four "sides" variables, then multiply by the area and sum the
results.
```q
q)sidesLeft+sidesRight+sidesTop+sidesBottom
10 4 22 12 10 12 4 8 16 6 6i
q)area*sidesLeft+sidesRight+sidesTop+sidesBottom
120 16 308 120 130 132 4 104 224 30 18
q)sum area*sidesLeft+sidesRight+sidesTop+sidesBottom
1206
```
