# Breakdown
Example input:
```q
x:enlist"se,sw,se,sw,sw"
```

## Common
First, we split the string on commas and turn each piece into a symbol.
```q
q)`$","vs first x
`se`sw`se`sw`sw
```
Next, we use a mapping to the coordinate changes each step leads to. See 
https://www.redblobgames.com/grids/hexagons/ for an explanation on hexagonal coordinates
(the section "Distances/Cube coordinates" is most relevant here).
```q
q)(`n`ne`se`s`sw`nw!(0 1 -1;1 0 -1;1 -1 0;0 -1 1;-1 0 1;-1 1 0))`$","vs first x
1  -1 0
-1 0  1
1  -1 0
-1 0  1
-1 0  1
```
This is the return value of the common function `d11`.

## Part 1
The `sum` function works component-wise, so by adding up the coordinate changes from the steps, we
get the coordinates of the final position.
```q
q)sum d11 x
-1 -2 3
```
Since we are looking for the distance from the origin, the result is just the highest absolute value
among the 3 coordinates.
```q
q)max abs sum d11 x
3
```

## Part 2
We use `sums` instead of `sum` to get a list of every visited position:
```q
q)sums d11 x
1  -1 0
0  -1 1
1  -2 1
0  -2 2
-1 -2 3
```
This time we want the max of each position (row) rather than each coordinate (column), so we use
`max each`.
```q
q)max each abs sums d11 x
1 1 2 2 3
```
The maximum of this list is the furthest distance visited.
```q
q)max max each abs sums d11 x
3
```
