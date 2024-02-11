# Breakdown
Example input:
```q
x:"00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010"
```

## Part 1
We split the lines and then convert every character into a boolean. The latter requires two `/:`
iterators because not only are we going into the list, we are also going into every element in it.
```q
q)a:"\n"vs x
q)"B"$/:/:a
00100b
11110b
10110b
...
```
By summing this list, we can add up the bits in each position:
```q
q)sum["B"$/:/:a]
7 5 8 7 5i
```
Then we compare this to half the length of the list to get which bit is more common:
```q
q)b:sum["B"$/:/:a]>count[a]%2
q)b
10110b
```
The epsilon value is just the `not` of this value.
Then we need to convert the binary values to decimal. The `sv` function has an [overload](https://code.kx.com/q/ref/sv/#base-to-integer) for this
where it takes an integer on the left and a list on the right, and it does the base conversion.
Since we are invoking this on a two-element list, we need to use the `/:` iterator.
```q
q)2 sv/:(b;not b)
22 9
```
The answer is the product of these two numbers.
```q
q)prd 2 sv/:(b;not b)
198
```

## Part 2
This requires an iterative solution. Each step of the iteration will filter on a particular bit.
So if we have a list of binary numbers x, an we are checkin bit position y:
```q
q)x:(00100b;11110b;10110b;10111b;10101b;01111b;00111b;11100b;10000b;11001b;00010b;01010b)
q)y:0
```
First we extract the column to check:
```q
q)b:x[;y]
q)b
011110011100b
```
Then we determine whether we are looking fot 0 or 1 bits (remember that `%` is float division):
```q
q)sum[b]>=count[b]%2
1b
```
And compare the list to this bit:
```q
q)b=sum[b]>=count[b]%2
011110011100b
```
Finally we use [`where`](https://code.kx.com/q/ref/where/) to turn this into a list of indices and then index into the original list
to filter it:
```q
q)x where b=sum[b]>=count[b]%2
11110b
10110b
10111b
10101b
11100b
10000b
11001b
```
The iteration also needs an initial condition that if the list only contains one element, that
should be returned unchanged:
```q
    if[1=count x;:x];
    b:x[;y];x where b=sum[b]>=count[b]%2]
```
Due to the tie breaker rule being different for the two ratings, we also pass in the operator used
to check which bit we are filtering on: `>=` for the CO2 rating and `<` for the oxygen rating. This
means the iterated function will be a three-parameter lambda.
```q
    {[op;x;y]if[1=count x;:x];
        b:x[;y];x where b=op[sum[b];count[b]%2]}
```
Then the function is iterated using the `/` iterator, in particular the overload that takes an
initial value and a list, and applies the function between the current state and the elements of
the list in turn. We pass in the whole list as the initial value and the element index as the list.
```q
    {[op;x;y]if[1=count x;:x];
        b:x[;y];x where b=op[sum[b];count[b]%2]}[x]/[y;til count first y]
```
All of this gets wrapped in another lambda just to avoid repetition:
```q
    f:{{[op;x;y]if[1=count x;:x];
        b:x[;y];x where b=op[sum[b];count[b]%2]}[x]/[y;til count first y]};
```
For `f`, the first parameter (`x`) is the operator and the second paramter (`y`) is the list.
Now that we have this function, we call it with the two operators and concatenate the two results
into a list:
```q
    f[>=;a],f[<;a]
```
and the extraction of the answer is similar to part 1.
```q
    prd 2 sv/:f[>=;a],f[<;a]
```
