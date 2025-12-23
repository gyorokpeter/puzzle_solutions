# Breakdown

## Part 1
Example input:
```q
x:enlist"12345678"
```
We convert the input into numbers and cast them into floats. This is because for an unexplained
reason the `mmu` (matrix multiply) operator doesn't work on anything else.
```q
q)a:`float$"J"$/:raze x
q)a
1 2 3 4 5 6 7 8f
```
Now we build up a matrix that can be used to multiply the input vector to get the next state. We
start with the four items in the period:
```q
q)0 1 0 -1
0 1 0 -1
```
We duplicate each item by the row index plus 1:
```
q)1+til count a
1 2 3 4 5 6 7 8
q)(1+til count a)#'/:0 1 0 -1
,0  0 0   0 0 0    0 0 0 0     0 0 0 0 0      0 0 0 0 0 0       0 0 0 0 0 0 0        0 0 0 0 0 0 0..
,1  1 1   1 1 1    1 1 1 1     1 1 1 1 1      1 1 1 1 1 1       1 1 1 1 1 1 1        1 1 1 1 1 1 1..
,0  0 0   0 0 0    0 0 0 0     0 0 0 0 0      0 0 0 0 0 0       0 0 0 0 0 0 0        0 0 0 0 0 0 0..
,-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -..
```
We flip this such that the items corresponding to a row in the final matrix are in the correct
place:
```q
q)flip(1+til count a)#'/:0 1 0 -1
0                       1                       0                       -1
0  0                    1  1                    0  0                    -1 -1
0  0  0                 1  1  1                 0  0  0                 -1 -1 -1
0  0  0  0              1  1  1  1              0  0  0  0              -1 -1 -1 -1
0  0  0  0  0           1  1  1  1  1           0  0  0  0  0           -1 -1 -1 -1 -1
0  0  0  0  0  0        1  1  1  1  1  1        0  0  0  0  0  0        -1 -1 -1 -1 -1 -1
0  0  0  0  0  0  0     1  1  1  1  1  1  1     0  0  0  0  0  0  0     -1 -1 -1 -1 -1 -1 -1
0  0  0  0  0  0  0  0  1  1  1  1  1  1  1  1  0  0  0  0  0  0  0  0  -1 -1 -1 -1 -1 -1 -1 -1
```
We raze each row to remove the extra level of nesting:
```q
q)raze each flip(1+til count a)#'/:0 1 0 -1
0 1 0 -1
0 0 1 1 0 0 -1 -1
0 0 0 1 1 1 0 0 0 -1 -1 -1
0 0 0 0 1 1 1 1 0 0 0 0 -1 -1 -1 -1
0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 -1 -1 -1 -1 -1
0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 -1 -1 -1 -1 -1 -1
0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0 -1 -1 -1 -1 -1 -1 -1
0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 -1 -1 -1 -1 -1 -1 -1 -1
```
We use the `#` (take) operator to resize each row to the length of the input. However, we actually
need to take an extra element and drop the first element to get the exact matrix we need.
```q
q)(count[a])#/:raze each flip(1+til count a)#'/:0 1 0 -1
0 1 0 -1 0 1 0  -1
0 0 1 1  0 0 -1 -1
0 0 0 1  1 1 0  0
0 0 0 0  1 1 1  1
0 0 0 0  0 1 1  1
0 0 0 0  0 0 1  1
0 0 0 0  0 0 0  1
0 0 0 0  0 0 0  0
q)1_/:(1+count[a])#/:raze each flip(1+til count a)#'/:0 1 0 -1
1 0 -1 0 1 0  -1 0
0 1 1  0 0 -1 -1 0
0 0 1  1 1 0  0  0
0 0 0  1 1 1  1  0
0 0 0  0 1 1  1  1
0 0 0  0 0 1  1  1
0 0 0  0 0 0  1  1
0 0 0  0 0 0  0  1
```
We also need to cast to float to allow `mmu` to be used on it:
```q
q)m:`float$1_/:(1+count[a])#/:raze each flip(1+til count a)#'/:0 1 0 -1
q)m
1 0 -1 0 1 0  -1 0
0 1 1  0 0 -1 -1 0
0 0 1  1 1 0  0  0
0 0 0  1 1 1  1  0
0 0 0  0 1 1  1  1
0 0 0  0 0 1  1  1
0 0 0  0 0 0  1  1
0 0 0  0 0 0  0  1
```
Now we do 100 iterations, performing an `abs` and a `mod 10` after the matrix multiplication:
```q
q)do[100;a:(abs m mmu a)mod 10]
q)a
2 3 8 4 5 6 7 8f
```
Then we convert the result to string and raze it. This is to ensure that any leading zeros are
preserved.
```q
q)raze string 8#a
"23845678"
```

## Part 2
This is not a general solution. It only works on input that abuses the fact that the 2nd half of the
vector is the partial sums counting back from the end of the vector (mod 10). All of the part 2
examples in the puzzle statement as well as the actual input have this property. Therefore we only
need the end of the extended input starting from the message offset.

Example input:
```q
x:enlist"03036732577212944063491565474664"
```
We convert the digits of the input into integers:
```q
q)a:"J"$/:raze x
q)a
0 3 0 3 6 7 3 2 5 7 7 2 1 2 9 4 4 0 6 3 4 9 1 5 6 5 4 7 4 6 6 4
```
We extract the offset by taking the first 7 elements and using the "list to number" overload of
`sv` with base 10:
```q
q)off:10 sv 7#a
q)off
303673
```
Then we take the necessary number of items from the back of the vector. When taking a negative
amount from a vector, we start from the back, and taking more elements than the length of the list
will cause it to wrap around.
```q
q)off-10000*count[a]
-16327
q)b:(off-10000*count[a])#a
q)b
5 4 7 4 6 6 4 0 3 0 3 6 7 3 2 5 7 7 2 1 2 9 4 4 0 6 3 4 9 1 5 6 5 4 7 4 6 6 4 0 3 0 3 6 7 3 2 5 7 ..
```
Now comes the main iteration. It can be done using the `/` (over) iterator, but first we need to
reverse the vector since `sums` works only forward, and also reverse after getting the result.
```q
q)b
5 4 7 4 6 6 4 0 3 0 3 6 7 3 2 5 7 7 2 1 2 9 4 4 0 6 3 4 9 1 5 6 5 4 7 4 6 6 4 0 3 0 3 6 7 3 2 5 7 ..
q)c:reverse {sums[x]mod 10}/[100;reverse b]
q)c
8 4 4 6 2 0 2 6 8 6 4 0 2 8 6 6 0 6 4 0 0 0 0 0 6 2 8 2 8 6 6 0 8 4 4 6 2 0 2 6 8 6 4 0 7 8 1 6 0 ..
```
Finally we extract the solution like in part 1:
```q
q)raze string 8#c
"84462026"
```
