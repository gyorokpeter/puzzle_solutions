# Breakdown
Example input:
```q
x:"\n"vs"[1,1,3,1,1]\n[1,1,5,1,1]\n\n[[1],[2,3,4]]\n[[1],4]\n\n[9]\n[[8,7,6]]\n\n[[4,4],4,4]\n[[4,4],4,4,4]\n\n[7,7,7,7]\n[7,7,7]\n\n[]\n[3]\n\n[[[]]]\n[[]]\n\n[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]";
```

## Part 1
Notice that the lists are valid JSON. Therefore we can use the built-in `.j.k` function to convert them into q's list format, but only after splitting into sections and then lines:
```q
a:.j.k each/:"\n"vs/:"\n\n"vs"\n"sv x;
```
For doing comparisons, we define a function like the `cmp` functions in C: it should return a negative, zero or positive number depending on which of its two arguments is greater. We can differentiate the cases based on the types of the arguments - since JSON numbers are always floats, we need to check for type `-9h` to find numbers.

The first case is when both arguments are numbers. Then we return the signum of the difference between the two:
```q
$[-9 -9h~tt:type each (x;y);signum x-y;
```
If only the first argument is a number, we wrap it in a list and try again. `.z.s` is the currently executing function, so we can call it to get a recursive call.
```q
-9h=tt 0; .z.s[enlist x;y];
```
The symmetrical case is when only the second argument is a number.
```q
-9h=tt 1; .z.s[x;enlist y];
```
The last case is the most complicated one, when both arguments are lists. First we find the shorter length between the two lists:
```q
c:min count each (x;y);
```
We recursively call the function on the prefixes of the two lists with this common length:
```q
tmp:.z.s'[c#x;c#y];
```
Then in a nested if-then-else, we check if there is any non-zero result in the comparisons:
```q
$[0<>tr:first (tmp except 0),0;tr;
```
If there isn't, the result is based on comparing the lengths of the lists just like in the numbers case:
```q
signum count[x]-count[y]]
```
This completes the comparison function.
```q
]]};
```
For part 1, we call the comparison function on the pairs in the input. This can be done with the `.` _apply_ operator, which we must iterate over the pairs:
```q
.[cmp]'[a]
```
The answer is the indices of places where the comparison results in -1. But as usual q's indices start with zero, so we have to add one for the actual answer.
```q
if[part=1; :sum 1+where -1=.[cmp]'[a]];
```

## Part 2
We no longer need the input to be in pairs, so we raze them, also adding in the two delimiters (which we also save to a variable for later use):
```q
b:raze[a],dl:(enlist enlist 2f;enlist enlist 6f);
```
q doesn't have a comparator-based sort function. However it's not difficult to implement a quicksort that uses one. This is a textbook quicksort written using q syntax:
```q
    sort:{[cmp;b]
        if[1>=count b; :b];
        cr:cmp[first b]'[1_b];
        left:b 1+where 1=cr;
        right:b 1+where -1=cr;
        .z.s[cmp;left],(1#b),.z.s[cmp;right]};
```
We can use this to sort the list of packets:
```q
b2:sort[cmp;b];
```
Then we look up the indices of the delimiter packets we saved earlier, and once again add one before multiplying them together. `~` _match_ is used for the comparison because `?` is unpredictable when both arguments are lists. The comparison must be done using each-left and each-right, because we are searching for two items, and we are searching for each of them in the larger list.
```q
prd 1+where any b2~\:/:dl
```

## Note
The title text refers back to [2021 day 18](https://adventofcode.com/2021/day/18), which is about snailfish numbers, using a similar nested list format, although it is not mentioned there that the snailfish use them as a distress signal.
