# Breakdown
Example input:
```q
x:"\n"vs"2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n1,2,5\n3,2,5\n2,1,5\n2,3,5";
```

## Common
We hardcode the neighbors in the 6 main directions:
```q
.d18.dirs:(1 0 0;-1 0 0;0 1 0;0 -1 0;0 0 1;0 0 -1);
```
We split the input on commas and convert to integers:
```q
q)a:"J"$","vs/:x;
q)a
2 2 2
1 2 2
3 2 2
..
```

## Part 1
We simply add the 6 main directions to each coordinate, remove those that overlap the original coordinates, then count the remaining ones.
```q
q)count raze[a+/:\:.d18.dirs]except a
64
```

## Part 2
We store the neighbors from part 1 in a variable:
```q
q)b:raze[a+/:\:.d18.dirs]except a;
q)b
0 2 2
1 3 2
1 1 2
..
```
We calculate a displacement to ensure that there are no negative coordinates:
```q
disp:min[b];
b:b-\:disp;
a:a-\:disp;
```
We cache the size, which is the maximum along each coordinate:
```q
size:max b;
```
We calculate how many times each coordinate should be counted based on how many cubes it's adjacent to:
```q
q)bg:count each group b;
q)bg
0 2 2| 1
1 3 2| 2
1 1 2| 2
1 2 3| 2
..
```
The next section is a BFS to find the open coordinates. We initialize the found counter to zero and the visited array to all zeros:
```q
found:0;
visited:(1+size)#0b;
```
The initial queue will be the coordinate 0 0 0:
```q
queue:enlist 0 0 0;
```
We repeat until we run out of coordinates:
```q
while[count queue;
```
We mark all the coordinates in the queue as visited:
```q
visited:.[;;:;1b]/[visited;queue];
```
We add the number of found coordinates to the found counter, making sure to respect how many times each should be counted (anything not in the dictionary will be ignored):
```q
found+:sum bg queue;
```
We expand each node by adding the 6 main directions, excluding the coordinates matching the input:
```q
queue:(distinct raze queue+/:\:.d18.dirs)except a;
```
We filter to the coordinates within the bounds:
```q
queue:queue where all each queue within\:(0 0 0;size);
```
We also filter out any visited nodes:
```
queue:queue where not visited ./:queue;
```
This ends the main loop. At the end, we simply need to return the found counter.
```q
];
found
```
