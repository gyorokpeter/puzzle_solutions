# Breakdown
Example input:
```q
x:"\n"vs"1, 1\n1, 6\n8, 3\n3, 4\n5, 5\n8, 9"
```

## Common
We use a helper function (`d6prep`) to preprocess the input.

We cut the lines on `", "`, convert to integers and swap the order (such that X,Y becomes row,
column):
```q
q)c:reverse each"J"$", "vs/:x
q)c
1 1
6 1
3 8
4 3
5 5
9 8
```
We normalize the coordinates by subtracting the minimum in each coordinate and adding 1 (this
doesn't affect the example since `1 1` is already the top left, but this matters for the real
input).
```q
q)c1:c-\:-1+min c
q)c
1 1
6 1
3 8
4 3
5 5
9 8
```
We calculate the grid size by taking the maximum in each coordinate, and allowing for one row/column
for padding, so we add 2 to the maximum coordinate (if there was no padding, we would only be adding
1):
```q
q)sz:2+max c1
q)sz
11 10
```
We create a grid, putting in the coordinates by using `,` (concatenation) with `/:\:` (combinaiton
of each right and each left):
```q
q)grid:til[first sz],/:\:til[last sz]
q)grid
0 0  0 1  0 2  0 3  0 4  0 5  0 6  0 7  0 8  0 9
1 0  1 1  1 2  1 3  1 4  1 5  1 6  1 7  1 8  1 9
2 0  2 1  2 2  2 3  2 4  2 5  2 6  2 7  2 8  2 9
3 0  3 1  3 2  3 3  3 4  3 5  3 6  3 7  3 8  3 9
4 0  4 1  4 2  4 3  4 4  4 5  4 6  4 7  4 8  4 9
5 0  5 1  5 2  5 3  5 4  5 5  5 6  5 7  5 8  5 9
6 0  6 1  6 2  6 3  6 4  6 5  6 6  6 7  6 8  6 9
7 0  7 1  7 2  7 3  7 4  7 5  7 6  7 7  7 8  7 9
8 0  8 1  8 2  8 3  8 4  8 5  8 6  8 7  8 8  8 9
9 0  9 1  9 2  9 3  9 4  9 5  9 6  9 7  9 8  9 9
10 0 10 1 10 2 10 3 10 4 10 5 10 6 10 7 10 8 10 9
```
We calculate the distance from each of the given points to each point in the grid. This time we need
two `\:` (each left) and one `/:` (each right) to get the ranks of the operations correct.
```q
q)grid-\:\:/:c1
-1 -1 -1 0  -1 1  -1 2  -1 3  -1 4  -1 5  -1 6  -1 7  -1 8  0 -1  0 0   0 1   0 2   0 3   0 4   0 ..
-6 -1 -6 0  -6 1  -6 2  -6 3  -6 4  -6 5  -6 6  -6 7  -6 8  -5 -1 -5 0  -5 1  -5 2  -5 3  -5 4  -5..
-3 -8 -3 -7 -3 -6 -3 -5 -3 -4 -3 -3 -3 -2 -3 -1 -3 0  -3 1  -2 -8 -2 -7 -2 -6 -2 -5 -2 -4 -2 -3 -2..
-4 -3 -4 -2 -4 -1 -4 0  -4 1  -4 2  -4 3  -4 4  -4 5  -4 6  -3 -3 -3 -2 -3 -1 -3 0  -3 1  -3 2  -3..
-5 -5 -5 -4 -5 -3 -5 -2 -5 -1 -5 0  -5 1  -5 2  -5 3  -5 4  -4 -5 -4 -4 -4 -3 -4 -2 -4 -1 -4 0  -4..
-9 -8 -9 -7 -9 -6 -9 -5 -9 -4 -9 -3 -9 -2 -9 -1 -9 0  -9 1  -8 -8 -8 -7 -8 -6 -8 -5 -8 -4 -8 -3 -8..
```
To get the Manhattan distance, we take the absolute values of all the numbers and sum the pairs.
The pairs are at the third level, so we use `each` with two `/:` iterators.
```q
q)dist:sum each/:/:abs grid-\:\:/:c1
q)dist
2  1 2  3  4  5  6  7  8  9  1  0 1  2  3  4  5  6  7  8  2  1 2  3  4  5  6  7  8  9  3  2 3  4  ..
7 6 7 8 9 10 11 12 13 14     6 5 6 7 8 9  10 11 12 13     5 4 5 6 7 8  9  10 11 12     4 3 4 5 6 7..
11 10 9  8  7  6  5 4 3 4    10 9  8  7  6  5  4 3 2 3    9  8  7  6  5  4  3 2 1 2    8  7  6  5 ..
7 6 5 4 5 6 7 8  9  10       6 5 4 3 4 5 6 7  8  9        5 4 3 2 3 4 5 6  7  8        4 3 2 1 2 3..
10 9 8 7 6 5 6 7 8 9         9  8 7 6 5 4 5 6 7 8         8  7 6 5 4 3 4 5 6 7         7  6 5 4 3 ..
17 16 15 14 13 12 11 10 9 10 16 15 14 13 12 11 10 9  8 9  15 14 13 12 11 10 9  8  7 8  14 13 12 11..
```
The return value is the distance matrix and the list of shifted coordinates:
```q
    (dist;c1)
```

## Part 1
We call the preprocessing function and extract the two components of the result:
```q
q)cd:d6prep x;dist:cd 0;c1:cd 1;
```
We find the minimum distance for each point in the grid. Simply using `min` on the 3-dimensional
matrix achieves this, as the first coordinate is the index of the reference point, and the second
and third coordinates are the row and column in the matrix, which are left alone by the aggregation:
```q
q)md:min dist
q)md
2 1 2 3 4 5 5 4 3 4
1 0 1 2 3 4 4 3 2 3
2 1 2 2 3 3 3 2 1 2
3 2 2 1 2 2 2 1 0 1
3 2 1 0 1 1 2 2 1 2
2 1 2 1 1 0 1 2 2 3
1 0 1 2 2 1 2 3 3 4
2 1 2 3 3 2 3 3 2 3
3 2 3 4 4 3 3 2 1 2
4 3 4 5 4 3 2 1 0 1
5 4 5 6 5 4 3 2 1 2
```
We check which point is the closest by matching the distances in the 3D matrix with the minimum
distances for each cell:
```q
q)dist=\:md
1111110000b 1111110000b 1110000000b 1100000000b 0000000000b 0000000000b 0000000000b 0000000000b 00..
0000000000b 0000000000b 0000000000b 0000000000b 1100000000b 1110000000b 1111000000b 1111000000b 11..
0000001111b 0000001111b 0000001111b 0000001111b 0000000111b 0000000011b 0000000011b 0000000000b 00..
0000000000b 0000000000b 0001100000b 0011100000b 1111100000b 0011000000b 0001000000b 0001000000b 00..
0000010000b 0000010000b 0000010000b 0000010000b 0000011000b 0000111100b 0000111100b 0000111000b 00..
0000000000b 0000000000b 0000000000b 0000000000b 0000000000b 0000000000b 0000000011b 0000000111b 00..
```
We could use `where` to find the index of the reference point for each cell, but `where` takes a
list and is not atomic, so we need to shift the point index down to the third coordinate. `flip`
essentially swaps the first two coordinates of a multi-dimensional matrix, and `each` allows
lowering a function by one or more levels, so we can combine these two operations to shuffle the
coordinates in any way necessary. In particular, to move the point index from first to third
position, we flip the entire matrix first, moving it to the second coordinate, then we do `flip
each`, which then moves it from second to third coordinate.
```q
q)flip each flip dist=\:md
100000b 100000b 100000b 100000b 100000b 100010b 001000b 001000b 001000b 001000b
100000b 100000b 100000b 100000b 100000b 100010b 001000b 001000b 001000b 001000b
100000b 100000b 100000b 000100b 000100b 000010b 001000b 001000b 001000b 001000b
100000b 100000b 000100b 000100b 000100b 000010b 001000b 001000b 001000b 001000b
010100b 010100b 000100b 000100b 000100b 000010b 000010b 001000b 001000b 001000b
010000b 010000b 010100b 000100b 000010b 000010b 000010b 000010b 001000b 001000b
010000b 010000b 010000b 010100b 000010b 000010b 000010b 000010b 001001b 001001b
010000b 010000b 010000b 010100b 000010b 000010b 000010b 000001b 000001b 000001b
010000b 010000b 010000b 010100b 000010b 000010b 000001b 000001b 000001b 000001b
010000b 010000b 010000b 010101b 000001b 000001b 000001b 000001b 000001b 000001b
010000b 010000b 010000b 010101b 000001b 000001b 000001b 000001b 000001b 000001b
```
Now we can call `where` on each cell, which requires lifting it down two levels:
```q
q)closest:where each/:flip each flip dist=\:md
q)closest
,0  ,0  ,0  ,0    ,0 0 4 ,2 ,2 ,2  ,2
,0  ,0  ,0  ,0    ,0 0 4 ,2 ,2 ,2  ,2
0   0   0   3     3  4   2  2  2   2
0   0   3   3     3  4   2  2  2   2
1 3 1 3 ,3  ,3    ,3 ,4  ,4 ,2 ,2  ,2
,1  ,1  1 3 ,3    ,4 ,4  ,4 ,4 ,2  ,2
,1  ,1  ,1  1 3   ,4 ,4  ,4 ,4 2 5 2 5
,1  ,1  ,1  1 3   ,4 ,4  ,4 ,5 ,5  ,5
,1  ,1  ,1  1 3   ,4 ,4  ,5 ,5 ,5  ,5
,1  ,1  ,1  1 3 5 ,5 ,5  ,5 ,5 ,5  ,5
,1  ,1  ,1  1 3 5 ,5 ,5  ,5 ,5 ,5  ,5
```
Now we would like to extract the index of the closest point, but only if it is unique. So we count
each cell:
```q
q)1=count each/:closest
1111101111b
1111101111b
1111111111b
1111111111b
0011111111b
1101111111b
1110111100b
1110111111b
1110111111b
1110111111b
1110111111b
```
We also generate the first element of each cell, even though only the cells corresponding to unique
values will be correct:
```q
q)first each/:closest
0 0 0 0 0 0 2 2 2 2
0 0 0 0 0 0 2 2 2 2
0 0 0 3 3 4 2 2 2 2
0 0 3 3 3 4 2 2 2 2
1 1 3 3 3 4 4 2 2 2
1 1 1 3 4 4 4 4 2 2
1 1 1 1 4 4 4 4 2 2
1 1 1 1 4 4 4 5 5 5
1 1 1 1 4 4 5 5 5 5
1 1 1 1 5 5 5 5 5 5
1 1 1 1 5 5 5 5 5 5
```
To keep only the correct values, we can use a [vector conditional](https://code.kx.com/q/ref/vector-conditional/),
which picks between two values depending on whether a boolean list is true. Normally it only works
on 1D lists, but we can extend it to a matrix by using the `'` (each) iterator. The other branch
that indicates the "false" values is the null integer, which is rendered as a blank in the console
display of the matrix.
```q
q)unique:?'[1=count each/:closest;first each/:closest;0N]
q)unique
0 0 0 0 0   2 2 2 2
0 0 0 0 0   2 2 2 2
0 0 0 3 3 4 2 2 2 2
0 0 3 3 3 4 2 2 2 2
    3 3 3 4 4 2 2 2
1 1   3 4 4 4 4 2 2
1 1 1   4 4 4 4
1 1 1   4 4 4 5 5 5
1 1 1   4 4 5 5 5 5
1 1 1   5 5 5 5 5 5
1 1 1   5 5 5 5 5 5
```
We find which regions are finite. We do this by checking all four edges of the matrix, which is why
the coordinates were shifted to have `1 1` on top instead of `0 0`, and also why we added 2 to find
the size instead of 1.
```q
q)unique[0]
0 0 0 0 0 0N 2 2 2 2
q)last[unique]
1 1 1 0N 5 5 5 5 5 5
q)unique[;0]
0 0 0 0 0N 1 1 1 1 1 1
q)last each unique
2 2 2 2 2 2 0N 5 5 5 5
q)finite:til[count c1] except unique[0],last[unique],unique[;0],last each unique
q)finite
3 4
```
We find the region size for each of the finite regions. We do this by comparing the ID matrix with
each of the finite region IDs in turn:
```q
q)unique=/:finite
0000000000b 0000000000b 0001100000b 0011100000b 0011100000b 0001000000b 0000000000b 0000000000b 00..
0000000000b 0000000000b 0000010000b 0000010000b 0000011000b 0000111100b 0000111100b 0000111000b 00..
```
Then we sum each element twice to collapse them into single numbers:
```q
q)finiteDist:sum each sum each unique=/:finite
q)finiteDist
9 17i
```
The answer is the maximum of these areas:
```q
q)max finiteDist
17i
```

## Part 2
The function takes an extra parameter for the range:
```q
q)rng:32
```
We call the preprocessing function and extract the first component of the result:
```q
q)dist:first d6prep x
```
The helper function has already done the heavy work of finding the distances to each reference
point, so all we have to do is sum the distances, compare against the given range, then sum the
results of that:
```q
q)sum dist
54 48 46 44 44 44 46 48 50 56
48 42 40 38 38 38 40 42 44 50
44 38 36 34 34 34 36 38 40 46
40 34 32 30 30 30 32 34 36 42
38 32 30 28 28 28 30 32 34 40
38 32 30 28 28 28 30 32 34 40
40 34 32 30 30 30 32 34 36 42
44 38 36 34 34 34 36 38 40 46
48 42 40 38 38 38 40 42 44 50
52 46 44 42 42 42 44 46 48 54
58 52 50 48 48 48 50 52 54 60
q)sum[dist]<rng
0000000000b
0000000000b
0000000000b
0001110000b
0011111000b
0011111000b
0001110000b
0000000000b
0000000000b
0000000000b
0000000000b
q)sum sum sum[dist]<rng
16i
```
