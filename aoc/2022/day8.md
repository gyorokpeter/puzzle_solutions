# Breakdown
Example input:
```q
x:"\n"vs"30373\n25512\n65332\n33549\n35390";
```

## Common
We convert all the digits to integers. This requires using `/:` _each-right_ twice, since even though normally `$` is atomic in its right argument, it stops at the first string to convert it, but this time we do want to go to the next level to convert the individual digits.
```q
q)a:"J"$/:/:x
q)a
3 0 3 7 3
2 5 5 1 2
6 5 3 3 2
3 3 5 4 9
3 5 3 9 0
```

## Part 1
To find the visibility of a tree, we need to compare it to the highest tree so far from a certain direction. The `maxs` function can generate the partial maxima for a list in a single direction, which is useful for this. However it needs a few tweaks.

We are only interested in trees _before_ the tree we are checking. So we shift the entire array to the right by dropping the last element and prepending -1 elements (which are shorter than any tree).
```q
q)-1_/:-1,/:a
-1 3 0 3 7
-1 2 5 5 1
-1 6 5 3 3
-1 3 3 5 4
-1 3 5 3 9
```
Then we take the partial maxima for each row.
```q
q)maxs each -1_/:-1,/:a
-1 3 3 3 7
-1 2 5 5 5
-1 6 6 6 6
-1 3 3 5 5
-1 3 5 5 9
```
We compare them to the actual height to determine visibility.
```q
q)a>maxs each -1_/:-1,/:a
10010b
11000b
10000b
10101b
11010b
```

The other problem is that `maxs` only works in one direction (left to right). To check the other directions, we need to transform the grid such that the direction we want to check goes from left to right, then transform it back after getting the result. To make this easier, let's abstract the above operation as the function `f`:
```q
q)f:{x>maxs each -1_/:-1,/:x};
q)f a
10010b
11000b
10000b
10101b
11010b
```
Visibility from the top:
```q
q)flip f flip a
11111b
01100b
10000b
00001b
00010b
```
Visibility from the bottom:
```q
q)reverse flip f flip reverse a
00000b
00000b
10000b
00101b
11111b
```
Visibility from the right:
```q
q)reverse each f reverse each a
00011b
00101b
11011b
00001b
00011b
```
Putting these four matrices into a list and taking the `max` of them returns which trees are visible from _any_ direction:
```q
q)max(f a; flip f flip a; reverse flip f flip reverse a; reverse each f reverse each a)
11111b
11101b
11011b
10101b
11111b
```
We can sum the matrix to get the count (twice, once per dimension):
```q
q)sum sum max(f a; flip f flip a; reverse flip f flip reverse a; reverse each f reverse each a)
21i
```

## Part 2
The operation this time will be more complicated. We will calculate the score for every possible height of tree for every location, and then only keep those that actually match the tree in that location. This is more array-like than iterating over the trees in two dimensions.

In the innermost operation, we assume that the height of the tree is `m`. We need to count the consecutive trees that are shorter than `m`, but just like with part 1 the grid needs to be shifted to the right, filling in with zeros on the left. There is no built in operator for "increase, except if greather than or equal to a certain number, in which case reset to 1". So this needs to be an iterated function:
```q
{[m;x;y]$[y<m;x+1;1]}[m]\[0;]
```
The input list for the iteration will be each of the numbers in the grid. Putting this together with the grid reshaping:
```q
op:{[m;x]0,/:{[m;x;y]$[y<m;x+1;1]}[m]\[0;]each -1_/:x};
```
The second level still fixes the height to `m`, and checks the scores for all of the trees. Just like part 1, we need to call the underlying operation four times with various transformations:
```q
(op[m]x; flip op[m] flip x; reverse flip op[m] flip reverse x; reverse each op[m] reverse each x)
```
The result is the product of the four lists. The function `op` needs to be passed in as a parameter due to the convention of not allowing global functions.
```q
op2:{[op;m;x]prd(op[m]x; flip op[m] flip x; reverse flip op[m] flip reverse x; reverse each op[m] reverse each x)}[op];
```
The third level filters out which trees the score actually applies to. This can be simply done by comparing the heights to `m` and multiplying the scores by the results.
```q
op3:{[op2;x;m]op2[m;x]*m=x}[op2];
```
To get the answer, we call this last operation with all possible values for `m` from 0 to 9, and sum the results:
```q
q)op3[a] each til 10
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 1 2 0 0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0
0 0 0 0 0 0 1 4 0 0 0 6 0 0 0 0 0 8 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
q)max max sum op3[a] each til 10
8
```
