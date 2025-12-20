# Breakdown
Example input:
```q
x:"\n"vs"123 328  51 64 \n 45 64  387 23 \n  6 98  215 314\n*   +   *   +  "
```

## Part 1
We cut every line on spaces. Due to the varying numbers of spaces, this will introduce extra empty
strings, which we need to remove:
```q
q)" "vs/:x
("123";"328";"";"51";"64";"")
("";"45";"64";"";"387";"23";"")
("";"";,"6";"98";"";"215";"314")
(,"*";"";"";,"+";"";"";,"*";"";"";,"+";"";"")
q)a:(" "vs/:x)except\:enlist""
q)a
"123" "328" "51"  "64"
"45"  "64"  "387" "23"
,"6"  "98"  "215" "314"
,"*"  ,"+"  ,"*"  ,"+"
```
We can find the operands by converting everything except the last line to integers:
```q
q)"J"$-1_a
123 328 51  64
45  64  387 23
6   98  215 314
```
The operators are in the first (and only) elements of each string in the last row:
```q
q)last[a][;0]
"*+*+"
```
However, these are not the actual operators we need to use, instead we need `sum` or `prd`. We can
use a dictionary to map the characters to the respective operator:
```q
q)("+*"!(sum;prd))last[a][;0]
prd
sum
prd
sum
```
We would like to apply the operators to the respective column of the operand matrix. It is easier to
express if we flip the operand matrix, in which case we perform function application pairwise
between the list of operators and the list of lists of operands:
```q
q)flip"J"$-1_a
123 45  6
328 64  98
51  387 215
64  23  314
q)(("+*"!(sum;prd))last[a][;0])@'flip"J"$-1_a
33210 490 4243455 401
```
The answer is the sum of the individual results:
```q
q)sum(("+*"!(sum;prd))last[a][;0])@'flip"J"$-1_a
4277556
```

## Part 2
Same deal as before, but the flipping appears in a different place.

We flip the input and cut on the locations of the lines that are made up of only spaces. As a
reminder, `cut` will remove the first section of its argument unless the number 0 is among the
cutting points. We can accommodate this by prepending an empty string (for which it is true that all
the characters in it are spaces), which ensures that 0 appears in the cuts, and it also makes the
post-cut segments consistent in that there is exactly one junk line at the start of them that we
have to remove.
```q
q)enlist[""],flip x
""
"1  *"
"24  "
"356 "
"    "
"369+"
"248 "
"8   "
"    "
" 32*"
"581 "
"175 "
"    "
"623+"
"431 "
"  4 "
q){where all each" "=x}enlist[""],flip x
0 4 8 12
q){(where all each" "=x)cut x}enlist[""],flip x
""     "1  *" "24  " "356 "
"    " "369+" "248 " "8   "
"    " " 32*" "581 " "175 "
"    " "623+" "431 " "  4 "
q)a:{1_/:(where all each" "=x)cut x}enlist[""],flip x
q)a
"1  *" "24  " "356 "
"369+" "248 " "8   "
" 32*" "581 " "175 "
"623+" "431 " "  4 "
```
To find the operands, we drop the last character of each string, then convert to integers, which
luckily ignores any leading and trailing space:
```q
q)-1_/:/:a
"1  " "24 " "356"
"369" "248" "8  "
" 32" "581" "175"
"623" "431" "  4"
q)"J"$-1_/:/:a
1   24  356
369 248 8
32  581 175
623 431 4
```
We find the operators again, which are in the last character of the first element of each row:
```q
q)last each a[;0]
"*+*+"
q)("+*"!(sum;prd))last each a[;0]
prd
sum
prd
sum
```
We apply the operators to the operands and sum the results:
```q
q)(("+*"!(sum;prd))last each a[;0])@'"J"$-1_/:/:a
8544 625 3253600 1058
q)sum(("+*"!(sum;prd))last each a[;0])@'"J"$-1_/:/:a
3263827
```
