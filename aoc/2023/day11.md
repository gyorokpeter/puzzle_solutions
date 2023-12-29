# Breakdown

Example input:
```q
x:();
x,:enlist"...#......";
x,:enlist".......#..";
x,:enlist"#.........";
x,:enlist"..........";
x,:enlist"......#...";
x,:enlist".#........";
x,:enlist".........#";
x,:enlist"..........";
x,:enlist".......#..";
x,:enlist"#...#.....";
```

## Common
The solution to both parts will be a single function called `d11` which takes a `mult` parameter in addition to the map.
```q
mult:2
```
We find the coordinates of all the galaxies:
```q
q)a:raze til[count x],/:'where each"#"=x
q)a
0 3
1 7
2 0
4 6
5 1
6 9
8 7
9 0
9 4
```
We define a stretching function that expands the first coordinates with the given `mult`.

We start with the `deltas` of the coordinate:
```q
q)d:deltas[x[;0]]
q)d
0 1 1 2 1 1 2 1 0
```
For each step, the number of tiles that need stretching is the size of the step minus 1, but it shouldn't go below zero. Reminder that for integers, `or` chooses the higher of the two arguments.
```q
q)0 or d-1
0 0 0 1 0 0 1 0 0
```
We multiply these steps by one less than the multiplier (the original `d` already contains one multiple) and add it to the deltas:
```q
q)d+(m-1)*0 or d-1
0 1 1 3 1 1 3 1 0
```
We use `sums` to transform this back to the actual list of coordinates:
```q
q)sums d+(m-1)*0 or d-1
0 1 2 5 6 7 10 11 11
```
So the stretching function is:
```q
stretch:{[m;x]d:deltas[x[;0]];x[;0]:sums d+(m-1)*0 or d-1;x}[mult];
```
Note that this requires the first coordinate to be in ascending order. This is implicit in the way we calculated the coordinates, but when stretching the second coordinate we need to explicitly sort it using `asc`.

To stretch the second coordinate, we reverse the coordinates, and after stretching we don't actually need to reverse them again as after this the ordering doesn't matter:
```q
q)a:stretch a
q)b:asc reverse each a
q)b:stretch b
q)b
0  2
0  11
1  6
4  0
5  11
8  5
9  1
9  10
12 7
```
To find the distances, we subtract the coordinates in every combination, therefore we need to use `/:\:`.
```q
q)b-/:\:b
0   0  0   -9 -1  -4 -4  2  -5  -9 -8  -3 -9  1  -9  -8 -12 -5
0   9  0   0  -1  5  -4  11 -5  0  -8  6  -9  10 -9  1  -12 4
1   4  1   -5 0   0  -3  6  -4  -5 -7  1  -8  5  -8  -4 -11 -1
4  -2  4  -11 3  -6  0  0   -1 -11 -4 -5  -5 -1  -5 -10 -8 -7
5  9   5  0   4  5   1  11  0  0   -3 6   -4 10  -4 1   -7 4
8  3   8  -6  7  -1  4  5   3  -6  0  0   -1 4   -1 -5  -4 -2
9  -1  9  -10 8  -5  5  1   4  -10 1  -4  0  0   0  -9  -3 -6
9  8   9  -1  8  4   5  10  4  -1  1  5   0  9   0  0   -3 3
12 5   12 -4  11 1   8  7   7  -4  4  2   3  6   3  -3  0  0
```
The distance between two galaxies is the Manhattan distance of the coordinates, so we take the absolute value and add the differences of the two coordinates together:
```q
q)sum each/:abs b-/:\:b
0  9  5  6  14 11 10 17 17
9  0  6  15 5  14 19 10 16
5  6  0  9  9  8  13 12 12
6  15 9  0  12 9  6  15 15
14 5  9  12 0  9  14 5  11
11 14 8  9  9  0  5  6  6
10 19 13 6  14 5  0  9  9
17 10 12 15 5  6  9  0  6
17 16 12 15 11 6  9  6  0
```
Finally we sum this matrix, but since this counts every distance twice, we divide the result by 2.
```q
q)(sum sum sum each/:abs b-/:\:b)div 2
374
```

## Part 1
We call `d11` with a multiplier of 2.

## Part 2
We call `d11` with a multiplier of 1000000.
