# Breakdown
Example input:
```q
x:"\n"vs"+1\n-2\n+3\n+1"
```

## Part 1
The answer is just the sum of the numbers. So we convert the lines into strings using the [lexical
cast](https://code.kx.com/q/ref/tok/) operator with `"J"` (long) as the target type and sum them:
```q
q)"J"$x
1 -2 3 1
q)sum"J"$x
3
```

## Part 2
The solution in other languages might be to create a set or hash data structure and check for
membership before each insertion to see if the element to be inserted is a duplicate. In q there is 
no such data structure, so the solution consists of repeatedly appending the list to itself until
there is a duplicate in the partial sums.

We store the parsed integers in a variable:
```q
q)d:"J"$x
q)d
1 -2 3 1
```
We perform an iteration. The iteration has no explicit termination condition since there is a return
statement in the middle that will break out of it.
```q
    while[1b;
        ...
    ]};
```
In the iteration, we check if there is a repeated value in the cumulative sums. First we use
[`sums`](https://code.kx.com/q/ref/sum/#sums) to generate the partial sums:
```q
q)sums d
1 -1 2 3
```
We group the list, which creates a dictionary that is essentially the inversion of the list, mapping
the distinct items of the list to their indices:
```q
q)group[sums d]
1 | 0
-1| 1
2 | 2
3 | 3
```
There are no duplicates yet, so we will return to this part later.

At the end of the iteration, we append the number list to itself, doubling its size:
```q
q)d,:d
q)d
1 -2 3 1 1 -2 3 1
```
If we generate the sums now, we can see there is a duplicate:
```q
q)sums d
1 -1 2 3 4 2 5 6
```
This means the grouped list will have two indices for the duplicated element:
```q
q)group sums d
1 | ,0
-1| ,1
2 | 2 5
3 | ,3
4 | ,4
5 | ,6
6 | ,7
```
So we check the count of each element, and whether there is any with more than one index:
```q
q)count each group sums d
1 | 1
-1| 1
2 | 2
3 | 1
4 | 1
5 | 1
6 | 1
q)1<count each group sums d
1 | 0
-1| 0
2 | 1
3 | 0
4 | 0
5 | 0
6 | 0
```
We use [`where`](https://code.kx.com/q/ref/where/) to find the keys where the value is true (1).
The dictionary created by `group` is in the order of first occurrence, so if we take the first item
with more than one occurrence, that will be the first repetition in the original ungrouped list.
```q
q)r:where 1<count each group sums d
q)r
,2
q)first r
2
```
This is what the exit condition checks:
```q
    if[0<count r; :first r];
```
