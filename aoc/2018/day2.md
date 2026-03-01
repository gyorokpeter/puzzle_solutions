# Breakdown

## Part 1
Example input:
```q
x:"\n"vs"abcdef\nbababc\nabbcde\nabcccd\naabcdd\nabcdee\nababab"
```
The trick to group items to count their occurrences that was used for [day 1](day1.md) comes in
handy here as well. We can group each of the strings:
```q
q)group each x
"abcdef"!(,0;,1;,2;,3;,4;,5)
"bac"!(0 2 4;1 3;,5)
"abcde"!(,0;1 2;,3;,4;,5)
"abcd"!(,0;,1;2 3 4;,5)
"abcd"!(0 1;,2;,3;4 5)
"abcde"!(,0;,1;,2;,3;4 5)
"ab"!(0 2 4;1 3 5)
```
We then apply more operations on each individual result. It would be possible to list those on the
top level, but that would require and unwieldy amount of iterators, so using a function makes the
code look simpler:
```q
q){group x}each x
```
We count the occurrences within each group:
```q
q){count each group x}each x
"abcdef"!1 1 1 1 1 1
"bac"!3 2 1
"abcde"!1 2 1 1 1
"abcd"!1 1 3 1
"abcd"!2 1 1 2
"abcde"!1 1 1 1 2
"ab"!3 3
```
A string is valid if the number 2 or 3 (or both) appears among the frequencies. We can check this
using the list membership operator [`in`](https://code.kx.com/q/ref/in/):
```q
q){2 3 in count each group x}each x
00b
11b
10b
01b
10b
10b
01b
```
We can get the number of strings that have a 2 or 3 respectively by summing this matrix. In general,
using an aggregation function on a matrix collapses it vertically, aggregating column by column.
```q
q)sum{2 3 in count each group x}each x
4 3i
```
To get the answer, we take the product using `prd` (since we know there are exactly two numbers,
`(*).` would be another option).
```q
q)prd sum{2 3 in count each group x}each x
12i
```

## Part 2
Example input:
```q
x:"\n"vs"abcde\nfghij\nklmno\npqrst\nfguij\naxcye\nwvxyz"
```
We pairwise compare each string to find which characters match. If we only had two strings, it would
only be a matter of using the `=` operator between them, since it is atomic and performs a pairwise
match. To extend this functionality to a list, we can use the `/:` (each right) and `\:` (each left)
iterators. Combining the two results in a matrix, with each cell containing the result of applying
the operator between a specific pair of elements.
```q
q)x=/:\:x
11111b 00000b 00000b 00000b 00000b 10101b 00000b
00000b 11111b 00000b 00000b 11011b 00000b 00000b
00000b 00000b 11111b 00000b 00000b 00000b 00000b
00000b 00000b 00000b 11111b 00000b 00000b 00000b
00000b 11011b 00000b 00000b 11111b 00000b 00000b
10101b 00000b 00000b 00000b 00000b 11111b 00010b
00000b 00000b 00000b 00000b 00000b 00010b 11111b
```
We are interested in the number of matching characters, so we sum the small list in each cell. In
general, `each` lifts a function down one level. If we need to go down multiple levels, we have to
add a `/:` (each right) for each additional level.
```q
q)sum each/:x=/:\:x
5 0 0 0 0 3 0
0 5 0 0 4 0 0
0 0 5 0 0 0 0
0 0 0 5 0 0 0
0 4 0 0 5 0 0
3 0 0 0 0 5 1
0 0 0 0 0 1 5
```
The IDs we are looking for are those where the number of matches is one less than the count of the
individual string. Since all strings are of equal length, we can just take the first one and get its
count.
```q
q)(count[first x]-1)=sum each/:x=/:\:x
0000000b
0000100b
0000000b
0000000b
0100000b
0000000b
0000000b
```
We find the indices of the `1b` elements using `where`. It needs to be lifted down once, since the
top level is the entire matrix, the first level down is a single row of the matrix.
```q
q)where each(count[first x]-1)=sum each/:x=/:\:x
`long$()
,4
`long$()
`long$()
,1
`long$()
`long$()
```
On a well-formed input, there are exactly two numbers in the lists, so we can raze them together to
find the indices of the correct IDs.
```q
q)raze where each(count[first x]-1)=sum each/:x=/:\:x
4 1
```
We use these to index into the original string list, resulting in the correct IDs themselves:
```q
q)corr:x raze where each(count[first x]-1)=sum each/:x=/:\:x
q)corr
"fguij"
"fghij"
```
Now to get the common letters, we compare character by character again. This time we apply `=`
between arguments provided as a list, so we use the `.` operator and pass in `=` as the function to
apply. The brackets and space are required due to syntax rules.
```q
q)(=). corr
11011b
```
We use `where` on this list, which returns the indices of the common letters.
```q
q)where(=). corr
0 1 3 4
```
Finally we use these as indices to the first string to get only the matching letters.
```q
q)corr[0]where(=). corr
"fgij"
```
(Note that `inter` also returns the common letters, but it doesn't guarantee the order. This is why
this check with `where` is necessary.)
