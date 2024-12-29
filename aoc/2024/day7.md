# Breakdown

Example input:
```q
x:"\n"vs"190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15";
x,:"\n"vs"161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20";
```

## Part 1
We split on `": "`, then we parse the first elements into integers to get the target numbers, and
splith the last elements on `" "` for the operands:
```q
q)a:": "vs/:x
q)a
"190"    "10 19"
"3267"   "81 40 27"
"83"     "17 5"
"156"    "15 6"
"7290"   "6 8 6 15"
"161011" "16 10 13"
"192"    "17 8 14"
"21037"  "9 7 18 13"
"292"    "11 6 16 20"
q)t
190 3267 83 156 7290 161011 192 21037 292
q)n:"J"$" "vs/:a[;1]
q)n
10 19
81 40 27
17 5
15 6
6 8 6 15
16 10 13
17 8 14
9 7 18 13
11 6 16 20
```
We generate every possible combination of the operators by taking the cross product of the list of
operators with itself repeatedly. This iteration is done using 
[`scan (\)`](https://code.kx.com/q/ref/accumulators/), using the overload that takes a repetition
count and an initial value. We precalculate the list for every possible element count up to the
maximum occurring element count minus 1 (since we need one less operator than there are numbers).
```q
q)op:cross[;(+;*)]\[max[count each n]-1;enlist()]
q)op
,()
(,+;,*)
((+;+);(+;*);(*;+);(*;*))
((+;+;+);(+;+;*);(+;*;+);(+;*;*);(*;+;+);(*;+;*);(*;*;+);(*;*;*))
```
To get the actual operator list for each number list, we index into this list with the counts of the
lists minus one:
```q
q)op -1+count each n
(,+;,*)
((+;+);(+;*);(*;+);(*;*))
(,+;,*)
(,+;,*)
((+;+;+);(+;+;*);(+;*;+);(+;*;*);(*;+;+);(*;+;*);(*;*;+);(*;*;*))
((+;+);(+;*);(*;+);(*;*))
((+;+);(+;*);(*;+);(*;*))
((+;+;+);(+;+;*);(+;*;+);(+;*;*);(*;+;+);(*;+;*);(*;*;+);(*;*;*))
((+;+;+);(+;+;*);(+;*;+);(+;*;*);(*;+;+);(*;+;*);(*;*;+);(*;*;*))
```
Now we apply the operators to the number lists. The overall structure of this performs an operation
between the operand list and the operator list, so this requires a `'` (binary each in this case):
```q
{...}'[n;op -1+count each n]
```
Inside the lambda, we would like to try every operator sequence in succession, so there needs to be
another `each` (in this case an unary one) going over the operator list, which is the second
parameter (`y`):
```q
{...'[y]}'[n;op -1+count each n]
```
The logic that we would like to iterate is to start with the first operand, then apply the next
operator between the current value and the next operand. _Over_ (`/`) can do this - just like `'`,
the `/` operation is omnivalent, in this case we use the binary version (most textbook examples use
the unary version). The function to iterate is `{y[x;z]}`, since `x` is the accumulator, `y` is the
next operator and `z` is the next operand.
```q
q){{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]
29 190
148 3267 3267 87480
22 85
21 90
35 300 99 1260 69 810 303 4320
39 338 173 2080
39 350 150 1904
47 442 301 3744 94 1053 1147 14742
53 660 292 5440 102 1640 1076 21120
```
The correct numbers are those where the target appears in the results:
```q
q)t in'{{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]
110000001b
```
We filter the list of targets on this condition and sum the result:
```q
q)t where t in'{{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]
190 3267 292
q)sum t where t in'{{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]
3749
```

## Part 2
The code for part 1 looks like this so far:
```q
d7p1:{a:": "vs/:x; t:"J"$a[;0]; n:"J"$" "vs/:a[;1];
    op:cross[;(+;*)]\[max[count each n]-1;enlist()];
    sum t where t in'{{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]};
```
This lends itself to generalization: we only need to turn the list `(+;*)` into a parameter.
```q
d7:{[ops;x]a:": "vs/:x; t:"J"$a[;0]; n:"J"$" "vs/:a[;1];
    op:cross[;ops]\[max[count each n]-1;enlist()];
    sum t where t in'{{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]};
d7p1:{d7[(+;*);x]};
```
For part 2, we need to add concatenation as a third possible operator. However q has no built-in
numeric concatenation operator. There are multiple ways to implement one:
* Split the numbers into digits using `vs`, concatenate the lists, then convert back to an integer
using `sv`: `{10 sv raze 10 vs/:(x;y)}`
* Divide the second argument by 10 until it disappears, multiply the first argument by 10 for every
division, then add the original second argument: `{a:y;while[a>0;a:a div 10;x*:10];x+y}`
* Convert both numbers to strings, concatenate them, then parse the result as integer:
`{"J"$raze string(x;y)}`

After some experimentation, it appears the third option is the fastest, but even this one struggles
on the real input.
```q
q)d7[(+;*;{"J"$raze string(x;y)});x]
11387
```
