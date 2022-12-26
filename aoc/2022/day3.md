# Breakdown
Example input:
```q
x:"\n"vs"vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw";
```

## Part 1
The [`take`](https://code.kx.com/q/ref/take/#atom-or-list) operator has a special case if we try to make a 2-dimensional matrix and specify null as the second dimension. It will maximize that dimension but also not change the ordering of the elements. This is a useful trick for cutting lists exactly in half. Note the use of each-right as we want to split each line instead of the whole list.
```q
q)p:2 0N#/:x
q)p
"vJrwpWtwJgWr"     "hcsFMMfFFhFp"
"jqHRNqRjqzjGDLGL" "rsFMfFZSrLrFZsSL"
"PmmdzqPrV"        "vPwwTWBwg"
"wMqvLMZHhHMvwLH"  "jbvcjnnSBnvTQFn"
"ttgJtRGJ"         "QctTZtZT"
"CrZsJsPPZsGz"     "wwsLwLmpwMDw"
```
We can check the common letter using the `inter` operator:
```q
p[;0]inter'p[;1]
q)p[;0]inter'p[;1]
,"p"
"LL"
"PP"
"vv"
"ttt"
"sss"
```

## Part 2
We cut the lines into groups of three:
```q
q)3 cut x
"vJrwpWtwJgWrhcsFMMfFFhFp"       "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL" "PmmdzqPrVvPwwTWBwg"
"wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn" "ttgJtRGJQctTZtZT"                 "CrZsJsPPZsGzwwsLwLmpwMDw"
```
Once again we can use `inter` - this time with `/` to iterate over the lists.
```q
q)(inter/)each 3 cut x
"rr"
,"Z"
```

## Common
This applies to both parts to convert the partial output from above into a score.

We start by taking the distinct of the lists of common elements, since it may contain some letters duplicated:
```q
q)distinct each p[;0]inter'p[;1]
,"p"
,"L"
,"P"
,"v"
,"t"
,"s"
q)distinct each (inter/)each 3 cut x
,"r"
,"Z"
```
We also raze them, which will result in a string:
```q
q)raze distinct each p[;0]inter'p[;1]
"pLPvts"
q)raze distinct each (inter/)each 3 cut x
"rZ"
```
To figure out the score, we can look up (with `?` _find_) the letters in the internal variable [`.Q.an`](https://code.kx.com/q/ref/dotq/#qan-all-alphanumerics). This has all the letters in the right order, however as the indexing starts from zero we have to add one to the result.
```q
q).Q.an?raze distinct each p[;0]inter'p[;1]
15 37 41 21 19 18
q)1+.Q.an?raze distinct each p[;0]inter'p[;1]
16 38 42 22 20 19
q)sum 1+.Q.an?raze distinct each p[;0]inter'p[;1]
157
q)sum 1+.Q.an?raze distinct each (inter/)each 3 cut x
70
```
