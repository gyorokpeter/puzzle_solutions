# Breakdown

Example input:
```q
x:"\n"vs"5,4\n4,2\n4,5\n3,0\n2,1\n6,3\n2,4\n1,5\n0,6\n3,3\n2,6\n5,1\n1,2\n5,5\n2,5\n6,5\n1,4\n0,4";
x,:"\n"vs"6,4\n1,1\n6,1\n1,0\n0,5\n1,6\n2,0";
size:7;
cutoff:12;
```

## Part 1
Due to the discrepancies between the example and the real input, the function takes two extra
arguments, the size and the cutoff point.

We parse the integer pairs and swap them in order to use them as matrix indices:
```q
q)a:reverse each"J"$","vs/:x;
q)a
4 5
2 4
5 4
0 3
1 2
..
```
We initialize a visited matrix of the correct size:
```q
q)visited:(2#size)#0b
q)visited
0000000b
0000000b
0000000b
0000000b
0000000b
0000000b
0000000b
```
We use iterated functional amend to place the obstacles up to the cutoff point:
```q
q)visited:.[;;:;1b]/[visited;cutoff#a]
q)visited
0001000b
0010010b
0000100b
0001001b
0010010b
0100100b
1010000b
```
The rest of the solution is a utility function `d18` that takes the visited matrix and the size, and
returns the length of the shortest path or null if there is none. This will also be used by part 2.
```q
    d18:{[size;visited]
        ...
    };
```
The helper function is a BFS. We initialize the goal position (the size minus one repeated twice),
the queue with the starting position and a step counter:
```q
    goal:2#size-1;
    queue:enlist 0 0;
    step:0;
```
We iterate as long as there are items in the queue. If there are no items, we return null to
indicate the lack of a path.
```q
    while[count queue;
        ...
    ];
    0N
```
In the iteration, we first check if the goal is in the queue. If it is, we return the step counter.
```q
    if[goal in queue; :step];
```
Otherwise we increase the step counter by one:
```q
    step+:1;
```
We mark the positions in the queue as visited:
```q
    visited:.[;;:;1b]/[visited;queue];
```
We expand the nodes by adding the offsets for the four cardinal directions:
```q
    nxts:raze queue+/:\:(-1 0;0 1;1 0;0 -1);
```
We filter to coordinates within the map bounds, as well as to those not yet visited:
```q
    nxts:nxts where all each nxts within\:(0;size-1);
    nxts:nxts where not visited ./:nxts;
```
We update the queue to the distinct next coordinates:
```q
    queue:distinct nxts;
```

## Part 2
The initialization is similar to part 1:
```q
    a:reverse each"J"$","vs/:x;
    visited:(2#size)#0b;
    visited:.[;;:;1b]/[visited;cutoff#a];
```
However, instead of simply calling `d18` again, we iterate and add one obstacle at a time, checking
if there is still a path. If the function returns null, we return the coordinate of the current
obstacle based on the step counter.

The step counter is initialized to `cutoff` because we know there is still a path in that state so
no point iterating over the earlier states.
```q
    step:cutoff;
    while[step<count a;
        visited:.[visited;a step;:;1b];
        if[null d18[size;visited]; :x step];
        step+:1;
    ];
```
