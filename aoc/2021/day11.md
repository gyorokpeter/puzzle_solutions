# Breakdown
Example input:
```q
x:"\n"vs"5483143223\n2745854711\n5264556173\n6141336146\n6357385478\n4167524645\n2176841721"
x,:"\n"vs"6882881134\n4846848554\n5283751526"
```

## Part 1
We parse the input into numbers:
```q
q)a:"J"$/:/:x
q)a
5 4 8 3 1 4 3 2 2 3
2 7 4 5 8 5 4 7 1 1
5 2 6 4 5 5 6 1 7 3
...
```
Then we do a loop with 100 steps. The step is implemented as a separate function so it can be
reused for part 2.

The function takes the matrix `a` and returns a pair of `(a;fl)` where `a` is the modified matrix
and `fl` is a boolean matrix indicating which octopus flashed.

We start the step by increasing every value in the matrix by 1:
```q
q)a+:1
q)a
6 5 9 4 2 5 4 3 3 4
3 8 5 6 9 6 5 8 2 2
6 3 7 5 6 6 7 2 8 4
...
```
The next part is actually more intersting in the 2nd generation when there are actual flashes:
```q
q)a
7 6  10 5 3  6  5  4 4 5
4 9  6  7 10 7  6  9 3 3
7 4  8  6 7  7  8  3 9 5
...
```
We find the octopuses that flashed using an iterated function since the flashes may spread.
Initially the flash matrix is empty:
```q
q)fl:a<>a
q)fl
0000000000b
0000000000b
0000000000b
...
```
`a<>a` is an easy way to create an all-zero matrix to match the size of another.
To make the next calculation easier, we add a border of zeros around the matrix:
```q
q)w:count first a
q)a:0,/:(enlist[w#0],a,enlist[w#0]),\:0
0 0 0  0  0 0  0  0  0 0 0  0
0 7 6  10 5 3  6  5  4 4 5  0
0 4 9  6  7 10 7  6  9 3 3  0
0 7 4  8  6 7  7  8  3 9 5  0
...
```
We also do the same with the flash array:
```q
q)fl:0b,/:(enlist[w#0b],fl,enlist[w#0b]),\:0b
q)fl
000000000000b
000000000000b
000000000000b
...
```
We determine which octopuses flash at this step by checking which have a level higher than 10 but
not being marked as flashing yet:
```q
q)nfl:(a>9) and not fl
q)nfl
000000000000b
000100000000b
000001000000b
...
```
Then we rotate this new flash matrix in 3*3 direcions: by -1, 1 and 0 both horizontally and
vertically. The order is important because rotating by 0 in both directions just leaves the matrix
alone, so putting the 0 last allows it to be easily dropped.

The expression needs precise usage of iterators to fall into place:
```q
    -1 1 0 rotate/:\:nfl
```
This rotates every row. The `/:` after rotate is necessary because we descend into the matrix as
opposed to rotating the matrix itself (which would rotate the columns). The `\:` is necessary
because we are rotating by 3 different amounts. The order `\:/:` is important as the opposite order
would put the items in the wrong order in the result.
```q
    -1 1 0 rotate\:/:-1 1 0 rotate/:\:nfl
```
The second rotate applies to the columns. We need both iterators again, but this time in the
opposite order. This ensures that after razing the resulting 4-dimensional array, we get a list of
matrices in the original dimension. Then we drop the last element that we don't need.
The artifical border is useful here because it allows the usage of rotate without worrying about
unwanted elements wrapping around. There is no "shift in zeros" function in q. (There is `next` and
`prev` but those shift in nulls and they also don't work properly on matrices.)
```q
q)nfls:-1_raze -1 1 0 rotate\:/:-1 1 0 rotate/:\:nfl
q)nfls
000000000000b 000000000000b 000010000000b 000000100000b 000000000000b 0000000..
000010000000b 000000100000b 000000000000b 000000000000b 000000010001b 0000000..
000000000000b 000010000000b 000000100000b 000000000000b 000000000000b 0000000..
...
```
To find out how much to increase the energy levels by, all we need to do is sum these matrices.
```q
q)sum nfls
0 0 1 1 1 0 0 0 0 0 0 0
0 0 1 0 2 1 1 0 0 0 0 0
0 0 1 1 2 0 1 0 0 0 0 0
...
q)a+:sum nfls
q)a
0 0  1  1  1  0  0  0  0 0  0  0
0 7  7  10 7  4  7  5  4 4  5  0
0 4  10 7  9  10 8  6  9 3  3  0
...
```
We also update the `fl` matrix to avoid flashing the same octopus multiple times:
```q
q)fl:fl or nfl
q)fl
000000000000b
000100000000b
000001000000b
...
```
Finally we strip the artificial borders, which gets rid of the effects outside the board.
```q
q)a:-1_/:1_/:-1_1_a
q)a
7  7  10 7  4  7  5  4 4  5
4  10 7  9  10 8  6  9 3  3
7  4  8  7  8  8  8  3 9  5
...
q)fl:-1_/:1_/:-1_1_fl
q)fl
0010000000b
0000100000b
0000000000b
...
```
This flashing function is iterated using `/` (over) with the
[overload](https://code.kx.com/q/ref/accumulators/#converge) that takes a unary function and
calls it repeatedly on a value until the output is no longer different from the input. We start the
iteration from the all-zero `fl` matrix and the initial `a` matrix, passing them in as a list to
make the function unary, and return a similar pair. After all the flashes are processed, we extract
the final matrices which might look like this:
```q
q)a
8  8  11 7  4  7  6  5  5  5
5  10 8  9  10 8  7  10 5  4
8  5  9  7  8  8  9  6  12 8
8  4  8  5  7  6  9  6  10 12
8  7  10 13 9  11 8  8  12 13
6  6  13 16 13 8  8  9  8  9
6  8  15 16 17 10 5  9  4  3
10 15 17 12 18 16 7  4  5  6
9  15 13 16 18 12 13 8  7  6
8  7  14 10 14 11 6  8  4  8
q)fl
0010000000b
0100100100b
0000000010b
0000000011b
0011010011b
0011100000b
0011110000b
1111110000b
0111111000b
0011110000b
```
The last step we need to do is set the flashed octopuses to zero. This can be done by multiplying
the `a` matrix by the logical NOT of the `fl` matrix.
```q
q)a:not[fl]*a
q)a
8 8 0 7 4 7 6 5 5 5
5 0 8 9 0 8 7 0 5 4
8 5 9 7 8 8 9 6 0 8
8 4 8 5 7 6 9 6 0 0
8 7 0 0 9 0 8 8 0 0
6 6 0 0 0 8 8 9 8 9
6 8 0 0 0 0 5 9 4 3
0 0 0 0 0 0 7 4 5 6
9 0 0 0 0 0 0 8 7 6
8 7 0 0 0 0 6 8 4 8
```
We also return both `a` and `fl` (in in the form of a two-element list). For part 1, we add the sum
of all the elements in `fl` to a running total. After 100 iterations this running total is
returned.
```q
    tf:0;
    do[100;
        fla:d11step[a];
        fl:fla 0; a:fla 1;
        tf+:sum sum fl;
    ];
```

## Part 2
The step function is the same, the only difference is that instead of a running total, we count the
number of steps, and check whether all elements of `fl` are true. If so, we return the number of
the current step. Since we don't know the number of iterations in advance, it is easier to write
this as a while loop with a condition of true. The return statement will break out of it.
```q
    gen:0;
    while[1b;
        gen+:1;
        fla:d11step[a];
        fl:fla 0; a:fla 1;
        if[all all fl; :gen];
    ];
```
