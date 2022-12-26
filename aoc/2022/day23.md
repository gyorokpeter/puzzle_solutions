# Breakdown
Example input:
```q
x:"\n"vs"....#..\n..###.#\n#...#.#\n.#...##\n#.###..\n##.#.##\n.#..#..";
```

## Common
We convert the map to a boolean array using an equality comparison:
```q
map:"#"=x;
```
We initialize the round counter to zero:
```q
round:0;
```
We initialize the direction indices (this will make sense later) and the movement deltas:
```q
moveDirs:(6 3 0;7 4 1;2 0 1;5 3 4);
moveDeltas:(-1 0;1 0;0 -1;0 1);
```
We iterate forever - the exit condition is either reaching round 10 (for part 1) or a round with no changes (part 2):
```q
while[1b;
```
We start by incrementing the round counter:
```q
round+:1;
```
We generate the "neighbor maps" in all 8 directions using the same technique as the classical Conway's Game of Life APL implementation. This will involve adding a filler row at the top or the bottom, so we cache this:
```q
filler:enlist (2+count first map)#0b;
```
We then add a complete blank border around the map:
```q
mapp:filler,(0b,/:map,\:0b),filler;
```
To generate the maps, we rotate each line by -1, 1 and 0 in turn, as well as the whole map by -1, 1 and 0 in turn, giving 9 combinations. The 0 rotations are last as this makes it easy to drop the unchanged map as that will be the last one. Note the order of directions in the resulting list - this is what the `moveDirs` indices refer to.
```q
mapr:-1_raze -1 1 0 rotate\:/:-1 1 0 rotate/:\:mapp;  //NW, SW, W, NE, SE, E, N, S
```
We figure out which elves don't move by checking for tiles with zero neighbors:
```q
noMove:0=sum mapr;
```
We check for potential moves by looking at which directions have 3 empty tiles for each elf:
```q
pmv:3=sum each not[mapr] moveDirs;
```
We extend the "no move" array to include tiles that don't have elves on them, as well as those with no potential moves:
```q
noMove:not[mapp] or noMove or 0=sum pmv;
```
We generate an extended array of potential moves by mapping every layer in `pmv`, plus `noMove` at the beginning, to -1 (`noMove`) or 0..3 if that tile has the value of true, and 0N otherwise. The reason for this is that we can then put the layers on top of each other in reverse order to find which tile will have which movement on it.
```q
pmv2:(0N,/:-1+til 5)@'enlist[noMove],pmv;
```
We calculate the proposals using fill with over:
```q
prop:^/[reverse pmv2];
```
We convert the proposals to coordinates:
```q
propCoord:raze til[count prop],/:'where each prop>-1;
```
We also fetch the directions for the proposals:
```q
propDir:prop ./:propCoord;
```
We calculate the target coordinates from the proposed directions/coordinates:
```q
propDest:propCoord+moveDeltas propDir;
```
We check which destinations are not duplicated:
```q
validDest:where propDest in where 1=count each group propDest;
```
At this point if we are in part 2 and there are no valid destinations, we are done and return the round number:
```q
if[(part=2) and 0=count validDest; :round];
```
We filter the proposals to the valid ones:
```q
propCoord:propCoord validDest;
propDest:propDest validDest;
```
We remove the moving elves from their starting positions and add them back at their destinations:
```q
mapp:.[;;:;0b]/[mapp;propCoord];
mapp:.[;;:;1b]/[mapp;propDest];
```
We remove any blank edges from the padded map, and replace the original (unpadded) map with the result:
```q
while[0b=max first mapp; mapp:1_mapp];
while[0b=max last mapp; mapp:-1_mapp];
while[0b=max mapp[;0]; mapp:1_/:mapp];
while[0b=max mapp[;count[first mapp]-1]; mapp:-1_/:mapp];
map:mapp;
```
We rotate the move priorities in preparation for the next round:
```q
moveDirs:1 rotate moveDirs;
moveDeltas:1 rotate moveDeltas;
```
If we are in part 1 and reached round 10, we return the number of empty fields in the unpadded map. Otherwise we move on to the next iteration of the loop.
```q
if[(part=1) and round=10;
    :`long$sum sum not map;
];
];
```
