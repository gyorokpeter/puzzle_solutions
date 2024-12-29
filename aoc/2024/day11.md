# Breakdown

Example input:
```q
x:enlist"125 17";
```

## Common
We only store the number of occurrences of every number. Despite the puzzle placing emphasis on the
order being important, it's actually not, that's probably there to lead the reader down the garden
path.

We split the input on spaces and convert it to integers:
```q
q)n:"J"$" "vs first x;
q)n
125 17
```
We count the number of occurrences of each number using `count each group`. This returns a
dictionary, which we turn into a table, putting the keys into the column `n` and the values into the
column `c`.
```q
q)t:{([]n:key x;c:value x)}count each group n
q)t
n   c
-----
125 1
17  1
```
We define the successor function as a [conditional](https://code.kx.com/q/ref/cond/) with different
branches for the possible operations.

If the number is zero, we replace it with 1:
```q
    $[0=x;1;...]
```
We split the number into digits using `10 vs`, and check if this is even (`mod 2` returns 0 for it).
If it does, we split it in half. `2 0N#` does exactly that, splitting a list into a 2-row matrix
with the suitable number of columns.
```q
    $[0=x;1;0=count[s:10 vs x]mod 2;10 sv/:2 0N#s;...]
```
In the default case, we multiply the number by 2024:
```q
    $[0=x;1;0=count[s:10 vs x]mod 2;10 sv/:2 0N#s;2024*x]
```
We also need to turn the result into a list for consistency. An easy way is to concatenate it to an
empty list.
```q
    f:{(),$[0=x;1;0=count[s:10 vs x]mod 2;10 sv/:2 0N#s;2024*x]}
```
There is one more level needed to perform the transformation of the full set of stones. This is just
a technicality based on how we represent the stones: we call `f` on the `n` column, which replaces
it with a list of lists. We can then `ungroup` this so we return to the form where each row
represents only one value, then we also have to sum the counts for the identical numbers for
deduplication.
```q
    g:{[f;x]select sum c by n from ungroup update f each n from x}[f]
```
We can then use `/` (over) with a step count to iterate `g` a certain number of times:
```q
q)g/[steps;t]
n       | c
--------| ----
0       | 2952
1       | 2138
2       | 2862
3       | 727
4       | 3204
5       | 606
..
```
The answer is the sum of the `c` column in the table.
```q
q)exec sum c from g/[steps;t]
55312
```
This logic solves both parts with a `steps` parameter indicating the number of steps.

## Part 1
The step count is 25.
```q
q)d11[25;x]
55312
```

## Part 2
The step count is 75. Note that there is no example given in the puzzle.
```q
q)d11[75;x]
65601038650482
```
