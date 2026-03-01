# Breakdown
Example input:
```q
x:18
```

## Common
### d11tbl
This function creates the table from a seed.
```q
q)seed:18
```
We create a grid with the numbers starting from 11 repeated in each row up to the grid size:
```q
q)seed:18
q)sz:300
q)a:sz#enlist 11+til sz
q)a
11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43..
11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43..
11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43..
11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43..
11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43..
..
```
We perform the operations as described in the puzzle text to generate the power levels:
```q
q)b:(((a*seed+(1+til sz)*'a)div 100)mod 10)-5
q)b
-2 -2 -1 -1 -1 0  0  1  2  2  3  3  4  -5 -5 -4 -3 -3 -2 -1 0  1  1  2  3  4  -5 -4 -3 -2 -1 0  1 ..
-1 0  0  1  2  3  3  4  -5 -4 -3 -2 -1 0  2  3  4  -5 -3 -2 -1 1  2  4  -5 -3 -1 0  2  4  -4 -3 -1..
0  1  2  3  4  -5 -4 -3 -1 0  2  3  -5 -4 -2 -1 1  3  -5 -3 -1 1  3  -5 -2 0  2  -5 -3 0  2  -5 -2..
1  2  4  -5 -4 -2 -1 1  2  4  -4 -2 0  2  4  -4 -1 1  3  -4 -1 1  4  -3 0  3  -4 -1 2  -4 -1 3  -4..
3  4  -5 -3 -2 0  2  4  -4 -2 0  3  -5 -2 0  3  -4 -1 2  -5 -2 1  -5 -2 2  -4 0  4  -2 2  -4 0  -5..
..
```
This is the return value of the function.

### d11common
This function finds the best place for the goal window. It takes two parameters: the grid and the
window size.
```q
q)tbl:d11tbl x
q)wnd:3
```
We use the built-in [`msum`](https://code.kx.com/q/ref/sum/#msum) function to generate moving sums
of the given window size. Note that this also generates output numbers for the first `wnd-1`
elements, which are garbage for our purposes, so we drop those:
```q
q)s:(wnd-1)_/:wnd msum/:(wnd-1)_wnd msum tbl
q)s
-3  3   9   6   2   -1  -3  -4  -4  4   4   -7  -16 -16 -5  -5  -13 -21 -18 -5  7   10  3   -2  -7..
9   8   7   -3  -4  -4  -4  -2  -9  -6  -12 -9  -4  0   6   1   -2  -15 -17 -9  9   8   -2  -11 -1..
12  3   -6  -14 -12 -8  -4  1   -3  4   -8  -10 -12 -4  -4  -3  -1  -9  -16 -13 1   -5  -8  -11 -3..
5   -12 -18 -13 -8  -1  -4  4   -7  -6  -15 -3  -1  3   -2  -6  0   -3  -5  -6  -6  -6  -4  -1  3 ..
-11 -16 -10 -3  -5  -6  -5  -4  -11 -7  -12 -6  -9  0   -1  -1  0   3   -4  0   -14 -7  -9  0   0 ..
..
```
We find the maximum sum in the grid:
```q
q)ms:max max s
q)ms
29
```
We locate this maximal sum in the table using a [2D search](../utils/patterns.md#2d-search):
```q
q)mloc:first raze {til[count x],/:'x}where each s=ms
q)mloc
44 32
```
The return value is the maximal sum and the coordinates in text form (after reversing and adding 1):
```q
q)(ms;","sv string 1+reverse mloc)
29
"33,45"
```

## Part 1
We call the common function with a window size of 3 and only keep the last element (the position):
```q
q)last d11common[d11tbl x;3]
"33,45"
```

## Part 2
We call the common function for each window size from 1 to 300:
```q
q)tmp:d11common[d11tbl x]each 1+til 300
q)tmp
4   "13,1"
16  "21,15"
29  "33,45"
36  "215,9"
47  "243,45"
48  "234,249"
61  "233,251"
68  "232,249"
77  "231,249"
82  "230,247"
86  "235,246"
90  "234,245"
100 "233,244"
100 "232,243"
106 "90,269"
113 "90,269"
84  "90,268"
84  "230,239"
93  "90,266"
98  "90,265"
84  "90,264"
67  "224,235"
..
```
We find the index where the sum is maximal:
```q
q)best:{first where x=max x}first each tmp
q)best
15
```
We generate the answer by adding 1 to the index and appending it with a comma to the location:
```q
q)last[tmp best],",",string[1+best]
"90,269,16"
```
