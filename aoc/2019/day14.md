# Breakdown
Example input:
```q
x:()
x,:enlist"9 ORE => 2 A"
x,:enlist"8 ORE => 3 B"
x,:enlist"7 ORE => 5 C"
x,:enlist"3 A, 4 B => 1 AB"
x,:enlist"5 B, 7 C => 1 BC"
x,:enlist"4 C, 1 A => 1 CA"
x,:enlist"2 AB, 3 BC, 4 CA => 1 FUEL"
```

## Part 1
The input is deeply nested so we need a lot of each-right (/:) during input parsing.
```q
q)a:"JS"$/:/:/:" "vs/:/:/:", "vs/:/:" => "vs/:x
q)a
9 `ORE                    2 `A
8 `ORE                    3 `B
7 `ORE                    5 `C
((3;`A);(4;`B))           ,(1;`AB)
((5;`B);(7;`C))           ,(1;`BC)
((4;`C);(1;`A))           ,(1;`CA)
((2;`AB);(3;`BC);(4;`CA)) ,(1;`FUEL)
```
The parsed input is put in a table with the output type (`rt`), output count (`rq`) and the required
materials (`mats`):
```q
q)t:([rt:a[;1;0;1]]rq:a[;1;0;0];mats:a[;0])
q)t
rt  | rq mats
----| ----------------------------
A   | 2  ,(9;`ORE)
B   | 3  ,(8;`ORE)
C   | 5  ,(7;`ORE)
AB  | 1  ((3;`A);(4;`B))
BC  | 1  ((5;`B);(7;`C))
CA  | 1  ((4;`C);(1;`A))
FUEL| 1  ((2;`AB);(3;`BC);(4;`CA))
```
In other languages this simulation might best be done using recursion. However, q doesn't like
recursion as flow control structure (there is a 2000 stack limit). So we use a top-down solution
instead.

We maintain a queue (what materials we need) and a storage (what we have as a by-product). Queue
starts at the number of fuel we need. Storage starts out empty.
```q
q)fuel:1
q)queue:enlist[`FUEL]!enlist fuel
q)totalOre:0
q)storage:(`$())!`long$()
```
We iterate as long as there are items in the queue:
```q
    while[0<count queue;
        ...
    ];
```
During every iteration:

We check if any item in the storage can be used to fulfill any needs:
```q
q)canUse:0^(key[queue]#storage)&queue
q)canUse
FUEL| 0
q)queue-:canUse
q)storage-:canUse
q)queue:(where queue>0)#queue
q)queue
FUEL| 1
```
We fetch the rules corresponding to the items we need and add the needed number as a new column
(`mult`):
```q
q)nxts:update mult:value queue from 0!([]rt:key queue)#t
q)nxts
rt   rq mats              mult
------------------------------
FUEL 1  2 `AB 3 `BC 4 `CA 1
```
We find out how many times we need to use the recipe (`pq`):
```q
q)nxts2:update pq:ceiling mult%rq from nxts
q)nxts2
rt   rq mats              mult pq
---------------------------------
FUEL 1  2 `AB 3 `BC 4 `CA 1    1
```
We multiply the materials by the number of times the recipe was used:
```q
q)nxts3:update mats:.[mats;(::;::;0);*;pq] from nxts2
q)nxts3
rt   rq mats              mult pq
---------------------------------
FUEL 1  2 `AB 3 `BC 4 `CA 1    1
```
We convert the material lists to dictionaries and add them together:
```q
q)nxts4:((`$())!`long$()),sum .[{enlist[y]!enlist[x]}]each exec raze mats from nxts3
q)nxts4
AB| 2
BC| 3
CA| 4
```
We add any excess materials produced to storage:
```q
q)storage+:(exec rt!pq*rq from nxts3)-queue
q)storage
FUEL| 0
```
We add the amount of ore produced to the ongoing total:
```q
q)totalOre+:0^nxts4`ORE
q)totalOre
0
```
We remove the ORE element to avoid problems and take the next set of needed materials:
```q
q)queue:`ORE _nxts4
q)nxts4
AB| 2
BC| 3
CA| 4
```
Notice that the entire queue is replaced in each iteration. This is characteristic to well-written
"vector BFS" in q. Other languages would process element after element.

Second iteration for demonstration:
```q
q)canUse:0^(key[queue]#storage)&queue
q)canUse
AB| 0
BC| 0
CA| 0
q)queue-:canUse
q)storage-:canUse
q)queue:(where queue>0)#queue
q)queue
AB| 2
BC| 3
CA| 4
q)nxts:update mult:value queue from 0!([]rt:key queue)#t
q)nxts
rt rq mats      mult
--------------------
AB 1  3 `A 4 `B 2
BC 1  5 `B 7 `C 3
CA 1  4 `C 1 `A 4
q)nxts2:update pq:ceiling mult%rq from nxts
q)nxts2
rt rq mats      mult pq
-----------------------
AB 1  3 `A 4 `B 2    2
BC 1  5 `B 7 `C 3    3
CA 1  4 `C 1 `A 4    4
q)nxts3:update mats:.[mats;(::;::;0);*;pq] from nxts2
q)nxts3
rt rq mats        mult pq
-------------------------
AB 1  6 `A  8 `B  2    2
BC 1  15 `B 21 `C 3    3
CA 1  16 `C 4  `A 4    4
q)nxts4:((`$())!`long$()),sum .[{enlist[y]!enlist[x]}]each exec raze mats from nxts3
q)nxts4
A| 10
B| 23
C| 37
q)storage+:(exec rt!pq*rq from nxts3)-queue
q)storage
FUEL| 0
AB  | 0
BC  | 0
CA  | 0
q)totalOre+:0^nxts4`ORE
q)totalOre
0
q)queue:`ORE _nxts4
q)queue
A| 10
B| 23
C| 37
```
At the end of the iteration, we return the accumulated ore amount:
```q
q)totalOre
165
```

## Part 2
We reuse the logic from part 1, but with a customizable fuel goal. In the above breakdown, the fuel
amount was fixed at 1 (`fuel:1`). We extract the logic into a function where `fuel` is a parameter:
```q
    d14:{[t;fuel]
        ...
    }
```
We do a binary search using the familiar formula, plugging in the call to `d14` where we need to
fetch the current value:
```q
    totalOre:1000000000000;
    u:0; v:1;
    while[d14[t;v]<totalOre; v*:2];
    while[u<=v;
        d:u+(v-u)div 2;
        r:d14[t;d];
        $[r<=totalOre; u:d+1; v:d-1];
    ];
```
After the iteration, `v` will contain the highest argument for which `ore` is less than or equal to
`totalOre`.
```q
q)v
6323777403
```
