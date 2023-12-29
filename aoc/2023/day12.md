This day seems to be inspired by a [nonogram](https://en.wikipedia.org/wiki/Nonogram) puzzle.

# Breakdown

Example input:
```q
x:();
x,:enlist"???.### 1,1,3";
x,:enlist".??..??...?##. 1,1,3";
x,:enlist"?#?#?#?#?#?#?#? 1,3,1,6";
x,:enlist"????.#...#... 4,1,1";
x,:enlist"????.######..#####. 1,6,5";
x,:enlist"?###???????? 3,2,1";
```

## Common

The common logic (`d12`) expects two arguments, a row of the map (`mr`) and the row of corresponding numbers (`nr`).

We use a BFS to find the number of combinations. Each step will place one block in all possible places. The state of the BFS will be the map position and the number of ways we can reach the map position. Most of the logic will be around filtering out impossible combinations.

The first step is to calculate the clearance needed for each block, considering that they need to have one space between them:
```q
lefts:reverse sums[reverse nr]+til count nr
```
E.g. for `1 1 3` we get `7 5 3`.

We initialize the queue to a single element with the starting position being 0 and the count being 1:
```q
queue:([]mp:enlist 0;cnt:1);
```
We also keep track of the numbers of blocks placed which starts at zero:
```q
np:0
```
We iterate until we reach the number of blocks to place:
```q
while[np<count nr; ... ]
```
We generate all the possible starting positions for the next block considering the current position and the clearance required for the next block:
```q
queue:ungroup update nmp:mp+til each 1+count[mr]-mp+lefts np from queue
```
We extract the slice of the map starting from the chosen start position:
```q
queue:update slice:mr nmp+\:til nr np from queue
```
We also extract the padding - these are the tiles that must be left empty, and include all the tiles between the current position and the chosen start position, as well as one tile after the end of the block:
```q
queue:update pad:"."^mr((mp+til each nmp-mp),'nmp+nr np) from queue;
```
We filter out the invalid solutions by checking if all of the the block tiles are one of `"#?"` and the padding tiles are one of `".?"`:
```q
queue:select from queue where all each slice in"#?",all each pad in"?."
```
We update the current position to 1 more than the end position of the block (to account for the mandatory empty tile):
```q
queue:select mp:nmp+1+nr np,cnt from queue
```
We collapse the queue by summing the counts by the current position:
```q
queue:0!select sum cnt by mp from queue
```
Finally we increment the block pointer:
```q
np+:1
```
This is the end of the iteration, however we are not done, as any remaining tiles after the last block must also be `".?"`. Therefore we check the remaining padding from the current position to the end of the row at the final state of the queue:
```q
queue:update pad:mp _\:mr from queue;
queue:select from queue where all each pad in"?."
```
Now what is left are the counts of the valid arrangements, which we can sum together:
```q
exec sum cnt from queue
```

## Part 1
We split the input on `" "` and put the left sides into the list of rows and parse the right sides as numbers after splitting on `","`:
```q
p:" "vs/:x; m:p[;0]; n:"J"$","vs/:p[;1]
```
We then call the common logic pairwise on the two lists and sum the results:
```q
sum .d12.paths'[m;n]
```

## Part 2
The first part of the input parsing is the same, but we do a bit of additional preprocessing. We repeat the map rows 5 times each and then join them together with `"?"` as a separator:
```q
m:"?"sv/:5#/:enlist each m
```
We do the same with the numbers but there is no separator so we raze them:
```q
n:raze each 5#/:enlist each n
```
The invocation of the common logic is the same as in part 1.
