# Breakdown

## Part 1
Example input:
```q
x:"xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
```
We raze the input into a single string, but this is a formality as there is only one line:
```q
q)a:raze x
q)a
"xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
```
We split on the string `mul(`, so we get the substrings after each start of a `mul` expression:
```q
q)"mul("vs a
,"x"
"2,4)%&mul[3,7]!@^do_not_"
"5,5)+"
"32,64]then("
"11,8)"
"8,5))"
```
There is an extra element at the beginning before the first `mul`, so we drop it:
```q
q)1_"mul("vs a
"2,4)%&mul[3,7]!@^do_not_"
"5,5)+"
"32,64]then("
"11,8)"
"8,5))"
```
To find the ends of the expressions, we split on `")"`:
```q
q)")"vs/:1_"mul("vs a
("2,4";"%&mul[3,7]!@^do_not_")
("5,5";,"+")
,"32,64]then("
("11,8";"")
("8,5";"";"")
```
The interesting parts here are the first elements of each list:
```q
q)first each ")"vs/:1_"mul("vs a
"2,4"
"5,5"
"32,64]then("
"11,8"
"8,5"
```
We find the parameters by splitting on `","`:
```q
q)","vs/:first each ")"vs/:1_"mul("vs a
,"2" ,"4"
,"5" ,"5"
"32" "64]then("
"11" ,"8"
,"8" ,"5"
```
We conert the results to integers:
```q
q)b:"J"$","vs/:first each ")"vs/:1_"mul("vs a
q)b
2  4
5  5
32
11 8
8  5
```
Note that this result still includes invalid entries, which appear as nulls. We have to filter the
list to only keep elements with no nulls:
```q
q){x where not 0N in/:x}b
2  4
5  5
11 8
8  5
```
We also need to filter to ensure each list has two elements. There are no violations of this rule in
the example input but there are in the real input.
```q
q)c:{x where 2=count each x}{x where not 0N in/:x}b
q)c
2  4
5  5
11 8
8  5
```
We can multiply the corresponding numbers by applying the `*` operator with `.`, but we have to use
_each-right_ as we have multiple lists of operands:
```q
q)(*)./:c
8 25 88 40
```
We sum the products:
```q
q)sum(*)./:c
161
```

## Part 2
Example input:
```q
x:"xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
```
We split on `"don't()"`, then inside each segment, we split on `"do()"`:
```q
q)a
,"xmul(2,4)&mul[3,7]!^"
("_mul(5,5)+mul(32,64](mul(11,8)un";"?mul(8,5))")
```
Now the active sections are the first element plus all but the first elements of the remaining
elements:
```q
q)a[0],raze 1_/:1_a
"xmul(2,4)&mul[3,7]!^"
"?mul(8,5))"
```
We call the part 1 logic to evaluate these. Due to the use of `raze` this is vulnerable to input
where a `mul(...)` comes together accidentally from multiple segments, but this doesn't happen in
the input.
```q
q)d3p1 a[0],raze 1_/:1_a
48
```
