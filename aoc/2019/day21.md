# Breakdown
Example input:
```q
q)md5 raze x
0xe1dc9309cfcb78514b0a17e9ac6a7a9e
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
The invocation of the intcode interpreter and printing of the output is rather straightforward:
```q
    a:.intcode.new x;
    a:.intcode.run[a];
    -1`char$last a;
    a:.intcode.getOutput .intcode.runI[a;{-1 x;`long$x}"\n"sv(
        ...
        "RUN";"")];
    -1`char$a;
    last a
```
The two parts are more focused on finding what code for the bot goes in the middle.

## Part 1
What if we just take the example for jumping over the tile in front?
```
NOT A J
```
The bot will jump here and end up in the pit:
```
....@............
#####..#.########
```
In this case we should jump one tile earlier. This can be expressed by checking C for a hole and
D for ground. The overall formula (using q's rules for evaluation order): `not[A] or not[C] and D`.
Converting this into bot code:
```
NOT A J     // J=not[A]
NOT C T     // T=not[C]
AND D T     // T=not[C] and D
OR T J      // T=not[A] or not[C] and D
```
Indeed this solves part 1:
```q
q)d21p1 x
Input instructions:

NOT A J
NOT C T
AND D T
OR T J
WALK


Walking...

?
19361414
```

## Part 2
What if we try the same solution as in part 1 but with `RUN` instead of `WALK`? It ends up failing
on this case:
```
..@..............
#####.#.##.#.####

......@..........
#####.#.##.#.####

.................
#####.#.##@#.####
```
The problem is that the bot jumped onto a spot where there is no valid move forward - both jumping
and not jumping lead to a pit. So we need to make sure that at least one of those tiles is passable:
`E or H`. Furthermore, `D` must still be true to jump on it, and to avoid complications with `A` and
`C`, we can instead have the jump condition being a pit in any of the three positions in front:
`not[A] or not[B] or not C`. Put together: `(not[A] or not[B] or not[C]) and D and E or H`.
Converting this into bot code:
```
NOT A J     // J=not A
NOT B T     // T=not B
OR T J      // J=not[A] or not B
NOT C T     // T=not C
OR T J      // J=not[A] or not[B] or not C
AND D J     // J=(not[A] or not[B] or not C) and D
NOT E T     // T=not E
NOT T T     // T=E
OR H T      // T=E or H
AND T J     // J=(not[A] or not[B] or not C) and D and E or H
```
Indeed this solves part 2:
```
q)d21p2 x
Input instructions:

NOT A J
NOT B T
OR T J
NOT C T
OR T J
AND D J
NOT E T
NOT T T
OR H T
AND T J
RUN


Running...

?
1139205618
```

## Whiteboxing
The intcode program runs a series of tests using predefined tracks, which change between inputs.
Each track is represented as a 9-bit integer, with 1 bits representing ground and 0 bits
representing holes (with the most significant bit on the left). There is some hardcoded ground at
the beginning and the end of each track, but that only matters for the simulation, not for the
whiteboxing.

As the robot passes over a hole, the score is increased by the product of:
* the memory address containing the current track
* the value of the current track
* the index of the hole, with 10 corresponding to the leftmost bit (which always seems to be a hole)
and increasing by 1 for each position towards the right.

The tracks are also stored at fixed addresses. The only difference between parts 1 and 2 is the list
of tracks. Part 2 goes through the same list of tracks as part 1 plus a large set of extra tracks.

### Common
To find the tracks, we need to pass in the indices where the tracks are located.

For part 1:
```q
ind:758+til 7
```
For part 2:
```q
ind:(758+til 7),766+til 153
```
The below is the demo for part 1.

We get the values for the tracks:
```q
q)a:"J"$","vs raze x
q)tracks:a[ind]
q)tracks
255 63 127 191 95 159 223
```
We split the tracks into bits to find the holes. `0b vs` splits in MSB-to-LSB order. However, the
integers are 64-bit and we only need the last 9 bits.
```q
q)-9#/:0b vs/:tracks
011111111b
000111111b
001111111b
010111111b
001011111b
010011111b
011011111b
```
We are looking for the pits, which are the negation of the above:
```q
q)not -9#/:0b vs/:tracks
100000000b
111000000b
110000000b
101000000b
110100000b
101100000b
100100000b
```
We use `where` to find the indices of the pits (the `1b` elements):
```q
q)where each not -9#/:0b vs/:tracks
,0
0 1 2
0 1
0 2
0 1 3
0 2 3
0 3
```
And we add 10 since that's the starting index of the pits:
```q
q)mult:10+where each not -9#/:0b vs/:tracks;
q)mult
,10
10 11 12
10 11
10 12
10 11 13
10 12 13
10 13
```
Now that we have these 3 lists (`ind`, `tracks` and `mult`), we can multiply them together and sum
the results. But due to the shape of `mult`, the result will be in an odd shape:
```q
q)ind*tracks*mult
,1932900
478170 525987 573804
965200 1061720
1453510 1744212
723900 796290 941070
1213170 1455804 1577121
1703720 2214836
```
We can work around this by summing each row first, then again summing the whole list.
```q
q)sum each ind*tracks*mult
1932900 1577961 2026920 3197722 2461260 4246095 3918556
q)sum sum each ind*tracks*mult
19361414
```
(Part 2 is the same with the extended `ind` list.)
