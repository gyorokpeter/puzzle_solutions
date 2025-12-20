# Breakdown
Example input:
```q
x:()
x,:enlist"..@@.@@@@."
x,:enlist"@@@.@.@.@@"
x,:enlist"@@@@@.@.@@"
x,:enlist"@.@@@@..@."
x,:enlist"@@.@@@@.@@"
x,:enlist".@@@@@@@.@"
x,:enlist".@.@.@.@@@"
x,:enlist"@.@@@.@@@@"
x,:enlist".@@@@@@@@."
x,:enlist"@.@.@@@.@."
```

## Common
The logic to simulate one step is the helper function `d4`. It takes one parameter, which we obtain
by comparing the input to the `"@"` character, resulting in a boolean matrix:
```q
q)a:x="@"
q)a
0011011110b
1110101011b
1111101011b
1011110010b
1101111011b
0111111101b
0101010111b
1011101111b
0111111110b
1010111010b

    d4:{[a]
        ...
    };
```
To find the number of rolls in adjacent cells, we overlay shifted versions of the grid over itself.
The basic idea of a shift is to drop one row/column at one end, and insert a row/column of zeros at
the corresponding opposite end. This is achieved by using a combination of drop and join with
copious amounts of iterators.
```q
q)0b,/:-1_/:a     //shifted right
0001101111b
0111010101b
0111110101b
0101111001b
0110111101b
0011111110b
0010101011b
0101110111b
0011111111b
0101011101b
q)(1_/:a),\:0b      //shifted left
0110111100b
1101010110b
1111010110b
0111100100b
1011110110b
1111111010b
1010101110b
0111011110b
1111111100b
0101110100b
```
For inserting a row of zeros, it is useful to pregenerate this row:
```q
q)f:00b a 0
q)f
0000000000b
q)enlist[f],-1_a    //shifted down
0000000000b
0011011110b
1110101011b
1111101011b
1011110010b
1101111011b
0111111101b
0101010111b
1011101111b
0111111110b
q)(1_a),enlist[f]   //shifted up
1110101011b
1111101011b
1011110010b
1101111011b
0111111101b
0101010111b
1011101111b
0111111110b
1010111010b
0000000000b
```
By putting these four shifted grids into a list, we can more easily generate the diagonally shifted
variants by applying the left/right shift to the shifted-up/down grids:
```q
q)r:(0b,/:-1_/:a;(1_/:a),\:0b;enlist[f],-1_a;(1_a),enlist[f])
q)0b,/:-1_/:r 2
0000000000b
0001101111b
0111010101b
0111110101b
0101111001b
0110111101b
0011111110b
0010101011b
0101110111b
0011111111b
q)(1_/:r 2),\:0b
0000000000b
0110111100b
1101010110b
1111010110b
0111100100b
1011110110b
1111111010b
1010101110b
0111011110b
1111111100b
q)0b,/:-1_/:r 3
0111010101b
0111110101b
0101111001b
0110111101b
0011111110b
0010101011b
0101110111b
0011111111b
0101011101b
0000000000b
q)(1_/:r 3),\:0b
1101010110b
1111010110b
0111100100b
1011110110b
1111111010b
1010101110b
0111011110b
1111111100b
0101110100b
0000000000b
```
We can add these to the first four grids:
```q
q)r,:(0b,/:-1_/:r 2;(1_/:r 2),\:0b;0b,/:-1_/:r 3;(1_/:r 3),\:0b)
```
Summing the list of grids results in the number of filled neighbors for each cell:
```q
q)sum r
2 4 3 3 3 3 3 4 3 3
3 6 6 7 4 6 4 7 5 4
4 7 6 7 5 6 2 5 4 4
4 7 6 7 7 6 4 5 4 5
3 5 7 7 8 7 5 5 4 3
4 4 6 5 7 6 6 5 7 4
3 4 7 6 7 5 7 6 7 4
2 5 6 6 6 6 6 7 7 4
3 5 5 7 6 7 6 7 5 4
1 4 3 5 4 5 4 5 2 2
```
The condition for a cell dying is this number being less than 4, as well as it being alive in the
original grid:
```q
q)(4>sum r)
1011111011b
1000000000b
0000001000b
0000000000b
1000000001b
0000000000b
1000000000b
1000000000b
1000000000b
1010000011b
q)(4>sum r)and a
0011011010b
1000000000b
0000001000b
0000000000b
1000000001b
0000000000b
0000000000b
1000000000b
0000000000b
1010000010b
```

## Part 1
We apply the helper function to the input and sum the result:
```q
q)d4 a
0011011010b
1000000000b
0000001000b
0000000000b
1000000001b
0000000000b
0000000000b
1000000000b
0000000000b
1010000010b
q)sum sum d4 a
13i
```

## Part 2
To generate the next state of the grid, we can do `a and not d4 a`. We would like to repeat this
until there is no change in the grid. Fortunately there is an overload of [`/`](https://code.kx.com/q/ref/accumulators/#converge)
that repeatedly calls a function on a value until it stops changing. So we call this overload with
the succession function and the initial state.
```q
q)a2:{x and not d4 x}/[a]
q)a2
0000000000b
0000000000b
0000000000b
0000110000b
0001111000b
0001111100b
0001010110b
0001101110b
0001111100b
0000111000b
```
The answer is the sum of the original grid with the modified grid `not`ted out.
```q
q)a and not a2
0011011110b
1110101011b
1111101011b
1011000010b
1100000011b
0110000001b
0100000001b
1010000001b
0110000010b
1010000010b
q)sum sum a and not a2
43i
```
