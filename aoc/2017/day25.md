# Breakdown
Example input:
```q
x:()
x,:enlist"Begin in state A."
x,:enlist"    Perform a diagnostic checksum after 6 steps."
x,:enlist""
x,:enlist"    In state A:"
x,:enlist"      If the current value is 0:"
x,:enlist"        - Write the value 1."
x,:enlist"        - Move one slot to the right."
x,:enlist"        - Continue with state B."
x,:enlist"      If the current value is 1:"
x,:enlist"        - Write the value 0."
x,:enlist"        - Move one slot to the left."
x,:enlist"        - Continue with state B."
x,:enlist""
x,:enlist"    In state B:"
x,:enlist"      If the current value is 0:"
x,:enlist"        - Write the value 1."
x,:enlist"        - Move one slot to the left."
x,:enlist"        - Continue with state A."
x,:enlist"      If the current value is 1:"
x,:enlist"        - Write the value 1."
x,:enlist"        - Move one slot to the right."
x,:enlist"        - Continue with state A."
```
We trim the input and split on spaces:
```q
q)lines:" "vs/:trim x
q)lines
("Begin";"in";"state";"A.")
("Perform";,"a";"diagnostic";"checksum";"after";,"6";"steps.")
,""
("In";"state";"A:")
..
```
We extract the starting state by indexing and cast it to symbol:
```q
q)startState:`$-1_lines[0;3]
q)startState
`A
```
We extract the step count by indexing and cast it to integer:
```q
q)steps:"J"$lines[1;5]
q)steps
6
```
We convert the rules into a more machine-friendly form by cutting the input (after the first 2
lines) into chunks of 10, then doing various kinds of indexing and conversion:
```q
q)rules:raze{([state:`$-1_x[1;2];input:01b]write:"B"$-1_/:x[3 7;4];move:(`left`right!-1 1)`$-1_/:x[4 8;6];nextState:`$-1_/:x[5 9;4])}each 10 cut 2_lines
q)rules
state input| write move nextState
-----------| --------------------
A     0    | 1     1    B
A     1    | 0     -1   B
B     0    | 1     -1   A
B     1    | 1     1    A
```
We simulate the Turing machine using an iterated function. The function takes the rules as a bound
parameter and also takes an accumulator. The accumulator contains the current state, the head
position and the tape as a boolean vector.
```q
q)sht:(startState;50;100#0b)
```
In the function, we get the rule corresponding to the current state:
```q
q)rule:rules[(sht 0;sht[2;sht 1])]
q)rule
write    | 1b
move     | 1
nextState| `B
```
We write the value indicated by the rule on the tape:
```q
q)sht[2;sht 1]:rule`write
q)sht
`A
50
00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000..
```
We update the head position as indicated by the rule:
```q
q)sht[1]+:rule`move
q)sht
`A
51
00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000..
```
We update the current state as indicated by the rule:
```q
q)sht[0]:rule`nextState
q)sht
`B
51
00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000..
```
We need to check if the move caused the head to move off the pre-allocated tape and add more
elements if necessary. If the head moved off the beginning of the tape, we also have to adjust the
position to compensate for the expansion.
```q
    if[sht[1]<0; sht[1]+:count[sht[2]]; sht[2]:(count[sht[2]]#0b),sht[2]];
    if[sht[1]>=count sht[2]; sht[2],:count[sht[2]]#0b];
```
The updated accumulator is the return value of the function.

We iterate the function using `/` (over), with the overload that takes a unary function, an
iteration count and an initial state:
```q
    finalState:{[rules;sht]
        ...
    }[rules]/[steps;(startState;50;100#0b)];
```
After the iteration, we have the final state:
```q
q)finalState
`A
50
00000000000000000000000000000000000000000000000011010000000000000000000000000000000000000000000000..
```
The answer is the sum of the tape array:
```q
q)sum finalState[2]
3i
```
