# Breakdown

Example input:
```q
x:"\n"vs"2413432311323\n3215453535623\n3255245654254\n3446585845452\n4546657867536\n1438598798454";
x,:"\n"vs"4457876987766\n3637877979653\n4654967986887\n4564679986453\n1224686865563\n2546548887735\n4322674655533";
```

## Common
The common logic (`d17`) takes three arguments: the minimum and maximum moves required for turning (`moMin` and `moMax`) and the map. We use a modified Dijkstra's algorithm to find the path. Just like a vector BFS, the vector Dijkstra processes all of the nodes with a minimal path length at once.

We convert the input into integers:
```q
a:"J"$/:/:x
```
The node in the queue will have five fields: row, column, direction (0=north, 1=east, 2=south, 3=west), moves since last turn and total heat loss. The first four fields are all part of the "position" of the node. We need two starting nodes: both start from the top left but one points east and one points south. For part 1 it is enough to use only one starting node, since a turn on the first step can stand in for having the other starting node. However in part 2 this would be a mistake since we can't turn on the first step (the movement counter is at zero), which means the search would miss any path that starts by going south.
```q
q0:`r`c`d`mo`h!0 0 1 0 0
q1:q0; q1[`d]:2
queue:4!(q0;q1)
```
We also maintain a "heat" map that will be updated with the shortest paths as we find them:
```q
heat:();
```
This time we won't iterate until the queue is empty. Instead the queue becoming empty is a failure condition. This is not strictly necessary to handle but it is useful during testing to avoid an infinite loop.
```q
while[1b;
    if[0=count queue;'"no solution?!"];
    ...
]
```
We pick the nodes from the queue with the minimum total heat:
```q
nxts:select from queue where h=min h
```
We check if there are any finishing nodes. (During implementation this is the bit of code that is added last, but comes early in the logic.) We need to check both the coordinates and the minimum movement requirement. If there are any such nodes, we return the minimum heat value.
```q
if[count finish:select from nxts where r=count[a]-1,c=count[a 0]-1,mo>=moMin;:exec min h from finish];
```
We append the selected nodes to the heat map, which will also overwrite any already existing values:
```q
heat,:nxts
```
We update the queue by deleting the nodes we picked out:
```q
queue:delete from queue where h=min h
```
We expand each selected node with a direction delta (`dd`) of either -1, 0 or 1 (for turning left, continuing straight and turning right):
```q
nxts:ungroup update dd:{0 -1 1}each i from nxts
```
We drop the nodes where we want to turn but we don't meet the minimum move requirement:
```q
nxts:delete from nxts where dd<>0, mo<moMin
```
We "commit" the direction change (addition modulo 4) and also update the movement count depending on whether we are turning or not:
```q
nxts:delete dd from update mo:?[dd=0;mo+1;1],d:(d+dd)mod 4 from nxts
```
We update the position based on the current direction:
```q
nxts:update r+-1 0 1 0 d,c+0 1 0 -1 d from nxts
```
We filter out nodes that would go off the map or breach the move count limit:
```q
nxts:delete from nxts where not (moMax>=mo) and (r within (0;count[a]-1)) and c within (0;count[a 0]-1)
```
We update the total heat by adding the value at the current position:
```q
nxts:update h+a ./:(r,'c) from nxts
```
We delete nodes where we know there is a way to reach the coordinate/direction/moves combination in less heat:
```q
nxts:delete from nxts where (0W^heat[key 4!nxts;`h])<h
```
We append the remaining nodes to the queue, then select the minimum heat by position in case there are multiple nodes for the same position in the queue:
```q
queue:select min h by r,c,d,mo from nxts,0!queue
```
We continue to the next iteration here. There is no return at the end of the function, as we only return if we found a finishing node when we check for it near the beginning of the iteration.

## Part 1
We call the common logic with a minimum move count of 0 and a maximum move count of 3.
```q
q)d17[0;3;x]
102
```

## Part 2
We call the common logic with a minimum move count of 4 and a maximum move count of 10.
```q
q)d17[4;10;x]
94
```