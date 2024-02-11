# Breakdown
Example input: not pasting it in as it's too long, but the start and end would look like
```q
x:"--- scanner 0 ---\n"
x,:"404,-588,-901\n"
..
x,:"-652,-548,-490\n"
x,:"30,-46,-14\n"
```

## Common

We split on double-newlines to find the boundaries of the scanners:
```q
q)"\n\n"vs x
"--- scanner 0 ---\n404,-588,-901\n528,-643,409\n-838,591,734\n390,-675,-793\..
"--- scanner 1 ---\n686,422,578\n605,423,415\n515,917,-361\n-336,658,858\n95,..
"--- scanner 2 ---\n649,640,665\n682,-795,504\n-784,533,-524\n-644,584,-595\n..
"--- scanner 3 ---\n-589,542,597\n605,-692,669\n-500,565,-823\n-660,373,557\n..
"--- scanner 4 ---\n727,592,562\n-293,-554,779\n441,611,-461\n-714,465,-776\n..
```
We split each sensor's output on newlines:
```q
q)"\n"vs/:"\n\n"vs x
("--- scanner 0 ---";"404,-588,-901";"528,-643,409";"-838,591,734";"390,-675,..
("--- scanner 1 ---";"686,422,578";"605,423,415";"515,917,-361";"-336,658,858..
("--- scanner 2 ---";"649,640,665";"682,-795,504";"-784,533,-524";"-644,584,-..
("--- scanner 3 ---";"-589,542,597";"605,-692,669";"-500,565,-823";"-660,373,..
("--- scanner 4 ---";"727,592,562";"-293,-554,779";"441,611,-461";"-714,465,-..
```
We drop the first element of each list to get rid of the "scanner" header:
```q
q)1_/:"\n"vs/:"\n\n"vs x
("404,-588,-901";"528,-643,409";"-838,591,734";"390,-675,-793";"-537,-823,-45..
("686,422,578";"605,423,415";"515,917,-361";"-336,658,858";"95,138,22";"-476,..
("649,640,665";"682,-795,504";"-784,533,-524";"-644,584,-595";"-588,-843,648"..
("-589,542,597";"605,-692,669";"-500,565,-823";"-660,373,557";"-458,-679,-417..
("727,592,562";"-293,-554,779";"441,611,-461";"-714,465,-776";"-743,427,-804"..
```
We split again, this time on commas and at a depth of two:
```q
q)","vs/:/:1_/:"\n"vs/:"\n\n"vs x
(("404";"-588";"-901");("528";"-643";"409");("-838";"591";"734");("390";"-675..
(("686";"422";"578");("605";"423";"415");("515";"917";"-361");("-336";"658";"..
(("649";"640";"665");("682";"-795";"504");("-784";"533";"-524");("-644";"584"..
(("-589";"542";"597");("605";"-692";"669");("-500";"565";"-823");("-660";"373..
(("727";"592";"562");("-293";"-554";"779");("441";"611";"-461");("-714";"465"..
```
We convert the numbers to integers:
```q
q)vecs:"J"$","vs/:/:1_/:"\n"vs/:"\n\n"vs x
q)vecs
(404 -588 -901;528 -643 409;-838 591 734;390 -675 -793;-537 -823 -458;-485 -3..
(686 422 578;605 423 415;515 917 -361;-336 658 858;95 138 22;-476 619 847;-34..
(649 640 665;682 -795 504;-784 533 -524;-644 584 -595;-588 -843 648;-30 6 44;..
(-589 542 597;605 -692 669;-500 565 -823;-660 373 557;-458 -679 -417;-488 449..
(727 592 562;-293 -554 779;441 611 -461;-714 465 -776;-743 427 -804;-660 -479..
```
Now we can start on actually looking for the solution. The goal is to normalize the lists of points
for each scanner so they are in the same orientation and origin. We consider scanner 0 to be
initially normalized. To find another scanner that shares 12 points, we first generate all 24
rotations of the points and take the pairwise differences. One of the orientations will have 132
shared differences (12*11 based on how we pick the two points). We make that direction the "main"
one for the second scanner and recalculate the point coordinates and the differences. Then to find
out the position of the scanner, we take the differences between the points from the two scanners.
The value that is most common will be the displacement between the two.

To generate all rotations of the coordinates, we use the idea described at
https://stackoverflow.com/questions/16452383/how-to-get-all-24-rotations-of-a-3-dimensional-array.
We need some helper variables:
```q
q)turn:(1 0 0;0 0 -1;0 1 0)
q)roll:(0 0 1;0 1 0;-1 0 0)
q)id:(1 0 0;0 1 0;0 0 1)
```
We define a helper function for integer matrix multiplication, just a wrapper around `mmu` which
only works on floats:
```q
q)immu:{`long$(`float$x)mmu`float$y}
```
We can generate all rotations by applying the `turn` and `roll` operations in the following
sequence:
```q
q)seq:(12#(roll;turn;turn;turn)),(roll;turn;roll),12#(roll;turn;turn;turn)
q)seq
0  0 1 0  1 0 -1 0 0
1 0 0  0 0 -1 0 1 0
1 0 0  0 0 -1 0 1 0
1 0 0  0 0 -1 0 1 0
0  0 1 0  1 0 -1 0 0
..
```
We generate a list of matrices to calculate the rotated values from the initial ones. To do that we 
start from the identity matrix and use `\` (scan) on the `immu` operation to multiply it by every
matrix in the sequence. Since we generate the same state more than once, we use `distinct` to remove
the duplicate states, and also remove any identities in the middle, instead putting one at the
beginning:
```q
q)ms:enlist[id],(distinct immu\[id;seq])except enlist id
q)ms
1 0 0    0 1 0    0 0 1
0  0 1   0  1 0   -1 0 0
0  1 0   0  0 -1  -1 0 0
0  0  -1 0  -1 0  -1 0  0
0  -1 0  0  0  1  -1 0  0
..
```
We define two more helper functions, one to generate the rotated versions of a list of vectors and
one to generate the pairwise differences between a list of vectors (excluding the self-differences).
Both of these make use of each-right and each-left applied together, first because we apply every
matrix to every vector, second because the differences are taken between every pair of vectors.
```q
q)makeRvecs:{[immu;ms;x]ms immu/:\:x}[immu;ms]
q)makeDirDiffs:{[x]{(raze x-/:\:x)except enlist 0 0 0}each x}
```
We generate the rotations of the initial vectors:
```q
q)rvecs:makeRvecs each vecs
q)rvecs
404  -588 -901 528  -643 409  -838 591  734  390  -675 -793 -537 -823 -458 -4..
686  422  578  605  423  415  515  917  -361 -336 658  858  95   138  22   -4..
649  640  665  682  -795 504  -784 533  -524 -644 584  -595 -588 -843 648  -3..
-589 542  597  605  -692 669  -500 565  -823 -660 373  557  -458 -679 -417 -4..
727  592  562  -293 -554 779  441  611  -461 -714 465  -776 -743 427  -804 -6..
```
We also generate the pairwise differences for these:
```q
q)dirdiffs:makeDirDiffs each rvecs
q)dirdiffs
-124  55    -1310 1242  -1179 -1635 14    87    -108  941   235   -443  889  ..
81    -1    163   171   -495  939   1022  -236  -280  591   284   556   1162 ..
-33   1435  161   1433  107   1189  1293  56    1260  1237  1483  17    679  ..
-1194 1234  -72   -89   -23   1420  71    169   40    -131  1221  1014  -101 ..
1020  1146  -217  286   -19   1023  1441  127   1338  1470  165   1366  1387 ..
```
We set up an iteration. Initially all scanners are assumed to be non-normalized except the first
one. We also track which ones are "checked", i.e. we have found all other scanners that can be
normalized by comparing to the base scanner. We also store the origin point for each scanner,
starting at 0 0 0, which will be moved as part of normalization.
```q
q)normalized:count[vecs]#0b;
q)normalized[0]:1b;
q)checked:count[vecs]#0b;
q)origin:count[vecs]#enlist 0 0 0;
```
We perform an iteration until there are no unnormalized scanners:
```q
    while[not all normalized;
```
We find a scanner that is normalized but not yet checked:
```q
q)checkInd:first where normalized and not checked
q)checkInd
0
```
We also find which scanners are not normalized so we can compare against them:
```q
q)otherInd:til[count vecs] except where normalized
q)otherInd
1 2 3 4
```
We compare how many common elements there are between the pairwise differences of the checked
scanner versus the other scanners. The result is a matrix with one row for each other scanner and
one column for each rotation.
```q
q)sim:count each/:dirdiffs[checkInd;0] inter/:/:dirdiffs[otherInd]
q)sim
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 132 0 0 2 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 6 0   0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0   0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 30 0 0 0 0   0 0 0 0
```
If there is an overlap, one of the rotations will have at least 132 (11*12) common differences. So
we find which other scanners have a common difference count of 132 or higher:
```q
q)matchInds:where (max each sim)>=132
q)matchInds
,0
```
If we found any matches, we can normalize one of the matching scanners.
```q
    if[0<count matchInds;
```
We pick the first one found - if there are multiple, the next iteration can pick them up anyway.
```q
q)matchInd:first matchInds
q)matchInd
0
```
We look at the matching difference counts again to find which direction we need to rotate in:
```q
q)matchDir:first where sim[matchInd]>=132
q)matchDir
19
```
We map back the original index of the sensor we are normalizing:
```q
q)realMatchInd:otherInd matchInd
q)realMatchInd
1
```
We update the vectors for the scanner to the rotated ones:
```q
q)vecs[realMatchInd]:rvecs[realMatchInd;matchDir]
q)vecs
(404 -588 -901;528 -643 409;-838 591 734;390 -675 -793;-537 -823 -458;-485 -3..
(-686 422 -578;-605 423 -415;-515 917 361;336 658 -858;-95 138 -22;476 619 -8..
(649 640 665;682 -795 504;-784 533 -524;-644 584 -595;-588 -843 648;-30 6 44;..
(-589 542 597;605 -692 669;-500 565 -823;-660 373 557;-458 -679 -417;-488 449..
(727 592 562;-293 -554 779;441 611 -461;-714 465 -776;-743 427 -804;-660 -479..
```
We generate the rotated vectors for this scanner again using the new coordinates:
```q
q)rvecs[realMatchInd]:makeRvecs vecs[realMatchInd]
q)rvecs
404  -588 -901 528  -643 409  -838 591  734  390  -675 -793 -537 -823 -458 -4..
-686 422  -578 -605 423  -415 -515 917  361  336  658  -858 -95  138  -22  47..
649  640  665  682  -795 504  -784 533  -524 -644 584  -595 -588 -843 648  -3..
-589 542  597  605  -692 669  -500 565  -823 -660 373  557  -458 -679 -417 -4..
727  592  562  -293 -554 779  441  611  -461 -714 465  -776 -743 427  -804 -6..
```
We also update the pairwise differences:
```q
q)dirdiffs[realMatchInd]:makeDirDiffs rvecs[realMatchInd];
q)dirdiffs
-124  55    -1310 1242  -1179 -1635 14    87    -108  941   235   -443  889  ..
-81   -1    -163  -171  -495  -939  -1022 -236  280   -591  284   -556  -1162..
-33   1435  161   1433  107   1189  1293  56    1260  1237  1483  17    679  ..
-1194 1234  -72   -89   -23   1420  71    169   40    -131  1221  1014  -101 ..
1020  1146  -217  286   -19   1023  1441  127   1338  1470  165   1366  1387 ..
```
We find the offset of the second scanner from the first one by looking at the most common difference
between the vectors in the two lists:
```q
q)vecs[realMatchInd]-/:\:vecs[checkInd]
-1090 1010 323    -1214 1065 -987   152   -169 -1312  -1076 1097 215    -149 ..
-1009 1011 486    -1133 1066 -824   233   -168 -1149  -995  1098 378    -68  ..
-919  1505 1262   -1043 1560 -48    323   326  -373   -905  1592 1154   22   ..
-68  1246 43      -192 1301 -1267   1174 67   -1592   -54  1333 -65     873  ..
-499 726  879     -623 781  -431    743  -453 -756    -485 813  771     442  ..
..
q)group raze vecs[realMatchInd]-/:\:vecs[checkInd]
-1090 1010 323  | ,0
-1214 1065 -987 | ,1
152   -169 -1312| ,2
..
-68   1246 43   | 9 29 62 75 139 201 257 303 394 456 499 605
..
q)count each group raze vecs[realMatchInd]-/:\:vecs[checkInd]
-1090 1010 323  | 1
-1214 1065 -987 | 1
152   -169 -1312| 1
..
-68   1246 43   | 12
..
q)desc count each group raze vecs[realMatchInd]-/:\:vecs[checkInd]
-68   1246 43   | 12
-1090 1010 323  | 1
-1214 1065 -987 | 1
..
q)move:first key desc count each group raze vecs[realMatchInd]-/:\:vecs[checkInd]
q)move
-68 1246 43
```
We update the origin of the normalized scanner:
```q
q)origin[realMatchInd]:move
```
We also move the coordinates for this scanner by subtracting the offset:
```q
q)vecs[realMatchInd]:vecs[realMatchInd]-\:move
```
Finally we mark the scanner as normalized:
```q
q)normalized[realMatchInd]:1b
```
This ends the normalization operation.
```q
    ];
```
If we didn't find any (other) scanners that could be normalized, we instead mark the scanner as
checked, so we won't try with this one again:
```q
q)if[0=count matchInds; checked[checkInd]:1b]
```

This ends the iteration.
```q
    ];
```

## Part 1
We raze the lists of coordinates and find how many distinct ones there are:
```q
q)count distinct raze vecs
79
```

## Part 2
We find the pairwise distances between the origins (scanner locations). We start on the coordinate
level, take the absolute values of the differences, sum the coordinates, and find the maximum.
```q
q)max sum each raze abs origin-/:\:origin
3621
```
