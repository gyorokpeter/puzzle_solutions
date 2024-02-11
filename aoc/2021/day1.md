# Breakdown
Example input:
```q
x:"199\n200\n208\n210\n200\n207\n240\n269\n260\n263"
```

## Common
The input parsing is pretty standard. First we break the input to lines using `"\n"vs`:
```q
q)"\n"vs x
"199"
"200"
"208"
"210"
...
```
and then use `"J"$` to convert them to integers.
```q
q)a:"J"$"\n"vs x
q)a
199 200 208 210 200 207 240 269 260 263
```
This will be similar for many of the other days.

## Part 1
The built-in [`deltas`](https://code.kx.com/q/ref/deltas/) function generates the difference between consecutive elements:
```q
q)deltas a
199 1 8 2 -10 7 33 29 -9 3
```
But it also keeps the first element which is unnecessary, so we drop it with `1_`:
```q
q)1_deltas a
1 8 2 -10 7 33 29 -9 3
```
Then we check which elements are positive using `0<`:
```q
q)0<1_deltas a
111011101b
```
The answer is the sum of the booleans:
```q
q)sum 0<1_deltas a
7i
```

## Part 2
q has a handy [`msum`](https://code.kx.com/q/ref/sum/#msum) (moving sum) function for this exact use case:
```q
q)3 msum a
199 399 607 618 618 617 647 716 769 792
```
The `3` is the length of the window, but notice that once again there are some garbage items that we need to drop:
```q
q)2_3 msum a
607 618 618 617 647 716 769 792
```
The rest is similar to part 1:
```q
q)sum 0<1_deltas 2_3 msum a
5i
```
