# Breakdown

Example input:
```q
x:"\n"vs"kh-tc\nqp-kh\nde-cg\nka-co\nyn-aq\nqp-ub\ncg-tb\nvc-aq\ntb-ka\nwh-tc\nyn-cg\nkh-ub\nta-co";
x,:"\n"vs"de-co\ntc-td\ntb-wq\nwh-td\nta-ka\ntd-qp\naq-cg\nwq-ub\nub-vc\nde-ta\nwq-aq\nwq-vc";
x,:"\n"vs"wh-yn\nka-de\nkh-ta\nco-tc\nwh-qp\ntb-vc\ntd-yn";
```

## Part 1
We cut the lines on dashes and create a table with the node pairs. We also add the reverse of each
edge.
```q
q)a:asc each`$"-"vs/:x
q)a
kh tc
kh qp
cg de
co ka
aq yn
..
q)b:flip`s`t!flip a,reverse each a
q)b
s  t
-----
kh tc
kh qp
cg de
co ka
aq yn
..
tc kh
qp kh
de cg
ka co
yn aq
..
```
We create a mapping from each node to its successors:
```q
q)c:exec t by s from b
q)c
aq| yn vc cg wq
cg| de tb yn aq
co| ka ta de tc
de| ta ka cg co
ka| tb ta co de
..
```
We apply the mapping to itself to find the nodes two edges away:
```q
q)d:c c
q)d
aq| aq cg wh td wq aq ub tb de tb yn aq tb ub aq vc
cg| ta ka cg co wq vc cg ka aq cg wh td yn vc cg wq
co| tb ta co de co ka de kh ta ka cg co wh td kh co
de| co ka de kh tb ta co de de tb yn aq ka ta de tc
ka| wq vc cg ka co ka de kh ka ta de tc ta ka cg co
..
q)d`aq
aq cg wh td
wq aq ub tb
de tb yn aq
tb ub aq vc
```
We filter down the level-2 nodes to only those found in the original mapping:
```q
q)d in'c
aq| 0100b 1000b 0010b 0001b
cg| 0000b 0000b 1000b 1000b
co| 0101b 0110b 1100b 0000b
de| 1100b 0110b 0000b 1100b
ka| 0000b 1010b 0110b 1001b
..
q)d@''where each/:d in'c
aq| cg         wq         yn         vc
cg| `symbol$() `symbol$() ,`aq       ,`yn
co| `ta`de     `ka`de     `ta`ka     `symbol$()
de| `co`ka     `ta`co     `symbol$() `ka`ta
ka| `symbol$() `co`de     `ta`de     `ta`co
..
q)raze each c,/:''d@''where each/:d in'c
aq| (`yn`cg;`vc`wq;`cg`yn;`wq`vc)
cg| (`yn`aq;`aq`yn)
co| (`ka`ta;`ka`de;`ta`ka;`ta`de;`de`ta;`de`ka)
de| (`ta`co;`ta`ka;`ka`ta;`ka`co;`co`ka;`co`ta)
ka| (`ta`co;`ta`de;`co`ta;`co`de;`de`ta;`de`co)
..
```
We also add the starting node to the list, order them alphabetically and take the distinct list:
```q
q)key[c],/:'raze each c,/:''d@''where each/:d in'c
aq| (`aq`yn`cg;`aq`vc`wq;`aq`cg`yn;`aq`wq`vc)
cg| (`cg`yn`aq;`cg`aq`yn)
co| (`co`ka`ta;`co`ka`de;`co`ta`ka;`co`ta`de;`co`de`ta;`co`de`ka)
de| (`de`ta`co;`de`ta`ka;`de`ka`ta;`de`ka`co;`de`co`ka;`de`co`ta)
ka| (`ka`ta`co;`ka`ta`de;`ka`co`ta;`ka`co`de;`ka`de`ta;`ka`de`co)
..
q)e:distinct asc each raze key[c],/:'raze each c,/:''d@''where each/:d in'c
q)e
aq cg yn
aq vc wq
co ka ta
co de ka
co de ta
de ka ta
kh qp ub
qp td wh
tb vc wq
tc td wh
td wh yn
ub vc wq
```
We find which groups contain nodes starting with `"t"` and count them:
```q
q)e like\:"t*"
000b
000b
001b
000b
001b
001b
000b
010b
100b
110b
100b
000b
q)any each e like\:"t*"
001011011110b
q)sum any each e like\:"t*"
7i
```

## Part 2
We create the mapping as in part 1:
```q
q)b:exec t by s from flip`s`t!flip a,reverse each a
q)b
aq| yn vc cg wq
cg| de tb yn aq
co| ka ta de tc
de| ta ka cg co
ka| tb ta co de
..
```
We start a BFS with a queue entry for each node:
```q
    queue:enlist each key b
```
We iterate until the queue is empty, but we keep the last state, as that will contain the largest
groups:
```q
    while[count queue;
        prevQueue:queue;
        ...
    ];
```
During iteration, we expand each node by adding all neighbors from the mapping:
```q
q)nxts:raze ([]p:queue),/:'flip each([]ext:b last each queue)
q)nxts
p  ext
------
aq yn
aq vc
aq cg
aq wq
cg de
..
```
We filter out entries that have the new node not alphabetically after the last one in the group.
This avoids the combinatorial explosion of having every path in every possible order in the queue.
It also prevents duplicate nodes from being added to groups.
```q
q)nxts:delete from nxts where ext<=last each p
q)nxts
p  ext
------
aq yn
aq vc
aq cg
aq wq
cg de
..
```
We add a column with the neighbors of the new node:
```q
q)nxts:update ext2:b ext from nxts
q)nxts
p  ext ext2
------------------
aq yn  aq cg wh td
aq vc  wq aq ub tb
aq cg  de tb yn aq
aq wq  tb ub aq vc
cg de  ta ka cg co
..
```
We delete any entries where the group members are not also members of the neighbors of the new node.
These can't form a clique.
```q
q)nxts:delete from nxts where not all each p in'ext2
q)nxts
p  ext ext2
------------------
aq yn  aq cg wh td
aq vc  wq aq ub tb
aq cg  de tb yn aq
aq wq  tb ub aq vc
cg de  ta ka cg co
..
```
We update the queue by concatenating the next node with the existing members of the groups:
```q
q)queue:exec (p,'ext) from nxts
q)queue
aq yn
aq vc
aq cg
aq wq
cg de
..
```
At the end of the iteration, `queue` will be empty, but `prevQueue` should contain exactly one
element, which is the largest clique. It is also already in alphabetical order, so we just need to
join it with commas.
```q
co de ka ta
q)","sv string first prevQueue
"co,de,ka,ta"
```
... Code kata? That looks nerdy enough. In fact Advent of Code offers a great library of problems to
practice, ranging from easy to very hard. Revisiting the same problem and solution multiple times
might give you new ideas - sometimes when I write these breakdowns I modify the code that I
originally posted on Reddit with optimizations and simplifications, or sometimes I even rewrite the
whole thing from the ground up if I come across an interesting alternative solution.
