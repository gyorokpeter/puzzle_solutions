# Breakdown

## Part 1
Example input:
```q
x:("5\t1\t9\t5";"7\t5\t3";"2\t4\t6\t8")
```
Note that the puzzle doesn't specify that the input is tab-separated, but this is the case for the
real input, so the example inputs are presented in the same way for consistency.

To parse the input, we break on tab characters using [`vs`](https://code.kx.com/q/ref/vs/):
```q
q)"\t"vs/:x
(,"5";,"1";,"9";,"5")
(,"7";,"5";,"3")
(,"2";,"4";,"6";,"8")
```
Then we convert the results to integers:
```q
q)r:"J"$"\t"vs/:x
q)r
5 1 9 5
7 5 3
2 4 6 8
```
We take the maximum and minimum of each row:
```q
q)max each r
9 7 8
q)min each r
1 3 2
```
We perform the subtraction and sum the results:
```q
q)(max each r)-min each r
8 4 6
q)sum(max each r)-min each r
18
```

## Part 2
Example input:
```q
x:("5\t9\t2\t8";"9\t4\t7\t3";"3\t8\t6\t5")
```
We parse the input as in part 1:
```q
q)r:"J"$"\t"vs/:x
q)r
5 9 2 8
9 4 7 3
3 8 6 5
```
The main logic is a function that is applied to one line at a time:
```q
q)x:5 9 2 8
```
We generate each pairing of the numbers in the list:
```q
q)x cross x
5 5
5 9
5 2
5 8
9 5
..
```
Then we find the pairs where the second element divides the first, using `x[;0]` to index the first
item of each pair and `x[;1]` to index the second element of each pair:
```q
q)x:x cross x
q)0=x[;0]mod x[;1]
1000010000100011b
```
We also need to filter out pairs where the two elemens match, since `cross` includes those:
```q
q)x[;0]<>x[;1]
0111101111011110b
q)x where (x[;0]<>x[;1])and 0=x[;0]mod x[;1]
8 2
```
The result should be the single pair that is evenly divisible, so we can just take the first (the
only) element.
```q
q)x:5 9 2 8
q)first{x where (x[;0]<>x[;1])and 0=x[;0]mod x[;1]}(x cross x)
8 2
```
We need to divide the first element of the list by the second. Instead of just indexing the list, it
is also possible to directly invoke a binary operator on a two-element list using the `.` operator.
```q
q)(%). first{x where (x[;0]<>x[;1])and 0=x[;0]mod x[;1]}(x cross x)
4f
```
Once we have this value for all rows, we sum them together.
```q
q)sum{(%). first{x where (x[;0]<>x[;1])and 0=x[;0]mod x[;1]}(x cross x)}each r
9f
```
