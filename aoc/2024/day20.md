# Breakdown

Example input:
```q
x:();
x,:enlist"###############";
x,:enlist"#...#...#.....#";
x,:enlist"#.#.#.#.#.###.#";
x,:enlist"#S#...#.#.#...#";
x,:enlist"#######.#.#.###";
x,:enlist"#######.#.#...#";
x,:enlist"#######.#.###.#";
x,:enlist"###..E#...#...#";
x,:enlist"###.#######.###";
x,:enlist"#...###...#...#";
x,:enlist"#.#####.#.###.#";
x,:enlist"#.#...#.#.#...#";
x,:enlist"#.#.#.#.#.#.###";
x,:enlist"#...#...#...###";
x,:enlist"###############";
```

## Common
The two parts can be solved using a single technique that takes the cheat length (`cl`) as a
parameter. We generate the single path through the maze, then match up every position in the path
with every other position in the path. We check if the Manhattan distance between them is not longer
than the cheat length, and if so, how much time is saved by taking the Manhattan distance instead of
the regular path (which is 1 unit for each position in the path). Theoretically this can be done by
storing the cross product of the path with itself in a huge matrix, but this breaches the limit of
32-bit kdb+. So instead I chose a solution that iterates over the positions in the path, only
generating a single row of the matrix at a time. This iteration can also cut off backwards cheats to
save time. For this demonstration, we use `cl:20` (the condition for part 2).

We initialize a visited matrix with the obstacles, find the start and end position, and replace them
with empty space:
```q
    visited:x="#";
    pos:first raze til[count x],/:'where each x="S";
    goal:first raze til[count x],/:'where each x="E";
    map:.[;;:;"."]/[x;(pos;goal)];
```
We use BFS to find the path. This time there is no queue, we just keep one position and choose the
next position that is not visited, appending to the path on every step. The iteration goes until the
current position is the goal, at which point we add the goal to the path.
```q
    path:();
    while[not pos~goal;
        visited:.[visited;pos;:;1b];
        path,:enlist pos;
        nxts:pos+/:(-1 0;0 1;1 0;0 -1);
        nxts:nxts where not visited ./:nxts;
        pos:first nxts;
    ];
    path,:enlist goal;

q)path
3  1
2  1
1  1
1  2
1  3
..
```
We calculate the possible saved time from each position in the path using a helper function. For
demonstration, let's use `i:0`, i.e. the current position is the start of the path.
```q
    saves:{[cl;path;i]
        ...
    }[cl;path]each til count path;
```
We pick out the current element and drop the part of the path up to the current element as those
would correspond to backwards cheats:
```q
q)pi:path i;
q)pi
3 1
q)p2:i _path;
q)p2
3  1
2  1
1  1
1  2
1  3
..
```
We generate the Manhattan distances from the current node to every other node in the remaining path:
```q
q)dist:sum each abs pi-/:p2
q)dist
0 1 2 3 4 3 2 3 4 5 6 7 8 7 6 7 8 9 10 11 12 11 10 9 8 9 10 11 12 13 14 13 12 11 10 11 12 13 14 15..
```
We find the time saved by subtracting the Manhattan distance from the list index, which represents
the natural flow of time with one tile moved per step:
```q
q)til[count p2]-dist
0 0 0 0 0 2 4 4 4 4 4 4 4 6 8 8 8 8 8 8 8 10 12 14 16 16 16 16 16 16 16 18 20 22 24 24 24 24 24 24..
```
We also check for which distances are not longer than the cheat limit:
```q
q)dist<=cl
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111b
```
(We find that in this small example all cheats are valid, but that's a coincidence as the path tile
furthest away from the starting point happens to be exacly 20 tiles away. For lower `cl` or a bigger
grid we would see some zeros in this vector.)

We multiply together the two vectors to find the valid cheats. An invalid cheat will become a zero,
which we filter out:
```q
q)((dist<=cl)*til[count p2]-dist)except 0
2 4 4 4 4 4 4 4 6 8 8 8 8 8 8 8 10 12 14 16 16 16 16 16 16 16 18 20 22 24 24 24 24 24 24 24 26 28 ..
```
After iterating the function, the `saves` variable contains the saved times for all positions in the
path:
```q
q)saves
2 4 4 4 4 4 4 4 6 8 8 8 8 8 8 8 10 12 14 16 16 16 16 16 16 16 18 20 22 24 24 24 24 24 24 24 26 28 ..
2 2 2 2 4 4 4 4 6 6 6 6 6 6 6 6 8 10 12 14 16 16 16 16 16 16 18 18 20 22 22 22 22 22 22 22 24 26 2..
2 4 4 4 4 4 4 4 4 4 4 4 6 8 10 12 14 16 16 16 16 16 16 16 18 20 20 20 20 20 20 20 22 24 24 24 24 2..
2 4 4 4 4 4 4 4 4 4 4 4 6 8 10 12 14 16 16 16 16 16 16 16 18 20 20 20 20 20 20 20 22 24 24 24 24 2..
2 4 4 4 4 4 4 4 4 4 4 4 6 8 10 12 14 16 16 16 16 16 16 16 18 20 20 20 20 20 20 20 22 24 24 24 24 2..
..
```
We format this into a neat dictionary with ascending keys to get the number of cheats for each
amount of time saved:
```q
q){asc[key x]#x}count each group raze saves
2 | 138
4 | 329
6 | 122
8 | 224
10| 109
..
```
We must implement a cutoff logic in the form `.d20.ccc` ("calc cheats with cutoff"). This function
filters the dictionary based on a low and high value. This can be used to test the examples:
```q
    .d20.ccc:{[cutoff;cl;x] //calc cheats with cutoff
        cc:{([]k:key x;v:value x)}.d20.cc[cl;x];
        exec k!v from cc where k within cutoff};
q).d20.ccc[0 0W;2;x]
2 | 14
4 | 14
6 | 2
8 | 4
10| 2
12| 3
20| 1
36| 1
38| 1
40| 1
64| 1
q).d20.ccc[50 0W;20;x]
50| 32
52| 31
54| 29
56| 39
58| 25
60| 23
62| 20
64| 19
66| 12
68| 14
70| 12
72| 22
74| 4
76| 3
```
To parameterize for the real input, we use `100 0W` as the cutoff.

## Part 1
The cheat length is 2.

## Part 2
The cheat length is 20.
