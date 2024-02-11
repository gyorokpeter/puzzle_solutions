# Breakdown
Example input:
```q
x:"[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]\n[[[5,[2,8]],4],[5,[[";
x,:"9,9],0]]]\n[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]\n[[[6,[0,7]],[0,9]],[4,[9,[";
x,:"9,0]]]]\n[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]\n[[6,[[7,3],[3,2]]],[[[3,";
x,:"8],[5,7]],4]]\n[[[[5,4],[7,7]],8],[[8,3],8]]\n[[9,3],[[9,9],[6,[4,9]]]]\n";
x,:"[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]\n[[[[5,2],5],[8,[3,7]]],[[5,[7,5]";
x,:"],[4,4]]]";
```

## Common
Broken down to the elementary operations:

### Reduce
For reduction, we should represent the numbers as integers since they can go above 9. However we
also need to keep to keep track of where the brackets are. So we keep the two representations in
parallel and update both of them when necessary with the exception that the numbers in the character
representation only need to be updated once, at the end.

We generate the integer list from the character representation:
```q
q)x:"[[[[[9,8],1],2],3],4]"
q)n:"J"$/:x;
q)n
0N 0N 0N 0N 0N 9 0N 8 0N 0N 1 0N 0N 2 0N 0N 3 0N 0N 4 0N
```
We perform an iteration until the input no longer changes. The details of the iteration are
explained below.
```q
q)red:.d18.reduce1/[(x;n)];
q)x:red 0; n:red 1;
q)x
"[[[[0,1],2],3],4]"
q)n
0N 0N 0N 0N 0 0N 9 0N 0N 2 0N 0N 3 0N 0N 4 0N
```
To update the digits, we find the indices of non-null numbers in the integer representation:
```q
q)digits:where not null n;
q)digits
4 6 9 12 15
```
Finally we substitute the characters with the string version of the digits. We have to `raze` the
string list because using `string` on a number always results in a list, even if it's only one
character long.
```q
q)x[digits]:raze string n[digits];
q)x
"[[[[0,9],2],3],4]"
```
#### Reduce step
The reduce step performs just one operation, depending on which one can be executed.

##### Explode
Here is an example when the operation is an explode:
```q
q)x:"[[6,[5,[4,[3,2]]]],1]"
q)n:"J"$/:x;
q)n
0N 0N 6 0N 0N 5 0N 0N 4 0N 0N 3 0N 2 0N 0N 0N 0N 0N 1 0N
```
We generate the depth at each position. This can be done by adding 1 for each `[` and subtracting 1
for each `]`. Thanks to atomic operations, we can compare the input to the two characters and
subtract the second list from the first. Then the depth is the cumulative sum of the result.
```q
q)x="["
110010010010000000000b
q)x="]"
000000000000001111001b
q)(x="[")-x="]"
1 1 0 0 1 0 0 1 0 0 1 0 0 0 -1 -1 -1 -1 0 0 -1i
q)depth:sums(x="[")-x="]";
q)
q)depth
1 2 2 2 3 3 3 4 4 4 5 5 5 5 4 3 2 1 1 1 0i
```
We look for any numbers to explode. The depth must be at least 5, and there must be a digit at the
given position.
```q
q)5<=depth
000000000011110000000b
q)not null n
001001001001010000010b
q)deep:(5<=depth) and not null n;
q)deep
000000000001010000000b
```
We find the first `1b` value in the list. We have to explode if the value returned by `?` iss less
than the length of the list.
```q
q)expl:deep?1b;
q)expl
11
q)expl<count[depth]
1b
```
We find the left and right numbers that will "soak up" the explosion. To do this we cut the list
to get the part before the exploding number and find the last non-null entry, and similarly we get
the part after the second exploding number (we add 3 to the index of the first exploding number to
find where to cut) and find the first non-null entry, adding the starting position of this section.
We use `where not null ...` which returns a list of indices, then we take either the first and last.
```q
q)expl#n
0N 0N 6 0N 0N 5 0N 0N 4 0N 0N
q)where not null expl#n
2 5 8
q)left:last where not null expl#n;
q)left
8
q)(expl+3)_n
0N 0N 0N 0N 0N 1 0N
q)where not null (expl+3)_n
,5
q)right:(expl+3)+first where not null (expl+3)_n;
q)right
19
```
We add the exploding numbers to the ones that will soak them up, as long as those numbers exist. We
do need to explicitly check, otherwise we would be assigning to a null index which is an error.
```q
q)n
0N 0N 6 0N 0N 5 0N 0N 4 0N 0N 3 0N 2 0N 0N 0N 0N 0N 1 0N
q)if[not null left; n[left]+:n expl];
q)if[not null right; n[right]+:n expl+2];
q)n
0N 0N 6 0N 0N 5 0N 0N 7 0N 0N 3 0N 2 0N 0N 0N 0N 0N 3 0N
```
We also need to replace the exploded segment with a zero. We cut the list again and concatenate the
two sections with a correctly-typed zero in the middle. We do this with both the integer and char
representations. (The numbers will be off in the char representation, that's fixed in the final step
of the outer function.)
```q
q)n:((expl-1)#n),0,(expl+4)_n;
q)n
0N 0N 6 0N 0N 5 0N 0N 7 0N 0 0N 0N 0N 0N 3 0N
q)x:((expl-1)#x),"0",(expl+4)_x;
q)x
"[[6,[5,[4,0]]],1]"
```
Since we changed the list, we need to exit the iteration step here.

##### Split
Here is an example that results in a split:
```q
q)x:"[[[[0,7],4],[7,[[8,4],9]]],[1,1]]"
q)n:"J"$/:x;
q)xn:.d18.reduce1(x;n)
q)x:xn 0;n:xn 1
q)x
"[[[[0,7],4],[7,[0,9]]],[1,1]]"
q)n
0N 0N 0N 0N 0 0N 7 0N 0N 4 0N 0N 0N 15 0N 0N 0 0N 13 0N 0N 0N 0N 0N 1 0N 1 0N 0N
```
We once again go through the steps to check for the need of an explosion, but find nothing:
```q
q)depth:sums(x="[")-x="]";
q)deep:(5<=depth) and not null n;
q)expl:deep?1b;
q)expl<count[depth]
0b
```
We look for numbers greater than or equal to 10 to split:
```q
q)split:first where 10<=n;
q)split
13
```
If we find any, we need to split:
```q
q)not null split
1b
```
We find the two resulting numbers by taking the floor and ceiling of the number divided by 2:
```q
q)n split
15
q)sn:{(floor x%2;ceiling x%2)}n split
q)sn
7 8
```
We insert the new numbers into the numeric representation, replacing the old number:
```q
q)n
0N 0N 0N 0N 0 0N 7 0N 0N 4 0N 0N 0N 15 0N 0N 0 0N 13 0N 0N 0N 0N 0N 1 0N 1 0N 0N
q)n:(split#n),0N,sn[0],0N,sn[1],0N,(split+1)_n
q)n
0N 0N 0N 0N 0 0N 7 0N 0N 4 0N 0N 0N 0N 7 0N 8 0N 0N 0N 0 0N 13 0N 0N 0N 0N 0N 1 0N 1 0N 0N
```
We also update the string representation. We use zeros as placeholders, as these will be overwritten
in the outer function.
```q
q)x
"[[[[0,7],4],[7,[0,9]]],[1,1]]"
q)x:(split#x),"[0,0]",(split+1)_x;
q)x
"[[[[0,7],4],[[0,0],[0,9]]],[1,1]]"
```

### Addition and Sum
Addition simply involves putting the two numbers into a list and reducing the result.
```q
q)x:"[[[[4,3],4],4],[7,[[8,4],9]]]"
q)y:"[1,1]"
q)"[",x,",",y,"]"
"[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"
q).d18.reduce"[",x,",",y,"]"
"[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
```
Summing is done by invoking the addition function with the `/` (over) iterator.
```q
q)x:("[1,1]";"[2,2]";"[3,3]";"[4,4]")
q).d18.add/[x]
"[[[[1,1],[2,2]],[3,3]],[4,4]]"
```

### Magnitude
To calculate the magnitued, we parse the string representation as JSON and use a recursive function
to perform the operation.
```q
q)x:"[[9,1],[1,9]]"
q).j.k x
9 1
1 9
```
The recursive function will have 3 cases. The first is when the current element is a general list
(type 0). In this case we call the function itself (`.z.s`) on each element and update the list:
```q
    if[0h=type x; x:.z.s each x];
```
If the current element is a number (in JSON all numbers are floats so this will be type `-9`), we
simply return the number:
```q
    if[-9h=type x; :x];
```
Otherwise we assume there are exactly 2 numbers in the list, so we multiply them by 3 and 2
respectively and sum the result:
```q
    sum 3 2*x
```

## Part 1
We split the input, sum the list and take the magnitude:
```q
    .d18.magn .d18.sum"\n"vs x
```

## Part 2
We split the input again, but instead of summing all of them, we pairwise add them, which can be
easily done by combining the `/:` and `\:` (each-right and each-left) iterators. The result is a
matrix, but we can `raze` the result to have a list of the pairwise sums:
```q
    raze {x .d18.add/:\:x}"\n"vs x
```
We calculate the magnitude of each result and then find the maximum:
```q
    max .d18.magn each raze {x .d18.add/:\:x}"\n"vs x
```
