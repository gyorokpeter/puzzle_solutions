# Breakdown

Example input:
```q
x:"\n"vs"3   4\n4   3\n2   5\n1   3\n3   9\n3   3";
```

## Common
First we split the input lines into two numbers each. A quick and dirty way is to split the lines on
spaces and then take the first and last element.

We use [`vs`](https://code.kx.com/q/ref/vs/) to split strings. This is a very useful function that
will be used for almost all input parsing. Since we want to split each string in a list, we have to
combine it with [`each-right (/:)`](https://code.kx.com/q/ref/maps/#each-left-and-each-right).
```q
q)" "vs/:x
,"3" "" "" ,"4"
,"4" "" "" ,"3"
,"2" "" "" ,"5"
,"1" "" "" ,"3"
,"3" "" "" ,"9"
,"3" "" "" ,"3"
```
We could take the first and last element with `first each` and `last each`. However we can combine
the two operations by using the [`apply (@)`](https://code.kx.com/q/ref/apply/#apply-at-index-at)
operator, providing the function to be called on the left and the operand on the right. Since we
both have a list of operations and a list of items to apply them to, we have to combine each-left
and each-right to get `/:\:`. The ordering between `/:` and `\:` depends on the circumstance, in
this order we get a matrix with one row for each operation (`first` and `last`) and one column for
each line of the input, while the reverse order would result in a transpose of this matrix. This
time having two rows makes the rest of the solution easier.
```q
q)(first;last)@/:\:" "vs/:x
,"3" ,"4" ,"2" ,"1" ,"3" ,"3"
,"4" ,"3" ,"5" ,"3" ,"9" ,"3"
```
Finally we cast the numbers to integers. This is also a very common operation for input parsing, and
it uses an overload of [`cast ($)`](https://code.kx.com/q/ref/tok/) that takes a capital letter
corresponding to the target type on the left and the values as strings on the right (the right
argument is flexible, it could be a single string, a list of strings, a dictionary with string
values, a matrix etc.). Usually we cast using `"J"`, which stands for `long`, the default
integer type.
```q
q)"J"$(first;last)@/:\:" "vs/:x
3 4 2 1 3 3
4 3 5 3 9 3
```
This parsing logic is the function `d1`.

## Part 1
After parsing the input, we sort both lists. We can do this by using the built-in
[`asc`](https://code.kx.com/q/ref/asc/) function with `each` (since we have two lists).
```q
q)asc each d1 x
1 2 3 3 3 4
3 3 3 4 5 9
```
We calculate the difference between the two lists by using the minus operator with _apply_ - this
time with the `.` operator, which takes a function on the left and a list of the arguments on the
right. The binary `-` operator subtracts its second argument from its first, so all we need to do
is pass in our two-element list into apply:
```q
q)(-). asc each d1 x
-2 -1 0 -1 -2 -5
```
The distance is the absolute value of the difference:
```q
q)abs(-). asc each d1 x
2 1 0 1 2 5
```
Finally we sum the list to get the total distance:
```q
q)sum abs(-). asc each d1 x
11
```

## Part 2
For counting the number of occurrences of elements in a list, we can use the
[`group`](https://code.kx.com/q/ref/group/) function and then count each group:
```q
q)a:d1 x
q)count each group a 1
4| 1
3| 3
5| 1
9| 1
```
We find the values corresponding to the numbers on the first list by indexing this dictionary with
the first list:
```q
q)(count each group a 1)a 0
3 1 0N 0N 3 3
```
We multiply the counts with the list itself:
```q
q)a[0]*(count each group a 1)a 0
9 4 0N 0N 9 9
```
We sum this list, which also ignores the nulls (as if they were zero):
```q
q)sum a[0]*(count each group a 1)a 0
31
```
