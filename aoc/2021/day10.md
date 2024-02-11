# Breakdown
Example input:
```q
x:()
x,:enlist"[({(<(())[]>[[{[]{<()<>>"
x,:enlist"[(()[<>])]({[<{<<[]>>("
x,:enlist"{([(<{}[<>[]}>{[]{[(<()>"
x,:enlist"(((({<>}<{<{<>}{[]{[]{}"
x,:enlist"[[<[([]))<([[{}[[()]]]"
x,:enlist"[{[{({}]{}}([{[{{{}}([]"
x,:enlist"{<[[]]>}<{[{[{[]{()[[[]"
x,:enlist"[<(<(<(<{}))><([]([]()"
x,:enlist"<{([([[(<>()){}]>(<<{{"
x,:enlist"<{([{{}}[<[[[<>{}]]]>[]]"
```

## Part 1
The [`ssr`](https://code.kx.com/q/ref/ss/#ssr) function can be used to replace a character sequence
with another. Combined with the `/` iterator, it can replace multiple sequences - in this case all
the pairs of matching brackets. The only thing to watch out for is `[]`, which has special meaning
and so must be specified as `[[]]`. Also `ssr` only passes through the string once, and each
replacement may open up new pairs of brackets to remove, so we need to iterate it with another `/`
until the input no longer changes:
```q
q)a:{{ssr[;;""]/[x;("[[]]";"()";"{}";"<>")]}/[x]}each x
q)a
"[({([[{{"
"({[<{("
"{([(<[}>{{[("
...
```
After all the replacements, the only closing brackets left over are those that are mismatched, so
we filter to those:
```q
q)a inter\:")]}>"
""
""
"}>"
""
...
```
And take the first of each:
```q
q)first each a inter\:")]}>"
"  } )] )> "
```
Since taking the first element of an empty list returns a null (in this case a space) we also need
to get rid of those:
```q
q)(first each a inter\:")]}>")except" "
"})])>"
```
Then we apply a mapping to find the scores and sum them up.
```q
q)(")]}>"!3 57 1197 25137)(first each a inter\:")]}>")except" "
1197 3 57 3 25137
q)sum(")]}>"!3 57 1197 25137)(first each a inter\:")]}>")except" "
26397
```

## Part 2
We do the replacements like before. But this time we remove the lines with any closing bracket:
```q
q)b:a where not any each ")]}>" in/:a
q)b
"[({([[{{"
"({[<{("
"((((<{<{{"
"<{[{[{{[["
"<{(["
```
The matching brackets will be the same types but in reverse order:
```q
q)reverse each b
"{{[[({(["
"({<[{("
"{{<{<(((("
"[[{{[{[{<"
"[({<"
```
And in fact we don't even need to generate the closing brackets, we can just apply the scoring to
the opening ones:
```q
q)("([{<"!1+til 4)reverse each b
3 3 2 2 1 3 1 2
1 3 4 2 3 1
3 3 4 3 4 1 1 1 1
...
```
We then use the "interpret as base X number" feature of `sv` to calculate the scores:
```q
q)5 sv/:("([{<"!1+til 4)reverse each b
288957 5566 1480781 995444 294
```
And luckily q has a `med` function to get the median:
```q
q)med 5 sv/:("([{<"!1+til 4)reverse each b
288957f
```
