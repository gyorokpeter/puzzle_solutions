# Breakdown
Example input:
```q
q)md5 raze x
0x9fdf4482dab09e5ee25714e277671ac4
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

This puzzle requires finding a hidden pattern in the real input that is not present in the examples.
In particular, every case can be classified into one of two categories:
* The grid is too small, such that if we count the number of cells needed to hold all the required
  pieces, we get a bigger number than the grid size.
* The grid is so large that if we divide it into 3x3 regions (even disregarding odd strips of cells
  on the edges if the dimensions are not divisible by 3) we get enough regions for the required
  number of pieces, so we don't have to worry about rotating pieces or fitting them together.

We join the input together to be able to split on the empty lines:
```q
q)a:"\n\n"vs"\n"sv x
q)a
"0:\n#..\n##.\n.##"
"1:\n###\n.##\n##."
"2:\n###\n###\n#.."
"3:\n..#\n.##\n###"
"4:\n###\n.#.\n###"
"5:\n###\n..#\n###"
"42x45: 51 48 40 49 56 48\n40x47: 38 43 52 44 61 48\n49x41: 48 45 53 62 51 51\n50x44: 42 38 32 45 ..
```
We find the shape sizes by counting the number of `#` characters, droppin the last line which is not
a shape:
```q
q)shsz:sum each sum each "#"=-1_a
q)shsz
5 7 7 6 7 7i
```
We split the last line on newlines and then on `": "`:
```q
q)b:": "vs/:"\n"vs last a
q)b
"42x45" "51 48 40 49 56 48"
"40x47" "38 43 52 44 61 48"
"49x41" "48 45 53 62 51 51"
"50x44" "42 38 32 45 34 32"
"45x41" "46 49 42 48 51 48"
..
```
We find the grid sizes by splitting the first elements on `"x"` and converting to integers:
```q
q)flds:"J"$"x"vs/:b[;0]
q)flds
42 45
40 47
49 41
50 44
45 41
..
```
We find the piece counts for each grid by splitting the last elements on `" "` and converting to
integers:
```q
q)fldc:"J"$" "vs/:b[;1]
q)fldc
51 48 40 49 56 48
38 43 52 44 61 48
48 45 53 62 51 51
42 38 32 45 34 32
46 49 42 48 51 48
..
```
We find which grids fit into the "too big" category. To do this, we multiply the piece sizes by the
counts and sum them, then multiply the two dimensions of the grids together, so we get two numbers
that can be compared:
```q
q)shsz*/:fldc
255 336 280 294 392 336
190 301 364 264 427 336
240 315 371 372 357 357
210 266 224 270 238 224
230 343 294 288 357 336
..
q)sum each shsz*/:fldc
1893 1882 2012 1432 1848..
q)prd each flds
1890 1880 2009 2200 1845..
q)tooBig:(prd each flds)<sum each shsz*/:fldc
q)tooBig
11101111111100001001000001111100111101100011101110101101111001001111100110111111000101100110000000..
```
We also find which fields are trivially fillable. This is not strictly necessary, but I added it
just so that my code can reject inputs that don't follow the pattern of the real input.
```q
q)sum each fldc
292 286 310 223 284..
q)prd each flds div 3
210 195 208 224 195..
q)trivialFill
00010000000011110110111110000011000010011100010001010010000110110000011001000000111010011001111111..
```
We reject any inputs that don't fall into either category:
```q
    if[any bad:where not tooBig or trivialFill;'"nontrivial cases: ",","sv string bad];
```
Since we are looking for grids that _can_ be filled, the `trivialFill` variable tells just that:
```q
q)sum trivialFill
406i
```
