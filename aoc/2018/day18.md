# Breakdown
Example input:
```q
x:"\n"vs".#.#...|#.\n.....#|##|\n.|..|...#.\n..|#.....#\n#.#|||#|#|\n...#.||...\n.|....|..."
x,:"\n"vs"||...#|.#|\n|.||||..|.\n...#.|..|."
```

## Common
The function `d18step` calculates the next state of the grid.
```q
q)map:x
q)map
".#.#...|#."
".....#|##|"
".|..|...#."
"..|#.....#"
"#.#|||#|#|"
"...#.||..."
".|....|..."
"||...#|.#|"
"|.||||..|."
"...#.|..|."
```
We calculate the number of trees adjacent to each tile. To do this, we append a row of empty tiles
on the right and bottom, calculate the moving sum with a window of 3 in both directions, and drop
the first row and column from the result. We also subtract the boolean flag of whether each tile is
a tree since we shoudn't count a tile as a neighbor of itself.
```q
q)treeAdj:(1_3 msum (1_/:3 msum/:(map,\:".")="|"),enlist count[first map]#0)-map="|"
q)treeAdj
0 0 0 0 0 1 2 1 2 1
1 1 1 1 1 2 1 2 2 0
1 1 2 2 0 2 1 1 1 1
1 2 2 4 4 3 2 1 2 1
0 1 2 2 3 3 4 1 2 0
1 1 2 2 4 4 4 3 2 1
3 2 2 0 1 4 3 3 1 1
3 4 4 3 3 4 2 3 2 1
2 4 2 2 3 3 3 3 2 3
1 2 2 3 4 2 2 2 1 2
```
We do the same for lumberyards:
```q
q)yardAdj:(1_3 msum (1_/:3 msum/:(map,\:".")="#"),enlist count[first map]#0)-map="#"
q)yardAdj
1 0 2 0 2 1 2 3 2 2
1 1 2 1 2 0 2 3 3 3
0 0 1 1 2 1 2 3 3 3
1 2 2 1 1 1 1 3 3 2
0 2 2 3 2 1 0 2 1 2
1 2 2 1 1 1 1 2 1 1
0 0 1 1 2 1 1 1 1 1
0 0 0 0 1 0 1 1 0 1
0 0 1 1 2 1 1 1 1 1
0 0 1 0 1 0 0 0 0 0
```
We calculate the next state of the grid using a multi-branched vector conditional. Normally the `?`
operator only handles lists, but it can be extended to matrices by using it with the `'` (each)
iterator.

The first check is for whether the tile is empty:
```q
    ?'[(map="."); ... ; ... ]
```
In the first branch, the tile becomes a tree if the number of adjacent trees is at least 3,
otherwise it stays the same:
```q
    ?'[treeAdj>=3;"|";map]
```
In the second branch, we check for which tiles are already trees:
```q
    ?'[(map="|"); ... ; ... ]
```
In the first branch, we put in lumberyards where there are 3 or more adjacent ones:
```q
    ?'[yardAdj>=3;"#";map]
```
In the second branch (which is the lumberyard case), we check if there is at least one tree and yard
nearby, and put a yard or empty space on the tile:
```q
    _'[(treeAdj>=1) and (yardAdj>=1);"#";"."]
```
Putting it together:
```q
    map:?'[(map=".");
        ?'[treeAdj>=3;"|";map];
        ?'[(map="|");?'[yardAdj>=3;"#";map];
            ?'[(treeAdj>=1) and (yardAdj>=1);"#";"."]]];

q)map
".......##."
"......|###"
".|..|...#."
"..|#||...#"
"..##||.|#|"
"...#||||.."
"||...|||.."
"|||||.||.|"
"||||||||||"
"....||..|."
```

## Part 1
We call the step function 10 times:
```q
q)map:d18step/[10;x]
q)map
".||##....."
"||###....."
"||##......"
"|##.....##"
"|##.....##"
"|##....##|"
"||##.####|"
"||#####|||"
"||||#|||||"
"||||||||||"
```
We compare the map to the characters `"|"` and `"#"` in turn:
```q
q)map=/:"|#"
0110000000b 1100000000b 1100000000b 1000000000b 1000000000b 1000000001b 1100000001b 1100000111b 11..
0001100000b 0011100000b 0011000000b 0110000011b 0110000011b 0110000110b 0011011110b 0011111000b 00..
```
We sum both lists, requiring an `each` since we have two lists. The answer is the product of the
sums.
```q
q)prd sum each sum each map=/:"|#"
1147i
```

## Part 2
This requires finding a hidden pattern in the input. Namely, the state eventually starts repeating,
so all we need to do is find the loop length and skip enough loops to find the final state.

This code works on the example, but the result for that case is 0 because the grid becomes empty and
so that becomes the repeating state. So this demo uses a real input:
```q
q)md5"\n"sv x
0x89e38500577fed08245a6af81865c481
```
We find the loop using an iterated function. While there is an overload of `/` and `\` that stops
iterating once the input no longer changes or the initial input reappears, in this case there is no
guarantee that the loop is exactly only the final state or the entire sequence of states from the
beginning. So we have to implement keeping a history of states and checking if the current state
already appeared before. The accumulator will be a 3-tuple containing a continuation flag, the list
of historical states and the current state. The history will be storead in flattened format as that
is easier to search. The function merely calls the step function and adjusts the accumulator
accordingly:
```q
    res:{
        map:d18step last x;
        $[raze[map]in x 1;
            (0b;x[1];map);
            (1b;x[1],enlist raze map;map)]}/[first;(1b;enlist raze x;x)];

q)res
q)res
0b
("..|.#.....|.....##...#|..||...#.|#.#.||...#.....#|#...|.....|.|.#....#.|.|...|.#.||..#....#||.#|..
("......||||#.........||||#....................#||||";"......|||##.........|||##.........|..........
```
We find the first repeated index by matching the final state with the history:
```q
q)repeat:first where res[1]~\:raze res[2]
q)repeat
443
```
We find the loop length by subtracting the total state count from the first repeating state index:
```q
q)period:count[res 1]-repeat
q)period
28
```
We find the index of the final state:
```q
q)finalState
468
```
We fetch the final map at that index:
```q
q)finalMap:res[1][finalState]
q)finalMap
"........|||##.........|||##................##|||.........||||##........||||##................##||..
```
We find the score as in part 1, except there is no need to sum twice since the map is flattened:
```q
q)prd sum each finalMap=/:"|#"
202301i
```
