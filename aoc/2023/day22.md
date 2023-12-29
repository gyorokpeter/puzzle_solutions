# Overview
We simulate the falling bricks by going from the bottom up, maintaining a height map, since the x and y coordinates are in a very narrow range (3x3 for the example and 5x5 for the real input).

# Breakdown

Example input:
```q
x:"\n"vs"1,0,1~1,2,1\n0,0,2~2,0,2\n0,2,3~2,2,3\n0,0,4~0,2,4\n2,0,5~2,2,5\n0,1,6~2,1,6\n1,1,8~1,1,9";
```

## Common
The two parts will be solved by the same function, to avoid redoing the same calculations twice. The `d22p1` and `d22p2` functions only index into the result and are there for the formality.

### The move function
The function `.d22.move` takes one argument, the _expanded_ coordinates of all the bricks. Expanded means all the individual coordinates covered by the brick must be included. The positions must also be sorted from bottom to top. This is important to note because the example input is sorted this way but the real input isn't.
```q
q)poss
(1 0 1;1 1 1;1 2 1)
(0 0 2;1 0 2;2 0 2)
(0 2 3;1 2 3;2 2 3)
(0 0 4;0 1 4;0 2 4)
(2 0 5;2 1 5;2 2 5)
(0 1 6;1 1 6;2 1 6)
(1 1 8;1 1 9)
```
We initialize a height map with all zeros:
```q
q)h:(1+max raze poss[;;0 1])#0
q)h
0 0 0
0 0 0
0 0 0
```
We also initialize an array to keep track of which bricks moved.
```q
q)moved:count[poss]#0b
q)moved
0000000b
```
We iterate through the bricks and move each one in turn:
```q
i:0; while[i<count poss; ... i+:1];
```
We pick the current brick from the list:
```q
curr:poss i
```
We generate the floor plan of the brick, i.e. only the x and y coordinates:
```q
fp:distinct curr[;0 1]
```
We find the next z coordinate by looking at the positions in the height map corresponding to the floor plan, taking the maximum and adding 1:
```q
nz:1+max h ./:fp
```
We find how many units to move down by subtracting the new z coordinate from the lowest z coordinate in the brick:
```q
move:min[curr[;2]-nz]
```
We check whether the brick actually moved and update the array:
```q
moved[i]:move>0
```
We update the z coordinates of the brick by subtracting the move distance:
```q
poss[i;;2]-:move
```
We update the height map to the highest z coordinate at the floor plan positions:
```q
h:.[;;:;max poss[i;;2]]/[h;fp]
```
The return value is the updated positions and the moved array.

### Main logic
We split the input and convert it to integers:
```q
q)pos:"J"$","vs/:/:"~"vs/:x
q)pos
1 0 1 1 2 1
0 0 2 2 0 2
0 2 3 2 2 3
0 0 4 0 2 4
2 0 5 2 2 5
0 1 6 2 1 6
1 1 8 1 1 9
```
We expand each brick such that we have all the coordinates covered by all the bricks:
```q
q)poss:pos[;0]+/:'{c:abs max each x;(til each 1+c)*\:'0^x div c}pos[;1]-pos[;0]
q)poss
(1 0 1;1 1 1;1 2 1)
(0 0 2;1 0 2;2 0 2)
(0 2 3;1 2 3;2 2 3)
(0 0 4;0 1 4;0 2 4)
(2 0 5;2 1 5;2 2 5)
(0 1 6;1 1 6;2 1 6)
(1 1 8;1 1 9)
```
We sort the list by the bottommost z coordinate of each brick:
```q
q)zs:min each poss[;;2]; zi:iasc zs; poss:poss zi;
q)poss
(1 0 1;1 1 1;1 2 1)
(0 0 2;1 0 2;2 0 2)
(0 2 3;1 2 3;2 2 3)
(0 0 4;0 1 4;0 2 4)
(2 0 5;2 1 5;2 2 5)
(0 1 6;1 1 6;2 1 6)
(1 1 8;1 1 9)
```
We perform the possible moves from this starting position:
```q
q)poss:first .d22.move poss
q)poss
(1 0 1;1 1 1;1 2 1)
(0 0 2;1 0 2;2 0 2)
(0 2 2;1 2 2;2 2 2)
(0 0 3;0 1 3;0 2 3)
(2 0 3;2 1 3;2 2 3)
(0 1 4;1 1 4;2 1 4)
(1 1 5;1 1 6)
```
We now perform the moves with each brick removed in turn, and this time we are interested in which bricks moved:
```q
q)rs:last each .d22.move each poss _/:til count poss
q)rs
111111b
000000b
000000b
000000b
000000b
000001b
000000b
```
For part 1, the answer is the number of rows with all zeros:
```q
q)sum all each 0=rs
5i
```
For part 2, the answer is the sum of all the values:
```q
q)sum sum each rs
7i
```
