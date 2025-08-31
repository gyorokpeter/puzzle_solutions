# Breakdown

## Validation

This solution uses the `value` function. In order to guarantee that this does not lead to code
injection by providing a malicious values file, we validate each expression for some basic rules.
```q
x:"1 + (2 * 3) + (4 * (5 + 6))"
```
We parse the expression, which throws an error on invalid expressions:
```q
q)parse x
+
1
(+;(*;2;3);(*;4;(+;5;6)))
```
Validation is a recursive function on the parse tree. For the current node, we check for the
following:
* the type must be one of `0h` or `-7h` (general list or long)
* for type `-7h`, it must be within 0 and 9
* for type `0h`, it must have 3 elements, the first one must be `+` or `*`, and the elements other
than the first are themselves successfully validated

## Part 1

We iterate over the lines of the input with an `each`. We validate each expression before
processing.

q's expression evaluation is right-to-left, the exact opposite of what we need to do. However, we
can reverse the expression and flip the parentheses, and it will work correctly.
```q
q)reverse x
"))6 + 5( * 4( + )3 * 2( + 1"
q)ssr/[reverse x;"().";".()"]
"((6 + 5) * 4) + (3 * 2) + 1"
q)value ssr/[reverse x;"().";".()"]
51
```
The answer is the sum of doing this to all entries:
```q
    sum {.d18.valid x;value ssr/[reverse x;"().";".()"]}each x
```

## Part 2

```q
x:"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
```

There is still no precedence, so the solution will require iteratively replacing the operations with
their results.

After validation, we remove the spaces from the expression:
```q
q)x:x except" "
q)x
"5*9*(7*3*3+9*3+(8+6*4))"
```
We iterate as long as there are any parentheses or operators:
```q
    while[any x in"(+*"; ... ]
```
In the body of the iteration, we first find the innermost parenthesis, which can be done via a
running sum that counts a left parenthesis as 1 and a right one as -1.
```q
q)(x="(")-(" ",-1_x)=")"
0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 -1i
q)level:sums(x="(")-(" ",-1_x)=")"
q)level
0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 1i
```
We split out the deepest part by comparing the list with its maximum, then checking where this list
changes:
```q
q)level=max level
00000000000000011111110b
q)deltas level=max level
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 -1i
q)0<>deltas level=max level
00000000000000010000001b
q)where 0<>deltas level=max level
15 22
q)split:0,where 0<>deltas level=max level
q)split
0 15 22
```
The 0 at the beginning is required because `cut` discards the part of the list before the first cut
point. Even if the deepest expression is at the beginning, we still prepend the 0, as this makes
sure that the first element is not the deepest expression.
```q
q)p:split cut x
q)p
"5*9*(7*3*3+9*3+"
"(8+6*4)"
,")"
```
The expressions to evaluate are at the odd indices, which we can generate from the count:
```q
q)ci:1+2*til count[p] div 2
q)ci
,1
```
To evaluate additions with a higher priority, first we remove the parentheses and split it on `"*"`
characters, so the parts are additions:
```q
q)p[ci]except\:"()"
"8+6*4"
q)"*"vs/:p[ci]except\:"()"
"8+6" ,"4"
```
We evaluate these expressions, take their product, and reassemble the original expression:
```q
q)value each/:"*"vs/:p[ci]except\:"()"
14 4
q)prd each value each/:"*"vs/:p[ci]except\:"()"
,56
q)p[ci]:string prd each value each/:"*"vs/:p[ci]except\:"()"
q)p
"5*9*(7*3*3+9*3+"
"56"
,")"
q)x:raze p
q)x
"5*9*(7*3*3+9*3+56)"
```
At the end of the iteration, the expression is reduced to a string representation of the result,
which we parse as an integer.
```q
q)x
"669060"
q)"J"$x
669060
```
