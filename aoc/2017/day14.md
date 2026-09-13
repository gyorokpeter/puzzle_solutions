# Breakdown
Example input:
```q
q)x:"flqrgnkx"
```
This solution reuses the function `d10p2` from [day 10](day10.md).

## Part 1
We generate the strings to hash by converting the numbers from 0 to 127 into strings and appending
them preceded by a dash:
```q
q)string til 128
,"0"
,"1"
,"2"
,"3"
,"4"
..
q)"-",/:string til 128
"-0"
"-1"
"-2"
"-3"
"-4"
..
q)x,/:"-",/:string til 128
"flqrgnkx-0"
"flqrgnkx-1"
"flqrgnkx-2"
"flqrgnkx-3"
"flqrgnkx-4"
"flqrgnkx-5"
..
```
We pass this into `d10p2` to get the hashes. Since the function only calculates a single hash but
requires a string list, we `enlist` each string.
```q
q)hs:d10p2 each enlist each x,/:"-",/:string til 128
q)hs
"d4f76bdcbf838f8416ccfa8bc6d1f9e6"
"55eab3c4fbfede16dcec2c66dda26464"
"0adf13fa40e8ea815376776af3b7b231"
"ad3da28cd7b8fb99742c0e63672caf62"
"682fe48c55876aaaa11df2634f96d31a"
..
```
We interpret the individual characters as the `byte` type, which is represented in hexadecimal.
Since `$` would try to convert the entire string, we have to use `/:` (each right) to lift it two
levels down.
```q
q)"X"$/:/:hs
0x0d040f07060b0d0c0b0f0803080f080401060c0c0f0a080b0c060d010f090e06
0x05050e0a0b030c040f0b0f0e0d0e01060d0c0e0c020c06060d0d0a0206040604
0x000a0d0f01030f0a04000e080e0a0801050307060707060a0f030b070b020301
0x0a0d030d0a02080c0d070b080f0b09090704020c000e06030607020c0a0f0602
0x0608020f0e04080c05050807060a0a0a0a01010d0f020603040f09060d03010a
..
```
We also create a list of the binary representations of the first 16 natural numbers using the
overload of `vs` that converts a number to a boolean list and taking only the last 4 elements:
```q
q)-4#/:0b vs/:til 16
0000b
0001b
0010b
0011b
0100b
..
```
We apply the converted hash bytes as indices to get the bit sequences:
```q
q)(-4#/:0b vs/:til 16)"X"$/:/:hs
1101b 0100b 1111b 0111b 0110b 1011b 1101b 1100b 1011b 1111b 1000b 0011b 1000b 1111b 1000b 0100b 00..
0101b 0101b 1110b 1010b 1011b 0011b 1100b 0100b 1111b 1011b 1111b 1110b 1101b 1110b 0001b 0110b 11..
0000b 1010b 1101b 1111b 0001b 0011b 1111b 1010b 0100b 0000b 1110b 1000b 1110b 1010b 1000b 0001b 01..
1010b 1101b 0011b 1101b 1010b 0010b 1000b 1100b 1101b 0111b 1011b 1000b 1111b 1011b 1001b 1001b 01..
0110b 1000b 0010b 1111b 1110b 0100b 1000b 1100b 0101b 0101b 1000b 0111b 0110b 1010b 1010b 1010b 10..
..
```
Since this is still one level too deep, we raze each element:
```q
q)raze each(-4#/:0b vs/:til 16)"X"$/:/:hs
11010100111101110110101111011100101111111000001110001111100001000001011011001100111110101000101111..
01010101111010101011001111000100111110111111111011011110000101101101110011101100001011000110011011..
00001010110111110001001111111010010000001110100011101010100000010101001101110110011101110110101011..
10101101001111011010001010001100110101111011100011111011100110010111010000101100000011100110001101..
..
```
The answer is the sum of this matrix:
```q
q)sum sum raze each(-4#/:0b vs/:til 16)"X"$/:/:hs
8108i
```

## Part 2
We store the grid in a variable:
```q
q)grid:raze each(-4#/:0b vs/:til 16)"X"$/:/:hs
q)grid
11010100111101110110101111011100101111111000001110001111100001000001011011001100111110101000101111..
01010101111010101011001111000100111110111111111011011110000101101101110011101100001011000110011011..
00001010110111110001001111111010010000001110100011101010100000010101001101110110011101110110101011..
10101101001111011010001010001100110101111011100011111011100110010111010000101100000011100110001101..
01101000001011111110010010001100010101011000011101101010101010101010000100011101111100100110001101..
..
```
We find the regions using an iterated function. The accumulator is the number of regions found and
the grid with all the already found regions zeroed out. Thus the initial value is zero and the
initial grid:
```q
q)st:(0;grid)
```
In the function, we extract the grid into a local variable:
```q
q)grid:st[1]
```
We find the potential first positions for new regions using the
[2D search](../utils/patterns.md#2d-search) technique, although this time there is no need to do a
comparison since the values of the grid are already booleans.
```q
q)fst:raze til[count grid],/:'where each grid
q)fst
0 0
0 1
0 3
0 5
0 8
```
If this list is empty, that means we can't add any more regions, so we return the accumulator
unchanged, which will cause `/` (over) to stop iterating.
```q
    if[0=count fst; :st];
```
We pick the first element in the list for the starting position:
```q
q)start:first fst
q)start
0 0
```
We increment the first element of the state to indicate a new region:
```q
q)st[0]+:1
q)st
1
(1101010011110111011010111101110010111111100000111000111110000100000101101100110011111010100010111..
```
We perform an iteration to find the new region. We initialize the queue to consist of only the
starting position:
```q
q)queue:enlist start
q)queue
0 0
```
We iterate as long as there are items in the queue:
```q
    while[0<count queue;
        ...
    ];
```
We update the grid to zero out the queued positions. This serves both to avoid visiting the same
square multiple times and to remove the region from subsequent runs of the function.
```q
q)grid:.[;;:;0b]/[grid;queue]
q)grid
01010100111101110110101111011100101111111000001110001111100001000001011011001100111110101000101111..
01010101111010101011001111000100111110111111111011011110000101101101110011101100001011000110011011..
00001010110111110001001111111010010000001110100011101010100000010101001101110110011101110110101011..
10101101001111011010001010001100110101111011100011111011100110010111010000101100000011100110001101..
01101000001011111110010010001100010101011000011101101010101010101010000100011101111100100110001101..
..
```
We generate the adjacent positions by adding the deltas for the four main directions to each of the
queue elements. Since this introduces an additional level of nesting, we raze the list. We also use
`distinct` to avoid queuing the same position more than once.
```q
q)queue+/:\:(-1 0;0 -1;1 0;0 1)
-1 0  0  -1 1  0  0  1
q)raze queue+/:\:(-1 0;0 -1;1 0;0 1)
-1 0
0  -1
1  0
0  1
q)nxts:distinct raze queue+/:\:(-1 0;0 -1;1 0;0 1)
q)nxts
-1 0
0  -1
1  0
0  1
```
We filter the positions to those that correspond to `1b` values in the grid. Since indexing out of
bounds results in `0b`, this also removes positions outside the grid.
```q
q)queue:nxts where grid ./:nxts
q)queue
0 1
```
After the iteration, we have the entire region zeroed out:
```q
q)grid
00010100111101110110101111011100101111111000001110001111100001000001011011001100111110101000101111..
00010101111010101011001111000100111110111111111011011110000101101101110011101100001011000110011011..
00001010110111110001001111111010010000001110100011101010100000010101001101110110011101110110101011..
10101101001111011010001010001100110101111011100011111011100110010111010000101100000011100110001101..
01101000001011111110010010001100010101011000011101101010101010101010000100011101111100100110001101..
..
```
We update the grid in the accumulator with this new version and return the updated value:
```q
    st[1]:grid;
    st
```
We iterate this function using `/` (over) such that it runs until the accumulator no longer changes:
```q
    st:{[st]
        ...
    st}/[(0;grid)]};
```
After this iteration, we have the state containing the number of regions and a zeroed-out grid:
```q
q)st
1242
(0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000..
```
The answer is the first element:
```q
q)first st
1242
```
