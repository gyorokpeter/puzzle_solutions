# Breakdown
Example input:
```q
x:enlist"Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.";
x,:enlist"Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.";
```

## Common
We try to parse everything as integers and then throw away the nulls. No need to fiddle with the indices.
```q
q)a:("J"$(" "vs/:x))except\:0N
q)a
4 2 3 14 2 7
2 3 3 8  3 12
```
The main logic is in the function `.d19.checkRecipe` which returns the maximum for a certain maximum time (`mt`) and recipe (`r`).

We use a BFS where the node contains the elapsed time and all the robot and resource counts. Initially we have a single ore bot (`b0`).
```q
queue:enlist`time`b0`b1`b2`b3`m0`m1`m2`m3!@[9#0;1;:;1];
```
We find the maximum ore a bot can cost:
```q
maxb0:max r 0 1 2 4;
```
We initialize the maximum result to zero:
```q
top:0;
```
The main loop will run as long as there are items in the queue:
```q
while[count queue;
```
We calculate an overly generous upper bound (`ub`) based on what would happen if we bought a new geode bot every single remaining turn. If even this estimate means we won't beat the best outcome so far, we can prune this node:
```q
queue:update ub:m3+rmt*(b3+b3+rmt-1)%2 from update rmt:mt-time from queue;
```
We also calculate how many geodes we will get if we stop doing anything:
```q
queue:update ptop:m3+rmt*b3 from queue;
```
We update the top score based on this calculation if necessary:
```q
top|:exec max ptop from queue;
```
We can prune on the upper bounds now:
```q
queue:delete from queue where ub<top;
```
For expanding the nodes, we don't expand every minute, but calculate how many minutes need to pass until we can build a certain bot, then simulate what happens if we wait that many minutes and then build the bot:
```q
qtmp:update b0t:0 or(r[0]-m0)%b0, b1t:0 or(r[1]-m0)%b0, b2t:0 or((r[2]-m0)%b0)or(r[3]-m1)%b1, b3t:0 or((r[4]-m0)%b0)or(r[5]-m2)%b2 from queue;
```
For each bot, we check if we can build it (which means the minutes left is less than infinity), and if so, deduct the cost of the bot. We also take the opportunity to prune such that we don't build more bots than necessary - we don't need more if we can already mine the full cost of a bot in a single turn.
```q
q0:update dtime:ceiling b0t+1, m0-r[0], bt:`b0 from select from qtmp where 0w>b0t, b0<maxb0;
q1:update dtime:ceiling b1t+1, m0-r[1], bt:`b1 from select from qtmp where 0w>b1t, b1<r 3;
q2:update dtime:ceiling b2t+1, m0-r[2], m1-r[3], bt:`b2 from select from qtmp where 0w>b2t, b2<r 5;
q3:update dtime:ceiling b3t+1, m0-r[4], m2-r[5], bt:`b3 from select from qtmp where 0w>b3t;
```
We merge back these four cases into the queue and drop the extra columns:
```q
queue:delete b0t,b1t,b2t,b3t from q0,q1,q2,q3;
```
If there are actually items in the queue, we simulate the passage of time:
```q
if[0<count queue;
    queue:update time+dtime, m0:m0+dtime*b0, m1:m1+dtime*b1, m2:m2+dtime*b2, m3:m3+dtime*b3 from queue;
```
We also add the built bot (which must be added _after_ simulating the resource extraction, therefore we store it in a temporary column `bt`):
```q
queue:delete dtime,bt from @[;;+;1]'[queue;exec bt from queue];
```
We prune the nodes where the maximum time would be exceeded:
```q
queue:distinct delete from queue where time>mt;
```
This is the end of the main loop. Once we are out of nodes to expand, we simply return the maximum found score:
```q
];
];
top
```

## Part 1
We use the function above to check each recipe and multiply their maxima by the recipe index, which must be incremented by 1.
```q
sum(1+til[count x])*d19[24;x]
```
## Part 2
We use the function above on the first 3 recipes and multiply the results together:
```q
prd d19[32;3 sublist x]
```

I used `sublist` here because the example input only contains 2 recipes so "only having the first 3 out of 2 recipes" doesn't make sense. Normally I would use `#`, but in that case that would duplicate the first recipe and give a nonsense answer.

## Note
The title refers to StarCraft, where you need to collect minerals to build units. In the case of the Protoss, if you try to build something when you don't have the required minerals for it, the advisor will say "You've not enough minerals".
