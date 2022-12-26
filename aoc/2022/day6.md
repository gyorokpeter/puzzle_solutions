# Breakdown
Example input:
```q
x:"\n"vs"mjqjpqmgbljsphdztnvjfqwrcgsmlb";
c:4;
```

## Common
Even though the input is a single line, it's still a list of strings due to my conventions. So the first thing is to take out that single string from the list.
```q
q)x:first x
q)x
"mjqjpqmgbljsphdztnvjfqwrcgsmlb"
```
To find a substring of length `c` with distinct characters, we first generate a matrix of indices for all the possible substrings. We use `til` to generate the starting points of the indices, but we must count back `c-1` characters from the end because otherwise those indices would point past the end of the string.
```q
q)til count[x]-c-1
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
```
We add the integers from 0 to `c-1` to each of the starting indices, so we end up with the indices for every possible substring:
```q
q)til[c]+/:til count[x]-c-1
0  1  2  3
1  2  3  4
..
25 26 27 28
26 27 28 29
```
We apply the indices to the string:
```q
q)x til[c]+/:til count[x]-c-1
"mjqj"
"jqjp"
..
"gsml"
"smlb"
```
We check the count of distinct characters within each substring:
```q
q)distinct each x til[c]+/:til count[x]-c-1
"mjq"
"jqp"
"qjp"
"jpqm"
...
"gsml"
"smlb"
q)count each distinct each x til[c]+/:til count[x]-c-1
3 3 3 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4
```
We find the first position where the number of distinct characters equals `c`. The answer is the first character after the end of the substring, so we must add `c` to the found index.
```q
q)c+first where c=count each distinct each x til[c]+/:til count[x]-c-1
7
```

## Part 1 vs 2
The only difference is that we use 4 as `c` for part 1 and 14 for part 2.
