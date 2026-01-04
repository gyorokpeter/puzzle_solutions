# Breakdown
Example input:
```q
x:"\n"vs"L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82"
```

## Part 1
The goal is to convert the input into positive and negative numbers, then generate their partial
sums and find any zeros.

First we convert the letters `L` and `R` into -1 and 1 respectively, such that they can be used to
set the signs of the numbers. We can do this by creating a [dictionary](https://code.kx.com/q/basics/dictsandtables/)
and applying it to the list of the first characters of each line:
```q
q)"LR"!-1 1
L| -1
R| 1
```
We obtain the first item of each string by indexing with an elided first index and a zero second
index:
```q
q)x[;0]
"LLRLRLLLRL"
```
We apply the dictionary by juxtaposition:
```q
q)("LR"!-1 1)x[;0]
-1 -1 1 -1 1 -1 -1 -1 1 -1
```
Now we extract the step counts by first [dropping](https://code.kx.com/q/ref/drop/) the first
element. The operation needs to match the static parameter `1` on the left to each element of the
list on the right, which is achieved using the [`/:` (each right)](https://code.kx.com/q/ref/maps/#each-left-and-each-right)
iterator.
```q
q)1_/:x
"68"
"30"
"48"
,"5"
"60"
"55"
,"1"
"99"
"14"
"82"
```
Then we convert them from strings to integers. This uses the `$` operator in the [lexical cast](https://code.kx.com/q/ref/tok/)
sense. The type we cast to is `"J"`, which stands for `long`. This kind of conversion will appear in
almost every puzzle.
```q
q)"J"$1_/:x
68 30 48 5 60 55 1 99 14 82
```
We multiply the numbers by their signs that we calculated above:
```q
q)(("LR"!-1 1)x[;0])*"J"$1_/:x
-68 -30 48 -5 60 -55 -1 -99 14 -82
```
To calculate the partial sums, we use one of the overloads of the [`\` (scan)](https://code.kx.com/q/ref/accumulators/#binary-values)
iterator that takes a starting value and a binary operator. The starting value is 50, and the
operator is `+`.
```q
q)50+\(("LR"!-1 1)x[;0])*"J"$1_/:x
-18 -48 0 -5 55 0 -1 -100 -86 -168
```
Since the numbers need to wrap around, we `mod` them by 100:
```q
q)(50+\(("LR"!-1 1)x[;0])*"J"$1_/:x)mod 100
82 52 0 95 55 0 99 0 14 32
```
We can use the `=` operator to compare each element in the list to zero. Since `=` is atomic, there
is no need to use an explicit iterator this time.
```q
q)0=(50+\(("LR"!-1 1)x[;0])*"J"$1_/:x)mod 100
0010010100b
```
And since booleans work fine in arithmetic operations, we can sum this list to get the answer.
```q
q)sum 0=(50+\(("LR"!-1 1)x[;0])*"J"$1_/:x)mod 100
3i
```

## Part 2
Easter egg:
```q
q)`char$0x434C49434B
"CLICK"
```
For this part, we just repeat the number 1 and -1 the appropriate number of times and then find the
partial sums of this version of the list.

We convert the letters `L` and `R` into -1 and 1 like before:
```q
q)("LR"!-1 1)x[;0]
-1 -1 1 -1 1 -1 -1 -1 1 -1
```
Instead of multiplying, we use the [`#` (take)](https://code.kx.com/q/ref/take/) operator to
duplicate -1 or 1 the necessary amount of times. We need to apply the operator pairwise between the
multiplicities on the left and the numbers to be duplicated on the right, which can be achieved
with the [`'` (each)](https://code.kx.com/q/ref/maps/#each) iterator.
```q
q)("J"$1_/:x)#'("LR"!-1 1)x[;0]
-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1..
-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
-1 -1 -1 -1 -1
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ..
-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1..
,-1
-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1..
1 1 1 1 1 1 1 1 1 1 1 1 1 1
-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1..
```
We use `raze` to turn this all into a single list, then find the partial sums as in part 1:
```q
q)(50+\raze("J"$1_/:x)#'("LR"!-1 1)x[;0])mod 100
49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17..
```
We also use the same logic to find the zeros and sum their count:
```q
q)sum 0=(50+\raze("J"$1_/:x)#'("LR"!-1 1)x[;0])mod 100
6i
```
