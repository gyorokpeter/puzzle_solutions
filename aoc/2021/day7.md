# Breakdown
Example input:
```q
x:"16,1,2,0,4,2,7,1,2,14"
```

## Common
Note that the input is an intcode program. This also relates to the title of the puzzle. However
this has no bearing on the solution.

## Part 1
We parse as a list of integers:
```q
q)a:"J"$","vs x;
q)a
16 1 2 0 4 2 7 1 2 14
```
We also generate the list of locations where the crabs can go, using a "til with min and max"
technique:
```q
q)lo:min a
q)lo
0
q)hi:max a
q)hi
16
q)dest:lo+til 1+hi-lo
q)dest
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
```
We calculate the costs, which are just the sums of the distance from each destination:
```q
q)abs a-/:dest
16 1  2  0  4  2  7 1  2  14
15 0  1  1  3  1  6 0  1  13
14 1  0  2  2  0  5 1  0  12
13 2  1  3  1  1  4 2  1  11
...
q)costs:sum each abs a-/:dest
q)costs
49 41 37 39 41 45 49 53 59 65 71 77 83 89 95 103 111
```
The answer is the minimum of these:
```q
q)min costs
37
```

## Part 2
Almost the same, the only difference is how the costs are calculated.

We still calculate the offsets:
```q
q)offs:abs a-/:dest
q)offs
16 1  2  0  4  2  7 1  2  14
15 0  1  1  3  1  6 0  1  13
14 1  0  2  2  0  5 1  0  12
13 2  1  3  1  1  4 2  1  11
```
We also find the longest distance any crab might need to travel:
```q
q)maxOffs:max max offs
q)maxOffs
16
```
Then we precalculate all the triangle numbers up to this point:
```q
q)cost:sums til 1+maxOffs
q)cost
0 1 3 6 10 15 21 28 36 45 55 66 78 91 105 120 136
```
The cost calculations are then just an indexing into this list:
```q
q)cost offs
136 1   3   0   10 3   28 1   3   105
120 0   1   1   6  1   21 0   1   91
105 1   0   3   3  0   15 1   0   78
91  3   1   6   1  1   10 3   1   66
...
q)costs:sum each cost offs
q)costs
290 242 206 183 170 168 176 194 223 262 311 370 439 518 607 707 817
q)min costs
168
```
