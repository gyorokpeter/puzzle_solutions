# Breakdown

## Part 1

Example input:
```q
x:()
x,:enlist"class: 1-3 or 5-7"
x,:enlist"row: 6-11 or 33-44"
x,:enlist"seat: 13-40 or 45-50"
x,:enlist""
x,:enlist"your ticket:"
x,:enlist"7,1,14"
x,:enlist""
x,:enlist"nearby tickets:"
x,:enlist"7,3,47"
x,:enlist"40,4,50"
x,:enlist"55,2,20"
x,:enlist"38,6,12"
```
We parse the input into sections by looking for empty lines:
```q
q)s:"\n\n"vs"\n"sv x
q)s
"class: 1-3 or 5-7\nrow: 6-11 or 33-44\nseat: 13-40 or 45-50"
"your ticket:\n7,1,14"
"nearby tickets:\n7,3,47\n40,4,50\n55,2,20\n38,6,12"
```
We parse the input ranges from the first element. First we cut on `": "` to separate the name:
```q
q)"\n"vs s[0]
"class: 1-3 or 5-7"
"row: 6-11 or 33-44"
"seat: 13-40 or 45-50"
q)last each": "vs/:"\n"vs s[0]
"1-3 or 5-7"
"6-11 or 33-44"
"13-40 or 45-50"
```
We separate the ranges by splitting on `" or "`. In the real input, there are only ever two ranges
for each field, but this code would handle a different number of them as long as there was an
`" or "` separator between them.
```q
q)" or "vs/:last each": "vs/:"\n"vs s[0]
"1-3"   "5-7"
"6-11"  "33-44"
"13-40" "45-50"
```
We raze the list as the individual fields are not relevant for part 1:
```q
q)raze " or "vs/:last each": "vs/:"\n"vs s[0]
"1-3"
"5-7"
"6-11"
"33-44"
"13-40"
"45-50"
```
We split the ranges into their lower and upper bound, then parse them into integers and put them in
ascending order:
```q
q)"-"vs/:raze " or "vs/:last each": "vs/:"\n"vs s[0]
,"1" ,"3"
,"5" ,"7"
,"6" "11"
"33" "44"
"13" "40"
"45" "50"
q)"J"$"-"vs/:raze " or "vs/:last each": "vs/:"\n"vs s[0]
1  3
5  7
6  11
33 44
13 40
45 50
q)rule:asc"J"$"-"vs/:raze " or "vs/:last each": "vs/:"\n"vs s[0]
q)rule
1  3
5  7
6  11
13 40
33 44
45 50
```
We split the nearby tickets on commas and parse them into integers:
```q
q)1_"\n"vs s[2]
"7,3,47"
"40,4,50"
"55,2,20"
"38,6,12"
q)tk:"J"$","vs/:1_"\n"vs s[2]
q)tk
7  3 47
40 4 50
55 2 20
38 6 12
```
We check which of the numbers are within which ranges. This requires a combination of iterators. The
easiest way to figure out which order to put the iterators on is to start with the innermost
operation, which is checking whether a single element of the matrix is within one of the ranges:
```q
q)tk[0][0] within rule 0
0b
```
To eliminate the index on the rules, we use `/:` (each-right):
```q
q)tk[0][0] within/:rule
011000b
```
To eliminate the two indices on the matrix, we use two instances of `\:` (each-left):
```q
q)tk within/:\:\:rule
011000b 100000b 000001b
000110b 000000b 000001b
000000b 100000b 000100b
000110b 011000b 000000b
```
We need to find whether each of the innermost lists contains at least no `1b` value, which is the
negated resut of the `any` function. We have to apply it two levels down, so we use it with
`each/:`:
```q
q)not any each/:tk within/:\:\:rule
000b
010b
100b
001b
```
We find the indices corresponding to the `1b` values using `where`, again with an `each` since we
need to go down one level:
```q
q)where each not any each/:tk within/:\:\:rule
`long$()
,1
,0
,2
```
The expression can be simplified by rearranging the layout of the matrix by swapping the iterators.
Then the `where` and `not any` can be merged into a single lambda:
```q
q)tk within\:/:\:rule
010b 100b 100b 000b 000b 001b
000b 000b 000b 100b 100b 001b
010b 000b 000b 001b 000b 000b
000b 010b 010b 100b 100b 000b
q){not any x}each tk within\:/:\:rule
000b
010b
100b
001b
q){where not any x}each tk within\:/:\:rule
`long$()
,1
,0
,2
```
To find the corresponding values, we pairwise apply the indices to the matrix:
```q
q)tk@'{where not any x}each tk within\:/:\:rule
`long$()
,4
,55
,12
```
To get the answer, we raze and add the numbers together:
```q
q)raze tk@'{where not any x}each tk within\:/:\:rule
4 55 12
q)sum raze tk@'{where not any x}each tk within\:/:\:rule
71
```

## Part 2

Example input:
```q
2:();
2,:enlist"class: 0-1 or 4-19"
2,:enlist"row: 0-5 or 8-19"
2,:enlist"seat: 0-13 or 16-19"
2,:enlist""
2,:enlist"your ticket:"
2,:enlist"11,12,13"
2,:enlist""
2,:enlist"nearby tickets:"
2,:enlist"3,9,18"
2,:enlist"15,1,5"
2,:enlist"5,14,9"
```
We split the input into sections again:
```q
q)s:"\n\n"vs"\n"sv x
q)s
"class: 1-3 or 5-7\nrow: 6-11 or 33-44\nseat: 13-40 or 45-50"
"your ticket:\n7,1,14"
"nearby tickets:\n7,3,47\n40,4,50\n55,2,20\n38,6,12"
```
We parse the rules, but this time not ignoring the label:
```q
q)": "vs/:"\n"vs s[0]
"class" "1-3 or 5-7"
"row"   "6-11 or 33-44"
"seat"  "13-40 or 45-50"
q){"J"$"-"vs/:/:" or "vs/:x[;1]}": "vs/:"\n"vs s[0]
1 3   5 7
6  11 33 44
13 40 45 50
q){`$x[;0]}": "vs/:"\n"vs s[0]
`class`row`seat
```
We put the ranges into a table with the field name and ranges, and ungroup them so each range gets
its own row:
```q
q){([]field:`$x[;0];range:"J"$"-"vs/:/:" or "vs/:x[;1])}": "vs/:"\n"vs s[0]
field range
-----------------
class 1 3   5 7
row   6  11 33 44
seat  13 40 45 50
q)rule:ungroup{([]field:`$x[;0];range:"J"$"-"vs/:/:" or "vs/:x[;1])}": "vs/:"\n"vs s[0]
q)rule
field range
-----------
class 1  3
class 5  7
row   6  11
row   33 44
seat  13 40
seat  45 50
```
We parse the tickets like in part 1:
```q
q)tk:"J"$","vs/:1_"\n"vs s[2]
q)tk
7  3 47
40 4 50
55 2 20
38 6 12
```
We figure out which tickets are valid. So instead of finding the indices, we do `all` on the results
of the `within` checks:
```q
q){all any x} each tk within\:/:\:rule[`range]
1000b
```
We filter the tickets to only the valid ones:
```q
q)tk:tk where {all any x} each tk within\:/:\:rule[`range]
q)tk
7 3 47
```
We initialize a field map with enough null symbols for the fields of a ticket:
```q
q)fmap:count[first tk]#`
q)fmap
```
We check which fields are correct for the ranges of which fields. This is another 3-iterator affair,
but this time we take the ranges from the table and find the field names corresponding to the
ranges:
```q
q)tk within/:\:\:rule[`range]
011000b 100000b 000001b
q)where each/:tk within/:\:\:rule[`range]
1 2 ,0 ,5
q)a:rule[`field]where each/:tk within/:\:\:rule[`range]
q)a
`class`row ,`class ,`seat
```
Now we fill out the field mapping with an iteration:
```q
    while[any null fmap; ... ]
```
In the body of the iteration, first we find out which fields are valid for all tickets by iterating
`inter` with `/` (over) for each field. This would only be interesting with multiple valid tickets.
```q
q)poss:(inter')/[a]
q)poss
`class`row
,`class
,`seat
```
We find which fields are unique in the list of possibilites:
```q
q)uniq:where 1=count each poss
q)uniq
1 2
```
We update the field mapping for these unique fields:
```q
q)poss[uniq;0]
`class`seat
q)fmap[uniq]:poss[uniq;0]
q)fmap
``class`seat
```
We find the fields that are still missing from the mapping:
```q
q)miss:where null fmap
q)miss
,0
```
We remove the known fields from the possibilities for the unknown fields:
```q
q)a[;miss]:a[;miss] except\:\:fmap
q)a
row   class seat
```
This ends the iteration.

At the end of the iteration, we have a full field mapping:
```q
q)fmap
`row`class`seat
```
We parse the "your ticket" into integers (this could be done any time up to this point):
```q
q)ytk:"J"$","vs last"\n"vs s[1]
q)ytk
7 1 14
```
We find the fields with names starting with `"departure"` and get the product of the matching values
from "your ticket". For the example input, this results in 1 (identity element) because no fileld's
name starts with `"departure"`.
```q
q)prd ytk where fmap like "departure*"
1
```
