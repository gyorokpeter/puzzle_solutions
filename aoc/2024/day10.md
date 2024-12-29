# Breakdown

Example input:
```q
x:();
x,:enlist"89010123";
x,:enlist"78121874";
x,:enlist"87430965";
x,:enlist"96549874";
x,:enlist"45678903";
x,:enlist"32019012";
x,:enlist"01329801";
x,:enlist"10456732";
```

## Common
The two parts are solved using the same algorithm. We use BFS starting from the `0` positions. The
only difference between the two parts is whether we keep the individual paths or not.

We parse the input into integers. Just like [day 9](day9.md), we have to add an extra _each-right_
since we want to parse individual characters, not whole lines.
```q
q)a:"J"$/:/:x
q)a
8 9 0 1 0 1 2 3
7 8 1 2 1 8 7 4
8 7 4 3 0 9 6 5
9 6 5 4 9 8 7 4
4 5 6 7 8 9 0 3
3 2 0 1 9 0 1 2
0 1 3 2 9 8 0 1
1 0 4 5 6 7 3 2
```
We use the [2D search](../utils/patterns.md#2d-search) technique to find the coordinates of the
zeros, which will be the starting positions. We initialize a queue with these origin points, as well
as the current position which starts out the same as the origin, and an occurrence count that starts
at 1.
```q
q)queue:update pos:orig from([]orig:raze til[count a],/:'where each a=0;cnt:1)
q)queue
orig cnt pos
------------
0 2  1   0 2
0 4  1   0 4
2 4  1   2 4
4 6  1   4 6
5 2  1   5 2
..
```
We initialize a step counter, then iterate until we pass step 9:
```q
    step:0;
    while[step<9;
        step+:1;
        ...
    ];
```
Note that we increase the step counter first, so in the first iteration `step` will already be 1.

We find the next position by adding the offsets of the four cardinal directions to the current
positions. The iterators and the `flip each` are there to make sure we can join the next positions
to the respective base positions. `ungroup` would do this better but it only works if all the
columns that we want to expand are atomic, and in this case `pos` is a list so it doesn't work.
```q
q)queue:raze queue,/:'flip each select nxt:pos+/:\:(-1 0;0 1;1 0;0 -1) from queue
q)queue
orig cnt pos nxt
------------------
0 2  1   0 2 -1 2
0 2  1   0 2 0  3
0 2  1   0 2 1  2
0 2  1   0 2 0  1
0 4  1   0 4 -1 4
0 4  1   0 4 0  5
0 4  1   0 4 1  4
0 4  1   0 4 0  3
..
```
We only keep the positions that have heights equal to the step counter. This also deals with
positions off the map as those result in nulls from the indexing.
```q
q)queue:select from queue where step=a ./:nxt
q)queue
orig cnt pos nxt
----------------
0 2  1   0 2 0 3
0 2  1   0 2 1 2
0 4  1   0 4 0 5
0 4  1   0 4 1 4
0 4  1   0 4 0 3
..
```
We calculate the next queue by replacing the current position with the next one and adding up the
counts as applicable. The `0!` is there because the `select ... by` returns a keyed table, but an
unkeyed table is preferable for the concatenation step.
```q
q)queue:0!select sum cnt by orig,pos:nxt from queue
q)queue
orig pos cnt
------------
0 2  0 3 1
0 2  1 2 1
0 4  0 3 1
0 4  0 5 1
0 4  1 4 1
2 4  1 4 1
```
At the end of the iteration, the queue contains a table for all final positions with their origins
and counts:
```q
q)queue
orig pos cnt
------------
0 2  0 1 4
0 2  3 0 4
0 2  3 4 4
0 2  4 5 4
0 2  5 4 4
0 4  0 1 4
0 4  2 5 2
0 4  3 0 4
```

## Part 1
The answer is the length of the queue, as each row represents a distinct origin-target combination:
```q
q)count queue
36
```

## Part 2
The answer is the total of the occurrence counts from the queue:
```q
q)exec sum cnt from queue
81
```
