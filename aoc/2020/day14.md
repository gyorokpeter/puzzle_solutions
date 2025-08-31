# Breakdown

## Part 1

Example input:
```q
x :enlist"mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
x,:enlist"mem[8] = 11"
x,:enlist"mem[7] = 101"
x,:enlist"mem[8] = 0"
```

The solution uses an iterated function. We initialze the state to `(();()!())`. The first element is
the mask and the second element is the memory contents.

In the function, we check the type of the instruction:
```q
    $[x like "mask*"; ...;
    ...]
```
For the `"mask"` case, we update the first element of the state. We cast each element of the mask to
integers and prepend 28 nulls (36+28=64).
```q
q)x:"mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
q)last" "vs x
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
q)"J"$/:last" "vs x
0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 1 0N 0N 0N ..
q)mask:(28#0N),"J"$/:last" "vs x
q)mask
0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N..
```
This way the mask is 3-valued, which is useful as we can fill over the nulls.

In the "assignment" case, we first calculate the index that needs overwriting by cutting the string
on square brackets:
```q
q)x:"mem[8] = 11"
q)"J"$last"["vs first"]"vs x
8
```
We get the new value by splitting on spaces and taking the last element:
```q
q)"J"$last" "vs x
11
```
We convert the number to a list of booleans using `0b vs`:
```q
q)0b vs "J"$last" "vs x
0000000000000000000000000000000000000000000000000000000000001011b
```
We fill the list with the mask. This means the non-null elements on the mask will overwrite the
number. We also compare the result to 1 to convert it back to a list of booleans:
```q
q)1=(0b vs "J"$last" "vs x)^mask
0000000000000000000000000000000000000000000000000000000001001001b
```
We convert the result back into a number using `0 sv` (the inverse operation of `0 vs`). This is
where the size matters, as the operation will only succeed if the list length is one of the
supported integer sizes, in this case 64. This is why we needed to pad the mask to 64 bits
```q
q)0b sv 1=(0b vs "J"$last" "vs x)^mask
73
```
The full assignment looks like this:
```q
    st[1;"J"$last"["vs first"]"vs x]:0b sv 1=(0b vs "J"$last" "vs x)^st[0]
```
We also return `st` from the function so it can be passed into the next iteration.

We iterate the function over the list of instructions:
```q
    st:{[st;x] ... st}/[(();()!());x]
```
At the end of the iteration, we get the final state:
```q
q)st
0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N..
8 7!64 101
```
To get the answer, we sum the stored values in the second element of the state:
```q
q)sum st 1
165
```

## Part 2

Example input:
```q
x :enlist"mask = 000000000000000000000000000000X1001X"
x,:enlist"mem[42] = 100"
x,:enlist"mask = 00000000000000000000000000000000X0XX"
x,:enlist"mem[26] = 1"
```
Like part 1, we are iterating a function. The state will contain 3 elements: the bits to change to
1, the bits that change in every possible way, and the memory map. When updating the mask, we
don't store the values of the bits but the indices where the special bits are. We still need to pad
to 64 bits, but we do that by adding 28 to the index.
```q
q)x:"mask = 000000000000000000000000000000X1001X"
q)m:last" "vs x
q)m
"000000000000000000000000000000X1001X"
q)mask1:28+where m="1"
q)mask1
59 62
q)maskX:28+where m="X"
q)maskX
58 63
```
For the assignment case, we find the number and split it into a list of digits:
```q
q)x:"mem[42] = 100"
q)d:0b vs"J"$last"["vs first"]"vs x
q)d
0000000000000000000000000000000000000000000000000000000000101010b
```
We overwrite the digits that need to be changed to 1:
```q
q)d[mask1]:1b
q)d
0000000000000000000000000000000000000000000000000000000000111010b
```
We generate all the combinations of `0b` and `1b` for the nubmer of fluctiating bits. (This could be
cached but this wasn't necessary for the solution.)
```q
q){x cross 01b}/[count[maskX]-1;01b]
00b
01b
10b
11b
```
We use functional amend to generate each possible result of flipping the bits. The indices come from
the mask, while the values to assign are the combinations above:
```q
q)@[d;maskX;:;]each{x cross 01b}/[count[maskX]-1;01b]
0000000000000000000000000000000000000000000000000000000000011010b
0000000000000000000000000000000000000000000000000000000000011011b
0000000000000000000000000000000000000000000000000000000000111010b
0000000000000000000000000000000000000000000000000000000000111011b
```
We convert back to integers to get the final addresses:
```q
q)d:0b sv/:@[d;maskX;:;]each{x cross 01b}/[count[maskX]-1;01b]
q)d
26 27 58 59
```
We finally assign the value from the instruction to all of these addresses. The full assignment part
looks like this:
```q
    d:0b vs"J"$last"["vs first"]"vs x;d[st[0]]:1b;
    d:0b sv/:1=@[d;st[1];:;]each{x cross 01b}/[count[st[1]]-1;01b];
    st[2;d]:"J"$last" "vs x
```
We iterate the function over the list of instructions:
```q
    st:{[st;x] ... st}/[(();();()!());x]
```
At the end of the iteration, we get the final state:
```q
q)st
`long$()
60 62 63
26 27 58 59 16 17 18 19 24 25!1 1 100 100 1 1 1 1 1 1
```
To get the answer, we sum the stored values in the third element of the state:
```q
q)sum st 2
208
```
