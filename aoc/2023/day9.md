# Breakdown

Example input:
```q
x:"\n"vs"0 3 6 9 12 15\n1 3 6 10 15 21\n10 13 16 21 30 45";
```

## Part 1
We split the input into integers:
```q
q)"J"$" "vs/:x
0  3  6  9  12 15
1  3  6  10 15 21
10 13 16 21 30 45
```
We process each line individually. For example with the first line:
```q
q)x:0 3 6 9 12 15
```
We iterate `deltas`, removing the first element from the result, while any element is non-zero:
```q
q){1_deltas x}\[any;x]
0 3 6 9 12 15
3 3 3 3 3
0 0 0 0
```
The extrapolation is equivalent to summing the last number of each of the sequences:
```q
q)sum last each{1_deltas x}\[any;x]
18
```
Returning to the original example:
```q
q)x:"\n"vs"0 3 6 9 12 15\n1 3 6 10 15 21\n10 13 16 21 30 45"
q){sum last each{1_deltas x}\[any;x]}each"J"$" "vs/:x
18 28 68
q)sum{sum last each{1_deltas x}\[any;x]}each"J"$" "vs/:x
114
```

## Part 2
Similar to part 1, except instead of summing the last numbers, we walk through the first elements backwards and subtract the "total" from the next element:
```q
q)x:0 3 6 9 12 15
q)first each reverse{1_deltas x}\[any;x]
0 3 0
q){y-x}\[first each reverse{1_deltas x}\[any;x]]
0 3 -3
q){y-x}/[first each reverse{1_deltas x}\[any;x]]
-3
```
Applying this to the entire input:
```q
q)x:"\n"vs"0 3 6 9 12 15\n1 3 6 10 15 21\n10 13 16 21 30 45"
q){{y-x}/[first each reverse{1_deltas x}\[any;x]]}each"J"$" "vs/:x
-3 0 5
q)sum{{y-x}/[first each reverse{1_deltas x}\[any;x]]}each"J"$" "vs/:x
2
```
