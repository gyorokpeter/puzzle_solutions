# Breakdown
Example input:
```q
x:();
x,:enlist"pbga (66)"
x,:enlist"xhth (57)"
x,:enlist"ebii (61)"
x,:enlist"havc (66)"
x,:enlist"ktlj (57)"
x,:enlist"fwft (72) -> ktlj, cntj, xhth"
x,:enlist"qoyq (66)"
x,:enlist"padx (45) -> pbga, havc, qoyq"
x,:enlist"tknk (41) -> ugml, padx, fwft"
x,:enlist"jptl (61)"
x,:enlist"ugml (68) -> gyxo, ebii, jptl"
x,:enlist"gyxo (61)"
x,:enlist"cntj (57)"
```

## Common
We parse the input into a table with each row containing a node's weight and parent.

We cut the input lines on `" -> "`:
```q
q)p:" -> "vs/:x
q)p
,"pbga (66)"
,"xhth (57)"
,"ebii (61)"
,"havc (66)"
,"ktlj (57)"
("fwft (72)";"ktlj, cntj, xhth")
..
```
We further split the left sides on spaces:
```q
q)p2:" "vs/:p[;0]
q)p2
"pbga" "(66)"
"xhth" "(57)"
"ebii" "(61)"
"havc" "(66)"
"ktlj" "(57)"
"fwft" "(72)"
..
```
We convert the node names to symbols:
```q
q)n
`pbga`xhth`ebii`havc`ktlj`fwft`qoyq`padx`tknk`jptl`ugml`gyxo`cntj
```
To create the first part of the table, we cut the first and last characters (the parentheses) from
the second elements and convert them to integers:
```q
q)n:`$p2[;0]
q)n
`pbga`xhth`ebii`havc`ktlj`fwft`qoyq`padx`tknk`jptl`ugml`gyxo`cntj
q)1_/:-1_/:p2[;1]
"66"
"57"
"61"
"66"
"57"
"72"
..
q)"J"$1_/:-1_/:p2[;1]
66 57 61 66 57 72 66 45 41 61 68 61 57
q)n1:([n]w:"J"$1_/:-1_/:p2[;1])
q)n1
n   | w
----| --
pbga| 66
xhth| 57
ebii| 61
havc| 66
ktlj| 57
fwft| 72
..
```
To generate the parents, we split the children on `", "` and convert the result to symbol. Since
this results in an erroneous null symbol for nodes with no children, we have to filter those out.
```q
q)", "vs/:p[;1]
,""
,""
,""
,""
,""
("ktlj";"cntj";"xhth")
..
q)`$", "vs/:p[;1]
,`
,`
,`
,`
,`
`ktlj`cntj`xhth
..
q)(`$", "vs/:p[;1])except\:`
`symbol$()
`symbol$()
`symbol$()
`symbol$()
`symbol$()
`ktlj`cntj`xhth
..
```
To get the child to parent mapping, we put the parents and children into a table and ungroup it. We
change the key to the child in order to get a table that conforms with the weights table from
earlier.
```q
q)([]p:n;n:(`$", "vs/:p[;1])except\:`)
p    n
--------------------
pbga `symbol$()
xhth `symbol$()
ebii `symbol$()
havc `symbol$()
ktlj `symbol$()
fwft `ktlj`cntj`xhth
..
q)ungroup([]p:n;n:(`$", "vs/:p[;1])except\:`)
p    n
---------
fwft ktlj
fwft cntj
fwft xhth
padx pbga
padx havc
..
q)`n xkey ungroup([]p:n;n:(`$", "vs/:p[;1])except\:`)
n   | p
----| ----
ktlj| fwft
cntj| fwft
xhth| fwft
pbga| padx
havc| padx
..
```
We perform a sideways join to get the final table.
```q
q)n1,'`n xkey ungroup([]p:n;n:(`$", "vs/:p[;1])except\:`)
n   | w  p
----| -------
pbga| 66 padx
xhth| 57 fwft
ebii| 61 ugml
havc| 66 padx
ktlj| 57 fwft
..
```

## Part 1
We call the common function to generate the node table:
```q
q)nodes:d7 x
q)nodes
n   | w  p
----| -------
pbga| 66 padx
xhth| 57 fwft
ebii| 61 ugml
havc| 66 padx
ktlj| 57 fwft
..
```
The node we are looking for is the one with no parent. When we created the table by joining the
parent table to the weight table, the root node was not present in the parent table, so the `p`
column was filled in with a null symbol. We simply have to find this value and return the
corresponding node name from the `n` column.
```q
q)exec first n from nodes where null p
`tknk
```

## Part 2
We call the common function to generate the node table:
```q
q)nodes:d7 x
q)nodes
n   | w  p
----| -------
pbga| 66 padx
xhth| 57 fwft
ebii| 61 ugml
havc| 66 padx
ktlj| 57 fwft
..
```
We regenerate the parent-child map by grouping the table by `p`:
```q
q)child:exec n by p from nodes
q)child
    | ,`tknk
fwft| `xhth`ktlj`cntj
padx| `pbga`havc`qoyq
tknk| `fwft`padx`ugml
ugml| `ebii`jptl`gyxo
```
We also generate the [transitive closure](../utils/patterns.md#transitive-closure) of this map in
order to calculate the total weight held by
each node:
```q
q)child1:{{asc distinct raze x}each value[x],'x x}/[child]
q)child1
    | `s#`cntj`ebii`fwft`gyxo`havc`jptl`ktlj`padx`pbga`qoyq`tknk`ugml`xhth
fwft| `s#`cntj`ktlj`xhth
padx| `s#`havc`pbga`qoyq
tknk| `s#`cntj`ebii`fwft`gyxo`havc`jptl`ktlj`padx`pbga`qoyq`ugml`xhth
ugml| `s#`ebii`gyxo`jptl
```
We calculate the total weight for each node. To do this, we sum the weights based on the transitive
closure, then add the weight of the node itself.
```q
q)nodes[([]n:child1);`w]
    | 57 61 72 61 66 61 57 45 66 66 41 68 57
fwft| 57 57 57
padx| 66 66 66
tknk| 57 61 72 61 66 61 57 45 66 66 68 57
ugml| 61 61 61
q)sum each nodes[([]n:child1);`w]
    | 778
fwft| 171
padx| 198
tknk| 737
ugml| 183
q)cw:(exec n!w from nodes)+sum each nodes[([]n:child1);`w]
q)cw
pbga| 66
xhth| 57
ebii| 61
havc| 66
ktlj| 57
..
```
We calculate the weight of the children of each node based on the above map. We drop the mapping for
the blank symbol as that corresponds to the implicitly added root node of the tree which we don't
care about.
```q
q)cws:cw `_ child
q)cws
fwft| 57  57  57
padx| 66  66  66
tknk| 243 243 251
ugml| 61  61  61
```
We find which nodes are imbalanced by counting how many distinct values there are among the weights
of its children:
```q
q)imbal:where 1<count each distinct each cws
q)imbal
,`tknk
```
We filter the list to those nodes which are not the child of another imbalanced node. This is not
relevant in the example input as there is only one imbalanced node, but this is required for the
real input. Since there should only ever be one node that has no imbalanced children, we take the
first element of the filtered list.
```q
q)bad:first imbal where not any each child[imbal] in\:imbal
q)bad
`tknk
```
We cache the children of the bad node and group the weights:
```q
q)w:group cw c:child bad
q)c
`fwft`padx`ugml
q)w
243| 0 1
251| ,2
```
We find the correct weight by checking which group has more than one member, and the bad weight by
which group has exactly one member:
```q
q)corrw:first where 1<count each w
q)badw:first where 1=count each w
q)corrw
243
q)badw
251
```
The amount to fix the bad node is the difference between the two:
```q
q)diff:badw-corrw
q)diff
8
```
We find the weight of the bad child and subtract the diff to get the final answer:
```q
q)c w[badw]0
`ugml
q)nodes[c w[badw]0;`w]
68
q)nodes[c w[badw]0;`w]-diff
60
```
