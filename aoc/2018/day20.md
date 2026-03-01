# Breakdown
Example input:
```q
x:enlist"^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$"
```

## Common
We start by building a list of edges from the regex. This would normally require recursion, but
recursion is not a preferred control structure in q due to the limited stack size and the
performance impact, so we have to instead use an iterative implementation with a stack variable.

Due to the conventions, the input is a list of strings, but it only contains one string, so we take
the first element:
```q
q)a:first x
```
We drop the first and last element since these are static:
```q
q)re:1_-1_a
q)re
"WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))"
```
We find the parenthesis level at each position by mapping an opening parenthesis to 1 and a closing
one to -1, and taking the partial sums of the resulting list:
```q
q)pl:sums("()"!1 -1)re
q)pl
0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 3 ..
```
We initialize the stack with a single node containing the map position and cursor position, both
starting at zero:
```q
q)stack:([]pos:enlist 0 0;cur:0)
q)stack
pos cur
-------
0 0 0
```
We initialize a map of the edges:
```q
q)edges:([]s:();t:())
q)edges
s t
---
```
We iterate as long as there are elements in the stack:
```q
    while[0<count stack;
        ...
    ];
```
In the iteration, we append the parenthesis level to each entry in the stack:
```q
q)s1:update p:-1^pl cur from stack
q)s1
pos cur p
---------
0 0 0   0
```
We select only those nodes where the parenthesis level is the maximum:
```q
q)nxts:(delete p from select from s1 where p=max p)
q)nxts
pos cur
-------
0 0 0
```
We use the expansion function (see below) to expand the current nodes:
```q
q)rss:d20expand[re;pl] each nxts
q)rss
+`s`t!((0 -1;0 -1;1 -1;2 -1;2 0;2 1;3 0;3 -1;3 -2;2 -2;2 -3);(0 0;1 -1;2 -1;2 0;2 1;3 1;3 1;3 0;3 ..
```
We append the edges found by the expansion:
```q
q)edges:distinct edges,raze first each rss
q)edges
s    t
---------
0 -1 0 0
0 -1 1 -1
1 -1 2 -1
2 -1 2 0
2 0  2 1
2 1  3 1
3 0  3 1
3 -1 3 0
3 -2 3 -1
2 -2 3 -2
2 -3 2 -2
```
We generate the new state of the stack by keeping the elements that don't have the maximum
parenthesis level, then appending the new stack nodes from the expansion function:
```q
q)stack:distinct(delete p from select from s1 where p<>max p),raze last each rss
q)stack
pos  cur
--------
2 -3 11
```
After the iteration, we have the full edge list:
```q
q)edges
s     t
-----------
0  -1 0  0
0  -1 1  -1
1  -1 2  -1
2  -1 2  0
2  0  2  1
2  1  3  1
3  0  3  1
3  -1 3  0
3  -2 3  -1
2  -2 3  -2
2  -3 2  -2
2  -3 3  -3
1  -3 2  -3
1  -3 1  -2
0  -2 1  -2
-1 -2 0  -2
-1 -2 -1 -1
-1 -1 -1 0
-1 0  -1 1
-1 1  -1 2
..
```
We explore the map using a BFS. We initialize the queue to the starting position, an empty visited
array, a generation and a target counter:
```q
q)queue:enlist 0 0
q)visited:()
q)gen:-1
q)targets:0
```
We iterate as long as there are items in the queue:
```q
    while[0<count queue;
        ...
    ];
```
In the iteration, we append the queue nodes to the visited array:
```q
q)visited,:queue
q)visited
0 0
```
We expand the nodes by taking the possible next nodes from the edge list, excluding any visited
ones:
```q
q)nxts:((exec t from edges where s in queue),exec s from edges where t in queue)except visited
q)nxts
0 -1
```
We increment the generation counter:
```q
q)gen+:1
q)gen
0
```
If we are past generation 1000, we add the number of nodes in the queue to the target counter:
```q
    if[1000<=gen; targets+:count queue]
```
We replace the queue with the next nodes:
```q
q)queue:nxts
```
At the end of the iteration, we have the final generation and target counters:
```q
q)(gen;targets)
31 0
```
These numbers are the answers to parts 1 and 2 respectively.

### d20expand
This helper function deals with actually interpreting the regex. It takes three paremeters: the
regex, the parenthesis level list and the next node from the stack (which contains the map position
and the cursor position). The return value is a list of edges and a list of new stack items. The old
stack items are popped one level higher in the DFS implementation.

The function is a large conditional, performing various actions depending on the state. The branches
are evaluated from top to bottom and the first one to pass is taken, so each condition specified
below implicitly assumes that all the conditions above it are false.

Condition 1: the cursor is at or beyond the end of the regex.
```q
q)nxt
pos| 3 -3
cur| 63
q)count re
63
```
Action 1: nothing, we return empty lists.
```q
    (();())
```

Condition 2: the character at the current position is one of `"NESW"`.
```q
q)nxt
pos| 0 0
cur| 0
q)re[nxt`cur]
"W"
```
Action 2:

We find the end of the letter sequence:
```q
q)endcur:nxt`cur;while[re[endcur]in"NESW";endcur+:1];
q)endcur
11
```
We take this sequence from the regex:
```q
q)sect:nxt[`cur]_endcur#re
q)sect
"WSSEESWWWNW"
```
We generate a path by summing the deltas corresponding to the four directions, starting from the
current position in the node:
```q
q)path:sums enlist[nxt`pos],("NESW"!(-1 0;0 1;1 0;0 -1))sect
q)path
0 0
0 -1
1 -1
2 -1
2 0
2 1
3 1
3 0
3 -1
3 -2
2 -2
2 -3
```
We generate edges by taking two elements of the path at a time:
```q
q){-2#x,enlist y}\[1#path;1_path]
0 0  0 -1
0 -1 1 -1
1 -1 2 -1
2 -1 2 0
2 0  2 1
2 1  3 1
3 1  3 0
3 0  3 -1
3 -1 3 -2
3 -2 2 -2
2 -2 2 -3
```
We put these in ascending order and create a table:
```q
q)edges:flip`s`t!flip asc each{-2#x,enlist y}\[1#path;1_path]
q)edges
s    t
---------
0 -1 0 0
0 -1 1 -1
1 -1 2 -1
2 -1 2 0
2 0  2 1
2 1  3 1
3 0  3 1
3 -1 3 0
3 -2 3 -1
2 -2 3 -2
2 -3 2 -2
```
For the stack entries, we return one entry with the map and cursor position after traversing the
path:
```q
q)enlist`pos`cur!(last path;endcur)
pos  cur
--------
2 -3 11
```

Condition 3: the current character is `"("`.
```q
q)nxt
pos| 2 -3
cur| 11
q)re[nxt`cur]
"("
```
Action 3:

We find the parenthesis level at the cursor:
```q
q)spl:pl[nxt`cur]
q)spl
1
```
We find the end of the current parenthesized section by seeking as long as the parenthesis level is
greater than or equal to the starting one:
```q
q)endcur:nxt`cur; while[pl[endcur]>=spl;endcur+:1]
q)endcur
62
```
We find any splits at the current parenthesis level (in the whole regex):
```q
q)split:where (pl=spl) and re="|"
q)split
,13
```
We filter these to positions in the current parenthesized section:
```q
q)split2:split where split within (nxt`cur;endcur)
q)split
,13
```
We don't generate any edges, but we generate stack items for the next character after the `"("` as
well as each split, keeping the same map position:
```q
q)([]pos:(1+count split2)#enlist nxt`pos;cur:1+nxt[`cur],split2)
pos  cur
--------
2 -3 12
2 -3 14
```

Condition 4: the current character is `")"`.
```q
q)nxt
pos| 0 -3
cur| 59
q)re[nxt`cur]
")"
```
Action 4: we don't generate any edges, but we generate a new stack item for the cursor position
following the `")"`, keeping the map position.
```q
q)enlist`pos`cur!(nxt`pos;1+nxt`cur)
pos  cur
--------
0 -3 60
```

Condition 5: the current character is `"|"`.
```q
q)nxt
pos| -2 -2
cur| 56
q)re[nxt`cur]
"|"
```
Action 5:

We find the parenthesis level at the cursor:
```q
q)spl:pl[nxt`cur]
q)spl
4
```
We find the end of the current parenthesized section by seeking as long as the parenthesis level is
greater than or equal to the starting one:
```q
q)endcur:nxt`cur; while[pl[endcur]>=spl;endcur+:1]
q)endcur
59
```
The cursor now points to the closing parenthesis. We don't generate any edges, but we generate a new
stack item at the closing parenthesis position, keeping the map position.
```q
q)enlist`pos`cur!(nxt`pos;endcur)
pos   cur
---------
-2 -2 60
```

Condition 6: none of the above.

Action 6: this is an error.
```q
    '"nyi"
```

## Part 1
We call the common function and return the first element.
```q
q)first d20common x
31
```

## Part 2
All examples are too small so the output would be 0. We need to use a real input:
```q
q)md5"\n"sv x
0x1dcdb1606dfd0845482a0f17a68765a7
```
We call the common function and return the second (which is also the last) element.
```q
q)last d20common x
8627
```
