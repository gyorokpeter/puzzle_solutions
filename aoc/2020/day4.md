# Breakdown
Example input:
```q
x: enlist"ecl:gry pid:860033327 eyr:2020 hcl:#fffffd"
x,:enlist"byr:1937 iyr:2017 cid:147 hgt:183cm"
x,:enlist""
x,:enlist"iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884"
x,:enlist"hcl:#cfa07d byr:1929"
x,:enlist""
x,:enlist"hcl:#ae17e1 iyr:2013"
x,:enlist"eyr:2024"
x,:enlist"ecl:brn pid:760753108 byr:1931"
x,:enlist"hgt:179cm"
x,:enlist""
x,:enlist"hcl:#cfa07d eyr:2025 pid:166559648"
x,:enlist"iyr:2011 ecl:brn hgt:59in"
```

## Part 1
We break down the input into records by splitting on double newlines.
```q
q)"\n\n"vs"\n"sv x
"ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\nbyr:1937 iyr:2017 cid:147 hgt:183cm"
"iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884\nhcl:#cfa07d byr:1929"
"hcl:#ae17e1 iyr:2013\neyr:2024\necl:brn pid:760753108 byr:1931\nhgt:179cm"
"hcl:#cfa07d eyr:2025 pid:166559648\niyr:2011 ecl:brn hgt:59in"
```
We replace the newlines in the records with spaces such that there is a consistent separator.
```q
q)ssr[;"\n";" "]each"\n\n"vs"\n"sv x
"ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm"
"iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884 hcl:#cfa07d byr:1929"
"hcl:#ae17e1 iyr:2013 eyr:2024 ecl:brn pid:760753108 byr:1931 hgt:179cm"
"hcl:#cfa07d eyr:2025 pid:166559648 iyr:2011 ecl:brn hgt:59in"
```
Now we can use an overload of `0:` that
[parses key-value pairs](https://code.kx.com/q/ref/file-text/#load-csv). The first argument to this
will be `"S: "`. `"S"` because the key type is symbol, `":"` for the separator between key and
value, and `" "` for the separator between fields.
```q
q)"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x
ecl   pid         eyr    hcl       byr    iyr    cid   hgt     "gry" "860033327" "2020" "#fffffd" ..
iyr    ecl   cid   eyr    pid         hcl       byr            "2013" "amb" "350" "2023" "02804888..
hcl       iyr    eyr    ecl   pid         byr    hgt           "#ae17e1" "2013" "2024" "brn" "7607..
hcl       eyr    pid         iyr    ecl   hgt                  "#cfa07d" "2025" "166559648" "2011"..
```
For now we care only about the keys so we take the first of each element in the result.
```q
q)first each"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x
`ecl`pid`eyr`hcl`byr`iyr`cid`hgt
`iyr`ecl`cid`eyr`pid`hcl`byr
`hcl`iyr`eyr`ecl`pid`byr`hgt
`hcl`eyr`pid`iyr`ecl`hgt
```
We remove `cid` from the keys since that's optional.
```q
q)(first each"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x)except\:`cid
`ecl`pid`eyr`hcl`byr`iyr`hgt
`iyr`ecl`eyr`pid`hcl`byr
`hcl`iyr`eyr`ecl`pid`byr`hgt
`hcl`eyr`pid`iyr`ecl`hgt
```
Then we count the number of keys in each record.
```q
q)count each(first each"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x)except\:`cid
7 6 7 6
```
The answer is the count of 7's in this list. (This abuses the format of the input, in particular
there are no duplicate fields and no fields not mentioned in the puzzle statement.)
```q
q)sum 7=count each(first each"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x)except\:`cid
2i
```

## Part 2
We parse the key-value pairs like in part 1.
```q
q)t:"S: "0:/:ssr[;"\n";" "]each"\n\n"vs"\n"sv x
q)t
ecl   pid         eyr    hcl       byr    iyr    cid   hgt     "gry" "860033327" "2020" "#fffffd" ..
iyr    ecl   cid   eyr    pid         hcl       byr            "2013" "amb" "350" "2023" "02804888..
hcl       iyr    eyr    ecl   pid         byr    hgt           "#ae17e1" "2013" "2024" "brn" "7607..
hcl       eyr    pid         iyr    ecl   hgt                  "#cfa07d" "2025" "166559648" "2011"..
```
Also we filter it using the same condition to keep only the valid ones.
```q
q)t where 7=count each (first each t) except\:`cid
ecl   pid         eyr    hcl       byr    iyr    cid   hgt     "gry" "860033327" "2020" "#fffffd" ..
hcl       iyr    eyr    ecl   pid         byr    hgt           "#ae17e1" "2013" "2024" "brn" "7607..
```
We would like to turn the data into a table, which requires each record to be a dictionary. This
can be done by applying the `!` operator on the two elements of each element in the top-level list.
This is expressed as `(!)./:` using
[dot-apply (multi-argument)](https://code.kx.com/q/ref/apply/#apply-index) between the constant `!`
on the left and each element (2-element lists) on the right.
```q
q)(!)./:t where 7=count each (first each t) except\:`cid
`ecl`pid`eyr`hcl`byr`iyr`cid`hgt!("gry";"860033327";"2020";"#fffffd";"1937";"2017";"147";"183cm")
`hcl`iyr`eyr`ecl`pid`byr`hgt!("#ae17e1";"2013";"2024";"brn";"760753108";"1931";"179cm")
```
The easiest way to make a table out of this is to enlist each element (turning it into a one-row
table) and then union-join all those tables together.
```q
q)t2:(uj/) enlist each (!)./:t where 7=count each (first each t) except\:`cid;
q)t2
ecl   pid         eyr    hcl       byr    iyr    cid   hgt
--------------------------------------------------------------
"gry" "860033327" "2020" "#fffffd" "1937" "2017" "147" "183cm"
"brn" "760753108" "2024" "#ae17e1" "1931" "2013" ""    "179cm"
```
From here we build up a query to filter out the invalid entries. Since the values are still
strings, we need to cast them to numbers whenever a numerical comparison is necessary.
The where clauses for the years are simple:
```q
    ("J"$byr) within 1920 2002,
    ("J"$iyr) within 2010 2020,
    ("J"$eyr) within 2020 2030,
```
For height we use [vector conditional (?)](https://code.kx.com/q/ref/vector-conditional/) with a
pattern match (`like`) as the condition. In fact we need to nest two vector conditionals becuase in
addition to the two types of units there is the case of the field not containing a valid unit, in
which case the match should return false. For the numerical comparisons we cut the last 2 characters
using `-2_/:` since those are the unit.
```q
    ?[hgt like "*in";("J"$-2_/:hgt)within 59 76;
        ?[hgt like "*cm";("J"$-2_/:hgt)within 150 193;
        0b]],
```
For `hcl` we do a pattern match. It needs to start with `"#"` and then be followed by 6 characters
that could be `0-9` or `a-f`. The like-expression `"[0-9a-f]"` will match one of these characters.
To match 6 of them we repeat this pattern 6 times by taking from a single-element list containing
the pattern and then razing the result.
```q
q)"#",raze 6#enlist"[0-9a-f]"
"#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]"
```
Using this we can express the condition on `hcl`.
```q
    hcl like("#",raze 6#enlist"[0-9a-f]"),
```
A similar condition applies on `pid`, but we only allow digits and we repeat the pattern 9 times.
```q
    pid like raze 9#enlist"[0-9]"};
```
The condition on `ecl` is simply membership in a list.
        ecl in ("amb";"blu";"brn";"gry";"grn";"hzl";"oth"),
Putting these together we have a full table query. But we only need the number of matching rows
so we "exec count i from" it.
```q
    exec count i from t2 where
        ("J"$byr) within 1920 2002,
        ("J"$iyr) within 2010 2020,
        ("J"$eyr) within 2020 2030,
        ?[hgt like "*in";("J"$-2_/:hgt)within 59 76;
            ?[hgt like "*cm";("J"$-2_/:hgt)within 150 193;
            0b]],
        hcl like("#",raze 6#enlist"[0-9a-f]"),
        ecl in ("amb";"blu";"brn";"gry";"grn";"hzl";"oth"),
        pid like raze 9#enlist"[0-9]"};
```
The result of this query is a single number that is the answer to part 2.
