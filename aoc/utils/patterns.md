# Range of integers
`til` only generates integers from `0` to `n-1`. What if we need integers between the bounds `a` and
`b`? We can still use `til` but we need to carefully choose the number of integers to generate and
then use an addition to shift the numbers into the correct range.

For example to generate the integers from 10 to 15:
```q
q)a:10
q)b:15
```
The number of integers to generate is the difference between the two bounds plus one (the interval
is closed on both sides).
```q
q)b-a
5
q)1+b-a
6
q)til 1+b-a
0 1 2 3 4 5
```
To shift the numbers to the correct range, we add the lower bound:
```q
q)a+til 1+b-a
10 11 12 13 14 15
```

# 2D search
This technique allows searching for the coordinates of all elements matching a value in a matrix.

Suppose we would like to find all the occurrences of the letter `X` in the following matrix:
```q
x:();
x,:enlist"MMMSXXMASM";
x,:enlist"MSAMXMSMSA";
x,:enlist"AMXSXMAAMM";
x,:enlist"MSAMASMSMX";
x,:enlist"XMASAMXAMM";
x,:enlist"XXAMMXXAMA";
x,:enlist"SMSMSASXSS";
x,:enlist"SAXAMASAAA";
x,:enlist"MAMMMXMMMM";
x,:enlist"MXMXAXMASX";
```
We take advantage of the fact that
the `=` operator is atomic, so we just compare the matrix to a single character and get a boolean
matrix where each element indicates whether that character matches or not.
```q
q)x="X"
0000110000b
0000100000b
0010100000b
0000000001b
1000001000b
1100011000b
0000000100b
0010000000b
0000010000b
0101010001b
```
We can get the second coordinate (column) of the occurrences using the function `where`. When used
on a boolean list, it returns the indices of the true elements. Since we have a list, we have to use
it with `each`.
```q
q)where each x="X"
4 5
,4
2 4
,9
0 6
0 1 5 6
,7
,2
,5
1 3 5 9
```
The first coordinate is the index in the outer list, which we can generate using `til`:
```q
q)til[count x]
0 1 2 3 4 5 6 7 8 9
```
To join the two coordinates together, we use the `,` (concatenation) operator, however we have to
apply some iterators. First, each index must be matched to the corresponding row of the matrix,
so we use `'` (the "omnivalent each" operation):
```q
q)til[count x],'where each x="X"
0 4 5
1 4
2 2 4
3 9
4 0 6
5 0 1 5 6
6 7
7 2
8 5
9 1 3 5 9
```
However this only concatenates the index to the beginning of the list. We need to concatenate it to
every elemnt instead, so we add an _each-right_:
```q
q)til[count x],/:'where each x="X"
(0 4;0 5)
,1 4
(2 2;2 4)
,3 9
(4 0;4 6)
(5 0;5 1;5 5;5 6)
,6 7
,7 2
,8 5
(9 1;9 3;9 5;9 9)
```
We raze this list so we get a list of the coordinate pairs:
```q
q)a:raze til[count x],/:'where each x="X"
q)a
0 4
0 5
1 4
2 2
2 4
3 9
..
```
