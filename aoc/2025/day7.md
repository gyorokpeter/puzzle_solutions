# Breakdown
Example input:
```q
x:()
x,:enlist".......S......."
x,:enlist"..............."
x,:enlist".......^......."
x,:enlist"..............."
x,:enlist"......^.^......"
x,:enlist"..............."
x,:enlist".....^.^.^....."
x,:enlist"..............."
x,:enlist"....^.^...^...."
x,:enlist"..............."
x,:enlist"...^.^...^.^..."
x,:enlist"..............."
x,:enlist"..^...^.....^.."
x,:enlist"..............."
x,:enlist".^.^.^.^.^...^."
x,:enlist"..............."
```

## Part 1
We convert the input into positions by looking for `S` or `^` characters. We ignore lines that have
none of them as they are not relevant to the solution.
```q
q)x in"S^"
000000010000000b
000000000000000b
000000010000000b
000000000000000b
000000101000000b
000000000000000b
000001010100000b
000000000000000b
000010100010000b
000000000000000b
000101000101000b
000000000000000b
001000100000100b
000000000000000b
010101010100010b
000000000000000b
q)where each x in"S^"
,7
`long$()
,7
`long$()
6 8
`long$()
5 7 9
`long$()
4 6 10
`long$()
3 5 9 11
`long$()
2 6 12
`long$()
1 3 5 7 9 13
`long$()
q)a:(where each x in"S^")except enlist`long$()
q)a
,7
,7
6 8
5 7 9
4 6 10
3 5 9 11
2 6 12
1 3 5 7 9 13
```
We use an iterated function to generate the beam positions. The function takes three parameters: `n`
(the number of splits), `b1` (the active beam positions) and `b2` (the positions of splitters on the
next line). `n` and `b1` are bundled together into a list for more easily passing them across the
iterations. The starting value for `n` is 0 and the starting value for `b1` is `a 0` (this is why
it was useful to match both `S` and `^` in the first step). The list we are iterating on is `1_a`.
```q
    a2:{[(n;b1);b2]
        ...
    }/[(0;a 0);1_a];

q)n:0
q)b1:a 0
q)b1
,7
q)b2:a 1
q)b2
,7
```
In the iteration, we first find which beams will split by taking the intersection between the
current beam positions and the splitters:
```q
q)s:b1 inter b2
q)s
,7
```
To generate the next state of the accumulator, we add the number of splits to `n`, remove the split
positions from `b1` using `except`, and append the positions obtained by adding both 1 and -1 to the
split positions. We need to `distinct` the result as there might be duplicates.
```q
q)(n+count s;distinct(b1 except s),raze s+/:1 -1)
1
8 6
```
At the end of the iteration, we end up with the beam state after the last row:
```q
q)a2
21
8 10 4 11 14 6 2 12 0
```
The first element of the list is the answer:
```q
q)first a2
21
```

## Part 2
We generate the list `a` as before. We perform another iteration. This time the accumulator is a
dictionary, such that we can store the multiplicity of each beam. The initial value of the
accumulator is the starting beam position mapped to the number 1, and the list to iterate over is
again `1_a`. (This way of constructing the initial value would allow for more than one beam on the
first line.)
```q
    a2:{ ... }/[a[0]!count[a 0]#1;1_a]}

q)x:a[0]!count[a 0]#1
q)x
7| 1
q)y:a 1
```
In the iteration, we first find which beams will split by taking the intersection between the
current beam positions (the keys of the accumulator) and the splitters:
```q
q)s:key[x]inter y
q)s
,7
```
To generate the next state of the accumulator, we drop the keys corresponding to the split beams
from the dictionary, then add beams with both 1 and -1 added to the positions of the split beams,
each taking a copy of the multiplicities of its parent beam. We can conveniently express this by
creating a list with three elements, the first one being the dictionary with the splits removed, and
the second and third being the new beams with a +1 and -1 offset respectively. Adding the three
dictionaries together will correctly handle the deduplication and the addition of the
multiplicities.
```q
q)(s _x;(s+1)!x s;(s-1)!x s)
(`long$())!`long$()
(,8)!,1
(,6)!,1
q)sum(s _x;(s+1)!x s;(s-1)!x s)
8| 1
6| 1
```
At the end of the iteration, we end up with the beam positions and multiplicities after the last
row:
```q
q)a2
8 | 11
10| 2
4 | 10
11| 1
14| 1
6 | 11
2 | 2
12| 1
0 | 1
```
The answer is the sum of the multiplicities, which we can get by directly calling `sum` on the
dictionary (aggregation functions ignore the domain of the input, in this case the dictionary keys):
```q
q)sum a2
40
```
