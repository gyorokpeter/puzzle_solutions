# Breakdown
Example input:
```q
x:"\n"vs"    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 \n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2";
```

## Common
We split the input into sections (by merging with newlines and splitting on double-newline - this will be a recurring operation):
```q
q)a:"\n\n"vs"\n"sv x
q)a
"    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 "
"move 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2"
```
For the **crates**:
```q
q)a 0
"    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 "
```
we cut on newlines:
```q
q)"\n"vs a 0
"    [D]    "
"[N] [C]    "
"[Z] [M] [P]"
" 1   2   3 "
```
We remove the last line containing the numbers:
```q
q)-1_"\n"vs a 0
"    [D]    "
"[N] [C]    "
"[Z] [M] [P]"
```
We cut each line into 4-character sections. The second character (i.e. at index 1) contains the letters.
```q
q)4 cut/:-1_"\n"vs a 0
"    " "[D] " "   "
"[N] " "[C] " "   "
"[Z] " "[M] " "[P]"
q)(4 cut/:-1_"\n"vs a 0)[;;1]
" D "
"NC "
"ZMP"
```
To make this easier to process, we `flip` (transpose) the lists, so each stack is on its own line, then `trim` to remove the spaces and `reverse` them so the top of the stack is at the end:
```q
q)flip(4 cut/:-1_"\n"vs a 0)[;;1]
" NZ"
"DCM"
"  P"
q)trim flip(4 cut/:-1_"\n"vs a 0)[;;1]
"NZ"
"DCM"
,"P"
q)st:reverse each trim flip(4 cut/:-1_"\n"vs a 0)[;;1]
q)st
"ZN"
"MCD"
,"P"
```
For the **instructions**:
```q
q)a 1
"move 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2"
```
we cut on newlines:
```q
q)"\n"vs a 1
"move 1 from 2 to 1"
"move 3 from 1 to 3"
"move 2 from 2 to 1"
"move 1 from 1 to 2"
```
We also cut on spaces and index to keep only the numbers:
```q
q)(" "vs/:"\n"vs a 1)
"move" ,"1" "from" ,"2" "to" ,"1"
"move" ,"3" "from" ,"1" "to" ,"3"
"move" ,"2" "from" ,"2" "to" ,"1"
"move" ,"1" "from" ,"1" "to" ,"2"
q)(" "vs/:"\n"vs a 1)[;1 3 5]
,"1" ,"2" ,"1"
,"3" ,"1" ,"3"
,"2" ,"2" ,"1"
,"1" ,"1" ,"2"
```
We convert the numbers to integers:
```q
q)"J"$(" "vs/:"\n"vs a 1)[;1 3 5]
1 2 1
3 1 3
2 2 1
1 1 2
```
The _from_ and _to_ indices are off by one, so we fix them by adding -1 but only those two, so we add the vector 0 -1 -1:
```q
q)ins:0 -1 -1+/:"J"$(" "vs/:"\n"vs a 1)[;1 3 5];
q)ins
1 1 0
3 0 2
2 1 0
1 0 1
```
The next part is to apply the instructions. This part can be generic to provide a common solution for both parts. We'll use an iterated function to perform one instruction. The function takes three parameters: the operation `op`, current state `x` and the next instruction `y`.

The processing consists of two parts:
* we copy the last `y[0]` crates from row `y[1]`, perform the operation on them, and append the result to the row `y[2]`:
```q
x[y 2],:op neg[y 0]#x[y 1];
```
* we delete the last `y[0]` crates from row `y[1]`:
```q
x[y 1]:neg[y 0]_x[y 1]
```
The completed function (`op` will be `reverse` for part 1 and `::` for part 2):
```q
f:{[op;x;y]x[y 2],:op neg[y 0]#x[y 1];x[y 1]:neg[y 0]_x[y 1];x}[op]
```
We iterate this function using `/` _over_, with the starting value being the `st` variable above and the input list being the instructions. Remember that `\` can be substituted to retrieve the intermetidate results.
```q
q)f\[st;ins]
"ZND" "MC" ,"P"
""    "MC" "PZND"
"MC"  ""   "PZND"
,"M"  ,"C" "PZND"
q)st2:f/[st;ins]
q)st2
,"M"
,"C"
"PZND"
```
The answer is the topmost, i.e. the last element of each stack.
```q
q)last each st2
"MCD"
```

## Note
The generic implementation allows support for e.g. a hypothetical CrateMover 9002 that can arrange crates in ascending order of their letters while holding them. For this one should pass in `desc` in the `op` parameter (as the topmost crate goes _last_).
