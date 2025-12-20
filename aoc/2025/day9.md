# Breakdown
Example input:
```q
x:"\n"vs"7,1\n11,1\n11,7\n9,7\n9,5\n2,5\n2,3\n7,3"
```

## Part 1
We split the input lines on commas and convert them to integers:
```q
q)"J"$","vs/:x
7  1
11 1
11 7
9  7
9  5
2  5
2  3
7  3
```
We generate the areas of each rectangle by calling a function with `/:\:` (combined each right and
each left). The function takes the absolute differences, adding one to the result because of the
coordinates being inclusive, and multiplies them together.
```q
q){{prd 1+abs x-y}/:\:[x;x]}"J"$","vs/:x
1  5  35 21 15 30 18 3
5  1  7  21 15 50 30 15
35 7  1  3  9  30 50 25
21 21 3  1  3  24 40 15
15 15 9  3  1  8  24 9
30 50 30 24 8  1  3  18
18 30 50 40 24 3  1  6
3  15 25 15 9  18 6  1
```
The answer is the overall maximum in this matrix.
```q
q)max max{{prd 1+abs x-y}/:\:[x;x]}"J"$","vs/:x
50
```

## Part 2
We need to generate the full map to decide which coordinates are inside the polygon. However, with
the large magnitudes of the numbers in the real input, this would generate a lot of waste because of
all the identical tiles between two adjacent values of one coordinate. So we first remap the input
coordinates into a smaller space by gathering up the values for each coordinate and looking them up
with `?`. We multiply the result by two to allow for proper handling of gaps between parallel edges,
and add one to make sure that the coordinate 0 corresponds to a fully empty row/column as opposed to
handling the special cases involved with the polygon touching the edges. We also swap the two
coordinates such that the row index comes first.
```q
q)xm:asc distinct a[;0]
q)xm
`s#2 7 9 11
q)ym:asc distinct a[;1]
q)ym
`s#1 3 5 7
q)b:1+2*(ym?a[;1]),'(xm?a[;0])
q)b
1 3
1 7
7 7
7 5
5 5
5 1
3 1
3 3
```
We initialize a grid that can fit the reduced coordinates, also leaving enough space for a blank
edge:
```q
q)grid:(2+max b)#"."
q)grid
"........."
"........."
"........."
"........."
"........."
"........."
"........."
"........."
"........."
```
We populate the grid using an iterated function. The accumulator is the grid and the current
position. The initial value for the position is the first coordinate pair, and the list to iterate
over is the coordinate list rotated by one (the rotation is to make sure that we return to the
starting point at the end). We ignore the current coordinate when assigning the final result.
```q
    (grid;):{[(grid;p);nxt]
        ...
    }/[(grid;b 0);1 rotate b];

q)p:b 0
q)nxt:b 1
q)p
1 3
q)nxt
1 7
```
Inside the function, we first take the difference (vector) between the next and current position:
```q
q)v:nxt-p
q)v
0 4
```
We calculate the length of the vector by taking the absolute sum (only one coordinate will be
nonzero for a well-formed input):
```q
q)l:abs sum v
q)l
4
```
We generate the coordinates to update by dividing the vector by its length and then multiplying it
by every number from 0 up to the length plus 1:
```q
q)p+/:(v div l)*/:til 1+l
1 3
1 4
1 5
1 6
1 7
```
We update the grid using an iterated [functional amend](https://code.kx.com/q/ref/amend/):
```q
q).[;;:;"O"]/[grid;p+/:(v div l)*/:til 1+l]
"........."
"...OOOOO."
"........."
"........."
"........."
"........."
"........."
"........."
"........."
```
The new value of the accumulator is this updated grid plus the new coordinate, which is just `nxt`.
```q
    (.[;;:;"O"]/[grid;p+/:(v div l)*/:til 1+l];nxt)
```
At the end of the iteration, the grid will contain the full polygon:
```q
q)grid
"........."
"...OOOOO."
"...O...O."
".OOO...O."
".O.....O."
".OOOOO.O."
".....O.O."
".....OOO."
"........."
```
We need to find which other cells of the grid are insde the polygon. We can instead find which cells
are outside by doing a BFS starting at the top left corner (this is why the doubling of the
coordinates and the offset by 1 are important).
```q
    queue:enlist 0 0;
    while[count queue;
        grid:.[;;:;"X"]/[grid;queue];
        nxts:raze queue+/:\:(-1 0;0 -1;1 0;0 1);
        queue:distinct nxts where"."=grid ./:nxts;
    ];

q)grid
"XXXXXXXXX"
"XXXOOOOOX"
"XXXO...OX"
"XOOO...OX"
"XO.....OX"
"XOOOOO.OX"
"XXXXXO.OX"
"XXXXXOOOX"
"XXXXXXXXX"
```
Now that we have the outside cells marked, we can fill the inside cells by replacing all the `.`
characters with `O` characters, which entails adding 33 (the difference between the ASCII codes of
`O` and `.`) for cells where the grid contains a `.`. Characters are not arithmetic in q, but we can
cast them to integers, perform the arithmetic, then cast them back to characters.
```q
q)grid:`char$(`int$grid)+33*grid="."
q)grid
"XXXXXXXXX"
"XXXOOOOOX"
"XXXOOOOOX"
"XOOOOOOOX"
"XOOOOOOOX"
"XOOOOOOOX"
"XXXXXOOOX"
"XXXXXOOOX"
"XXXXXXXXX"
```
Now we are ready to check which rectangles are fully inside the polygon. We generate ID pairs,
making sure to not include any self-pairs or reversed pairs:
```q
q)ind:til count b
q)ind
0 1 2 3 4 5 6 7
q)raze ind,/:'(1+ind)_\:ind
0 1
0 2
0 3
0 4
0 5
0 6
0 7
1 2
1 3
1 4
1 5
1 6
1 7
2 3
2 4
2 5
2 6
2 7
3 4
3 5
3 6
3 7
..
```
We index into the coordinate array to find the coordinates of the rectangle corners:
```q
q)c:b raze ind,/:'(1+ind)_\:ind
q)c
1 3 1 7
1 3 7 7
1 3 7 5
1 3 5 5
1 3 5 1
1 3 3 1
1 3 3 3
1 7 7 7
1 7 7 5
1 7 5 5
1 7 5 1
1 7 3 1
1 7 3 3
7 7 7 5
7 7 5 5
7 7 5 1
7 7 3 1
7 7 3 3
7 5 5 5
7 5 5 1
7 5 3 1
7 5 3 3
..
```
We find which rectangles are inside the polygon by generating all the coordinates covered by the
rectangle, separately for the first and second coordinate, and using these coordinate lists as
indices into the grid, since multi-dimensional indexing involves a cross product:
```q
q){[grid;x]a:min x;b:max x;grid . a+til each 1+b-a}[grid]each c
,"OOOOO"
("OOOOO";"OOOOO";"OOOOO";"OOOOO";"OOOOO";"XXOOO";"XXOOO")
("OOO";"OOO";"OOO";"OOO";"OOO";"XXO";"XXO")
("OOO";"OOO";"OOO";"OOO";"OOO")
("XXO";"XXO";"OOO";"OOO";"OOO")
("XXO";"XXO";"OOO")
(,"O";,"O";,"O")
(,"O";,"O";,"O";,"O";,"O";,"O";,"O")
("OOO";"OOO";"OOO";"OOO";"OOO";"OOO";"OOO")
("OOO";"OOO";"OOO";"OOO";"OOO")
("XXOOOOO";"XXOOOOO";"OOOOOOO";"OOOOOOO";"OOOOOOO")
("XXOOOOO";"XXOOOOO";"OOOOOOO")
("OOOOO";"OOOOO";"OOOOO")
,"OOO"
("OOO";"OOO";"OOO")
("OOOOOOO";"XXXXOOO";"XXXXOOO")
("OOOOOOO";"OOOOOOO";"OOOOOOO";"XXXXOOO";"XXXXOOO")
("OOOOO";"OOOOO";"OOOOO";"XXOOO";"XXOOO")
(,"O";,"O";,"O")
("OOOOO";"XXXXO";"XXXXO")
("OOOOO";"OOOOO";"OOOOO";"XXXXO";"XXXXO")
("OOO";"OOO";"OOO";"XXO";"XXO")
..
q){[grid;x]a:min x;b:max x;all"O"=raze grid . a+til each 1+b-a}[grid]each c
1001001111001110001000111111b
q)d:c where{[grid;x]a:min x;b:max x;all"O"=raze grid . a+til each 1+b-a}[grid]each c
q)d
1 3 1 7
1 3 5 5
1 3 3 3
1 7 7 7
1 7 7 5
1 7 5 5
1 7 3 3
7 7 7 5
7 7 5 5
7 5 5 5
5 5 5 1
5 5 3 1
5 5 3 3
5 1 3 1
5 1 3 3
3 1 3 3
```
Finally we map the coordinates back to their original versions, then find the sizes and find the
maximum of them:
```q
q)(d-1)div 2
0 1 0 3
0 1 2 2
0 1 1 1
0 3 3 3
0 3 3 2
0 3 2 2
0 3 1 1
3 3 3 2
3 3 2 2
3 2 2 2
2 2 2 0
2 2 1 0
2 2 1 1
2 0 1 0
2 0 1 1
1 0 1 1
q)(ym;xm)@'/:/:(d-1)div 2
1 7  1 11
1 7  5 9
1 7  3 7
1 11 7 11
1 11 7 9
1 11 5 9
1 11 3 7
7 11 7 9
7 11 5 9
7 9  5 9
5 9  5 2
5 9  3 2
5 9  3 7
5 2  3 2
5 2  3 7
3 2  3 7
q){prd 1+abs y-x}./:(ym;xm)@'/:/:(d-1)div 2
5 15 3 7 21 15 15 3 9 3 8 24 9 3 18 6
q)max{prd 1+abs y-x}./:(ym;xm)@'/:/:(d-1)div 2
24
```
