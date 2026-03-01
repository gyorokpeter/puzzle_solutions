# Breakdown
Example input:
```q
x:"\n"vs"pos=<0,0,0>, r=4\npos=<1,0,0>, r=1\npos=<4,0,0>, r=3\npos=<0,2,0>, r=1\npos=<0,5,0>, r=3";
x,:"\n"vs"pos=<0,0,3>, r=1\npos=<1,1,1>, r=1\npos=<1,1,2>, r=1\npos=<1,3,1>, r=1";
```

## Part 1
We split the input on `"<"` and take the last part to drop the prefix. We split on `">"` and take
the first part to drop the part after the coordinates. We split on `","` and convert to integer to
get the coordinates.
```q
q)ps:"J"$","vs/:first each">"vs/:last each "<"vs/:x
q)ps
0 0 0
1 0 0
4 0 0
0 2 0
0 5 0
0 0 3
1 1 1
1 1 2
1 3 1
```
We split on `"="` and keep the last part to keep only the ranges:
```q
q)rs:"J"$last each"="vs/:x
q)rs
4 1 3 1 3 1 1 1 1
```
We find the largest range by finding the maximum in the list:
```q
q)longest:first where rs=max rs
q)longest
0
```
To find the distances from each bot to the selected bot, we subtract the coordinates of the selected
bot from all the others with a `\:` (each-left):
```q
q)ps-\:ps longest
0 0 0
1 0 0
4 0 0
0 2 0
0 5 0
0 0 3
1 1 1
1 1 2
1 3 1
```
We take the absolute values and sum each list:
```q
q)sum each abs ps-\:ps longest
0 1 4 2 5 3 3 4 5
```
We compare these to the selected bot's range and sum the result to count the true values:
```q
q)(sum each abs ps-\:ps longest)<=rs longest
111101110b
q)sum(sum each abs ps-\:ps longest)<=rs longest
7i
```

## Part 2
I haven't found a portable solution to this part. The solutions on reddit either use a pre-built
linear algebra solver library (which I consider cheating) or are an incorrect solution that happened
to work on the poster's input but doesn't work on other inputs.

One promising solution was to transform the bot ranges into 4 dimensions by taking the bounding
planes of the octahedrons. It should then be possible to take the intersections between the
octahedrons like the intersection between cuboids. However, the poster then proceeded to build an
incorrect greedy algorithm on top of this that worked on their solution but not mine. I tried to
apply the same space partitioning method that I originally used for [2021 day 22](../2021/day22.md),
but in 4D space, the number of splits grows too quickly so it doesn't look feasible to finish in a
reasonable amount of time.

I have left in scraps of my experiments in the .q file in the commented section.

If you have a solution (in any interpreted language) that returns the correct answer for at least 5
different inputs AND it doesn't use a prebuilt "solver" library (using an algorithm that these
libraries would be used for but reimplementing it as part of the solution is okay), let me know and
I'll try to transform it into q.
