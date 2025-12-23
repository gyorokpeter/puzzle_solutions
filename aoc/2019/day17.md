# Breakdown
Example input:
```q
q)md5 raze x
0x75412dc5bf64f9e74eb97cd893dfef87
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Part 1
We initialize the intcode interpreter:
```q
q)a:.intcode.new x
```
We run the program and fetch the output:
```q
q).intcode.getOutput .intcode.run[a]
46 46 46 46 46 46 46 46 46 46 46 46 46 46 35 35 35 35 35 35 35 46 46 46 46 46 46 46 46 46 46 46 46..
```
We convert the output into characters, cut on newlines and remove the empty lines:
```q
q)r:("\n"vs`char$.intcode.getOutput .intcode.run[a])except enlist""
q)r
"..............#######................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#########.............................."
"....................#.#.............................."
"....................###########......................"
"......................#.......#......................"
"......................#.......#......................"
"......................#.......#......................"
"......................#.......#......................"
"......................#.......#......................"
"............###########.......#......................"
"............#.................#......................"
"............#.................#......................"
"............#.................#......................"
..
```
The intersections are those spots where there are `#` symbols in all four directions and on the tile
itself. We can calculate these by shifting the matrix in all 4 directions (adding empty spaces to
fill up the edges):
```q
q)r1:"#"=".",/:-1_/:r
q)r1
00000000000000011111110000000000000000000000000000000b
00000000000000010000010000000000000000000000000000000b
00000000000000010000010000000000000000000000000000000b
00000000000000010000010000000000000000000000000000000b
00000000000000010000010000000000000000000000000000000b
..
q)r2:"#"=(1_/:r),\:"."
q)r2
00000000000001111111000000000000000000000000000000000b
00000000000001000001000000000000000000000000000000000b
00000000000001000001000000000000000000000000000000000b
00000000000001000001000000000000000000000000000000000b
00000000000001000001000000000000000000000000000000000b
..
q)r3:"#"=(1_r),enlist count[first r]#"."
q)r3
00000000000000100000100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
..
q)r4:"#"=enlist[count[first r]#"."],(-1_r)
q)r4
00000000000000000000000000000000000000000000000000000b
00000000000000111111100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
00000000000000100000100000000000000000000000000000000b
..
```
Then we take the intersection of all five versions to find the intersections in the path:
```q
q)cr:all("#"=r;r1;r2;r3;r4)
q)cr
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000100000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000001000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
..
```
We find the coordinates of the intersections using a [2D search](../utils/patterns.md#2d-search):
```q
q)raze til[count cr],/:'where each cr
10 20
12 22
26 12
28 10
34 42
38 42
38 48
40 40
46 40
48 30
48 36
```
We perform the multiplication on them and sum the results:
```q
q)(*).'raze til[count cr],/:'where each cr
200 264 312 280 1428 1596 1824 1600 1840 1440 1728
q)sum(*).'raze til[count cr],/:'where each cr
12512
```

## Part 2
The solution consists of two phases. First we construct the program to trace the entire path, then
we find the combination of `A,B,C` that can be used to compose the main program.

After initializing the intcode VM, we overwrite the trigger byte as instructed:
```q
q)a:.intcode.editMemory[.intcode.new x;0;2]
```
We run the program and extract the output as in part 1:
```q
q)r:("\n"vs`char$.intcode.getOutput a:.intcode.run[a])except enlist""
q)r
"..............#######................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
..
```
We find the bot position using a 2D search for any of the 4 possible directional "arrows":
```q
q)botPos:first raze til[count r],/:'where each r in "^><v"
q)botPos
50 18
```
We also convert the direction to an integer between 0 and 3 for easier processing:
```q
q)botDir:"^>v<"?r . botPos
q)botDir
0
```
For the first phase, we initialize a visited matrix (using a trick of indexing an empty boolean list
with the map, resulting in all cells becoming zeros):
```q
q)visited:(0#0b)r
q)visited
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
00000000000000000000000000000000000000000000000000000b
..
```
We mark the initial bot position as visited:
```q
q)visited[botPos 0;botPos 1]:1b
```
We initialize the path to empty, define the deltas corresponding to the four directions, and set a
loop continuation variable to true:
```q
q)path:()
q)dirs:(-1 0;0 1;1 0;0 -1)
q)run:1b
```
The iteration runs while the run flag is true:
```q
    while[run;
        ...
    ];
```
During the iteration, first we find the number of tiles to move forward. We initialize the move
counter to zero:
```q
    move:0;
```
We find the next position by adding the delta corresponding to the bot direction to the bot's
current position:
```q
    nxt:botPos+dirs botDir;
```
In a sub-iteration, we check for `#` tiles at the next position. If we find one, we increment the
move counter, mark the tile as visited and update the bot and next position:
```q
    while["#"=r . nxt;
        move+:1;
        botPos:nxt;
        visited[nxt 0;nxt 1]:1b;
        nxt:botPos+dirs botDir;
    ];
```
We append the move command to the path, but only if there are more than zero tiles to move (this
check avoids adding a zero command at the beginning):
```q
    if[0<move;
        path,:enlist string move;
    ];
```
Now we try to turn the bot. We generate the coordinates of the tiles in all four directions:
```q
    nxts:botPos+/:dirs;
```
We filter to those tiles that have `#` on them:
```q
    nxts:nxts where "#"=r ./:nxts;
```
We also drop any visited tiles:
```q
    nxts:nxts where not visited ./:nxts;
```
If there are no tiles left after this filtering, that means we reached the end of the path, so the
iteration can stop:
```q
    if[0=count nxts; run:0b];
```
Otherwise, we take only the first possible next position (there should only ever be one):
```q
    nxt:first nxts;
```
We look up what direction this corresponds to and subtract that from the bot's direction to see what
direction to turn in:
```q
    nxtDir:dirs?nxt-botPos;
    turn:(nxtDir-botDir)mod 4;
```
Depending on the turn direction, we add either a `R` or `L` command, and update the bot's direction:
```q
    $[turn=1; [path,:enlist enlist"R";botDir:(botDir+1)mod 4];
      turn=3; [path,:enlist enlist"L";botDir:(botDir-1)mod 4];
      '"stuck"];
```
This ends the first iteration. At the end, the variable `path` contains the full path element by
element:
```q
q)path
,"R"
"12"
,"L"
"10"
,"R"
"12"
,"L"
,"8"
,"R"
"10"
,"R"
,"6"
,"R"
"12"
,"L"
"10"
,"R"
"12"
,"R"
"12"
,"L"
"10"
..
```
We calculate the three subprograms using a recursive function. Generally, recursion is not a good
idea to use as a control structure in q, but this time we know that the recursion won't go too deep
because of the short lengths of the programs. The recursive function takes two arguments: the
prefixes of the subprograms (one or even all of them may be missing) and the remaining path.
```q
    findAbc:{[prefixes;path]
        ...
    }
```
The exit condition is if the path contains only a single empty string:
```q
    if[path~enlist""; :enlist prefixes];
```
We convert the path into a single string by joining the elements with commas:
```q
q)cpath:","sv path
q)cpath
"R,12,L,10,R,12,L,8,R,10,R,6,R,12,L,10,R,12,R,12,L,10,R,10,L,8,L,8,R,10,R,6,R,12,L,10,R,10,L,8,L,8..
```
If there are already some prefixes, we check which of them match the remaining path:
```q
    match:where prefixes~'(count each prefixes)#\:cpath;
```
Then we call the function recursively on the remaining path after taking away the matching prefix.
We split the path again on commas. This is why the exit check is for `enlist""`, because that's what
we get if we try to split an empty string (which is unfortunate, logically it should be an empty
general list).
```q
    res:raze .z.s[prefixes] each ","vs/:(1+count each prefixes)[match]_\:cpath;
```
If we have less than 3 prefixes, we try every possible way to add a new prefix.
```q
    if[3>count prefixes;
        ...
    ];
```
We do this by taking increasing prefixes of the path, up to 20 characters, also making sure not to
duplicate a previously discovered prefix:
```q
q)poss:({x where 20>=count each x}{x,",",y}\[first path;1_path])except prefixes;
q)poss
"R,12"
"R,12,L"
"R,12,L,10"
"R,12,L,10,R"
"R,12,L,10,R,12"
"R,12,L,10,R,12,L"
"R,12,L,10,R,12,L,8"
"R,12,L,10,R,12,L,8,R"
```
We then recursively call the function, with the path not changing, and adding each of the possible
prefixes in turn to the prefix list:
```q
    res,:raze .z.s[;path] each prefixes,/:enlist each poss;
```
The variable `res` now has results from two places, first the attempt to remove a prefix from the
path, and the other where we try to add new prefixes. This combined list is the return value of the
function.

An example of successfully removing a prefix:
```q
q)path:(enlist"R";"12";enlist"L";"10";enlist"R";"10";enlist"L";enlist"8")
q)prefixes:("R,12,L,10,R,12";"L,8,R,10,R,6";"R,12,L,10,R,10,L,8")
q)cpath:","sv path
q)match:where prefixes~'(count each prefixes)#\:cpath
q)match
,2
q)(1+count each prefixes)[match]_\:cpath
""
q)res:raze findAbc[prefixes] each ","vs/:(1+count each prefixes)[match]_\:cpath
q)res
"R,12,L,10,R,12" "L,8,R,10,R,6" "R,12,L,10,R,10,L,8"
```
We call the function with an empty list of prefixes and the full path:
```q
q)abcs:findAbc[();path]
q)abcs
"R,12,L,10,R,12" "L,8,R,10,R,6" "R,12,L,10,R,10,L,8"
```
This is actually a list of solutions, but we only care that there is at least one, so we take
the first one:
```q
q)if[0=count abcs; '"no ABC found?!"]
q)abc:first abcs
q)abc
"R,12,L,10,R,12"
"L,8,R,10,R,6"
"R,12,L,10,R,10,L,8"
```
We use `ssr` on the comma-separated path to replace parts of the path with the corresponding `A`,
`B` or `C` functions. This relies on there being no overlap between the three prefixes, which is
true for the puzzle input.
```q
q)pg:ssr/[","sv path;abc;"ABC"]
q)pg
"A,B,A,C,B,C,B,C,A,C"
```
We create the input that can be fed into the intcode program:
```q
q)allInput:"\n"sv enlist[pg],abc,(enlist"n";"")
q)allInput
"A,B,A,C,B,C,B,C,A,C\nR,12,L,10,R,12\nL,8,R,10,R,6\nR,12,L,10,R,10,L,8\nn\n"
```
We cast the input string to long and run the intcode VM with it:
```q
q)r:.intcode.runI[a;`long$allInput]
```
The answer is the last number of the output generated by the VM:
```q
q)last .intcode.getOutput r
1409507
```

## Whiteboxing
### Part 1
The map is stored in the code with run-length encoding. There is a list of numbers and each number
describes how many tiles of the same state follow, starting with space tiles (if the top left tile
is a platform tile, there is a zero in the encoding to indicate the initial sequence of zero space
tiles).

We split the encoding out of the code:
```q
q)a:"J"$","vs raze x
q)1182_(first a[11 12]except 0 1)#a
14 7 46 1 5 1 46 1 5 1 46 1 5 1 46 1 5 1 46 1 5 1 46 1 5 1 46 1 5 1 46 1 5 1 46 1 5 1 46 9 50 1 1 ..
```
q has a nuke that we can use to expand the run length encoding. Although it is not often used for
this purpose, the [`where`](https://code.kx.com/q/ref/where/) function actually repeats every index
as many times as the value of the respective element of the list. For boolean values this results in
the familiar "return the true indices" behavior, however it works just as well on integers, such as
this RLE scenario, creating sequences of the given lengths:
```q
q)where 1182_(first a[11 12]except 0 1)#a
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 ..
```
Now we only need to fix the values. Since we know they alternate between space and platform, we can
modulo by 2:
```q
q)(where 1182_(first a[11 12]except 0 1)#a)mod 2
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
```
And use list indexing to map these to the corresponding ASCII characters:
```q
q)".#"(where 1182_(first a[11 12]except 0 1)#a)mod 2
"..............#######..............................................#.....#.........................
```
Then we need to cut this string into a rectangle, looking up the width from the code:
```q
q)r:a[935] cut".#"(where 1182_(first a[11 12]except 0 1)#a)mod 2
q)r
"..............#######................................"
"..............#.....#................................"
"..............#.....#................................"
"..............#.....#................................"
..
```
From here the solution proceeds like regular part 1.

### Part 2
This is more interesting as we can completely bypass the requirement to program the robot by
generating the score (the "dust counter") directly.

It turns out that the score is composed of multiple values added together:
- The offset in memory of where the tile is found (after the code decodes the RLE). This is always
found at the end of the RLE, in row major order, so the value is `(y*w)+x`.
- The x and y coordinates multiplied together plus one.
- A running counter starting at 0.
This is only how the code does it, of course in q we can use a closed vector formula.

We get the width of the field:
```q
q)w:a[935]
q)w
53
```
We find the end of the RLE, where the decoding will start:
```q
q)a[11 12]
0 1483
q)cend:(first a[11 12]except 0 1)
q)cend
1483
```
We generate the tiles like in part 1:
```q
q)r:w cut(where 1182_cend#a)mod 2
q)r
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
..
```
We get the tile positions using a 2D search:
```q
q)tilePos:raze til[count r],/:'where each r
q)tilePos
0 14
0 15
0 16
0 17
0 18
0 19
0 20
..
```
We extract the x and y coordinates, then apply the formula as described above:
```q
q)cx:tilePos[;1]
q)cy:tilePos[;0]
q)cx
14 15 16 17 18 19 20 14 20 14 20 14 20 14 20 14 20 14 20 14 20 14 20 14 20 14 15 16 17 18 19 20 21..
q)cy
0 0 0 0 0 0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 10 10 10 10 10 10 10 11 11 12 12 12 12 12 ..
q)(1+cend+cx+cy*w+cx)+til count tilePos
1498 1500 1502 1504 1506 1508 1510 1572 1585 1641 1660 1710 1735 1779 1810 1848 1885 1917 1960 198..
q)sum(1+cend+cx+cy*w+cx)+til count tilePos
1409507
```
