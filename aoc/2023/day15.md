# Breakdown

Example input:
```q
x:enlist"rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
```

## Common
The hashing algorithm can be implemented as an iteration, starting from 0 and processing the characters one by one:
```q
.d15.hash:{{(17*x+y)mod 256}/[0;`long$x]};
```

## Part 1
We split the input on `","` and use the hash function on each element:
```q
q)","vs raze x
"rn=1"
"cm-"
"qp=3"
"cm=2"
"qp-"
"pc=4"
"ot=9"
"ab=5"
"pc-"
"pc=6"
"ot=7"
q).d15.hash each","vs raze x
30 253 97 47 14 180 9 197 48 214 231
q)sum .d15.hash each","vs raze x
1320
```

## Part 2
It turns out that the update and delete operations on q's dictionaries work exactly according to the long description in the puzzle.

We iterate an update function starting from a list of 256 empty dictionaries (`256#enlist(`$())!`long$()`) and process the instructions one by one. Inside the function we use a conditional (`$[...]`) to perform either an update or a delete. Both are trivial operations, most of the code is just glue to extract the index into the boxes and the element to add or delete.
```q
ins:","vs raze x
box:{$["="in y;[p:"="vs y;x[.d15.hash p 0;`$p 0]:"J"$p 1];
    "-"in y;[b:first"-"vs y;x[.d15.hash b]_:`$b];
    '`nyi];x}/[256#enlist(`$())!`long$();ins]
```
We read out the result from each box by multiplying together the three properties for each element: the box number (`1+til 256`), the slot number (`til each count each box`) and the value of the element itself.
```q
q)box*(1+til 256)*1+til each count each box
`rn`cm!1 4
(`symbol$())!`long$()
(`symbol$())!`long$()
`ot`ab`pc!28 40 72
(`symbol$())!`long$()
..
q)sum sum each box*(1+til 256)*1+til each count each box
145
```
