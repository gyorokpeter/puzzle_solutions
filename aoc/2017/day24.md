# Breakdown
Example input:
```q
x:"\n"vs"0/2\n2/2\n2/3\n3/4\n3/5\n0/1\n10/1\n9/10"
```

## Common
A single function solves both parts and returns the results as a list. The solver functions for
parts 1 and 2 merely call this function and index into the list.

We parse the input by cutting on `"/"` characters and converting to integers:
```q
q)a:"J"$"/"vs/:x
q)a
0  2
2  2
2  3
3  4
3  5
0  1
10 1
9  10
```
We generate a mapping to easily find the adapters for a given number of pins. First we prepend the
ID of the adapter to its pin counts in both orientations:
```q
q)til[count a],'/:(a;reverse each a)
0 0  2  1 2  2  2 2  3  3 3  4  4 3  5  5 0  1  6 10 1  7 9  10
0 2  0  1 2  2  2 3  2  3 4  3  4 5  3  5 1  0  6 1  10 7 10 9
```
We raze the two lists and get rid of duplicates:
```q
q)distinct raze til[count a],'/:(a;reverse each a)
0 0  2
1 2  2
2 2  3
3 3  4
4 3  5
5 0  1
6 10 1
7 9  10
0 2  0
2 3  2
3 4  3
4 5  3
5 1  0
6 1  10
7 10 9
```
We create a mapping by grouping the second element and using the result as an index into the
original list:
```q
q){group x[;1]}distinct raze til[count a],'/:(a;reverse each a)
0 | 0 5
2 | 1 2 8
3 | 3 4 9
10| 6 14
9 | ,7
4 | ,10
5 | ,11
1 | 12 13
q)pins:{x group x[;1]}distinct raze til[count a],'/:(a;reverse each a)
q)pins
0 | (0 0 2;5 0 1)
2 | (1 2 2;2 2 3;0 2 0)
3 | (3 3 4;4 3 5;2 3 2)
10| (6 10 1;7 10 9)
9 | ,7 9 10
4 | ,3 4 3
5 | ,4 5 3
1 | (5 1 0;6 1 10)
```
We initialize a queue for a BFS. The queue nodes will have a current position, a total score and a
visited array. There is no need to store the entire sequence, only the current position.
```q
q)queue:([]pos:enlist 0;total:0;visited:enlist count[a]#0b)
q)queue
pos total visited
-------------------
0   0     00000000b
```
We initalize a variable for the best score seen so far:
```q
q)best:0
```
We perform an iteration as long as there are items in the queue:
```q
    while[count queue;
        ...
    ];
```
In the iteration, we save the current state of the queue before processing the items. This is
relevant for part 2.
```q
q)prevq:queue
```
We look up the possible next adapters for each queue node using the mapping:
```q
q)nxts:update nxt:pins pos from queue
q)nxts
pos total visited   nxt
-------------------------------
0   0     00000000b 0 0 2 5 0 1
```
We flatten the nodes such that each element in `nxt` gets its own row. This is a kind of ungroup
operation, but the built-in `ungroup` function wouldn't work due to the presence of the `visited`
column which is also a list of lists but we don't want to ungroup that. Instead, we have to manually
pick apart the row and rejoin it with `,`:
```q
q)nxts:raze{(`nxt _ x),/:([]nxt:x`nxt)}each nxts
q)nxts
pos total visited   nxt
-------------------------
0   0     00000000b 0 0 2
0   0     00000000b 5 0 1
```
We drop the rows that would correspond to reusing an adapter:
```q
)nxts:delete from nxts where visited@'nxt[;0]
q)nxts
pos total visited   nxt
-------------------------
0   0     00000000b 0 0 2
0   0     00000000b 5 0 1
```
We prepare the next state of the queue by updating the values of the normal columns and dropping
the `nxt` column:
```q
q)queue:delete nxt from update pos:nxt[;2],total:total+sum each nxt[;1 2],visited:@[;;:;1b]'[visited;nxt[;0]] from nxts
q)queue
pos total visited
-------------------
2   2     10000000b
1   1     00000100b
```
We update the best score in case a new best score was generated:
```q
q)best:exec max (best,total) from queue
q)best
2
```
The code for the iteration ends here.

After the iteration, we have the best score in the `best` variable, which is the answer to part 1:
```q
q)best
31
```
We also have the queue nodes from before the queue became empty in the `prevq` variable. These
represent the longest paths, so we can get the answer to part 2 by extracting the highest score from
those paths:
```q
q)prevq
pos total visited
-------------------
4   18    11110000b
5   19    11101000b
q)exec max total from prevq
19
```
