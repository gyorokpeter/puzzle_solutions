# Breakdown
Example input:
```q
x:"\n"vs"1000\n2000\n3000\n\n4000\n\n5000\n6000\n\n7000\n8000\n9000\n\n10000";
```

## Part 1
For the input parsing, we convert the list of strings to integers. Any lines which are not valid integers get converted to nulls - in this case these are the separators between elves.
```q
q)"J"$x
1000 2000 3000 0N 4000 0N 5000 6000 0N 7000 8000 9000 0N 10000
```
We find out where to cut the list by looking for the nulls:
```q
q)null"J"$x
00010100100010b
q)where null"J"$x
3 5 8 12
```
The [`cut`](https://code.kx.com/q/ref/cut/#cut-keyword) function takes a list of the beginnings of the slices, so we need to prepend a zero to avoid losing the first group:
```q
q)0,where null"J"$x
0 3 5 8 12
```
We also want to refer to `"J"$x` twice in the same expression, so we wrap it in a lambda to avoid duplication:
```q
q){(0,where null x)cut x}"J"$x
1000 2000 3000
0N 4000
0N 5000 6000
0N 7000 8000 9000
0N 10000
```
Note that the nulls are still there in the list, but luckily the [`sum`](https://code.kx.com/q/ref/sum/#sum) function ignores them. We need to use `sum` with `each` in order to sum row by row, normally it would go column by column.
```q
q)sum each{(0,where null x)cut x}"J"$x
6000 4000 11000 24000 10000
```
The answer to part 1 is simply the maximum of this list.
```q
q)max sum each{(0,where null x)cut x}"J"$x
24000
```

## Part 2
Instead of taking the maximum, we put the list in descending order:
```q
q)desc sum each{(0,where null x)cut x}"J"$x
24000 11000 10000 6000 4000
```
We take the first three elements, which are now the biggest ones:
```q
q)3#desc sum each{(0,where null x)cut x}"J"$x
24000 11000 10000
```
And sum these three:
```q
q)sum 3#desc sum each{(0,where null x)cut x}"J"$x
45000
```

**Note:** in my compact solution the final expression of part 1 minus the `sum` is put into a function `d1` which is then reused in both `d1p1` and `d1p2` to avoid repetition.
