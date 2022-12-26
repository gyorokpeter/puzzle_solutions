# Breakdown
Example input:
```q
x:"\n"vs"addx 15\naddx -11\naddx 6\naddx -3\naddx 5\naddx -1\naddx -8\naddx 13\naddx 4\nnoop\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx -35\naddx 1\naddx 24\naddx -19";
x,:"\n"vs"addx 1\naddx 16\naddx -11\nnoop\nnoop\naddx 21\naddx -15\nnoop\nnoop\naddx -3\naddx 9\naddx 1\naddx -3\naddx 8\naddx 1\naddx 5\nnoop\nnoop\nnoop\nnoop\nnoop\naddx -36\nnoop\naddx 1\naddx 7\nnoop";
x,:"\n"vs"noop\nnoop\naddx 2\naddx 6\nnoop\nnoop\nnoop\nnoop\nnoop\naddx 1\nnoop\nnoop\naddx 7\naddx 1\nnoop\naddx -13\naddx 13\naddx 7\nnoop\naddx 1\naddx -33\nnoop\nnoop\nnoop\naddx 2\nnoop\nnoop\nnoop";
x,:"\n"vs"addx 8\nnoop\naddx -1\naddx 2\naddx 1\nnoop\naddx 17\naddx -9\naddx 1\naddx 1\naddx -3\naddx 11\nnoop\nnoop\naddx 1\nnoop\naddx 1\nnoop\nnoop\naddx -13\naddx -19\naddx 1\naddx 3\naddx 26\naddx -30";
x,:"\n"vs"addx 12\naddx -1\naddx 3\naddx 1\nnoop\nnoop\nnoop\naddx -9\naddx 18\naddx 1\naddx 2\nnoop\nnoop\naddx 9\nnoop\nnoop\nnoop\naddx -1\naddx 2\naddx -37\naddx 1\naddx 3\nnoop\naddx 15\naddx -21\naddx 22";
x,:"\n"vs"addx -6\naddx 1\nnoop\naddx 2\naddx 1\nnoop\naddx -10\nnoop\nnoop\naddx 20\naddx 1\naddx 2\naddx 2\naddx -6\naddx -11\nnoop\nnoop\nnoop";
```

## Part 1
We cut the input lines on spaces:
```q
q)a:" "vs/:x
q)a
("addx";"15")
("addx";"-11")
("addx";,"6")
("addx";"-3")
("addx";,"5")
```
We get the run time of each instruction, which is 1 by default, plus 1 if the instruction is `addx`:
```q
q)t:1+a[;0]like"addx"
q)t
2 2 2 2 2 2 2 2 2 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 ..
```
We also get the register deltas (which will be invalid for `noop` instructions but they should still occupy their space):
```q
q)"J"$a[;1]
15 -11 6 -3 5 -1 -8 13 4 0N -1 5 ..
```
We calculate the values of the register by taking the partial sums from this list. We prepend a 1 to the list for the starting value.
```q
q)d
1 16 5 11 8 13 12 4 17 21 21 20 25 24 ..
```
We use the duplicating property of the `where` function to expand the register values for every timer tick:
```q
q)val:d where t;
q)val
1 1 16 16 5 5 11 11 8 8 13 13 12 12 4 4 17 17 21 21 21 20 20 25 25 24
..
```
We prepare a list of indices to sample:
```q
q)ind:20+40*til 6
q)ind
20 60 100 140 180 220
```
Finally we calculate the answer according to the instructions, using the register values in the given ticks:
```q
q)val ind-1
21 19 18 21 16 18
q)ind*val ind-1
420 1140 1800 2940 2880 3960
q)sum ind*val ind-1
13140
```

## Part 2
We pick up after the calculation of the register values (`val`). We calculate the position of the ray at every timer tick, by taking advantage of the wrap-around behavior of the `#` _take_ operator:
```q
q)240#til 40
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 0 1 2 3 4 5 6 7 ..
```
We subtract the beam position from the register value to see if they are close enough:
```q
q)val-240#til 40
1 0 14 13 1 0 5 4 0 -1 3 2 0 -1 -10 -11 1 0 3 2 1 -1 -2 2 1 -1 ..
```
The lit pixels are those where this difference is within -1 and 1:
```q
q)(val-240#til 40)within -1 1
110011001100110011001100110011001100110011100011100
```
We cut the pixels into rows of 40:
```q
q)r:40 cut (val-240#til 40)within -1 1;
q)r
1100110011001100110011001100110011001100b
1110001110001110001110001110001110001110b
1111000011110000111100001111000011110000b
1111100000111110000011111000001111100000b
1111110000001111110000001111110000001111b
1111111000000011111110000000111111100000b
q)-1 " #"r;
##  ##  ##  ##  ##  ##  ##  ##  ##  ##
###   ###   ###   ###   ###   ###   ###
####    ####    ####    ####    ####
#####     #####     #####     #####
######      ######      ######      ####
#######       #######       #######
```
The following part requires an actual input, as the example doesn't result in legible characters. Let's assume we got the following value for `r`:
```q
q)-1 " #"r;
###   ##  ###  ###  #  #  ##  ###    ##
#  # #  # #  # #  # # #  #  # #  #    #
#  # #    #  # ###  ##   #  # #  #    #
###  #    ###  #  # # #  #### ###     #
#    #  # #    #  # # #  #  # #    #  #
#     ##  #    ###  #  # #  # #     ##
```
We flip the array and cut to sublists of length 5 and raze them. This means each character will be an element in the list.
```q
q)raze each 5 cut flip r
111111100100100100011000000000b
011110100001100001010010000000b
111111100100100100011000000000b
111111101001101001010110000000b
111111001000010110100001000000b
011111100100100100011111000000b
111111100100100100011000000000b
000010000001100001111110000000b
```
We convert these "binary numbers" to integers for easier usage as dictionary indices.
```q
q)r2:2 sv/:raze each 5 cut flip r;
q)r2
1066550784 512103552 1066550784 1067881856 1059153984 529680320 1066550784 33955712
```
The final step requires a hardcoded lookup dictionary that maps the above numbers to the letters:
```q
.d10.ocr:()!();
.d10.ocr[529680320]:"A";
.d10.ocr[1067881856]:"B";
.d10.ocr[512103552]:"C";
.d10.ocr[1067882560]:"E";
.d10.ocr[1067616256]:"F";
.d10.ocr[512120256]:"G";
.d10.ocr[1059098560]:"H";
.d10.ocr[33955712]:"J";
.d10.ocr[1059153984]:"K";
.d10.ocr[1057230912]:"L";
.d10.ocr[1066550784]:"P";
.d10.ocr[1066559040]:"R";
.d10.ocr[1040457600]:"U";
.d10.ocr[597072960]:"Z";

q).d10.ocr r2
"PCPBKAPJ"
```
