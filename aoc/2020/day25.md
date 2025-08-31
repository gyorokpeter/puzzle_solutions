# Breakdown
Example input:
```q
x:("5764801";"17807724")
```

We convert the input to integers:
```q
q)pk:"J"$x
q)pk
5764801 17807724
```
We initialize two values, one for the key and one for the counter:
```q
q)b:7;c:1
```
We iterate the operation described in the puzzle until the key matches:
```q
q)while[b<>pk 0; c+:1; b:(b*7) mod 20201227]
q)b
5764801
q)c
8
```
We initialize another set of variables with the second key:
```q
q)d:e:pk 1
```
We repeat the transformation `c-1` times on the new key:
```q
q)do[c-1;e:(e*d) mod 20201227]
q)e
14897079
```
Notice that it is not even necessary to find the other loop size.
