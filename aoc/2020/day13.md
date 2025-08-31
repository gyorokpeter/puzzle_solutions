# Breakdown
Example input:
```q
x:"\n"vs"939\n7,13,x,x,59,x,31,19"
```

## Part 1
We get the start time by parsing the first line as an integer:
```q
q)st:"J"$x 0
q)st
939
```
We get the bus intervals by splitting the second line on `","`, converting to integers, then
throwing out the nulls (which the `x` entries will become).
```q
q)per:("J"$","vs x 1)except 0N
q)per
7 13 59 31 19
```
We find the next occurrence of each period. We can do this by applying the `mod` operator with the
negative of the start time on the left and the periods on the right:
```q
q)nxt:neg[st] mod per
q)nxt
6 10 5 22 11
```
We find the index of the bus to take next by looking for the minimal element:
```q
q)take:first where nxt=min nxt
q)take
2
```
We find the answer by multiplying the next departure by the period:
```q
q)nxt[take]*per[take]
295
```

## Part 2
This requires some advanced math to solve a linear congruence system. Since I'm here for the coding
and not for the math, I won't explain the details, just provide the helper functions.

Calculating the multiplicative index of an integer by a modulus:
```q
mulInv:{[a;b]
    if[b=1; :1];
    b0:b; x0:0; x1:1;
    while[a>1;
        q:a div b;
        t:b; b:a mod b; a:t;
        t:x0; x0:x1-q*x0; x1:t;
    ];
    if[x1<0; x1+:b0];
    x1};
```
Finding the smallest integer that satisfies a linear congruence system:
```q
//eqs:list of (n;a) pairs where x === a (mod n)
lc:{[eqs]
    prod:prd eqs[;0];
    p:prod div eqs[;0];
    sum[eqs[;1]*mulInv'[p;eqs[;0]]*p]mod prod};
```
We find the periods, ignoring the start time:
```q
q)per:"J"$","vs x 1
q)per
7 13 0N 0N 59 0N 31 19
```
We filter to the valid periods:
```q
q)ind:where not null per
q)per2:per ind
q)per2
7 13 59 31 19
```
We generate the coefficients for the linear congruence system and plug them into the above helper
function:
```q
q)per2,'neg[ind]mod per2
7  0
13 12
59 55
31 25
19 12
q)lc[per2,'neg[ind]mod per2]
1068781
```
