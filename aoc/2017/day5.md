# Breakdown
Example input:
```q
x:string 0 3 0 1 -3
```

## Part 1
We convert the input into integers:
```q
q)s:"J"$x
q)s
0 3 0 1 -3
```
We initialize a variable for the current position and one for the step count:
```q
q)p:0
q)c:0
```
We do an iteration while the pointer is within the bounds of the input:
```q
    while[p within (0;count[s]-1);
        ...
    ];
```
In the iteration, we calculate the new position:
```q
    np:p+s p
```
We increment the input at the current position:
```q
    s[p]+:1
```
We update the current position to the next one:
```q
    p:np
```
We increment the step counter:
```q
    c+:1
```
The code of the iteration ends here.

After the iteration, the answer is in the `c` variable.

## Part 2
Same as part 1, except at the following step:
```q
    s[p]+:1
```
Instead of always adding 1, we add 1 or -1 depending on whether the value at that position is at
least 3:
```q
    s[p]+:$[s[p]>=3;-1;1]
```
