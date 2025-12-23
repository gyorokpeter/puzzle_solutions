# Breakdown
Example input:
```q
q)md5 raze x
0xfee5630062bdc7f1f4cabf87c33862c9
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Part 1
We initialize the intcode interpreter:
```q
q)a:.intcode.new x
```
We run the program with all coordinates from 0 0 to 49 49:
```q
q)r:raze .intcode.getOutput each .intcode.runI[a;]each raze {x,\:/:x}til 50
q)r
1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
```
We sum the results:
```q
q)sum r
181
```

## Part 2
The function takes an extra parameter for the size of the target square:
```q
q)sqsz:100
```
We initialize the intcode interpreter:
```q
q)a:.intcode.new x
```
We set a variable for the size, to make sure the same value is used everywhere:
```q
q)size:10
```
We calculate the top left of the grid up to the desired size:
```q
q)grid:size cut raze .intcode.getOutput each .intcode.runI[a;]each raze {x,\:/:x}til size
q)grid
1 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0
0 0 1 0 0 0 0 0 0 0
0 0 1 0 0 0 0 0 0 0
0 0 0 1 0 0 0 0 0 0
0 0 0 1 0 0 0 0 0 0
0 0 0 0 1 0 0 0 0 0
0 0 0 0 1 0 0 0 0 0
```
We find the first and last position in the last row that is part of the beam:
```q
q)sqsz:100
q)minx:first where last grid
q)maxx:last where last grid
q)minx
4
q)maxx
4
```
We also store the full X and Y coordinates of these positions:
```q
q)minPos:(minx;size-1)
q)maxPos:(maxx;size-1)
q)minPos
4 9
q)maxPos
4 9
```
We create a list of historical maximum X coordinates. The initial values are all zeros, except the
last one which is the one we found in the last row.
```q
q)maxxs:((sqsz-1)#0), maxx
q)maxxs
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
```
We start an iteration, which runs until a flag is false.
```q
q)run:1b
    while[run;
        ...
    ];
```
Inside the iteration, we start by moving the minimum position down one row:
```q
q)minPos+:0 1
q)minPos
4 10
```
We run the intcode program on this position. If we find that the position is not in the beam, we
increment the X coordinate and try again until it is.
```q
q)minPos+:0 1
q)minPos
4 10
q)r:last .intcode.getOutput .intcode.runI[a;minPos]
q)while[not r; minPos+:1 0;r:last .intcode.getOutput .intcode.runI[a;minPos]]
q)minPos
4 10
```
We do the same process to find the last position that is still inside the beam. Instead of just
scanning from `minPos`, we again start by incrementing Y coordinate of the previous `maxPos`. But
this means we do have to find a position inside the beam first, because it is possible that there
is no overlap between the beam positions between consecutive rows. Also we are looking at an
inclusive max position, so we step back once we move off the beam.
```q
q)maxPos+:0 1
q)maxPos
4 10
q)r:last .intcode.getOutput .intcode.runI[a;maxPos]
q)while[not r; maxPos+:1 0;r:last .intcode.getOutput .intcode.runI[a;maxPos]]
q)while[r; maxPos+:1 0;r:last .intcode.getOutput .intcode.runI[a;maxPos]]
q)maxPos-:1 0
q)maxPos
5 10
```
We roll the history of maximum positions by removing the first element and appending the current
maximum position:
```q
q)maxxs:1_maxxs,first maxPos
q)-10#maxxs
0 0 0 0 0 0 0 0 4 5
```
We find the size of the maximum square by checking the top right corner (which is the first element
in the history) and subtracting the current
minimum position:
```q
q)maxsq:1+first[maxxs]-first[minPos]
q)maxsq
-3
```
We check if the square size is enough to meet our goal. If so, we store the coordinates of the top
left corner and set the run flag to false.
```q
    if[maxsq>=sqsz; found:(minPos[0];minPos[1]-sqsz-1); run:0b]
```
This ends the iteration code.

At the end of the iteration, we have the top left coordinates of the square in the `found` variable:
```q
q)found
424 964
```
We transform the coordinates as requested in the puzzle:
```q
q)sum found*10000 1
4240964
```

## Whiteboxing
The program calculates the following to decide whether a coordinate is a beam tile:
```
    1-(cx*cy*dz)<abs[(cy*cy*dy)-cx*cx*dx]
```
Where `cx` and `cy` are the X and Y coordinate inputs, and `dx`, `dy` and `dz` are constants that
change between puzzle inputs.

We can rearrange this to eliminate the absolute value and get two simultaneous inequalities instead:
```
    ((cx*cy*dz)>=(cy*cy*dy)-cx*cx*dx)and
    (cx*cy*dz)>=(cx*cx*dx)-cy*cy*dy
```
Given a fixed `cy`, the first inequality puts a lower bound on `cx` and the second inequality puts
an upper bound on it. Notice that these are quadratic inequalities both in `cx` and `cy`. We can use
the solution formula to get a closed form to calculate both bounds for `cx`:
```q
    minx0:{[dx;dy;dz;cy]ceiling((neg[cy*dz])+sqrt[(cy*dz*cy*dz)+4*dx*cy*cy*dy])%2*dx};
    maxx0:{[dx;dy;dz;cy]floor((neg[cy*dz])-sqrt[(cy*dz*cy*dz)+4*dx*cy*cy*dy])%2*neg dx};
```
This is very advantageous because we can use these as vector formulas to calculate the bounds for a
large number of `cy` values at the same time. This makes both parts very trivial.

### Part 1
We extract the constants from the code:
```q
q)a:"J"$","vs raze x
q)dx:first a[81 82]except 0 1
q)dy:first a[123 124]except 0 1
q)dz:first a[161 162]except 0 1
q)(dx;dy;dz)
97 21 14
```
We make a list of y coordinates up to 50:
```q
q)cy:til 50
q)cy
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 ..
```
We find the lower and upper bounds for x using the formulas:
```q
q)minx:ceiling((neg[cy*dz])+sqrt[(cy*dz*cy*dz)+4*dx*cy*cy*dy])%2*dx
q)minx
0 1 1 2 2 2 3 3 4 4 4 5 5 6 6 6 7 7 8 8 8 9 9 10 10 10 11 11 12 12 12 13 13 14 14 14 15 15 16 16 1..
q)maxx:floor((neg[cy*dz])-sqrt[(cy*dz*cy*dz)+4*dx*cy*cy*dy])%2*neg dx
q)maxx
0 0 1 1 2 2 3 3 4 4 5 5 6 7 7 8 8 9 9 10 10 11 11 12 13 13 14 14 15 15 16 16 17 17 18 19 19 20 20 ..
```
The number of beam tiles is the difference between the two lists plus one for each row.
```q
q)1+maxx-minx
1 0 1 0 1 1 1 1 1 1 2 1 2 2 2 3 2 3 2 3 3 3 3 3 4 4 4 4 4 4 5 4 5 4 5 6 5 6 5 6 6 6 6 6 6 7 6 7 7 7
q)sum 0|1+maxx-minx
181
```

### Part 2
We can use the formulas above to generate lots of minimum and maximum X coordinates. A while loop
can be used to ensure there is no bound to the amount of numbers generated.

Given the amount of numbers to generate as `cc`:
```q
q)cc:sqsz
```
We generate the left bounds of the intervals (square size-1) ahead:
```q
q)cyl:(sqsz-1)+til[cc]
q)cyl
99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123..
```
And the right bounds starting from row 0:
```q
q)minx:ceiling((neg[cyl*dz])+sqrt[(cyl*dz*cyl*dz)+4*dx*cyl*cyl*dy])%2*dx
q)maxx:floor((neg[cyr*dz])-sqrt[(cyr*dz*cyr*dz)+4*dx*cyr*cyr*dy])%2*neg dx
q)minx
40 40 41 41 42 42 42 43 43 44 44 44 45 45 46 46 46 47 47 48 48 48 49 49 50 50 50 51 51 52 52 52 53..
q)maxx
0 0 1 1 2 2 3 3 4 4 5 5 6 7 7 8 8 9 9 10 10 11 11 12 13 13 14 14 15 15 16 16 17 17 18 19 19 20 20 ..
```
We iterate this until the difference between the bounds is greater than the square size:
```q
    while[sqsz>last[maxx]-last[minx];
        ...
    ];
```
Once we have enough numbers, the coordinates can be found by checking the difference between the
right and left bounds (plus 1 for each row) and finding where the square size first appears.
```q
q)ry:first where (sqsz-1)<=maxx-minx
q)ry
964
q)rx:minx ry
q)rx
424
q)ry+10000*rx
4240964
```
