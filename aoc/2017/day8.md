# Breakdown
Example input:
```q
x:"\n"vs"b inc 5 if a > 1\na inc 1 if b < 5\nc dec -10 if a >= 1\nc inc -20 if c == 10"
```

## Common
The bulk of the solution is in the function `d8`. This function iterates a nested function over the
instruction list. The iterated function takes two parameters: an accumulator and the next line of
input. The accumulator is a list of two elements: a dictionary of registers and the list of highest
register values after each step. The iteration is done using `/` (over):
```q
    {[rm;x]
        ...
    }/[((`$())!`long$();`long$());x]
```
One step could look like:
```q
rm:((`$())!`long$();`long$())
x:"a inc 1 if b < 5"
```
In the iterated function, we extract the register map:
```q
q)reg:rm 0
```
We split the input line on spaces:
```q
q)p:" "vs x
q)p
,"a"
"inc"
,"1"
"if"
,"b"
,"<"
,"5"
```
We determine the condition using a dictionary mapping strings to operators, invoked on element 5 of
the instruction:
```q
q)cond:(("==";"!=";">=";"<=";enlist"<";enlist">")!(=;<>;<=;>=;<;>))p 5
q)cond
<
```
We evaluate the condition between the given register filled with 0 in case it is not yet set, and
the constant in element 6:
```q
q)p 4
,"b"
q)`$p 4
`b
q)reg`$p 4
0N
q)0^reg`$p 4
0
q)"J"$p 6
5
q)cond[0^reg`$p 4;"J"$p 6]
1b

    if[cond[0^reg`$p 4;"J"$p 6];
        ...
    ];
```
If the condition returns true, we update the register. We choose between adding and subtracting by
comparing element 1 to `"dec"` (the only other possibility is `"inc"` so we don't check that
explicitly), and multiply element 2 by 1 or -1 respectively. We use in-place add on the register
dictionary, which implicitly treats missing elements as zero.
```q
q)$["dec"~p 1;-1;1]
1
q)$["dec"~p 1;-1;1]*"J"$p 2
1
q)reg[`$p 0]+:$["dec"~p 1;-1;1]*"J"$p 2
q)reg
a| 1
```
We return the updated register map and the maximum value list extended with the current maximum:
```q
q)(reg;rm[1],max reg)
(,`a)!,1
,1
```
The code of the iterated function ends here. Calling the function on the original input returns the
final state of the registers (which is not relevant afterwards) and the list of maximum register
values per step:
```q
q)x
"b inc 5 if a > 1"
"a inc 1 if b < 5"
"c dec -10 if a >= 1"
"c inc -20 if c == 10"
q)d8 x
`a`c!1 -10
-0W 1 10 1
```

## Part 1
We call the common function and take the last element of the second element:
```q
q)last last d8 x
1
```

## Part 2
We call the common function and take the maximum of the second element:
```q
q)max last d8 x
10
```
