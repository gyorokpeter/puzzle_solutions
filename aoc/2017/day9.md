# Breakdown

## Part 1
Example input:
```q
x:enlist"{{<a!>},{<a!>},{<a!>},{<ab>}}"
```
By convention, the input is a list of strings, but there is only one line, so we take the first
element:
```q
q)a:first x
q)a
"{{<a!>},{<a!>},{<a!>},{<ab>}}"
```
The first step is to remove the escaped characters. The built-in `ssr` (search and replace) function
is useful for this, as it allows using a `?` wildcard to indicate exactly one arbitrary character,
and it also does not replace overlapping occurrences (which in other scenarios is more of a
hindrance but here it's beneficial). We replace the escapes and the escaped characters with dots,
since those don't normally appear in the string:
```q
q)b:ssr[a;"!?";".."]
q)b
"{{<a..},{<a..},{<a..},{<ab>}}"
```
Next, we remove the garbage. To do this, we mark each position whether it is garbage or not by
looking for `<` and `>` characters. However, the `>` character itself counts as garbage, so the end
positions need to be shifted one to the right. The trick here is to build up the list in two parts,
indicating the matching character with either 1 or 0, and every other character as a null. We can
use the atomic equality operator to get booleans for where the character matches, then use the
result as an index into a list to map them to two distinct values. For the closing angle brackets,
we also shift in a 0 at the starting position, which will make sense in the next step.
```q
q)0N 0 b=">"
0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0 0N 0N
q)0,-1_0N 0 b=">"
0 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0 0N
q)0N 1 b="<"
0N 0N 1 0N 0N 0N 0N 0N 0N 1 0N 0N 0N 0N 0N 0N 1 0N 0N 0N 0N 0N 0N 1 0N 0N 0N 0N 0N
```
We can merge the two lists together with the `^` (fill) operator, which "paints" the second list
over the first such that any "transparent" (null) elements will have the items from the first list
"show through".
```q
q)(0,-1_0N 0 b=">")^0N 1 b="<"
0 0N 1 0N 0N 0N 0N 0N 0N 1 0N 0N 0N 0N 0N 0N 1 0N 0N 0N 0N 0N 0N 1 0N 0N 0N 0 0N
```
To get which positions are garbage, we repeat the "painting" but horizontally, from left to right.
The `fills` function (which is just an alias for `^\`) does this. The reason to insert a 0 at the
start is that the fill-forward will leave any leading nulls in place which is undesirable in this
scenario. We also put the list of 1s second since that should take priority over a garbage string
that just ended on the previous position.
```q
q)fills(0,-1_0N 0 b=">")^0N 1 b="<"
0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0
```
We also convert the numbers to booleans for the next step:
```q
q)g:`boolean$fills(0,-1_0N 0 b=">")^0N 1 b="<"
q)g
00111111111111111111111111100b
```
We can use this boolean list in a vector conditional to replace garbage characters with dots:
```q
q)c:?[g;".";b]
q)c
"{{.........................}}"
```
At this point, all the garbage characters have been removed, so any `{}` characters left over are
legitimate. We calculate the depth by mapping the string using a dictionary that maps `{` to 1 and
`}` to -1. Any other character causes out-of-bounds indexing, which returns a null. The depth is
then the running sum of the numbers:
```q
q)("{}"!1 -1)c
1 1 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N -1 -1
q)sums[("{}"!1 -1)c]
1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 0
```
The scores for the groups are equal to the values of the depth list where the string is `{`. So we
can simply multiply the list with the result of the comparison, then sum the results.
```q
q)sums[("{}"!1 -1)c]*c="{"
1 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
q)sum sums[("{}"!1 -1)c]*c="{"
3
```

## Part 2
Example input:
```q
x:enlist"<{o\"i!a,<{i<a>"
```
Just like part 1, we get rid of the escape characters and create a boolean list of which characters
are garbage. But this time, the angle brackets don't count as garbage, so it is the opening bracket
that needs to be shifted one to the right:
```q
q)a:first x
q)b:ssr[a;"!?";".."]
q)b
"<{o\"i..,<{i<a>"
q)(0,-1_0N 1 b="<")
0 1 0N 0N 0N 0N 0N 0N 0N 1 0N 0N 1 0N
q)0N 0 b=">"
0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0N 0
q)fills(0,-1_0N 1 b="<")^0N 0 b=">"
0 1 1 1 1 1 1 1 1 1 1 1 1 0
q)g:`boolean$fills(0,-1_0N 1 b="<")^0N 0 b=">"
q)g
01111111111110b
```
We use a vector conditional, this time to replace the non-garbage characters with dots:
```q
q)?[g;b;"."]
".{o\"i..,<{i<a."
```
The answer is the number of characters that aren't dots:
```q
q)?[g;b;"."]<>"."
01111001111110b
q)sum?[g;b;"."]<>"."
10i
```
