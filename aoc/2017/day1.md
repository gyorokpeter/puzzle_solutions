# Breakdown
The trick in both parts is to rotate the list and compare it to the original.

## Part 1
Example input:
```q
x:enlist"93112239"
```
By convention, the input is a list of strings, but we only have one element, so we take the first
element fro
m the list:
```q
q)a:first x
q)x
"93112239"
```
We rotate the string by 1 (which puts each character one position earlier and shifts the first one
into the last position:
```q
q)1 rotate a
"31122399"
```
We check where the rotated string matches the original. The `=` operator is atomic in q, so we don't
need any explicit iteration.
```
q)a=1 rotate a
00101001b
```
The comparison will only be true for numbers that match the next number on the list. So we filter
out to only keep those numbers using [`where`](https://code.kx.com/q/ref/where/) and indexing:
```q
q)a where a=1 rotate a
"129"
```
Then we parse each character as a number and sum them up. Normally, the [`$` (lexical cast)](https://code.kx.com/q/ref/tok/)
opreator would parse the whole string as a single integer. To parse the individual characters, we
need to use it with the [`/:` (each right)](https://code.kx.com/q/wp/iterators/#each-left-each-right)
iterator. We cast to `"J"` (long), the default integer type.
```q
q)"J"$/:a where a=1 rotate a
1 2 9
```
Then we sum the numbers:
```q
q)sum"J"$/:a where a=1 rotate a
12
```
There is one more catch: if the sum is empty, the list returned by the filtering will be an empty
general list instead of a string. This can be overcome by prepending a 0 to the list before summing.
```q
q)a:"1234"
q)sum"J"$/:a where a=1 rotate a
q)sum 0,"J"$/:a where a=1 rotate a
0
```

## Part 2
Example input:
```q
x:enlist"12131415"
```
Same as part 1 except we rotate by half the length of the list:
```q
q)a:first x
q)(count[a]div 2) rotate a
"14151213"
q)sum 0,"J"$/:a where a=(count[a]div 2) rotate a
4
```
