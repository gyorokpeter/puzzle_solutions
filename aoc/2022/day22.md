# Breakdown
Example input:
```q
x:"\n"vs"        ...#\n        .#..\n        #...\n        ....\n...#.......#\n........#...\n..#....#....\n..........#.\n        ...#....\n        .....#..\n        .#......\n        ......#.\n\n10R5L5R10L4R5L5";
```

## Part 1
We split the input into sections:
```q
a:"\n\n"vs"\n"sv x
```
For the map, we split it on newlines:
```q
map:"\n"vs a 0;
```
We split the path into segments based on when it changes between letters and numbers:
```q
path:{(0,where 0<>deltas x in "LR")cut x}a 1;
```
We initialize the position based on where the first empty position is, with the 3rd coordinate indicating direction:
```q
pos:0,(first where "."=map[0]),0;
```
We update the position by iterating a function.

We check what the next instruction is. For L and R instructions, we simply adjust the direction:
```q
$[ins~enlist"L"; pos[2]:(pos[2]-1)mod 4;
  ins~enlist"R"; pos[2]:(pos[2]+1)mod 4;
  [
```
Otherwise the instruction is a number. We convert it to an integer and also cache the direction:
```q
amt:"J"$ins;
dir:pos 2;
```
We extract the tiles from the map that correspond to the current coordinates. This may be a row or a column, and may be reversed.
```q
row:$[dir=0; map[pos 0];
    dir=1; map[;pos 1];
    dir=2; reverse map[pos 0];
    dir=3; reverse map[;pos 1]];
```
We calculate the actual position on the row that was extracted:
```q
actpos:$[dir=0; pos 1;
    dir=1; pos 0;
    dir=2; count[map pos 0]-1+pos 1;
    dir=3; count[map]-1+pos 0];
```
We calculate the offset, which is the first position on the map that is not a void:
```q
ofs:first where " "<>row;
```
We cut off the void fromt he extracted row:
```q
row:trim row;
```
We remove the offset from the current position for easier calculation:
```q
actpos-:ofs;
```
We find the updated position based on how much we can move. For this purpose we rotate the row to start at the current position and repeat it as many times as necessary. If we run into a wall, we stop there, otherwise we perform the full amount.
```q
actpos+:(amt and 0W^-1+first where "#"=(amt+1)#actpos rotate row);
```
We use modulo to ensure that the position is still on the map:
```q
actpos:actpos mod count row;
```
We add back the offset to the position:
```q
actpos+:ofs;
```
We transform back the position into the original coordinates and return the modified position:
```q
$[dir=0; pos[1]:actpos;
    dir=1; pos[0]:actpos;
    dir=2; pos[1]:count[map pos 0]-1+actpos;
    dir=3; pos[0]:count[map]-1+actpos];
]
];
pos
```
After the iteration we adjust the coordinates by offsetting and multiplying as necessary and sum the results:
```q
sum 1000 4 1*1 1 0+pos}
```

## Part 2
I couldn't figure out the generic version of the cube folding so I adopted some code from [https://github.com/taylorott/Advent_of_Code/blob/main/src/Year_2022/Day22/Solution.py].

Initialization is similar to part 1:
```q
a:"\n\n"vs"\n"sv x;
map:"\n"vs a 0;
path:{(0,where 0<>deltas x in "LR")cut x}a 1;
pos:0,(first where "."=map[0]),0;
```
We expand all lines of the map to be the same length:
```q
map:max[count each map]$map;
```
We use the stolen code to generate a mapping on the edges of the cube:
```q
wrap:.d22.genAdjacency[map];
```
The position is once again updated using an iterated function. The handling of L/R instructions is the same as before:
```q
$[ins~enlist"L"; pos[2]:(pos[2]-1)mod 4;
  ins~enlist"R"; pos[2]:(pos[2]+1)mod 4;
  [
```
Otherwise we repeat a single movement the given number of times:
```q
amt:"J"$ins;
do[amt;
```
We back up the current position:
```q
prevpos:pos;
```
If the current position is in the wrapping map, we look up where to go, otherwise we do one step in the current direction:
```q
pos:$[pos in key wrap;wrap pos;(.d22.direction[pos 2],0)+pos];
```
If we ran into a wall, we restore the saved position. If q had a `break` instruction, we would use it here, but alas, it doesn't, so we just waste trying to move dozens of times.
```q
if["#"=map . 2#pos; pos:prevpos];
```
We return the modified position.
```q
];
]
];
pos
```
The final adjustment of the output is as in part 1.
```q
sum 1000 4 1*1 1 0+pos
```
