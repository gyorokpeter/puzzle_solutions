# Breakdown

Example input:
```q
x:"\n"vs"47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53";
x,:"\n"vs"61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13\n";
x,:"\n"vs"75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47";
```

## Part 1
We start by merging the input on newlines and splitting it on double-newlines to get the two
sections. This is a common pattern for puzzles with multiple sections.
```q
q)a:"\n\n"vs"\n"sv x
q)a
"47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\..
"75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47"
```
We cut the first section on newlines, then cut the lines on `"|"` and parse the result as integers:
```q
q)b:"J"$"|"vs/:"\n"vs a 0
q)b
47 53
97 13
97 61
97 47
75 29
..
```
We cut the second section on commas and parse the result as integers:
```q
q)c:"J"$","vs/:"\n"vs a 1
q)c
75 47 61 53 29
97 61 53 29 13
75 29 13
75 97 47 61 53
61 13 29
97 13 75 29 47
```
To find which sequences have rule violations, we create pairs of consecutive values and reverse
them. If any of the resulting pairs is found in the rules, that pair is a violation. (Actually this
assumes that for any violating sequence, there will be at least one violation where the pair is
consecutive. It turns out this is actually always the case, even while shuffling the elements in
part 2!)

To create the pairs, we drop the last element (`-1_x`)) and in a separate operation we drop the first
element (`1_x`), and we pairwise concatenate the results (`(-1_x),'1_x`). We apply this over each
element of `c`.
```q
q){reverse each(-1_x),'1_x}each c
(47 75;61 47;53 61;29 53)
(61 97;53 61;29 53;13 29)
(29 75;13 29)
(97 75;47 97;61 47;53 61)
(13 61;29 13)
(13 97;75 13;29 75;47 29)
```
We find out which of the pairs is a member of the rule list:
```q
q)({reverse each(-1_x),'1_x}each c)in\:b
0000b
0000b
00b
1000b
01b
0101b
```
The correct lists are those where there is no `1b` value in the membership check result. This is
expressed with `not any`, however we have to use `each` on the `any` to make it collapse
horizontally, as plain `any` would (attempt to) collapse vertically.
```q
q)not any each({reverse each(-1_x),'1_x}each c)in\:b
111000b
```
We filter the list using `where`:
```q
q)d:c where not any each({reverse each(-1_x),'1_x}each c)in\:b
q)d
75 47 61 53 29
97 61 53 29 13
75 29 13
```
We find the middle indices by dividing the list lengths by 2:
```q
q)(count each d)div 2
2 2 1
```
We index into the filtered lists to find the corresponding middle element, then sum them:
```q
q)d@'(count each d)div 2
61 53 29
q)sum d@'(count each d)div 2
143
```

## Part 2
The solution for part 2 involves repeatedly pulling out the incorrect pages and reinserting them at
the end. This results in a kind of bubble sort, but it works well enough.

The input parsing is similar to part 1. Then we initialize a variable to hold the indices of the bad
lists. This will only be filled once but I didn't feel like duplicating the order checking to do it
outside the loop and then again inside it.
```q
    bad:();
```
The iteration will be a `while` loop with an always-true condition. To finish, we return the result
in the middle.
```q
    while[1b;
        ...
    ]
```
One iteration will look like this:
```q
q)c
75 47 61 53 29
97 61 53 29 13
75 29 13
75 97 47 61 53
61 13 29
97 13 75 29 47
```
We generate the pairs like in part 1:
```q
q)d:{reverse each(-1_x),'1_x}each c
q)d
(47 75;61 47;53 61;29 53)
(61 97;53 61;29 53;13 29)
(29 75;13 29)
(97 75;47 97;61 47;53 61)
(13 61;29 13)
(13 97;75 13;29 75;47 29)
```
We find the indices of the violating pairs:
```q
q)e:where each d in\:b
q)e
`long$()
`long$()
`long$()
,0
,1
1 3
```
If this is the first iteration, we initialize the variable `bad` with the indices of the violating
lists:
```q
q)if[0=count bad; bad:where 0<count each e];
q)bad
3 4 5
``` 
We check if we are finished. The details are further down.
```q
    if[0=count raze e; ...]
```
We find the numbers to pick out of each list by indexing into the violating pairs and taking the
last element of the pair (which is the earlier element in the original list):
```q
q)f:(d@'e)[;;1]
q)f
()
()
()
,75
,13
13 29
```
We remove the elements using `except` and then put them back using concatenation, using the
necessary iterators:
```q
q)c:(c except'f),'f
q)c
75 47 61 53 29
97 61 53 29 13
75 29 13
97 47 61 53 75
61 29 13
97 75 47 13 29
```
The iteration continues from here.

On the last iteration, the check `0=count raze e` returns false. At this point we return the sum
of the middle elements like in part 1, except we filter using the `bad` list before summing:
```q
q)c
75 47 61 53 29
97 61 53 29 13
75 29 13
97 75 47 61 53
61 29 13
97 75 47 29 13
q)c@'(count each c)div 2
61 53 29 47 29 47
q)(c@'(count each c)div 2)bad
47 29 47
q)sum(c@'(count each c)div 2)bad
123
```
