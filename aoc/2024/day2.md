# Breakdown

Example input:
```q
x:"\n"vs"7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9";
```

## Part 1
We split the input on spaces and convert it into integers:
```q
q)"J"$" "vs/:x
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
```
We find the differences between the consecutive elements in each list:
```q
q)deltas each"J"$" "vs/:x
7 -1 -2 -2 -1
1 1  5  1  1
9 -2 -1 -4 -1
1 2  -1 2  1
8 -2 -2 0  -3
1 2  3  1  2
```
The result of `deltas` includes the first element but that is irrelevant so we drop it:
```q
q)1_/:deltas each"J"$" "vs/:x
-1 -2 -2 -1
1  5  1  1
-2 -1 -4 -1
2  -1 2  1
-2 -2 0  -3
2  3  1  2
```
The condition can be rephrased as "all differences are either one of `-1 -2 -3` or one of `1 2 3`".
So we use `in` to check each difference against these two lists, adding an _each-right_ due to the
right argument being a list of lists:
```q
q)(1_/:deltas each"J"$" "vs/:x)in/:(1 2 3;-1 -2 -3)
0000b 1011b 0000b 1011b 0000b 1111b
1111b 0000b 1101b 0100b 1101b 0000b
```
The condition only holds when all of the booleans in the small lists are true. We can use `all` to
check for this, however we need to bring this down two levels (the first level is the choice
between the positive and negative differences, and the second is the line in the input). `each`
brings a function down one level, but if we want to bring it down more than level, we need to add an
`each-right` for each additional level:
```q
q)all each/:(1_/:deltas each"J"$" "vs/:x)in/:(1 2 3;-1 -2 -3)
000001b
100000b
```
A list is safe if either of the checks returned true. Calling `any` on this list of two boolean
lists finds exactly this (it "collapses" the list vertically):
```q
q)any all each/:(1_/:deltas each"J"$" "vs/:x)in/:(1 2 3;-1 -2 -3)
100001b
```
We can treat booleans as numbers and sum them to get the answer. Due to a quirk in q, the summation
of a boolean list returns an `int` instead of a `long`, therefore there is an `i` suffix.
```q
q)sum any all each/:(1_/:deltas each"J"$" "vs/:x)in/:(1 2 3;-1 -2 -3)
2i
```

## Part 2
First we generate all possible results of removing an element from the lists. For example with a
list `x:2 4 6 8 10`, we start by generating a list of indices up to the count of the list:
```q
q)til count x
0 1 2 3 4
```
We use the overload of [`drop (_)`](https://code.kx.com/q/ref/drop/) that takes an index on the
right and drops that index from the list on the left. We want to drop each index in turn, so we
iterate using an _each-right_:
```q
q)x _/:til count x
4 6 8 10
2 6 8 10
2 4 8 10
2 4 6 10
2 4 6 8
```
Since not dropping anything is also an option, we have to add the original list back. This must be
enlisted in order to make sure the elements have the same shape.
```q
q)enlist[x],x _/:til count x
2 4 6 8 10
4 6 8 10
2 6 8 10
2 4 8 10
2 4 6 10
2 4 6 8
```
Returning to the original input, we can iterate the index-wise removal function with `each`:
```q
q)a:{enlist[x],x _/:til count x}each"J"$" "vs/:x
q)a
7 6 4 2 1 6 4 2 1 7 4 2 1 7 6 2 1 7 6 4 1 7 6 4 2
1 2 7 8 9 2 7 8 9 1 7 8 9 1 2 8 9 1 2 7 9 1 2 7 8
9 7 6 2 1 7 6 2 1 9 6 2 1 9 7 2 1 9 7 6 1 9 7 6 2
1 3 2 4 5 3 2 4 5 1 2 4 5 1 3 4 5 1 3 2 5 1 3 2 4
8 6 4 4 1 6 4 4 1 8 4 4 1 8 6 4 1 8 6 4 1 8 6 4 4
1 3 6 7 9 3 6 7 9 1 6 7 9 1 3 7 9 1 3 6 9 1 3 6 7
```
The remainder is very similar to Part 1, but we need to mind the shape of the list, as there is now
an extra level. When generating the differences, we have to bring it down by an additional level:
```q
q)deltas each/:a
7 -1 -2 -2 -1 6 -2 -2 -1 7 -3 -2 -1 7 -1 -4 -1 7 -1 -2 -3 7 -1 -2 -2
1 1 5 1 1     2 5 1 1    1 6 1 1    1 1 6 1    1 1 5 2    1 1 5 1
9 -2 -1 -4 -1 7 -1 -4 -1 9 -3 -4 -1 9 -2 -5 -1 9 -2 -1 -5 9 -2 -1 -4
1 2 -1 2 1    3 -1 2 1   1 1 2 1    1 2 1 1    1 2 -1 3   1 2 -1 2
8 -2 -2 0 -3  6 -2 0 -3  8 -4 0 -3  8 -2 -2 -3 8 -2 -2 -3 8 -2 -2 0
1 2 3 1 2     3 3 1 2    1 5 1 2    1 2 4 2    1 2 3 3    1 2 3 1
```
The same applies to dropping the initial elements:
```q
q)1_/:/:deltas each/:a
-1 -2 -2 -1 -2 -2 -1 -3 -2 -1 -1 -4 -1 -1 -2 -3 -1 -2 -2
1 5 1 1     5 1 1    6 1 1    1 6 1    1 5 2    1 5 1
-2 -1 -4 -1 -1 -4 -1 -3 -4 -1 -2 -5 -1 -2 -1 -5 -2 -1 -4
2 -1 2 1    -1 2 1   1 2 1    2 1 1    2 -1 3   2 -1 2
-2 -2 0 -3  -2 0 -3  -4 0 -3  -2 -2 -3 -2 -2 -3 -2 -2 0
2 3 1 2     3 1 2    5 1 2    2 4 2    2 3 3    2 3 1
```
The `in` check doesn't need a change as it doesn't care much about the shape of its left argument:
```q
q)(1_/:/:deltas each/:a)in/:(1 2 3;-1 -2 -3)
0000b 000b 000b 000b 000b 000b 1011b 011b 011b 101b 101b 101b 0000b 000b 000b 000b 000b 000b 1011b..
1111b 111b 111b 101b 111b 111b 0000b 000b 000b 000b 000b 000b 1101b 101b 101b 101b 110b 110b 0100b..
```
The `all` check does need the extra level:
```q
q)all each/:/:(1_/:/:deltas each/:a)in/:(1 2 3;-1 -2 -3)
000000b 000000b 000000b 001100b 000000b 110011b
111011b 000000b 000000b 000000b 000110b 000000b
```
We can collapse the lists vertically with `any` again to resolve the choice between the positive
and negative differences:
```q
q)any all each/:/:(1_/:/:deltas each/:a)in/:(1 2 3;-1 -2 -3)
111011b
000000b
000000b
001100b
000110b
110011b
```
However to find which lists are safe we need to collapse this matrix horizontally, so we need to use
`each` with `any`:
```q
q)any each any all each/:/:(1_/:/:deltas each/:a)in/:(1 2 3;-1 -2 -3)
100111b
```
We can sum the result as before:
```q
q)sum any each any all each/:/:(1_/:/:deltas each/:a)in/:(1 2 3;-1 -2 -3)
4i
```
