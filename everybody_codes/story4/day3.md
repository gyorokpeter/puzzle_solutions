# Breakdown

## Part 1
Example input:
```q
x:()
x,:enlist"width=30"
x,:enlist"height=10"
x,:enlist"horizontal-offsets=10011"
x,:enlist"vertical-offsets=11011"
```
We cut on `=` characters and only keep the last part of each line:
```q
q)"="vs/:x
"width"              "30"
"height"             "10"
"horizontal-offsets" "10011"
"vertical-offsets"   "11011"
q)a:last each"="vs/:x
q)a
"30"
"10"
"10011"
"11011"
```
We extract the width and height into variables by casting the relevant elements to integers:
```q
q)(w;h):"J"$2#a
q)w
30
q)h
10
```
We also extract the horizontal and vertical offsets. Note that we need the `/:` (each right)
iterators here, otherwise `$` would try to conver the whole strings into numbers instead of the
individual characters.
```q
q)(ho;vo):"J"$/:/:a 2 3
q)ho
1 0 0 1 1
q)vo
1 1 0 1 1
```
We generate the full horizontal and vertical patterns by extending the offsets to width/height plus
one:
```q
q)vpat
1 0 0 1 1 1 0 0 1 1 1
q)hpat:(w+1)#vo
q)hpat
1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1
```
We generate the full shifted pattern for each row by repeating the list `01b` to fill up the while
width and subtracting it from the offset pattern, turning it back into a boolean value by modulo'ing
it by 2:
```q
q)w#10b
101010101010101010101010101010b
q)vpat-\:w#10b
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
-1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0
-1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
-1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0
-1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 0
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1 0  1
q)(vpat-\:w#10b)mod 2
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0
1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0
1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
```
From this pattern, we figure out which squares are horizontally bounded by two lines. We can do this
by taking the logical AND of the matrix with a version shifted by one row up. Instead of actually
shifting, we remove the first row in one case and the last row in the other case, so we get two
equal-sized matrices, then AND the two together.
```q
q)hb:{(1_x)and -1_x}(vpat-\:w#10b)mod 2
q)hb
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
```
We also perform the same operations in the vertical direction. Since this would result in a matrix
with the rows and columns swapped, we flip it to give it the correct orientation.
```q
q)vb:flip{(1_x)and -1_x}(hpat-\:h#10b) mod 2
q)vb
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1 1 0 0 1 1
```
The tiles we have to count are those that are both horizontally and vertically bounded, wich is the
logical AND of these two matrices.
```q
q)hb and vb
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 1 0 0 0 1 0 1 0 0 0 1 0 0 0 1 0 1 0 0 0 1 0 0 0 1 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 1 0 1 0 0 0 1 0 0 0 1 0 1 0 0 0 1 0 0 0 1 0 1 0 0 0 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 1 0 1 0 0 0 1 0 0 0 1 0 1 0 0 0 1 0 0 0 1 0 1 0 0 0 1
q)sum sum hb and vb
27
```

## Part 2 and 3
The following solution already implements the shortcut that is needed to solve part 3, but is also
able to solve part 2.

Example input:
```q
x:()
x,:enlist"width=100"
x,:enlist"height=70"
x,:enlist"horizontal-offsets=111101111101101111000100100110"
x,:enlist"vertical-offsets=110100001110111011101000001111"
```
Input parsing is as in part 1.
```q
q)a:last each"="vs/:x
q)(w;h):"J"$2#a
q)(ho;vo):"J"$/:/:a 2 3
q)w
100
q)h
70
q)ho
1 1 1 1 0 1 1 1 1 1 0 1 1 0 1 1 1 1 0 0 0 1 0 0 1 0 0 1 1 0
q)vo
1 1 0 1 0 0 0 0 1 1 1 0 1 1 1 0 1 1 1 0 1 0 0 0 0 0 1 1 1 1
```
The trick is that the pattern repeats, so we don't have to generate the full map, only a small
segment of it. The size of the repeating pattern should be twice of the length of the offset list
(since the parity may change after just a single iteration). We also need to account for the fact
that the full map width may not be an integer multiple of the repeated tile.

We calculate the tile width and height:
```q
q)tw:2*count vo;th:2*count ho;
q)tw
60
q)th
60
```
We calculate the size of the generated map segment by taking the minimum of the map size and the
segment size with the appropriate padding:
```q
q)mw:min(w;tw+w mod tw)
q)mh:min(h;th+h mod th)
q)mw
100
q)mh
70
```
We calculate the number of full tiles in both directions:
```q
q)htc:w div tw;vtc:h div th
q)htc
1
q)vtc
1
```
We generate the isolated tiles similarly to part 1, this time using the modified width and height:
```q
q)vpat:(mh+1)#ho
q)hpat:(mw+1)#vo
q)he:(vpat-\:mw#10b)mod 2
q)ve:(hpat-\:mh#10b) mod 2
q)hb:{(1_x)and -1_x}he
q)vb:flip{(1_x)and -1_x}ve
q)iso
0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 ..
0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
..
```
This time we also have to calculate the parity-based color of each tile. We can do this using a `+\`
(addition with scan) operator, which just creates the rolling sums of a list, which we can turn into
parities by `mod`ding them by 2. Whether we have a border at the top is irrelevant, so we drop the
first element, and put a 0 as the first element of the result to fix the starting color.
```q
q)leftc:(0,0+\1_-1_he[;0])mod 2
q)leftc
0 0 0 0 1 1 1 1 1 1 0 0 0 1 1 1 1 1 0 1 0 0 1 0 0 1 0 0 0 1 1 1 1 1 0 0 0 0 0 0 1 1 1 0 0 0 0 0 1 ..
```
This gives the colors of the left edge of the map. To get the rest of the map, we repeat the same
kind of operation, but adding the entire vertical pattern, also flipping the result to ensure the
correct orientation:
```q
q)color
0 0 1 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 1 0 1 0 1 1 1 1 1 1 1 0 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 ..
0 1 1 0 0 0 0 0 1 0 1 1 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 0 1 0 1 0 0 1 1 1 1 1 0 1 0 0 1 0 1 1 0 1 0 ..
0 0 1 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 1 0 1 0 1 1 1 1 1 1 1 0 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 ..
0 1 1 0 0 0 0 0 1 0 1 1 0 1 0 0 1 0 1 1 0 0 0 0 0 0 1 0 1 0 1 0 0 1 1 1 1 1 0 1 0 0 1 0 1 1 0 1 0 ..
1 1 0 0 1 0 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 0 1 0 1 0 0 0 0 0 0 0 1 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 1 ..
1 0 0 1 1 1 1 1 0 1 0 0 1 0 1 1 0 1 0 0 1 1 1 1 1 1 0 1 0 1 0 1 1 0 0 0 0 0 1 0 1 1 0 1 0 0 1 0 1 ..
..
```
(This matches the color pattern of the second example.)

We generate the isolated tiles of both colors by doing a logical AND between the `iso` matrix and
the `color` matrix (inverting the `color` matrix for the second color):
```q
q)iso and color
0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 ..
0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
..
q)iso and not color
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
..
```
We prepare the colored isolated tile matrices for the tiling trick by summing the numbers in four
regions: the top left is the region that is repeated both horizontally and vertcically, the top
right is only repeated vertically, the bottom left is only repeated horizontally, and the bottom
right is not repeated. To split up the matrices, we cut on the tile size in both directions, then
apply `sum` with the right iterator combination to sum only within the respective region.
```q
q)(0;th)cut(0;tw)cut/:iso and color
((0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
((0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ..
q)(0;th)cut(0;tw)cut/:iso and not color
((0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 ..
((0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 ..
q)isoA:`long$sum each/:sum each(0;th)cut(0;tw)cut/:iso and color
q)isoB:`long$sum each/:sum each(0;th)cut(0;tw)cut/:iso and not color
q)isoA
136 88
27  18
q)isoB
136 88
27  16
```
We calculate the number of colored isolated tiles for the full map by multiplying each element by
the corresponding sizes that it needs to be repeated by:
```q
q)totalA:sum 0^(isoA[1;1];htc*isoA[1;0];vtc*isoA[0;1];htc*vtc*isoA[0;0])
q)totalB:sum 0^(isoB[1;1];htc*isoB[1;0];vtc*isoB[0;1];htc*vtc*isoB[0;0])
q)totalA
269
q)totalB
267
```
(The usage of `0^` and the usage of a list with `sum` instead of the `+` operator is just to avoid
having to special-case the calculation if any of the regions is empty.)

Now that we have two totals, we return the greater one of them:
```q
q)max(totalA;totalB)
269
```
