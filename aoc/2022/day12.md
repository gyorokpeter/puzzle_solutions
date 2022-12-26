# Breakdown
Example input:
```q
x:"\n"vs"Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi";
```

## Common
We convert the map to a numerical heightmap. We need to replace `S` and `E` with `a` and `z` respectively to get the correct values.
```q
q)a:-97+`int$ssr/[;"SE";"az"]each x;
q)a
0 0 1 16 15 14 13 12
0 1 2 17 24 23 23 11
0 2 2 18 25 25 23 10
0 2 2 19 20 21 22 9
0 1 3 4  5  6  7  8
```
We get the coordinates of the start and end point by looking for the respective letters:
```q
q)st:raze raze each til[count x],/:'/:where each/:x=/:"SE";
q)st
0 0
2 5
```
We initialize a visited array with zeros. This `x<>x` trick is an easy way to initialize a boolean vector or matrix with zeros.
```q
q)visited:a<>a;
q)visited
00000000b
00000000b
00000000b
00000000b
00000000b
```
We initialize a queue. For part 1, the queue will only contain the start point designated by `S`. For part 2, it will be all the `a` tiles.
```q
q)queue:$[part=1;enlist first st;raze til[count x],/:'where each a=0];
q)queue
0 0
```
We initialize the step counter to zero.
```q
d:0;
```
The rest of the solution is a vector BFS. For each iteration we do the following:

We increment the step counter:
```q
d+:1;
```
We mark all the tiles in the queue as visited:
```q
visited:.[;;:;1b]/[visited;queue];
```
We expand all the nodes in the queue by adding the four cardinal directions:
```q
nxts:update queue f from ungroup([]f:til count queue;b:queue+/:\:(-1 0;0 1;1 0;0 -1));
```
We filter the queue on the following constraints: the coordinates must be within the field, they must not be visited, and we can't climb more than a height difference of 1 in each step.
```q
nxts:select from nxts where b[;0]>=0,b[;1]>=0,b[;0]<count a,b[;1]<count first a,not visited ./:b,(a ./:f)>=(a ./:b)-1;
```
We deduplicate the found destination coordinates:
```q
queue:exec distinct b from nxts;
```
At this point if the destination is in the queue, we immediately return the step counter:
```q
if[st[1] in queue; :d];
```
Otherwise the next iteration of the loop starts.

If the queue becomes empty, we throw an error. This is not necessary, but I like to code it this way in case I mess up the implementation of the loop.

## Note
The vector BFS is the adaptation of regular BFS into an array language. Instead of processing the nodes in the queue one by one, we process every item in the queue at the same time. The step counter goes up by one in each iteration. This is more efficient than trying to implement a regular BFS in q because that would require removing and adding single elements from the list for every single element processed, which would add up to considerable run time.
