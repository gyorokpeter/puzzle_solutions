# Breakdown
Example input:
```q
x:enlist"dabAcCaCBAcCcaDA"
```

## Part 1
Since the input is a list by convention, we take the first element to convert it into a string:
```q
q)s:first x
```
We generate the possible pairs of letters with opposite case. The built-in variables `.Q.a` and
`.Q.A` come in handy here.
```q
q).Q.a
"abcdefghijklmnopqrstuvwxyz"
q).Q.A
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
q)pairs:(.Q.a,.Q.A),'(.Q.A,.Q.a)
q)pairs
"aA"
"bB"
"cC"
"dD"
"eE"
..
q)24_pairs
"yY"
"zZ"
"Aa"
"Bb"
"Cc"
..
```
The "reaction" is a repeated application of `ssr` (string search and replace), replacing one element
of `pairs` with the null string every time. A single round of replacement iterates over `pairs`.
Since we need to succesively build on the previous result, we can use the `/` (over) iterator, which
keeps an accumulator value and applies the function between it and the next element of the list to
produce the next value of the accumulator. So a single round is:
```q
q)ssr[;;""]/[s;pairs]
"dabCBAcaDA"
```
We would like to continue this until the input no longer changes. This is possible with another
overload of `/`. We "extract" the `s` parameter from the single-round form to get a function that
can be iterated again.
```q
q)s2:ssr[;;""]/[;pairs]/[s];
q)s2
"dabCBAcaDA"
```
The answer is the length of this string.
```q
q)count s2
10
```

## Part 2
We extract the first line as before:
```q
q)s:first x
```
We generate modified strings with each letter of the alphabet removed with `except`. Once again,
the built-in `.Q.a` and `.Q.A` are useful shortcuts.
```q
q)as:s except/:.Q.a,'.Q.A
q)as
"dbcCCBcCcD"
"daAcCaCAcCcaDA"
"dabAaBAaDA"
"abAcCaCBAcCcaA"
"dabAcCaCBAcCcaDA"
..
```
We call the solution function for part 1 on each of these strings. Since that function expects a
list, we enlist them first.
```q
q)rs:d5p1 each enlist each as
q)rs
6 8 4 6 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10
```
The answer is the minimum of this list.
```q
q)min rs
4
```
