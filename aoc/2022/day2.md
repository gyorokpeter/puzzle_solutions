# Breakdown
Example input:
```q
x:"\n"vs"A Y\nB X\nC Z";
```

## Common
We take the first and third character from each line (i.e. the index `0 2`):
```q
q)x[;0 2]
"AY"
"BX"
"CZ"
```
We convert the characters to integers for easier processing:
```q
q)`int$x[;0 2]
65 89
66 88
67 90
```
We normalize by subtracting 65 from the first number and 88 from the second number, such that both sides have the values 0, 1 and 2. This can be done with a single subtraction with each-left.
```q
q)a:(`int$x[;0 2])-\:65 88
q)a
0 1
1 0
2 2
```

## Part 1
There are only 9 possible combinations. We might think about a function that takes the two players' moves and returns the score for the outcome (0, 3 or 6). In q this can also be expressed as a matrix, since function invocation and list indexing are the same operation. So we will have a matrix where the row index is the first player's move and the column index is the second player's move. For example, the element at index ```[0;0]``` will be the outcome of playing rock against rock (3), and ```[0;1]``` is the opponent playing rock and us playing paper (6).
```q
q)(3 6 0;0 3 6;6 0 3)
3 6 0
0 3 6
6 0 3
```
To calculate the score for all rounds, we index the matrix with all the elements from our `a` variable from above. This can be done using the `.` operator with each-right. This is the reason for normalizing the values to be zero-based.
```q
q)(3 6 0;0 3 6;6 0 3)./:a
6 0 3
```
The other part of the score is the selected shape - although since it's zero-based, we need to add one to the result.
```q
q)1+a[;1]+(3 6 0;0 3 6;6 0 3)./:a
8 1 6
```
Finally we sum the scores to get the answer.
```q
q)sum 1+a[;1]+(3 6 0;0 3 6;6 0 3)./:a
15
```
## Part 2
It is now the outcome score that is easier to calculate - just multiply the second number by 3.
```q
q)3*a[;1]
3 0 6
```
For the score for the played shape, we need to figure out which shape to play for every combination. Once again this can be expressed as a 3x3 matrix. This time the values can be from 1 to 3.
```q
q)(3 1 2;1 2 3;2 3 1)
3 1 2
1 2 3
2 3 1
q)(3 1 2;1 2 3;2 3 1)./:a
1 1 1
```
Then we add and sum the scores:
```q
q)(3*a[;1])+(3 1 2;1 2 3;2 3 1)./:a
4 1 7
q)sum(3*a[;1])+(3 1 2;1 2 3;2 3 1)./:a
12
```

## Note
The matrices can also be calculated programatically, although it's not necessary as the generation takes longer to write than the result.
```q
q)(1-til 3)rotate\:3*til 3
3 6 0
0 3 6
6 0 3
q)(-1+til 3)rotate\:1+til 3
3 1 2
1 2 3
2 3 1
```
