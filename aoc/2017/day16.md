# Breakdown
The function for part 1 takes an extra parameter for the initial string. The function for part 2
takes an extra parameter for the number of steps.

Example input:
```q
q)seq:"abcde"
q)x:enlist"s1,x3/4,pe/b"
q)n:2
```

The idea is to convert the set of instructions into a single transformation (actually two
transformations, one for the positions from the `s`/`x` instructions, and one for the letters from
the `p` instructions).

Part 1 is calling this transformation once. Part 2 is calculating the period of the transformation
and applying only as much as required. The periods are calculated by piecewise checking the period
of each letter/position and taking the least common multiple of those. Also note that the periods of
the positions and the letters could be different but they are independent in forming the solution.

We use helper functions to calculate greatest common divisor and least common multiple:
```q
gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
lcm:{(x*y)div gcd[x;y]};
```

## Building the transformation
`.d16.getTransform` converts a series of commands into a single transformation.

First we split the input on commas:
```q
q)x:"abcde"
q)y:"s1,x3/4,pe/b"
q)","vs y
"s1"
"x3/4"
"pe/b"
```
Then we do an iteration using `/` (over) using an accumulator and a list to iterate over.

The starting accumulator value is the identity transformation:
* The identity for the positions in the string x is `til count x` (0 1 2 ... n-1).
* The identity for the characters in the string x is `x!x` (each character maps to itself).
```q
q)pl:(til count x;x!x)
q)pl
0 1 2 3 4
"abcde"!"abcde"
```
Since the iterated function can only take one parameter for the accumulator, we pack the two
transformations into a two-element list. The other parameter to the function is the next element of
the input list:
```q
q)ni:"s13"
```
If the command is `s`, we extract the length of the rotation:
```q
q)"J"$1_ni
13
```
Then we use this value to rotate the position part of the mapping. Note that it's the output that is
rotated by the given number, not the mapping. To get the correct mapping, we rotate it by the
negation of the number.
```q
q)pl[0]
0 1 2 3 4
q)neg["J"$1_ni] rotate pl[0]
2 3 4 0 1
```
If the command is `x`, we swap two positions in the position mapping. We extract the two positions
from the string:
```q
q)ni:"x3/4"
q)pos:"J"$"/"vs 1_ni
q)pos
3 4
```
Then we swap the two respective values in the mapping.
```q
q)pl[0]
0 1 2 3 4
q)pl[0;pos]
3 4
q)pl[0;reverse pos]
4 3
q)pl[0;pos]:pl[0;reverse pos]
q)pl[0]
0 1 2 4 3
```
If the command is `p`, we swap two positions in the character mapping. This works similarly to the
above, except we use `"C"$` to parse (since the indexes are characters).

Also, we need to find the indices in the keys of the dictionary using the `?` operator.

`-1 .Q.s1 something` prints a linear version of a value to the console, instead of the normal
formatted output. The dictionary might fill too many lines when formatted. Since `-1` returns itself
in addition to printing a string,we have to add a  semicolon to the end of the line to discard it.
```q
q)ni:"pe/b"
q)"C"$"/"vs 1_ni
"eb"
q)-1 .Q.s1 pl[1];
"abcde"!"abcde"
q)pl[1]?"C"$"/"vs 1_ni
"eb"
q)pos:pl[1]?"C"$"/"vs 1_ni
q)pos
"eb"
q)pl[1;pos]
"eb"
q)pl[1;reverse pos]
"be"
q)pl[1;pos]:pl[1;reverse pos]
q)-1 .Q.s1 pl[1];
"abcde"!"aecdb"
```
This is the end of the code of the iterated function. We call this with `/` (over), and put this
wrapper in a function called `.d16.getTransform`.

## Part 1
We apply the returned transformation on the input.

Starting from the example:
```q
q)ins:first x
q)transform:.d16.getTransform[seq;ins]
q)transform
4 0 1 3 2
"abcde"!"aecdb"
```
We apply the two parts of the transformation by indexing:
```q
q)seq transform[0]
"eabdc"
q)transform[1] seq transform[0]
"baedc"
```

## Part 2
The number 1000000000 is too large to evaluate the transformation that many times, although it can
be done within an hour after the above transform trick.

However, since we are only applying the same 16-element permutations over and over, there will be
cycles in the generated values. The position and character mappings are independent for this
purpose. So we can first calculate the period of the position mapping, find the requested iteration
(e.g. 1000000000) modulo the period, and only do the transformation that many times. Then we can do
the same for the character mapping. Combining the two gives the final answer.

To get the period for the position mapping, we calculate it for each index. We use `\` (scan) on the
position mapping to follow each index until it wraps back to the initial position.
```q
q)transform[0]
4 0 1 3 2
q)(transform[0]\)each til count seq
0 4 2 1
1 0 4 2
2 1 0 4
,3
4 2 1 0
```
The period of each index is the number of elements in each of these lists:
```q
q)count each (transform[0]\)each til count seq
4 4 4 1 4
```
The period is the least common multiple of the individual periods. This is where the `lcm` helper
function comes in. We just fold it over the list using `/` (over):
```q
q)orderPeriod:lcm/[count each (transform[0]\)each til count seq]
q)orderPeriod
4
```
To get the final order, we count how many times we have to apply it:
```q
q)n mod orderPeriod
2
```
Then we apply the position mapping this many times to the identity mapping using the overload of `/`
(over) that takes the iteration count as the first parameter:
```q
q)order:transform[0]/[n mod orderPeriod;til count seq]
q)order
0 1 2 3 4
```
The calculation of the character mapping works the same way:
```
q)-1 .Q.s1 transform[1];
"abcde"!"aecdb"
q)(transform[1]\)each seq
,"a"
"be"
,"c"
,"d"
"eb"
q)count each (transform[1]\)each seq
1 2 1 1 2
q)permPeriod:lcm/[count each (transform[1]\)each seq]
q)permPeriod
2
q)perm:transform[1]/[n mod permPeriod;seq]
q)perm
"abcde"
```
Finally, we apply the position mapping to the result of the character mapping.
```
q)perm order
"abcde"
```
