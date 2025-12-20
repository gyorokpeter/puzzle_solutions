# Breakdown
Example input:
```q
x:"\n"vs"987654321111111\n811111111111119\n234234234234278\n818181911112111"
```

## Part 1
We find the maximum digit in each line, ignoring the last digit as we need to ensure we have at
least one digit left to use as the second digit:
```q
q)x
"987654321111111"
"811111111111119"
"234234234234278"
"818181911112111"
q)-1_/:x
"98765432111111"
"81111111111111"
"23423423423427"
"81818191111211"
q)a:max each -1_/:x
q)a
"9879"
```
We search for these maximum values and drop the beginning of the lines until the first occurrence:
```q
q)x='a
100000000000000b
100000000000000b
000000000000010b
000000100000000b
q)where each x='a
0
0
13
6
q)first each where each x='a
0 0 13 6
q)(1+first each where each x='a)_'x
"87654321111111"
"11111111111119"
,"8"
"11112111"
```
We take the maximum of this remaining part to get the second digits:
```q
q)b:max each(1+first each where each x='a)_'x
q)b
"8982"
```
We join the two found digits together, convert them to integers, then sum them to get the answer:
```q
q)a,'b
"98"
"89"
"78"
"92"
q)"J"$a,'b
98 89 78 92
q)sum"J"$a,'b
357
```

## Part 2
A generalization of the above. We start with requiring numbers of length `n`. We find the first
maximal digit in each line, ignoring the last `n-1` digits, as we need at least that many to
complete the numbers. Going for the maximum is always the best choice, as otherwise we would end up
with a number that is lexicographically less than one that we could have picked, and we can't fix
this with any choice of the later digits. We repeat the choice for lower and lower values of `n`.

We initialize `n` to 12 and create a variable for the results. This needs to be a list of lists that
has the same length as the input - a trick to create this is to take 0 elements of each list in the
input.
```q
q)n:12
q)r:0#/:x
q)r
""
""
""
""
```
We initialize a variable that holds the remaining part of the input:
```q
q)x1:x
```
We iterate as long as we have digits left to add:
```q
    while[n>0;
        ...
    ];
```
In the iteration, we start by decrementing `n` (it is a useful trick to do this first, as otherwise
`n-1` would have to appear in the next expression):
```q
q)n-:1
q)n
11
```
We find the maximum digit, ignoring the last `n` characters in each line:
```q
q)neg[n]_/:x1
"9876"
"8111"
"2342"
"8181"
q)a:max each neg[n]_/:x1
q)a
"9848"
```
We append the found maximal digits to the under-construction results:
```q
q)r:r,'a
q)r
,"9"
,"8"
,"4"
,"8"
```
We search for these maximum values and drop the beginning of the lines until the first occurrence:
```q
q)x1:(1+first each where each x1='a)_'x1
q)x1
"87654321111111"
"11111111111119"
"234234234278"
"18181911112111"
```
This is the end of the code for the iteration.

At the end of the iteration, the variable `r` will contain the full numbers:
```q
q)r
"987654321111"
"811111111119"
"434234234278"
"888911112111"
```
We convert them into integers and sum them:
```q
q)"J"$r
987654321111 811111111119 434234234278 888911112111
q)sum"J"$r
3121910778619
```
