# Breakdown
Example input:
```q
x:"6,10\n0,14\n9,10\n0,3\n10,4\n4,11\n6,0\n6,12\n4,1\n0,13\n10,12\n3,4\n3,0";
x,:"\n8,4\n1,10\n2,14\n8,10\n9,0\n\nfold along y=7\nfold along x=5";
```

## Part 1
We cut the input on `"\n\n"` to get the two sections.

We cut the first section to lines and then cut each line on commas and convert them to integers.
```q
q)a:"\n\n"vs x;
q)dot:"J"$","vs/:"\n"vs a 0;
q)dot
6  10
0  14
9  10
...
```
We cut the second section to lines, cut on spaces and take the last element of each line, then
cut on `"="` and convert the first elements to symbols and the second elements to integers.
```q
q)ins:"SJ"$/:"="vs/:last each" "vs/:"\n"vs a 1;
q)ins
`y 7
`x 5
```
For part 1 only, we drop all the elements of the instructions except the first:
```q
q)if[part=1; ins:1#ins];
q)ins
`y 7
```
We process the instructions in an iterated function with `/` (over), using the version that iterates
on a list, which will be the list of instructions.

For example
```q
q)ins0:ins 0;
q)ins0
`y
7
```
We pick an index based on whether the coordinate is x or y using the ? ([find](https://code.kx.com/q/ref/find/)) operator:
```q
q)coord:`x`y?ins0[0];
q)coord
1
```
We find which dots need to be folded by comparing the respective coordinate to the number in the
instruction:
```q
q)ind:where dot[;coord]>ins0[1]
q)ind
0 1 2 5 7 9 10 14 15 16
```
We apply the instruction, which is equivalent to subtraction from 2 times the number in the
instruction. This operation can be conveniently expressed as a projection:
```q
    (2*ins0[1])-
```
The actual update is done using functional amend with the dot operator:
```q
q).[dot;(ind;coord);(2*ins0[1])-]
6  4
0  0
9  4
0  3
...
```
And since we want to get rid of duplicates, we apply "distinct" to the result:
```q
q)distinct .[dot;(ind;coord);(2*ins0[1])-]
6  4
0  0
9  4
...
```
For part 1, we return the number of dots here.
```q
    if[part=1; :count dot];
```

## Part 2
Since there is no working example provided for part 2, no intermediate results will be shown.
Picking up from the above (after doing all the instructions, not just the first one), we first
swap the two coordinates of each dot, just to make it look easier on screen when converting it to
a matrix:
```q
    dot:reverse each dot;
```
We convert the coordinate array into a dot matrix using functional amend. We start with an empty
matrix with a size enough to hold all the dots which is 1 plus the maximum of the coordinates:
```q
   (1+max dot)#0
   out:.[;;:;1]/[(1+max dot)#0;dot]
```
Then we cut the matrix into individual letters. We cut every line into segments of 5 items, only
keep the first 4 elements of each segment, then raze them together so each character is squashed to
a single array. We also convert each letter to an integer using the "interpret as base X" version
of [`sv`](https://code.kx.com/q/ref/sv/#base-to-integer):
```q
    letter:2 sv/:raze each 4#/:/:flip 5 cut/:out
```
And to output the result as a string rather than a matrix requiring human inspection, we use a
mapping on the integers. This was also not part of the problem specification so I had to hunt
together various inputs to find every character.

Looks like the folding instructions are the same for everyone, just the dots are different.
