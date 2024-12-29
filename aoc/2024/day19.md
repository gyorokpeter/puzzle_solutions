# Breakdown

Example input:
```q
x:"\n"vs"r, wr, b, g, bwu, rb, gb, br\n\nbrwrr\nbggr\ngbbr\nrrbgbr\nubwu\nbwurrg\nbrgr\nbbrgwb";
```

## Common
We find the number of ways to create each pattern using BFS.

We split the input into groups. In the first group we split on commas, and in the second group
we split on newlines. We don't cast to integers this time.
```q
q)a:"\n\n"vs"\n"sv x;
q)elem:", "vs a 0;
q)goal:"\n"vs a 1;
q)elem
,"r"
"wr"
,"b"
,"g"
"bwu"
"rb"
"gb"
"br"
q)goal
"brwrr"
"bggr"
"gbbr"
"rrbgbr"
"ubwu"
"bwurrg"
"brgr"
"bbrgwb"
```
We evaluate each goal separately using a nested function:
```q
    ways:{[elem;g]
        ...
    }[elem]each goal;
```
Using an example for demonstration:
```q
q)g:"brwrr"
```
We initialize the queue with a single node containing the position 0 and the occurrence count of 1:
```q
    queue:([]pos:enlist 0;cnt:enlist 1);
```
We also initialize a counter for the total ways:
```q
    total:0;
```
We iterate as long as there are nodes in the queue, then return the total:
```q
while[count queue;
    ...
];
total
```
In the iteration, we first add the counts of any nodes that are at the end position, which is the
length of `g`:
```q
    total+:exec sum cnt from queue where pos=count g;
```
We also delete these nodes to avoid processing them further:
```q
    queue:delete from queue where pos=count g;
```
We expand the nodes by trying to append all of the possible elements as the next element in the
sequence. Since the original columns are atomic, we can use `ungroup` to explode the table:
```q
q)nxts:ungroup update e:count[queue]#enlist til count elem from queue
q)nxts
pos cnt e
---------
0   1   0
0   1   1
0   1   2
0   1   3
0   1   4
0   1   5
0   1   6
0   1   7
```
We add a column containing the lengths of the elements:
```q
q)nxts:update ec:count each elem e from nxts;
q)nxts
pos cnt e ec
------------
0   1   0 1
0   1   1 2
0   1   2 1
0   1   3 1
0   1   4 3
0   1   5 2
0   1   6 2
0   1   7 2
```
We add a column containing the chunk of the goal with the starting position being the position in
the node, and the length being the column added in the previous step:
```q
q)nxts:update chunk:g pos+til each ec from nxts;
q)nxts
pos cnt e ec chunk
------------------
0   1   0 1  ,"b"
0   1   1 2  "br"
0   1   2 1  ,"b"
0   1   3 1  ,"b"
0   1   4 3  "brw"
0   1   5 2  "br"
0   1   6 2  "br"
0   1   7 2  "br"
```
We delete any nodes where the extracted chunk doesn't match the element we are checking against:
```q
q)nxts:delete from nxts where not chunk~'elem e;
q)nxts
pos cnt e ec chunk
------------------
0   1   2 1  ,"b"
0   1   7 2  "br"
```
We update the queue by moving the position forward by the element length and deduplicating the nodes
while summing their occurrence counts:
```q
q)queue:0!select sum cnt by pos+ec from nxts;
q)queue
pos cnt
-------
1   1
2   1
```
After going through all the goals, we will have the number of ways for each of them in a list:
```q
q)ways
2 1 4 6 0 1 2 0
```

## Part 1
The answer is the number of goals for which the helper function returned a number greater than zero.
```q
q)sum ways>0
6i
```

## Part 2
The answer is the sum of the number of ways themselves.
```q
q)sum ways
16
```
