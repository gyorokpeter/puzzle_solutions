# Breakdown

Example input:
```q
x:"\n"vs".#.\n..#\n###"
dim:3
```

## Common

Instead of keeping a n-dimensional array of the state of each cell, we just keep the coordinates of
the live cells. This allows the solution to easily extend from 3 to 4 dimensions by just adding one
more coordinate.

First we check the active cells in the input:
```q
q)"#"=x
010b
001b
111b
```
We find the coordinates of the active cells. The `where` function does it inside a single list. But
we have to do it on each list and then prepend the index of that list to get the full coordinates.
```q
q)where each "#"=x
,1
,2
0 1 2
q)raze{til[count x],/:'where each x}"#"=x
0 1
1 2
2 0
2 1
2 2
```
These are 2-dimensional coordinates, so we prepend enough zeros to fill out the dimensions.
```q
q)st:((dim-2)#0),/:raze{til[count x],/:'where each x}"#"=x
q)st
0 0 1
0 1 2
0 2 0
0 2 1
0 2 2
```
We also generate a helper value that only depends on the dimension. It is the list of neighbors for
a cell which we get by doing cross-product on the list -1 1 0 with itself to get enough dimensions.
```q
q)(-1 1 0 cross)/[dim-1;-1 1 0]
-1 -1 -1
..
0  0  1
0  0  0
```
The ordering of -1 1 0 is deliberate (like [day 11](day11.md)) because this way the all-zeros list
ends up as the last one and therefore easy to drop.
```q
q)nbd:-1_(-1 1 0 cross)/[dim-1;-1 1 0]
q)nbd
-1 -1 -1
-1 -1 1
..
0  0  -1
0  0  1
```
Now we do an iteration on the state. We first add the neighbor coordinates to each coordinate in
the state. This requires +/:\: because both sides are lists and we want to pair them up in every
combination.
```q
q)st+/:\:nbd
-1 -1 0 -1 -1 2 -1 -1 1 -1 1  0 -1 1  2 -1 1  1 -1 0  0 -1 0  2 -1 0  1 1  -1 0 1  -1 2 1  -1 1 1..
-1 0 1  -1 0 3  -1 0 2  -1 2 1  -1 2 3  -1 2 2  -1 1 1  -1 1 3  -1 1 2  1  0 1  1  0 3  1  0 2  1..
-1 1 -1 -1 1 1  -1 1 0  -1 3 -1 -1 3 1  -1 3 0  -1 2 -1 -1 2 1  -1 2 0  1  1 -1 1  1 1  1  1 0  1..
-1 1 0  -1 1 2  -1 1 1  -1 3 0  -1 3 2  -1 3 1  -1 2 0  -1 2 2  -1 2 1  1  1 0  1  1 2  1  1 1  1..
-1 1 1  -1 1 3  -1 1 2  -1 3 1  -1 3 3  -1 3 2  -1 2 1  -1 2 3  -1 2 2  1  1 1  1  1 3  1  1 2  1..
```
We raze this since there is no need for distinction of which direction the neighbor is.
```q
q)raze st+/:\:nbd
-1 -1 0
-1 -1 2
..
0  3  2
0  2  1
0  2  3
```
We take the frequency of each coordinate - the `count each group` idiom.
```q
q)nb:count each group raze st+/:\:nbd
q)nb
-1 -1 0 | 1
-1 -1 2 | 1
-1 -1 1 | 1
-1 1  0 | 3
..
-1 3  3 | 1
1  3  3 | 1
0  3  3 | 1
```
Using this dictionary we can easily apply the rules to get the next state. The next state is built
up of two parts: first, all coordinates that appear exactly 3 times:
```q
q)where 3=nb
-1 1 0
1  1 0
0  1 0
0  1 2
-1 2 2
1  2 2
0  2 1
-1 3 1
1  3 1
0  3 1
```
second, the coordinates already in st that appear exactly 2 times:
```q
q)st inter where 2=nb
0 2 2
```
The two sets definitely don't overlap.

We wrap the step into a function, also passing in the `nbd` list that we made earlier. We iterate
the function 6 times using the `/` iterator. Since the state is a list of coordinates, the answer is
simply the count of this list.
```q
q)count st
112
```

## Part 1
The above code runs with `dim=3`.

## Part 2
The above code runs with `dim=4`.

R.I.P. John Conway.
