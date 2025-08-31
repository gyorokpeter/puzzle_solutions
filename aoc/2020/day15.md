# Breakdown

Example input:
```q
x:"0,3,6"
n:2020
```
Note that for this puzzle, the input is a string rather than a list of strings (no input file).

## Common
We use an array to keep track of which number was said on which turn. We start with an array big
enough for the highest number and whenever we want to say a number that doesn't fit into the array
we simply add as many elements as that number. Doubling the size is sometimes not enough.

This puzzle is a killer because of the sequential array operations which are simply not possible
to express in any way that makes it faster.

We split and parse the input as integers:
```q
q)ns:"J"$","vs x
q)ns
0 3 6
```
We intialize the array with enough nulls such that it can be indexed with the highest number seen so
far:
```q
q)arr:(1+max[ns])#0N
q)arr
0N 0N 0N 0N 0N 0N 0N
```
Note that the array has 7 elements, so it can indexed with numbers from 0 to 6.

We initialize the array for the starting numbers except the last one with the turn numbers they are
first spoken:
```q
q)arr[-1_ns]:1+til count[ns]-1
q)arr
1 0N 0N 2 0N 0N 0N
```
So `arr[0]=1` and `arr[3]=2`.

We find the number of iterations, which is the turn number of the last number minus the number of
starting numbers:
```q
q)c:n-count ns
q)c
2017
```
We initialize the current number with the last starting number:
```q
q)num:last ns
q)num
6
```
We initialize the step number with the number of starting numbers:
```q
q)step:count[ns]
q)step
3
```
Next is a brute-force iteration for the given number of turns:
```q
    do[c; ...]
```
During the iteration, we find the next number by looking up the last turn the current number was
said, and subtract this from the current step number. If the number was not said before, the list
will have a null at that position, so we fill it with `0`.
```q
q)nxt:0^step-arr[num]
q)nxt
0
```
We check if the array is big enough to hold the next number as an index. If not, we append enough
nulls:
```q
q)if[count[arr]<=num;arr,:num#0N]
```
We update the current turn for the current number:
```q
q)arr[num]:step
q)arr
1 0N 0N 2 0N 0N 3
```
We set the current number to the next:
```q
q)num:nxt
q)num
0
```
We increment the step counter:
```q
q)step+:1
q)step
4
```
This ends the body of the iteration.

At the end of the iteration, `num` contains the current number on the requested turn.
```q
q)num
436
```

## Part 1
The above code runs with `n=2020`.

## Part 2
The above code runs with `n=30000000`. There is no optimization. It takes about 22 seconds on my
machine as of writing this.
