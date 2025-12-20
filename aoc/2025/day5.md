# Breakdown
Example input:
```q
x:"\n"vs"3-5\n10-14\n16-20\n12-18\n\n1\n5\n8\n11\n17\n32"
```

## Part 1
The first step is to separate the two sections of the input. Since the input comes in the form of
lines, we first join them up, then split on a double newline, then split on newlines inside the two
sections.
```q
q)a:"\n"vs/:"\n\n"vs"\n"sv x
q)a
("3-5";"10-14";"16-20";"12-18")
(,"1";,"5";,"8";"11";"17";"32")
```
For the first section, we split on dashes and convert to integers:
```q
q)"J"$"-"vs/:a[0]
3  5
10 14
16 20
12 18
```
For the second section, we convert to integers directly:
```q
q)"J"$a[1]
1 5 8 11 17 32
```
The function `within` checks if a number is in a (closed) interval. It takes a two-element list on
the right, but it can process any number of elements on the left. Since we have a list of intervals
to check, we have to extend the function using `/:` (each right).
```q
q)("J"$a[1])within/:"J"$"-"vs/:a[0]
010000b
000100b
000010b
000010b
```
The ingredients are fine if there is at least one `1b` value in their corresponding column. Since
aggregating operators collapse vertically when invoked on a matrix, using `any` directly will
return exactly what we want:
```q
q)any("J"$a[1])within/:"J"$"-"vs/:a[0]
010110b
```
The answer is the sum of these booleans:
```q
q)sum any("J"$a[1])within/:"J"$"-"vs/:a[0]
3i
```

## Part 2
Enumerating each number in each interval would be too expensive (at leat for the real input).
Instead we can try to merge the intervals and use the merged bounds to figure out how many numbers
they cover.

We split the input into sections like in part 1, but this time we only take the first section, also
splitting it and converting into integers:
```q
q)"J"$"-"vs/:first"\n"vs/:"\n\n"vs"\n"sv x
3  5
10 14
16 20
12 18
```
Before merging, we sort the list in ascending order. This results in a lexicographic sort, so the
inervals will be sorted by their lower bounds.
```q
q)asc"J"$"-"vs/:first"\n"vs/:"\n\n"vs"\n"sv x
3  5
10 14
12 18
16 20
```
We also add 1 to the second element of each interval to "open" it (which is typically the form used
to measure their size).
```q
q)r:0 1+/:asc"J"$"-"vs/:first"\n"vs/:"\n\n"vs"\n"sv x
q)r
3  6
10 15
12 19
16 21
```
To merge the intervals, first we calculate the running maximum of their upper bounds:
```q
q)maxs r[;1]
6 15 19 21
```
There is a break in the intervals if the start of the interval is higher than the running maximum
at the previous position:
```q
q)r[;0]>prev maxs r[;1]
1100b
```
We split the list of intervals into groups based on which are separate:
```q
q)b:where[r[;0]>prev maxs r[;1]]cut r
q)b
,3 6
(10 15;12 19;16 21)
```
Note that `cut` will remove the first section of the list unless 0 is among the cutting points. In
this case it is, because `prev` shifts in a null, which is considered to be less than any valid
number.

We take the minimum lower and maximum upper bound for each group:
```q
q)(min each b[;;0]),'(max each b[;;1])
3  6
10 21
```
We get the answer by applying the subtraction operator pairwise on the elements of the list, then
summing the results:
```q
q)neg(-)./:(min each b[;;0]),'(max each b[;;1])
3 11
q)sum neg(-)./:(min each b[;;0]),'(max each b[;;1])
14
```
