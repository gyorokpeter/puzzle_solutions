# Breakdown
Example input:
```q
x:enlist"13 players; last marble is worth 7999 points"
```

## Common
The standard "classical language" solution is to use a linked list, where adding and removing
marbles is a matter of traversing and altering pointers, making linsertion and removal constant in
time. q doesn't have a built-in linked list type, it would only be possible to create a clumsy
simulation with array indices. However, it is still possible to optimize somewhat by processing the
entire array at once, dividing it into chunks where the insertions and removals follow a predictable
pattern.

The helper function `d9common` takes two parameters: the number of players and the value of the last
marble.
```q
q)pl:13
q)lm:7999
```
We initialize the circle to a single 0:
```q
q)circle:enlist 0
```
We initialize a variable for the current marble:
```q
q)curr:0
```
We initialize a variabe for the next marble to place:
```q
q)cm:0
```
We initialize a list of scores:
```q
q)score:pl#0
q)score
0 0 0 0 0 0 0 0 0 0 0 0 0
```
We perform an iteration until we place the last marble:
```q
    while[cm<lm;
        ...
    ];
```
In the iteration, we first increment the marble to place:
```q
q)cm+:1
q)cm
1
```
At the **end** of each iteration, we rotate the circle to ensure that the current marble pointer is
zero:
```q
    circle:curr rotate circle;
    curr:0;
```

We handle three separate cases during the iteration.

### Case 1
(This is actually the last case in the code, since it occurs when the special conditions for the
other two cases aren't met.)

The default case can be demonstrated on marble 5:
```q
q)cm
5
q)curr
0
q)circle
4 2 1 3 0
```
Notice that the current marble pointer moves two positions to the right with each placement. We
first move it by one, wrap it around if necessary, and move it once again. This method of split
movement is necessary because we only want the pointer to wrap around if it is past the valid
indices, but not when it's pointing at the end of the circle.
```q
q)curr:((curr+1)mod count circle)+1
q)curr
2
```
We find how many marbles we can place before hitting a different case. The number of marbles is the
minumum of
- the number of slots left until the end of the circle
```q
q)1+count[circle]-curr
4
```
- the number of marbles left until the next multiple of 23
```q
q)neg[cm]mod 23
18
```
- the number of marbles left to place
```q
q)1+lm-cm
7995
```
We put these three values into a list and take the minimum:
```q
q)toPlace:min (1+count[circle]-curr;neg[cm]mod 23;1+lm-cm)
q)toPlace
4
```
We generate the next state of the circle. We take the initial part until the current position:
```q
q)curr#circle
4 2
```
We intersperse the next `toPlace-1` marbles with the corresponding elements of the circle. Since the
`'` (each) iterator requires lists of equal length, we have to stop short of placing the final
marble such that we have enough elements to pair up:
```q
q)(cm+til[toPlace-1])
5 6 7
q)(toPlace-1)#curr _circle
1 3 0
q)(cm+til[toPlace-1]),'(toPlace-1)#curr _circle
5 1
6 3
7 0
q)raze[(cm+til[toPlace-1]),'(toPlace-1)#curr _circle]
5 1 6 3 7 0
```
We then place the last marble in the sequence and any leftover at the end of the circle (this is
relevant if the length of the circle is not the limiting factor in the `toPlace` calculation):
```q
q)cm+toPlace-1
8
q)(curr+toPlace-1)_circle
`long$()
```
Putting it all together:
```q
q)circle:(curr#circle),raze[(cm+til[toPlace-1]),'(toPlace-1)#curr _circle],(cm+toPlace-1),(curr+toPlace-1)_circle
q)circle
4 2 5 1 6 3 7 0 8
```
We update the current marble position to reflect the `toPlace-1` marbles we haven't accounted for.
Since `toPlace` is bounded by the length of the circle, there is no need to wrap around this time.
```q
q)curr+:(toPlace-1)*2
q)curr
8
```

### Case 2
This case occurs when the next marble to place has an ID divisible by 23:
```q
q)cm
23
q)0=cm mod 23
1b
q)curr
0
q)circle
22 11 1 12 6 13 3 14 7 15 0 16 8 17 4 18 9 19 2 20 10 21 5
```
We update the current marble pointer to point to 7 positions before, wrapping around as necessary:
```q
q)curr:(curr-7)mod count circle
q)curr
16
```
We add the next marble and the marble at the current position to the current player's score:
```q
q)(cm-1) mod pl
9
q)cm+circle[curr]
32
q)score[(cm-1) mod pl]+:cm+circle[curr]
q)score
0 0 0 0 0 0 0 0 0 32 0 0 0
```
We update the circle by removing the marble at the current position:
```q
q)circle _:curr
q)circle
22 11 1 12 6 13 3 14 7 15 0 16 8 17 4 18 19 2 20 10 21 5
```

### Case 3
This case requires a specific set of conditions. It is best to demonstrate when placing marble 70.
```q
q)cm
70
q)curr
0
q)circle
65 30 66 1 67 31 68 12 32 6 33 13 34 3 35 14 36 7 37 15 38 0 39 16 40 8 41 42 4 47 43 48 18 49 44 ..
```
The conditions are:
- there are at least 23 marbles in the circle
```q
q)count circle
64
q)23<=count circle
1b
```
- the next marble ID modulo 23 is 1 (i.e. we are just after a marble was stolen as in case 2)
```q
q)1=cm mod 23
1b
```
- there are more than 23 marbles left to place
```q
q)1+lm-cm
7930
q)(1+lm-cm)>23
1b
```
In this case, we can complete full cycles of 22 placements + 1 steal in a single go. We calculate
the number of cycles by taking the minimum of the circle length and the remaining marbles, in both
cases divided by 23:
```q
q)cycles:min((1+lm-cm);count[circle]) div 23
q)cycles
2
```
We calculate the IDs of the marbles that will get stolen:
```q
q)stealm:(cm-1)+23*1+til cycles
q)stealm
92 115
```
We find the positions of the marbles already in the circle that will get removed:
```q
q)stealpos:19+16*til cycles
q)stealpos
19 35
```
We get the values of those marbles:
```q
q)stealv:circle[stealpos]
q)stealv
15 50
```
We update the scores. The scores to add are `stealm+stealv`, but which elf gets which score is a bit
more complicated to figure out. First, we take the steal positions and modulo them by the number of
players:
```q
q)stealm mod pl
1 11
```
We use `group` which will indicate which player gets which score:
```q
q)group stealm mod pl
1 | 0
11| 1
```
We use this dictionary to index the score list. Since the index is a dictionary, the resulting
object will also be a dictionary with the same keys, and the values will be replaced with the
corresponding values from the score list:
```q
q)(stealm+stealv) group stealm mod pl
1 | 107
11| 165
```
We sum each element in the values, since they are lists:
```q
q)sum each (stealm+stealv) group stealm mod pl
1 | 107
11| 165
```
We index into the dictionary with each player's ID to get that player's score:
```q
q)(sum each (stealm+stealv) group stealm mod pl)[til pl]
0N 107 0N 0N 0N 0N 0N 0N 0N 0N 0N 165 0N
```
We fill in the nulls with zeros:
```q
q)0^(sum each (stealm+stealv) group stealm mod pl)[til pl]
0 107 0 0 0 0 0 0 0 0 0 165 0
```
We add this result to the score:
```q
q)score
0 0 0 0 80 0 63 0 0 32 0 0 0
q)score+:0^(sum each (stealm+stealv) group stealm mod pl)[til pl]
q)score
0 107 0 0 80 0 63 0 0 32 0 165 0
```
We remove the stolen marbles from the circle by cutting on the steal indices. We need to be careful
because `cut` drops the first part of its input unless there is a 0 in the cut indices. We also
prepend a null value to the circle such that after cutting, each part including the first part has
exactly one element to drop.
```q
q)(0,1+stealpos) cut 0N,circle
0N 65 30 66 1 67 31 68 12 32 6 33 13 34 3 35 14 36 7 37
15 38 0 39 16 40 8 41 42 4 47 43 48 18 49 44
50 19 51 45 52 2 53 24 54 20 55 25 56 10 57 26 58 21 59 27 60 5 61 28 62 22 63 29 64
q)1_/:(0,1+stealpos) cut 0N,circle
65 30 66 1 67 31 68 12 32 6 33 13 34 3 35 14 36 7 37
38 0 39 16 40 8 41 42 4 47 43 48 18 49 44
19 51 45 52 2 53 24 54 20 55 25 56 10 57 26 58 21 59 27 60 5 61 28 62 22 63 29 64
q)circle:raze 1_/:(0,1+stealpos) cut 0N,circle
q)circle
65 30 66 1 67 31 68 12 32 6 33 13 34 3 35 14 36 7 37 38 0 39 16 40 8 41 42 4 47 43 48 18 49 44 19 ..
```
We calculate the marbles to be inserted. The numbers here come from looking at what the pattern
looks like over multiple cycles.
```q
q)(enlist each til 6),6+(-3_raze((23*til cycles)+\:(enlist each til 11),enlist[11 12],(17 13 18;19 14 20;21 15 22))),enlist each ((cycles-1)*23)+13+til 3
,0
,1
,2
,3
,4
,5
,6
,7
,8
,9
,10
,11
,12
,13
,14
,15
,16
17 18
23 19 24
25 20 26
27 21 28
,29
..
```
We add the next marble ID to get the actual marbles:
```q
    ins:cm+(enlist each til 6),6+(-3_raze((23*til cycles)+\:(enlist each til 11),enlist[11 12],(17 13 18;19 14 20;21 15 22))),
        enlist each ((cycles-1)*23)+13+til 3;

q)ins
,70
,71
,72
,73
,74
,75
,76
,77
,78
,79
,80
,81
,82
,83
,84
,85
,86
87 88
93 89 94
95 90 96
97 91 98
,99
..
```
We insert the marbles into the circle using a similar technique to case 1:
```q
q)circle:(2#circle),(raze ins,'count[ins]#2_circle),(count[ins]+2)_circle
q)circle
65 30 70 66 71 1 72 67 73 31 74 68 75 12 76 32 77 6 78 33 79 13 80 34 81 3 82 35 83 14 84 36 85 7 ..
```
We update the next marble ID by adding 23 times the number of cycles (minus 1 to compensate for the
overall loop already incrementing it by 1):
```q
q)cm:cm+(cycles*23)-1
q)cm
115
```
We update the current marble position to exactly 37 times the number of cycles:
```q
q)curr:37*cycles
q)curr
74
```

### End of iteration
At the end of the iteration, we have the final scores:
```q
q)score
138335 141778 146287 140403 137866 139700 132353 136253 142223 136559 139327 140652 146373
```
The answer is the maximum of these:
```q
q)max score
146373
```

## Part 1
We cut the input on spaces, take the elements at indices 0 and 6, cast them to integers, and invoke
the common function with these as parameters:
```q
q)"J"$(" "vs first x)0 6
13 7999
q)d9common . "J"$(" "vs first x)0 6
146373
```

## Part 2
Before invoking the common function, we multiply the second number by 100. This is easier to write
with an atomic application of `*` if we also specify that we multiply the first number by 1.
```q
q)1 100*"J"$(" "vs first x)0 6
13 799900
q)d9common . 1 100*"J"$(" "vs first x)0 6
1406506122
```
(There is no example for part 2. This is just the result of applying the part 2 solution to one of
the part 1 examples.)
