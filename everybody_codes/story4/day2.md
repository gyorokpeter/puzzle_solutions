# Breakdown

## Part 1
Example input:
```q
x:()
x,:enlist"START=[5,0]"
x,:enlist"A=[0,0]"
x,:enlist"B=[10,0]"
x,:enlist"C=[5,10]"
x,:enlist"MOVES=ABCCBABCA"
```
We cut on `=` characters and only keep the last part of each line:
```q
q)a:last each"="vs/:x
q)a
"[5,0]"
"[0,0]"
"[10,0]"
"[5,10]"
"ABCCBABCA"
```
We take the first four elements, drop the first and last characters (the square brackets), split on
commas and convert to integers:
```q
q)p:"J"$","vs/:1_/:-1_/:4#a
q)p
5  0
0  0
10 0
5  10
```
We convert the moves into integers by looking them up in the string `"ABC"`:
```q
q)"ABC"?last a
0 1 2 2 1 0 1 2 0
```
We add 1 to these so that the numbers can be used as indices into `p`:
```q
q)p 1+"ABC"?last a
q)1+"ABC"?last a
1 2 3 3 2 1 2 3 1
0  0
10 0
5  10
5  10
10 0
0  0
10 0
5  10
0  0
```
We calculate the illuminated positions using an iterated function. The accumulator is the current
position, and the additional parameter is the next beacon coordinate to move towards:
```q
q)x:5 0
q)y:0 0
```
To calculate the next position, we add the parameters together and divide by 2. `%` is float
division, and rounding down is done using the `floor` function.
```q
q)(x+y)%2
2.5 0
q)floor(x+y)%2
2 0
``` 
We iterate this function using `\` (scan) in order to keep the list of all visited positions. The
initial value of the accumulator is the starting position (`p 0`). Since the list returned by scan
doesn't include the initial value, we explicitly prepend it.
```q
q)enlist[p 0],{floor(x+y)%2}\[p 0;p 1+"ABC"?last a]
5 0
2 0
6 0
5 5
5 7
7 3
3 1
6 0
5 5
2 2
```
We get the unique positions using `distinct` and count them:
```q
q)distinct enlist[p 0],{floor(x+y)%2}\[p 0;p 1+"ABC"?last a]
5 0
2 0
6 0
5 5
5 7
7 3
3 1
2 2
q)count distinct enlist[p 0],{floor(x+y)%2}\[p 0;p 1+"ABC"?last a]
8
```

## Part 2
Continuing from part 1, we store the list of illuminated positions in a variable:
```q
q)sq:distinct enlist[p 0],{floor(x+y)%2}\[p 0;p 1+"ABC"?last a]
```
To get the firefly locations, we add the deltas for each of the four cardinal directions to each of
the illuminated locations. Using the `+` operator with both `/:` (each right) and `\:` (each left)
ensures that it is applied between every combination. The result is a matrix, but since we only care
about the elements themselves and not their arrangement in the matrix, we can raze it:
```q
q)sq+/:\:(0 -1;1 0;0 1;-1 0)
5 -1 6 0  5 1  4 0
2 -1 3 0  2 1  1 0
6 -1 7 0  6 1  5 0
5 4  6 5  5 6  4 5
5 6  6 7  5 8  4 7
7 2  8 3  7 4  6 3
3 0  4 1  3 2  2 1
2 1  3 2  2 3  1 2
q)raze sq+/:\:(0 -1;1 0;0 1;-1 0)
5 -1
6 0
5 1
4 0
2 -1
..
```
We take the distinct list of coordinates and exclude the already illuminated squares using `except`.
Then we count what remains.
```q
q)distinct[raze sq+/:\:(0 -1;1 0;0 1;-1 0)]except sq
5 -1
5 1
4 0
2 -1
3 0
..
q)count distinct[raze sq+/:\:(0 -1;1 0;0 1;-1 0)]except sq
25
```

## Part 3
Input parsing is the same as for part 1. The lack of the fifth line doesn't cause any problem.

To calculate the illuminated squares, we use an iterated function. The accumulator is the previously
seen illuminated squares, and it takes no list element parameter. We bind the three beacon
locations as a parameter since q doesn't have automatic variable capture.
```q
q)pp:p 1+til 3
q)pp
0  0
10 0
5  10
q)pl:(5 0;2 0;7 0;5 5)
```
To calculate the next set of illuminated squares, we perform the add-and-divide operation like in
part 1 and 2, but this time the addition is performed between all of the known illuminated squares
and all beacon positions. Once again, this requires using `+/:\:` to get all combinations. However,
`%` and `floor` can be used atomically to affect all elements of the result of the addition.
```q
q)pl+/:\:pp
5  0  15 0  10 10
2  0  12 0  7  10
7  0  17 0  12 10
5  5  15 5  10 15
q)(pl+/:\:pp)%2
2.5 0   7.5 0   5   5
1   0   6   0   3.5 5
3.5 0   8.5 0   6   5
2.5 2.5 7.5 2.5 5   7.5
q)floor(pl+/:\:pp)%2
2 0 7 0 5 5
1 0 6 0 3 5
3 0 8 0 6 5
2 2 7 2 5 7
```
Like before, we raze the matrix as we don't care about the row/column structure. We append the list
of new positions to the existing ones and `distinct` them to remove duplicates:
```q
q)distinct pl,raze floor(pl+/:\:pp)%2
5 0
2 0
7 0
5 5
1 0
6 0
3 5
3 0
8 0
6 5
2 2
7 2
5 7
```
This is the return value of the iterated function.

We iterate the function using `/` (over), using the overload that takes a single parameter that is
the initial value and stops iterating once the accumulator stops changing. This way we eventually
end up with all the illuminated positions.
```q
q)sq:{[pp;pl]distinct pl,raze floor(pl+/:\:pp)%2}[p 1+til 3]/[enlist p 0]
q)sq
5 0
2 0
7 0
5 5
1 0
6 0
3 5
..
```
We calculate the firefly positions using the same formula as in part 2.
```q
q)count distinct[raze sq+/:\:(0 -1;1 0;0 1;-1 0)]except sq
42
```
We can visualize the tiles using iterated functional amend on a matrix (the `reverse` and `flip` are
only there to fix the orientation of the display):
```q
q)-1 reverse flip" #".[;;:;1b]/[(1+max[sq])#0b;sq];
    ##
    ##
   ####
   ####
  ######
  #    #
 ###  ###
 ###  ###
## #### ##
##########
```
