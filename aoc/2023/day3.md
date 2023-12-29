# Breakdown

Example input:
```q
x:();
x,:enlist"467..114..";
x,:enlist"...*......";
x,:enlist"..35..633.";
x,:enlist"......#...";
x,:enlist"617*......";
x,:enlist".....+.58.";
x,:enlist"..592.....";
x,:enlist"......755.";
x,:enlist"...$.*....";
x,:enlist".664.598..";
```

## Common

We start by finding the numbers and the area they touch.

We check every character for wheter it is a digit by testing for set membership in `.Q.n`:
```q
q)a:x in .Q.n
q)a
1110011100b
0000000000b
0011001110b
0000000000b
1110000000b
0000000110b
0011100000b
0000001110b
0000000000b
0111011100b
```
To isolate the numbers, we cut the input on the positions where "digitness" switches between false and true:
```q
q)differ each a
1001010010b
1000000000b
1010101001b
1000000000b
1001000000b
1000000101b
1010010000b
1000001001b
1000000000b
1100110010b
q)where each differ each a
0 3 5 8
,0
0 2 4 6 9
,0
0 3
0 7 9
0 2 5
0 6 9
,0
0 1 4 5 8
q)b:(where each differ each a)cut'x
q)b
("467";"..";"114";"..")
,"...*......"
("..";"35";"..";"633";,".")
,"......#..."
("617";"*......")
(".....+.";"58";,".")
("..";"592";".....")
("......";"755";,".")
,"...$.*...."
(,".";"664";,".";"598";"..")
```
We parse the numbers to integers and also calculate their lengths, for now ignoring the fact that not all of the cuts are actually numbers:
```q
q)num:"J"$b
q)num
467 0N 114 0N
,0N
0N 35 0N 633 0N
,0N
617 0N
0N 58 0N
0N 592 0N
0N 755 0N
,0N
0N 664 0N 598 0N
q)len:count each/:b
q)len
3 2 3 2
,10
2 2 2 3 1
,10
3 7
7 2 1
2 3 5
6 3 1
,10
1 3 1 3 2
```
We calculate the horizontal ranges covered by every number. To find the start of the interval we calculate the cumulative sums of the lengths starting with zero:
```q
q)sums each 0,/:len
0 3 5 8 10
0 10
0 2 4 6 9 10
0 10
0 3 10
0 7 9 10
0 2 5 10
0 6 9 10
0 10
0 1 4 5 8 10
```
Each interval is obtained by pairing up the starting position minus 1 with the next interval's starting position. The range must include the first position after the end of a number, and the split points calculated above are exactly that so we don't need to add or subtract anything. As there are one more split points than intervals, we also have to drop the last point when calculating the start points and similarly the first point in case of the end points.
```q
q)-1+-1_/:sums each 0,/:len
-1 2 4 7
,-1
-1 1 3 5 8
,-1
-1 2
-1 6 8
-1 1 4
-1 5 8
,-1
-1 0 3 4 7
q)1_/:sums each 0,/:len
3 5 8 10
,10
2 4 6 9 10
,10
3 10
7 9 10
2 5 10
6 9 10
,10
1 4 5 8 10
q)xr:{(-1+-1_/:x),''1_/:x}sums each 0,/:len
q)xr
(-1 3;2 5;4 8;7 10)
,-1 10
(-1 2;1 4;3 6;5 9;8 10)
,-1 10
(-1 3;2 10)
(-1 7;6 9;8 10)
(-1 2;1 5;4 10)
(-1 6;5 9;8 10)
,-1 10
(-1 1;0 4;3 5;4 8;7 10)
```
The calculation of the vertical ranges is simpler - we simply have to add -1 and 1 to the row index:
```q
q){-1 1+/:x}til count num
-1 1
0  2
1  3
2  4
3  5
4  6
5  7
6  8
7  9
8  10
```
These are the vertical ranges for each row index, now we have to pair them up with the horizontal ranges. This can be done using `/:` (each-right) since we have lists on the right and single elements on the left, then `'` (each) to pairwise match up the rows. The operation that we apply this way is putting two elements into a list, which is what `enlist` does, in this case the operation should be written as `enlist[;]` to get the two-argument version but a shorthand for this is `(;)`.
```q
q)xyr:({-1 1+/:x}til count num)(;)/:'xr
q)xyr
((-1 1;-1 3);(-1 1;2 5);(-1 1;4 8);(-1 1;7 10))
,(0 2;-1 10)
((1 3;-1 2);(1 3;1 4);(1 3;3 6);(1 3;5 9);(1 3;8 10))
,(2 4;-1 10)
((3 5;-1 3);(3 5;2 10))
((4 6;-1 7);(4 6;6 9);(4 6;8 10))
((5 7;-1 2);(5 7;1 5);(5 7;4 10))
((6 8;-1 6);(6 8;5 9);(6 8;8 10))
,(7 9;-1 10)
((8 10;-1 1);(8 10;0 4);(8 10;3 5);(8 10;4 8);(8 10;7 10))
```
Now we can look into removing the non-numbers (we needed them as scaffolds while finding the intervals). To do this we first raze the lists numbers, and then find the indices of the actual numbers:
```q
q)num2:raze num
q)num2
467 0N 114 0N 0N 0N 35 0N 633 0N 0N 617 0N 0N 58 0N 0N 592 0N 0N 755 0N 0N 0N 664 0N 598 0N
q)nz:where not null num2
q)nz
0 2 6 8 11 14 17 20 24 26
```
We use this list of indices to index into the list of numbers and ranges to filter them:
```
q)num3:num2 nz
q)num3
467 114 35 633 617 58 592 755 664 598
q)xyr3:raze[xyr]nz
q)xyr3
-1 1 -1 3
-1 1 4  8
1 3  1 4
1 3  5 9
3  5 -1 3
4 6  6 9
5 7  1 5
6 8  5 9
8 10 0 4
8 10 4 8
```
The common logic is complete. This is function `d3` and it returns the pair `(num3;xyr3)`.

## Part 1

We pick up where the common logic left off:
```q
r:d3 x; num3:r 0; xyr3:r 1;
```
We find the coordinates of all the special symbols (i.e. anything that is not `"."` and not in `.Q.n`). This is a frequently occurring technique: we use `where` to generate a list of lists with the second coordinate (column) and to find the first coordinate we concatenate the row index calculated by `til` using a combination of each-right and each. We finish with `raze` to get a flat list of coordinates.
```q
q)where each not x in .Q.n,"."
`long$()
,3
`long$()
,6
,3
,5
`long$()
`long$()
3 5
`long$()
q)til[count x],/:'where each not x in .Q.n,"."
()
,1 3
()
,3 6
,4 3
,5 5
()
()
(8 3;8 5)
()
q)sp:raze til[count x],/:'where each not x in .Q.n,"."
q)sp
1 3
3 6
4 3
5 5
8 3
8 5
```
To find which numbers touch a special symbol, we check which symbol coordinates are `within` the ranges calculated by the common logic. However the required iterators are tricky due to how `within` works and what the shapes of the arguments look like. Iterators are always written deepest first. In our case the deepest operation is checking if the row coordinate is within the row coordinate range and whether the column coordinate is within the column coordinate range. Both arguments are lists of length two and we want to apply the operation pairwise so the first iterator is `'` (each). Next we want to check each symbol against each range, which assumes a Cartesian-product-like operation, which uses a combination of `/:` (each-right) and `\:` (each-left). Both orderings of these will process all pairings, but the result will be in row-first or column-first order depending on which one we use. This time we want one row for each number (right argument) so the ordering to use is `\:/:`.
```q
q)sp within'\:/:xyr3
11b 00b 01b 00b 01b 00b
10b 01b 00b 01b 00b 01b
11b 10b 01b 00b 01b 00b
10b 11b 00b 01b 00b 01b
01b 10b 11b 10b 01b 00b
00b 01b 10b 10b 00b 00b
01b 00b 01b 11b 01b 01b
00b 01b 00b 01b 10b 11b
01b 00b 01b 00b 11b 10b
00b 01b 00b 01b 10b 11b
```
The symbol is only in range of the number if both coordinates are within the respective ranges, so we need to use `all` on the small boolean lists. These are two levels deep so we need to use `each/:`.
```q
q)all each/:sp within'\:/:xyr3
100000b
000000b
100000b
010000b
001000b
000000b
000100b
000001b
000010b
000001b
```
We find which numbers have any symbol in their range, which is of course done with `any`:
```q
q)touch:any each all each/:sp within'\:/:xyr3
q)touch
1011101111b
```
To get the answer we multiply the booleans by the numbers so only the numbers corresponding to the `1b` values are kept and we sum them.
```q
q)sum num3*touch
4361
```

## Part 2

We pick up where the common logic left off:
```q
r:d3 x; num3:r 0; xyr3:r 1;
```
We find the coordinates of the special symbols like in part 1, except this time we are only looking for `"*"` symbols:
```q
q)sp:raze til[count x],/:'where each x="*";
q)sp
1 3
4 3
8 5
```
We also find out which special symbols are in range of which numbers:
```q
q)snxt:all each/:sp within'\:/:xyr3
q)snxt
100b
000b
100b
000b
010b
000b
000b
001b
000b
001b
```
To find how many numbers there are next to each symbol, we can sum this list:
```q
q)sum snxt
2 1 2i
```
The gears will be those where the number is exactly 2:
```q
q)2=sum snxt
101b
```
We use these to filter the adjacency matrix to only those symbols that have 2 numbers next to them:
```q
q)snxt[;where 2=sum snxt]
10b
00b
10b
00b
00b
00b
00b
01b
00b
01b
```
To find which numbers we need to multiply together, we should find the indices of the rows where the adjacency matrix contains a `1b` value. However the `where` function works horizontally, not vertically, so we need to `flip` the matrix first so the column indices become the indices in the list of numbers:
```q
q)flip snxt[;where 2=sum snxt]
1010000000b
0000000101b
q)numidx:where each flip snxt[;where 2=sum snxt]
q)numidx
0 2
7 9
```
To get the answer we index into the list of numbers, take the product of each row and sum the results.
```q
q)num3 numidx
467 35
755 598
q)prd each num3 numidx
16345 451490
q)sum prd each num3 numidx
467835
```
