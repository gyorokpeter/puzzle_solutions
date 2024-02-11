# Breakdown
Example input:
```q
x:"2199943210\n3987894921\n9856789892\n8767896789\n9899965678"
```

## Part 1
We parse the input into numbers:
```q
q)a:"J"$/:/:"\n"vs x
q)a
2 1 9 9 9 4 3 2 1 0
3 9 8 7 8 9 4 9 2 1
9 8 5 6 7 8 9 8 9 2
8 7 6 7 8 9 6 7 8 9
9 8 9 9 9 6 5 6 7 8
```

We also store the width for easier reference:
```q
q)w:count first a
q)w
10
```
To find the low points, we generate four different matrices, corresponding to the four directions.
These are generated by dropping one row/column and inserting `0W` (infinity) values on the other
side.
```q
q)(1_/:a),\:0W
1 9 9 9 4 3 2 1 0 0W
9 8 7 8 9 4 9 2 1 0W
8 5 6 7 8 9 8 9 2 0W
7 6 7 8 9 6 7 8 9 0W
8 9 9 9 6 5 6 7 8 0W
q)0W,/:-1_/:a
0W 2 1 9 9 9 4 3 2 1
0W 3 9 8 7 8 9 4 9 2
0W 9 8 5 6 7 8 9 8 9
0W 8 7 6 7 8 9 6 7 8
0W 9 8 9 9 9 6 5 6 7
q)1_a,enlist w#0W
3  9  8  7  8  9  4  9  2  1
9  8  5  6  7  8  9  8  9  2
8  7  6  7  8  9  6  7  8  9
9  8  9  9  9  6  5  6  7  8
0W 0W 0W 0W 0W 0W 0W 0W 0W 0W
q)enlist[w#0W],-1_a
0W 0W 0W 0W 0W 0W 0W 0W 0W 0W
2  1  9  9  9  4  3  2  1  0
3  9  8  7  8  9  4  9  2  1
9  8  5  6  7  8  9  8  9  2
8  7  6  7  8  9  6  7  8  9
```

We use the less-than operator to compare the initial matrix to all four of these:
```q
q)a</:((1_/:a),\:0W;0W,/:-1_/:a;1_a,enlist w#0W;enlist[w#0W],-1_a)
0100000001b 1001101001b 0011110101b 0011101111b 0100001111b
1100011111b 1011001011b 1110000101b 1110001000b 1100011000b
1100011111b 1000001011b 0011110001b 1111100000b 1111111111b
1111111111b 0011100000b 0111110100b 1100001110b 0000011111b
```
The low points are those where all of these are true:
```q
q)g:all a</:((1_/:a),\:0W;0W,/:-1_/:a;1_a,enlist w#0W;enlist[w#0W],-1_a)
q)g
0100000001b
0000000000b
0010000000b
0000000000b
0000001000b
```
To sum the values, we can multiply the "is low point" flags by the heights:

```q
q)a*g
0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 5 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 5 0 0 0
```
We also need to add one but only to the nonzero values. We can add the boolean matrix to achieve
this:
```q
q)g+a*g
0 2 0 0 0 0 0 0 0 1
0 0 0 0 0 0 0 0 0 0
0 0 6 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 6 0 0 0
```
Then we sum these numbers:
```q
q)sum sum g+a*g
15
```

## Part 2
This is a breadth-first search with starting nodes in each low point. We also give each starting
node a unique "basin" identifier to help counting them.
```q
q)nodes:update basin:1+i from ([]pos:raze til[count a],/:'where each g);
q)nodes
pos basin
---------
0 1 1
0 9 2
2 2 3
4 6 4
```
We also store the height for easier reference.
```q
q)h:count a
q)h
5
```
We initialize the queue and the list of visited nodes:
```q
q)queue:nodes;
q)visited:nodes;
```
During each step, we first generate the neighbors of each node in the queue by adding the vectors
for the four main directions:
```q
q)nxts:distinct ungroup update pos:pos+/:\:(-1 0;0 -1;1 0;0 1) from queue
q)nxts
pos   basin
-----------
-1 1  1
0  0  1
1  1  1
0  2  1
-1 9  2
...
```
We filter out positions outside the board:
```q
q)nxts:select from nxts where pos[;0] within (0;h-1), pos[;1] within (0;w-1)
q)nxts
pos basin
---------
0 0 1
1 1 1
0 2 1
0 8 2
...
```
We also filter out any positions corresponding to a 9. We can use the `.` (index at depth) operator
between the board and the pos column to find the height values.
```q
q)nxts
pos basin
---------
0 0 1
0 8 2
1 9 2
1 2 3
...
```
We update the visited nodes and queue:
```q
q)visited,:nxts;
q)queue:nxts;
```
After the iteration is over, the visited list will contain all the nodes with their basin number.
We can extract the size of each basin by grouping on the basin column:
```q
q)exec count i by basin from visited
1| 3
2| 9
3| 14
4| 9
```
Then sort them in descending order:
```q
q)desc exec count i by basin from visited
3| 14
2| 9
4| 9
1| 3
```
To get the answer, we take the first 3 elements and multiply them together:
```q
q)3#desc exec count i by basin from visited
3| 14
2| 9
4| 9
q)prd 3#desc exec count i by basin from visited
1134
```