{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

.d25.parseOutput:{[out]
    outs:"\n"vs out;
    roomIdx:where outs like "==*==";
    roomName:$[0<count roomIdx; `$3_-3_outs[first roomIdx];`];
    doorIdx:where outs~\:"Doors here lead:";
    emptyIdx:where 0=count each outs;
    doors:`$();
    if[0<count doorIdx;
        doorEnd:first emptyIdx where first[doorIdx]<emptyIdx;
        doors:`$2_/:(1+first doorIdx) _doorEnd#outs;
    ];
    itemIdx:where outs~\:"Items here:";
    items:`$();
    if[0<count itemIdx;
        itemEnd:first emptyIdx where first[itemIdx]<emptyIdx;
        items:`$2_/:(1+first itemIdx) _itemEnd#outs;
    ];
    `roomName`doors`items!(roomName;doors;items)};

.d25.dangerousItems:`$(
    "infinite loop";
    "giant electromagnet";
    "photons";
    "escape pod";
    "molten lava"
    );

.d25.buildMap:{[a]
    a1:.intcode.run a;
    out:`char$last a1;
    rooms:1!enlist .d25.parseOutput[out],enlist[`state]!enlist a1;
    links:([roomFrom:`$();dir:`$()]roomTo:`$());
    missing:ungroup select roomFrom:roomName, dir:doors from rooms;
    while[0<count missing;
        sts:exec .intcode.runI'[rooms[([]roomName:roomFrom);`state];`long$(string[dir],\:"\n")]from missing;
        outs:.d25.parseOutput each `char$last each sts;
        links,:missing!select roomTo:roomName from outs;
        newRooms:select from (update state:sts from outs) where not roomName in exec roomName from rooms;
        rooms,:select last doors, last items, last state by roomName from newRooms where not null roomName;
        missing:(ungroup select roomFrom:roomName, dir:doors from rooms) except key links;
    ];
    rooms:update items:items except\:.d25.dangerousItems from rooms;
    (delete state from rooms;links)};

.d25.getCmds:{[rooms;links]
    queue:enlist`room`items!(`$"Hull Breach";`$());
    parent:enlist[exec (first[room],first items) from queue]!enlist`$();
    while[0<count queue;
        nxts:update doors:rooms[([]roomName:room);`doors] from queue;
        if[count founds:select from nxts where room=`$"Security Checkpoint",8=count each items;
            found:first founds;
            path:1_reverse parent\[found[`room],found[`items]];
            roomPath:first each path;
            roomDirs:string 1_{[links;x;y]exec first dir from links where roomFrom=y,roomTo=x}[links]':[roomPath];
            pickups:1_except':[1_/:path];
            items:1_last path;
            cmds:(raze(enlist each roomDirs),'"take ",/:/:string pickups),"drop ",/:string items;
            :cmds;
        ];
        nxts:update nroom:links[;`roomTo] each ungroup each enlist each ([]roomFrom:room;dir:doors) from nxts;
        nxts:raze{([]room:x`room;items:count[x`doors]#enlist x`items;nroom:x`nroom)}each nxts;
        nxts:update nitems:asc each distinct each (items,'rooms[([]roomName:nroom);`items]) from nxts;
        nxts:select from nxts where not (nroom,'nitems) in key parent;
        parent,:exec (nroom,'nitems)!(room,'items) from nxts;
        queue:select room:nroom, items:nitems from nxts;
    ];
    '"not found";
    };

.d25.getItemsToPass:{[st;allItems;tryDir]
    takes:neg[count allItems]#/:0b vs/:til `long$2 xexp count allItems;
    takeItems:allItems where each takes;
    cmdss:"\n"sv/:("take ",/:/:takeItems),\:enlist string[tryDir],"\n";
    rs:.intcode.runI[st] each `long$cmdss;
    outs:`char${$[0=type x;last x;x]}each rs;
    itemsToPass:first takeItems where not outs like "*Alert!*";
    itemsToPass};

d25:{
    a:.intcode.new x;
    rl:.d25.buildMap a;
    rooms:rl 0;
    links:rl 1;
    allItems:string asc exec raze items from rooms;
    -1"all items: ",", "sv allItems;
    cmds:.d25.getCmds[rooms;links];
    cmdIn:`long$raze cmds,\:"\n";
    st:.intcode.runI[a;cmdIn];
    tryDir:exec first dir from links where roomFrom=`$"Security Checkpoint", roomTo=`$"Pressure-Sensitive Floor";
    itemsToPass:.d25.getItemsToPass[st;allItems;tryDir];
    -1"items to pass: ",", "sv itemsToPass;
    cmdIn2:`long$("\n"sv ("take ",/:itemsToPass),enlist string[tryDir]),"\n";
    st2:.intcode.getOutput .intcode.runI[st;cmdIn2];
    if[not 7h=type st2; '"solution failed"];
    password:"J"$first" on the keypad" vs last"get in by typing " vs `char$st2;
    password};

d25whitebox:{a:"J"$","vs raze x;
    0b sv (32#0b),a[1902+til 32]>=a[2486]*a[1352]};

.d25.xstr:{[a;addr]c:a[addr];d:til c;`char$c+d+a addr+1+d};

.d25.xitems:{[a]
    itemData:flip`loc`name`score`pickupHandler!flip 4 cut (13*4)#4601_a;
    itemData:update name:.d25.xstr[a] each name from itemData;
    itemData:update score-i+27 from itemData;
    itemData};
//itemData:.d25.xitems a

.d25.xroom:{[a;addrs]
    roomData:`addr xcols update addr:addrs from (flip`name`descr`enterHandler`roomNorth`roomEast`roomSouth`roomWest!flip a[addrs+\:til 7])};
.d25.xrooms:{[a]
    roomData:.d25.xroom[a;exec loc from itemData];
    while[0<count missing:distinct exec (roomNorth,roomEast,roomSouth,roomWest) except (0,addr) from roomData;
        roomData,:.d25.xroom[a;missing];
    ];
    roomData:`addr xasc update .d25.xstr[a]each name,.d25.xstr[a]each descr from roomData;
    roomData};
//roomData:.d25.xrooms a;

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

/
No example input provided
