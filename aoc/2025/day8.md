# Breakdown
Example input:
```q
x:"\n"vs"162,817,812\n57,618,57\n906,360,560\n592,479,940\n352,342,300\n466,668,158\n542,29,236"
x,:"\n"vs"431,825,988\n739,650,466\n52,470,668\n216,146,977\n819,987,18\n117,168,530\n805,96,715"
x,:"\n"vs"346,949,466\n970,615,88\n941,993,340\n862,61,35\n984,92,344\n425,690,689"
```

## Common
The helper function `d8` deals with the input parsing and precalculates the distances for use by
both parts.

We split the lines on commas and convert to integers:
```q
q)a:"J"$","vs/:x
q)a
162 817 812
57  618 57
906 360 560
592 479 940
352 342 300
466 668 158
542 29  236
431 825 988
..
```
We create a list of IDs for each node:
```q
q)ids:til count a
q)ids
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
```
We generate a table of pairs by taking the cross product of the IDs list with itself and only
keeping those pairs where the first element is less than the second one:
```q
q)pair:select from([]s:ids)cross([]t:ids)where s<t
q)pair
s t
----
0 1
0 2
0 3
0 4
0 5
0 6
0 7
0 8
0 9
0 10
0 11
0 12
0 13
0 14
0 15
0 16
0 17
0 18
0 19
1 2
..
```
We calculate the distances between each pair by using the IDs to index into the coordinates. Note
that while Euclidean distance normally requires taking the square root, this is not necessary here
because we are only comparing the distances, and square root is strictly monotonic. We also order
the pairs in ascending order of distance.
```q
q)diffs:`diff xasc update diff:sum each{x*x}a[s]-a[t] from pair
q)diffs
s  t  diff
------------
0  19 100427
0  7  103401
2  13 103922
7  19 107662
17 18 111326
9  12 114473
11 16 118604
2  8  120825
14 19 123051
2  18 124564
3  19 135411
4  6  138165
4  12 138401
4  5  139436
6  17 143825
3  7  147941
8  19 149925
0  9  153245
11 15 166085
13 18 169698
..
```
The return value of the function is the three-element list `(a;ids;diffs)`.

## Part 1
This function takes an extra parameter, the number of connections to make.
```q
q)n:10
```
After generating the intermediate variables from the helper function, we take the first `n` pairs:
```q
q)b:n#diffs
q)b
s  t  diff
------------
0  19 100427
0  7  103401
2  13 103922
7  19 107662
17 18 111326
9  12 114473
11 16 118604
2  8  120825
14 19 123051
2  18 124564
```
We create an adjacency map by grouping the second elements of the pair by the first and vice versa:
```q
q)adj:(exec t by s from b),'(exec s by t from b)
q)adj
0 | 19 7
2 | 13 8 18
7 | 19 0
9 | ,12
11| ,16
14| ,19
17| ,18
8 | ,2
12| ,9
13| ,2
16| ,11
18| 17 2
19| 0 7 14
```
We calculate the transitive closure of the adjacency map. We start by making single-node components
of each node, then iterate by applying the adjacency map to the accumulator, removing any
duplicates. We use the overload of `/` (over) that stops iterating when the accumulator no longer
changes.
```q
q)nodes:enlist each ids
q)net:{[adj;nodes]{distinct asc x}each nodes,'raze each adj nodes}[adj]/[nodes]
q)net
`s#0 7 14 19
`s#,1
`s#2 8 13 17 18
`s#,3
`s#,4
`s#,5
`s#,6
`s#0 7 14 19
`s#2 8 13 17 18
`s#9 12
`s#,10
`s#11 16
`s#9 12
`s#2 8 13 17 18
`s#0 7 14 19
`s#,15
`s#11 16
`s#2 8 13 17 18
`s#2 8 13 17 18
`s#0 7 14 19
```
Since some nodes have been merged into components, we need to deduplicate the result:
```q
q)distinct net
`s#0 7 14 19
`s#,1
`s#2 8 13 17 18
`s#,3
`s#,4
`s#,5
`s#,6
`s#9 12
`s#,10
`s#11 16
`s#,15
```
We take the counts of each component, find the top three, and take the product:
```q
q)count each distinct net
4 1 5 1 1 1 1 2 1 2 1
q)desc count each distinct net
5 4 2 2 1 1 1 1 1 1 1
q)3#desc count each distinct net
5 4 2
q)prd 3#desc count each distinct net
40
```

## Part 2
We start with single-node components like in part 1:
```q
q)nodes:enlist each ids
```
This time the iteration is an explicit `while` loop. We initialize a counter to 0 and keep
increasing it:
```q
    i:0;
    while[1b;
        ...
        i+:1;
    ];
```
Inside the iteration, we check if the pair at the current index contains two nodes in different
components:
```q
q)diffs[i;`s`t]
0 19
q)diffs[i;`s`t] in/:nodes
10b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
00b
01b
q)where each flip diffs[i;`s`t] in/:nodes
0
19
q)pos:first each where each flip diffs[i;`s`t] in/:nodes
q)pos
0 19
q)(<>). pos
1b

    if[(<>). pos:first each where each flip diffs[i;`s`t] in/:nodes;
        ...
    ];
```
If the two components don't match, we merge them by razing together the nodes in the first node's
component and deleting that of the second one:
```q
q)nodes[pos 0]:asc raze nodes pos 0 1
q)nodes _:pos 1
q)nodes
`s#0 19
,1
,2
,3
,4
,5
,6
,7
,8
,9
,10
,11
,12
,13
,14
,15
,16
,17
,18
```
We check if there is only one component, and if so, we return the product of the X coordinates of
the current pair:
```q
...
q)nodes
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
q)1=count nodes
1b
q)diffs[i;`s`t]
10 12
q)a[diffs[i;`s`t]]
216 146 977
117 168 530
q)a[diffs[i;`s`t]][;0]
216 117
q)prd a[diffs[i;`s`t]][;0]
25272

    if[1=count nodes;:prd a[diffs[i;`s`t]][;0]];
```
