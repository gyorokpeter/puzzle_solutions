# Breakdown
Example input:
```q
x:();
x,:"\n"vs"Tile 2311:\n..##.#..#.\n##..#.....\n#...##..#.\n####.#...#\n##.##.###.\n##...#.###"
x,:"\n"vs".#.#.#..##\n..#....#..\n###...#.#.\n..###..###\n"
x,:"\n"vs"Tile 1951:\n#.##...##.\n#.####...#\n.....#..##\n#...######\n.##.#....#\n.###.#####"
x,:"\n"vs"###.##.##.\n.###....#.\n..#.#..#.#\n#...##.#..\n"
x,:"\n"vs"Tile 1171:\n####...##.\n#..##.#..#\n##.#..#.#.\n.###.####.\n..###.####\n.##....##."
x,:"\n"vs".#...####.\n#.##.####.\n####..#...\n.....##...\n"
x,:"\n"vs"Tile 1427:\n###.##.#..\n.#..#.##..\n.#.##.#..#\n#.#.#.##.#\n....#...##\n...##..##."
x,:"\n"vs"...#.#####\n.#.####.#.\n..#..###.#\n..##.#..#.\n"
x,:"\n"vs"Tile 1489:\n##.#.#....\n..##...#..\n.##..##...\n..#...#...\n#####...#.\n#..#.#.#.#"
x,:"\n"vs"...#.#.#..\n##.#...##.\n..##.##.##\n###.##.#..\n"
x,:"\n"vs"Tile 2473:\n#....####.\n#..#.##...\n#.##..#...\n######.#.#\n.#...#.#.#\n.#########"
x,:"\n"vs".###.#..#.\n########.#\n##...##.#.\n..###.#.#.\n"
x,:"\n"vs"Tile 2971:\n..#.#....#\n#...###...\n#.#.###...\n##.##..#..\n.#####..##\n.#..####.#"
x,:"\n"vs"#..#.#..#.\n..####.###\n..#.#.###.\n...#.#.#.#\n"
x,:"\n"vs"Tile 2729:\n...#.#.#.#\n####.#....\n..#.#.....\n....#..#.#\n.##..##.#.\n.#.####..."
x,:"\n"vs"####.#.#..\n##.####...\n##..#.##..\n#.##...##.\n"
x,:"\n"vs"Tile 3079:\n#.#.#####.\n.#..######\n..#.......\n######....\n####.#..#.\n.#...#.##."
x,:"\n"vs"#.#####.##\n..#.###...\n..#.......\n..#.###..."
```

## Common
We split the input into sections based on double newlines, then split each tile on newlines:
```q
q)ts:("\n"vs/:"\n\n"vs"\n"sv x)except\:enlist""
q)ts
"Tile 2311:" "..##.#..#." "##..#....." "#...##..#." "####.#...#" "##.##.###." "##...#.###" ".#.#.#..
"Tile 1951:" "#.##...##." "#.####...#" ".....#..##" "#...######" ".##.#....#" ".###.#####" "###.##..
"Tile 1171:" "####...##." "#..##.#..#" "##.#..#.#." ".###.####." "..###.####" ".##....##." ".#...#..
"Tile 1427:" "###.##.#.." ".#..#.##.." ".#.##.#..#" "#.#.#.##.#" "....#...##" "...##..##." "...#.#..
"Tile 1489:" "##.#.#...." "..##...#.." ".##..##..." "..#...#..." "#####...#." "#..#.#.#.#" "...#.#..
"Tile 2473:" "#....####." "#..#.##..." "#.##..#..." "######.#.#" ".#...#.#.#" ".#########" ".###.#..
"Tile 2971:" "..#.#....#" "#...###..." "#.#.###..." "##.##..#.." ".#####..##" ".#..####.#" "#..#.#..
"Tile 2729:" "...#.#.#.#" "####.#...." "..#.#....." "....#..#.#" ".##..##.#." ".#.####..." "####.#..
"Tile 3079:" "#.#.#####." ".#..######" "..#......." "######...." "####.#..#." ".#...#.##." "#.####..
```
We find the tile IDs by cutting the first elements on `" "` and dropping the last character:
```q
q)tid:"J"$-1_/:last each" "vs/:first each ts
q)tid
2311 1951 1171 1427 1489 2473 2971 2729 3079
```
We drop the tile numbers from the tile contents:
```q
q)tc:1_/:ts
q)tc
"..##.#..#." "##..#....." "#...##..#." "####.#...#" "##.##.###." "##...#.###" ".#.#.#..##" "..#.....
"#.##...##." "#.####...#" ".....#..##" "#...######" ".##.#....#" ".###.#####" "###.##.##." ".###....
"####...##." "#..##.#..#" "##.#..#.#." ".###.####." "..###.####" ".##....##." ".#...####." "#.##.#..
"###.##.#.." ".#..#.##.." ".#.##.#..#" "#.#.#.##.#" "....#...##" "...##..##." "...#.#####" ".#.###..
"##.#.#...." "..##...#.." ".##..##..." "..#...#..." "#####...#." "#..#.#.#.#" "...#.#.#.." "##.#....
"#....####." "#..#.##..." "#.##..#..." "######.#.#" ".#...#.#.#" ".#########" ".###.#..#." "######..
"..#.#....#" "#...###..." "#.#.###..." "##.##..#.." ".#####..##" ".#..####.#" "#..#.#..#." "..####..
"...#.#.#.#" "####.#...." "..#.#....." "....#..#.#" ".##..##.#." ".#.####..." "####.#.#.." "##.###..
"#.#.#####." ".#..######" "..#......." "######...." "####.#..#." ".#...#.##." "#.#####.##" "..#.##..
```
We generate all 8 possible orientations for each tile by applying various operations. The initial
state is the default, marked as `...` (the dots will be filled with operations if necessary):
```q
q)tco:enlist[`...]!enlist tc
```
We generate the flipped versions:
```q
q)tco[`f..]:flip each tc
```
We generate the reversed (=vertically mirrored) versions:
```q
q)tco[`.r.]:reverse each tc
```
We generate the flipped-reversed versions based on the flipped ones:
```q
q)tco[`fr.]:reverse each tco[`f..]
```
We generate the (horizontally) mirrored versions for each of the above:
```q
q)tco[`..m]:reverse each/:tco[`...]
q)tco[`.rm]:reverse each/:tco[`.r.]
q)tco[`f.m]:reverse each/:tco[`f..]
q)tco[`frm]:reverse each/:tco[`fr.]
```
We cache the tile size:
```q
q)tw:count tc[0;0]
q)tw
10
```
We get the number of tiles per side of the big square, which is the square root of the tile count:
```q
q)mw:`long$sqrt count tid
q)mw
3
```
We figure out which tiles can be placed below and to the right of which other tiles, considering all
orientations. For example, for the "right" alignment, we get the right and left side of each tile
in all orientations, which requires indexing at depth 4:
```q
q)tco[;;;tw-1]
...| "...#.##..#" ".#####..#." ".#..#....." "..###.#.#." ".....#..#." "...###.#.." "#...##.#.#" "#..
f..| "..###..###" "#...##.#.." ".....##..." "..##.#..#." "###.##.#.." "..###.#.#." "...#.#.#.#" "#..
fr.| "###..###.." "..#.##...#" "...##....." ".#..#.##.." "..#.##.###" ".#.#.###.." "#.#.#.#..." "...
.r.| "#..##.#..." ".#..#####." ".....#..#." ".#.#.###.." ".#..#....." "..#.###..." "#.#.##...#" "...
..m| ".#####..#." "##.#..#..#" "###....##." "#..#......" "#...##.#.#" "####...##." ".###..#..." "...
.rm| ".#..#####." "#..#..#.##" ".##....###" "......#..#" "#.#.##...#" ".##...####" "...#..###." "#..
f.m| "..##.#..#." "#.##...##." "####...##." "###.##.#.." "##.#.#...." "#....####." "..#.#....#" "...
frm| ".#..#.##.." ".##...##.#" ".##...####" "..#.##.###" "....#.#.##" ".####....#" "#....#.#.." "#..
q)tco[;;;0]
...| ".#####..#." "##.#..#..#" "###....##." "#..#......" "#...##.#.#" "####...##." ".###..#..." "...
f..| "..##.#..#." "#.##...##." "####...##." "###.##.#.." "##.#.#...." "#....####." "..#.#....#" "...
fr.| ".#..#.##.." ".##...##.#" ".##...####" "..#.##.###" "....#.#.##" ".####....#" "#....#.#.." "#..
.r.| ".#..#####." "#..#..#.##" ".##....###" "......#..#" "#.#.##...#" ".##...####" "...#..###." "#..
..m| "...#.##..#" ".#####..#." ".#..#....." "..###.#.#." ".....#..#." "...###.#.." "#...##.#.#" "#..
.rm| "#..##.#..." ".#..#####." ".....#..#." ".#.#.###.." ".#..#....." "..#.###..." "#.#.##...#" "...
f.m| "..###..###" "#...##.#.." ".....##..." "..##.#..#." "###.##.#.." "..###.#.#." "...#.#.#.#" "#..
frm| "###..###.." "..#.##...#" "...##....." ".#..#.##.." "..#.##.###" ".#.#.###.." "#.#.#.#..." "...
```
To find which combinations align, we match them pairwise with the combined iterator `/:\:`
(each-right and each-left). We have to do this at two different levels (since we have to match up
both tiles and orientations):
```q
q){x{x~/:\:y}/:\:y}[tco[;;;tw-1];tco[;;;0]]
   | ...                                                                                          ..
---| ---------------------------------------------------------------------------------------------..
...| 000000000b 100000000b 000000000b 000000000b 000000000b 000000000b 000010000b 000100000b 00000..
f..| 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 00000..
fr.| 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 00000..
.r.| 000000001b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 00000..
..m| 100000000b 010000000b 001000000b 000100000b 000010000b 000001000b 000000100b 000000010b 00000..
.rm| 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 00000..
f.m| 000000000b 000000000b 000001000b 000000000b 000000000b 000000000b 000000000b 000000000b 00000..
frm| 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 000000000b 00000..
```
We convert this matrix to coordinates using `where` and prepending an increasing index:
```q
q){x{til[count y],/:'where each x~/:\:y}/:\:y}[tco[;;;tw-1];tco[;;;0]]
   | ...                                      f..                                      fr.        ..
---| ---------------------------------------------------------------------------------------------..
...| ()   ,1 0 ()   ()  ()  ()  ,6 4 ,7 3 ()                                                      ..
f..|                                          ()  ()  ()  ,3 0 ,4 3 ()   ,6 7 ,7 1 ()             ..
fr.|                                                                                   ()  ()  () ..
.r.| ,0 8 ()   ()   ()  ()  ()  ()   ()   ()                                                      ..
..m| 0 0  1 1  2 2  3 3 4 4 5 5 6 6  7 7  8 8 ()  ()  ()  ()   ()   ,5 2 ()   ()   ()             ..
.rm|                                                                                   ()  ()  () ..
f.m| ()   ()   ,2 5 ()  ()  ()  ()   ()   ()  0 0 1 1 2 2 3 3  4 4  5 5  6 6  7 7  8 8            ..
frm|                                                                                   0 0 1 1 2 2..
```
This includes instances where a tile can be placed after itself, so we need to filter those out:
```q
q)a:{x{c:count y;til[c],/:'where each (x~/:\:y) and til[c]<>/:\:til[c]}/:\:y}[tco[;;;tw-1];tco[;;;0]]
q)a
   | ...                                  f..                                  fr.                ..
---| ---------------------------------------------------------------------------------------------..
...| ()   ,1 0 ()   () () () ,6 4 ,7 3 ()                                                         ..
f..|                                      () () () ,3 0 ,4 3 ()   ,6 7 ,7 1 ()                    ..
fr.|                                                                           () () () ,3 0 ,4 3 ..
.r.| ,0 8 ()   ()   () () () ()   ()   ()                                                         ..
..m|                                      () () () ()   ()   ,5 2 ()   ()   ()                    ..
.rm|                                                                           () () () ()   ()   ..
f.m| ()   ()   ,2 5 () () () ()   ()   ()                                                         ..
frm|                                                                                              ..
```
We convert this matrix into a flat table for easier processing. First we prepend the column header
to the coordinates:
```q
q){key[x],/:''value x}each a
...| ()          ,(`...;1;0) ()          ()          ()          ()          ,(`...;6;4) ,(`...;7;..
f..|                                                                                              ..
fr.|                                                                                              ..
.r.| ,(`...;0;8) ()          ()          ()          ()          ()          ()          ()       ..
..m|                                                                                              ..
.rm|                                                                                              ..
f.m| ()          ()          ,(`...;2;5) ()          () () () ()          ()                      ..
frm|                                                                                              ..
```
We also prepend the row header in a similar way:
```q
q){key[x],/:'''value x}{key[x],/:''value x}each a
()               ,(`...;`...;1;0) ()               ()               ()               ()           ..
                                                                                                  ..
                                                                                                  ..
,(`.r.;`...;0;8) ()               ()               ()               ()               ()           ..
                                                                                                  ..
                                                                                                  ..
()               ()               ,(`f.m;`...;2;5) ()               () () () ()               ()  ..
                                                                                                  ..
```
We raze a total of 3 times to get a flat list:
```q
q)raze raze raze{key[x],/:'''value x}{key[x],/:''value x}each a
`... `... 1 0
`... `... 6 4
`... `... 7 3
`... `.r. 0 8
`... `.rm 2 4
`... `.rm 4 2
`... `f.m 3 5
`... `frm 5 8
`f.. `f.. 3 0
`f.. `f.. 4 3
`f.. `f.. 6 7
`f.. `f.. 7 1
..
```
We convert this into a table by putting the first and third elements into the `s` (source) column
and the second and fourth elements into the `t` (target) column:
```q
q){([]s:x[;0 2];t:x[;1 3])}raze raze raze{key[x],/:'''value x}{key[x],/:''value x}each a
s      t
-------------
`... 1 `... 0
`... 6 `... 4
`... 7 `... 3
`... 0 `.r. 8
`... 2 `.rm 4
`... 4 `.rm 2
`... 3 `f.m 5
`... 5 `frm 8
`f.. 3 `f.. 0
`f.. 4 `f.. 3
`f.. 6 `f.. 7
`f.. 7 `f.. 1
```
We group the targets by source, prepending a dummy element for invalid transitions:
```q
q)nr:(enlist[(`;0N)]!enlist()),exec t by s from{([]s:x[;0 2];t:x[;1 3])}raze raze raze{key[x],/:'''value x}{key[x],/:''value x}each a
q)nr
`    0N| ()
`... 0 | ,(`.r.;8)
`... 1 | ,(`...;0)
`... 2 | ,(`.rm;4)
`... 3 | ,(`f.m;5)
`... 4 | ,(`.rm;2)
`... 5 | ,(`frm;8)
`... 6 | ,(`...;4)
`... 7 | ,(`...;3)
`..m 0 | ,(`..m;1)
`..m 3 | ,(`..m;7)
`..m 4 | ,(`..m;6)
`..m 5 | ,(`f..;2)
```
The "down" direction works the same way, only the way we extract the edges differs:
```q
    align:{a:(x{c:count y;til[c],/:'where each (x~/:\:y) and til[c]<>/:\:til[c]}/:\:y);
        (enlist[(`;0N)]!enlist()),exec t by s from{([]s:x[;0 2];t:x[;1 3])}raze raze raze{key[x],/:'''value x}{key[x],/:''value x}each a};
q)nr:align[tco[;;;tw-1];tco[;;;0]]
q)nd:align[tco[;;tw-1];tco[;;0]]
q)nd
`    0N| ()
`... 3 | ,(`...;0)
`... 4 | ,(`...;3)
`... 5 | ,(`fr.;3)
`... 6 | ,(`...;7)
`... 7 | ,(`...;1)
`... 8 | ,(`frm;5)
`..m 3 | ,(`..m;0)
`..m 4 | ,(`..m;3)
`..m 5 | ,(`frm;3)
```
Now we try to actually populate the map, which is done using BFS. We start from the top left and in
each step we figure out the next tiles right and down from the current ones. Instead of going row by
row, we go in diagonals. Since the tiles in the middle have two constraints (both in the right and
the down direction), it helps to cut down the search space to handle these constraints within a
single step.

We initialize the queue by trying to put every tile in every orientation (that has a connection both
to the right and down) in the top left and initializing the remaining tiles with empty lists:
```q
q)queue:(enlist each key[nr] inter key[nd]),\:(count[tc]-1)#enlist[()]
q)queue
(`;0N)   () () () () () () () ()
(`...;3) () () () () () () () ()
(`...;4) () () () () () () () ()
(`...;5) () () () () () () () ()
(`...;6) () () () () () () () ()
(`...;7) () () () () () () () ()
(`..m;3) () () () () () () () ()
(`..m;4) () () () () () () () ()
(`..m;5) () () () () () () () ()
(`..m;8) () () () () () () () ()
(`.r.;0) () () () () () () () ()
(`.r.;1) () () () () () () () ()
(`.r.;2) () () () () () () () ()
(`.r.;3) () () () () () () () ()
(`.r.;7) () () () () () () () ()
(`.rm;0) () () () () () () () ()
(`.rm;3) () () () () () () () ()
(`f..;3) () () () () () () () ()
(`f..;4) () () () () () () () ()
(`f..;5) () () () () () () () ()
(`f..;6) () () () () () () () ()
(`f..;7) () () () () () () () ()
..
```
We iterate as long as there are items in the queue. There is an early exit in the loop, so running
out of items would only be possible due to a bug or invalid input.
```q
    while[0<count queue;
        ...
    ];
    '"not found"
```
Inside the loop, we first check which tiles still need filling in, which is indicated by them being
empty lists. It is enough to check only the first item in the queue.
```q
q)nl:where ()~/:first queue
q)nl
1 2 3 4 5 6 7 8
```
If there is no such position, we are done, and we return the current state including the map width,
tile IDs, queue (with the completed maps) and the tile connections. Note that there will be 8
different solutions, since each rotation and mirroring of the entire map leaves the solution valid.
```q
    if[0=count nl;
        :(mw;tid;queue;tco);
    ];
```
Otherwise we find the next tile to update. This is done by `div`ing and `mod`ing the indices by the
map width and finding where the sum of these values is minimal. The result is that the map is filled
in in diagonals going in a down-left direction.
```q
q)(nl div mw)+nl mod mw
1 2 1 2 3 2 3 4
q){x=min x}(nl div mw)+nl mod mw
10100000b
q)ni:nl first where{x=min x}(nl div mw)+nl mod mw
q)ni
1
```
We find the tiles that properly connect at the next tile index. The choice of tiles is different
depending on where the next tile is in the map. If it's on the top row (as in this example), only
the rightwards connections are checked:
```q
q)0<ni mod mw
1b
q)0<ni div mw
0b
q)queue[;ni-1]
`    0N
`... 3
`... 4
`... 5
`... 6
`... 7
`..m 3
..
q)nr queue[;ni-1]
()
,(`f.m;5)
,(`.rm;2)
,(`frm;8)
,(`...;4)
,(`...;3)
..
q)poss:nr queue[;ni-1]
q)poss
()
,(`f.m;5)
,(`.rm;2)
,(`frm;8)
,(`...;4)
,(`...;3)
..
```
Similarly, for a tile in the left column, only the downwards connections are checked:
```q
    0<ni div mw; nd queue[;ni-mw]
```
For any other tile, we need to take the intersection of the downwards and rightwards connections.
Since the elements of the queue are lists, we need to use `inter` with the `each` iterator to apply
it pairwise.
```q
    poss:$[(0<ni mod mw) and 0<ni div mw; nr[queue[;ni-1]]inter'nd queue[;ni-mw];
        0<ni mod mw; nr queue[;ni-1];
        0<ni div mw; nd queue[;ni-mw];
        '"???"];
```
We update the queue elements at the next position to create the next state of the queue. This is
done using [amend](https://code.kx.com/q/ref/amend/) in order to be able to iterate it. For each
row in the queue, we want to apply the amend separately for each element on the right, so a
combination of `'` (each) and `/:` (each-right) is necessary. Furthermore, we need to raze the
results to get rid of the exra level of nesting.
```q
q)raze @[;ni;:;]/:'[queue;poss]
(`...;3) (`f.m;5) () () () () () () ()
(`...;4) (`.rm;2) () () () () () () ()
(`...;5) (`frm;8) () () () () () () ()
(`...;6) (`...;4) () () () () () () ()
(`...;7) (`...;3) () () () () () () ()
(`..m;3) (`..m;7) () () () () () () ()
(`..m;4) (`..m;6) () () () () () () ()
..
```
The iteration continues with the updated queue. At the end, we end up with all tiles filled in:
```q
q)queue
`... 6 `... 4 `.rm 2 `... 7 `... 3 `f.m 5 `... 1 `... 0 `.r. 8
`..m 8 `.rm 0 `.rm 1 `fr. 5 `.rm 3 `.rm 7 `... 2 `.rm 4 `.rm 6
`.r. 1 `.r. 0 `... 8 `.r. 7 `.r. 3 `frm 5 `.r. 6 `.r. 4 `..m 2
`.r. 2 `..m 4 `..m 6 `f.. 5 `..m 3 `..m 7 `.rm 8 `..m 0 `..m 1
`f.. 6 `f.. 7 `f.. 1 `f.. 4 `f.. 3 `f.. 0 `frm 2 `.r. 5 `f.m 8
`f.m 1 `f.m 7 `f.m 6 `f.m 0 `f.m 3 `f.m 4 `f.. 8 `.rm 5 `fr. 2
`f.m 2 `... 5 `frm 8 `fr. 4 `fr. 3 `fr. 0 `fr. 6 `fr. 7 `fr. 1
`fr. 8 `..m 5 `f.. 2 `frm 0 `frm 3 `frm 4 `frm 1 `frm 7 `frm 6
```
This forms part of the return value of the helper function `d20`, with some other variables as
mentioned above.

## Part 1
We call the above helper function on the input. We extract the map width into a variable.
```q
q)mw:r 0
q)mw
3
```
We find the indices of the corner tiles based on the map width:
```q
q)(0;mw-1;mw*mw-1;(mw*mw)-1)
0 2 6 8
```
The tiles are in element 2 of `r`. There are 8 different map configurations, but the answer only
requires the IDs of the corner tiles, which are the same regardless of rotation and mirroring, so we
arbitrarily pick the first configuration. The third index is where we plug in the numbers from the
previous step. The fourth index is the one that distinguishes between the two components of a tile
(the symbol indicating the transformations and the tile index), so we put in 1 as we don't care
about the transformations at this point.
```q
q)r[2]

`... 6 `... 4 `.rm 2 `... 7 `... 3 `f.m 5 `... 1 `... 0 `.r. 8
`..m 8 `.rm 0 `.rm 1 `fr. 5 `.rm 3 `.rm 7 `... 2 `.rm 4 `.rm 6
`.r. 1 `.r. 0 `... 8 `.r. 7 `.r. 3 `frm 5 `.r. 6 `.r. 4 `..m 2
`.r. 2 `..m 4 `..m 6 `f.. 5 `..m 3 `..m 7 `.rm 8 `..m 0 `..m 1
`f.. 6 `f.. 7 `f.. 1 `f.. 4 `f.. 3 `f.. 0 `frm 2 `.r. 5 `f.m 8
`f.m 1 `f.m 7 `f.m 6 `f.m 0 `f.m 3 `f.m 4 `f.. 8 `.rm 5 `fr. 2
`f.m 2 `... 5 `frm 8 `fr. 4 `fr. 3 `fr. 0 `fr. 6 `fr. 7 `fr. 1
`fr. 8 `..m 5 `f.. 2 `frm 0 `frm 3 `frm 4 `frm 1 `frm 7 `frm 6
q)r[2;0]
`... 6
`... 4
`.rm 2
`... 7
`... 3
`f.m 5
`... 1
`... 0
`.r. 8
q)r[2;0;;1]
6 4 2 7 3 5 1 0 8
q)r[2;0;;1](0;mw-1;mw*mw-1;(mw*mw)-1)
6 2 1 8
```
We use these as indices into the tile ID list (`r[1]`) and take their product:
```q
q)r[1]r[2;0;;1](0;mw-1;mw*mw-1;(mw*mw)-1)
2971 1171 1951 3079
q)prd r[1]r[2;0;;1](0;mw-1;mw*mw-1;(mw*mw)-1)
20899048083289
```

## Part 2
We call the helper function and extract the map width and queue into helper variables:
```q
q)r:d20 x
q)mw:r 0
q)queue:r 2
q)mw
3
q)queue
`... 6 `... 4 `.rm 2 `... 7 `... 3 `f.m 5 `... 1 `... 0 `.r. 8
`..m 8 `.rm 0 `.rm 1 `fr. 5 `.rm 3 `.rm 7 `... 2 `.rm 4 `.rm 6
`.r. 1 `.r. 0 `... 8 `.r. 7 `.r. 3 `frm 5 `.r. 6 `.r. 4 `..m 2
`.r. 2 `..m 4 `..m 6 `f.. 5 `..m 3 `..m 7 `.rm 8 `..m 0 `..m 1
`f.. 6 `f.. 7 `f.. 1 `f.. 4 `f.. 3 `f.. 0 `frm 2 `.r. 5 `f.m 8
`f.m 1 `f.m 7 `f.m 6 `f.m 0 `f.m 3 `f.m 4 `f.. 8 `.rm 5 `fr. 2
`f.m 2 `... 5 `frm 8 `fr. 4 `fr. 3 `fr. 0 `fr. 6 `fr. 7 `fr. 1
`fr. 8 `..m 5 `f.. 2 `frm 0 `frm 3 `frm 4 `frm 1 `frm 7 `frm 6
```
The tile contents are in element 3 of `r`. We eliminate the borders from these using the `_` (drop)
operator - we remove the first and last element of each tile, plus the first and last element of
each row of each tile, which requires varying the number of `/:` (each-right) iterators to make sure
the operation is applied at the correct level:
```q
q)r 3
...| "..##.#..#." "##..#....." "#...##..#." "####.#...#" "##.##.###." "##...#.###" ".#.#.#..##" "...
f..| ".#####..#." ".#.####.#." "#..#...###" "#..##.#..#" ".##.#....#" "#.##.##..." "....#...#." "...
.r.| "..###..###" "###...#.#." "..#....#.." ".#.#.#..##" "##...#.###" "##.##.###." "####.#...#" "#..
fr.| "...#.##..#" "#.#.###.##" "....##.#.#" "....#...#." "#.##.##..." ".##.#....#" "#..##.#..#" "#..
..m| ".#..#.##.." ".....#..##" ".#..##...#" "#...#.####" ".###.##.##" "###.#...##" "##..#.#.#." "...
.rm| "###..###.." ".#.#...###" "..#....#.." "##..#.#.#." "###.#...##" ".###.##.##" "#...#.####" "...
f.m| ".#..#####." ".#.####.#." "###...#..#" "#..#.##..#" "#....#.##." "...##.##.#" ".#...#...." "#..
frm| "#..##.#..." "##.###.#.#" "#.#.##...." ".#...#...." "...##.##.#" "#....#.##." "#..#.##..#" "#..
q)tco:-1_/:/:/:1_/:/:/:-1_/:/:1_/:/:r 3
q)tco
...| "#..#...." "...##..#" "###.#..." "#.##.###" "#...#.##" "#.#.#..#" ".#....#." "##...#.#" ".###..
f..| "#.####.#" "..#...##" "..##.#.." "##.#...." ".##.##.." "...#...#" "...##.#." ".#.###.#" "...#..
.r.| "##...#.#" ".#....#." "#.#.#..#" "#...#.##" "#.##.###" "###.#..." "...##..#" "#..#...." ".#.#..
fr.| ".#.###.#" "...##.#." "...#...#" ".##.##.." "##.#...." "..##.#.." "..#...##" "#.####.#" ".##...
..m| "....#..#" "#..##..." "...#.###" "###.##.#" "##.#...#" "#..#.#.#" ".#....#." "#.#...##" "...#..
.rm| "#.#...##" ".#....#." "#..#.#.#" "##.#...#" "###.##.#" "...#.###" "#..##..." "....#..#" ".#....
f.m| "#.####.#" "##...#.." "..#.##.." "....#.##" "..##.##." "#...#..." ".#.##..." "#.###.#." ".###..
frm| "#.###.#." ".#.##..." "#...#..." "..##.##." "....#.##" "..#.##.." "##...#.." "#.####.#" ".###..
```
There are 8 different map configurations in the queue. We don't know which one is correct, so we
assemble the full map for all of them. This is how it is done for the first configuration.

We use the items of the configuration as indices into the tile contents map. The `.` (multi-level
apply) will look up a single tile. To look up multiple tiles, we iterate it with `/:` (each-right).
```q
q)queue 0
`... 6
`... 4
`.rm 2
`... 7
`... 3
`f.m 5
`... 1
`... 0
`.r. 8
q)tco ./:queue 0
"...###.." ".#.###.." "#.##..#." "#####..#" "#..####." "..#.#..#" ".####.##" ".#.#.###"
".##...#." "##..##.." ".#...#.." "####...#" "..#.#.#." "..#.#.#." "#.#...##" ".##.##.#"
"..#..###" "####.##." "####...#" "##....##" "###.###." "####.###" "#.#..#.#" "..#.##.."
"###.#..." ".#.#...." "...#..#." "##..##.#" "#.####.." "###.#.#." "#.####.." "#..#.##."
"#..#.##." "#.##.#.." ".#.#.##." "...#...#" "..##..##" "..#.####" "#.####.#" ".#..###."
"######.." ".###.##." ".###.###" ".#.#.#.." "######.#" "##.#..##" ".#.###.." "#.##...."
".####..." "....#..#" "...#####" "##.#...." "###.####" "##.##.##" "###....#" ".#.#..#."
"#..#...." "...##..#" "###.#..." "#.##.###" "#...#.##" "#.#.#..#" ".#....#." "##...#.#"
".#......" ".#.###.." ".#####.#" "#...#.##" "###.#..#" "#####..." ".#......" "#..#####"
```
This only provides the tile contents in reading order, and it's not yet possible to raze them
together to form the full map. First we need to cut the overall list to the map size:
```q
q)mw cut tco ./:queue 0
"...###.." ".#.###.." "#.##..#." "#####..#" "#..####." "..#.#..#" ".####.##" ".#.#.###" ".##...#."..
"###.#..." ".#.#...." "...#..#." "##..##.#" "#.####.." "###.#.#." "#.####.." "#..#.##." "#..#.##."..
".####..." "....#..#" "...#####" "##.#...." "###.####" "##.##.##" "###....#" ".#.#..#." "#..#...."..
```
This 4-dimensional structure has the indices (map row; map column; tile row; tile column). In order
to form the map, we need the tile rows to be contiguous, which means swapping the second and third
coordinate. Applying a `flip` swaps the first two coordinates, so we need to lower the operation
by one level using an `each`:
```q
q)flip each mw cut tco ./:queue 0
"...###.." ".##...#." "..#..###" ".#.###.." "##..##.." "####.##." "#.##..#." ".#...#.." "####...#"..
"###.#..." "#..#.##." "######.." ".#.#...." "#.##.#.." ".###.##." "...#..#." ".#.#.##." ".###.###"..
".####..." "#..#...." ".#......" "....#..#" "...##..#" ".#.###.." "...#####" "###.#..." ".#####.#"..
```
Now that the row contents are next to each other, we can raze them, which we need to do on the third
level, so we need two levels of `each` (which can be collaped to `each/:`):
```q
q)raze each/:flip each mw cut tco ./:queue 0
"...###...##...#...#..###" ".#.###..##..##..####.##." "#.##..#..#...#..####...#" "#####..#####...#..
"###.#...#..#.##.######.." ".#.#....#.##.#...###.##." "...#..#..#.#.##..###.###" "##..##.#...#...#..
".####...#..#.....#......" "....#..#...##..#.#.###.." "...########.#....#####.#" "##.#....#.##.###..
```
We further raze the result to get the full map:
```q
q)raze raze each/:flip each mw cut tco ./:queue 0
"...###...##...#...#..###"
".#.###..##..##..####.##."
"#.##..#..#...#..####...#"
"#####..#####...###....##"
"#..####...#.#.#.###.###."
"..#.#..#..#.#.#.####.###"
".####.###.#...###.#..#.#"
".#.#.###.##.##.#..#.##.."
"###.#...#..#.##.######.."
".#.#....#.##.#...###.##."
"...#..#..#.#.##..###.###"
"##..##.#...#...#.#.#.#.."
"#.####....##..########.#"
"###.#.#...#.######.#..##"
"#.####..#.####.#.#.###.."
"#..#.##..#..###.#.##...."
".####...#..#.....#......"
"....#..#...##..#.#.###.."
"...########.#....#####.#"
"##.#....#.##.####...#.##"
"###.#####...#.#####.#..#"
"##.##.###.#.#..######..."
..
```
We need to do this to all elements in the queue. However, that would mean adding one level of depth
to each of the operations, which would look quite ugly. I chose to wrap the above logic in a
function and call it with `each` on the queue, but since the code requires `mw` and `tco`, these
also need to be passed in:
```q
q)imgs:{[tco;mw;x]raze raze each/:flip each mw cut tco ./:x}[tco;mw]each queue
q)imgs
"...###...##...#...#..###" ".#.###..##..##..####.##." "#.##..#..#...#..####...#" "#####..#####...#..
"#####..##.#...##.#..#.#." "......#..#....#.#....###" "...######..#.#.###.##.##" "#..#.#####.#...#..
".#.#..#.##...#.##..#####" "###....#.#....#..#......" "##.##.###.#.#..######..." "###.#####...#.##..
"###..#...#...##...###..." ".##.####..##..##..###.#." "#...####..#...#..#..##.#" "##....###...####..
"..###...#..#####...####." ".#.#..####.#.#..#..#####" "..##.##.#...###.#...#.#." "#####.##.##.#.##..
".####...#####..#...###.." "#####..#..#.#.####..#.#." ".#.#...#.###...#.##.##.." "#.#.##.###.#.##...
"#.##.##...#.##....###..#" "##.###...##..#.....#...#" "##..#########.#..##....#" "....#..##...#.#...
"#..###....##.#...##.##.#" "#...#.....#..##...###.##" "#....##..#.#########..##" "#.#####..#.#...#..
```
We create a representation of the sea monster pattern:
```q
q)pattern:enlist"                  # "
q)pattern,:enlist"#    ##    ##    ###"
q)pattern,:enlist" #  #  #  #  #  #   "
q)pattern
"                  # "
"#    ##    ##    ###"
" #  #  #  #  #  #   "
```
To make it easier to find the pattern, we convert it into a list of coordinate pairs using the
[2D search](../utils/patterns.md#2d-search) technique:
```q
q)pattern2:raze til[count pattern],/:'where each"#"=pattern
q)pattern2
0 18
1 0
1 5
1 6
1 11
1 12
1 17
1 18
1 19
2 1
2 4
2 7
2 10
2 13
2 16
```
The coordinates to check are the sums of the above and the possible top-left coordinates. We can
calculate the top-left coordinates from the difference of the size of the map and the pattern. Note
that there is a possible off-by-one error here - e.g. if the map width is 24 and the pattern width
is 4, the possible horizontal coordinates are 0 to 4 (`til 5`), not 0 to 3 (`til 4`).
```q
q)til 1+count[imgs 0]-count[pattern]
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
q)til 1+count[imgs[0;0]]-count pattern 0
0 1 2 3 4
q)topLefts:(til 1+count[imgs 0]-count[pattern])cross til 1+count[imgs[0;0]]-count pattern 0
q)topLefts
0 0
0 1
0 2
0 3
0 4
1 0
1 1
1 2
1 3
1 4
2 0
2 1
2 2
2 3
2 4
3 0
3 1
3 2
3 3
3 4
4 0
4 1
..
```
To get all the coordinates that we need to check, we add the pattern coordinates to the top-left
coordinates with a combination of each-left and each-right:
```q
q)coords:topLefts+/:\:pattern2
q)coords
0 18 1 0  1 5  1 6  1 11 1 12 1 17 1 18 1 19 2 1  2 4  2 7  2 10 2 13 2 16
0 19 1 1  1 6  1 7  1 12 1 13 1 18 1 19 1 20 2 2  2 5  2 8  2 11 2 14 2 17
0 20 1 2  1 7  1 8  1 13 1 14 1 19 1 20 1 21 2 3  2 6  2 9  2 12 2 15 2 18
0 21 1 3  1 8  1 9  1 14 1 15 1 20 1 21 1 22 2 4  2 7  2 10 2 13 2 16 2 19
0 22 1 4  1 9  1 10 1 15 1 16 1 21 1 22 1 23 2 5  2 8  2 11 2 14 2 17 2 20
1 18 2 0  2 5  2 6  2 11 2 12 2 17 2 18 2 19 3 1  3 4  3 7  3 10 3 13 3 16
1 19 2 1  2 6  2 7  2 12 2 13 2 18 2 19 2 20 3 2  3 5  3 8  3 11 3 14 3 17
1 20 2 2  2 7  2 8  2 13 2 14 2 19 2 20 2 21 3 3  3 6  3 9  3 12 3 15 3 18
1 21 2 3  2 8  2 9  2 14 2 15 2 20 2 21 2 22 3 4  3 7  3 10 3 13 3 16 3 19
1 22 2 4  2 9  2 10 2 15 2 16 2 21 2 22 2 23 3 5  3 8  3 11 3 14 3 17 3 20
2 18 3 0  3 5  3 6  3 11 3 12 3 17 3 18 3 19 4 1  4 4  4 7  4 10 4 13 4 16
2 19 3 1  3 6  3 7  3 12 3 13 3 18 3 19 3 20 4 2  4 5  4 8  4 11 4 14 4 17
2 20 3 2  3 7  3 8  3 13 3 14 3 19 3 20 3 21 4 3  4 6  4 9  4 12 4 15 4 18
2 21 3 3  3 8  3 9  3 14 3 15 3 20 3 21 3 22 4 4  4 7  4 10 4 13 4 16 4 19
2 22 3 4  3 9  3 10 3 15 3 16 3 21 3 22 3 23 4 5  4 8  4 11 4 14 4 17 4 20
3 18 4 0  4 5  4 6  4 11 4 12 4 17 4 18 4 19 5 1  5 4  5 7  5 10 5 13 5 16
3 19 4 1  4 6  4 7  4 12 4 13 4 18 4 19 4 20 5 2  5 5  5 8  5 11 5 14 5 17
3 20 4 2  4 7  4 8  4 13 4 14 4 19 4 20 4 21 5 3  5 6  5 9  5 12 5 15 5 18
3 21 4 3  4 8  4 9  4 14 4 15 4 20 4 21 4 22 5 4  5 7  5 10 5 13 5 16 5 19
3 22 4 4  4 9  4 10 4 15 4 16 4 21 4 22 4 23 5 5  5 8  5 11 5 14 5 17 5 20
4 18 5 0  5 5  5 6  5 11 5 12 5 17 5 18 5 19 6 1  6 4  6 7  6 10 6 13 6 16
4 19 5 1  5 6  5 7  5 12 5 13 5 18 5 19 5 20 6 2  6 5  6 8  6 11 6 14 6 17
..
```
We can apply the coordinates using the `.` operator - this time this requires two levels of descent
into the list:
```q
q)imgs[5]./:/:coords
".#...##..#.##.."
"##.##...#...#.#"
"###..#.#.#.#.##"
"##..###.#.##..."
".#.###.#...#.##"
"....#.##..##.##"
".#.#..#.#######"
"#.#....##..#..."
".#.#.###.##.###"
"#.###.#..######"
"###.#.#.#..##.."
"...#.#.####.#.#"
"###############"
"#.###.###.##..#"
".##..#####.#.##"
"..#######.....#"
"#.###.###.###.."
"###...##.#.##.."
"##.#.##.#....##"
"#.###..#####..."
"#.#.##..#...###"
"#...#..#.###..#"
..
```
Each of the items of the result is the content of a possible sea monster location. If there is a
monster there, all of the characters will be `"#"`:
```q
q)all each"#"=imgs[5]./:/:coords
00000000000010000000000000000000000000000000000000000000000000000000000000000000010000000000000000..
```
The number of monsters is the number of places where this condition is true, which can be obtained
simply by summing the list:
```q
q)sum all each"#"=imgs[5]./:/:coords
2i
```
Like before, in order to iterate this over all the maps, I chose to put the logic into a function:
```q
q){[coords;img]sum all each"#"=img ./:/:coords}[coords]each imgs
0 0 0 0 0 2 0 0i
```
At this point there is some ambiguity. The first point is whether the monster pattern can match on
incorrect orientations of the map. It turns out it can't, so it's enough to take the maximum of the
monster counts across all orientations:
```q
q)monster:max{[coords;img]sum all each"#"=img ./:/:coords}[coords]each imgs
q)monster
2i
```
The second point is whether monsters can overlap. Turns out they don't, so we can obtain the number
of non-monster characters by subtracting the number of `#` characters in the pattern times the
number of monsters from the number of `#` characters in the map. If there was a possible overlap,
it would have been more complicated to mark the monsters on the map to avoid double-counting
characters.
```q
q)monster*count pattern2
30
q)sum sum imgs[0]="#"
303i
q)(sum sum imgs[0]="#")-monster*count pattern2
273
```
