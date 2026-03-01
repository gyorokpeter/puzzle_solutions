# Breakdown
Example input:
```q
x:"\n"vs"#1 @ 1,3: 4x4\n#2 @ 3,1: 4x4\n#3 @ 5,5: 2x2"
```

## Common
Due to the rather complex input structure, we use a helper function (`d3parse`) to convert the input
into a list of integers that can be processed further.

We use [`vs`](https://code.kx.com/q/ref/vs/) to cut the input on the separator `"@ "`:
```q
q)"@ "vs/:x
"#1 " "1,3: 4x4"
"#2 " "3,1: 4x4"
"#3 " "5,5: 2x2"
```
We don't care about the first part of the line as the IDs can be regenerated from the element index.
So we take only the last elements:
```q
q)last each"@ "vs/:x
"1,3: 4x4"
"3,1: 4x4"
"5,5: 2x2"
```
We cut again, this time on `": "`:
```q
q)": "vs/:last each"@ "vs/:x
"1,3" "4x4"
"3,1" "4x4"
"5,5" "2x2"
```
Now we have two strings per line with different separators. We should cut the first element on `","`
and the second element on `"x"`. For a single row, we could use the [`'` (each)](https://code.kx.com/q/ref/maps/#each)
iterator to pairwise apply `vs` between the elements of the list `",x"` and the strings in the row:
```q
q)",x"vs'("1,3";"4x4")
,"1" ,"3"
,"4" ,"4"
```
Extending this to each row requires using the `/:` (each-right) iterator. When stacking iterators
this way, the order is significant.
```q
q)",x"vs'/:": "vs/:last each"@ "vs/:x
,"1" ,"3" ,"4" ,"4"
,"3" ,"1" ,"4" ,"4"
,"5" ,"5" ,"2" ,"2"
```
Finally, we cast into integers, which is the return value of the function.
```q
q)"J"$",x"vs'/:": "vs/:last each"@ "vs/:x
1 3 4 4
3 1 4 4
5 5 2 2
```

## Part 1
We store the parsed input in a variable:
```q
q)a:d3parse x
q)a
1 3 4 4
3 1 4 4
5 5 2 2
```
We find each individual coordinate that is covered by the rectangles. So first we generate the list
of values for each coordinate in turn:
```q
q){til x[1;0]}each a
0 1 2 3
0 1 2 3
0 1
q){til x[1;1]}each a
0 1 2 3
0 1 2 3
0 1
```
We take their Cartesian product using `cross`:
```q
q){til[x[1;0]]cross til x[1;1]}each a
(0 0;0 1;0 2;0 3;1 0;1 1;1 2;1 3;2 0;2 1;2 2;2 3;3 0;3 1;3 2;3 3)
(0 0;0 1;0 2;0 3;1 0;1 1;1 2;1 3;2 0;2 1;2 2;2 3;3 0;3 1;3 2;3 3)
(0 0;0 1;1 0;1 1)
```
These only represent offsets from the top left of the rectangle, so we add them to the top left
coordinate in turn (using `/:` (each right):
```q
q){x[0]+/:til[x[1;0]]cross til x[1;1]}each a
(1 3;1 4;1 5;1 6;2 3;2 4;2 5;2 6;3 3;3 4;3 5;3 6;4 3;4 4;4 5;4 6)
(3 1;3 2;3 3;3 4;4 1;4 2;4 3;4 4;5 1;5 2;5 3;5 4;6 1;6 2;6 3;6 4)
(5 5;5 6;6 5;6 6)
```
We raze this list to get all the covered coordinates:
```q
q)b:raze{x[0]+/:til[x[1;0]]cross til x[1;1]}each a
q)b
1 3
1 4
1 5
1 6
2 3
2 4
..
```
Finally we use the familiar technique of using `group` to count frequencies of items:
```q
q)group b
1 3| ,0
1 4| ,1
1 5| ,2
1 6| ,3
2 3| ,4
2 4| ,5
2 5| ,6
2 6| ,7
3 3| 8 18
3 4| 9 19
3 5| ,10
3 6| ,11
4 3| 12 22
4 4| 13 23
4 5| ,14
4 6| ,15
3 1| ,16
3 2| ,17
4 1| ,20
4 2| ,21
5 1| ,24
5 2| ,25
..
q)count each group b
1 3| 1
1 4| 1
1 5| 1
1 6| 1
2 3| 1
2 4| 1
2 5| 1
2 6| 1
3 3| 2
3 4| 2
3 5| 1
3 6| 1
4 3| 2
4 4| 2
4 5| 1
4 6| 1
3 1| 1
3 2| 1
4 1| 1
4 2| 1
5 1| 1
5 2| 1
..
q)1<count each group b
1 3| 0
1 4| 0
1 5| 0
1 6| 0
2 3| 0
2 4| 0
2 5| 0
2 6| 0
3 3| 1
3 4| 1
3 5| 0
3 6| 0
4 3| 1
4 4| 1
4 5| 0
4 6| 0
3 1| 0
3 2| 0
4 1| 0
4 2| 0
5 1| 0
5 2| 0
..
q)sum 1<count each group b
4i
```

## Part 2
We store the parsed input again in the variable `a`. We also generate the coordinate lists, but this
time we don't raze them:
```q
q)b:{x[0]+/:til[x[1][0]]cross til x[1][1]}each a
q)b
(1 3;1 4;1 5;1 6;2 3;2 4;2 5;2 6;3 3;3 4;3 5;3 6;4 3;4 4;4 5;4 6)
(3 1;3 2;3 3;3 4;4 1;4 2;4 3;4 4;5 1;5 2;5 3;5 4;6 1;6 2;6 3;6 4)
(5 5;5 6;6 5;6 6)
```
We find which coordinates only appear once, which is a bit similar to part 1. We raze the list to
get this value, but note that `b` continues to hold the unrazed list.
```q
q)c:where 1=count each group raze b
q)c
1 3
1 4
1 5
1 6
2 3
2 4
..
```
Now we find which of the rectangles are made up entirely of these singleton coordinates. Simply
using `in` between `b` and `c` performs a convenient membership check:
```q
q)b in c
1111111100110011b
1100110011111111b
1111b
```
The correct claim is the one with only `1b` values. `all` performs this check, but as we saw before,
merely using it would try to collapse the matrix vertically, which is not meaningful here. Instead
we use it with `each` so it collapses the rows instead.
```q
q)all each b in c
001b
```
We use `where` to find the index of the `1b` element:
```q
q)where all each b in c
,2
```
Since the index is 0-based, we have to add 1 to get the actual ID. The result is also a list, but
a well-formed input will only have one element, so we can just take the first element of the list.
```q
q)first 1+where all each b in c
3
```
