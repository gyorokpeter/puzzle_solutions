# Breakdown

Example input:
```q
x:"\n"vs"jqt: rhn xhk nvd\nrsh: frs pzl lsr\nxhk: hfx\ncmg: qnr nvd lhk bvb\nrhn: xhk bvb hfx";
x,:"\n"vs"bvb: xhk hfx\npzl: lsr hfx nvd\nqnr: nvd\nntq: jqt hfx bvb xhk\nnvd: lhk\nlsr: lhk";
x,:"\n"vs"rzs: qnr cmg lsr rsh\nfrs: qnr lhk lsr";
```

## Part 1
The goal is to find the 3 "bridges" that connect the two components and remove them from the graph. We start from an abitrary node and generate the shortest paths to every node in the graph. Then we find which nodes appear most frequently across all of the shortest paths. Obviously the most frequent one will be the one we started from, but the second one is more interesting - it indicates that a disproportionate number of paths goes through this node, which is a signal that a bridge may be in that direction. So we step onto the second-most-frequent node and repeat the path generation process and find the second-most-frequent node in the new result. We keep the list of nodes that we used as the starting point. Eventually we will reach a point where we are supposed to turn back to an already visited node. This suggests that we found a bridge. We remove the bridge from the graph and continue exploring using the same method as above. Eventually after removing a bridge we will find that some nodes are not reachable from the starting node. In a well-formed input this will happen exactly after we remove 3 bridges. So we find the number of reachable and unreachable nodes, and the product of these two numbers is the answer.

### Top node search
The function `.d25.topNodes` takes two arguments: the parsed connectivity map and the starting node.
```q
q)conn2
bvb| `xhk`hfx`cmg`rhn`ntq
cmg| `qnr`nvd`lhk`bvb`rzs
frs| `qnr`lhk`lsr`rsh
hfx| `xhk`rhn`bvb`pzl`ntq
jqt| `rhn`xhk`nvd`ntq
lhk| `cmg`nvd`lsr`frs
lsr| `lhk`rsh`pzl`rzs`frs
ntq| `jqt`hfx`bvb`xhk
nvd| `lhk`jqt`cmg`pzl`qnr
pzl| `lsr`hfx`nvd`rsh
qnr| `nvd`cmg`rzs`frs
rhn| `xhk`bvb`hfx`jqt
rsh| `frs`pzl`lsr`rzs
rzs| `qnr`cmg`lsr`rsh
xhk| `hfx`jqt`rhn`bvb`ntq
q)start
`bvb
```
We generate all the paths from the start node using BFS. We initialize the queue to contain the start node, make a parent map with all nodes having a null parent, and set the parent of the start node to a dummy value, in this case ``` `000 ```. This allows using the null values to indicate unvisited nodes.
```q
queue:enlist start
parent:key[conn2]!count[conn2]#`
parent[first queue]:`000
```
The BFS is rather simple, we update the parent of every node visited and we don't step onto already visited nodes.
```q
while[count queue;
    nxts:raze queue,/:'conn2 queue;
    nxts:nxts where null parent nxts[;1];
    parent[nxts[;1]]:nxts[;0];
    queue:distinct nxts[;1];
];
```
We need to be prepared for the final state when not all nodes are reachable from the start node. In which case we return a value indicating this fact, with `0b` in the first element and the grouping of nodes based on whether they were visited or not. Since a null parent indicates unvisited nodes, the grouping is a simple as using `group` on the parent map after calling `null` on it.
```q
if[any null parent; :(0b;value group null parent)]
```
Otherwise we generate the paths by following the parent map. Simply applying the `\` iterator to the map turns it into a function that follows the map until it hits a fixed point. Due to how the map was constructed, this means it will follow the path back to the start node, then find that its parent is ``` `000 ```, try to follow that but that's not in the map so it gets a null symbol instead, and the null symbol itself is also not in the map so it gets another null symbol, which is a fixed point. Overall this means applying the iterated map to every node results in all paths but with two junk elements at the end that we can easily cut off.
```q
paths:-2_/:(parent\)each key conn2
```
We generate the frequencies of the nodes in the path using `group`.
```q
freq:desc count each group raze paths
```
Since previously returned a result with `0b` for the disconnected case, for the regular case we will return a result with `1b` in the first element and the top few most frequent nodes. (2 would be enough but I left the number at 10 that was there during debugging.)
```q
(1b;10#freq)
```

### Main logic
We cut the input and construct the map from the left side and a further cut of the right side:
```q
q)p:": "vs/:x
q)conn:(`$p[;0])!`$" "vs/:p[;1]
q)conn
jqt| `rhn`xhk`nvd
rsh| `frs`pzl`lsr
xhk| ,`hfx
cmg| `qnr`nvd`lhk`bvb
rhn| `xhk`bvb`hfx
bvb| `xhk`hfx
pzl| `lsr`hfx`nvd
qnr| ,`nvd
ntq| `jqt`hfx`bvb`xhk
nvd| ,`lhk
lsr| ,`lhk
rzs| `qnr`cmg`lsr`rsh
frs| `qnr`lhk`lsr
```
We need the edges to go both ways, so we put the map into a temporary table to be able to ungroup it, then add the reverse of each edge and group again:
```q
q)e:{distinct x,reverse each x}raze(`$p[;0]),/:'`$" "vs/:p[;1]
q)conn2:exec t by s from flip`s`t!flip e
q)conn2
bvb| `xhk`hfx`cmg`rhn`ntq
cmg| `qnr`nvd`lhk`bvb`rzs
frs| `qnr`lhk`lsr`rsh
hfx| `xhk`rhn`bvb`pzl`ntq
jqt| `rhn`xhk`nvd`ntq
lhk| `cmg`nvd`lsr`frs
lsr| `lhk`rsh`pzl`rzs`frs
ntq| `jqt`hfx`bvb`xhk
nvd| `lhk`jqt`cmg`pzl`qnr
pzl| `lsr`hfx`nvd`rsh
qnr| `nvd`cmg`rzs`frs
rhn| `xhk`bvb`hfx`jqt
rsh| `frs`pzl`lsr`rzs
rzs| `qnr`cmg`lsr`rsh
xhk| `hfx`jqt`rhn`bvb`ntq
```
It can be useful to visualize the graph. The following can be used in the Graphviz `neato` utility:
```q
q)e2:e{where x[;0]<x[;1]}(distinct raze e)?e
q)-1"graph G {\n",raze[{"    \"",string[x 0],"\" -- \"",string[x 1],"\"\n"}each e2],"}";
q)-1"graph G {\n",raze[{"    \"",string[x 0],"\" -- \"",string[x 1],"\"\n"}each e2],"}";
graph G {
    "jqt" -- "rhn"
    "jqt" -- "xhk"
    "jqt" -- "nvd"
    "rsh" -- "frs"
    "rsh" -- "pzl"
    "rsh" -- "lsr"
    "xhk" -- "hfx"
    "cmg" -- "qnr"
    "cmg" -- "lhk"
    "cmg" -- "bvb"
    "rhn" -- "xhk"
    "rhn" -- "bvb"
    "rhn" -- "hfx"
    "pzl" -- "lsr"
    "pzl" -- "hfx"
    "nvd" -- "lhk"
    "lsr" -- "lhk"
    "frs" -- "qnr"
    "frs" -- "lhk"
    "frs" -- "lsr"
    "nvd" -- "cmg"
    "xhk" -- "bvb"
    "hfx" -- "bvb"
    "nvd" -- "pzl"
    "nvd" -- "qnr"
    "jqt" -- "ntq"
    "hfx" -- "ntq"
    "bvb" -- "ntq"
    "xhk" -- "ntq"
    "qnr" -- "rzs"
    "cmg" -- "rzs"
    "lsr" -- "rzs"
    "rsh" -- "rzs"
}
```
Note that on the real input the nodes will be very tightly packed, but the bridges will be clearly visible with their node labels, allowing easier debugging (and possibly cheating by removing the edges from the input and then counting the nodes in the components which only requires a simple BFS).

We want to walk through the graph and find the bridges. We start with an arbitrary node:
```q
curr:first key conn2
```
We initialize a `seen` list to be empty:
```q
seen:()
```
We iterate with no upfront end condition, as the exit condition will be checked in the middle:
```q
while[1b; ... ]
```
At each step, we first add the current node to the seen list:
```q
seen,:curr
```
We run the top nodes function to examine the paths from the current node:
```q
nxt:.d25.topNodes[conn2;curr]
```
If the first element of the result is false, we are finished as the graph is no longer connected. The second element will contain the nodes in the two components, so we need to count them and multiply the two results together, returning the result.
```q
if[not first nxt;
    :prd count each nxt 1;
];
```
Otherwise we update the current node to be the second-most-frequent node in the dictionary that is the second element of the result:
```q
curr:key[nxt[1]][1]
```
We check if the current node is already seen. If it is, that means we just backtracked through a bridge.
```q
if[curr in seen;
    ...
    -1"found bridge: ",.Q.s1 bridge;
    ...
];
```
The bridge will consist of the last two elements in the `seen` list. We remove the corresponding edges from `conn2` and reset the `seen` list to empty. No further handling is needed, as the iteration will continue from the "bridgehead" and eventually find the next bridge.
```q
if[curr in seen;
    bridge:-2#seen;
    -1"found bridge: ",.Q.s1 bridge;
    conn2[bridge 0]:conn2[bridge 0] except bridge 1;
    conn2[bridge 1]:conn2[bridge 1] except bridge 0;
    seen:();
];
```
We continue on to the next iteration and we eventually end up with a disconnected graph which will trigger a return in the middle of the iteration.
