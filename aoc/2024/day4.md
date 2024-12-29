# Breakdown

Example input:
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

## Part 1
Note that this is not the same solution that I posted on reddit. The revised solution makes it
easier to generalize between the two parts.

We find the occurrences of the letter `X` in the matrix using the
[2D search](../utils/patterns.md#2d-search) technique:
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
Next we would like to find the coordinates that could complete the word "XMAS". This means 3 steps
(`til 3`) in all 8 directions. (It's only 3, not 4, because the starting coordinate matches the
"X"). We combine the 3 steps with zero and itself in various combinations to cover all 8 directions:
```q
q)t3:1+til 3
q)t3
1 2 3
q)tn3:(t3;neg t3)
q)tn3
1  2  3
-1 -2 -3
q)0,/:/:tn3 //right and left
0 1  0 2  0 3
0 -1 0 -2 0 -3
q)tn3,\:\:0 //down and up
1 0  2 0  3 0
-1 0 -2 0 -3 0
q)tn3,''tn3 //down-right and up-left
1 1   2 2   3 3
-1 -1 -2 -2 -3 -3
q)tn3,''reverse tn3 //down-left and up-right
1 -1 2 -2 3 -3
-1 1 -2 2 -3 3
q)cs:raze(0,/:/:tn3;tn3,\:\:0;tn3,''tn3;tn3,''reverse tn3);
q)cs
0 1   0 2   0 3
0 -1  0 -2  0 -3
1 0   2 0   3 0
-1 0  -2 0  -3 0
1 1   2 2   3 3
-1 -1 -2 -2 -3 -3
1 -1  2 -2  3 -3
-1 1  -2 2  -3 3
```
Now we would like to add these offsets to all the coordinates we found earlier. This requires using
a couple of iterators. One way to figure out the correct set of iterators is to start from the
innermost operation that can't be decomposed further (after accounting for q's automatic
decomposition, such as for the operator `+`). In this case the innermost operation is an addition
of one of the "X" coordinates to one of the offsets. So the left argument will be some element of
`a` and the right argument will be some element of `cs`:
```q
q)a[0]
0 4
q)cs[0][0]
0 1
q)a[0]+cs[0][0]
0 5
```
Then we remove one layer of indexing, replacing it with iteration. First we remove a layer from
the right argument, which corresponds to iterating over one set of offsets (stepping in one
direction). We replace the index with an _each-right_ on the operator:
```q
q)a[0]+/:cs[0]
0 5
0 6
0 7
```
We repeat the same, this time iterating over all the 8 directions:
```q
q)a[0]+/:/:cs
0 5  0 6  0 7
0 3  0 2  0 1
1 4  2 4  3 4
-1 4 -2 4 -3 4
1 5  2 6  3 7
-1 3 -2 2 -3 1
1 3  2 2  3 1
-1 5 -2 6 -3 7
```
Finally we iterate over the "X" coordinates, so we remove the index from `a` and add an _each-left_:
```q
q)a+/:/:\:cs
0 5  0 6  0 7     0 3  0 2  0 1     1 4  2 4  3 4     -1 4 -2 4 -3 4    1 5  2 6  3 7     -1 3 -2 ..
0 6  0 7  0 8     0 4  0 3  0 2     1 5  2 5  3 5     -1 5 -2 5 -3 5    1 6  2 7  3 8     -1 4 -2 ..
1 5  1 6  1 7     1 3  1 2  1 1     2 4  3 4  4 4     0  4 -1 4 -2 4    2 5  3 6  4 7     0  3 -1 ..
2 3   2 4   2 5   2 1   2 0   2 -1  3 2   4 2   5 2   1  2  0  2  -1 2  3 3   4 4   5 5   1  1  0 ..
2 5  2 6  2 7     2 3  2 2  2 1     3 4  4 4  5 4     1  4 0  4 -1 4    3 5  4 6  5 7     1  3 0  ..
..
```
We can now find what letters the coordinates map to. We use the `.` operator for indexing the
character matrix. We have to use three `each-right` iterators since the coordinates are at the third
level:
```q
q)x ./:/:/:a+/:/:\:cs
"XMA" "SMM" "XXA" "   " "MAS" "   " "MXS" "   "
"MAS" "XSM" "MMS" "   " "SAM" "   " "XSA" "   "
"MSM" "MAS" "XAA" "X  " "MMA" "S  " "SAM" "X  "
"SXM" "MA " "AAA" "AM " "MAX" "SM " "SX " "MX "
"MAA" "SXM" "AAM" "XX " "SXA" "MM " "MAX" "MM "
..
```
This gives us the strings in all 8 directions that can be read from everx "X" coordinate. We need to
count the occurrences of `"MAS"` in the matrix. For exact matches on strings we can use `~`, and we
must use two `each-right` iterators this time as the strings are two levels deep:
```q
q)"MAS"~/:/:x ./:/:/:a+/:/:\:cs
00001000b
10000000b
01000000b
00000000b
00000000b
..
```
We can sum this boolean matrix twice to get the number of matches. The first application of `sum`
removes the first axis (i.e. a collapses it vertically) and the second one collapses the remaining
list.
```q
q)sum "MAS"~/:/:x ./:/:/:a+/:/:\:cs
3 2 1 2 1 4 1 4i
q)sum sum "MAS"~/:/:x ./:/:/:a+/:/:\:cs
18i
```

## Part 2
The code for part 1 would look like this so far:
```q
d4p1:{a:raze til[count x],/:'where each x="X";
    t3:1+til 3; tn3:(t3;neg t3);
    cs:raze(0,/:/:tn3;tn3,\:\:0;tn3,''tn3;tn3,''reverse tn3);
    sum sum"MAS"~/:/:x ./:/:/:a+/:/:\:cs};
```
This lends itself to a nice generalization for part 2. All we need to do is extract the starting
letter (`"X"` for part 1), the match pattern (`"MAS"` for part 1) and the offsets for the straight
lines into parameters, so we can rewrite part 1 by calling this utility function:
```q
d4:{[start;match;cs;x]
    a:raze til[count x],/:'where each x=start;
    sum sum match~/:/:x ./:/:/:a+/:/:\:cs};
d4p1:{t3:1+til 3; tn3:(t3;neg t3);
    cs:raze(0,/:/:tn3;tn3,\:\:0;tn3,''tn3;tn3,''reverse tn3);
    d4["X";"MAS";cs;x]};
```
For part 2, the starting letter will be `"A"`, the match will be `"MMSS"`, and the offsets will be
the four diagonal directions, clockwise with all four starting points. We start with one order and
use `rotate` to generate the others.
```q
q)cs:til[4]rotate\:(-1 -1;-1 1;1 1;1 -1)
q)cs
-1 -1 -1 1  1  1  1  -1
-1 1  1  1  1  -1 -1 -1
1  1  1  -1 -1 -1 -1 1
1  -1 -1 -1 -1 1  1  1
```
We plug the parameters into the refactored function and we get the result:
```q
q)d4["A";"MMSS";cs;x]
9i
```
