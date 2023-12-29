# Breakdown

Example input:
```q
x:"\n"vs"RL\n\nAAA = (BBB, CCC)\nBBB = (DDD, EEE)\nCCC = (ZZZ, GGG)";
x,:"\n"vs"DDD = (DDD, DDD)\nEEE = (EEE, EEE)\nGGG = (GGG, GGG)\nZZZ = (ZZZ, ZZZ)";
```

## Part 1
We convert the instructions to integers (0 for left and 1 for right). We split the two sides of the map.
```q
q)ins:"LR"?x 0; map0:" = "vs/:2_x;
q)ins
1 0
q)map0
"AAA" "(BBB, CCC)"
"BBB" "(DDD, EEE)"
"CCC" "(ZZZ, GGG)"
"DDD" "(DDD, DDD)"
"EEE" "(EEE, EEE)"
"GGG" "(GGG, GGG)"
"ZZZ" "(ZZZ, ZZZ)"
```
We create an adjacency map by dropping the superfluous characters:
```q
q)map:(`$map0[;0])!`$", "vs/:1_/:-1_/:map0[;1];
q)map
AAA| BBB CCC
BBB| DDD EEE
CCC| ZZZ GGG
DDD| DDD DDD
EEE| EEE EEE
GGG| GGG GGG
ZZZ| ZZZ ZZZ
```
We create a stepping function that follows all the instructions. The function body simply indexes into the current map node with the current instruction. We use the `/` (over) iterator to step through the instructions, but we elide the first argument so we can plug in all the nodes.
```q
step:{[m;x;y]m[x;y]}[map]/[;ins];
```
With this in hand, we create a collapsed map that maps each node directly to the one that we reach by following all the instructions:
```q
q)map2:key[map]!step each key map;
q)map2
AAA| ZZZ
BBB| EEE
CCC| GGG
DDD| DDD
EEE| EEE
GGG| GGG
ZZZ| ZZZ
```
Starting from the `AAA` node, we iterate the map until we reach the `ZZZ` node using a version of scan that takes a continuation condition:
```q
q)map2\[`ZZZ<>;`AAA]
`AAA`ZZZ
```
Due to using scan, we can count the result to get the number of steps, but we need to subtract one as it includes the starting node, and then multiply by the number of instructions since each step in the second iteration corresponds to a full run of the instructions:
```q
q)count[ins]*-1+count map2\[cond:`ZZZ<>;`AAA]
2
```
Unfortunately neither of the example inputs is interesting as they both reach the `ZZZ` node after the first run of the instructions. In fact the collapsing of the map is an orphaned optimization added for an early attempt at part 2.

## Part 2
The solution doesn't work on the example inputs as it abuses the structure of the real input. The parsing and collapsing of the map are similar to part 1:
```q
ins:"LR"?x 0; map0:" = "vs/:2_x;
map:(`$map0[;0])!`$", "vs/:1_/:-1_/:map0[;1];
step:{[m;x;y]m[x;y]}[map]/[;ins];
map2:key[map]!step each key map;
```
We find the starting positions by looking up all the nodes with names ending in `"A"`:
```q
pos:{x where x like "*A"}key[map];
```
We iterate the collapsed map "enough times". The number of nodes is a good upper bound since the path will run into a loop at that point but probably (and in the case of the real inputs, definitely) well before that.
```q
paths:map2\[count map2;]each pos;
```
We find at which steps the path passes a target node:
```q
where each paths like\:"*Z"
```
This is where we rely on the structure of the input: each start node is at the start of the loop, so the loop length can be calculated by subtracting the first matching position from the second one. The loop lengths are also primes so we can simply multiply them together to find when all of the paths end up on a target node at the same time:
```q
prd{x[;1]-x[;0]}where each paths like\:"*Z"
```
Just like with part 1, we need to multiply back by the number of instructions:
```q
count[ins]*prd{x[;1]-x[;0]}where each paths like\:"*Z"
```

There are various ways to make "evil" inputs that break this solution:
* If the cycle lengths are not primes, we need to use LCM (least common multiple) to find the overall period.
* If the cycles start at different times, we need to use the Chinese remainder theorem to find when the paths overlap.
* Extra evil can be added by making the path cross more than one target node per cycle (so we would have to check all possible combinations for when they overlap and which overlap happens first), or having a long lead-in before the loop that includes passing through target nodes (so we also have to check scenarios where some of the paths are in loops while others aren't yet, as one of those might be the first overlap).