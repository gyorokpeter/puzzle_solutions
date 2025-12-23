# Breakdown

## Common
Let's start with the case when we have a single number:
```q
q)x:100756
```
The calculation of the fuel can be written using the operators
[`div`](https://code.kx.com/q/ref/div/), subtraction and [`or`](https://code.kx.com/q/ref/greater/)
which in this case returns the greater of two numbers (so we don't go below zero):
```q
q)0|(x div 3)-2
33583
```
This logic is encapsulated in the function `d1`.

## Part 1
If we have the input in the standard format:
```q
q)x:("12";"14";"1969";"100756")
```
we first need to convert the strings to integers, which we can do using the
[lexical cast](https://code.kx.com/q/ref/tok/) operator, with `"J"` (long) as the target type. This
will be used in almost every puzzle.
```q
q)"J"$x
12 14 1969 100756
```
Since the function `d1` is made up entirely of atomic operations, we can apply it to the input to
process all elements at once:
```q
q)d1"J"$x
2 2 654 33583
```
To get the answer, we sum these results:
```q
q)sum d1"J"$x
34241
```

## Part 2
Now we want to repeat `d1` until the result no longer changes. In other languages we might use a
while loop. In q we have iterators which loop implicitly. In particular we use
[`\`](https://code.kx.com/q/ref/accumulators/) (scan), which has multiple meanings, one of which is
"repeat until no change". The `/` (over) iterator does everything that `\` does. The only difference
is that `\` returns the intermediate results while `/` only returns the final result. So if we use
these iterators on `d1`, it will keep calculating the the next item in the fuel sequence until it
stops changing. We need to be careful to avoid negative weights. This is where the `0|` operation in
`d1` comes in. Once the weight would turn negative, it stays zero instead, and due to the lack of
change, `\` stops iterating and returns. The result is a list of lists:
```q
q)d1\["J"$x]
12 14 1969 100756
2  2  654  33583
0  0  216  11192
0  0  70   3728
0  0  21   1240
0  0  5    411
0  0  0    135
0  0  0    43
0  0  0    12
0  0  0    2
0  0  0    0
```
This still has the original weights at the beginning, which should not be included in the final
calculation. So we get rid of them using the [`_`](https://code.kx.com/q/ref/drop/) (drop) operator:
```q
q)1_d1\["J"$x]
2 2 654 33583
0 0 216 11192
0 0 70  3728
0 0 21  1240
0 0 5   411
0 0 0   135
0 0 0   43
0 0 0   12
0 0 0   2
0 0 0   0
```
Since the result is a matrix, we can call `sum` twice to get the overall sum. The first one sums the
rows into one (in effect summing the columns), and the second one sums the resulting one-dimensional
list.
```q
q)sum 1_d1\["J"$x]
2 2 966 50346
q)sum sum 1_d1\["J"$x]
51316
```
