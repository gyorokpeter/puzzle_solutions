# Breakdown
Example input:
```q
x:()
x,:enlist"#######"
x,:enlist"#.G...#"
x,:enlist"#...EG#"
x,:enlist"#.#.#G#"
x,:enlist"#..G#E#"
x,:enlist"#.....#"
x,:enlist"#######"
```

## Common
The solution is a straightforward simulation, it is not really that complex, only verbose due to the
many small details that need to be implemented. The many small examples for the individual behaviors
and the detailed breakdown of the first example are helpful for testing the code.

The common function (`d15combat`) resolves the entire combat and takes the map and the elves' AP as
parameters:
```q
q)map:x
q)elfAp:3
```
We extract the unit positions by doing a [2D search](../utils/patterns.md#2d-search) for the letters
`E` and `G`:
```q
q)unitPos:raze til[count map],/:'where each map in "EG"
q)unitPos
1 2
2 4
2 5
3 5
4 3
4 5
```
We fetch the corresponding unit types by indexing the map:
```q
q)unitType:map ./:unitPos
q)unitType
"GEGGGE"
```
We create a table for the units, adding the HP and AP (with a vector conditional to choose between
the two possible values):
```q
q)units:([]unitType;pos:unitPos;hp:200;ap:?[unitType="E";elfAp;3])
q)units
unitType pos hp  ap
-------------------
G        1 2 200 3
E        2 4 200 3
G        2 5 200 3
G        3 5 200 3
G        4 3 200 3
E        4 5 200 3
```
We store the number of elves, which is only used in part 2 to determine if there were any elf
casualties:
```q
q)elfCount:sum unitType="E"
q)elfCount
2i
```
We generate a blank version of the map by replacing the units with empty space:
```q
q)blankMap:("#.GE"!"#...")map
q)blankMap
"#######"
"#.....#"
"#.....#"
"#.#.#.#"
"#...#.#"
"#.....#"
"#######"
```
We initialize the turn counter to zero and the continuation flag to true:
```q
q)turns:0
q)cont:1b
```
We perform an iteration while the continuation flag is true:
```q
    while[cont;
        ...
    ];
```
In the iteration, we call the helper function that simulates a single turn (see below):
```q
q)res:d15turn[blankMap;units]
q)res
+`unitType`pos`hp`ap!("GEGGGE";`s#(1 3;2 4;2 5;3 3;3 5;4 5);200 197 197 200 197 197;3 3 3 3 3 3)
1b
```
We extract the two components into the respective variables:
```q
q)units:res 0
q)cont:res 1
```
If we need to continue, we update the turn counter:
```q
    if[cont;
        turns+:1;
    ];
```
The code for the iteration ends here.

At the end, we have the final state of the units:
```q
q)units
unitType pos hp  ap
-------------------
G        1 1 200 3
G        2 2 131 3
G        3 5 59  3
G        5 5 200 3
```
We determine whether any elves were killed by comparing the number of elves in the units table to
the value cached before the iteration:
```q
q)sum"E"=units`unitType
0i
q)elfCount=sum"E"=units`unitType
0b
```
We also calculate the outcome score by multiplying the sum of unit HPs by the turn counter:
```q
q)turns
47
q)exec sum hp from units
590
q)turns*exec sum hp from units
27730
```
The return value is a tuple containing these two values:
```q
q)(elfCount=sum"E"=units`unitType;turns*exec sum hp from units)
0b
27730
```

### d15turn
This helper function simulates a single turn of combat (for all units on the map). It takes the
blank map calculated in `d15combat` and the current unit table. It returns a tuple containing the
updated units table and a boolean flag indicating whether to continue combat.
```q
q)map:("#######";"#.....#";"#.....#";"#.#.#.#";"#...#.#";"#.....#";"#######")
q)units:([]unitType:"GEGGGE";pos:(1 2;2 4;2 5;3 5;4 3;4 5);hp:200 200 200 200 200 200;ap:3 3 3 3 3 3)
```
We initialize the current unit index to 0:
```q
q)unit:0
```
We perform an iteration until the unit index exceeds the unit count, incrementing the counter at the
end:
```q
    while[unit<count units;
        ...
        unit+:1;
    ];
```
We assume that the units in the table are in reading order.

In the iteration, we first check if the combat needs to continue by checking the number of distinct
elements in the `unitType` column. If there is only one type of unit in the table, that means the
other kind of units have all been defeated, so combat ends:
```q
    if[2>count exec distinct unitType from units; :(units;0b)];
```
We extract the properties of the current unit:
```q
q)ac:units[unit]
q)ac
unitType| "G"
pos     | 1 2
hp      | 200
ap      | 3
```
We look for targets by checking for units whose position only differs by one from the current unit,
and the type is not the same:
```q
q)targets:select from (update j:i from units) where 1=sum each abs pos-\:ac[`pos], unitType<>ac`unitType
q)targets
unitType pos hp ap j
--------------------
```
If there are no targets, the unit has to move:
```q
    if[0=count targets;
        ...
    ];
```
To move, we determine the shortest paths via BFS. The queue nodes will contain the whole path, not
just the current position. We initialize the queue to a path containing only the unit's current
position, the visited array to empty and the found flag to false:
```q
q)queue:enlist enlist ac`pos
q)queue
1 2
q)visited:()
q)found:0b
```
We iterate until either we find a target or the queue is empty (the latter means no target):
```q
    while[not[found] and 0<count queue;
        ...
    ];
```
In the iteration, we add the ends of the paths in the queue to the visited array:
```q
q)visited,:last each queue
q)visited
1 2
```
We generate the next positions for each path in the queue by adding the deltas for the four main
directions, but excluding positions in the visited array and those occupied by units:
```q
q)nxts:((last each queue)+/:\:(1 0;-1 0;0 1;0 -1))except\:visited,exec pos from units
q)nxts
2 2 0 2 1 3 1 1
```
We filter the positions to those with no wall on the map:
```q
q)nxts:nxts @' where each "#"<>map ./:/:nxts
q)nxts
2 2 1 3 1 1
```
We merge the next positions with the paths to generate the full next paths:
```q
q)nxtp:raze queue,/:'enlist each/:nxts
q)nxtp
1 2 2 2
1 2 1 3
1 2 1 1
```
We deduplicate and reorder the paths such that those with the last position earliest in
lexicographic order come at the top:
```q
q)([]path:nxtp)
path
-------
1 2 2 2
1 2 1 3
1 2 1 1
q)update lp:last each path from ([]path:nxtp)
path    lp
-----------
1 2 2 2 2 2
1 2 1 3 1 3
1 2 1 1 1 1
q)select first asc path by lp from update lp:last each path from ([]path:nxtp)
lp | path
---| -------
1 1| 1 2 1 1
1 3| 1 2 1 3
2 2| 1 2 2 2
q)nxtp:exec path from select first asc path by lp from update lp:last each path from ([]path:nxtp)
q)nxtp
1 2 1 1
1 2 1 3
1 2 2 2
```
We check if there are any units in range of any of the paths, using a similar calculation to that
for finding targets:
```q
q)arrive:select from (update reach:(where each 1=sum each/:abs pos-/:\:last each nxtp) from units) where i<>unit, unitType<>ac`unitType, 0<count each reach
q)arrive
unitType pos hp ap reach
------------------------
```
If there are any units in range, we do special processing:
```q
    if[0<count arrive;
        ...
    ];
```
Otherwise, we replace the queue with the next paths:
```q
q)queue:nxtp
q)queue
1 2 1 1
1 2 1 3
1 2 2 2
```
The special processing when finding a target can be demonstrated in a later state:
```q
q)queue
1 2 1 1
1 2 1 3
1 2 2 2
q)nxtp
1 2 1 3 1 4
1 2 1 1 2 1
1 2 1 3 2 3
q)arrive
unitType pos hp  ap reach
-------------------------
E        2 4 200 3  0 2
```
We set the found flag to true:
```q
q)found:1b
```
We extract the paths that reach the target:
```q
q)finps:nxtp distinct raze exec reach from arrive
q)finps
1 2 1 3 1 4
1 2 1 3 2 3
```
We only keep the path that is lexicographically first:
```q
q)finp:finps(iasc last each finps)?0
q)finp
1 2
1 3
1 4
```
After the BFS iteration, we perform special processing if there are any targets:
```q
    if[found;
        ...
    ];
```
In particular, we update the current unit's position to the first step on the path towards the
target:
```q
q)ac
unitType| "G"
pos     | 1 2
hp      | 200
ap      | 3
q)ac[`pos]:finp[1]
q)ac
unitType| "G"
pos     | 1 3
hp      | 200
ap      | 3
```
We perform the same change in the units table:
```q
q)units[unit;`pos]:finp[1]
q)units
unitType pos hp  ap
-------------------
G        1 3 200 3
E        2 4 200 3
G        2 5 200 3
G        3 5 200 3
G        4 3 200 3
E        4 5 200 3
```
We re-calculate the targets table with the unit's new position:
```q
q)targets:select from (update j:i from units) where 1=sum each abs pos-\:ac[`pos], unitType<>ac`unitType
q)targets
unitType pos hp ap j
--------------------
```
The next section is demonstrated in a later state, when a unit actually finds a target to attack.
```q
q)unit
1
q)targets
unitType pos hp  ap j
---------------------
G        2 5 200 3  2
```
We select the target(s) with the lowest HP, and keep only the first by lexicographic order on the
position:
```q
q)targetId:exec j iasc[pos]?0 from select from targets where hp=min hp
q)targetId
2
```
We reduce the target's HP by the attacker's AP:
```q
q)units[targetId;`hp]-:units[unit;`ap]
q)units
unitType pos hp  ap
-------------------
G        1 3 200 3
E        2 4 200 3
G        2 5 197 3
G        3 5 200 3
G        4 3 200 3
E        4 5 200 3
```
We check if the target has 0 or less HP:
```q
    if[units[targetId;`hp]<=0;
        ...
    ];
```
If it does, we delete it from the table:
```q
    units:delete from units where i=targetId
```
We also check if the deleted unit's ID is lower than that of the current unit, in which case the
increment of the unit index would skip a unit in the table. We compensate by decrementing the unit
index.
```q
    if[targetId<unit; unit-:1]
```
After the iteration, we reorder the units table by position to maintain the lexicographic order for
the nex invocation:
```q
q)units:`pos xasc units
q)units
unitType pos hp  ap
-------------------
G        1 3 200 3
E        2 4 200 3
G        2 5 197 3
G        3 5 200 3
G        4 3 200 3
E        4 5 200 3
```
The normal return value is the units table plus a true flag to indicate that combat should continue:
```q
    (units;1b)
```

### d15showMap
This helper function displays the map with HP indicators in the same format as the one used in the
examples:
```q
    d15showMap:{[blankMap;units]
        blankMap1:{.[x;y`pos;:;y`unitType]}/[blankMap;units];
        hpDisplays:{[x;y]{$[0<count x;3#" ";""],x}exec ", "sv(unitType,'"(",/:string[hp],\:")") from x where pos[;0]=y}[units]each til count blankMap1;
        -1 blankMap1,'hpDisplays;
    };

q)map
"#######"
"#.....#"
"#.....#"
"#.#.#.#"
"#...#.#"
"#.....#"
"#######"
q)units
unitType pos hp  ap
-------------------
G        1 3 200 3
E        2 4 200 3
G        2 5 197 3
G        3 5 200 3
G        4 3 200 3
E        4 5 200 3
q)d15showMap[map;units]
#######
#..G..#   G(200)
#...EG#   E(200), G(197)
#.#.#G#   G(200)
#..G#E#   G(200), E(200)
#.....#
#######
```

## Part 1
We call the combat simulation with the elf AP of 3 and return the last element:
```q
q)last d15combat[x;3]
...
final state:
#######
#G....#   G(200)
#.G...#   G(131)
#.#.#G#   G(59)
#...#.#
#....G#   G(200)
#######
27730
```

## Part 2
We initialize the elf AP to 1, try to simulate the combat, and check the first element for whether
there were any elf casualties. If there were, we increment the elf AP and try again.
```q
q)elfAp:1
q)while[not first res:d15combat[x;elfAp]; elfAp+:1]
...
final state:
#######
#..E..#   E(158)
#...E.#   E(14)
#.#.#.#
#...#.#
#.....#
#######
q)res
1b
4988
```
We return both the elf AP and the resulting score. The elf AP is not part of the answer but it is
useful to cross-check with the examples.
```q
q)(elfAp;last res)
15 4988
```
An important note about part 2: while it may be tempting to try a binary search for the correct elf
AP, it is not a valid solution because the combat outcome is not "linear" or "monotonic", so it is
possible to miss a scenario with no elf casualties by increasing the elf AP too much. So the only
valid option is to try each value one by one.
