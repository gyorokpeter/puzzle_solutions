# Breakdown
Example input:
```q
x:()
x,:"\n"vs"position=< 9,  1> velocity=< 0,  2>\nposition=< 7,  0> velocity=<-1,  0>"
x,:"\n"vs"position=< 3, -2> velocity=<-1,  1>\nposition=< 6, 10> velocity=<-2, -1>"
x,:"\n"vs"position=< 2, -4> velocity=< 2,  2>\nposition=<-6, 10> velocity=< 2, -2>"
x,:"\n"vs"position=< 1,  8> velocity=< 1, -1>\nposition=< 1,  7> velocity=< 1,  0>"
x,:"\n"vs"position=<-3, 11> velocity=< 1, -2>\nposition=< 7,  6> velocity=<-1, -1>"
x,:"\n"vs"position=<-2,  3> velocity=< 1,  0>\nposition=<-4,  3> velocity=< 2,  0>"
x,:"\n"vs"position=<10, -3> velocity=<-1,  1>\nposition=< 5, 11> velocity=< 1, -2>"
x,:"\n"vs"position=< 4,  7> velocity=< 0, -1>\nposition=< 8, -2> velocity=< 0,  1>"
x,:"\n"vs"position=<15,  0> velocity=<-2,  0>\nposition=< 1,  6> velocity=< 1,  0>"
x,:"\n"vs"position=< 8,  9> velocity=< 0, -1>\nposition=< 3,  3> velocity=<-1,  1>"
x,:"\n"vs"position=< 0,  5> velocity=< 0, -1>\nposition=<-2,  2> velocity=< 2,  0>"
x,:"\n"vs"position=< 5, -2> velocity=< 1,  2>\nposition=< 1,  4> velocity=< 2,  1>"
x,:"\n"vs"position=<-2,  7> velocity=< 2, -2>\nposition=< 3,  6> velocity=<-1, -1>"
x,:"\n"vs"position=< 5,  0> velocity=< 1,  0>\nposition=<-6,  0> velocity=< 2,  0>"
x,:"\n"vs"position=< 5,  9> velocity=< 1, -2>\nposition=<14,  7> velocity=<-2,  0>"
x,:enlist"position=<-3,  6> velocity=< 2, -1>"
```

## Common
We use a helper function to find the moment where the message appears and the configuration of
positions at that moment.

We use some cutting to extract the numbers from the input:
```q
q)a:"J"$", "vs/:/:first each/:-1_/:/:1_/:">"vs/:/:"<"vs/:x
q)a
9 1   0 2
7  0  -1 0
3  -2 -1 1
6  10 -2 -1
2 -4  2 2
..
```
We extract the positions and speeds into different variables:
```q
q)pos:a[;0]
q)pos
9  1
7  0
3  -2
6  10
2  -4
..
q)spd:a[;1]
q)spd
0  2
-1 0
-1 1
-2 -1
2  2
..
```
We estimate how many turns it takes for the message to appear. This is based on some heuristics of
the input: the points start from far away coordinates, and if they are to concentrate near the
origin to form a message, their speeds should point in the opposite direction of their positions,
and the number of steps it takes them to reach the origin is roughly the time it takes for the
message to form. The value of `0w` (infinity) needs to be excluded because we get that for dividing
a positive value by zero (which only occurs in the example).
```q
q)turns:`long$max abs(pos[;0]%spd[;0])except 0w
q)turns
10
```
Since this was only an estimate, we generate the states of the points within a range around the
guessed turn, in this case 300 turns before up to 100 turns after (not tested what numbers work for
other inputs).
```q
q)states:pos+/:spd*/:turns+-300+til 400
q)states
9    -579 297  0    293  -292 586  300  -578 -584 -586 590  -289 298  -289 7    -293 591  297  296..
9    -577 296  0    292  -291 584  299  -576 -582 -584 588  -288 297  -288 7    -292 589  296  295..
9    -575 295  0    291  -290 582  298  -574 -580 -582 586  -287 296  -287 7    -291 587  295  294..
9    -573 294  0    290  -289 580  297  -572 -578 -580 584  -286 295  -286 7    -290 585  294  293..
9    -571 293  0    289  -288 578  296  -570 -576 -578 582  -285 294  -285 7    -289 583  293  292..
..
```
Another heuristic is that the turn containing the message will have the smallest bounding box out of
all the turns. So we calculate the differences between the maximum and minimum X coordinates in each
state:
```q
q)sizes:{max[x[;0]]-min x[;0]}each states
q)sizes
1181 1177 1173 1169 1165 1161 1157 1153 1149 1145 1141 1137 1133 1129 1125 1121 1117 1113 1109 110..
```
We find the index of which of these is minimal:
```q
q)delay:first where sizes=min sizes
q)delay
293
```
The return value is the state at the guessed turn and the delay from the start until that turn,
compensating for the offset used when calculating the states:
```q
q)(states delay;-300+turns+delay)
(9 7;4 0;0 1;0 7;8 2;0 4;4 5;4 7;0 5;4 3;1 3;2 3;7 0;8 5;4 4;8 1;9 0;4 6;8 6;0 6;0 2;4 2;8 4;7 7;4..
3
```

## Part 1
This uses a real input because the example input doesn't conform to the format of the real input.
```q
q)md5"\n"sv x
0x1ddb4f5314226cc92b6fe566a1d11a98
```
We call the helper function and keep only the first element of the result:
```q
q)st:first d10prep x
q)st
211 149
207 147
188 149
212 149
202 144
..
```
We shift the coordinates by subtracting the minimum X and Y coordinates among the points from each
of the points:
```q
q)st:st-\:(min st[;0];min[st[;1]])
q)st
44 9
40 7
21 9
45 9
35 4
..
```
We initialize a grid that is large enough to hold all the coordinates:
```q
q)grid:(1+max st[;0];1+max st[;1])#0
q)grid
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
..
```
We populate the grid using an iterated functional amend, then replace the numerical values with
graphical characters to make the grid more readable:
```q
q)msg:" #"flip 0<./[;;+;1][grid;st]
q)msg
"#####   #####     ##    #    #  ######  #         ##     #### "
"#    #  #    #   #  #   ##   #       #  #        #  #   #    #"
"#    #  #    #  #    #  ##   #       #  #       #    #  #     "
"#    #  #    #  #    #  # #  #      #   #       #    #  #     "
"#####   #####   #    #  # #  #     #    #       #    #  #     "
"#  #    #  #    ######  #  # #    #     #       ######  #     "
"#   #   #   #   #    #  #  # #   #      #       #    #  #     "
"#   #   #   #   #    #  #   ##  #       #       #    #  #     "
"#    #  #    #  #    #  #   ##  #       #       #    #  #    #"
"#    #  #    #  #    #  #    #  ######  ######  #    #   #### "
```
Many people will stop here and say that the answer is "RRANZLAC". However that is cheating as it is
using human brain power as a CAPTCHA recognizer. My solution goes all the way and reconstructs the
ASCII string that should be given as the puzzle answer. To do this, first we need to convert the
image into a list of letters. Right now each row is a scanline in the image. Since each character
is 6 pixels wide with a 2-pixel padding, if we cut the lines by 8 and take the first 6 elements,
we get the components of each letter:
```q
q)6#/:/:flip 8 cut/:msg
"##### " "#    #" "#    #" "#    #" "##### " "#  #  " "#   # " "#   # " "#    #" "#    #"
"##### " "#    #" "#    #" "#    #" "##### " "#  #  " "#   # " "#   # " "#    #" "#    #"
"  ##  " " #  # " "#    #" "#    #" "#    #" "######" "#    #" "#    #" "#    #" "#    #"
"#    #" "##   #" "##   #" "# #  #" "# #  #" "#  # #" "#  # #" "#   ##" "#   ##" "#    #"
"######" "     #" "     #" "    # " "   #  " "  #   " " #    " "#     " "#     " "######"
"#     " "#     " "#     " "#     " "#     " "#     " "#     " "#     " "#     " "######"
"  ##  " " #  # " "#    #" "#    #" "#    #" "######" "#    #" "#    #" "#    #" "#    #"
" #### " "#    #" "#     " "#     " "#     " "#     " "#     " "#     " "#    #" " #### "
```
By razing these lists, we get the linearized representations of each letter:
```q
q)letters:raze each 6#/:/:flip 8 cut/:msg
q)letters
"##### #    ##    ##    ###### #  #  #   # #   # #    ##    #"
"##### #    ##    ##    ###### #  #  #   # #   # #    ##    #"
"  ##   #  # #    ##    ##    ########    ##    ##    ##    #"
"#    ###   ###   ## #  ## #  ##  # ##  # ##   ###   ###    #"
"######     #     #    #    #    #    #    #     #     ######"
"#     #     #     #     #     #     #     #     #     ######"
"  ##   #  # #    ##    ##    ########    ##    ##    ##    #"
" #### #    ##     #     #     #     #     #     #    # #### "
```
We now have to map these to ASCII characters. This is a dictionary containing the letters that
occurred in my input:
```q
    ocr:enlist[""]!enlist"?";
    ocr["  ##   #  # #    ##    ##    ########    ##    ##    ##    #"]:"A";
    ocr[" #### #    ##     #     #     #     #     #     #    # #### "]:"C";
    ocr["#     #     #     #     #     #     #     #     #     ######"]:"L";
    ocr["#    ###   ###   ## #  ## #  ##  # ##  # ##   ###   ###    #"]:"N";
    ocr["##### #    ##    ##    ###### #  #  #   # #   # #    ##    #"]:"R";
    ocr["######     #     #    #    #    #    #    #     #     ######"]:"Z";
```
We can simply apply the dictionary to the linearized letters:
```q
q)ocr letters
"RRANZLAC"
```

## Part 2
We call the helper function and return the second element of the answer.
```q
q)last d10prep x
10942
```
(This also works on the example input and returns 3.)
