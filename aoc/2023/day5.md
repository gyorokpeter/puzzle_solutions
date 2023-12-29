# Breakdown

Example input:
```q
x:();
x,:enlist"seeds: 79 14 55 13";
x,:("";"seed-to-soil map:";"50 98 2";"52 50 48");
x,:("";"soil-to-fertilizer map:";"0 15 37";"37 52 2";"39 0 15");
x,:("";"fertilizer-to-water map:";"49 53 8";"0 11 42";"42 0 7";"57 7 4");
x,:("";"water-to-light map:";"88 18 7";"18 25 70");
x,:("";"light-to-temperature map:";"45 77 23";"81 45 19";"68 64 13");
x,:("";"temperature-to-humidity map:";"0 69 1";"1 0 69");
x,:("";"humidity-to-location map:";"60 56 37";"56 93 4");
```

## Part 1

We extract the seed numbers:
```q
q)s:"J"$" "vs last": "vs first x
q)s
79 14 55 13
```
We also extract the ranges by cutting the input on double-newlines first:
```q
q)m:"J"$" "vs/:/:2_/:(where 0=count each x)cut x;
q)m
(50 98 2;52 50 48)
(0 15 37;37 52 2;39 0 15)
(49 53 8;0 11 42;42 0 7;57 7 4)
(88 18 7;18 25 70)
(45 77 23;81 45 19;68 64 13)
(0 69 1;1 0 69)
(60 56 37;56 93 4)
```
To find the final location we iterate over the maps, starting with the initial seed numbers. The iterated function takes the seed numbers (`cs`) and one row of the map (`cm`). In each step of the iteration:

We find the difference between the seed locations and the starts of each interval:
```q
d:x-/:y[;1];
```
We find which maps apply to which seed by checking that the difference is not negative and is smaller than the last index affected by the maps:
```q
ind:first each where each flip(d>=0) and x</:y[;1]+y[;2];
```
This will return a list of indices into the maps, with nulls for seeds that don't get mapped. We update the seed numbers by adding the previously calculated differences to the starting points of the destination intervals. We fill with the original seed numbers to ensure that any seed that doesn't get mapped retains its existing number.
```q
x^y[ind][;0]+flip[d]@'ind
```
After the iteration we get a list of the final seed numbers:
```q
q)loc:{[cs;cm] .... }/[s;m];
q)loc
82 43 86 35
```
The answer is the minimum of these numbers:
```q
q)min loc
35
```

## Part 2

Because the intervals are too large, we can no longer simulate the individual number assigned to each seed. Instead we keep track of the intervals. If a mapping affects only part of an interval, we split the interval. Similarly it may be necessary to merge intervals to avoid double-counting.

The implementation is long and complicated due to all the intricacies of how to find which intervals to split and then actually splitting them.

The input parsing is similar to part 1:
```q
q)s0:2 cut"J"$" "vs last": "vs first x;
q)m0:"J"$" "vs/:/:2_/:(where 0=count each x)cut x;
```
However this time we preprocess the input to make it more intuitive. In case of the seed intervals, we change them to pairs of lower and upper bound:
```q
q)s:asc s0[;0],'s0[;0]+s0[;1]-1;
q)s
55 67
79 92
```
And for the mappings, we change them to be in the format (old lower bound;old upper bound;shift) (where shift is the number we add to the old seed number to get the new seed number).

We iterate over the map like in part 1 but the actual operations are vastly different.

We split the intervals until there are no splits possible. To check whether it is possible to split, we find which seed intervals are cut by a lower bound of a mapping interval:
```q
aff:flip(cs[;0]</:cm[;0]) and cs[;1]>=/:cm[;0];
```
Similarly for the case when they are cut by an upper bound:
```q
aff:flip(cs[;0]<=/:cm[;1]) and cs[;1]>/:cm[;1];
```
For each interval that needs to be cut, we replace it with two intervals, changing the lower/upper bound as necessary:
```q
cs:asc(cs where not needCut),
    .[cs[cutInd];(::;1);:;cm[cutTarget;0]-1],
    .[cs[cutInd];(::;0);:;cm[cutTarget;0]];
...
cs:asc(cs where not needCut),
    .[cs[cutInd];(::;1);:;cm[cutTarget;1]],
    .[cs[cutInd];(::;0);:;cm[cutTarget;1]+1];

```
Once the splits are done, we perform the mapping as in part 1, but taking advantage of the differently formatted maps:
```q
aff:(cs[;0]>=/:cm[;0])and cs[;1]<=/:cm[;1];
ind:first each where each flip aff;
cs:asc cs+0^cm[ind][;2];
```
Then we merge any intervals that can be merged. Note that `cs` is sorted, which makes it easy to check for intervals touching or overlapping.
```q
change:1b;
while[change;
    change:0b;
    merge:(-1_cs[;1])>=(-1+1_cs[;0]);
    mergeInd:where merge;
    if[count mergeInd; change:1b;
        cs:asc cs[where not (merge,0b)or(0b,merge)],
        cs[mergeInd;0],'cs[mergeInd+1;1];
    ];
];
```
We iterate this whole procedure for the whole mapping list. We end up with a list of final seed number intervals:
```q
q)loc:f/[s;m]
q)loc
46 60
82 84
86 89
94 98
```
This time the minimum seed number will be the start of an interval, so we need to take the minimum of the interval lower bounds.
```q
q)min loc[;0]
46
```
