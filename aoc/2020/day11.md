# Breakdown
Example input:
```q
x: enlist"L.LL.LL.LL"
x,:enlist"LLLLLLL.LL"
x,:enlist"L.L.L..L.."
x,:enlist"LLLL.LL.LL"
x,:enlist"L.LL.LL.LL"
x,:enlist"L.LLLLL.LL"
x,:enlist"..L.L....."
x,:enlist"LLLLLLLLLL"
x,:enlist"L.LLLLLL.L"
x,:enlist"L.LLLLL.LL"
```

## Part 1
The basic idea is similar to the well-known APL implementation of Conway's Game of Life. We rotate
the matrix by -1, 1 and 0 along both axes (in this order, such that rotation by 0 0 comes last and
is easy to drop). Then we sum the rotated matrices to get the number of neighbors of each cell and
apply the rules to generate the next state.

The core logic is an iterated function using `/` (over), using the version that stops if the input
doesn't change:
```q
    a:{[a] ... a}/[x]
```
The iteration is better explained using an intermediate state:
```q
q)a:enlist"#.LL.L#.##"
q)a,:enlist"#LLLLLL.L#"
q)a,:enlist"L.L.L..L.."
q)a,:enlist"#LLL.LL.L#"
q)a,:enlist"#.LL.LL.LL"
q)a,:enlist"#.LLLL#.##"
q)a,:enlist"..L.L....."
q)a,:enlist"#LLLLLLLL#"
q)a,:enlist"#.LLLLLL.L"
q)a,:enlist"#.#LLLL.##"
```
We generate an occupancy matrix by comparing each element with `"#"`:
```q
q)occ:a="#"
q)occ
1000001011b
1000000001b
0000000000b
1000000001b
1000000000b
1000001011b
0000000000b
1000000001b
1000000000b
1010000011b
```
We save the row and column counts for easier reference:
```q
q)rc:count occ
q)cc:count occ 0
q)rc
10
q)cc
10
```
We create an empty row that is 2 elements longer to use as padding:
```q
q)r:enlist(cc+2)#0b
q)r
000000000000b
```
We create the rotated versions of the occupancy matrix, dropping the unrotated version:
```q
q)b:-1_raze {-1 1 0 rotate/:\:x}each -1 1 0 rotate\:r,(0b,/:occ,\:0b),r
q)b
000000000000b 000000000000b 001000001011b 001000000001b 000000000000b 001000000001b 001000000000b ..
000000000000b 000000000000b 100000101100b 100000000100b 000000000000b 100000000100b 100000000000b ..
000000000000b 000000000000b 010000010110b 010000000010b 000000000000b 010000000010b 010000000000b ..
001000001011b 001000000001b 000000000000b 001000000001b 001000000000b 001000001011b 000000000000b ..
100000101100b 100000000100b 000000000000b 100000000100b 100000000000b 100000101100b 000000000000b ..
010000010110b 010000000010b 000000000000b 010000000010b 010000000000b 010000010110b 000000000000b ..
000000000000b 001000001011b 001000000001b 000000000000b 001000000001b 001000000000b 001000001011b ..
000000000000b 100000101100b 100000000100b 000000000000b 100000000100b 100000000000b 100000101100b ..
```
Summing these rotated matrices returns the number of occupied neighbors for every position:
```q
q)sum b
1 1 1 0 0 0 1 1 2 2 2 1
2 1 2 0 0 0 1 0 2 2 2 2
2 1 2 0 0 0 1 1 2 3 2 2
2 2 2 0 0 0 0 0 0 2 2 2
2 1 2 0 0 0 0 0 0 1 0 1
3 2 3 0 0 0 1 1 2 3 3 2
2 1 2 0 0 0 1 0 2 1 1 1
2 2 2 0 0 0 1 1 2 3 3 2
2 1 2 0 0 0 0 0 0 1 0 1
3 2 4 1 1 0 0 0 1 3 3 2
2 1 3 0 1 0 0 0 1 1 1 1
1 1 2 1 1 0 0 0 1 2 2 1
```
We remove the padding from the sum:
```q
q)c:1_-1_1_/:-1_/:sum b
q)c
1 2 0 0 0 1 0 2 2 2
1 2 0 0 0 1 1 2 3 2
2 2 0 0 0 0 0 0 2 2
1 2 0 0 0 0 0 0 1 0
2 3 0 0 0 1 1 2 3 3
1 2 0 0 0 1 0 2 1 1
2 2 0 0 0 1 1 2 3 3
1 2 0 0 0 0 0 0 1 0
2 4 1 1 0 0 0 1 3 3
1 3 0 1 0 0 0 1 1 1
```
Now we would like to update the original matrix with `"#"` where it had `"L"` and the neighbor
matrix has zero values:
```q
    ?[(a="L") and c=0;"#";a]    //type error
```
and similarly with `"L"` where it had `"#"` and the neighbor matrix has values of 4 or higher:
```q
    ?[(a="#") and c>=4;"L";a]   //type error
```
... except q doesn't have a "matrix conditional" operator. Instead we have to use vector conditional
with the `'` (each) iterator. We can also combine the two transformations into one:
```q
q)a:{[c;x]?[(x="L")and c=0;"#";?[(x="#")and c>=4;"L";x]]}'[c;a]
q)a
"#.##.L#.##"
"#L###LL.L#"
"L.#.#..#.."
"#L##.##.L#"
"#.##.LL.LL"
"#.###L#.##"
"..#.#....."
"#L######L#"
"#.LL###L.L"
"#.#L###.##"
```
This modified matrix is the return value of the iterated function.

After the iteration, `a` will contain the stabilized seat occupancy:
```q
q)a
"#.#L.L#.##"
"#LLL#LL.L#"
"L.#.L..#.."
"#L##.##.L#"
"#.#L.LL.LL"
"#.#L#L#.##"
"..L.L....."
"#L#L##L#L#"
"#.LLLLLL.L"
"#.#L#L#.##"
```
The answer is the sum of this matrix where the elements are equal to `"#"`:
```q
q)sum sum "#"=a
37i
```

## Part 2
Line of sight can be implemented using the [`fills`](https://code.kx.com/q/ref/fills/) function that
replaces null values in a list with the previous non-null value. However this only works in one
direction (left to right), so in order to fill in other directions we have to warp the matrix in
different ways as shown below.

We start by replacing the dots with spaces, as the space counts as the null value of the char type
(as opposed to the actual null character) so that `fills` can fill over them:
```q
q)a:ssr[;".";" "]each x
q)a
"L LL LL LL"
"LLLLLLL LL"
"L L L  L  "
"LLLL LL LL"
"L LL LL LL"
"L LLLLL LL"
"  L L     "
"LLLLLLLLLL"
"L LLLLLL L"
"L LLLLL LL"
```
The iteration step is best demonstrated with an intermediate state:
```q
q)a:enlist"# L# ## L#"
q)a,:enlist"#L##### LL"
q)a,:enlist"L # #  #  "
q)a,:enlist"##L# ## ##"
q)a,:enlist"# ## #L ##"
q)a,:enlist"# ##### #L"
q)a,:enlist"  # #     "
q)a,:enlist"LLL####LL#"
q)a,:enlist"# L##### L"
q)a,:enlist"# L#### L#"
```
We save the row and column counts as in part 1:
```q
q)rc:count a
q)cc:count a 0
q)rc
10
q)cc
10
```
We create an empty matrix and an empty row to use as padding (this time with a size equal to the
original):
```q
q)em:(rc;cc)#" "
q)emr:enlist cc#" "
q)em
"          "
"          "
"          "
"          "
"          "
"          "
"          "
"          "
"          "
"          "
q)emr
"          "
```
We now create the line-of-sight matrices in all 8 directions. The left-to-right one is the easiest
as we can just use `fills` on each row. However we also need to shift it to the right with `prev` to
avoid a seat blocking its own line of sight. After the fill, we compare to `"#"` to check for actual
occupancy.
```q
q){prev fills x}each a
" ##L#####L"
" #L######L"
" LL#######"
" ##L######"
" ######LL#"
" #########"
"   #######"
" LLL####LL"
" ##L######"
" ##L#####L"
q)al:"#"={prev fills x}each a
q)al
0110111110b
0101111110b
0001111111b
0110111111b
0111111001b
0111111111b
0001111111b
0000111100b
0110111111b
0110111110b
```
For the other directions, we have to apply a transformation to the matrix before doing the fill and
then perform the opposite transformation on the result. For right-to-left this transformation is
reversing the list.
```q
q){reverse prev fills reverse x}each a
"LL####LL# "
"L#####LLL "
"#######   "
"#L####### "
"#####L### "
"########L "
"####      "
"LL####LL# "
"LL#####LL "
"LL####LL# "
q)ar:"#"={reverse prev fills reverse x}each a
```
For up-down, we flip the matrix before the fill:
```q
q)flip {prev fills x}each flip a
"          "
"# L# ## L#"
"#L##### LL"
"LL######LL"
"##L#######"
"######L###"
"#########L"
"#########L"
"LLL####LL#"
"#LL#####LL"
q)au:"#"=flip {prev fills x}each flip a
```
For down-up, we both flip and reverse:
```q
q)flip {reverse prev fills reverse x}each flip a
"#L######LL"
"L#########"
"##L####L##"
"#L####LL##"
"#L#####L#L"
"LL#####LL#"
"LLL####LL#"
"# L#####LL"
"# L#### L#"
"          "
q)ad:"#"=flip {reverse prev fills reverse x}each flip a
```
For the diagonal directions, we also have to shift each row/column in the matrix by a different
amount, creating a shearing effect. We use the padding matrix to provide enough nulls to rotate in
(since only `rotate` takes a shift amount but that actually rotates the elements, unlike `prev`and
`next` which shift in a null). We also have to do the final adjustment of shifting by one position
in the vertical direction by adding the null row and dropping the row on the other end.

This is the up-right-to-down-left direction, where we add the padding matrix on the left, shift each
row by an increased amount, do the `fills` (on the whole matrix, so it goes up-down), undo the
rotation, drop the padding, then shift the result left and down by adding a row and column of nulls:
```q
q)em,'a
"          # L# ## L#"
"          #L##### LL"
"          L # #  #  "
"          ##L# ## ##"
"          # ## #L ##"
"          # ##### #L"
"            # #     "
"          LLL####LL#"
"          # L##### L"
"          # L#### L#"
q)fills neg[til rc] rotate'em,'a
"          # L# ## L#"
"L         ##L#####LL"
"L         ##L#####L#"
"L##       ##L##L####"
"L###      ##L##L####"
"####L     ##L#######"
"####L     ##L#######"
"####LL#   ##L####LLL"
"L######L  ##L####L#L"
"LL#####L# ##L####L##"
q)neg[til rc] rotate'em,'a
"          # L# ## L#"
"L          #L##### L"
"            L # #  #"
" ##          ##L# ##"
"L ##          # ## #"
"## #L          # ###"
"#                 # "
"####LL#          LLL"
"L##### L          # "
" L#### L#          #"
q)til[rc] rotate'fills neg[til rc] rotate'em,'a
"          # L# ## L#"
"         ##L#####LLL"
"        ##L#####L#L "
"       ##L##L####L##"
"      ##L##L####L###"
"     ##L###########L"
"    ##L###########L "
"   ##L####LLL####LL#"
"  ##L####L#LL######L"
" ##L####L##LL#####L#"
q)cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'a
"# L# ## L#"
"#L#####LLL"
"L#####L#L "
"##L####L##"
"#L####L###"
"#########L"
"########L "
"LLL####LL#"
"#LL######L"
"#LL#####L#"
q)-1_emr,cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'a
"          "
"# L# ## L#"
"#L#####LLL"
"L#####L#L "
"##L####L##"
"#L####L###"
"#########L"
"########L "
"LLL####LL#"
"#LL######L"
q)next each -1_emr,cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'a
"          "
" L# ## L# "
"L#####LLL "
"#####L#L  "
"#L####L## "
"L####L### "
"########L "
"#######L  "
"LL####LL# "
"LL######L "
q)aur:"#"=next each -1_emr,cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'a
```
For up-left-to-down-right, we append the padding on the right and shear by rotating increasingly to
the left instead of right.
```q
q)a,'em
"# L# ## L#          "
"#L##### LL          "
"L # #  #            "
"##L# ## ##          "
"# ## #L ##          "
"# ##### #L          "
"  # #               "
"LLL####LL#          "
"# L##### L          "
"# L#### L#          "
q)til[rc] rotate'a,'em
"# L# ## L#          "
"L##### LL          #"
"# #  #            L "
"# ## ##          ##L"
" #L ##          # ##"
"## #L          # ###"
"                # # "
"LL#          LLL####"
" L          # L#####"
"#          # L#### L"
q)fills til[rc] rotate'a,'em
"# L# ## L#          "
"L######LL#         #"
"#######LL#        L#"
"#######LL#       ##L"
"##L####LL#      ####"
"##L#L##LL#     #####"
"##L#L##LL#     #####"
"LL##L##LL#   LLL####"
"LL##L##LL#  #LL#####"
"#L##L##LL# ##L#####L"
q)neg[til rc] rotate'fills til[rc] rotate'a,'em
"# L# ## L#          "
"#L######LL#         "
"L########LL#        "
"##L#######LL#       "
"######L####LL#      "
"#######L#L##LL#     "
" #######L#L##LL#    "
"LLL####LL##L##LL#   "
"#LL#####LL##L##LL#  "
"##L#####L#L##L##LL# "
q)cc#/:neg[til rc] rotate'fills til[rc] rotate'a,'em
"# L# ## L#"
"#L######LL"
"L########L"
"##L#######"
"######L###"
"#######L#L"
" #######L#"
"LLL####LL#"
"#LL#####LL"
"##L#####L#"
q)prev each -1_emr,cc#/:neg[til rc] rotate'fills til[rc] rotate'a,'em
"          "
" # L# ## L"
" #L######L"
" L########"
" ##L######"
" ######L##"
" #######L#"
"  #######L"
" LLL####LL"
" #LL#####L"
q)aul:"#"=prev each -1_emr,cc#/:neg[til rc] rotate'fills til[rc] rotate'a,'em
```
For the remaining two directions, we reverse the entire matrix, such that the fill goes upwards
instead of downwards, but the shearing works the same way.

For down-right-to-up-left:
```q
q)next each 1_(reverse cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'reverse a),emr
"L######LL "
"L#######  "
"#L####### "
"#####L### "
"########L "
"L####LL#  "
"LL####LL# "
"LL######L "
" L#### L# "
"          "
q)adr:"#"=next each 1_(reverse cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'reverse a),emr
```
For down-left-to-up-right:
```q
q)prev each 1_(reverse cc#/:neg[til rc] rotate'fills til[rc] rotate'reverse a,'em),emr
" #L######L"
" L##L####L"
" ##L####L#"
" ######L##"
" # #######"
"  L#L####L"
" LLL####LL"
" ##L##### "
" # L#### L"
"          "
q)adl:"#"=prev each 1_(reverse cc#/:neg[til rc] rotate'fills til[rc] rotate'reverse a,'em),emr
```
Now we can add together the 8 different occupancy matrices:
```q
q)occ:sum (al;ar;au;ad;aul;aur;adl;adr)
q)occ
1 3 4 4 5 5 4 3 3 0
1 5 5 6 6 7 6 5 4 2
4 5 5 7 8 8 7 4 4 3
4 4 8 7 8 6 7 5 6 4
5 6 6 7 8 7 7 6 6 4
2 6 7 8 7 6 6 6 5 4
3 4 5 7 7 7 6 5 3 3
3 3 6 6 8 8 7 6 4 0
1 2 4 5 8 8 6 3 3 3
1 2 3 3 5 5 4 4 3 0
```
The update of the matrix works exactly like part 1, only with the number 4 changed to 5.
```q
q)a:{[c;x]?[(x="L")and c=0;"#";?[(x="#")and c>=5;"L";x]]}'[occ;a]
q)a
"# L# L# L#"
"#LLLLLL LL"
"L L L  #  "
"##LL LL L#"
"L LL LL L#"
"# LLLLL LL"
"  L L     "
"LLLLLLLLL#"
"# LLLLL# L"
"# L#LL# L#"
```
The answer is returned the same way as in part 1.
```q
q)sum sum "#"=a
26i
```
