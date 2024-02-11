# Overview
There is no programmatic solution for this one. I have made an integration for [GenArch](../utils)
for the purpose of reverse engineering, which can be found in [alu.q](alu.q).

The input program consists of 14 blocks of 18 instructions each. Each block does the following:

* input one digit
* either pop or peek the top element of the stack (pop/peek of an empty stack returns zero)
* add a number to the retrieved element and compare it to the input digit
* if they don't match, push the input plus another number on the stack

The variance comes from what numbers are added during the comparison and during the push (14+14
numbers) and whether the stack is popped or peeked (14 possible locations but in the inputs that I
observed, only 9 of them had differences between inputs).

The "stack" is implemented by interpreting the z register as a base-26 number. So a `mod 26` means
peeking the stack and a `div 26` means popping it. The places where there is a difference between
inputs on where the peeks and pops are, this is done by having a `div 26` in one input and a `div 1`
in another since `div 1` is a noop. There always seems to be 7 peeks and 7 pops, and the peeks
always match up with the unconditional pushes.

The numbers used for comparison and pushing put constraints on the digits. Sometimes the
constraints are impossible to meet, such as "the second digit must be the first digit plus 11",
which corresponds to an unconditional push. In the other cases, if the constraint is met, no number
is pushed. So in order to have the input accepted, all the constraints must be met.

Once we have the list of constraints we can start with 99999999999999 and lower just enough digits
as necessary to meet the constraints. For part 2, we start with 11111111111111 and raise just
enough digits to meet the constraints.

# Whiteboxing
The input used for the demonstration is an actual puzzle input, loaded using the equivalent of
```q
    x:read0`:day24.in
```

## Common
We cut the input into lines, then extract the numbers that indicate the peek and pop instructions
and the numbers used for comparison and pushing:
```q
q)stackOp:(1 26!`peek`pop)"J"$last each" "vs/:x[4+18*til 14]
q)stackOp
`peek`peek`peek`pop`peek`pop`pop`peek`pop`peek`peek`pop`pop`pop
q)compareNum:"J"$last each " "vs/:x[5+18*til 14]
q)compareNum
11 11 15 -14 10 0 -6 13 -3 13 15 -2 -9 -2
q)pushNum:"J"$last each " "vs/:x[15+18*til 14]
q)pushNum
6 14 13 1 6 13 6 3 8 14 4 7 15 1
```
We generate the stack content at each step, assuming that each peek also comes with a pop. The
stack content is represented as pairs of (digit index;number added before push):
```q
q)stackContent:enlist[()],-1_{[x;a;b;c]$[a=`peek;x,enlist(c;b);-1_x]}\[();stackOp;pushNum;til 14]
q)stackContent
()
,0 6
(0 6;1 14)
(0 6;1 14;2 13)
(0 6;1 14)
(0 6;1 14;4 6)
(0 6;1 14)
,0 6
(0 6;7 3)
,0 6
(0 6;9 14)
(0 6;9 14;10 4)
(0 6;9 14)
,0 6
```
Using the stack values, we find the digits that are popped during the pop instructions:
```q
q)poppedNum:?[stackOp=`pop;last each stackContent;14#enlist`int$()]
q)poppedNum
`int$()
`int$()
`int$()
2 13
`int$()
4 6
1 14
`int$()
7 3
`int$()
`int$()
10 4
9 14
0 6
```
We extract the actual differences used for comparison by adding the numbers added before push to
the numbers added before comparison:
```q
q)compare:?[stackOp=`pop;(last each poppedNum)+compareNum;0N]
q)compare
0N 0N 0N -1 0N 6 8 0N 0 0N 0N 2 5 4
```
Then we put the constraints together, from the indices of the popped digits, the comparison
differences and the index of the operation itself, filtering to those rows where the operation is
pop:
```q
q)constr:enlist'[first each poppedNum;compare;til 14] where stackOp=`pop
q)constr
2  -1 3
4  6  5
1  8  6
7  0  8
10 2  11
9  5  12
0  4  13
```
In the above example, the first line means "the digit at index 3 is the digit at index 2 minus 1".
The second line means "the digit at index 5 is the digit at index 4 plus 6".

Now we can apply the constraints to a base number.

## Part 1
We start with 14 copies of the digit 9, and for every positive difference we subtract it from the
first index in the constraint, and for every negative difference we add it to the last index in the
constraint:
```q
q)@[;;-;]\[14#9;?[constr[;1]<0;constr[;2];constr[;0]];abs constr[;1]]
9 9 9 8 9 9 9 9 9 9 9 9 9 9
9 9 9 8 3 9 9 9 9 9 9 9 9 9
9 1 9 8 3 9 9 9 9 9 9 9 9 9
9 1 9 8 3 9 9 9 9 9 9 9 9 9
9 1 9 8 3 9 9 9 9 9 7 9 9 9
9 1 9 8 3 9 9 9 9 4 7 9 9 9
5 1 9 8 3 9 9 9 9 4 7 9 9 9
q)p1:10 sv @[;;-;]/[14#9;?[constr[;1]<0;constr[;2];constr[;0]];abs constr[;1]]
q)p1
51983999947999
```
## Part 2
Part 2 is a mirror image of part 1: we start from 1s, positive differences are added to the second
digit and negative differences are subtracted from the first digit.
```q
q)@[;;+;]\[14#1;?[constr[;1]<0;constr[;0];constr[;2]];abs constr[;1]]
1 1 2 1 1 1 1 1 1 1 1 1 1 1
1 1 2 1 1 7 1 1 1 1 1 1 1 1
1 1 2 1 1 7 9 1 1 1 1 1 1 1
1 1 2 1 1 7 9 1 1 1 1 1 1 1
1 1 2 1 1 7 9 1 1 1 1 3 1 1
1 1 2 1 1 7 9 1 1 1 1 3 6 1
1 1 2 1 1 7 9 1 1 1 1 3 6 5
q)p2:10 sv @[;;+;]/[14#1;?[constr[;1]<0;constr[;0];constr[;2]];abs constr[;1]]
q)p2
11211791111365
```
