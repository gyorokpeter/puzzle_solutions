# Breakdown
Example input:
```q
x:"\n"vs"#.######\n#>>.<^<#\n#.<..<<#\n#>v.><>#\n#<^v^^>#\n######.#";
```

## Common
We cache the width and height of the map:
```q
w:count first x; h:count x;
```
We find the start position (although it should be constant):
```q
s:0,first where"."=first x;
```
We also find the target position:
```q
t:(count[x]-1),first where"."=last x;
```
We map the blizzard directions to integers:
```q
bdirm:">v<^"?x;
```
We extract the blizzard coordinates:
```q
bpos:raze til[count x],/:'where each 4>bdirm;
```
We extract the blizzard directions:
```q
bdir:bdirm ./:bpos;
```
We cache the movement deltas, including a no-move option for waiting:
```q
moves:(0 1;1 0;0 -1;-1 0;0 0);
```
We make queues of the start and finish positions depending on the part. For part 1, we only need to go from `s` to `t`. For part 2 we also need to do the trip in reverse and then forward again.
```q
squeue:$[part=1;enlist s;(s;t;s)];
tqueue:$[part=1;enlist t;(t;s;t)];
```
We initialize the round counter to zero:
```q
round:0;
```
We iterate over the start/finish position pairs:
```q
while[count squeue;
    s:first squeue; t:first tqueue;
    squeue:1_squeue; tqueue:1_tqueue;
```
Within each iteration, we initialize the node queue and the found indicator:
```q
queue:enlist s;
found:0b;
```
Then we do a nested iteration that is a BFS. We don't have to pre-generate all the blizzard positions, since the search ends in a relatively low amount of steps. The exit condition is the `found` variable introduced above:
```q
while[not found;
```
We check for the queue becoming empty. This is not necessary but I prefer the defensive coding in case there is an error in the loop.
```q
if[0=count queue; '"no solution?!"];
```
We increment the round counter:
```q
round+:1;
```
We add the corresponding movement vector to the blizzard coordinates:
```q
bpos+:moves bdir;
```
We wrap around the blizzards as necessary:
```q
bpos[where bpos[;0]=0;0]:h-2;
bpos[where bpos[;1]=0;1]:w-2;
bpos[where bpos[;0]=h-1;0]:1;
bpos[where bpos[;1]=w-1;1]:1;
```
We find the distinct blizzard positions:
```q
dbpos:distinct bpos;
```
We expand the nodes in the queue by adding all possible movement vectors including the one for no movement:
```q
queue:distinct raze queue+/:\:moves;
```
We remove any positions that overlap with blizzards:
```q
queue:queue except dbpos;
```
We filter to positions within the bounds of the map:
```q
queue:queue where all each queue within\:(0 0;(h-1;w-1));
```
We also filter out any positions overlapping walls:
```q
queue:queue where "#"<>x ./:queue;
```
We check for arriving at the target position, and both loops end here:
```q
if[t in queue; found:1b];
];
];
```
At the end, the `round` counter is returned.
