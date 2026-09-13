# Breakdown
Example input:
```q
x:enlist"0\t2\t7\t0"
```
Note that the real input has tabs between the numbers. This rendering of the example input mimics
that formatting.

## Common
We start by splitting the input on tabs, and converting to integers:
```q
q)a:"J"$"\t"vs first x
q)a
0 2 7 0
```
We cache the count of the list:
```q
q)c:count a
q)c
4
```
We initialize the list of seen states with the initial state:
```q
q)l:enlist a
q)l
0 2 7 0
```
We perform an iteration with no exit condition. There is an early return in the middle.
```q
    while[1b;
        ...
    ];
```
In the iteration, we find the index of the tallest stack:
```q
q)p:first where a=max a
q)p
2
```
We cache the height of the stack at this position:
```q
q)n:a p
q)n
7
```
We clear the stack at the found position:
```q
q)a[p]:0
q)a
0 2 0 0
```
Instead of simulating the placement of each block one by one, we shortcut by first distributing as
many full layers as possible, the number of which is obtained via integer division by the number of
stacks:
```q
q)n div c
1
q)a+:n div c
q)a
1 3 1 1
```
We distribute the remaining blocks. The number of blocks is obtained via the modulo operation:
```q
q)n mod c
3
```
We generate the indices of the stacks that need to be increased by taking the appropriate number of
integers and adding them to the current position plus one. This also needs to wrap around, so we do
another modulo on top.
```q
q)p+1+til n mod c
3 4 5
q)(p+1+til n mod c)mod c
3 0 1
```
We increment the stacks at these indices by one:
```q
q)a[(p+1+til n mod c)mod c]+:1
q)a
2 4 1 2
```
We check if the resulting state is already on the seen state list. If it is, we return the list and
the state.
```q
    if[a in l;:(l;a)];
``` 
Otherwise, we append the new state to the list:
```q
q)l,:enlist a
q)l
0 2 7 0
2 4 1 2
```
The code of the iteration ends here. We call this helper function `d6`.

## Part 1
We call the helper function:
```q
q)d6 x
(0 2 7 0;2 4 1 2;3 1 2 3;0 2 3 4;1 3 4 1)
2 4 1 2
```
The answer is the length of the state list:
```q
q)count first d6 x
5
```

## Part 2
We call the helper function:
```q
q)la:d6 x
q)la
(0 2 7 0;2 4 1 2;3 1 2 3;0 2 3 4;1 3 4 1)
2 4 1 2
```
We locate the final state in the state list:
```q
q)la[0]?la 1
1
```
The answer is the length of the state list minus the found position:
```q
q)count[la 0]-la[0]?la 1
4
```
