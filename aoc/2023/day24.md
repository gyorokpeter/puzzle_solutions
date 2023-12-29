# Breakdown

Example input:
```q
x:"\n"vs"19, 13, 30 @ -2,  1, -2\n18, 19, 22 @ -1, -1, -2\n20, 25, 34 @ -2, -2, -4";
x,:"\n"vs"12, 31, 28 @ -1, -2, -1\n20, 19, 15 @  1, -5, -3";
```

## Part 1
The function takes an extra `bounds` parameter just to be able to use it on the example input.
```q
q)bounds
7 27
```
We split the input and cast to integers:
```q
q)lines:"J"$", "vs/:/:" @ "vs/:x
q)lines
19 13 30 -2 1  -2
18 19 22 -1 -1 -2
20 25 34 -2 -2 -4
12 31 28 -1 -2 -1
20 19 15 1  -5 -3
```
We take only the first 2 coordinates for every line:
```q
q)lines2:2#/:/:lines
q)lines2
19 13 -2 1
18 19 -1 -1
20 25 -2 -2
12 31 -1 -2
20 19 1  -5
```
To find the intersection points we need to find the `m` and `b` parameters in the line equation:
```q
q)m:lines[;1;1]%lines[;1;0];
q)b:lines[;0;1]-m*lines[;0;0];
q)m
-0.5 1 1 2 -5
q)b
22.5 1 5 7 119
```
We will use a helper function to find intersection points:
```q
intersect:{[m0;b0;m1;b1]x:(b1-b0)%(m0-m1);y:b0+m0*x;x,y}
```
We generate all the pairs of indices to check:
```q
q)pi:raze til[-1+count m],/:'(1+til[-1+count m])_\:til count m
q)pi
0 1
0 2
0 3
0 4
1 2
1 3
1 4
2 3
2 4
3 4
```
We find all the intersection points (for parallel lines we will have infinite values):
```q
q)meet:.[intersect]'[raze each(m,'b)pi]
q)meet
14.33333 15.33333
11.66667 16.66667
6.2      19.4
21.44444 11.77778
0w       0w
-6       -5
19.66667 20.66667
-2       3
19       24
16       39
```
We overwrite one of the coordinates with a negative infinity (to make sure it's definitely not within the bounds) if the intersection point is reached in the past. We need to check both coordinates.
```q
q)meet[where 0>(meet[;0]-lines[pi[;0];0;0])%lines[pi[;0];1;0];0]:-0w;
q)meet[where 0>(meet[;0]-lines[pi[;1];0;0])%lines[pi[;1];1;0];1]:-0w;
q)meet
14.33333 15.33333
11.66667 16.66667
6.2      19.4
-0w      -0w
-0w      0w
-6       -5
-0w      -0w
-2       3
19       -0w
-0w      -0w
```
We check which points are within the bounds and count them:
```q
q)meet within\:bounds
11b
11b
01b
00b
00b
00b
00b
00b
10b
00b
q)sum all each meet within\:bounds
2i
```

## Part 2
I didn't manage to solve this one - this is a hardcode math problem, not a programming problem, and it all boils down to solving the equations on paper and then writing a program that plugs your input into the solution. Or you can use one of the fan favorite equation-solver tools like z3 or Matlab. However in order to still have a q solution, I looked at the solutions in the megathread and searched for one that can easily be translated to q due to not relying on huge external libraries like z3. The one I found is [this one](https://pastebin.com/NmR6ZDXL), and an explanation can be found [here](https://old.reddit.com/r/adventofcode/comments/18pnycy/2023_day_24_solutions/kepu26z/). Below is how to transform this solution into q.

We parse the input as in part 1:
```q
q)lines:"J"$", "vs/:/:" @ "vs/:x
q)lines
19 13 30 -2 1  -2
18 19 22 -1 -1 -2
20 25 34 -2 -2 -4
12 31 28 -1 -2 -1
20 19 15 1  -5 -3
```
We use two helper functions, one for the cross product (from wikipedia) and one for `crossMatrix` from the C++ code:
```q
crossProd:{((x[1]*y[2])-x[2]*y[1];(x[2]*y[0])-x[0]*y[2];(x[0]*y[1])-x[1]*y[0])};
crossMtx:{((0;neg x 2;x 1);(x 2;0;neg x 0);(neg x 1;x 0;0))};
```
We build the `rhs` value by plugging the corresponding line coordinates into `crossProd` and concatenating the two vectors:
```q
rhs:(crossProd[lines[1;0];lines[1;1]]-crossProd[lines[0;0];lines[0;1]]),
    (crossProd[lines[2;0];lines[2;1]]-crossProd[lines[0;0];lines[0;1]]);
q)rhs
40 36 -44 24 34 -35
```
We build the matrix from four usages of `crossMtx`. We use concatenation operations to merge them into a 6x6 matrix.
```q
q)m1:(crossMtx[lines[0;1]]-crossMtx[lines[1;1]]),(crossMtx[lines[0;1]]-crossMtx[lines[2;1]]);
q)m2:(crossMtx[lines[1;0]]-crossMtx[lines[0;0]]),(crossMtx[lines[2;0]]-crossMtx[lines[0;0]]);
q)m1,'m2
0  0  2 0   8  6
0  0  1 -8  0  1
-2 -1 0 -6  -1 0
0  -2 3 0   -4 12
2  0  0 4   0  -1
-3 0  0 -12 1  0
```
We use the built-in `inv` and `mmu` operators to calculate the solution. Note that the input must be converted to floats, otherwise we get type errors.
```q
q)res:inv[`float$m1,'m2]mmu`float$rhs
q)res
24 13 10 -3 1 2f
```
We return the sum of the first 3 elements of the result.
```q
q)`long$sum 3#res
47
```
