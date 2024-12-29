# Breakdown

Example input:
```q
x:();
x,:enlist"##########";
x,:enlist"#..O..O.O#";
x,:enlist"#......O.#";
x,:enlist"#.OO..O.O#";
x,:enlist"#..O@..O.#";
x,:enlist"#O#..O...#";
x,:enlist"#O..O..O.#";
x,:enlist"#.OO.O.OO#";
x,:enlist"#....O...#";
x,:enlist"##########";
x,:enlist"";
x,:enlist"<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^";
x,:enlist"vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v";
x,:enlist"><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<";
x,:enlist"<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^";
x,:enlist"^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><";
x,:enlist"^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^";
x,:enlist">^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^";
x,:enlist"<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>";
x,:enlist"^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>";
x,:enlist"v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^";
```

## Part 1
We regroup based on the double newline and extract the map and instructions:
```q
q)a:"\n\n"vs"\n"sv x
q)map:"\n"vs a 0;
q)map
"##########"
"#..O..O.O#"
"#......O.#"
"#.OO..O.O#"
"#..O@..O.#"
"#O#..O...#"
"#O..O..O.#"
"#.OO.O.OO#"
"#....O...#"
"##########"
q)instr:a[1]except"\n";
q)instr
"<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^vvv<<^>^v^^><<>>><>^<<><^vv..
```
We find the position of the bot using the [2D search](../utils/patterns.md#2d-search) technique and
replace its position on the map with an open space:
```q
q)pos:first raze til[count map],/:'where each map="@";
q)pos
4 4
q)map1:.[map;pos;:;"."]
q)map1
"##########"
"#..O..O.O#"
"#......O.#"
"#.OO..O.O#"
"#..O...O.#"
"#O#..O...#"
"#O..O..O.#"
"#.OO.O.OO#"
"#....O...#"
"##########"
```
We iterate a function that takes a pair of `(map;pos)` and an instruction, and returns the updated
`(map;pos)`:
```q
    mp:{[mp;ni]
        map1:mp 0;pos:mp 1;
        ..
        (map1;pos)}/[(map1;pos);instr];
```
Inside the function, we select the coordinate delta based on the direction from the instruction:
```q
    delta:("^>v<"!(-1 0;0 1;1 0;0 -1))ni;
```
We then add this delta multiplied by all numbers from 1 to the height of the map to the position:
```q
    line:pos+/:(1+til count map1)*\:delta;
```
This is an overkill because it is guaranteed to go off the map, and the of-map coordinates are
caught by the border of walls on the map, but it's easier to implement than to fiddle with a
distance-to-edge-of-map check.

We find the type of tile along the line:
```q
    cont:map1 ./:line;
```
We find the first wall and first empty tile along the line. If there are none, this will return the
length of the list.
```q
    empty:cont?".";
    wall:cont?"#";
```
We determine whether to move by checking whether the first empty space is before the first wall:
```q
    if[empty<wall;
        ...
    ];
```
Furthermore if we can move, we check if the first empty tile is more than one tile away. If it is,
we have to move some boxes, however this can be simplified by replacing the first box with an empty
space and putting a box at the original first empty space. The boxes in between don't need to be
touched as they are boxes both before and after the move.
```q
    if[empty>0;
        map1:.[map1;line 0;:;"."];
        map1:.[map1;line empty;:;"O"];
    ];
```
Whether we move boxes or not, we update the position to the first position in the line (which is one
tile forward):
```q
    pos:line 0;
```
After iterating this function over the instructions, we get a pair of the final map and final
position. We only care about the map part:
```q
q)map2:mp 0
q)map2
"##########"
"#.O.O.OOO#"
"#........#"
"#OO......#"
"#OO......#"
"#O#.....O#"
"#O.....OO#"
"#O.....OO#"
"#OO....OO#"
"##########"
```
We find the coordinates of all the boxes (using the day 4 technique again) and multiply the
coordinates as required before summing them. This time using `sum` twice (without any `each`) works
as the rows are of the same length, so a vertical collapse doesn't throw a length error.
```q
q)raze til[count map],/:'where each map2="O"
1 2
1 4
1 6
1 7
1 8
..
q)100 1*/:raze til[count map],/:'where each map2="O"
100 2
100 4
100 6
100 7
100 8
..
q)sum sum 100 1*/:raze til[count map],/:'where each map2="O"
10092
```

## Part 2
The difference in the input parsing is that we expand the map from the input to the wide version:
```q
q)a:"\n\n"vs"\n"sv x;
q)map:raze each("#O.@"!("##";"[]";"..";"@."))"\n"vs a 0
q)map
"####################"
"##....[]....[]..[]##"
"##............[]..##"
"##..[][]....[]..[]##"
"##....[]@.....[]..##"
"##[]##....[]......##"
"##[]....[]....[]..##"
"##..[][]..[]..[][]##"
"##........[]......##"
"####################"
q)instr:a[1]except"\n";
q)pos:first raze til[count map],/:'where each map="@";
q)map1:.[map;pos;:;"."];
```
Once again we iterate a function with the map/position and incoming instructions. However there are
two major differences.

We split the logic based on whether the movement is horizontal or vertical:
```q
    $[ni in "><";[
        ...
    ];[
        ...
    ]];
```
The horizontal case is very similar to part 1:
```q
    delta:("><"!(0 1;0 -1))ni;
    line:pos+/:(1+til count first map1)*\:delta;
    cont:map1 ./:line;
    empty:cont?".";
    wall:cont?"#";
    if[empty<wall;
        if[empty>0;
            map1:.[;;:;]/[map1;line til 1+empty;".",map1 ./:line til empty];
        ];
        pos:line 0;
    ];
```
The main difference is in the `empty>0` branch: we can no longer use the trick from part 1 as the
boxes now have 2 different tiles, and pushing a line of boxes causes all the tiles in between to
change between the left and right box tiles. So instead we pick a section of the map up to the first
empty space, add an empty space before it, and overwrite the section using iterated functional
amend.

For the vertical case, we choose a delta based on the instruction as before:
```q
    delta:("^v"!(-1 0;1 0))ni;
```
However as multiple boxes can be moved at once, we discover all the tiles that contain movable boxes
using BFS. We start with a queue containing the bot's position, as well as an empty visited list.
```q
    queue:enlist pos;
    visited:();
```
We iterate until the queue is empty:
```q
    while[count queue;
        ...
    ];
```
In each step, we add the delta to the positions in the queue:
```q
    nxts:queue+\:delta;
```
We find the tiles at the new positions:
```q
    cont:map1 ./:nxts;
```
If we find a wall, that means the entire move is blocked by that wall. Luckily we can simply return
out of the function to leave the iteration and everything behind.
```q
    if["#" in cont;:(map1;pos)];
```
Otherwise we remove any empty spaces from the next positions, as these don't represent movable
boxes:
```q
    filter:where not cont=".";
    nxts@:filter; cont@:filter;
```
For every `[` tile under a next position, we also add its counterpart to the right, and similarly
for `]`:
```q
    nxts,:(nxts where cont="[")+\:0 1;
    nxts,:(nxts where cont="]")+\:0 -1;
```
We take the distinct list of coordinates (it may happen that two boxes each share a horizontal edge
with a box beyond them).
```q
    nxts:distinct nxts;
```
We add the positions to the visited list (which is only used at the end to find the boxes, as the
movement goes in one direction only):
```q
    visited,:nxts;
```
We replace the queue with the remaining next positions:
```q
    queue:nxts;
```
If we didn't exit from the iteration early, that means it is possible to move, whether there are
boxes or not, so we update the position:
```q
    pos+:delta;
```
To move the boxes, first we find the tiles for all the box positions, then replace those positions
with empty spaces, then place the boxes back with their coordinates modified by the delta.
```q
    if[count visited;
        vcont:map1 ./:visited;
        map1:.[;;:;"."]/[map1;visited];
        map1:.[;;:;]/[map1;visited+\:delta;vcont];
    ];
```
After iterating the new function over the instructions, we get a pair of the final map and final
position. We only care about the map part:
```q
q)map2:mp 0
q)map2
"####################"
"##[].......[].[][]##"
"##[]...........[].##"
"##[]........[][][]##"
"##[]......[]....[]##"
"##..##......[]....##"
"##..[]............##"
"##.........[].[][]##"
"##......[][]..[]..##"
"####################"
```
We find the coordinates of all the left sides of the boxes and multiply the coordinates as required
before summing them:
```q
q)raze til[count map],/:'where each map2="["
1 2
1 11
1 14
1 16
2 2
..
q)sum sum 100 1*/:raze til[count map],/:'where each map2="["
9021
```
