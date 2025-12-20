# Breakdown
Example input:
```q
x:();
x,:enlist"11-22,95-115,998-1012,1188511880-1188511890,222220-222224,"
x,:enlist"1698522-1698528,446443-446449,38593856-38593862,565653-565659,"
x,:enlist"824824821-824824827,2121212118-2121212124"
```

## Overview
While the "standard" solution seems to be to use regular expressions, this is not an option for q
(the built-in string pattern matching capability is not powerful enough for this, and as of this
season there is no grab-and-install official regex library available). So this solution generates
the numbers matching the required pattern constructively.

## Common
Input parsing works the same way for both parts.

First we raze the input together (only for convenience, as there are no line breaks in the real
input) and split it up using [`vs`](https://code.kx.com/q/ref/vs/). We cut on `","` first to get
one element per interval, then cut again on `"-"` to get the two ends of the interval. For the
latter, we need to descend into the list on the right, so we need to use the `/:` (each-right)
iterator.
```q
q)","vs raze x
"11-22"
"95-115"
"998-1012"
"1188511880-1188511890"
"222220-222224"
"1698522-1698528"
"446443-446449"
"38593856-38593862"
"565653-565659"
"824824821-824824827"
"2121212118-2121212124"
q)a:"-"vs/:","vs raze x
q)a
"11"         "22"
"95"         "115"
"998"        "1012"
"1188511880" "1188511890"
"222220"     "222224"
"1698522"    "1698528"
"446443"     "446449"
"38593856"   "38593862"
"565653"     "565659"
"824824821"  "824824827"
"2121212118" "2121212124"
```
We don't convert to integers yet. We return both the intervals and the length of each number to
avoid having to recalculate that in multiple places.
```q
q)cs:count each/:a
q)cs
2  2
2  3
3  4
10 10
6  6
7  7
6  6
8  8
6  6
9  9
10 10
```
Another helper function finds numbers which contain a given number of segments which are repeated
(e.g. 2121 would be 2 repetitions of 21, so the `rep` parameter would be 2).
```q
q)rep:2

    d2rep:{[rep;a;cs]
        ...
    };
```
We find the segment length based on the number lengths and the repetition count. This assumes that
at least one of the given endpoints is evenly divisible by the repetition count, which is true for
the example and real inputs. We check which counts are divisible:
```q
q)0=cs mod rep
11b
10b
01b
11b
11b
00b
11b
11b
11b
00b
11b
```
We filter down the endpoints to only keep the divisible ones. This uses a combination of [`where`](https://code.kx.com/q/ref/where/)
(which in this case returns which positions contain `1b` elements) and indexing to only keep the
elements where the `1b` values are found. Whenever we need to use list indexing in a custom way,
such as pairwise as in this example, we use the `@` operator (for one-level indexing) as the
function argument to the iterator.
```q
q)where each 0=cs mod rep
0 1
,0
,1
0 1
0 1
`long$()
0 1
0 1
0 1
`long$()
0 1
q)cs@'where each 0=cs mod rep
2 2
,2
,4
10 10
6 6
`long$()
6 6
8 8
6 6
`long$()
10 10
```
We perform the actual division to get the half-size, then only keep the first element for each
interval.
```q
q)(cs@'where each 0=cs mod rep)div rep
1 1
,1
,2
5 5
3 3
`long$()
3 3
4 4
3 3
`long$()
5 5
q)half:first each(cs@'where each 0=cs mod rep)div rep
q)half
1 1 2 5 3 0N 3 4 3 0N 5
```
Taking the first element of an empty list returns a null, which we need to ignore. So we find the
non-null elements:
```q
q)valid:where not null half
q)valid
0 1 2 3 4 6 7 8 10
```
We then filter both the `a` and `half` lists using these indices simultaneouly:
```q
q)(a2;half2):(a;half)@\:valid
q)a2
"11"         "22"
"95"         "115"
"998"        "1012"
"1188511880" "1188511890"
"222220"     "222224"
"446443"     "446449"
"38593856"   "38593862"
"565653"     "565659"
"2121212118" "2121212124"
q)half2
1 1 2 5 3 3 4 3 5
```
We can now find the lower and upper bounds of the segment that gets repeated. The lower bound is
the higher of two possibilities: the first is the initial segment of the lower bound in the input,
which we obtain by dropping the last `rep-1` segments from the number (a negative number to `_`
will cause it to drop from the end).
```q
q)a2[;0]
"11"
"95"
"998"
"1188511880"
"222220"
"446443"
"38593856"
"565653"
"2121212118"
q)half2*rep-1
1 1 2 5 3 3 4 3 5
q)neg[half2*rep-1]_'a2[;0]
,"1"
,"9"
,"9"
"11885"
"222"
"446"
"3859"
"565"
"21212"
q)"J"$neg[half2*rep-1]_'a2[;0]
1 9 9 11885 222 446 3859 565 21212
```
The other option is a 1 followed by enough 0's to fill up the segment. This comes into play for
those cases where the lower bound in the input doesn't have enough digits for a full segment.
```q
q)(half2-1)#\:"0"
""
""
,"0"
"0000"
"00"
"00"
"000"
"00"
"0000"
q)"1",/:(half2-1)#\:"0"
,"1"
,"1"
"10"
"10000"
"100"
"100"
"1000"
"100"
"10000"
q)"J"$"1",/:(half2-1)#\:"0"
1 1 10 10000 100 100 1000 100 10000
```
We pick the greater of the two options using the `or` operator. This is an atomic operator so no
iterator is necessary.
```q
q)lo:("J"$"1",/:(half2-1)#\:"0")or"J"$neg[half2*rep-1]_'a2[;0]
q)lo
1 9 10 11885 222 446 3859 565 21212
```
The upper bound works in a similar way. Once again we drop the final `rep-1` parts from the input
number to find the candidate upper bound:
```q
q)"J"$neg[half2*rep-1]_'a2[;1]
2 11 10 11885 222 446 3859 565 21212
```
The alternative is enough 9's to fill up the segment:
```q
q)"J"$half2#\:"9"
9 9 99 99999 999 999 9999 999 99999
```
The choice is now the lower between the two options (any extra digits in front of the segment need
to be ignored), which is obtained using the `and` operator.
```q
q)hi:("J"$half2#\:"9")and"J"$neg[half2*rep-1]_'a2[;1]
q)hi
2 9 10 11885 222 446 3859 565 21212
```
We are ready to generate the possible values for the segment. This use the [integer range](../utils/patterns.md#range-of-integers)
pattern, but we also provide a lower bound of 0 for degenerate inputs:
```q
q)lo+til each 0 or 1+hi-lo
1 2
,9
,10
,11885
,222
,446
,3859
,565
,21212
```
We store the possible values as strings:
```q
q)poss:string lo+til each 0 or 1+hi-lo
q)poss
(,"1";,"2")
,,"9"
,"10"
,"11885"
,"222"
,"446"
,"3859"
,"565"
,"21212"
```
To generate the full numbers, we need to repeat the segments `rep` times. q doesn't have Python's
"string multiplication" operator, but a rather similar feature is using `#` (take) with a length
that is longer than the string, in which case it will repeat the string as necessary until it has
enough characters. So we generate the lengths of the full numbers - since we have an extra level of
nesting, we have to go down one level on the right via the `/:` (each right) iterator:
```q
q)rep*count each/:poss
2 2
,2
,4
,10
,6
,6
,8
,6
,10
```
We use `#`, requiring two `'` (each) iterators due to the nesting:
```q
q)(rep*count each/:poss)#''poss
("11";"22")
,"99"
,"1010"
,"1188511885"
,"222222"
,"446446"
,"38593859"
,"565565"
,"2121221212"
```
Finally we convert the result to integers:
```q
q)poss2:"J"$(rep*count each/:poss)#''poss
q)poss2
11 22
,99
,1010
,1188511885
,222222
,446446
,38593859
,565565
,2121221212
```
We now have to check which of the possibilities actually fit between the bounds. To do this, we
finally convert the bounds into integers and use `within`, which does an inclusive bounds check:
```q
q)poss2 within'"J"$a2
11b
,1b
,1b
,1b
,1b
,1b
,1b
,0b
,0b
```
We use another `where`-based filtering to keep only the valid results:
```q
q)where each poss2 within'"J"$a2
0 1
,0
,0
,0
,0
,0
,0
`long$()
`long$()
q)raze poss2@'where each poss2 within'"J"$a2
11 22 99 1010 1188511885 222222 446446 38593859
```
This is the return value of the helper function `d2rep`. Note that we return the numbers, not just
the count. This is to allow deduplication, which is important for part 2 (e.g. the number 222222
may arise by repeating 22 3 times or 222 twice).

## Part 1
We invoke the helper function with a repetition count of 2 and sum the result.
```q
q)d2rep[2;a;cs]
11 22 99 1010 1188511885 222222 446446 38593859
q)sum d2rep[2;a;cs]
1227775554
```

## Part 2
We find the potential repetition counts based on the length of the longest bound in the input:
```q
q)max max cs
10
q)2+til -1+max max cs
2 3 4 5 6 7 8 9 10
```
We invoke the helper function with each of the repetition counts in turn:
```q
q)d2rep[;a;cs]each 2+til -1+max max cs
11 22 99 1010 1188511885 222222 446446 38593859
111 999 222222 565656 824824824
`long$()
,2121212121
,222222
`long$()
`long$()
`long$()
`long$()
```
We deduplicate the results with `distinct` and sum what remains:
```q
q)raze d2rep[;a;cs]each 2+til -1+max max cs
11 22 99 1010 1188511885 222222 446446 38593859 111 999 222222 565656 824824824 2121212121 222222
q)distinct raze d2rep[;a;cs]each 2+til -1+max max cs
11 22 99 1010 1188511885 222222 446446 38593859 111 999 565656 824824824 2121212121
q)sum distinct raze d2rep[;a;cs]each 2+til -1+max max cs
4174379265
```
