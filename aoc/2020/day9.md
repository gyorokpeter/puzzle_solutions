# Breakdown
This is a straightforward simulation, much less complex than the VMs from previous years.

Example input:
```q
x:"\n"vs"35\n20\n15\n25\n47\n40\n62\n55\n65\n95\n102\n117\n150\n182\n127\n219\n299\n277\n309\n576"
n:5
```
For this day the function will take an extra parameter `n`, to indicate the length of the preamble
(5 for the example and 25 for the actual input).

## Part 1
After parsing the integers, we drop the first `n` of them:
```q
q)a:"J"$x
q)a
35 20 15 25 47 40 62 55 65 95 102 117 150 182 127 219 299 277 309 576
q)b:n _a
q)b
40 62 55 65 95 102 117 150 182 127 219 299 277 309 576
```
Then we take all `n`-long sublists of the original list. To do this we generate `(start;length)`
pairs where the length is always `n` and the start goes from 0 to the length of the list minus `n`:
```q
q)til[count[a]-n],\:5
0  5
1  5
2  5
..
12 5
13 5
14 5
```
We use the `sublist` function to generate the slices:
```q
q)c:(til[count[a]-n],\:5) sublist\:a
q)c
35  20  15  25  47
20  15  25  47  40
15  25  47  40  62
..
150 182 127 219 299
182 127 219 299 277
127 219 299 277 309
```
We drop the numbers that are half of a number found in `b`. This is to avoid considering a number to
be the sum of two copies of the same number.
```q
q)d:c except'b%2
q)d
35 15 25 47
20 15 25 47 40
15 25 47 40 62
..
150 182 127 219 299
182 127 219 299 277
127 219 299 277 309
```
Using a similar trick to day 1, we subtract each sublist from the number we are trying to build
from it, and check the intersection between the original list and the result of the subtraction.
```q
q)e:d inter' b-d
q)e
15 25
15 47
..
65 117
`long$()
102 117
..
```
The number we are looking for is the one where the intersection has less than 2 elements.
```q
q)b where 2>count each e
,127
```
We need the first of such numbers:
```q
q)first b where 2>count each e
127
```

## Part 2
We start by invoking part 1 to find the unmatched number:
```q
q)t:d9p1[n;x]
q)t
127
```
We only need the part of the list before this number so first we find its index:
```q
q)a?t
14
```
And drop the list from this index:
```q
q)b:(a?t)#a
q)b
35 20 15 25 47 40 62 55 65 95 102 117 150 182
```
Next we generate the partial sums starting from each element in the reduced list. First we make
the necessary sublists:
```q
q)til[count b]_\:b
35 20 15 25 47 40 62 55 65 95 102 117 150 182
20 15 25 47 40 62 55 65 95 102 117 150 182
..
117 150 182
150 182
,182
```
Then take the partial sums inside each sublist:
```q
q)c:sums each til[count b]_\:b
q)c
35 55 70 95 142 182 244 299 364 459 561 678 828 1010
20 35 60 107 147 209 264 329 424 526 643 793 975
15 40 87 127 189 244 309 404 506 623 773 955
..
150 332
,182
```
We find which list of partial sums contains our number:
```q
q)where t in/:c
,2
```
We save this index as `t1` and the sublist in `d`:
```q
q)d:c t1:first where t in/:c
q)t1
2
q)d
15 40 87 127 189 244 309 404 506 623 773 955
```
The last index is obtained by finding the number within the sublist and adding it to the first
index:
```q
q)t2:t1+1+first where t=d
q)t2
6
```
Then we take this slice of the list, which is exactly the numbers that sum up to the missing
number:
```q
q)e:t1 _t2#a
q)e
15 25 47 40
```
The answer is the sum of the minimum and maximum of this list:
```q
q)min[e]
15
q)max[e]
47
q)min[e]+max[e]
62
```
