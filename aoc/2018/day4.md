# Breakdown
Example input:
```q
x:()
x,:enlist"[1518-11-01 00:00] Guard #10 begins shift"
x,:enlist"[1518-11-01 00:05] falls asleep"
x,:enlist"[1518-11-01 00:25] wakes up"
x,:enlist"[1518-11-01 00:30] falls asleep"
x,:enlist"[1518-11-01 00:55] wakes up"
x,:enlist"[1518-11-01 23:58] Guard #99 begins shift"
x,:enlist"[1518-11-02 00:40] falls asleep"
x,:enlist"[1518-11-02 00:50] wakes up"
x,:enlist"[1518-11-03 00:05] Guard #10 begins shift"
x,:enlist"[1518-11-03 00:24] falls asleep"
x,:enlist"[1518-11-03 00:29] wakes up"
x,:enlist"[1518-11-04 00:02] Guard #99 begins shift"
x,:enlist"[1518-11-04 00:36] falls asleep"
x,:enlist"[1518-11-04 00:46] wakes up"
x,:enlist"[1518-11-05 00:03] Guard #99 begins shift"
x,:enlist"[1518-11-05 00:45] falls asleep"
x,:enlist"[1518-11-05 00:55] wakes up"
```

## Common
We use a helper function (`d4prep`) to figure out which guard is asleep at which minute. Note that
the date is not relevant for either part.

We convert the timestamps into q's native timestamp data type, which has the type code `p`. However,
it has a limitation that it can't handle years as far back as 1518 (it cuts off around 1709). So we
extract only the part after the first `-` (by dropping the first 5 characters and taking the next
12), and prepend `2000` to each:
```q
q)12#/:5_/:x
"-11-01 00:00"
"-11-01 00:05"
"-11-01 00:25"
"-11-01 00:30"
"-11-01 00:55"
..
q)"2000",/:12#/:5_/:x
"2000-11-01 00:00"
"2000-11-01 00:05"
"2000-11-01 00:25"
"2000-11-01 00:30"
..
q)ts:"P"$"2000",/:12#/:5_/:x
q)ts
2000.11.01D00:00:00.000000000 2000.11.01D00:05:00.000000000 2000.11.01D00:25:00.000000000 2000.11...
```
We get the number of minutes by first casting to `minute` (which removes the date part and scales
the internal representation accordingly), then again to `long`. We put this into a table and put it
in ascending order by the original timestamps:
```q
q)es:([]minute:`long$`minute$ts;e:x) iasc ts
q)es
minute e
--------------------------------------------------
0      "[1518-11-01 00:00] Guard #10 begins shift"
5      "[1518-11-01 00:05] falls asleep"
25     "[1518-11-01 00:25] wakes up"
30     "[1518-11-01 00:30] falls asleep"
55     "[1518-11-01 00:55] wakes up"
1438   "[1518-11-01 23:58] Guard #99 begins shift"
..
```
We now try to find the event types by looking for one of the words `"begins"`, `"falls"` and
`"wakes"`. We can use the [`ss`](https://code.kx.com/q/ref/ss/) operator to find occurrences of
these substrings in every line:
```q
q)update et:{x ss/:("begins";"falls";"wakes")}each e from es
minute e                                           et
-----------------------------------------------------------------------------
0      "[1518-11-01 00:00] Guard #10 begins shift" ,29      `long$() `long$()
5      "[1518-11-01 00:05] falls asleep"           `long$() ,19      `long$()
25     "[1518-11-01 00:25] wakes up"               `long$() `long$() ,19
30     "[1518-11-01 00:30] falls asleep"           `long$() ,19      `long$()
55     "[1518-11-01 00:55] wakes up"               `long$() `long$() ,19
..
```
We count the number of matches to tell which event type the line is:
```q
q)update et:{count each x ss/:("begins";"falls";"wakes")}each e from es
minute e                                           et
--------------------------------------------------------
0      "[1518-11-01 00:00] Guard #10 begins shift" 1 0 0
5      "[1518-11-01 00:05] falls asleep"           0 1 0
25     "[1518-11-01 00:25] wakes up"               0 0 1
30     "[1518-11-01 00:30] falls asleep"           0 1 0
55     "[1518-11-01 00:55] wakes up"               0 0 1
..
```
The event type will be the location of the 1 in the resulting list:
```q
q)es2:update et:{first where count each x ss/:("begins";"falls";"wakes")}each e from es
q)es2
minute e                                           et
-----------------------------------------------------
0      "[1518-11-01 00:00] Guard #10 begins shift" 0
5      "[1518-11-01 00:05] falls asleep"           1
25     "[1518-11-01 00:25] wakes up"               2
30     "[1518-11-01 00:30] falls asleep"           1
55     "[1518-11-01 00:55] wakes up"               2
..
```
To find the guard number, we split on `"#"`, take the last part, then split on spaces and take the
first part. This will only return a valid value on `"begins"` lines, but we can use `fills` to carry
forward the guard number to the other lines.
```q
q)update gn:"J"${first" "vs last"#"vs x}each e from es2
minute e                                           et gn
--------------------------------------------------------
0      "[1518-11-01 00:00] Guard #10 begins shift" 0  10
5      "[1518-11-01 00:05] falls asleep"           1
25     "[1518-11-01 00:25] wakes up"               2
30     "[1518-11-01 00:30] falls asleep"           1
55     "[1518-11-01 00:55] wakes up"               2
1438   "[1518-11-01 23:58] Guard #99 begins shift" 0  99
..
q)es2:update gn:fills"J"${first" "vs last"#"vs x}each e from es2
q)es2
minute e                                           et gn
--------------------------------------------------------
0      "[1518-11-01 00:00] Guard #10 begins shift" 0  10
5      "[1518-11-01 00:05] falls asleep"           1  10
25     "[1518-11-01 00:25] wakes up"               2  10
30     "[1518-11-01 00:30] falls asleep"           1  10
55     "[1518-11-01 00:55] wakes up"               2  10
1438   "[1518-11-01 23:58] Guard #99 begins shift" 0  99
..
```
We create a table grouped by guard number and event type, but only for rows with an event type of 1
or 2. Note that we don't have to aggregate when using a group by, unlike traditional SQL.
```q
q)select minute by gn,et from es2 where 0<et
gn et| minute
-----| --------
10 1 | 5  30 24
10 2 | 25 55 29
99 1 | 40 36 45
99 2 | 50 46 55
```
A grouped query returns a keyed table, but that is not advantageous here because `each` only
considers the range of its input, which in this case is the value table (only the `minute` column).
So we remove the keys from the table using an overload of `!`:
```q
q)esg:0!select minute by gn,et from es2 where 0<et
q)esg
gn et minute
--------------
10 1  5  30 24
10 2  25 55 29
99 1  40 36 45
99 2  50 46 55
```
The next opeation is a function iterated with `each`. For example, considering the guard with ID 10:
```q
q)g:10
```
We select the rows from the table that match this guard:
```q
q)r:select from esg where gn=g
q)r
gn et minute
--------------
10 1  5  30 24
10 2  25 55 29
```
We extract the minutes from the two rows:
```q
q)exec minute from r
5  30 24
25 55 29
```
The top row indicates the start of the interval and the bottom row indicates the end. We can use the
[range of integers](../utils/patterns.md#range-of-integers) pattern to generate the entire list of
minutes within these ranges:
```q
q){x[0]+til each x[1]-x[0]}exec minute from r
5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54
24 25 26 27 28
```
We raze these lists together and add the guard number to create a dictionary:
```q
q)`g`m!(g;raze{x[0]+til each x[1]-x[0]}exec minute from r)
g| 10
m| 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 30 31 32 33 34 35 36 37 38 39 40 41 42 4..
```
We call this logic with `each` on all the different guard IDs:
```q
    gm:{[esg;g]
        r:select from esg where gn=g;
        `g`m!(g;raze{x[0]+til each x[1]-x[0]}exec minute from r)
    }[esg]each exec distinct gn from esg;

q)gm
g  m                                                                                              ..
--------------------------------------------------------------------------------------------------..
10 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 30 31 32 33 34 35 36 37 38 39 40 41 42 4..
99 40 41 42 43 44 45 46 47 48 49 36 37 38 39 40 41 42 43 44 45 45 46 47 48 49 50 51 52 53 54      ..
```
This is the return value of the helper function.

## Part 1
We call the helper function to get the guard-and-minutes table:
```q
q)gm:d4prep x
q)gm
g  m                                                                                              ..
--------------------------------------------------------------------------------------------------..
10 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 30 31 32 33 34 35 36 37 38 39 40 41 42 4..
99 40 41 42 43 44 45 46 47 48 49 36 37 38 39 40 41 42 43 44 45 45 46 47 48 49 50 51 52 53 54      ..
```
We find how many minutes each guard spends asleep by counting the minutes column:
```q
q)select g,cm:count each m from gm
g  cm
-----
10 50
99 30
```
We filter the original table to those where this value is maximum, then select the first such row:
```q
q)topg:first select g,m from (update cm:count each m from gm) where cm=max cm
q)topg
g| 10
m| 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 30 31 32 33 34 35 36 37 38 39 40 41 42 4..
```
We use the now-familiar `group` to count how many times each minute occurs:
```q
q)count each group topg[`m]
5 | 1
6 | 1
7 | 1
8 | 1
9 | 1
10| 1
..
```
We find which index the values of the dictionary equal to the maximum value:
```q
q){first where x=max x}count each group topg[`m]
24
```
The answer is this number multiplied by the guard ID:
```q
q)topg[`g]*{first where x=max x}count each group topg[`m]
240
```

## Part 2
We call the helper function to get the guard-and-minutes table:
```q
q)gm:d4prep x
q)gm
g  m                                                                                              ..
--------------------------------------------------------------------------------------------------..
10 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 30 31 32 33 34 35 36 37 38 39 40 41 42 4..
99 40 41 42 43 44 45 46 47 48 49 36 37 38 39 40 41 42 43 44 45 45 46 47 48 49 50 51 52 53 54      ..
```
We find the frequencies of minutes in each row:
```q
q)exec {count each group x}each m from gm
5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 30 31 32 33 34 35 36 37 38 39 40 41 42 43 4..
40 41 42 43 44 45 46 47 48 49 36 37 38 39 50 51 52 53 54!2 2 2 2 2 3 2 2 2 2 1 1 1 1 1 1 1 1 1
```
We find the minute with the maximum frequency within these dictionaries - note that now instead of
just using `where`, we also use `#` (take) on the dictionary, so we have both the key and the value:
```q
q)exec {{(where x=max x)#x}count each group x}each m from gm
(,24)!,2
(,45)!,3
```
We convert the dictionaries into table records by adding column labels:
```q
q)exec{{{`m`f!(key x;value x)}(where x=max x)#x}count each group x}each m from gm
m  f
----
24 2
45 3
```
We horizontally join this table with the `g` column from the original table:
```q
q)(select g from gm),'exec{{{`m`f!(key x;value x)}(where x=max x)#x}count each group x}each m from gm
g  m  f
-------
10 24 2
99 45 3
```
Although not visible in this example, the `m` and `f` columns are actually lists. We flatten the
table using `ungroup`, which would repeat the `g` values for each element in the `m`/`f` lists:
```q
q)gmf:ungroup(select g from gm),'exec{{{`m`f!(key x;value x)}(where x=max x)#x}count each group x}each m from gm
q)gmf
g  m  f
-------
10 24 2
99 45 3
```
To find the answer, we filter to rows where `f` is maximal:
```q
q)select from gmf where f=max f
g  m  f
-------
99 45 3
```
We then multiply the guard ID by the minute number:
```q
q)exec first g*m from gmf where f=max f
4455
```
