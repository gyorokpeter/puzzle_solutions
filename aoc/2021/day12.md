# Overview
The solution uses BFS, with modifications to allow a single repetition for part 2.

# Breakdown
Example input:
```q
x:"\n"vs"5483143223\n2745854711\n5264556173\n6141336146\n6357385478\n4167524645\n2176841721"
x,:"\n"vs"6882881134\n4846848554\n5283751526"
```

## Part 1
We split the input on dashes. We also flip the result, which will make it easier to use in the next
step.
```q
q)a:flip`$"-"vs/:x
q)a
start start A A b A   b
A     b     c b d end end
```
We put the edges into a table. The graph is undirected, so we add the edges in both directions. This
is why it's useful to extract the variable `a` like this, so we can pair the two elements with the
column names `s` and `t` first, and then with `t` and `s` for the reverse edges.
```q
q)(flip`s`t!a),flip`t`s!a
s     t
-----------
start A
start b
A     c
..
A     start
b     start
c     A
..
```
We group the edges by starting node:
```q
q)edges:exec t by s from (flip`s`t!a),flip`t`s!a where t<>`start
q)edges
A    | `c`b`end
b    | `d`end`A
c    | ,`A
d    | ,`b
end  | `A`b
start| `A`b
```
We find the nodes with capital letters by comparing each key in the edge map with the uppercase
version of itself:
```q
q)cap:{x where x=upper x}key edges
q)cap
,`A
```
We initialize a queue. It is a list of lists, since each element is a path. Initially there is only
one path that contains only the start node.
```q
q)queue:enlist enlist`start
q)queue
start
```
We also initialize a list for the finished paths:
```q
q)paths:()
```
We iterate as long as there are items in the queue:
```q
while[0<count queue;
    ...
    ];
```
The iteration is best demonstrated in an intermediate state:
```q
q)queue:(`start`A;`start`b)
```
In the iteration, first we expand every path in the queue by appending all the possible next nodes
based on the last node of the path. `(;)` is a projection of the list creation operator (also called
`enlist`) with 2 parameters, so applying this with `/:'` creates two-element lists where the first
element is coming from the queue and the right element is the value picked out of the map. We also
make this a table to be able to do delete statements on it.
```q
q)nxts:`p`n!/:raze queue(;)/:'edges last each queue
q)nxts
p       n
-------------
start A c
start A b
start A end
start A start
start b d
start b end
start b start
start b A
```
We drop any states where the next node is already in the list of nodes, but not if it's a capital
node:
```q
q)nxts:delete from nxts where n in' p, not n in cap
q)nxts
p       n
-----------
start A c
start A b
start A end
start b d
start b end
start b A
```
We append any paths where the next node is the end node to the list of complete paths:
```q
q)exec (p,'n) from nxts where n=`end
start A end
start b end
q)paths,:exec (p,'n) from nxts where n=`end
```
We also delete these paths from the table:
```q
q)nxts:delete from nxts where n=`end
q)nxts
p       n
---------
start A c
start A b
start b d
start b A
```
Finally we update the queue to be the next paths:
```q
q)queue:exec (p,'n) from nxts
q)queue
start A c
start A b
start b d
start b A
```
This ends the iteration.

After the iteration we have a list of paths in the `paths` variable. The answer is their count.
```q
q)paths
`start`A`end
`start`b`end
`start`A`b`end
`start`b`A`end
`start`A`c`A`end
`start`A`b`A`end
`start`A`c`A`b`end
`start`b`A`c`A`end
`start`A`c`A`b`A`end
`start`A`b`A`c`A`end
q)count paths
10
```

## Part 2
We start like part 1 up to calculating the nodes with capital letters. We do the same for the small
letters, but since `start` and `end` fit the pattern, we need to exclude them explicitly.
```q
q)small:({x where x=lower x}key edges)except `start`end
q)small
`b`c`d
```
The queue is a table this time. The first column is the list of paths (which was the entire queue
in part 1) and the second column is a boolean indicating that the single chance to re-enter a small
node has been used.
```q
q)queue:([]p:enlist enlist`start;sm:0b)
q)queue
p     sm
--------
start 0
```
We also initialize a list for the finished paths:
```q
q)paths:()
```
The iteration is best demonstrated in an intermediate state (step 4 on the example input):
```q
q)queue:([]p:(`start`A`c`A;`start`A`b`d;`start`A`b`A;`start`b`d`b;`start`b`A`c;`start`b`A`b);sm:000101b)
```
We append the possible next nodes as a new column:
```q
q)nxts:update n:edges[last each p] from queue
q)nxts
p           sm n
-----------------------
start A c A 0  `c`b`end
start A b d 0  ,`b
start A b A 0  `c`b`end
start b d b 1  `d`end`A
start b A c 0  ,`A
start b A b 1  `d`end`A
```
We explode each row such that the `n` column is split into individual values, and the `p` and `sm`
value is duplicated. This can be expressed as a lambda with `each` and then razing the results.
```q
q)nxts:raze{([]p:count[x`n]#enlist x`p;sm:x`sm;n:x`n)}each nxts
q)nxts
p           sm n
------------------
start A c A 0  c
start A c A 0  b
start A c A 0  end
start A b d 0  b
start A b A 0  c
start A b A 0  b
start A b A 0  end
start b d b 1  d
start b d b 1  end
start b d b 1  A
start b A c 0  A
start b A b 1  d
start b A b 1  end
start b A b 1  A
```
We delete the rows where the next node is already in the path, it's not a capital node and the `sm`
flag is already set:
```q
q)nxts:delete from nxts where n in' p, not n in cap, sm
q)nxts
p           sm n
------------------
start A c A 0  c
start A c A 0  b
start A c A 0  end
start A b d 0  b
start A b A 0  c
start A b A 0  b
start A b A 0  end
start b d b 1  end
start b d b 1  A
start b A c 0  A
start b A b 1  d
start b A b 1  end
start b A b 1  A
```
We update the `sm` flag to true for paths where we are about to repeat a small node:
```q
q)nxts:update sm:1b from nxts where n in' p, not n in cap
q)nxts
p           sm n
------------------
start A c A 1  c
start A c A 0  b
start A c A 0  end
start A b d 1  b
start A b A 0  c
start A b A 1  b
start A b A 0  end
start b d b 1  end
start b d b 1  A
start b A c 0  A
start b A b 1  d
start b A b 1  end
start b A b 1  A
```
We append any paths where the next node is the end node to the list of complete paths:
```q
q)exec (p,'n) from nxts where n=`end
start A c A end
start A b A end
start b d b end
start b A b end
q)paths,:exec (p,'n) from nxts where n=`end
```
We also delete these paths from the table:
```q
q)nxts:delete from nxts where n=`end
q)nxts
p           sm n
----------------
start A c A 1  c
start A c A 0  b
start A b d 1  b
start A b A 0  c
start A b A 1  b
start b d b 1  A
start b A c 0  A
start b A b 1  d
start b A b 1  A
```
Finally we update the queue to be the next paths:
```q
q)queue:select p:(p,'n), sm from nxts
q)queue
p             sm
----------------
start A c A c 1
start A c A b 0
start A b d b 1
start A b A c 0
start A b A b 1
start b d b A 1
start b A c A 0
start b A b d 1
start b A b A 1
```
This ends the iteration.

After the iteration we have a list of paths in the `paths` variable. The answer is their count.
```q
q)paths
`start`A`end
`start`b`end
`start`A`b`end
..
`start`A`b`A`c`A`c`A`end
`start`A`b`A`c`A`b`A`end
`start`A`b`A`b`A`c`A`end
q)count paths
36
```
