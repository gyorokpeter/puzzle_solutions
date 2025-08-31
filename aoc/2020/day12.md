# Breakdown
Example input:
```q
x:"\n"vs"F10\nN3\nF7\nR90\nF11"
```

## Part 1
For this part it is possible to separate the absolute and relative commands and then add together
the results. For the relative commands we first calculate the direction the ship will face after
each command, and then combine the distances from F commands with the current directions as of
those commands to figure out the positions of the ship. For absolute commands we simply map them
to coordinate changes and add them together.

We get the command from each line:
```q
q)d:first each x
q)d
"FNFRF"
```
We get the parameters by dropping the first character from each line and converting to integers:
```q
q)p:"J"$1_/:x
q)p
10 3 7 90 11
```
We find the indices of the relative commands:
```q
q)rel:where d in "FLR"
q)rel
0 2 3 4
```
We filter the command and parameter lists for the relative commands:
```q
q)drel:d rel
q)drel
"FFRF"
q)prel:p rel
q)prel
10 7 90 11
```
We generate the directions after each command. First we divide the parameters by 90 to get the
number of steps to turn:
```q
q)prel div 90
0 0 1 0
```
We multiply the step counts by -1 for a left turn and 1 for a right turn. This can be done by
indexing into a dictionary with the command letters. This returns nulls for F commands:
```q
q)("LR"!-1 1)drel
0N 0N 1 0N
```
We multiply the two together:
```q
q)(prel div 90)*("LR"!-1 1)drel
0N 0N 1 0N
```
We generate the facing direction using `\` (scan). Nulls are treated as zeros here so no need to
fill them in:
```q
q)1+\(prel div 90)*("LR"!-1 1)drel
1 1 2 2
```
Finally we modulo by 4 to ensure the directions go from 0 to 3:
```q
q)f:(1+\(prel div 90)*("LR"!-1 1)drel)mod 4
q)f
```
We find the position from the relative commands. To do this, we first index into a list of deltas
for each direction with the current direction at each step:
```q
q)(0 1;1 0;0 -1;-1 0)f
1 0
1 0
0 -1
0 -1
```
We multiply this with the result of the comparsion of the commands to `"F"`, as we don't move in the
rotation steps:
```q
q)(drel="F")*(0 1;1 0;0 -1;-1 0)f
1 0
1 0
0 0
0 -1
```
We multiply the deltas with the parameters to get the actual movements:
```q
q)prel*(drel="F")*(0 1;1 0;0 -1;-1 0)f
10 0
7  0
0  0
0  -11
```
The final position is the sum of the movements:
```q
q)pa:sum prel*(drel="F")*(0 1;1 0;0 -1;-1 0)f
q)pa
17 -11
```
We find the absolute commands and filter the command and parameter lists lik before:
```q
q)ab:where d in "NESW"
q)dabs:d ab
q)pabs:p ab
q)dabs
,"N"
q)pabs
,3
```
We calculate the movements in a very similar way to the relative ones:
```q
q)("NESW"!(0 1;1 0;0 -1;-1 0))dabs
0 1
q)pabs*("NESW"!(0 1;1 0;0 -1;-1 0))dabs
0 3
q)pb:sum pabs*("NESW"!(0 1;1 0;0 -1;-1 0))dabs
q)pb
0 3
```
Finally we add the absolute and relative total movements and take the absolute value of the sum of
the coordinates:
```q
q)pa+pb
17 -8
q)sum abs pa+pb
25
```

## Part 2
This is very similar to a VM implementation. We have a list of opcodes and a state consisting of
two points. Individual handler functions update the state based on the opcode.

We extract the commands and parameters like in part 1:

```q
q)d:first each x
q)p:"J"$1_/:x
q)d
"FNFRF"
q)p
10 3 7 90 11
```
We initialize a state with two coordinate pairs, one for the ship position and one for the waypoint:
```q
q)st:(0 0;10 1)
```
We initialize the dictionary of commands:
```q
q)op:()!()
```
Each command will take two parameters: the current state and the parameter for the command. The
command type is used as the dictionary index.

The operation for `N` adds the parameter to the second coordinate of the second pair:
```q
q)op["N"]:{x[1;1]+:y;x}
```
The operation for `E` adds the parameter to the first coordinate of the second pair:
```q
q)op["E"]:{x[1;0]+:y;x}
```
The operation for `S` subtracts the parameter from the second coordinate of the second pair:
```q
q)op["S"]:{x[1;1]-:y;x}
```
The operation for `W` subtracts the parameter from the first coordinate of the second pair:
```q
q)op["W"]:{x[1;0]-:y;x}
```
The operation for `L` is best expressed as multiplying the coordinates with two coefficients each
and adds together the result. For 180 degrees, the coefficient is -1 for the current coordinate
and 0 for the opposite. For left/right we also need to swap and only negate one of the coordinates.
`R` works similarly except the rotations are mapped in the opposite way.
```q
q)op["L"]:{x[1]:sum((90 180 270!((0 1;-1 0);(-1 0;0 -1);(0 -1;1 0)))y)*x[1];x}
q)op["R"]:{x[1]:sum((270 180 90!((0 1;-1 0);(-1 0;0 -1);(0 -1;1 0)))y)*x[1];x}
```
The operation for `F` adds the second coordinate pair times the parameter to the first pair:
```q
q)op["F"]:{x[0]+:y*x[1];x}
```
With this dictionary set up, we can use `/` (over) to iterate over the commands. Unfortunately there
is no variant of over that takes the state in the middle parameter, so we have to specify that the
function to iterate is `{y[x;z]}`, and since `op` is a local variable and therefore not accessible
in the lambda, we instead pre-index the dictionary with the commands, so in fact we are iterating
over a list of lambdas and a list of parameters.
```q
q)est:{y[x;z]}/[st;op d;p]
q)est
214 -72
4   -10
```
The answer is calculated by summing the absolute values of the first coorinate pair.
```q
q)sum abs est 0
286
```
