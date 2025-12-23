# Breakdown
Example input:
```q
x:("R75,D30,R83,U83,L12,D49,R71,U7,L72";"U62,R66,U55,R34,D71,R55,D58,R83")
```

## Common
The common function returns every coordinate along a path. First we cut the input lines on commas -
this needs to be done with `/:` (each-right) to make sure it applies to each line.
```q
q)a:","vs/:x
q)a
("R75";"D30";"R83";"U83";"L12";"D49";"R71";"U7";"L72")
("U62";"R66";"U55";"R34";"D71";"R55";"D58";"R83")
```
Both paths are traced the same way, so we can use a function with each to process them. This is how
the function works on the first line:
```q
q)x:("R75";"D30";"R83";"U83";"L12";"D49";"R71";"U7";"L72")
```
We take the first character of every string, which are the directions:
```q
q)x[;0]
"RDRULDRUL"
```
Then we map these to movement vectors. The vectors are in a dictionary with the direction as key and
the coordinates as value:
```q
q)"URDL"!(0 -1;1 0;0 1;-1 0)
U| 0  -1
R| 1  0
D| 0  1
L| -1 0
```
Invoking the dictionary with the list of directions as an argument results in a list of the
coordinates corresponding to each direction:
```q
q)("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]
1  0
0  1
1  0
0  -1
-1 0
0  1
1  0
0  -1
-1 0
```
Now we want to duplicate every coordinate by the number of steps. To do this first we chop off the
direction from the instructions, leaving the number:
```q
q)1_/:x
"75"
"30"
"83"
"83"
"12"
"49"
"71"
,"7"
"72"
```
Then we convert these strings to numbers:
```q
q)("J"$1_/:x)
75 30 83 83 12 49 71 7 72
```
As now we have two lists, one with the step counts and one with the direction vectors, we would like
to apply "duplication" pairwise between the two lists. The [`#`
(take)](https://code.kx.com/q/ref/take/) operator can do duplication as long as the right argument
is a one-element list. In q the main way to create a one-element list is the `enlist` function.
Since we want each element to be put in its own list instead of just creating a wrapper around the
whole list, we use `enlist each`.
```q
q)enlist each("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]
1 0
0 1
1 0
0 -1
-1 0
0 1
1 0
0 -1
-1 0
```
(Visually not distinct from the un-enlisted version but the actual types are not the same.)

Now we can do the pairwise duplication. The `#` operator must be modified with `'` (general "each"
iterator) so that it applies pairwise, rather than on the entire lists.
```q
q)("J"$1_/:x)#'enlist each("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]
(1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;..
(0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;..
(1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;1 0;..
(0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0..
(0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;0 1;..
(0 -1;0 -1;0 -1;0 -1;0 -1;0 -1;0 -1)
(-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-1 0;-..
```
There are so many steps that they don't fit on the screen, but they have been duplicated exactly by
the number of steps for the respective instruction. Now we raze all of this into a single list:
```q
q)raze("J"$1_/:x)#'enlist each("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]
1  0
1  0
1  0
..
1  0
1  0
0  1
0  1
0  1
0  1
..
```
And another neat q trick is to get the [partial sums](https://code.kx.com/q/ref/sum/#sums) of this
list, which results in the list of the visited coordinates:
```q
q)sums raze("J"$1_/:x)#'enlist each("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]
1   0
2   0
3   0
4   0
5   0
6   0
..
149 -11
148 -11
147 -11
146 -11
145 -11
```
Remember that this was all part of a function that we apply to both sets of instructions:
```q
q)a:","vs/:"\n"vs"R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83"
q){sums raze("J"$1_/:x)#'enlist each("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]}each a
(1 0;2 0;3 0;4 0;5 0;6 0;7 0;8 0;9 0;10 0;11 0;12 0;13 0;14 0;15 0;16 0;17 0;18 0;19 0;..
(0 -1;0 -2;0 -3;0 -4;0 -5;0 -6;0 -7;0 -8;0 -9;0 -10;0 -11;0 -12;0 -13;0 -14;0 -15;0 -16..
```
Now we have our helper function `d3`, which parses the input and traces both paths.

## Part 1
First we generate the paths:
```q
q)b:d3("R75,D30,R83,U83,L12,D49,R71,U7,L72";"U62,R66,U55,R34,D71,R55,D58,R83")
q)b
(1 0;2 0;3 0;4 0;5 0;6 0;7 0;8 0;9 0;10 0;11 0;12 0;13 0;14 0;15 0;16 0;17 0;18 0;19 0;..
(0 -1;0 -2;0 -3;0 -4;0 -5;0 -6;0 -7;0 -8;0 -9;0 -10;0 -11;0 -12;0 -13;0 -14;0 -15;0 -16..
```
We check the intersections using the [intersection](https://code.kx.com/q/ref/inter/) operator:
```q
q)b[0] inter b[1]
158 12
146 -46
155 -4
155 -11
```
To get the distance from the origin, first we take the absolute values of the coordinates:
```q
q)abs b[0] inter b[1]
158 12
146 46
155 4
155 11
```
Then we add them together. Note the use of `sum each`, instead of just `sum`, which would add the
matching coordinates of the different points together, while we actually want to add together the
two coordinates of the same point.
```q
q)sum each abs b[0] inter b[1]
170 192 159 166
```
The answer is the minimum of this list.
```q
q)min sum each abs b[0] inter b[1]
159
```

## Part 2
We start by getting the intersections again:
```q
q)b[0] inter b[1]
158 12
146 -46
155 -4
155 -11
```
Now we want to find each intersection in both paths. The [`?`](https://code.kx.com/q/ref/find/)
operator can do this find operation, however since we have a lists of lists to search in, we need to
use the `\:` (each-left) iterator such that it will search in both lists. Using it without `\:`
would mean it would compare the whole paths to the intersections, which wouldn't match.
```q
q)b?\:b[0]inter b[1]
205 289 340 471
403 333 384 377
```
This returns the number of steps until each intersection. However we also need to count the starting
point so we add 1 to each element (+ is atomic so no iterator needed):
```q
q)1+b?\:b[0]inter b[1]
206 290 341 472
404 334 385 378
```
Then we add together the two lists, so each element in the result will be the total steps across
both paths to reach that particular intersection:
```q
q)sum 1+b?\:b[0]inter b[1]
610 624 726 850
```
The final answer is the minimum of these step counts:
```q
q)min sum 1+b?\:b[0]inter b[1]
610
```
