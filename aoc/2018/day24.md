# Breakdown
Example input:
```q
x:"Immune System:\n"
x,:"17 units each with 5390 hit points (weak to radiation, bludgeoning) with"
x,:" an attack that does 4507 fire damage at initiative 2\n"
x,:"989 units each with 1274 hit points (immune to fire; weak to bludgeoning,"
x,:" slashing) with an attack that does 25 slashing damage at initiative 3\n"
x,:"\n"
x,:"Infection:\n"
x,:"801 units each with 4706 hit points (weak to radiation) with an attack"
x,:" that does 116 bludgeoning damage at initiative 1\n"
x,:"4485 units each with 2961 hit points (immune to radiation; weak to fire"
x,:" cold) with an attack that does 12 slashing damage at initiative 4"
x:"\n"vs x
```
Note that the odd formatting of the example must be accounted for, therefore the building up of the
string with embedded newlines and then breaking it up afterwards.

## Common
### Input parsing
We find the line that is the splitting point between the two factions:
```q
q)split:first where 0=count each x
q)split
3
```
We split the input lines to a list with one element per faction:
```q
q)armyraw:(1_split#x;(2+split)_x)
q)armyraw
"17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507..
"801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning ..
```
We convert the army descriptions into a table. For example, for the first line of the first faction:
```q
q)a0:first first armyraw
q)a0
"17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507..
```
We split the line on spaces:
```q
q)" "vs a0
"17"
"units"
"each"
"with"
"5390"
"hit"
..
```
We extract the useful parts by indexing into this list. The size and HP are found at indices 0 and
4, and the damage value, type and initiative are at indices 6, 5 and 1 from the back of the list:
```q
q){x[0 4,count[x]-6 5 1]}" "vs a0
"17"
"5390"
"4507"
"fire"
,"2"
```
We cast the numbers to long and the damage type to symbol:
```q
q)"JJJSJ"${x[0 4,count[x]-6 5 1]}" "vs a0
17
5390
4507
`fire
2
```
We add some appropriate dictionary keys:
```q
q)`size`hp`damage`dtype`initiative!"JJJSJ"${x[0 4,count[x]-6 5 1]}" "vs a0
size      | 17
hp        | 5390
damage    | 4507
dtype     | `fire
initiative| 2
```
For the weaknesses and immuinities, we split out the part between parentheses:
```q
q)first")"vs("("vs a0)1
"weak to radiation, bludgeoning"
```
We split this on `"; "` if present, then split on spaces:
```q
q)" "vs/:"; "vs first")"vs("("vs a0)1
"weak" "to" "radiation," "bludgeoning"
```
We parse each of the sections in turn. For the first section:
```q
q)a1:first" "vs/:"; "vs first")"vs("("vs a0)1
q)a1
"weak"
"to"
"radiation,"
"bludgeoning"
```
We drop the first two elements and remove any commas:
```q
q)2_a1
"radiation,"
"bludgeoning"
q)(2_a1)except\:","
"radiation"
"bludgeoning"
```
We convert this to symbol, and make it the single element of a dictionary, with the key being the
symbolified first element of the list (which will be either `weak` or `immune`):
```q
q)enlist[`$a1 0]!enlist`$(2_a1)except\:","
weak| radiation bludgeoning
```
We extend this using iterators to cover all of the weakness/immunity lists:
```q
q){` _ (`$x[;0])!`$(2_/:x)except\:\:","}" "vs/:"; "vs first")"vs("("vs a0)1
weak| radiation bludgeoning
```
As in this case, one of the entries may be missing, so we fill it in with a default value:
```q
q)(`weak`immune!`$(();())),{` _ (`$x[;0])!`$(2_/:x)except\:\:","}" "vs/:"; "vs first")"vs("("vs a0)1
weak  | `radiation`bludgeoning
immune| `symbol$()
```
We join the two dictionaries together. We apply the logic in a function and iterate it over the full
army:
```q
    a:{[a0](`size`hp`damage`dtype`initiative!"JJJSJ"${x[0 4,count[x]-6 5 1]}" "vs a0),
        (`weak`immune!`$(();())),
        {` _ (`$x[;0])!`$(2_/:x)except\:\:","}" "vs/:"; "vs first")"vs("("vs a0)1}each/:armyraw;

q)a
+`size`hp`damage`dtype`initiative`weak`immune!(17 989;5390 1274;4507 25;`fire`slashing;2 3;(`radia..
+`size`hp`damage`dtype`initiative`weak`immune!(801 4485;4706 2961;116 12;`bludgeoning`slashing;1 4..
```
We also need the name of the faction for each army. To find these, we look at the first line and the
first line after the split, remove any colons and spaces, and convert them to symbols:
```q
q)x[0,1+split]
"Immune System:"
"Infection:"
q)`$x[0,1+split]except\:" :"
`ImmuneSystem`Infection
q)([]faction:`$x[0,1+split]except\:" :")
faction
------------
ImmuneSystem
Infection
```
We append these to the respective rows of the armies' tables, then raze them into a single table:
```q
q)([]faction:`$x[0,1+split]except\:" :"),/:'a
+`faction`size`hp`damage`dtype`initiative`weak`immune!(`ImmuneSystem`ImmuneSystem;17 989;5390 1274..
+`faction`size`hp`damage`dtype`initiative`weak`immune!(`Infection`Infection;801 4485;4706 2961;116..
q)army:raze([]faction:`$x[0,1+split]except\:" :"),/:'a
q)army
faction      size hp   damage dtype       initiative weak                   immune
---------------------------------------------------------------------------------------
ImmuneSystem 17   5390 4507   fire        2          `radiation`bludgeoning `symbol$()
ImmuneSystem 989  1274 25     slashing    3          `bludgeoning`slashing  ,`fire
Infection    801  4706 116    bludgeoning 1          ,`radiation            `symbol$()
Infection    4485 2961 12     slashing    4          `fire`cold             ,`radiation
```

### Battle simulation
The function `d24common` takes the `army` table from the parse function and the `boost` which is the
power boost for part 2 and zero for part 1.
```q
q)boost:0
```
We start by applying the boost to the army:
```q
q)army:update damage:damage+boost from army where faction=`ImmuneSystem
q)army
faction      size hp   damage dtype       initiative weak                   immune
---------------------------------------------------------------------------------------
ImmuneSystem 17   5390 4507   fire        2          `radiation`bludgeoning `symbol$()
ImmuneSystem 989  1274 25     slashing    3          `bludgeoning`slashing  ,`fire
Infection    801  4706 116    bludgeoning 1          ,`radiation            `symbol$()
Infection    4485 2961 12     slashing    4          `fire`cold             ,`radiation
```
We do an iteration as long as there are two different factions in the table:
```q
    while[1<count exec distinct faction from army;
        ...
    ];
```
We sort the army by power and initiative, and add a power column that is the product of the group
size and damage. Since we need to restore the original order later, we also add a column `j` based
on `i` (the implicit row index). We also keep a copy of the initial state of the army in another
variable.
```q
q)prevArmy:army:update j:i from `power`initiative xdesc update power:size*damage from army
q)army
faction      size hp   damage dtype       initiative weak                   immune      power j
-----------------------------------------------------------------------------------------------
Infection    801  4706 116    bludgeoning 1          ,`radiation            `symbol$()  92916 0
ImmuneSystem 17   5390 4507   fire        2          `radiation`bludgeoning `symbol$()  76619 1
Infection    4485 2961 12     slashing    4          `fire`cold             ,`radiation 53820 2
ImmuneSystem 989  1274 25     slashing    3          `bludgeoning`slashing  ,`fire      24725 3
```
We do a sub-iteration to calculate the target selections. We initialize a counter to zero and a
table of targets to empty:
```q
q)nxt:0
q)targetSel:([]s:`long$();t:`long$();initiative:`long$())
```
We iterate until the counter reaches the size of the army:
```q
    while[nxt<count army;
        ...
        nxt+:1;
    ];
```
In the sub-iteration, we get the attack type of the current group:
```q
q)attackType:army[nxt;`dtype]
q)attackType
`bludgeoning
```
We figure out the potential targets for the group by filtering the army table to those where the
faction is not the current group's faction and the group hasn't been selected as a target yet. We
calculate the effective power based on the weakness/immunity. We sort the targets in descending
order based on the effective power, target power and initiative.
```q
    targets:`epower`power`initiative xdesc select initiative,j,power,epower:?[attackType in/:immune;0;?[attackType in/:weak;2;1]]*army[nxt;`power] from army
        where faction<>army[nxt;`faction],not j in exec t from targetSel;

q)targets
initiative j power epower
-------------------------
2          1 76619 185832
3          3 24725 185832
```
We check if any targets are valid and if the effecive power against the first target is greater than
zero. If so, we add the target to the targets table.
```q
    if[0<count targets;
        if[0<exec first epower from targets;
            targetSel,:`s`t`initiative!nxt,first[targets][`j],army[nxt;`initiative];
        ];
    ];

q)targetSel
s t initiative
--------------
0 1 1
```
The code for the sub-iteration ends here. After the sub-iteration, we have the full target selection
table:
```q
q)targetSel
s t initiative
--------------
0 1 1
1 2 2
2 3 4
3 0 3
```
We do another sub-iteration. We initialize a counter to zero and put the target selection table in
decreasing order of initiative:
```q
q)targetSel:`initiative xdesc targetSel
q)targetSel
s t initiative
--------------
2 3 4
3 0 3
1 2 2
0 1 1
```
We iterate until the counter reaches the end of the table:
```q
    while[nxt<count targetSel;
        ...
        nxt+:1;
    ];
```
In the sub-iteration, we extract the current target selection:
```q
q)ts:targetSel[nxt]
q)ts
s         | 2
t         | 3
initiative| 4
```
We check if the size of both the attacking and defending army is greater than zero:
```q
q)army[ts`s;`size]
4485
q)army[ts`t;`size]
989

    if[(0<army[ts`s;`size]) and 0<army[ts`t;`size];
        ...
    ];
```
If it is, we first get the attack type:
```q
q)attackType:army[ts`s;`dtype]
q)attackType
`slashing
```
We recalculate the effective power of the attack:
```q
q)epower:army[ts`s;`damage]*army[ts`s;`size]*$[attackType in army[ts`t;`immune];0;$[attackType in army[ts`t;`weak];2;1]]
q)epower
107640
```
We reduce the target army's size based on the damage, but capping it at zero:
```q
q)army[ts`t;`size]:0|army[ts`t;`size]-epower div army[ts`t;`hp]
q)army[ts`t;`size]
905
```
This is the end of the code of the second sub-iteration. At the end of the sub-iteration, we have
the updated army table after one round of combat:
```q
q)army
faction      size hp   damage dtype       initiative weak                   immune      power j
-----------------------------------------------------------------------------------------------
Infection    797  4706 116    bludgeoning 1          ,`radiation            `symbol$()  92916 0
ImmuneSystem 0    5390 4507   fire        2          `radiation`bludgeoning `symbol$()  76619 1
Infection    4434 2961 12     slashing    4          `fire`cold             ,`radiation 53820 2
ImmuneSystem 905  1274 25     slashing    3          `bludgeoning`slashing  ,`fire      24725 3
```
We filter out the eliminated groups:
```q
q)army:select from army where size>0
q)army
faction      size hp   damage dtype       initiative weak                  immune      power j
----------------------------------------------------------------------------------------------
Infection    797  4706 116    bludgeoning 1          ,`radiation           `symbol$()  92916 0
Infection    4434 2961 12     slashing    4          `fire`cold            ,`radiation 53820 2
ImmuneSystem 905  1274 25     slashing    3          `bludgeoning`slashing ,`fire      24725 3
```
The code for the main iteration ends here. At the end of the iteration, we have the final state of
the army:
```q
q)army
faction   size hp   damage dtype       initiative weak        immune      power j
---------------------------------------------------------------------------------
Infection 782  4706 116    bludgeoning 1          ,`radiation `symbol$()  90712 0
Infection 4434 2961 12     slashing    4          `fire`cold  ,`radiation 53208 1
```
We return a two-element list, with the first element indicating whether the immune system won, and
the second element being the sum of the group sizes:
```q
q)(`ImmuneSystem=first exec faction from army;exec sum size from army)
0b
5216
```

## Part 1
We call the common function on the parsed input and return the second element of the result:
```q
q)last d24common[0;d24parse x]
5216
```

## Part 2
We call the common function in a loop with an ever increasing value for the boost until the immune
system wins:
```q
    army:d24parse x;
    boost:0;
    while[not first res:d24common[boost;army];
        boost+:1;
    ];
```
At the end of the iteration, the result contains the answer in the second element:
```q
q)last res
51
```
