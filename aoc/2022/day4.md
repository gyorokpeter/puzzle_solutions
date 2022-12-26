# Breakdown
Example input:
```q
x:"\n"vs"2-4,6-8\n2-3,4-5\n5-7,7-9\n2-8,3-7\n6-6,4-6\n2-6,4-8";
```

## Common
We cut the lines on commas:
```q
q)","vs/:x
"2-4" "6-8"
"2-3" "4-5"
"5-7" "7-9"
"2-8" "3-7"
"6-6" "4-6"
"2-6" "4-8"
```
We also cut on dashes inside the previous cuts - as we are now one level deeper, this requires two usages of each-right.
```q
q)"-"vs/:/:","vs/:x
,"2" ,"4" ,"6" ,"8"
,"2" ,"3" ,"4" ,"5"
,"5" ,"7" ,"7" ,"9"
,"2" ,"8" ,"3" ,"7"
,"6" ,"6" ,"4" ,"6"
,"2" ,"6" ,"4" ,"8"
```
We convert the numbers to integers:
```q
q)"J"$"-"vs/:/:","vs/:x
2 4 6 8
2 3 4 5
5 7 7 9
2 8 3 7
6 6 4 6
2 6 4 8
```
Note that these are all 2x2 matrices although it's not evident from the format.

To make the next calculations easier, we put each section in ascending order, so the leftmost elf will always come first.
```q
q)a:asc each "J"$"-"vs/:/:","vs/:x
q)a
2 4 6 8
2 3 4 5
5 7 7 9
2 8 3 7
4 6 6 6
2 6 4 8
```

## Part 1
Now that the leftmost elf always comes first, the condition for when there is full containment is rather easy to express: it's when the end of the second elf's section is less than or equal to the end of the first elf's section. We just need to write this as list indices: the first index is the pair (which we elide), the second is the elf within the pair and the third is start vs end.
```q
q)a[;1;1]<=a[;0;1]
000110b
```
However there is another edge case - if the two elves' start positions are the same, the first elf's section end may come first but that's still a full overlap:
```q
q)a[;0;0]=a[;1;0]
000000b
```
The full condition is the logical `or` of these two. Then we can simply sum the booleans to get the answer.
```q
q)sum(a[;1;1]<=a[;0;1]) or a[;0;0]=a[;1;0]
2i
```

## Part 2
The condition for _any_ overlap is the start of the second elf's secion being less than or equal to the end of the first elf's section.
```q
q)a[;1;0]<=a[;0;1]
001111b
q)sum a[;1;0]<=a[;0;1]
4i
```
