# Breakdown
Example input:
```q
x:"\n"vs"0 <-> 2\n1 <-> 1\n2 <-> 0, 3, 4\n3 <-> 2, 4\n4 <-> 2, 3, 6\n5 <-> 6\n6 <-> 4, 5"
```

## Common
The input is parsed into a dictionary with the left side of the `"<->"` as the key and the right
side as the value. The latter requires removing the commas between the numbers.

The trim is there to allow indenting the input.
```q
q)" <-> "vs/:trim x
,"0" ,"2"
,"1" ,"1"
,"2" "0, 3, 4"
,"3" "2, 4"
,"4" "2, 3, 6"
,"5" ,"6"
,"6" "4, 5"
q){("J"$x[;0])}" <-> "vs/:trim x
0 1 2 3 4 5 6
q){"J"$", "vs/:x[;1]}" <-> "vs/:trim x
,2
,1
0 3 4
2 4
2 3 6
,6
4 5
q)m:{("J"$x[;0])!"J"$", "vs/:x[;1]}" <-> "vs/:trim x
q)m
0| ,2
1| ,1
2| 0 3 4
3| 2 4
4| 2 3 6
5| ,6
6| 4 5
```

## Part 1
We find the groups using the [transitive closure](../utils/patterns.md#transitive-closure) pattern:
```q
q){{asc distinct raze x} each x,'x x}/[m]
0| `s#0 2 3 4 5 6
1| `s#,1
2| `s#0 2 3 4 5 6
3| `s#0 2 3 4 5 6
4| `s#0 2 3 4 5 6
5| `s#0 2 3 4 5 6
6| `s#0 2 3 4 5 6
```
The answer is the length of the list at index 0:
```q
q)({{asc distinct raze x} each x,'x x}/[m])0
`s#0 2 3 4 5 6
q)count({{asc distinct raze x} each x,'x x}/[m])0
6
```

## Part 2
The answer is the number of distinct lists in the transitive map. The fact that the individual lists
are sorted makes it easy to just use `distinct` to find the distinct lists.
```q
q)distinct value{{asc distinct raze x} each x,'x x}/[m]
`s#0 2 3 4 5 6
`s#,1
q)count distinct value{{asc distinct raze x} each x,'x x}/[m]
2
```
