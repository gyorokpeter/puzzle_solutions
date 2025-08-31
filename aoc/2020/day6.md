# Breakdown
Example input:
```q
x:"\n"vs"abc\n\na\nb\nc\n\nab\nac\n\na\na\na\na\n\nb"
```

## Part 1
We break the input into groups by cutting on double newline:
```q
q)"\n\n"vs"\n"sv x
"abc"
"a\nb\nc"
"ab\nac"
"a\na\na\na"
,"b"
```
We remove the inner newlines to join all answers in the group together:
```q
q)("\n\n"vs"\n"sv x)except\:"\n"
"abc"
"abc"
"abac"
"aaaa"
,"b"
```
We take the distinct set of elements in each group:
```q
q)distinct each("\n\n"vs"\n"sv x)except\:"\n"
"abc"
"abc"
"abc"
,"a"
,"b"
```
We count the elements in the distinct sets:
```q
q)count each distinct each("\n\n"vs"\n"sv x)except\:"\n"
3 3 3 1 1
```
And sum them up:
```q
q)sum count each distinct each("\n\n"vs"\n"sv x)except\:"\n"
11
```

## Part 2
Once again we break the input into groups:
```q
q)"\n\n"vs"\n"sv x
"abc"
"a\nb\nc"
"ab\nac"
"a\na\na\na"
,"b"
```
And then also cut each group into its individual members:
```q
q)"\n"vs/:"\n\n"vs"\n"sv x
,"abc"
(,"a";,"b";,"c")
("ab";"ac")
(,"a";,"a";,"a";,"a")
,,"b"
```
This time we need the intersection within each group. `inter/` will do that for a single list. To do
it to each list we use it with the `each` function.
```q
q)(inter/)each"\n"vs/:"\n\n"vs"\n"sv x
"abc"
""
,"a"
,"a"
,"b"
```
And again we count and sum up the elements.
```q
q)sum count each(inter/)each"\n"vs/:"\n\n"vs"\n"sv x
6
```
