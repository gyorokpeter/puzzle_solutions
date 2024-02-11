# Breakdown
Example input:
```q
x:"forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2"
```

## Common
We split the input into lines, then also split each line to words by cutting on spaces. The `/:`
(each right) iterator is necessary on the second split since we are splitting each item in a list.
```q
q)a:" "vs/:"\n"vs x
q)a
"forward" ,"5"
"down"    ,"5"
"forward" ,"8"
"up"      ,"3"
"down"    ,"8"
"forward" ,"2"
```
We can then access the columns of this matrix using `a[;0]` and `a[;1]`. The numbers are column 1 and
we must cast them to integers:
```q
q)"J"$a[;1]
5 5 8 3 8 2
```
For the first column, we define a dictionary to map the words to (x;y) coordinate pairs:
```q
q)("forward";"down";"up")!(1 0;0 1;0 -1)
"forward"| 1 0
"down"   | 0 1
"up"     | 0 -1
```
and then immediately apply this to the first column:
```q
q)(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]
1 0
0 1
1 0
0 -1
0 1
1 0
```
Then we can multiply the two lists together:
```q
q)("J"$a[;1])*(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]
5 0
0 5
8 0
0 -3
0 8
2 0
```

## Part 1
The two directions are independent, so we can sum the list and then multiply the two elements of
the result, which is easily expressed using [`prd`](https://code.kx.com/q/ref/prd/):
```q
q)sum ("J"$a[;1])*(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]
15 10
q)prd sum ("J"$a[;1])*(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]
150
```

## Part 2
We assign the list to the variable `b` to simplify the remaining code:
```q
q)b:("J"$a[;1])*(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]
```
The horizontal movement is still just a matter of summing the respective coordinate:
```q
q)sum[b[;0]]
15
```
The aim is the partial sum of the second coordinate, which we can get using the [`sums`](https://code.kx.com/q/ref/sum/#sums) function:
```q
q)sums[b[;1]]
0 5 5 2 10 10
```
Then we multiply the aim by the first coordinate. Note that this also takes care of the 
non-"forward" instructions because for those the first coordinate is zero:
```q
q)b[;0]*sums[b[;1]]
0 0 40 0 0 20
```
Now we can sum these numbers and multiply the result by the sum of the horizontal movement:
```q
q)sum b[;0]*sums[b[;1]]
60
q)sum[b[;0]]*sum b[;0]*sums[b[;1]]
900
```
