# Breakdown
Example input:
```q
q)md5 raze x
0xe9d534cca081df842271bda237e00c2c
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
The OCR is the same as the one from [day 8](day8.md).

The solution relies on [intcode.q](intcode.q), which is the generalized version of the interpreter
from [day 9](day9.md)

The `d11` function takes a program and the color of the initial panel as parameters:
```q
    d11:{[x;st]
        ...
    };
```
We start by initializing the intcode interpeter with the program:
```q
q)a:.intcode.new x
q)a
`run
0
0
0
3 8 1005 8 299 1106 0 11 0 0 0 104 1 104 0 3 8 102 -1 8 10 101 1 10 10 4 10 108 1 8 10 4 10 102 1 ..
`long$()
`long$()
```
We initialize the grid with only one panel, and the value of the panel depends on the `st`
parameter:
```q
q)grid:enlist enlist st
q)grid
0
```
We initialize a cursor (a pair of coordinates), the current direction, an indicator that shows if we
have to continue running the program, and the path of the robot:
```q
q)cursor:0 0
q)dir:0
q)run:1b
q)path:()
```
The main part of the solution is an iteration:
```q
    while[run;
        ...
    ];
```
As the first step of the iteration, we run the intcode interpreter, adding an input with the color
of the panel under the cursor (the `genarch` API requires the input to be passed in as a string):
```q
q)a:.intcode.run[.intcode.addInput[a;string grid . cursor]]
q)a
`needInput
15
1
0
3 8 1005 8 299 1106 0 11 0 0 0 104 1 104 0 3 8 102 -1 8 10 101 1 10 10 4 10 108 1 8 10 4 10 102 1 ..
,0
1 0
```
We extract the output:
```q
q)ins:last a
q)ins
1 0
```
The iteration needs to continue if the intcode interpreter stopped in the `needInput` state:
```q
q)run:.intcode.needsInput[a]
q)run
1b
```
The rest of the iteration is also only necessary if the program still needs to run:
```q
    if[run;
        ...
    ];
```
If so, we append the current cursor position to the path:
```q
q)path,:enlist cursor
q)path
0 0
```
We update the grid at the cursor position with the color returned by the program:
```q
q)grid:.[grid;cursor;:;first ins]
q)grid
1
```
We update the direction. The input range is `0 1`, which we need to turn into `-1 1`. Multiplying
`0 1` by 2 gives `0 2`, and subtracting 1 gives `-1 1`. We also need to `mod` by 4 to ensure that
the direction wraps around.
```q
q)dir:(dir+(2*last[ins])-1)mod 4
q)dir
3
```
We update the cursor by adding an offset from a hardcoded list indexed by the direction:
```q
q)cursor+:(-1 0;0 1;1 0;0 -1)dir
q)cursor
0 -1
```
If the cursor points outside the currently stored grid, we need to expand the grid. This is done in
four conditional statements. This code is capable of handling the coordinates being more than one
unit off the grid, although this will not happen in this puzzle. If the expansion happens because
the coordinate is negative, we also offset the cursor to point to row/column 0:
```q
q)if[cursor[0]<0; grid:(abs[cursor 0]#enlist count[first grid]#0),grid; path[;0]+:abs cursor[0];cursor[0]:0]
q)if[cursor[0]>=count grid; grid:grid,(1+cursor[0]-count grid)#enlist count[first grid]#0]
q)if[cursor[1]<0; grid:(abs[cursor 1]#0),/:grid; path[;1]+:abs cursor 1;cursor[1]:0]
q)if[cursor[1]>=count first grid; grid:grid,\:(1+cursor[1]-count first grid)#0]
q)cursor
0 0
q)grid
0 1
```
This is the end of the iteration. Once the iteration stops, we have the final grid and path. We
return a pair containing the grid and the number of distinct elements in the path.
```q
q)grid
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0 0 0 0 1 0 1 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 1 0 0 1 0 1 1 0 0 0 1 1 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 1 1 0 0 0 1 1 0 0 1 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 0 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 1 0 1 0 0 0 0 1 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1 0 1 0 0 1 0 1 0 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 1 0 1 1 1 1 1 0 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 1 1 0 1 1 0 1 0 0 1 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 1 0 0 1 1 0 1 0 1 0 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 1 0 0 0 0 0 1 1 1 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 1 0 0 0 0 0 1 1 1 1 1 1 0 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 1 0 0 0 0 1 1 1 1 1 0 1 1 1 0 0 1 0 1 1 0 0 0 1 1 0 0 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 1 0 1 0 1 1 0 0 1 1 1 1 1 1 1 1 1 0 1 0 0 0 1 1 0 0 1 1 1 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 1 1 0 0 1 1 0 0 1 1 0 1 1 0 1 0 0 1 0 0 0 0 1 1 1 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 1 0 1 1 0 1 0 0 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 1 0 0 1 1 0 0 1 1 1 0 1 0 0 1 0 1 1 1 1 0 1 0 0 0 1 0 0 1 0 1 1 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 1 0 0 1 0 1 1 1 0 0 0 1 0 1 1 0 1 1 0 0 1 0 0 1 0 1 1 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 1 0 0 0 1 1 1 0 0 0 1 1 0 1 0 0 1 1 0 0 1 0 0 0 0 0 0 ..
..
q)path
41 12
41 11
42 11
42 10
41 10
41 9
40 9
40 10
41 10
41 9
40 9
40 10
39 10
39 11
40 11
40 10
39 10
39 9
38 9
38 8
39 8
39 9
..
q)count distinct path
2252
```

## Part 1
We pass in 0 as `st`. The answer is returned as the second element from the common function.

## Part 2
We pass in 1 as `st` and only keep the grid:
```q
q)first d11[x;1]
0 0 1 1 0 0 0 1 1 0 0 0 1 1 0 0 1 0 0 0 0 1 1 1 0 0 0 1 1 0 0 0 0 1 1 0 1 1 1 1 0 0 0
0 1 0 0 1 0 1 0 0 1 0 1 0 0 1 0 1 0 0 0 0 1 0 0 1 0 1 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0
0 1 0 0 1 0 1 0 0 0 0 1 0 0 1 0 1 0 0 0 0 1 0 0 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 0 0 0
0 1 1 1 1 0 1 0 1 1 0 1 1 1 1 0 1 0 0 0 0 1 1 1 0 0 1 0 1 1 0 0 0 0 1 0 1 0 0 0 0 0 0
0 1 0 0 1 0 1 0 0 1 0 1 0 0 1 0 1 0 0 0 0 1 0 1 0 0 1 0 0 1 0 1 0 0 1 0 1 0 0 0 0 0 0
0 1 0 0 1 0 0 1 1 1 0 1 0 0 1 0 1 1 1 1 0 1 0 0 1 0 0 1 1 1 0 0 1 1 0 0 1 1 1 1 0 0 0
```
For easier visualization, we replace black with `" "` and white with `"*"`:
```q
q)grid:" *"first d11[x;1]
q)grid
"  **   **   **  *    ***   **    ** ****   "
" *  * *  * *  * *    *  * *  *    * *      "
" *  * *    *  * *    *  * *       * ***    "
" **** * ** **** *    ***  * **    * *      "
" *  * *  * *  * *    * *  *  * *  * *      "
" *  *  *** *  * **** *  *  ***  **  ****   "
```
We cut off any empty columns on the left and make sure that the grid is 40 wide (we can't just cut
off all empty columns on the right since some letters have all blanks there):
```q
q)grid
" **   **   **  *    ***   **    ** **** "
"*  * *  * *  * *    *  * *  *    * *    "
"*  * *    *  * *    *  * *       * ***  "
"**** * ** **** *    ***  * **    * *    "
"*  * *  * *  * *    * *  *  * *  * *    "
"*  *  *** *  * **** *  *  ***  **  **** "
```
Then we cut the grid up like we did with day 8 and perform OCR on it.
```q
q)ocr raze each flip 5 cut/:grid
"AGALRGJE"
```

## Whiteboxing
An interesting detail is that the two parts take completely different code paths, and therefore
there is no overlap in the whiteboxing strategies between the two, unlike the blackbox solution
which is largely the same, with only the post-processing steps being different.

### Part 1
The first pair of outputs is hardcoded as `1 0`. Then there is a sequence of 10 inputs follwed by a
pair of outputs each. The first output (the panel color) is the inverse of the input color. The
second output (turn direction) is obtained by comparing the input to a hardcoded value. However,
right after this, the constant is overwritten to the input. This means after the first run, the
output is compared to the input 10 inputs ago. The whole loop runs a certain number times, for a
total of `10n+1` inputs.

There are junk instructions thrown in between the inputs within a loop, probably to make sure that
it's not possible to get the initial comparison values by a simple `a[x+i*y]` kind of indexing.

To find the initial values, we look for instructions that look like `EQ [8],x,[10]` (the two
arguments may be reversed).
```q
q)a:"J"$","vs raze x
q)ind:where a in 108 1008
q)ind
27 56 82 104 129 158 184 206 239 265 467
```
We check if the 3rd arg is `[10]` as there may be stray indices, also we drop the last one because
it is valid but not in part 1:
```q
q)ind:-1_ind where a[ind+3]=10
q)ind
27 56 82 104 129 158 184 206 239
```
We populate the compare buffer by taking the two values after the instruction index and filtering
out the 8s:
```q
q)compBuffer:raze a[ind+\:1 2]except\:8
q)compBuffer
1 0 0 1 0 0 0 1 1
```
To find the number of iterations, we look for a `LT` instruction:
```q
q)ind:where a=1007
q)ind
224 291
```
We check if the arguments are `[9]` and `[10]` since the others are stray indices:
```q
q)ind:ind where a[ind+\:1 3]~\:9 10
q)ind
,291
```
The period is the 2nd argument to this instruction:
```q
q)iter:a[first[ind]+2]
q)iter
1003
```
The rest is similar to the blackbox solution, with the only difference being that we directly
produce the output using the logic above and the constants that we extracted.
```q
    do[1+10*iter;
        $[0=count path;
            out:1 0;
            [   
                input:grid . cursor;
                out:(1-input;compBuffer[0]=input);
                compBuffer:(1_compBuffer),input;
            ]
        ];
    ...
```
The updating of `path`, `grid` and `dir`, including expanding the grid, is copied over from `d11p1`.
```q
q)count distinct path
2252
```
### Part 2
The ID is stored as a bitmap in 6 large numbers, which are then decoded and printed in a meandering
pattern. The first large number starts at the top left, and the first four bits correspond to a 2x2
square in the order top left, bottom left, bottom right, top left. There are 40 bits per large
number, so the first one fills half of the top two rows of the ID. The second large number completes
the first rows. The ID is drawn in a [boustrophedon](https://en.wikipedia.org/wiki/Boustrophedon)
way, so the next two large numbers are painted from right to left with the ordering of the pixels
inside the 2x2 squares reversed. Finally the last two large numbers are painted from left to right
like the first two.

To find the bitmaps, all we have to do is find very large numbers in the intcode:
```q
q)ns:a where a>100000
q)ns
387239486208 936994976664 29192457307 3450965211 837901103972 867965752164
```
We reorder the bits in each number to counteract the arrangement described above:
```q
q)seq1:raze each flip @[;(0 3;1 2)]each 4 cut raze -40#/:0b vs/:ns 0 1
q)seq2:raze each flip @[;(1 2;0 3)]each 4 cut reverse raze -40#/:0b vs/:ns 2 3
q)seq3:raze each flip @[;(0 3;1 2)]each 4 cut raze -40#/:0b vs/:ns 4 5
q)seq1
0110001100011001000011100011000011011110b
1001010010100101000010010100100001010000b
q)seq2
1001010000100101000010010100000001011100b
1111010110111101000011100101100001010000b
q)seq3
1001010010100101000010100100101001010000b
1001001110100101111010010011100110011110b
```
We put them together to form the final grid:
```q
q)grid:" *"seq1,seq2,seq3
q)grid
" **   **   **  *    ***   **    ** **** "
"*  * *  * *  * *    *  * *  *    * *    "
"*  * *    *  * *    *  * *       * ***  "
"**** * ** **** *    ***  * **    * *    "
"*  * *  * *  * *    * *  *  * *  * *    "
"*  *  *** *  * **** *  *  ***  **  **** "
```
From here the post-processing is the same as the blackbox solution.
```q
q)ocr raze each flip 5 cut/:grid
"AGALRGJE"
```
