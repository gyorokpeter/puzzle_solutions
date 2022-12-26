# Breakdown
Example input:
```q
x:"\n"vs"498,4 -> 498,6 -> 496,6\n503,4 -> 502,4 -> 502,9 -> 494,9";
```

## Common
We first cut the input lines on the separator `" -> "`, then on commas within each coordinate pair:
```q
q)a:"J"$","vs/:/:" -> "vs/:x;
q)a
(498 4;498 6;496 6)
(503 4;502 4;502 9;494 9)
```
We expand the coordinate lists to get every single coordinate along the way. For a coordinate pair `x` leading to coordinate pair `y`:

First we check if the destination is nonempty (the reason for this will be evident later):
```q
if[0=count y;:()]
```
We put the pairs in order, so we are going left->right or top->down:
```q
c:asc(x;y);x:c 0;y:c 1;
```
We check if the line is horizontal or vertical by comparing the first coordinates:
```q
$[x[0]=y[0];
```
For the horizontal case, we concatenate the fixed first coordinate to the range of second coordinates:
```q
x[0],/:x[1]+til 1+y[1]-x[1];
```
Similarly for the vertical case, where we append the fixed second coordinate on the right:
```q
(x[0]+til 1+y[0]-x[0]),\:x[1]]
```
Putting this together:
```q
f:{if[0=count y;:()];c:asc(x;y);x:c 0;y:c 1;$[x[0]=y[0];x[0],/:x[1]+til 1+y[1]-x[1];(x[0]+til 1+y[0]-x[0]),\:x[1]]};
```
This function can be used with `':` _each-prior_ to enumerate all the coordinates in a possibly multi-segment line. The only annoyance is that for the first element, each-prior will try to match it with an empty list as a starting value, which is why we need the check for the second coordinates being empty. Furthermore we do this to every line, requiring an use of `'` _each_.
```q
c:reverse each distinct raze raze f':'[a];
```
We calculate the top-left position, also taking the account the source of sand:
```q
start:min enlist[0 500],c;
```
We calculate the size as the maximum difference along each coordinate:
```q
size:1+max[c]-min[c];
```
We calculate the max height (which is relevant for part 2 only):
```
maxh:max[c[;1]];
```
If we are in part 2, we expand the field on the left to have plenty of space. There is surely a better way to calculate this without being wasteful but also providing all the necessary space, but I didn't bother as I was frustrated as it is with repeatedly giving _too little_ space.
```q
if[part=2; start[1]:min(start 1;500-maxh)];
```
We subtract the start position from the coordinates to ensure they are non-negative:
```q
b:c-\:start;
```
We do the same transformation to the sand origin:
```q
origin:0 500-start;
```
We calculate the bottom-right for the transformed coordinates:
```q
end:max b;
```
Once again if we are in part 2, we expand the field on the right:
```q
if[part=2; end[0]+:1;end[1]:max(end 1;origin[1]+maxh)];
```
We generate the map with `#` symbols for walls, using amend with over to assign the coordinates one by one:
```q
map:.[;;:;"#"]/[(1+end)#" ";b];
```
For part 2, we add a long wall at the bottom:
```q
if[part=2; map,:enlist (1+end[1])#"#"];
```
Dropping the sand is a DFS. We initialize a "queue" (really it's a stack) to the sand origin point:
```q
queue:enlist origin;
```
The main iteration will continue as long as there are items in the queue:
```q
while[count queue;
```
We process the last item in the queue:
```q
pos:last queue;
```
We set up a condition for whether we are finished, initializing it to false:
```q
finish:0b;
```
We also set up another condition for an inner loop, which we will repeat as long as the grain of sand can move:
```
moved:1b;
while[moved;
```
In the inner loop, we start assuming that the sand didn't move:
```q
moved:0b;
```
We check which way the sand can fall by checking which of the three coordinates below the current coordinate are free, using the corect order of priority:
```q
nudge:$[" "=map[pos[0]+1;pos[1]];0;
    " "=map[pos[0]+1;pos[1]-1];-1;
    " "=map[pos[0]+1;pos[1]+1];1;
    0N];
```
We also specifically check if the current position is already blocked or we are off the map, which indicates the finish conditions:
```q
if[not[" "=map . pos] or (pos[0]>=count map) or (pos[1]<0) or (pos[1]>=count first map); nudge:0N; finish:1b];
```
If the above checks indicate that we should move (`nudge` is not null), we perform the move:
```q
if[not null nudge;
    moved:1b;
    pos+:(1;nudge);
```
Then we also try to make the sand fall as much as possible vertically by checking where the next obstacle is:
```q
pos[0]:count[map]^pos[0]+first where not" "=(1+pos[0])_map[;pos[1]];
```
We add the updated position to the queue:
```q
queue,:enlist pos;
];
];
```
Now we are done with moving the sand as much as possible. If we are not finished, we put the new grain of sand on the map:
```q
if[not finish; map:.[map;pos;:;"o"]];
```
We pop the last entry from the stack so we can resume moving without having to trace another grain of sand from the beginning. I got the idea for this optimization from Reddit.
```q
queue:-1_queue;
```
If we are finished, we add a safety catch to clear the queue such that the outer loop quits:
```q
if[finish; queue:()];
];
```
Finally we count the number of `o` characters on the map which indicate the sand:
```q
sum sum "o"=map
```
