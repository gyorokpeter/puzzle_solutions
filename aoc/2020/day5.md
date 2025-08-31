# Breakdown
Example input:
```q
x:"\n"vs"BFFFBBFRRR\nFFFBBBFRRR\nBBFFBBFRLL"
```

## Common
The idea is that the seat identifiers are simply a binary number representing the seat number,
with `F` and `L` standing for 0 and `B` and `R` standing for 1.

We use the dictionary `"FBLR"!0101b` to map each letter to the corresponding binary digit.
```q
q)("FBLR"!0101b)x
1000110111b
0001110111b
1100110100b
```
We add 6 zeros at the beginning to pad these to the nearest available integer type, which has 16
bits.
```q
q)(6#0b),/:("FBLR"!0101b)x
0000001000110111b
0000000001110111b
0000001100110100b
```
Then we use the [`0b sv](https://code.kx.com/q/ref/sv/#bits-to-integer) operator to turn the boolean
lists into the corresponding integers.
```q
q)0b sv/:(6#0b),/:("FBLR"!0101b)x
567 119 820h
```
This logic will be the function d5.

## Part 1
The answer is the maximum of this list.
```q
q)max d5[x]
820h
```
## Part 2
The input used for the demonstration is an actual puzzle input, loaded using the equivalent of
```q
    x:read0`:day5.in
```
We get the list of integer seat numbers again:
```q
q)d5[x]
807 411 175 87 819 594 503 33 657 195 512 292 149 471 318 290 704 430 579 37 117 272 699 461 768 5..
```
We put them in ascending order:
```q
q)s:asc d5[x]
q)s
`s#12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43..
```
Now we need to find a break in the middle of the list. We use
[`deltas`](https://code.kx.com/q/ref/deltas/) to generate the differences between consecutive
elements:
```q
q)deltas s
12 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1..
```
There should be another number that is greater than 1 somewhere:
```q
q)where 1<deltas s
0 628
```
The first element is greater than 1 because the seat numbers don't start with 1 but we only need
the second number:
```q
q)last where 1<deltas s
628
```
Using this as an index into the list reveals the number after the jump:
```q
q)s last where 1<deltas s
641h
```
So the answer is one less than this number:
```q
q)-1+s last where 1<deltas s
640
```
