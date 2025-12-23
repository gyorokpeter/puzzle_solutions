# Breakdown
Example input:
```q
q)md5 raze x
0x24677239e855df0717851adc07a197c7
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Part 1
We initialize the intcode interpreter, run the program and extract the output:
```q
q)out:.intcode.getOutput .intcode.run .intcode.new x
q)out
0 0 1 1 0 1 2 0 1 3 0 1 4 0 1 5 0 1 6 0 1 7 0 1 8 0 1 9 0 1 10 0 1 11 0 1 12 0 1 13 0 1 14 0 1 15 ..
```
We cut the output to the width of 3 to get the paint instructions:
```q
q)paint:3 cut out
q)paint
0  0 1
1  0 1
2  0 1
3  0 1
4  0 1
5  0 1
6  0 1
..
```
Since we need the _block_ tiles, we need to find the instructions with a block type of 2:
```q
q)2=last each paint
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000..
```
The answer is the sum of these matches:
```q
q)sum 2=last each paint
329i
```

## Part 2
On each step we find the position of the paddle and the ball, and use the signum of the difference
between the ball and paddle X positions as the input in order to track the ball.

We initialize the intcode interpreter and change the memory at address 0 as indicated. We also
initialize a score and grid variable. The grid is a generic null because we don't know the size yet.
```q
q)a:.intcode.editMemory[.intcode.new x;0;2]; score:0; grid:(::);
```
We initialize a variable that indicates if the simulation should continue, and one to hold the input
which is empty but will be changed in the iteration:
```q
q)run:1b; input:();
```
We perform an iteration:
```q
    while[run;
        ...
    ];
```
Inside the iteration, we run the interpreter, passing in the input if any:
```q
q)a:.intcode.runI[a;input]
q)a
`needInput
75
1
2710
2 380 379 385 1008 2709 828459 381 1005 381 12 99 109 2710 1102 1 0 383 1102 1 0 382 20101 0 382 1..
,0N
0 0 1 1 0 1 2 0 1 3 0 1 4 0 1 5 0 1 6 0 1 7 0 1 8 0 1 9 0 1 10 0 1 11 0 1 12 0 1 13 0 1 14 0 1 15 ..
```
We update the iteration continuation flag based on whether the VM halted:
```q
q)run:not .intcode.isTerminated a
q)run
1b
```
We extract the paint instructions from the output as in part 1:
```q
q)paint:3 cut .intcode.getOutput a
q)paint
0  0 1
1  0 1
2  0 1
3  0 1
4  0 1
5  0 1
6  0 1
..
```
If the grid is not yet initialized, we initialize it by checking the maximum coordinates of the
paint instructions. The coordinates are in the opposite order, and the size is the maximum
coordiante plus one:
```q
q)max[paint]
44 22 4
q)max[paint]1 0
22 44
q)1+max[paint]1 0
23 45
```
The `#` (take) operator is handy to initialize a multi-dimensional array with a repeated value:
```q
q)grid:(1+max[paint]1 0)#0
q)grid
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```
We perform the painting by repeatedly assigning to the items of the grid based on the paint
instructions, but only those where the x coordinate is greater than -1. This requires using the `/`
(over) iterator since the results of the previous assignments should be maintained:
```q
q)grid:{x[y[1];y[0]]:y[2];x}/[grid;paint where -1<first each paint]
q)grid
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 2 2 0 0 0 0 2 2 2 2 0 2 2 2 2 2 0 2 0 0 2 2 0 2 0 0 0 2 2 2 2 0 2 2 2 0 0 2 2 2 0 0 1
1 0 0 0 2 0 2 2 0 0 0 2 2 0 2 2 0 0 2 0 0 0 2 0 2 2 0 0 2 0 0 0 2 0 0 0 2 0 2 0 0 0 2 0 1
1 0 2 2 2 0 2 2 2 2 0 0 2 0 2 2 0 0 2 0 0 2 0 2 2 2 2 0 2 0 2 0 0 2 2 2 0 0 2 0 0 0 2 0 1
1 0 2 0 2 0 2 2 0 0 0 0 2 2 2 2 0 0 0 2 2 2 2 2 2 2 2 2 2 2 0 0 0 0 0 0 2 0 0 2 0 0 2 0 1
1 0 0 2 0 2 2 2 0 0 0 2 2 0 0 0 2 2 0 0 0 2 0 0 2 2 0 2 0 0 0 2 2 2 2 0 2 0 2 0 0 2 0 0 1
1 0 2 2 0 2 2 0 2 2 0 0 0 2 2 2 0 2 0 0 2 2 0 2 0 2 2 0 2 2 0 2 0 2 2 2 2 0 0 0 2 2 0 0 1
1 0 2 2 0 2 0 0 2 2 0 0 2 0 0 2 2 0 0 2 2 2 2 2 2 2 0 0 0 2 2 2 2 2 0 0 0 2 0 0 2 2 2 0 1
1 0 2 2 2 0 0 0 0 2 0 0 0 2 2 2 0 0 2 2 0 0 0 0 0 2 2 0 2 2 0 2 0 2 2 0 2 0 2 2 0 0 0 0 1
1 0 0 2 0 2 0 2 0 0 0 0 2 0 0 2 0 2 0 0 0 0 0 2 0 2 2 2 2 2 0 2 2 0 2 2 0 2 0 2 2 2 0 0 1
1 0 2 2 0 0 0 2 2 0 2 2 0 0 0 2 2 2 2 0 0 0 2 2 2 0 0 0 0 2 2 2 2 2 0 0 2 2 0 2 2 2 2 0 1
1 0 2 0 0 2 2 2 0 0 2 0 2 0 2 0 2 2 0 2 0 2 0 2 2 2 2 2 2 2 0 2 0 0 2 0 2 0 2 2 2 2 0 0 1
1 0 0 0 0 2 2 0 0 0 0 0 0 0 2 2 2 0 2 2 0 2 0 2 0 0 2 2 0 2 2 2 0 2 2 0 0 2 0 2 0 2 0 0 1
1 0 2 0 2 2 0 2 2 0 0 2 0 0 0 2 0 0 2 2 0 2 0 2 0 0 2 2 0 2 0 2 0 2 2 2 0 0 2 0 2 2 2 0 1
1 0 2 0 2 2 0 2 2 2 0 0 2 0 0 2 2 2 2 2 0 0 2 2 0 2 2 2 0 0 0 2 2 2 2 2 0 2 0 2 2 2 0 0 1
1 0 0 0 0 0 2 2 0 2 2 0 2 0 2 2 2 0 0 2 0 2 0 0 2 0 2 2 0 2 2 2 2 0 0 0 2 2 2 0 0 2 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
```
For the score, we look at the paint instruction with x coordinate -1 and take the last element. We
max it with the existing score, which handles the case when no score is printed.
```q
q)score:max score,last last paint where -1=first each paint
q)score
0
```
It is useful to visualize the grid using ASCII characters. This can be done by applying the grid as
an index to a list of characters containing the visual representations. Because of the atomic
property of indexing, this returns an array with the same shape as the index and each element
replaced with the corresponding element from the source list.
```q
q)" +#=*"grid
"+++++++++++++++++++++++++++++++++++++++++++++"
"+                                           +"
"+ ##    #### ##### #  ## #   #### ###  ###  +"
"+   # ##   ## ##  #   # ##  #   #   # #   # +"
"+ ### ####  # ##  #  # #### # #  ###  #   # +"
"+ # # ##    ####   ###########      #  #  # +"
"+  # ###   ##   ##   #  ## #   #### # #  #  +"
"+ ## ## ##   ### #  ## # ## ## # ####   ##  +"
"+ ## #  ##  #  ##  #######   #####   #  ### +"
"+ ###    #   ###  ##     ## ## # ## # ##    +"
"+  # # #    #  # #     # ##### ## ## # ###  +"
"+ ##   ## ##   ####   ###    #####  ## #### +"
"+ #  ###  # # # ## # # ####### #  # # ####  +"
"+    ##       ### ## # #  ## ### ##  # # #  +"
"+ # ## ##  #   #  ## # #  ## # # ###  # ### +"
"+ # ## ###  #  #####  ## ###   ##### # ###  +"
"+     ## ## # ###  # #  # ## ####   ###  #  +"
"+                                           +"
"+                                           +"
"+                    *                      +"
"+                                           +"
"+                    =                      +"
"+                                           +"
```
Applying the number -1 to a list of strings prints them to the standard output, which is a useful
way to print diagnostic info from the middle of a function while it is running:
```q
q)-1 " +#=*"grid; -1"Score: ",string score;
+++++++++++++++++++++++++++++++++++++++++++++
+                                           +
+ ##    #### ##### #  ## #   #### ###  ###  +
+   # ##   ## ##  #   # ##  #   #   # #   # +
+ ### ####  # ##  #  # #### # #  ###  #   # +
+ # # ##    ####   ###########      #  #  # +
+  # ###   ##   ##   #  ## #   #### # #  #  +
+ ## ## ##   ### #  ## # ## ## # ####   ##  +
+ ## #  ##  #  ##  #######   #####   #  ### +
+ ###    #   ###  ##     ## ## # ## # ##    +
+  # # #    #  # #     # ##### ## ## # ###  +
+ ##   ## ##   ####   ###    #####  ## #### +
+ #  ###  # # # ## # # ####### #  # # ####  +
+    ##       ### ## # #  ## ### ##  # # #  +
+ # ## ##  #   #  ## # #  ## # # ###  # ### +
+ # ## ###  #  #####  ## ###   ##### # ###  +
+     ## ## # ###  # #  # ## ####   ###  #  +
+                                           +
+                                           +
+                    *                      +
+                                           +
+                    =                      +
+                                           +
Score: 0
```
We find the horizontal coordinate of the ball by looking for block type 4 in the grid:
```q
q)ballPos:first raze where each grid=4
q)ballPos
21
```
We do the same for the paddle, which has block type 3:
```q
q)paddlePos:first raze where each grid=3
q)paddlePos
21
```
To track the ball, we set the input to the signum of the difference between the ball position and
the paddle position:
```q
q)input:enlist signum ballPos-paddlePos
q)input
,0i
```
This is the end of the iteration block.

Once the iteration is over, the `score` variable contains the final score:
```q
q)score
15973
```

## Whiteboxing
### Part 1
The blocks are stored in plain sight in the code. They are always at the same offset but the board
size may be different. The board size also appears at fixed offsets in the code.

We extract the width and height:
```q
q)a:"J"$","vs raze x
q)w:a 49; h:a 60;
q)(w;h)
45 23
```
Then fetch the board and cut it to the right shape:
```q
q)board:w cut (w*h)#639_a
q)board
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 2 2 0 0 0 0 2 2 2 2 0 2 2 2 2 2 0 2 0 0 2 2 0 2 0 0 0 2 2 2 2 0 2 2 2 0 0 2 2 2 0 0 1
1 0 0 0 2 0 2 2 0 0 0 2 2 0 2 2 0 0 2 0 0 0 2 0 2 2 0 0 2 0 0 0 2 0 0 0 2 0 2 0 0 0 2 0 1
1 0 2 2 2 0 2 2 2 2 0 0 2 0 2 2 0 0 2 0 0 2 0 2 2 2 2 0 2 0 2 0 0 2 2 2 0 0 2 0 0 0 2 0 1
1 0 2 0 2 0 2 2 0 0 0 0 2 2 2 2 0 0 0 2 2 2 2 2 2 2 2 2 2 2 0 0 0 0 0 0 2 0 0 2 0 0 2 0 1
1 0 0 2 0 2 2 2 0 0 0 2 2 0 0 0 2 2 0 0 0 2 0 0 2 2 0 2 0 0 0 2 2 2 2 0 2 0 2 0 0 2 0 0 1
1 0 2 2 0 2 2 0 2 2 0 0 0 2 2 2 0 2 0 0 2 2 0 2 0 2 2 0 2 2 0 2 0 2 2 2 2 0 0 0 2 2 0 0 1
1 0 2 2 0 2 0 0 2 2 0 0 2 0 0 2 2 0 0 2 2 2 2 2 2 2 0 0 0 2 2 2 2 2 0 0 0 2 0 0 2 2 2 0 1
1 0 2 2 2 0 0 0 0 2 0 0 0 2 2 2 0 0 2 2 0 0 0 0 0 2 2 0 2 2 0 2 0 2 2 0 2 0 2 2 0 0 0 0 1
1 0 0 2 0 2 0 2 0 0 0 0 2 0 0 2 0 2 0 0 0 0 0 2 0 2 2 2 2 2 0 2 2 0 2 2 0 2 0 2 2 2 0 0 1
1 0 2 2 0 0 0 2 2 0 2 2 0 0 0 2 2 2 2 0 0 0 2 2 2 0 0 0 0 2 2 2 2 2 0 0 2 2 0 2 2 2 2 0 1
1 0 2 0 0 2 2 2 0 0 2 0 2 0 2 0 2 2 0 2 0 2 0 2 2 2 2 2 2 2 0 2 0 0 2 0 2 0 2 2 2 2 0 0 1
1 0 0 0 0 2 2 0 0 0 0 0 0 0 2 2 2 0 2 2 0 2 0 2 0 0 2 2 0 2 2 2 0 2 2 0 0 2 0 2 0 2 0 0 1
1 0 2 0 2 2 0 2 2 0 0 2 0 0 0 2 0 0 2 2 0 2 0 2 0 0 2 2 0 2 0 2 0 2 2 2 0 0 2 0 2 2 2 0 1
1 0 2 0 2 2 0 2 2 2 0 0 2 0 0 2 2 2 2 2 0 0 2 2 0 2 2 2 0 0 0 2 2 2 2 2 0 2 0 2 2 2 0 0 1
1 0 0 0 0 0 2 2 0 2 2 0 2 0 2 2 2 0 0 2 0 2 0 0 2 0 2 2 0 2 2 2 2 0 0 0 2 2 2 0 0 2 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
```
As with the regular part 1, we add up the number of 2's in the matrix.
```q
q)sum sum 2=board
329i
```

## Part 2
The scores are also stored as literal data in the code. However, there are scores for tiles which
are not breakable blocks, which we need to avoid counting. Furthermore, the scores are not in
reading order. Instead the following formula is used to determine which score position corresponds
to which block coordinate:
```
(((cx+cy*h)*da)+db)mod w*h
```
where `cx` and `cy` are the block coordinates and `da` and `db` are constants that vary between
inputs.

Picking up from part 2 we find all the block coordinates using 2D search:
```q
q)block:raze til[h],/:'where each board=2
q)block
2 2
2 3
2 8
2 9
2 10
2 11
2 13
2 14
2 15
2 16
..
```
We find the constants, which are part of either a MUL or ADD instruction, and either the first or
second argument so we need to ignore any 0 and 1.
```q
q)da:first a[612 613]except 0 1
q)da
521
q)db:first a[616 617]except 0 1
q)db
730
```
We apply the formula to each block coordinate to find the score offset. Note that this is a vector
operation.
```q
q)off:(((block[;0]+block[;1]*h)*da)+db)mod w*h
q)off
898 461 346 944 507 70 231 829 392 990 553 714 438 ..
```
Finally we sum up the scores from the corresponding code locations.
```q
q)sum a(639+w*h)+off
15973
```
