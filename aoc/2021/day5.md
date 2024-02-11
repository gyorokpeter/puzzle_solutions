# Breakdown
Example input:
```q
x:"0,9 -> 5,9\n8,0 -> 0,8\n9,4 -> 3,4\n2,2 -> 2,1\n7,0 -> 7,4\n6,4 -> 2,0\n0,9 -> 2,9\n3,4 -> 1,4"
x,:"\n0,0 -> 8,8\n5,5 -> 8,2"
```

## Part 1
We cut on lines, then cut each line on `" -> "`, then each sub-line on `","` and convert to integers.
We also sort to ensure that the coordinates go from left to right and top to bottom.
```q
q)a:asc each "J"$","vs/:/:" -> "vs/:"\n"vs x;
q)a
0 9 5 9
0 8 8 0
3 4 9 4
2 1 2 2
7 0 7 4
2 0 6 4
0 9 2 9
1 4 3 4
0 0 8 8
5 5 8 2
```
Then we filter horizontal and vertical lines based on where the first or second coordinates match.
```q
q)h:a where a[;0;1]=a[;1;1];
q)h
0 9 5 9
3 4 9 4
0 9 2 9
1 4 3 4
q)v:a where a[;0;0]=a[;1;0];
q)v
2 1 2 2
7 0 7 4
```
Then we generate the points on each line. The first step is to generate a sequence of numbers
matching the length of the line (1 plus the end point minus start point):
```q
q)1+h[;1;0]-h[;0;0]
6 7 3 3
q)til each 1+h[;1;0]-h[;0;0]
0 1 2 3 4 5
0 1 2 3 4 5 6
0 1 2
0 1 2
```
Then we add these to the start points and attach the fixed other coordinate:
```q
q)(h[;0;0]+til each 1+h[;1;0]-h[;0;0]),\:'h[;0;1]
(0 9;1 9;2 9;3 9;4 9;5 9)
(3 4;4 4;5 4;6 4;7 4;8 4;9 4)
(0 9;1 9;2 9)
(1 4;2 4;3 4)
q)hp:raze(h[;0;0]+til each 1+h[;1;0]-h[;0;0]),\:'h[;0;1];
q)hp
0 9
1 9
2 9
3 9
...
```
The generation of vertical lines is similar:
```q
q)vp:raze v[;0;0],/:'v[;0;1]+til each 1+v[;1;1]-v[;0;1];
q)vp
2 1
2 2
7 0
7 1
...
```
Finally we concatenate the two lists and check how many times each oint appears:
```q
q)group hp,vp
0 9| 0 13
1 9| 1 14
2 9| 2 15
3 9| ,3
...
q)count each group hp,vp
0 9| 2
1 9| 2
2 9| 2
3 9| 1
```
The answer is the number of entries where the number of occurrences is greater than 1.
```q
q)1<count each group hp,vp
0 9| 1
1 9| 1
2 9| 1
3 9| 0
...
sum 1<count each group hp,vp
5i
```

## Part 2
This solution would also work for part 1 after the filtering. However when reading part 1 I was
anticipating having to use GCD (greatest common divisor) for part 2 so I went with the
simpler solution for part 1 and I didn't feel like rewriting it afterwards.

The input parsing is the same as for part 1:
```q
q)a:asc each "J"$","vs/:/:" -> "vs/:"\n"vs x;
q)a
0 9 5 9
0 8 8 0
3 4 9 4
2 1 2 2
...
```
We will once again generate the list of points, but this time handling all the directions as a
single case. To do this we generate the direction vector for each line:
```q
q)diff:a[;1]-a[;0];
q)diff
5 0
8 -8
6 0
0 1
```
We also generate the unit vectors by dividing the vector by the coordinate with the greater
absolute value.
```q
q)dir:diff div max each abs diff
q)dir
1 0
1 -1
1 0
0 1
```
And the length itself by dividing the vector coordinates by the length.
```q
q)len:1+max each diff div dir
q)len
6 9 7 2 5 5 3 3 9 4
```
Once again we generate the list of numbers but this time we multiply them by the direction vector.
This requires an each-left inside an each since we want to multiply each direction vector by the
respective multipliers, but also each vector needs to be multiplied by all the multipliers in that
list.
```q
q)(til each len)*\:'dir
(0 0;1 0;2 0;3 0;4 0;5 0)
(0 0;1 -1;2 -2;3 -3;4 -4;5 -5;6 -6;7 -7;8 -8)
(0 0;1 0;2 0;3 0;4 0;5 0;6 0)
(0 0;0 1)
...
```
Like in part 1, we add the multiplied vectors to the start points:
```q
q)a[;0]+/:'(til each len)*\:'dir
(0 9;1 9;2 9;3 9;4 9;5 9)
(0 8;1 7;2 6;3 5;4 4;5 3;6 2;7 1;8 0)
(3 4;4 4;5 4;6 4;7 4;8 4;9 4)
(2 1;2 2)
...
```
And the rest plays out exactly like part 1.
```q
q)pts:raze a[;0]+/:'(til each len)*\:'dir
q)pts
0 9
1 9
2 9
3 9
q)sum 1<count each group pts
12i
```
