# Breakdown

Example input:
```q
x:enlist"2333133121414131402";
```

## Part 1
We parse the input into integers. Note that this time there needs to be an _each-right_ on the parse
operator since we want to parse the individual characters and not the whole string.
```q
q)"J"$/:first x
2 3 3 3 1 3 3 1 2 1 4 1 4 1 3 1 4 0 2
```
The _actual_ meaning of [`where`](https://code.kx.com/q/ref/where/) is to duplicate each index the
number of times equal to the value at that index. In the boolean case, this gives the familiar "find
the true elements" behavior, but we can use it here to generate the disk layout as well:
```q
q)a:where "J"$/:first x
q)a
0 0 1 1 1 2 2 2 3 3 3 4 5 5 5 6 6 6 7 8 8 9 10 10 10 10 11 12 12 12 12 13 14 14 14 15 16 16 16 16..
```
Here, both the full and empty blocks get their own ID, so the IDs of the files are doubled. So we
need to divide the IDs of the files by 2 and replace the IDs of the empty space with nulls.
Replacing with nulls can be done by dividing by zero. So we divide by 2 if the number is even and
by 0 if it's odd. [Vector conditional](https://code.kx.com/q/ref/vector-conditional/) is useful for
generating a list that chooses from two lists based on whether a condition is true or false:
```q
q)?[0=a mod 2;2;0]
2 2 0 0 0 2 2 2 0 0 0 2 0 0 0 2 2 2 0 2 2 0 2 2 2 2 0 2 2 2 2 0 2 2 2 0 2 2 2 2 2 2
q)b:a div ?[0=a mod 2;2;0]
q)b
0 0 0N 0N 0N 1 1 1 0N 0N 0N 2 0N 0N 0N 3 3 3 0N 4 4 0N 5 5 5 5 0N 6 6 6 6 0N 7 7 7 0N 8 8 8 8 9 9
```
To construct the final state, we begin by counting the file blocks and taking that many elements
from the initial state:
```q
q)sum[not null b]
28i
q)c:sum[not null b]#b
q)c
0 0 0N 0N 0N 1 1 1 0N 0N 0N 2 0N 0N 0N 3 3 3 0N 4 4 0N 5 5 5 5 0N 6
```
To fill in the nulls, we first take the same number of non-null elements from the end of the
original list as the number of nulls in the target, taking the numbers in reverse order:
```q
q)b except 0N
0 0 1 1 1 2 3 3 3 4 4 5 5 5 5 6 6 6 6 7 7 7 8 8 8 8 9 9
q)sum[null c]
12i
q)sum[null c]#reverse b except 0N
9 9 8 8 8 8 7 7 7 6 6 6
```
We fill in the nulls using indexed assignment. The indices are those where the nulls are in the
target, and the values to assign are the above list of numbers from the end.
```q
q)where null c
2 3 4 8 9 10 12 13 14 18 21 26
q)c[where null c]:sum[null c]#reverse b except 0N
q)c
0 0 9 9 8 1 1 1 8 8 8 2 7 7 7 3 3 3 6 4 4 6 5 5 5 5 6 6
```
To calculate the score, we multiply each eleemnt with its index (generated using `til`) and sum the
result.
```q
q)c*til count c
0 0 18 27 32 5 6 7 64 72 80 22 84 91 98 45 48 51 108 76 80 126 110 115 120 125 156 162
q)sum c*til count c
1928
```

## Part 2
Generating the full map is no longer that useful as it's easier to think in terms of blocks whose
positions are being moved around. So we simply parse the input as integers:
```q
q)a:"J"$/:first x
q)a
2 3 3 3 1 3 3 1 2 1 4 1 4 1 3 1 4 0 2
q)
```
We figure out the starting position of each block. This can be done with `sums`, although that
starts with the first element already being the first element of the original list, so in order to
get the positions we need to prepend a zero and drop the last element.
```q
q)sums a
2 5 8 11 12 15 18 19 21 22 26 27 31 32 35 36 40 40 42
q)0,-1_sums a
0 2 5 8 11 12 15 18 19 21 22 26 27 31 32 35 36 40 40
```
We pair up the positions with the lengths, then cut to length 2 such that the first elements will
contain the file blocks and the second elements will contain the empty blocks.
```q
q)(0,-1_sums a),'a
0  2
2  3
5  3
8  3
11 1
..
q)b:2 cut (0,-1_sums a),'a
q)b
(0 2;2 3)
(5 3;8 3)
(11 1;12 3)
..
(36 4;40 0)
,40 2
```
We extract the used and free blocks into their respective lists - note that the free blocks will
miss the last element so we have to drop the empty list that gets put there:
```q
q)used:b[;0]
q)used
0  2
5  3
11 1
15 3
19 2
..
q)free:-1_b[;1]
q)free
2  3
8  3
12 3
18 1
21 1
..
```
As the next section uses them heavily, we extract the offsets and sizes of the blocks into
separate lists, which improves performance as opposed to repeatedly indexing into the original lists
with `[;0]` and `[;1]` respectively:
```q
q)upos:used[;0]; ulen:used[;1];
q)fpos:free[;0]; flen:free[;1];
q)upos
0 5 11 15 19 22 27 32 36 40
q)ulen
2 3 1 3 2 4 4 3 4 2
q)fpos
2 8 12 18 21 26 31 35 40
q)flen
3 3 3 1 1 1 1 1 0
```
We initialize a position counter to point at the last element and iterate backwards:
```q
    pos:count[used]-1;
    while[0<=pos;
        ...
        pos-:1;
    ];
```
Within each iteration, we try to move a single file. We get the length of the file at the current
position:
```q
q)size:ulen pos
q)size
2
```
We find all the potential target blocks that have enough size to contain the selected file:
```q
q)tgt:where flen>=size;
q)tgt
0 1 2
```
We filter down this list to only those that are before the file, then pick the first one:
```q
q)tgt2:first tgt where fpos[tgt]<upos pos
q)tgt2
0
```
If there is no suitable position, `tgt2` will be null, so we only perform the move if it is not
null:
```q
    if[not null tgt2;
        ...
    ];
```
To perform the move, we first update the position of the target file to the target free space:
```q
    upos[pos]:fpos[tgt2];
```
We then update the starting position of the target free space by adding the size, and also decrease
its size by deducting the file size. This makes the block still available for future moves of
smaller files.
```q
    fpos[tgt2]+:size;
    flen[tgt2]-:size;
```
We don't have to worry about adding an empty space in place of the file just moved, because no file
can be moved to the right where the new free space appears.

At the end of the iteration, we have an updated vector of the files:
```q
q)upos
0 5 4 15 12 22 27 8 36 2
q)ulen
2 3 1 3 2 4 4 3 4 2
```
We calculate the positions occupied by each file by using `til` on their sizes and adding their
starting positions:
```q
q)til each ulen
0 1
0 1 2
,0
0 1 2
0 1
..
q)upos+'til each ulen
0 1
5 6 7
,4
15 16 17
12 13
..
```
We multiply the positions by the IDs of the files. This is why it is useful to keep the files in the
same order, even though the `upos` vector is no longer in ascending order.
```q
q)til[count used]*upos+'til each ulen
0 0
5 6 7
,8
45 48 51
48 52
..
```
Since the lists are ragged, we have to `sum` with `each` first, as `sum` on its own would try to
collapse vertically, which would lead to a length error.
```q
q)sum each til[count used]*upos+'til each ulen
0 18 8 144 100 470 684 189 1200 45
q)sum sum each til[count used]*upos+'til each ulen
2858
```