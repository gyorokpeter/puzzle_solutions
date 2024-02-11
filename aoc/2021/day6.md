# Breakdown
Example input:
```q
x:"3,4,3,1,2"
```

## Common
The trick is to not store each individual lanternfish but only their timers. The presence of the
word "exponential" in the description hints at this. I chose to use a table for easier processing.
So the only difference between the two parts is the number of days, which I pass in as a parameter
to the common function.

The input parsing splits on comma and casts to integers.
```q
q)a:"J"$","vs x;
q)a
3 4 3 1 2
```
We group the numbers and put them into the table. The lambda is only there to avoid repetition or
introducing another variable.
```q
q)count each group a
3| 2
4| 1
1| 1
2| 1
q)t:{([timer:key x]cnt:value x)}count each group a
q)t
timer| cnt
-----| ---
3    | 2
4    | 1
1    | 1
2    | 1
```
The next section will be iterated according to the number of days. It is enough to use a "do" loop
here.

A more interesting scenario occurs on the second day where the actual breeding starts:
```q
q)t
timer| cnt
-----| ---
2    | 2
3    | 1
0    | 1
1    | 1
```
We first select the rows corresponding to the lanternfish that will breed:
```q
q)breed:select from t where timer=0;
q)breed
timer| cnt
-----| ---
0    | 1
```
And similarly the ones that won't:
```q
q)notBreed
timer| cnt
-----| ---
2    | 2
3    | 1
1    | 1
```
The next generation will consist of three parts:
1. the non-breeding lanternfish with their timer reduced by 1:
```q
q)t1:update timer-1 from notBreed
q)t1
timer| cnt
-----| ---
1    | 2
2    | 1
0    | 1
...
q)count each group hp,vp
0 9| 2
1 9| 2
2 9| 2
3 9| 1
```
2. the breeding lanternfish with their timer reset to 6:
```q
q)t2:update timer:count[i]#6 from breed;
q)t2
timer| cnt
-----| ---
6    | 1
```
3. the new lanternfish from breeding with a timer of 8:
```q
q)t3:update timer:count[i]#8 from breed;
q)t3
timer| cnt
-----| ---
8    | 1
```
Since atomic operators are so powerful, we can simply add the 3 tables together:
```q
q)t:t1+t2+t3
q)t
timer| cnt
-----| ---
1    | 2
2    | 1
0    | 1
6    | 1
8    | 1
```
At the end of the iteraton, all we need is to sum the counts.
```q
q)t
timer| cnt
-----| ---
0    | 424
1    | 729
2    | 558
...
q)exec sum cnt from t
5934
```
