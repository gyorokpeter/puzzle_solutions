# Breakdown
Example input:
```q
x:"\n"vs"0: 3\n1: 2\n4: 4\n6: 4"
```

## Part 1
To parse the input, we split on `":"` and convert to integers. The trim is only there to allow
indenting the input.
```q
q)v:"J"$trim":"vs/:x
q)v
0 3
1 2
4 4
6 4
```
We first find the period of each layer. The scanner spends one tick on the ends of the layer and one
tick each way in the middle points. So the period is 2 times one less than the size of the layer.
```q
q)2*v[;1]-1
4 2 6 6
```
The layers where we get caught are those where the depth modulo the period is zero:
```q
q)v[;0]mod 2*v[;1]-1
0 1 4 0
q)0=v[;0]mod 2*v[;1]-1
1001b
```
We use `where` to extract the relevant indices, take the products of the numbers for those layers,
and sum the results:
```q
q)where 0=v[;0]mod 2*v[;1]-1
0 3
q)v where 0=v[;0]mod 2*v[;1]-1
0 3
6 4
q)prd each v where 0=v[;0]mod 2*v[;1]-1
0 24
q)sum prd each v where 0=v[;0]mod 2*v[;1]-1
24
```

## Part 2
The idea is to keep a list of possible delays and iteratively expand the list based on each
successive constraint imposed by the period and offset of the next scanner. We start with the
scanners with the lowest periods to filter the most offsets possible. We start by generating a table
of periods and offsets sorted by period:
```q
q)`p xasc ([]d:v[;0];p:2*v[;1]-1)
d p
---
1 2
0 4
4 6
6 6
```
We group the offsets by the period. Also we are interested in the _delay_, not the offset which is
the number in the input. The delay is the additive inverse of the offset modulo the period.
```q
q)t:0!select d:(p-d)mod p by p from `p xasc ([]d:v[;0];p:2*v[;1]-1)
q)t
p d
-----
2 ,1
4 ,0
6 2 0
```
We find the valid delays by filtering the possible delay space. Initially, we assume that the
period is 1, and the list of valid delays is `enlist 0`, which means that every delay is valid. We
then take the constraints table row by row and exclude delays that would coincide with one of the
delays in the row. To do this, we have to update the period and extend the delay list to cover the
incoming period. This requires helper functions to calculate the lowest common multiple of two
integers:
```q
gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
lcm:{(x*y)div gcd[x;y]};
```
We use an accumulator-based iterated function to process the rows of the table, using the `/` (over)
iterator. The accumulator is a two-element list, where the first element is the period and the
second element is the list of allowed delays:
```q
    {...}/[(1;enlist 0);t]};
```
One iteration might look like this:
```q
q)x:(1;enlist 0)
q)y:`p`d!(2;enlist 1)
```
We extract the two elements of the accumulator into their own variables:
```q
q)m:x 0
q)al:x 1
q)m
1
q)al
,0
```
We do the same for the incoming constraint:
```q
q)nm:y`p
q)nbad:y`d
q)nm
2
q)nbad
,1
```
We calculate the new period, which is the least common multiple of the accumulator period and the
period from the constraint:
```q
q)mul:lcm[m;nm]
q)mul
2
```
We expand the permitted delays by multiplying them with all the numbers up to the multiplier needed
to reach the new period:
```q
q)m*til mul div m
0 1
q)al+/:m*til mul div m
0
1
q)raze al+/:m*til mul div m
0 1
```
We similarly generate the "bad" delays by multiplying the delays from the constraint by all the
numbers up to the multiplier needed to reach the new period:
```q
q)nm*til mul div nm
,0
q)nbad+/:nm*til mul div nm
1
q)raze nbad+/:nm*til mul div nm
,1
```
We generate the new list of permitted delays by removing the bad delays after the expansions:
```q
q)(raze al+/:m*til mul div m) except raze nbad+/:nm*til mul div nm
,0
```
The new value of the accumulator is this value paired with the new period:
```q
q)(mul;(raze al+/:m*til mul div m) except raze nbad+/:nm*til mul div nm)
2
,0
```
The code of the iterated function ends here. This is how the iteration plays out for the rest of the
example:
```q
q)x:(mul;(raze al+/:m*til mul div m) except raze nbad+/:nm*til mul div nm)
q)x
2
,0
q)y:t 1 //next iteration
q)y
p| 4
d| ,0
q)m:x 0;al:x 1;nm:y`p;nbad:y`d;mul:lcm[m;nm]
q)(m;al;nm;nbad;mul)
2
,0
4
,0
4
q)raze al+/:m*til mul div m
0 2
q)raze nbad+/:nm*til mul div nm
,0
q)x:(mul;(raze al+/:m*til mul div m) except raze nbad+/:nm*til mul div nm)
q)x
4
,2
q)y:t 2 //next iteration
q)y
p| 6
d| 2 0
q)m:x 0;al:x 1;nm:y`p;nbad:y`d;mul:lcm[m;nm]
q)(m;al;nm;nbad;mul)
4
,2
6
2 0
12
q)raze al+/:m*til mul div m
2 6 10
q)raze nbad+/:nm*til mul div nm
2 0 8 6
q)x:(mul;(raze al+/:m*til mul div m) except raze nbad+/:nm*til mul div nm)
q)x //final result
12
,10
```
At the end of the iteration, we have the final list of allowed delays in the second element:
```q
q)last x
,10
```
The answer is the minimum of this list:
```q
q)min last x
10
```
