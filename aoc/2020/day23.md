# Breakdown
A straightforward simulation.

Example input:
```q
q)x:"389125467"
q)cups:0
q)moves:100
q)rlen:0;
q)rmode:`str
```

## Common
A generic function takes care of both parts. It takes a couple of parameters to control the
behavior:
- `cups`: the number of cups, used to expand the list if the input is too short (part 2 only)
- `moves`: the number of moves
- `rlen`: how many cups to check when returning the result, 0 means all but `"1"`
- `rmode`: ``` `mult``` multiplies the checked cups together, ``` `str``` converts them to string
- `x`: the input as a string

The core logic is the same for both parts, the parameters only matter for the setup and the
returning of the result. We use an array to represent the right neighbor of each cup. We decrease
the cup numbers by one to avoid leaving a gap in the array. With this representation each step
takes constant time since we only need to update 3 numbers in the array: the next cup after the
current cup, the last of the moved cups and the destination cup.
Still this ends up being a killer with a large number of moves, since there is no way to further
optimize the sequential array updates.

We start by converting the cup numbers to integers and subtracting one to get the cup IDs. Note that
`"J"$` would convert the whole string, so we need to use it with `/:` (each-right) to convert the
individual characters.
```q
q)c:-1+"J"$/:x
q)c
2 7 8 0 1 4 3 5 6
```
We add the remaining cups (only relevant for part 2):
```q
q)c,:count[c]_til cups
q)c
2 7 8 0 1 4 3 5 6
```
We generate the array that indicates which cup is to the right of each cup. We start by generating
the IDs of each cup, finding them in the cup array, adding 1 to the indices and `mod`ding them by
the cup count to wrap around:
```q
q)til count c
0 1 2 3 4 5 6 7 8
q)c?til count c
3 4 0 6 5 7 8 1 2
q)(c?til count c)+1
4 5 1 7 6 8 9 2 3
q)((c?til count c)+1)mod count c
4 5 1 7 6 8 0 2 3
q)right:c((c?til count c)+1)mod count c
q)right
1 4 7 5 3 6 2 8 0
```
(e.g. the element at index 3 is 5, which means cup 3 has cup 5 to its right).

We initialize the current cup to the first cup and also set the round counter to zero:
``` q
q)curr:first c
q)curr
2
q)round:0
```
We simulate the moves in a loop that goes on for `moves` iterations:
```q
    do[moves;
        ...
    ];
```
Inside the iteration, we increment the round counter:
```q
q)round+:1
q)round
1
```
We find the three cups picked up by iterating the `right` array as if it were a function three
times. Since we need the intermediate results, we use `\` (scan). This also returns the initial
value, but that cup is not picked up so we remove it from the result.
```q
q)right\[3;curr]
2 7 8 0
q)move:1_right\[3;curr]
q)move
7 8 0
```
(Reminder that the cup IDs have 1 subtracted from them, so this matches up with the 8, 9, 1 in the
example.)

We find the destination cup. We generate all four possibilities by subtracting 1..4 from the current
cup, `mod`ding it by the cup count and then removing the selected cups, and taking the first one
that remains.
```q
q)curr-1+til 4
1 0 -1 -2
q)(curr-1+til 4)mod count c
1 0 8 7
q)((curr-1+til 4)mod count c)except move
,1
q)dest:first ((curr-1+til 4)mod count c)except move
q)dest
1
```
We find the cup after the last cup to be moved:
```q
q)after:right last move
q)after
1
```
We also find the cup after the destination:
```q
q)aftd:right dest
q)aftd
4
```
Based on these, we update the `right` array to be correct after the result of the move. The cup to
the right of the current cup will be the one after the last one picked up, the cup to the right of
the destination will be the first one picked up, and the cup after the last one picked up will be
the one after the destination cup. All of these can be assigned in a single operation by indexing
with a list.
```q
q)right[(curr;dest;last move)]:(after;first move;aftd)
q)right
4 7 1 5 3 6 2 8 0
```
Finally we advance the current cup to the right:
```q
q)curr:right curr
q)curr
1
```
We also print progress for the long calculation in part 2:
```q
    if[0=round mod 10000; show round]
```
After the iteration, the `right` array will contain the final state:
```q
q)right
5 8 7 4 1 6 2 3 0
```
To extract the cup numbers, we iterate this list as if it was a function, starting with cup 1 (which
has the ID 0 in the list). The iteration count is either one less than the cup count if `rlen` is
zero (part 1) or the value of `rlen` (2 for part 2).
```q
q)1_right\[$[0=rlen;count[c]-1;rlen];0]
5 6 2 7 3 4 1 8
```
We add back the 1 to get the real cup IDs:
```q
q)1+1_right\[$[0=rlen;count[c]-1;rlen];0]
6 7 3 8 4 5 2 9
```
We produce the output by applying a function depending on the value of the `rmode` parameter. For
`mult` we take the product of the list elements, for any other value we convert them into strings
and raze them. The `@` after `string` makes sure that the expression remains a callable instead of
trying to apply `raze` to the function `string` itself.
```q
q)$[rmode=`mult;prd;raze string@]1+1_right\[$[0=rlen;count[c]-1;rlen];0]
"67384529"
```

## Part 1
Wrapping the above in a function `d23`, we call it with the appropriate parameters:
```q
q)d23[0;100;0;`str;x]
"67384529"
```

## Part 2:
We call the function with the appropriate parameters:
```q
q)d23[1000000;10000000;2;`mult;x]
..
9970000
9980000
9990000
10000000
149245887792
```
