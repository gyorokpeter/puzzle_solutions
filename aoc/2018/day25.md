# Breakdown
Example input:
```q
x:"\n"vs"-1,2,2,0\n0,0,2,-2\n0,0,0,-2\n-1,2,0,0\n-2,-2,-2,2\n3,0,2,-1\n-1,3,2,2\n-1,0,-1,0"
x,:"\n"vs"0,2,1,-2\n3,0,0,0"
```

We parse the input by splitting on commas and converting to integers:
```q
q)pos:"J"$","vs/:x
q)pos
-1 2  2  0
0  0  2  -2
0  0  0  -2
-1 2  0  0
-2 -2 -2 2
3  0  2  -1
-1 3  2  2
-1 0  -1 0
0  2  1  -2
3  0  0  0
```
We initialize the list of constellation IDs of each point to zero:
```q
q)cons:count[pos]#0
q)cons
0 0 0 0 0 0 0 0 0 0
```
We also initialize a constellation sequence number (which gets incremented to assign to each new
constellation):
```q
q)conssq:0
```
We iterate as long as there are unknown (ID=zero) constellations:
```q
    while[0<count unknown:where 0=cons;
        ...
    ];

q)unknown:where 0=cons
q)unknown
0 1 2 3 4 5 6 7 8 9
```
In the iteration, we pick the first point with an unknown constellation:
```q
q)nxt:first unknown
q)nxt
0
```
We increment the constellation sequence number:
```q
q)conssq+:1
q)conssq
1
```
We initialize a queue consisting of only the new point:
```q
q)queue:enlist nxt
q)queue
,0
```
We perform a sub-iteration as long as there are items in the queue:
```q
    while[0<count queue;
        ...
    ];
```
In the sub-iteration, we assign the queue items to the current constellation:
```q
q)cons[queue]:conssq
q)cons
1 0 0 0 0 0 0 0 0 0
```
We update the list of unknown indices after the assignment:
```q
q)unknown:where 0=cons
q)unknown
1 2 3 4 5 6 7 8 9
```
We generate the distances between the points in the queue and the unknown ones:
```q
q)pos[queue]-\:/:pos unknown
-1 2 0 2
-1 2 2 2
0 0 2 0
1 4 4 -2
-4 2 0 1
0 -1 0 -2
0 2 3 0
-1 0 1 2
-4 2 2 0
```
We sum the per-coordinate distances:
```q
q)sum each/:abs pos[queue]-\:/:pos unknown
5
7
2
11
7
3
5
4
8
```
We find the minimum for each unknown point:
```q
q)dists:min each sum each/:abs pos[queue]-\:/:pos unknown
q)dists
5 7 2 11 7 3 5 4 8
```
We find the next elements in the queue by checking where the distance is less than or equal to 3:
```q
q)queue:unknown where dists<=3
q)queue
3 6
```
The code of the sub-iteration ends here. At the end of the sub-iteration, we have all the points in
one constellation identified:
```q
q)cons
1 0 0 1 0 0 1 1 0 0
```
The code of the main iteration ends here. At the end of the iteration, we have all the points in all
constellations identified:
```q
q)cons
1 2 2 1 3 4 1 1 2 4
```
Additionally, the `conssq` variable conveniently contains the ID of the last constellation, which is
also the answer:
```q
q)conssq
4
```
