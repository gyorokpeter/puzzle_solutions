# Breakdown
Example input:
```q
q)md5 raze x
0x73803403d4fd0b170bca41d035232e49
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Normal solution
This is a generic solution that should work on any input. First we build a map using BFS, this time
storing the intcode VM state inside the queue nodes. This makes it easier to branch out without
backtracking. Then we do another run to collect all items (there is an ignore list of items that
cause a crash or an infinite loop (the latter item is literally called that)). To make the last step
easy, we collect each item and drop them at the security checkpoint. The last step consists of
trying to figure out the exact combination of items we need to hold to pass. There are 8 items so
256 possible combinations. These are tried one by one, and the input is checked to see if there is
an alert message. The only output without an alert is the goal. We parse the password from this
message.

### Main function
We initialize the intcode interpreter:
```q
q)a:.intcode.new x
```
We call the helper funcion that builds the map:
```q
q)rl:.d25.buildMap a
q)rooms:rl 0
q)links:rl 1
q)rooms
roomName                | doors             items
------------------------| ---------------------------------
Hull Breach             | `north`east`south `symbol$()
Corridor                | `north`east`south ,`spool of cat6
Stables                 | ,`north           ,`fixed point
Storage                 | `east`west        `symbol$()
..
q)links
roomFrom             dir  | roomTo
--------------------------| --------------------
Hull Breach          north| Corridor
Hull Breach          east | Storage
Hull Breach          south| Stables
Corridor             north| Observatory
Corridor             east | Gift Wrapping Center
Corridor             south| Hull Breach
..
```
We find all items in the rooms:
```q
q)allItems:string asc exec raze items from rooms
q)allItems
"candy cane"
"easter egg"
"fixed point"
"hypercube"
"monolith"
"ornament"
"planetoid"
"spool of cat6"
```
We call the helper function to generate the commands to get to the security room with all items:
```q
q)cmds:.d25.getCmds[rooms;links];
q)cmds
"south"
"take fixed point"
"north"
"north"
"take spool of cat6"
..
q)-10#cmds
"west"
"south"
"drop candy cane"
"drop easter egg"
"drop fixed point"
"drop hypercube"
"drop monolith"
"drop ornament"
"drop planetoid"
"drop spool of cat6"
```
We convert the commands into intcode input:
```q
q)cmdIn:`long$raze cmds,\:"\n"
q)cmdIn
115 111 117 116 104 10 116 97 107 101 32 102 105 120 101 100 32 112 111 105 110 116 10 110 111 114..
```
We run the VM with the input:
```q
q)st:.intcode.runI[a;cmdIn]
```
We find what direction to go to test the sensor:
```q
q)tryDir:exec first dir from links where roomFrom=`$"Security Checkpoint", roomTo=`$"Pressure-Sensitive Floor"
q)tryDir
`west
```
We call the helper function to get which items are needed to pass (this runs for the longest time):
```q
q)itemsToPass:.d25.getItemsToPass[st;allItems;tryDir]
q)itemsToPass
"easter egg"
"hypercube"
"monolith"
"ornament"
```
We generate another command input to pick up only the items needed to pass:
```q
q)cmdIn2:`long$("\n"sv ("take ",/:itemsToPass),enlist string[tryDir]),"\n"
q)cmdIn2
116 97 107 101 32 101 97 115 116 101 114 32 101 103 103 10 116 97 107 101 32 104 121 112 101 114 9..
```
We run the interpreter again with this input, and retrieve the output:
```q
q)st2:.intcode.getOutput .intcode.runI[st;cmdIn2]
q)st2
10 89 111 117 32 116 97 107 101 32 116 104 101 32 101 97 115 116 101 114 32 101 103 103 46 10 10 6..
```
We convert the output into a string and cut on the surrounding text to find the password:
```q
q)password:"J"$first" on the keypad" vs last"get in by typing " vs `char$st2
q)password
1073815584
```

### .d25.buildMap
This function builds the map of the station. It takes the intcode VM state and returns a pair of
the rooms and links tables.

We start by running the intcode VM until it blocks:
```q
q)a1:.intcode.run a
```
We extract the produced output:
```q
q)out:`char$last a1
q)out
"\n\n\n== Hull Breach ==\nYou got in through a hole in the floor here. To keep your ship from also..
```
We create the initial rooms table by parsing the output and appending the entire VM state as one of
the table columns:
```q
q).d25.parseOutput[out]
roomName| `Hull Breach
doors   | `north`east`south
items   | `symbol$()
q)rooms:1!enlist .d25.parseOutput[out],enlist[`state]!enlist a1
q)rooms
roomName   | doors            items state                                                         ..
-----------| -------------------------------------------------------------------------------------..
Hull Breach| north east south       `needInput 2663 0 4811 109 4804 21101 3124 0 1 21102 13 1 0 11..
```
We initialize the links table to be empty:
```q
q)links:([roomFrom:`$();dir:`$()]roomTo:`$())
q)links
roomFrom dir| roomTo
------------| ------
```
We create the initial queue from all the outgoing links from the starting room:
```q
q)missing:ungroup select roomFrom:roomName, dir:doors from rooms
q)missing
roomFrom    dir
-----------------
Hull Breach north
Hull Breach east
Hull Breach south
```
We iterate as long as there are missing links:
```q
    while[0<count missing;
        ...
    ];
```
We run the intcode VM for each entry in the queue, inputting the respective direction:
```q
q)sts:exec .intcode.runI'[rooms[([]roomName:roomFrom);`state];`long$(string[dir],\:"\n")]from missing
q)sts
`needInput 2663 6 4811 109 4804 21101 3124 0 1 21102 13 1 0 1105 1 1424 21102 1 166 1 21102 24 1 0..
`needInput 2663 5 4811 109 4804 21101 3124 0 1 21102 13 1 0 1105 1 1424 21102 1 166 1 21102 24 1 0..
`needInput 2663 6 4811 109 4804 21101 3124 0 1 21102 13 1 0 1105 1 1424 21102 1 166 1 21102 24 1 0..
```
We use the helper function to parse the outputs from each run:
```q
q)outs:.d25.parseOutput each `char$last each sts
q)outs
roomName doors             items
------------------------------------------
Corridor `north`east`south ,`spool of cat6
Storage  `east`west        `symbol$()
Stables  ,`north           ,`fixed point
```
We add the newly found links to the table:
```q
q)links,:missing!select roomTo:roomName from outs
q)links
roomFrom    dir  | roomTo
-----------------| --------
Hull Breach north| Corridor
Hull Breach east | Storage
Hull Breach south| Stables
```
We find the new rooms which don't yet appear in the rooms table:
```q
q)newRooms:select from (update state:sts from outs) where not roomName in exec roomName from rooms
q)newRooms
roomName doors             items           state                                                  ..
--------------------------------------------------------------------------------------------------..
Corridor `north`east`south ,`spool of cat6 `needInput 2663 6 4811 109 4804 21101 3124 0 1 21102 13..
Storage  `east`west        `symbol$()      `needInput 2663 5 4811 109 4804 21101 3124 0 1 21102 13..
Stables  ,`north           ,`fixed point   `needInput 2663 6 4811 109 4804 21101 3124 0 1 21102 13..
```
We add the info about the new rooms to the table, deduplicating if necessary:
```q
q)rooms,:select last doors, last items, last state by roomName from newRooms where not null roomName
q)rooms
roomName   | doors             items           state                                              ..
-----------| -------------------------------------------------------------------------------------..
Hull Breach| `north`east`south `symbol$()      `needInput 2663 0 4811 109 4804 21101 3124 0 1 2110..
Corridor   | `north`east`south ,`spool of cat6 `needInput 2663 6 4811 109 4804 21101 3124 0 1 2110..
Stables    | ,`north           ,`fixed point   `needInput 2663 6 4811 109 4804 21101 3124 0 1 2110..
Storage    | `east`west        `symbol$()      `needInput 2663 5 4811 109 4804 21101 3124 0 1 2110..
```
We find the new queue by checking for room-direction pairs that don't yet appear in the links table:
```q
q)missing:(ungroup select roomFrom:roomName, dir:doors from rooms) except key links
q)missing
roomFrom dir
--------------
Corridor north
Corridor east
Corridor south
Stables  north
Storage  east
Storage  west
```
This is the end of the iteration code.

At the end of the iteration, we have the info on all the rooms and the links between them. However,
the `items` column also contains some dangerous items that need to be removed. The list of dangerous
items is defined as a global variable:
```q
    .d25.dangerousItems:`$(
        "infinite loop";
        "giant electromagnet";
        "photons";
        "escape pod";
        "molten lava"
        );
```
We remove these from the rooms table:
```q
q)rooms:update items:items except\:.d25.dangerousItems from rooms
```
We return the rooms and links as a pair. We no longer need the state for the rooms, so we remove
that column.
```q
q)(delete state from rooms;links)
(+(,`roomName)!,`Hull Breach`Corridor`Stables`Storage`Crew Quarters`Gift Wrapping Center`Observato..
(+`roomFrom`dir!(`Hull Breach`Hull Breach`Hull Breach`Corridor`Corridor`Corridor`Stables`Storage`S..
```

### .d25.parseOutput
This function parses the output that is printed after entering a room, and finds the room name,
items and doors.
```q
q)out
"\n\n\n== Hull Breach ==\nYou got in through a hole in the floor here. To keep your ship from also..
```
We split the string into lines:
```q
q)outs:"\n"vs out
q)outs
""
""
""
"== Hull Breach =="
"You got in through a hole in the floor here. To keep your ship from also freezing, the hole has b..
""
"Doors here lead:"
"- north"
"- east"
"- south"
""
"Command?"
""
```
We find which line contains the room name by looking for the equal signs:
```q
q)roomIdx:where outs like "==*=="
q)roomIdx
,3
```
We fetch the found line and drop the first and last 3 characters:
```q
q)roomName:$[0<count roomIdx; `$3_-3_outs[first roomIdx];`]
q)roomName
`Hull Breach
```
We find which line introduces the doors:
```q
q)doorIdx:where outs~\:"Doors here lead:"
q)doorIdx
,6
```
We also find which lines are empty, as the list of doors ends with this as a delimiter:
```q
q)emptyIdx:where 0=count each outs
q)emptyIdx
0 1 2 5 10 12
```
We set the doors to the empty list, and populate the list if there are any doors:
```q
q)doors:`$()

    if[0<count doorIdx;
        ...
    ];
```
If there are any doors, we find the end of the door list by looking for the first empty line after
the start of the door list:
```q
q)doorEnd:first emptyIdx where first[doorIdx]<emptyIdx
q)doorEnd
10
```
We extract the doors by taking only the part between the start and end, and droppin the first two
characters (`"- "`):
```q
q)doors:`$2_/:(1+first doorIdx) _doorEnd#outs
q)doors
`north`east`south
```
We perform a similar process for the items:
```q
    itemIdx:where outs~\:"Items here:";
    items:`$();
    if[0<count itemIdx;
        itemEnd:first emptyIdx where first[itemIdx]<emptyIdx;
        items:`$2_/:(1+first itemIdx) _itemEnd#outs;
    ];
```
We return a dictionary containing the room info found:
```q
q)`roomName`doors`items!(roomName;doors;items)
roomName| `Hull Breach
doors   | `north`east`south
items   | `symbol$()
```

### .d25.getCmds
This helper function finds the list of commands for moving from Hull Breach to Security Checkpoint,
collecting all the items on the way, and dropping them at the checkpoint. It takes the `rooms` and
`links` tables discovered before.

We initialize a queue with a single node in Hull Breach and with no items:
```q
q)queue:enlist`room`items!(`$"Hull Breach";`$())
q)queue
room        items
-----------------
Hull Breach
```
We initialize a parent map that maps the initial node to the empty symbol:
```q
q)parent:enlist[exec (first[room],first items) from queue]!enlist`$()
q)parent
Hull Breach|
```
We perform an iteration until there are no items in the queue, which would be an error:
```q
    while[0<count queue;
        ...
    ];
    '"not found";

```
In the iteration, we generate the next nodes by appending the outgoing doors from each room:
```q
q)nxts:update doors:rooms[([]roomName:room);`doors] from queue
q)nxts
room        items doors
----------------------------------
Hull Breach       north east south
```
We check if there are any destination nodes in the queue, which have Security Checkpoint as the room
and all 8 items:
```q
    if[count founds:select from nxts where room=`$"Security Checkpoint",8=count each items;
        ...
    ];
```
Otherwise, we append the room on the other side of each door:
```q
q)nxts:update nroom:links[;`roomTo] each ungroup each enlist each ([]roomFrom:room;dir:doors) from nxts
q)nxts
room        items doors            nroom
-----------------------------------------------------------
Hull Breach       north east south Corridor Storage Stables
```
We flatten the table (can't use `ungroup` here because `items` is a list):
```q
q)nxts:raze{([]room:x`room;items:count[x`doors]#enlist x`items;nroom:x`nroom)}each nxts
q)nxts
room        items nroom
--------------------------
Hull Breach       Corridor
Hull Breach       Storage
Hull Breach       Stables
```
We add a column for the new items found in the target room:
```q
q)nxts:update nitems:asc each distinct each (items,'rooms[([]roomName:nroom);`items]) from nxts
q)nxts
room        items nroom    nitems
---------------------------------------------
Hull Breach       Corridor `s#,`spool of cat6
Hull Breach       Storage  `s#`symbol$()
Hull Breach       Stables  `s#,`fixed point
```
We delete any entries that refer to room/item combinations already in the parent map:
```q
q)nxts:select from nxts where not (nroom,'nitems) in key parent
q)nxts
room        items nroom    nitems
---------------------------------------------
Hull Breach       Corridor `s#,`spool of cat6
Hull Breach       Storage  `s#`symbol$()
Hull Breach       Stables  `s#,`fixed point
```
We append the new rooms to the parent map:
```q
q)parent,:exec (nroom,'nitems)!(room,'items) from nxts
q)parent
,`Hull Breach          | `symbol$()
`Corridor`spool of cat6| ,`Hull Breach
,`Storage              | ,`Hull Breach
`Stables`fixed point   | ,`Hull Breach
```
We generate the next state of the queue by only keeping the next room/item columns:
```q
q)queue:select room:nroom, items:nitems from nxts
q)queue
room     items
---------------------------
Corridor `s#,`spool of cat6
Storage  `s#`symbol$()
Stables  `s#,`fixed point
```
This is the end of the iteration code, but the part about returning the output is still missing.

Eventually we reach the point where the destination appears in the expanded nodes:
```q
q)founds:select from nxts where room=`$"Security Checkpoint",8=count each items
q)founds
room                items                                                                         ..
--------------------------------------------------------------------------------------------------..
Security Checkpoint candy cane easter egg fixed point hypercube monolith ornament planetoid spool ..
Security Checkpoint candy cane easter egg fixed point hypercube monolith ornament planetoid spool ..
```
We take the first valid entry:
```q
q)found:first founds
q)found
room | `Security Checkpoint
items| `s#`candy cane`easter egg`fixed point`hypercube`monolith`ornament`planetoid`spool of cat6
doors| `north`west
```
We generate the full path by tracing back the parent map, reversing the result and dropping the
first dummy element:
```q
q)path:1_reverse parent\[found[`room],found[`items]]
q)path
,`Hull Breach
`Stables`fixed point
`Hull Breach`fixed point
`Corridor`fixed point`spool of cat6
`Observatory`fixed point`monolith`spool of cat6
`Holodeck`fixed point`monolith`planetoid`spool of cat6
..
```
We extract the room names from the path:
```q
q)roomPath:first each path
q)roomPath
`Hull Breach`Stables`Hull Breach`Corridor`Observatory`Holodeck`Observatory`Science Lab`Observatory..
```
We find which directions we need to take in order to go from one room to the next:
```q
q)roomDirs:string 1_{[links;x;y]exec first dir from links where roomFrom=y,roomTo=x}[links]':[roomPath]
q)roomDirs
"south"
"north"
"north"
"north"
"west"
"east"
..
```
We find which items we pick up in each step:
```q
q)pickups:1_except':[1_/:path]
q)pickups
,`fixed point
`symbol$()
,`spool of cat6
,`monolith
,`planetoid
`symbol$()
..
```
We find the final list of items from the final element of the path:
```q
q)items:1_last path
q)items
`candy cane`easter egg`fixed point`hypercube`monolith`ornament`planetoid`spool of cat6
```
We generate the command list by splicing together the directions with the necessary "take" commands,
followed by "drop" commands for each item at the end:
```q
q)cmds:(raze(enlist each roomDirs),'"take ",/:/:string pickups),"drop ",/:string items
q)cmds
"south"
"take fixed point"
"north"
"north"
"take spool of cat6"
"north"
"take monolith"
..
q)-10#cmds
"west"
"south"
"drop candy cane"
"drop easter egg"
"drop fixed point"
"drop hypercube"
"drop monolith"
"drop ornament"
"drop planetoid"
"drop spool of cat6"
```
This is the return value of the function.

### .d25.getItemsToPass
This helper function finds which items are needed to pass the security check using a brute-force
method. It takes three parameters: `st` (the intcode VM state just after applying the commands from
`.d25.getCmds`), `allItems` (a string list with all the items) and `tryDir` (the direction to move
in order to test the current item combination).

We generate the possible lists of items to take by generating all integers up to 2 to the power of
the number of items, then use `0b vs` to conver these into boolean lists, and cut these to remove
the excess zeros at the beginning.
```q
q)takes:neg[count allItems]#/:0b vs/:til `long$2 xexp count allItems
q)takes
00000000b
00000001b
00000010b
00000011b
00000100b
00000101b
00000110b
00000111b
..
```
We convert these into actual item name lists:
```q
q)takeItems:allItems where each takes
q)takeItems
()
,"spool of cat6"
,"planetoid"
("planetoid";"spool of cat6")
,"ornament"
("ornament";"spool of cat6")
("ornament";"planetoid")
("ornament";"planetoid";"spool of cat6")
..
```
We generate the corresponding command sequences to take the items and move in the try direction:
```q
q)cmdss:"\n"sv/:("take ",/:/:takeItems),\:enlist string[tryDir],"\n"
q)cmdss
"west\n"
"take spool of cat6\nwest\n"
"take planetoid\nwest\n"
"take planetoid\ntake spool of cat6\nwest\n"
"take ornament\nwest\n"
"take ornament\ntake spool of cat6\nwest\n"
"take ornament\ntake planetoid\nwest\n"
"take ornament\ntake planetoid\ntake spool of cat6\nwest\n"
..
```
We feed each command sequence in turn into the intcode VM. This operation takes a long time.
```q
q)\t rs:.intcode.runI[st] each `long$cmdss
49874
```
We extract the outputs from each resulting state:
```q
q)outs:`char${$[0=type x;last x;x]}each rs
q)outs
"\n\n\n== Pressure-Sensitive Floor ==\nAnalyzing...\n\nDoors here lead:\n- east\n\nA loud, robotic..
"\nYou take the spool of cat6.\n\nCommand?\n\n\n\n== Pressure-Sensitive Floor ==\nAnalyzing...\n\n..
"\nYou take the planetoid.\n\nCommand?\n\n\n\n== Pressure-Sensitive Floor ==\nAnalyzing...\n\nDoor..
"\nYou take the planetoid.\n\nCommand?\n\nYou take the spool of cat6.\n\nCommand?\n\n\n\n== Pressu..
"\nYou take the ornament.\n\nCommand?\n\n\n\n== Pressure-Sensitive Floor ==\nAnalyzing...\n\nDoors..
"\nYou take the ornament.\n\nCommand?\n\nYou take the spool of cat6.\n\nCommand?\n\n\n\n== Pressur..
..
```
We find the one output that doesn't contain the alert message, and return the corresponding item
list:
```q
q)itemsToPass:first takeItems where not outs like "*Alert!*"
q)itemsToPass
"easter egg"
"hypercube"
"monolith"
"ornament"
```

## Whiteboxing
With the regular solution being so elaborate, it's quite a letdown tha the whiteboxed solution is
merely this:
```q
q)a:"J"$","vs raze x
q)0b sv (32#0b),a[1902+til 32]>=a[2486]*a[1352]
1073815584
```
This reads: take 32 integers starting from address 1902, check which are greater than or equal to
the product of the integers at address 2486 and 1352, and reinterpret the resulting boolean list as
the bits of an integer. `(32#0b)` is prepended to ensure that the result is a long instead of an
int, which would give the wrong answer if the very first bit was set.

However, there is more to explore in the code.

Strings are encrypted using a simple cipher so they can't simply be read by viewing the code as
ASCII. The first byte of the string is the length. Then every character has the length plus the
character position subtracted from it. So for a string of length 20, the first character after the
length number would have 20 subtracted, the second character 21 etc. The following function extracts
a single string from the given address:
```q
    .d25.xstr:{[a;addr]c:a[addr];d:til c;`char$c+d+a addr+1+d};
```
The following function finds all the strings in the code:
```q
    .d25.findStrs:{[a]
        strs:();
        cursor:0;
        while[cursor<count a;
            $[a[cursor] within 1 1000;[
                str:.d25.xstr[a;cursor];
                $[all (str=10)or str within 32 127;
                    [
                        strs,:enlist[(cursor;str)];
                        cursor+:1+count str;
                    ];
                    cursor+:1
                ];
                ];
            cursor+:1
            ];
        ];
        strs};

q).d25.findStrs a
5   ,"o"
16  ,"o"
34  "\n\n\n== "
41  " ==\n"
46  "\n\nDoors here lead:\n"
70  "north"
76  "east"
81  "south"
87  "west"
92  "\nItems here:\n"
106 "\nItems in your inventory:\n"
133 "\nYou aren't carrying any items.\n"
166 "\nCommand?\n"
177 "\nUnrecognized command.\n" 
..
```
At address 4601 there is an array of 13 item records. Each record is 4 integers:
- The room the item is in. -1 for items in inventory. (No item starts in your inventory.)
- Pointer to the item name.
- Score. Note that 27 plus the index of the item in the array is added to the score to obscure it.
  The number printed on winning is the sum of the scores of the items in your inventory after
  unscrambling them (at which point they are powers of two).
- Pickup handler function, or 0 for none. Only used for the harmful items.

The following function extracts all the item data from the code:
```q
    .d25.xitems:{[a]
        itemData:flip`loc`name`score`pickupHandler!flip 4 cut (13*4)#4601_a;
        itemData:update name:.d25.xstr[a] each name from itemData;
        itemData:update score-i+27 from itemData;
        itemData};

q).d25.xitems a
loc  name                  score      pickupHandler
---------------------------------------------------
3736 "planetoid"           8388608    0
4075 "molten lava"         0          1850
3547 "candy cane"          1048576    0
4246 "infinite loop"       0          1829
3940 "ornament"            8192       0
..
```

Rooms also have records describing them, however they don't form an array and there is no overall
list of all the rooms on the map. The only way to find all of them is via BFS starting from the
known rooms which are the starting locations of each item, then following the links between rooms.
The room record contains:
- Pointer to room name.
- Pointer to room description.
- Pointer to entry function. Only used for the pressure-sensitive floor.
- Pointers to room to the north, east, south and west in that order, with zeros for  the lack of a
passage.

The following function extracts room data from the given addresses in the code:
```q
    .d25.xroom:{[a;addrs]
        roomData:`addr xcols update addr:addrs from (flip`name`descr`enterHandler`roomNorth`roomEast`roomSouth`roomWest!flip a[addrs+\:til 7])};
```

The following function extracts all the room data from the code:
```q
    .d25.xrooms:{[a]
        roomData:.d25.xroom[a;exec loc from itemData];
        while[0<count missing:distinct exec (roomNorth,roomEast,roomSouth,roomWest) except (0,addr) from roomData;
            roomData,:.d25.xroom[a;missing];
        ];
        roomData:`addr xasc update .d25.xstr[a]each name,.d25.xstr[a]each descr from roomData;
        roomData};

q)itemData:.d25.xitems a
q).d25.xrooms a
addr name                       descr                                                             ..
--------------------------------------------------------------------------------------------------..
3124 "Hull Breach"              "You got in through a hole in the floor here. To keep your ship fr..
3252 "Corridor"                 "The metal walls and the metal floor are slightly different colors..
3348 "Observatory"              "There are a few telescopes; they're all bolted down, though."    ..
3428 "Stables"                  "Reindeer-sized. They're all empty."                              ..
3478 "Gift Wrapping Center"     "How else do you wrap presents on the go?"                        ..
..
q).d25.xrooms[a]1
addr        | 3252
name        | "Corridor"
descr       | "The metal walls and the metal floor are slightly different colors. Or are they?"
enterHandler| 0
roomNorth   | 3348
roomEast    | 3478
roomSouth   | 3124
roomWest    | 0
``` 
To find out how to get the winning number, we need to look at what the entry function for the
pressure-sensitive floor does. It goes through all the items in the game, and if the particular item
is in your inventory, it adds their unscrambled score to a total. (The harmful items have scores
that unscramble to zero.) Then it compares the result bit by bit to a bit mask stored in a scrambled
format at address 1901. There are 33 bits in the bit mask but only the lower 32 bits are ever used.
The values in the bit mask appear to be random values, and whether they correspond to 0 or 1 is
indicated by whether they are greater or lower than a threshold value. The threshold value is also
not itself stored in the program, however it is obtained by multiplying two numbers together, and
these two numbers can be found in the initial state, at addresses 2486 and 1352.

## Easter Eggs
Some of the items and rooms contain references.

### Harmful items
| Item | Note |
|------|------|
| [infinite loop](https://en.wikipedia.org/wiki/Infinite_loop) | Often a programming error. Picking it up triggers an actual infinite loop in the intcode program (but it also prints, so the output would eventually fill up all available memory). |
| giant electromagnet | Probably not a reference. |
| [photons](https://en.wikipedia.org/wiki/Photon) | Being eaten by a grue is a reference to [Zork](https://en.wikipedia.org/wiki/Zork). Photons are not things that can ordinarily be picked up. |
| [escape pod](https://en.wikipedia.org/wiki/Escape_pod) | A staple of science fantasy, e.g. they appear in [System Shock 2](https://en.wikipedia.org/wiki/System_Shock_2) and [The Fifth Element](https://en.wikipedia.org/wiki/The_Fifth_Element). |
| molten lava | Probably the joke is how this can exist in -40 degrees as it should cool down. |

### Normal items
| Item | Note |
|------|------|
| antenna | Probably not a reference, just here because of it being related to technology. |
| [asterisk](https://en.wikipedia.org/wiki/Asterisk) | The starts given as rewards for puzzles are represented as asterisks. |
| [astrolabe](https://en.wikipedia.org/wiki/Astrolabe) | A reference to the hidden text in [2019 day 1](https://adventofcode.com/2019/day/1). |
| astronaut ice cream | A reference to [freeze-dried ice cream](https://en.wikipedia.org/wiki/Freeze-dried_ice_cream). |
| boulder | Possibly a reference to using boulders to hold down pressure plates in games and other media. |
| candy cane | Christmas item, also one appears on the [2018 calendar](https://adventofcode.com/2018/). |
| coin | Possibly a reference to [2019 day 13](https://adventofcode.com/2019/day/13) and the coin-operated arcade machine. |
| [dark matter](https://en.wikipedia.org/wiki/Dark_matter) | Normally not something that can be picked up. |
| dehydrated water | A joke, dehydrating means removing water, so dehydrating water would result in nothing (maybe perhaps limescale). |
| easter egg | A name for the very concept of hidden jokes and references. Additionally, some puzzles refer to Easter, and the [2016 season](https://adventofcode.com/2016/) theme is infiltrating the Easter Bunny HQ. |
| festive hat | Possibly a reference to Santa's hat, which was featured on the [2018 calendar](https://adventofcode.com/2018/) and in some puzzles. |
| fixed point | A theoretical concept, not an actual object. It could refer to one of the possible representations of real numbers in computers. Also could be a reference to [2018 day 25](https://adventofcode.com/2018/day/25) ("fixed points in spacetime") which goes against the known laws of physics that dictate that there are no such fixed points and every movement is relative. |
| fuel cell | Possibly a reference to [2018 day 11](https://adventofcode.com/2018/day/11). |
| [hologram](https://en.wikipedia.org/wiki/Holography) | A hologram can refer to an actual photo-like picture that has a 3D effect when viewed, but in the sci-fi context it usually refers to an intangible 3D image which you wouldn't be able to pick up. |
| [hypercube](https://en.wikipedia.org/wiki/Hypercube) | This could be a more-than-3 dimensional object, which might not actually exist. |
| jam | Possibly a pun on [Space Jam](https://en.wikipedia.org/wiki/Space_Jam). |
| [klein bottle](https://en.wikipedia.org/wiki/Klein_bottle) | A mathematical object that has no outside vs inside distinction. It can only exist in 4 or more dimensions. 3D models exist of it but those don't have the defining property of the theoretical Klein bottle. |
| loom | ??? |
| [manifold](https://en.wikipedia.org/wiki/Manifold) | Generally a mathematical concept, not necessarily an actual object. |
| monolith | ??? |
| mouse | Not sure if it's the rodent or the input device (although the latter is more likely). |
| mug | Mugs of hot chocolate were featured on the [2018 calendar](https://adventofcode.com/2018/). |
| [mutex](https://en.wikipedia.org/wiki/Lock_(computer_science)) | A programming concept, certainly not an item that can be picked up. |
| ornament | Generic Christmas object, probbly not a reference. |
| [planetoid](https://en.wikipedia.org/wiki/Minor_planet) | Probably too large to fit inside a spaceship. Could be a reference to [2019 day 20](https://adventofcode.com/2019/day/20) and [2019 day 24](https://adventofcode.com/2019/day/24) since Pluto and Eris are "planetoids". |
| pointer | Either a physical object, or it could refer to the mouse pointer, or a value that points to a location in memory, which are not real objects. |
| [prime number](https://en.wikipedia.org/wiki/Prime_number) | Not a physical object. Prime numbers are essential to some puzzles like [2019 day 22](https://adventofcode.com/2019/day/22). |
| sand | A joke since in reality it should be possible to use only part of the sand on the pressure plate to bypass the guessing involved with the weights of the items, but according to the rules of this puzzle, this is a single item that can't be split up. |
| [semiconductor](https://en.wikipedia.org/wiki/Semiconductor) | Expected to be in any kind of modern tech, could be a reference to the [2017 season](https://adventofcode.com/2017/). |
| shell | If it's an animal part (e.g. shellfish or turtle shell) then it's very odd for it to appear on a spaceship. But it could also mean a [command interpreter](https://en.wikipedia.org/wiki/Shell_(computing)) (like cmd.exe or bash) which are not physical objects. |
| [space heater](https://en.wikipedia.org/wiki/Space_heater) | A pun as "space heater" refers to the fact that it heats a space, not that it is used in space. |
| space law space brochure | A reference to [2019 day 11](https://adventofcode.com/2019/day/11). |
| spool of [cat6](https://en.wikipedia.org/wiki/Category_6_cable) | A reference to [2019 day 23](https://adventofcode.com/2019/day/23). |
| tambourine | An odd object to appear here. Not sure if this is a reference. |
| weather machine | Could be a reference to the [2015 season](https://adventofcode.com/2015/). |
| whirled peas | Pun: homophone of "world peace". |
| wreath | Christmas item, especially the Advent wreath. Could also be a reference to [2019 day 20](https://adventofcode.com/2019/day/20) whith its donut a.k.a. toroidal maze. |

### Rooms
| Room | Note |
|------|------|
| Hull Breach | Standard way of entering a foreign spaceship in space fantasy. |
| Corridor | ??? |
| Observatory | ??? |
| Stables | Santa's spaceship must have stables for reindeer. |
| Gift Wrapping Center | Obviously, another necessary thing for Santa. |
| Hallway | ??? |
| Arcade | A reference to [2019 day 13](https://adventofcode.com/2019/day/13). |
| Kitchen | A reference to space food generally being freeze-dried. |
| [Holodeck](https://en.wikipedia.org/wiki/Holodeck) | A reference to Star Trek. |
| Passages | A reference to Adventure (a.k.a. [Colossal Cave Adventure](https://en.wikipedia.org/wiki/Colossal_Cave_Adventure)), the great-great-great-grandad of this very puzzle. Luckily there is no actual maze this time. |
| Hot Chocolate Fountain | Could be a reference to the [2018 season](https://adventofcode.com/2018/) and the puzzles involving hot chocolate. |
| Engineering | A reference to [2019 day 21](https://adventofcode.com/2019/day/21). |
| Storage | Could be a reference to [Matryoshka dolls](https://en.wikipedia.org/wiki/Matryoshka_doll), although those are not "recursive" all the way. |
| Navigation | A self-reference to the [2019 season](https://adventofcode.com/2019), with the framing story set in [2019 day 1](https://adventofcode.com/2019/day/1). |
| Science Lab | Could be a reference to [2018 day 5](https://adventofcode.com/2018/day/5). |
| [Warp Drive](https://en.wikipedia.org/wiki/Warp_drive) Maintenance | General space fantasy. Not sure if this is a reference. |
| Crew Quarters | Obviously the beds are elf-sized so too small for a human. |
| Sick Bay | Could be a reference to [2015 day 19](https://adventofcode.com/2015/day/19) or [2018 day 25](https://adventofcode.com/2018/day/25). |
| Security Checkpoint | Probably not a reference as this is functional to the puzzle. |
| Pressure-Sensitive Floor | Probably not a reference as this is functional to the puzzle. |
