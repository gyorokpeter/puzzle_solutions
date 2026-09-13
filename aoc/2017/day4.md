# Breakdown

## Part 1
The interesting part is done in a function that is called on each row.

We split the line into words:
```q
q)x:"aa bb cc dd aa"
q)" "vs x
"aa"
"bb"
"cc"
"dd"
"aa"
```
Then group them:
```q
q)group" "vs x
"aa"| 0 4
"bb"| ,1
"cc"| ,2
"dd"| ,3
```
We find which indices appear only once:
```q
q)count each group" "vs x
"aa"| 2
"bb"| 1
"cc"| 1
"dd"| 1
q)1=count each group" "vs x
"aa"| 0
"bb"| 1
"cc"| 1
"dd"| 1
```
We only return true if all of these values are 1:
```q
q)all 1=count each group" "vs x
0b
```
The overall result is the sum of the above function called for every row.

## Part 2
The only difference is that after splitting the line into words, we also sort each word. This means
the `group` function will put anagrams into the same group.
```q
q)" "vs x
"abcde"
"xyz"
"ecdab"
q)asc each" "vs x
`s#"abcde"
`s#"xyz"
`s#"abcde"
q)group asc each" "vs x
`s#"abcde"| 0 2
`s#"xyz"  | ,1
```
The rest is done the same way as Part 1.
