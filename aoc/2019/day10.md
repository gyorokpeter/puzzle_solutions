# Breakdown
Example input:
```q
x4:()
x4,:enlist".#..##.###...#######"
x4,:enlist"##.############..##."
x4,:enlist".#.######.########.#"
x4,:enlist".###.#######.####.#."
x4,:enlist"#####.##.#.##.###.##"
x4,:enlist"..#####..#.#########"
x4,:enlist"####################"
x4,:enlist"#.####....###.#.#.##"
x4,:enlist"##.#################"
x4,:enlist"#####.##.###..####.."
x4,:enlist"..######..##.#######"
x4,:enlist"####.##.####...##..#"
x4,:enlist".#####..#.######.###"
x4,:enlist"##...#.##########..."
x4,:enlist"#.##########.#######"
x4,:enlist".####.#.###.###.#.##"
x4,:enlist"....##.##.###..#####"
x4,:enlist".#.#.###########.###"
x4,:enlist"#.#.#.#####.####.###"
x4,:enlist"###.##.####.##.#..##"
```

## Common
The following helper functions are used:

### vlen
Calculates the length of the vector from `(0;0)` to `(x;y)`.
```q
    vlen:{sqrt(x*x)+y*y}
```
### atan2 
Like the similarly named function from C. We need the pi constant, which is not built in in q but
can be obtained using `acos` since `acos[0]` is `pi%2`.
```q
    pi:2*acos 0;
```
The `atan2` function is just a multi-branched case statement. See
[atan2](https://en.wikipedia.org/wiki/Atan2) for the mathematical definition.
```q
    atan2:{[y;x]
        $[x>0;
            atan[y%x];
          (x<0)and y>=0;
            atan[y%x]+pi;
          (x<0)and y<0;
            atan[y%x]-pi;
          (x=0)and y>0;
            pi%2;
          (x=0)and y<0;
            neg pi%2;
          0n]};
```
### gcdv
Greatest common divisor. This one needs to be adapted a bit to take advantage of the vector
capabilities of q. First we put the two input vectors into a table:
```q
    xy:([]abs x;abs y);
```
Then on each iteration we first make sure that `x<y`, which can be done simply by putting the `min`
and `max` of the two columns into `x` and `y` respectively:
```q
    xy:update x:min(x;y),y:max(x;y) from xy;
```
Then we update `y` to `y mod x`, but only where `x>0`. Using the `select` statement with a `where`
clause is actually a performance improvement here because we won't be calculating useless values for
the "already done" rows:
```q
    xy:update y:y mod x from xy where 0<x;
```
These two steps are alternated, and we use the "repeat until no change" `/` (over) iterator. Then
the result is the `y` column (since that is the larger of the two, and `x` will be all zeros).
```q
    gcdv:{exec y from {[xy]
        xy:update x:min(x;y),y:max(x;y) from xy;
        xy:update y:y mod x from xy where 0<x;
        xy}/[([]abs x;abs y)]};
```
### d10
The common logic that is actually relevant to the puzzle.

We convert the input from character to boolean by comparing every element to `"#"`:
```q
q)a:"#"=x
q)a
01001101110001111111b
11011111111111100110b
01011111101111111101b
01110111111101111010b
11111011010110111011b
00111110010111111111b
11111111111111111111b
10111100001110101011b
11011111111111111111b
11111011011100111100b
00111111001101111111b
11110110111100011001b
01111100101111110111b
11000101111111111000b
10111111111101111111b
01111010111011101011b
00001101101110011111b
01010111111111110111b
10101011111011110111b
11101101111011010011b
```
We convert the matrix to coordinates using the [2D search](../utils/patterns.md#2d-search)
technique:
```q
q)b:raze(where each a),\:'til count a
q)b
1  0
4  0
5  0
7  0
8  0
9  0
..
14 1
17 1
18 1
1  2
..
12 19
13 19
15 19
18 19
19 19
```
Now we want to figure out the best place for the station. First we need the relative coordinates
between each pair of asteroids. This can be done by subtracting every coordinate pair from every
other. The idiomatic way to do this in q is by combining the `/:` (each-right) and `\:` (each-left)
iterators. The two orders of combining them give equivalent results, but one is the transpose of the
other.
```q
q)(b-\:/:b)
0  0   3  0   4  0   6  0   7  0   8  0   12 0   13 0   14 0   15 0   16 0   ..
-3 0   0  0   1  0   3  0   4  0   5  0   9  0   10 0   11 0   12 0   13 0   ..
-4 0   -1 0   0  0   2  0   3  0   4  0   8  0   9  0   10 0   11 0   12 0   ..
-6 0   -3 0   -2 0   0  0   1  0   2  0   6  0   7  0   8  0   9  0   10 0   ..
-7 0   -4 0   -3 0   -1 0   0  0   1  0   5  0   6  0   7  0   8  0   9  0   ..
-8 0   -5 0   -4 0   -2 0   -1 0   0  0   4  0   5  0   6  0   7  0   8  0   ..
-12 0  -9  0  -8  0  -6  0  -5  0  -4  0  0   0  1   0  2   0  3   0  4   0  ..
-13 0  -10 0  -9  0  -7  0  -6  0  -5  0  -1  0  0   0  1   0  2   0  3   0  ..
-14 0  -11 0  -10 0  -8  0  -7  0  -6  0  -2  0  -1  0  0   0  1   0  2   0  ..
-15 0  -12 0  -11 0  -9  0  -8  0  -7  0  -3  0  -2  0  -1  0  0   0  1   0  ..
-16 0  -13 0  -12 0  -10 0  -9  0  -8  0  -4  0  -3  0  -2  0  -1  0  0   0  ..
-17 0  -14 0  -13 0  -11 0  -10 0  -9  0  -5  0  -4  0  -3  0  -2  0  -1  0  ..
-18 0  -15 0  -14 0  -12 0  -11 0  -10 0  -6  0  -5  0  -4  0  -3  0  -2  0  ..
1  -1  4  -1  5  -1  7  -1  8  -1  9  -1  13 -1  14 -1  15 -1  16 -1  17 -1  ..
0  -1  3  -1  4  -1  6  -1  7  -1  8  -1  12 -1  13 -1  14 -1  15 -1  16 -1  ..
-2 -1  1  -1  2  -1  4  -1  5  -1  6  -1  10 -1  11 -1  12 -1  13 -1  14 -1  ..
-3 -1  0  -1  1  -1  3  -1  4  -1  5  -1  9  -1  10 -1  11 -1  12 -1  13 -1  ..
..
```
This matrix can be interpreted such that the `i`th row contains the relative coordinates of every
asteroid compared to the `i`th asteroid. Naturally the relative coordinates of an asteroid to iself
will alway be `(0;0)` which is uninteresting, so we remove it from the matrix. We need to enlist
this because it's the whole item that we want to remove, and also use `\:` to remove it from every
row.
```q
q)c:(b-\:/:b)except\:enlist 0 0
q)c
3  0   4  0   6  0   7  0   8  0   12 0   13 0   14 0   15 0   16 0   17 0   ..
-3 0   1  0   3  0   4  0   5  0   9  0   10 0   11 0   12 0   13 0   14 0   ..
-4 0   -1 0   2  0   3  0   4  0   8  0   9  0   10 0   11 0   12 0   13 0   ..
-6 0   -3 0   -2 0   1  0   2  0   6  0   7  0   8  0   9  0   10 0   11 0   ..
-7 0   -4 0   -3 0   -1 0   1  0   5  0   6  0   7  0   8  0   9  0   10 0   ..
-8 0   -5 0   -4 0   -2 0   -1 0   4  0   5  0   6  0   7  0   8  0   9  0   ..
-12 0  -9  0  -8  0  -6  0  -5  0  -4  0  1   0  2   0  3   0  4   0  5   0  ..
-13 0  -10 0  -9  0  -7  0  -6  0  -5  0  -1  0  1   0  2   0  3   0  4   0  ..
-14 0  -11 0  -10 0  -8  0  -7  0  -6  0  -2  0  -1  0  1   0  2   0  3   0  ..
-15 0  -12 0  -11 0  -9  0  -8  0  -7  0  -3  0  -2  0  -1  0  1   0  2   0  ..
-16 0  -13 0  -12 0  -10 0  -9  0  -8  0  -4  0  -3  0  -2  0  -1  0  1   0  ..
-17 0  -14 0  -13 0  -11 0  -10 0  -9  0  -5  0  -4  0  -3  0  -2  0  -1  0  ..
-18 0  -15 0  -14 0  -12 0  -11 0  -10 0  -6  0  -5  0  -4  0  -3  0  -2  0  ..
1  -1  4  -1  5  -1  7  -1  8  -1  9  -1  13 -1  14 -1  15 -1  16 -1  17 -1  ..
0  -1  3  -1  4  -1  6  -1  7  -1  8  -1  12 -1  13 -1  14 -1  15 -1  16 -1  ..
-2 -1  1  -1  2  -1  4  -1  5  -1  6  -1  10 -1  11 -1  12 -1  13 -1  14 -1  ..
-3 -1  0  -1  1  -1  3  -1  4  -1  5  -1  9  -1  10 -1  11 -1  12 -1  13 -1  ..
..
```
Asteroids only obscure each other if they fall in a line, and since we have integer coordinates,
this means that if we divide the coordinates by the `gcd` of the X and Y coordinate, all points on a
line will collapse into the same point. This is where the `gcdv` function comes in. To find the two
arguments to pass in, we can flip each row of the matrix, so they become a two-element list with the
X and Y coordinates respectively.
```q
q)flip each c
3 4 6 7 8 12 13 14 15 16 17 18 -1 0 2 3 4 5 6 7 8 9 10 11 12 13 16 17 0 2 3 4..
-3 1 3 4 5 9 10 11 12 13 14 15 -4 -3 -1 0 1 2 3 4 5 6 7 8 9 10 13 14 -3 -1 0 ..
-4 -1 2 3 4 8 9 10 11 12 13 14 -5 -4 -2 -1 0 1 2 3 4 5 6 7 8 9 12 13 -4 -2 -1..
-6 -3 -2 1 2 6 7 8 9 10 11 12 -7 -6 -4 -3 -2 -1 0 1 2 3 4 5 6 7 10 11 -6 -4 -..
-7 -4 -3 -1 1 5 6 7 8 9 10 11 -8 -7 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 9 10 -7 -5 -..
-8 -5 -4 -2 -1 4 5 6 7 8 9 10 -9 -8 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 8 9 -8 -6 -..
-12 -9 -8 -6 -5 -4 1 2 3 4 5 6 -13 -12 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 4 5..
-13 -10 -9 -7 -6 -5 -1 1 2 3 4 5 -14 -13 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0..
-14 -11 -10 -8 -7 -6 -2 -1 1 2 3 4 -15 -14 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -..
-15 -12 -11 -9 -8 -7 -3 -2 -1 1 2 3 -16 -15 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4..
-16 -13 -12 -10 -9 -8 -4 -3 -2 -1 1 2 -17 -16 -14 -13 -12 -11 -10 -9 -8 -7 -6..
-17 -14 -13 -11 -10 -9 -5 -4 -3 -2 -1 1 -18 -17 -15 -14 -13 -12 -11 -10 -9 -8..
-18 -15 -14 -12 -11 -10 -6 -5 -4 -3 -2 -1 -19 -18 -16 -15 -14 -13 -12 -11 -10..
1  4  5  7  8  9  13 14 15 16 17 18 19 1 3 4 5 6 7 8 9 10 11 12 13 14 17 18 1..
0  3  4  6  7  8  12 13 14 15 16 17 18 -1 2 3 4 5 6 7 8 9 10 11 12 13 16 17 0..
-2 1  2  4  5  6  10 11 12 13 14 15 16 -3 -2 1 2 3 4 5 6 7 8 9 10 11 14 15 -2..
-3 0  1  3  4  5  9  10 11 12 13 14 15 -4 -3 -1 1 2 3 4 5 6 7 8 9 10 13 14 -3..
..
```
We can now calculate the `gcd`s, using the dot operator to pass in the two lists as the two
parameters, and with `/:`, because we want to do it once per row.
```q
q)gcdv ./:flip each c
3  4  6  7  8  12 13 14 15 16 17 18 1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
3  1  3  4  5  9  10 11 12 13 14 15 1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  1 ..
4  1  2  3  4  8  9  10 11 12 13 14 1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
6  3  2  1  2  6  7  8  9  10 11 12 1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
7  4  3  1  1  5  6  7  8  9  10 11 1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  1 ..
8  5  4  2  1  4  5  6  7  8  9  10 1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
12 9  8  6  5  4  1  2  3  4  5  6  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
13 10 9  7  6  5  1  1  2  3  4  5  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  1 ..
14 11 10 8  7  6  2  1  1  2  3  4  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
15 12 11 9  8  7  3  2  1  1  2  3  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  1 ..
16 13 12 10 9  8  4  3  2  1  1  2  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
17 14 13 11 10 9  5  4  3  2  1  1  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  1 ..
18 15 14 12 11 10 6  5  4  3  2  1  1 1 1 1 1 1 1 1 1 1  1  1  1  1  1  1  2 ..
1  1  1  1  1  1  1  1  1  1  1  1  1 1 3 4 5 6 7 8 9 10 11 12 13 14 17 18 1 ..
1  1  1  1  1  1  1  1  1  1  1  1  1 1 2 3 4 5 6 7 8 9  10 11 12 13 16 17 1 ..
1  1  1  1  1  1  1  1  1  1  1  1  1 3 2 1 2 3 4 5 6 7  8  9  10 11 14 15 1 ..
1  1  1  1  1  1  1  1  1  1  1  1  1 4 3 1 1 2 3 4 5 6  7  8  9  10 13 14 1 ..
..
```
We can use these to divide the relative coordinates.
```q
q)c div gcdv ./:flip each c
1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   ..
-1 0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   ..
-1 0   -1 0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   ..
-1 0   -1 0   -1 0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   ..
-1 0   -1 0   -1 0   -1 0   1  0   1  0   1  0   1  0   1  0   1  0   1  0   ..
-1 0   -1 0   -1 0   -1 0   -1 0   1  0   1  0   1  0   1  0   1  0   1  0   ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  1   0  1   0  1   0  1   0  1   0  ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  1   0  1   0  1   0  1   0  ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  1   0  1   0  1   0  ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  1   0  1   0  ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  1   0  ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  ..
-1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  -1  0  ..
1  -1  4  -1  5  -1  7  -1  8  -1  9  -1  13 -1  14 -1  15 -1  16 -1  17 -1  ..
0  -1  3  -1  4  -1  6  -1  7  -1  8  -1  12 -1  13 -1  14 -1  15 -1  16 -1  ..
-2 -1  1  -1  2  -1  4  -1  5  -1  6  -1  10 -1  11 -1  12 -1  13 -1  14 -1  ..
-3 -1  0  -1  1  -1  3  -1  4  -1  5  -1  9  -1  10 -1  11 -1  12 -1  13 -1  ..
..
```
Finally we take the distinct coordinates in each row. Since the division caused the asteroids on the
same line of sight to collapse into the same coordinate, taking the distinct only leaves one per
line.
```q
q)d:distinct each c div gcdv ./:flip each c
q)d
(1 0;-1 1;0 1;2 1;3 1;4 1;5 1;6 1;7 1;8 1;9 1;10 1;11 1;12 1;13 1;16 1;17 1;1..
(-1 0;1 0;-4 1;-3 1;-1 1;0 1;1 1;2 1;3 1;4 1;5 1;6 1;7 1;8 1;9 1;10 1;13 1;14..
(-1 0;1 0;-5 1;-4 1;-2 1;-1 1;0 1;1 1;2 1;3 1;4 1;5 1;6 1;7 1;8 1;9 1;12 1;13..
(-1 0;1 0;-7 1;-6 1;-4 1;-3 1;-2 1;-1 1;0 1;1 1;2 1;3 1;4 1;5 1;6 1;7 1;10 1;..
(-1 0;1 0;-8 1;-7 1;-5 1;-4 1;-3 1;-2 1;-1 1;0 1;1 1;2 1;3 1;4 1;5 1;6 1;9 1;..
(-1 0;1 0;-9 1;-8 1;-6 1;-5 1;-4 1;-3 1;-2 1;-1 1;0 1;1 1;2 1;3 1;4 1;5 1;8 1..
(-1 0;1 0;-13 1;-12 1;-10 1;-9 1;-8 1;-7 1;-6 1;-5 1;-4 1;-3 1;-2 1;-1 1;0 1;..
(-1 0;1 0;-14 1;-13 1;-11 1;-10 1;-9 1;-8 1;-7 1;-6 1;-5 1;-4 1;-3 1;-2 1;-1 ..
(-1 0;1 0;-15 1;-14 1;-12 1;-11 1;-10 1;-9 1;-8 1;-7 1;-6 1;-5 1;-4 1;-3 1;-2..
(-1 0;1 0;-16 1;-15 1;-13 1;-12 1;-11 1;-10 1;-9 1;-8 1;-7 1;-6 1;-5 1;-4 1;-..
(-1 0;1 0;-17 1;-16 1;-14 1;-13 1;-12 1;-11 1;-10 1;-9 1;-8 1;-7 1;-6 1;-5 1;..
(-1 0;1 0;-18 1;-17 1;-15 1;-14 1;-13 1;-12 1;-11 1;-10 1;-9 1;-8 1;-7 1;-6 1..
(-1 0;-19 1;-18 1;-16 1;-15 1;-14 1;-13 1;-12 1;-11 1;-10 1;-9 1;-8 1;-7 1;-6..
(1 -1;4 -1;5 -1;7 -1;8 -1;9 -1;13 -1;14 -1;15 -1;16 -1;17 -1;18 -1;19 -1;1 0;..
(0 -1;3 -1;4 -1;6 -1;7 -1;8 -1;12 -1;13 -1;14 -1;15 -1;16 -1;17 -1;18 -1;-1 0..
(-2 -1;1 -1;2 -1;4 -1;5 -1;6 -1;10 -1;11 -1;12 -1;13 -1;14 -1;15 -1;16 -1;-1 ..
(-3 -1;0 -1;1 -1;3 -1;4 -1;5 -1;9 -1;10 -1;11 -1;12 -1;13 -1;14 -1;15 -1;-1 0..
..
```

## Part 1
Given the list above, we count the number of coordinates in each row and find the highest one.
```q
q)count each d
191 188 193 191 195 185 189 194 190 194 196 191 187 198 194 197 192 200 196 1..
q)max count each d
210
```

## Part 2
The idea is to convert the relative coordinates to polar and sort the asteroids by the angle and
radius components.

While we didn't need the coordinates of the best location for part 1, we will store it now to make
the below calculations easier. First we take the index of the chosen asteroid:
```q
q)e:first {where x=max x}count each d
q)e
205
```
And then get the coordinates from the full asteroid list:
```q
q)f:b e
q)f
11 13
```
Storing the index is also good because we can take out the relevant row of the relative coordinates.
We no longer need the other rows.
```q
q)c e
-10 -13
-7  -13
-6  -13
-4  -13
-3  -13
-2  -13
2   -13
3   -13
4   -13
5   -13
6   -13
7   -13
8   -13
-11 -12
-10 -12
-8  -12
-7  -12
..
```
We store these coordinates in a table, calling the columns `dx` and `dy` (for delta x and delta y).
We use the q idiom to convert a matrix to a table.
```q
q)flip`dx`dy!flip c[e]
dx  dy
-------
-10 -13
-7  -13
-6  -13
-4  -13
-3  -13
-2  -13
2   -13
3   -13
4   -13
5   -13
6   -13
7   -13
8   -13
-11 -12
-10 -12
..
```
We also add the original coordinates to the table:
```q
q)g:update x:dx+f[0], y:dy+f[1] from flip`dx`dy!flip c e
q)g
dx  dy  x  y
------------
-10 -13 1  0
-7  -13 4  0
-6  -13 5  0
-4  -13 7  0
-3  -13 8  0
-2  -13 9  0
2   -13 13 0
3   -13 14 0
4   -13 15 0
5   -13 16 0
6   -13 17 0
7   -13 18 0
8   -13 19 0
-11 -12 0  1
-10 -12 1  1
..
```
We convert the relative coordinates from Cartesian to polar, which is why we needed the `vlen` and
`atan2` functions. Note that since the Y axis points down, the angle returned by `atan` is clockwise
from the positive direction of the X axis. Since the laser will start rotating from the up
direction, we have to adjust the angles so that up becomes 0 (this is done by adding `pi%2`) and
that there are no negative angles. The latter is done by adding `2*pi` to the negative angles,
and an equivalent way to write that in q is by `mod`ding it with `2*pi` since `mod A` returns a
number from 0 up to but not including `A`. Yes, it's not for integers only.
```q
q)update r:vlen[dx;dy], a:(atan2'[dy;dx]+pi%2)mod 2*pi from g
dx  dy  x  y r        a
-------------------------------
-10 -13 1  0 16.40122 5.62749
-7  -13 4  0 14.76482 5.789244
-6  -13 5  0 14.31782 5.850778
-4  -13 7  0 13.60147 5.984686
-3  -13 8  0 13.34166 6.056386
-2  -13 9  0 13.15295 6.130536
2   -13 13 0 13.15295 0.1526493
3   -13 14 0 13.34166 0.2267988
4   -13 15 0 13.60147 0.2984989
5   -13 16 0 13.92839 0.3671738
6   -13 17 0 14.31782 0.4324078
7   -13 18 0 14.76482 0.4939414
8   -13 19 0 15.26434 0.551655
-11 -12 0  1 16.27882 5.541238
-10 -12 1  1 15.6205  5.588447
..
```
Now to put the asteroids in the order of rotation, we sort the table by the `a` column, then we sort
by `r` as well such that of the asteroids on the same line, the closer one comes first.
```q
q)h:`a`r xasc update r:vlen[dx;dy], a:(atan2'[dy;dx]+pi%2)mod 2*pi from g
q)h
dx dy  x  y  r        a
--------------------------------
0  -1  11 12 1        0
0  -2  11 11 2        0
0  -3  11 10 3        0
0  -4  11 9  4        0
0  -5  11 8  5        0
0  -6  11 7  6        0
0  -7  11 6  7        0
0  -8  11 5  8        0
0  -9  11 4  9        0
0  -10 11 3  10       0
0  -11 11 2  11       0
0  -12 11 1  12       0
1  -12 12 1  12.04159 0.08314123
1  -11 12 2  11.04536 0.09065989
1  -9  12 4  9.055385 0.1106572
..
```
This is not yet good enough because now the obscured asteroids are mixed with the visible ones. A
cool way to separate them is to group the table by the angle. Remember that in q we don't have to
aggregate after grouping.

(The `1_` is not in the solution. I drop the first row in this demo to avoid it exploding the
layout.)
```q
q)1_select dx, dy, x, y, r by a from h
a         | dx  dy     x     y   r
----------| --------------------------------------
0.08314123| ,1  ,-12   ,12   ,1  ,12.04159
0.09065989| ,1  ,-11   ,12   ,2  ,11.04536
0.1106572 | ,1  ,-9    ,12   ,4  ,9.055385
0.124355  | ,1  ,-8    ,12   ,5  ,8.062258
0.1418971 | ,1  ,-7    ,12   ,6  ,7.071068
0.1526493 | ,2  ,-13   ,13   ,0  ,13.15295
0.1651487 | 1 2 -6 -12 12 13 7 1 6.082763 12.16553
0.1798535 | ,2  ,-11   ,13   ,2  ,11.18034
0.1973956 | 1 2 -5 -10 12 13 8 3 5.09902 10.19804
0.2267988 | ,3  ,-13   ,14   ,0  ,13.34166
0.2449787 | 2 3 -8 -12 13 14 5 1 8.246211 12.36932
0.266252  | ,3  ,-11   ,14   ,2  ,11.40175
0.2782997 | ,2  ,-7    ,13   ,6  ,7.28011
0.2914568 | ,3  ,-10   ,14   ,3  ,10.44031
0.2984989 | ,4  ,-13   ,15   ,0  ,13.60147
..
```
Now that every line is in its own group, we can add the rotation index by counting up from zero in
each row. The `til` function does just that, and we want to count up to the number of rotations,
which is the number of elements in any column, such as `r`.
```q
q)j:update ri:til each count each r from select dx, dy, x, y, r by a from h
q)1_j
a         | dx  dy     x     y   r                 ri
----------| ------------------------------------------
0.08314123| ,1  ,-12   ,12   ,1  ,12.04159         ,0
0.09065989| ,1  ,-11   ,12   ,2  ,11.04536         ,0
0.1106572 | ,1  ,-9    ,12   ,4  ,9.055385         ,0
0.124355  | ,1  ,-8    ,12   ,5  ,8.062258         ,0
0.1418971 | ,1  ,-7    ,12   ,6  ,7.071068         ,0
0.1526493 | ,2  ,-13   ,13   ,0  ,13.15295         ,0
0.1651487 | 1 2 -6 -12 12 13 7 1 6.082763 12.16553 0 1
0.1798535 | ,2  ,-11   ,13   ,2  ,11.18034         ,0
0.1973956 | 1 2 -5 -10 12 13 8 3 5.09902 10.19804  0 1
0.2267988 | ,3  ,-13   ,14   ,0  ,13.34166         ,0
0.2449787 | 2 3 -8 -12 13 14 5 1 8.246211 12.36932 0 1
0.266252  | ,3  ,-11   ,14   ,2  ,11.40175         ,0
0.2782997 | ,2  ,-7    ,13   ,6  ,7.28011          ,0
0.2914568 | ,3  ,-10   ,14   ,3  ,10.44031         ,0
0.2984989 | ,4  ,-13   ,15   ,0  ,13.60147         ,0
..
```
Now we ungroup the table, which we can do since every non-key column has the same number of elements
in the same row:
```q
q)ungroup j
a          dx dy  x  y  r        ri
-----------------------------------
0          0  -1  11 12 1        0
0          0  -2  11 11 2        1
0          0  -3  11 10 3        2
0          0  -4  11 9  4        3
0          0  -5  11 8  5        4
0          0  -6  11 7  6        5
0          0  -7  11 6  7        6
0          0  -8  11 5  8        7
0          0  -9  11 4  9        8
0          0  -10 11 3  10       9
0          0  -11 11 2  11       10
0          0  -12 11 1  12       11
0.08314123 1  -12 12 1  12.04159 0
0.09065989 1  -11 12 2  11.04536 0
0.1106572  1  -9  12 4  9.055385 0
..
```
We can see that the asteroids on the same row get to survive for the most rotations. To get the
order in which the asteroids are destroyed, we order by the newly obtained rotation index (`ri`),
followed by the angle (`a`):
```q
q)k:`ri`a xasc ungroup j
q)k
a          dx dy  x  y  r        ri
-----------------------------------
0          0  -1  11 12 1        0
0.08314123 1  -12 12 1  12.04159 0
0.09065989 1  -11 12 2  11.04536 0
0.1106572  1  -9  12 4  9.055385 0
0.124355   1  -8  12 5  8.062258 0
0.1418971  1  -7  12 6  7.071068 0
0.1526493  2  -13 13 0  13.15295 0
0.1651487  1  -6  12 7  6.082763 0
0.1798535  2  -11 13 2  11.18034 0
0.1973956  1  -5  12 8  5.09902  0
0.2267988  3  -13 14 0  13.34166 0
0.2449787  2  -8  13 5  8.246211 0
0.266252   3  -11 14 2  11.40175 0
0.2782997  2  -7  13 6  7.28011  0
0.2914568  3  -10 14 3  10.44031 0
..
```
We can verify the order using the indices given by the problem statement. Note that since indexing
starts from zero, we subtract 1 from the indices in the text:
```q
q)k[0 1 2 9 19 49 99 198 199 200 298;`x`y]
11 12
12 1
12 2
12 8
16 0
16 9
10 16
9  6
8  2
10 9
11 1
```
The actual answer that we want is at index 199, and we also do the little arithmetic to add `100*x`
to `y`.
```q
q)k[199][`x`y]
8 2
q)sum 100 1*k[199][`x`y]
802
```
