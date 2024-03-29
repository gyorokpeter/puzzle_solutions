# Breakdown
Example input:
```q
x:enlist"Valve AA has flow rate=0; tunnels lead to valves DD, II, BB";
x,:enlist"Valve BB has flow rate=13; tunnels lead to valves CC, AA";
x,:enlist"Valve CC has flow rate=2; tunnels lead to valves DD, BB";
x,:enlist"Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE";
x,:enlist"Valve EE has flow rate=3; tunnels lead to valves FF, DD";
x,:enlist"Valve FF has flow rate=0; tunnels lead to valves EE, GG";
x,:enlist"Valve GG has flow rate=0; tunnels lead to valves FF, HH";
x,:enlist"Valve HH has flow rate=22; tunnel leads to valve GG";
x,:enlist"Valve II has flow rate=0; tunnels lead to valves AA, JJ";
x,:enlist"Valve JJ has flow rate=21; tunnel leads to valve II";
```

## Part 1
We split the lines on spaces and remove the commas:
```q
q)a:(" "vs/:x except\:";,");
q)a
("Valve";"AA";"has";"flow";"rate=0";"tunnels";"lead";"to";"valves";"DD";"II";"BB")
("Valve";"BB";"has";"flow";"rate=13";"tunnels";"lead";"to";"valves";"CC";"AA")
..
```
We extract the names, flow rates and edges from the input:
```q
q)n:`$a[;1]; flow:n!"J"$5_/:a[;4]; edge:n!`$9_/:a;
q)n
`AA`BB`CC`DD`EE`FF`GG`HH`II`JJ
q)flow
AA| 0
BB| 13
..
q)edge
AA| `DD`II`BB
BB| `CC`AA
..
```
We transform the symbolic names to numeric indices:
```q
q)n:asc n; flow2:flow n; edge2:n?edge n;
q)flow2
0 13 2 20 3 0 0 22 0 21
q)edge2
3 8 1
2 0
3 1
..
```
We cache the count of the nodes:
```q
q)c:count n;
q)c
10
```
We generate the list of edges as pairs, as opposed to an array of destinations from each node:
```q
q)edge3:raze til[c],/:'edge2;
q)edge3
0 3
0 8
0 1
1 2
1 0
..
```
We use the Floyd-Warshall algorithm to calculate the distances between every pair of edges (the large numerical constant is a stand-in for infinity - even though q has 0W, that doesn't play well with the arithmetic used in this algorithm so we must choose a number that remains positive when added to itself):
```q
q)dist:(c;c)#4000000000000000000;
q)dist:.[;;:;0]/[dist;{x,'x}til c];
q)dist:.[;;:;1]/[dist;edge3];
q)dist:{[x;i]x&x[;i]+/:\:x[i;]}/[dist;til c];
q)dist
0 1 2 1 2 3 4 5 1 2
1 0 1 2 3 4 5 6 2 3
2 1 0 1 2 3 4 5 3 4
1 2 1 0 1 2 3 4 2 3
..
```
We only care about the nodes with non-zero flow, so we save the indices of these, with the exception of the starting node, which is easier to save despite the zero flow than keep making exceptional cases to handle it:
```q
q)pfi:distinct 0,where 0<flow2;
q)pfi
0 1 2 3 4 7 9
```
We also reduce the distance matrix using these indices:
```q
q)dist2:{x[y;y]}[dist;pfi];
q)dist2
0 1 2 1 2 5 2
1 0 1 2 3 6 3
2 1 0 1 2 5 4
..
```
We reduce the flow array using the indices to find the positive flow array (except the starting node which has zero flow):
```q
q)pf:flow2 pfi;
q)pf
0 13 2 20 3 22 21
```
We cache the count of the positive flow array:
```q
cpf:count pf;
```
We will search for the best flows using BFS. The node will consist of four fields: which valves are on (boolean list), the current position, the elapsed time and the total flow that we would get if we stopped right there. We initialize the queue with the values corresponding to the initial state:
```q
queue:enlist`on`pos`time`tflow!(0=til cpf;0;0;0);
```
We also initialize a dictionary to save the max flow for every combination of open valves. This is only relevant for part 2. For part 1 it would be enough to only track the ultimate maximum which allows for a smart pruning tactic, however that would lose information that is useful for part 2.
```q
q)maxflows:enlist[cpf#0b]!enlist 0;
q)maxflows
0000000b| 0
```
We run the main loop as long as there are elements in the queue:
```q
while[count queue;
```
We expand each node by setting all the nodes that are not `on` as the next node:
```q
nq:queue;
nq:raze{x,/:([]npos:where not x`on)}each nq;
```
The main processing only needs to take place if the queue is not empty after the expansion:
```q
if[count nq;
```
We update the `on` state, position and elapsed time based on the next position for each node:
```q
nq:update on:@[;;:;1b]'[on;npos], pos:npos, time:1+time+dist2 ./:(pos,'npos) from nq;
```
We delete nodes where we would go above the allowed time:
```q
nq:delete from nq where time>=dur;
```
We update the total flow by calculating how much flow will be provided by opening the current valve:
```q
nq:update tflow:tflow+(dur-time)*pf npos from nq;
```
We update the maximum flow if the current queue contains any node that beats the current maximum:
```q
maxflows|:exec on!tflow from nq;
```
We replace the queue with the new queue:
```q
];
queue:nq;
```
Once we are out of nodes, for part 1, we check the highest flow for any combination of valves:
```q
if[part=1; :max maxflows];
```

## Part 2
Having two agents means we effectively do the valve-opening procedure twice, and as long as the same valve is not opened by both agents, the flow from the two agents is additive. Although it is possible to simulate in the BFS by adding the ability to reset the time and location while keeping the `on` states and total flow, that would be quite slow. Instead, the fact that we saved the maximum flow for every combination of open valves gives a shortcut as we can simply pair up two elements from this dictionary, check that there is no overlap between the open valves, and add the two total flows together. The combination where this sum is the highest will be the answer.

We extract the key of the maxflows dictionary which is the list of possible states for each valve. We drop the first of each key (valve 0) as it's not relevant:
```q
kf:1_/:key maxflows;
```
We also extract the values, which is a list of integers:
```q
vf:value maxflows;
```
We add the items in value list in every possible combination:
```q
vf+/:\:vf
```
To check where the valves overlap, we use the same idiom, with the `and` operator instead, and we check if the sum of the results is zero or not. If there is no overlap, the sum should be zero.
```q
(0=sum each/:kf and/:\:kf)
```
Multiplying the "no overlap" condition by the sum of the flows filters out the invalid scenarios:
```q
(0=sum each/:kf and/:\:kf)*vf+/:\:vf
```
Now we can extract the maximum possible combined flow:
```q
max max (0=sum each/:kf and/:\:kf)*vf+/:\:vf
```
