# Breakdown
Example input:
```q
x:"\n"vs"1\n2\n-3\n3\n-2\n0\n4";
```

## Common
We represent the list using a table of (position;value). This allows iterating over the numbers in the original order while also keeping track of their current positions.

One move is taken care of by the `.d20.move` function which takes a state (`b`) and the index (`i`) of the number to move.

We start by caching a few variables: the count of the list; the full row corresponding to the number (i.e. both the position and value); the old position:
```q
c:count b;
n:b[i];
op:n`p;
```
We calculate the new position by adding the value:
```q
np:op+n[`v];
```
If we wrap around, we need to map the new position back to the original list. Since the list is circular, the position 0 and `c-1` are the same, so one needs to be mapped to the other. The example seems to avoid using position 0 as a destination this way, so we do the same:
```q
if[not np within 1,c-1;
    np:((np-1) mod c-1)+1];
```
Then we need to adjust the positions of the intervening numbers. Depending on whether the new position is later or earlier, we either need to add or subtract 1 from the intervening numbers:
```q
$[op<=np;
    b:update p-1 from b where p within (op+1;np);
    b:update p+1 from b where p within (np;op-1)];
```
Finally we update the position of the moved number and return the modified state.
```q
b[i;`p]:np;
b
```

A full round repeats this operation for each index:
```q
.d20.mix:{[b].d20.move/[b;til count b]};
```

We start by converting the numbers to integers:
```q
a:"J"$x;
```
We cache the count of the list and create the initial state, multiplying the numbers by the constant for part 2:
```q
c:count a;
b:([]p:til c;v:a*$[part=2;811589153;1]);
```
We then perform the mixing operation a number of times depending on the part:
```q
b:.d20.mix/[$[part=2;10;1];b];
```
We find the position of 0 in the result:
```q
p0:exec first p from b where v=0;
```
Finally we find the numbers which are in the positions `(p0+1000 2000 3000) mod c` and sum them:
```q
exec sum v from b where p in (p0+1000 2000 3000) mod c
```
