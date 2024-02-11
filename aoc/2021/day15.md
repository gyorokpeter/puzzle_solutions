# Breakdown
Example input:
```q
x:"\n"vs"1163751742\n1381373672\n2136511328\n3694931569\n7463417111\n1319128137\n1359912421"
x,:"\n"vs"3125421639\n1293138521\n2311944581"
part:1
```

## Common
The solution is almost the same for part 1 and 2. There is extra map preprocessing for part 2.

We use Dijkstra's algorithm to find the shortest path. It is just a rewrite of the canonical
algorithm into q, using vector operations to avoid losing performance.

We convert all the characters in the input to numbers:
```q
    a:"J"$/:/:x;
```
We store the width and height for easier access:
```q
    h:count[a];w:count first a;
```

## Part 2 only
For part 2, we need to expand the map. First we store the original width and height:
```q
    oh:h;ow:w;
```
We repeat the input 5 times in both directions:
```q
    a:(5*h)#(5*w)#/:a-1;
```
We update the width and height to the new sizes:
```q
    h:count[a];w:count first a;
```
We calculate the new risk levels by adding a matrix that contains the coordinates divided by the original width/height.
After the addition we also need to make sure they wrap around after 9. The easiest way to do this is doing a modulo 9
first and then adding 1.
```q
    a:1+(a+(til[h]div oh)+/:\:(til[w]div ow))mod 9;
```

## Common again
We initialize the queue with a single node in the top left (position 0 0) and a path length of 0:
```q
    queue:([]pos:enlist 0 0;len:0);
```
We also initialize the target position and  the shortest distance matrix. The shortest distance starts out as infinity
except for the start position where it's zero.
```q
    target:(h-1;w-1);
    dist:(h;w)#0W;
    dist[0;0]:0;
```
We iterate until we find the solution. The queue should never run out before reaching the goal, but better have standard
error handling in case there are bugs in the implementation.
```q
    while[0<count queue;
        ...
    ];
    '"no solution";
```
In the iteration, we first select all the nodes with the minimum length:
```q
    nxts:select from queue where len=min len;
```
We check if the nodes we found include the target node, in which case the path length of that node is the answer:
```q
    if[target in nxts[`pos]; :exec first len from nxts where target~/:pos];
```
We delete the picked nodes from the queue:
```q
    queue:delete from queue where len=min len;
```
We expand the nodes by adding the coordinates for steps in all 4 directions:
```q
    nxts:raze {x,/:([]npos:x[`pos]+/:(-1 0;0 1;1 0;0 -1))}each nxts;
```
We drop any nodes that would be off the map:
```q
    nxts:select from nxts where npos[;0] within (0;h-1),npos[;1] within (0;w-1);
```
We update the path lengths for the expanded nodes:
```q
    nxts:update len:len+a ./:npos from nxts;
```
We filter the nodes to only keep those which improve upon the best path lengths we already have:
```q
    nxts:select from nxts where len<dist ./:npos;
```
We store the newly found sortest paths into the length matrix:
```q
    dist:exec .[;;:;]/[dist;npos;len] from nxts;
```
We add the expanded nodes to the queue:
```q
    queue,:select pos:npos, len from nxts;
```
We filter the queue to only keep one copy of each position, the one with the shortest path:
```q
    queue:0!select min len by pos from queue;
```
The iteration continues. Eventually the target position will end up being chosen for expansion.
