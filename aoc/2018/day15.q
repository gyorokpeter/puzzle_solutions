d15turn:{[map;units]
    unit:0;
    while[unit<count units;
        if[2>count exec distinct unitType from units; :(units;0b)];
        ac:units[unit];
        targets:select from (update j:i from units) where 1=sum each abs pos-\:ac[`pos], unitType<>ac`unitType;
        if[0=count targets;
            queue:enlist enlist ac`pos;
            visited:();
            found:0b;
            while[not[found] and 0<count queue;
                visited,:last each queue;
                nxts:((last each queue)+/:\:(1 0;-1 0;0 1;0 -1))except\:visited,exec pos from units;
                nxts:nxts @' where each "#"<>map ./:/:nxts;
                nxtp:raze queue,/:'enlist each/:nxts;
                nxtp:exec path from select first asc path by lp from update lp:last each path from ([]path:nxtp);
                arrive:select from (update reach:(where each 1=sum each/:abs pos-/:\:last each nxtp) from units) where i<>unit, unitType<>ac`unitType, 0<count each reach;
                if[0<count arrive;
                    found:1b;
                    finps:nxtp distinct raze exec reach from arrive;
                    finp:finps(iasc last each finps)?0;
                ];
                queue:nxtp;
            ];
            if[found;
                ac[`pos]:finp[1];
                units[unit;`pos]:finp[1];
                targets:select from (update j:i from units) where 1=sum each abs pos-\:ac[`pos], unitType<>ac`unitType;
            ];
        ];
        if[0<count targets;
            targetId:exec j iasc[pos]?0 from select from targets where hp=min hp;
            units[targetId;`hp]-:units[unit;`ap];
            if[units[targetId;`hp]<=0;
                units:delete from units where i=targetId;
                if[targetId<unit; unit-:1];
            ];
        ];
        unit+:1;
    ];
    units:`pos xasc units;
    (units;1b)};
d15showMap:{[blankMap;units]
    blankMap1:{.[x;y`pos;:;y`unitType]}/[blankMap;units];
    hpDisplays:{[x;y]{$[0<count x;3#" ";""],x}exec ", "sv(unitType,'"(",/:string[hp],\:")") from x where pos[;0]=y}[units]each til count blankMap1;
    -1 blankMap1,'hpDisplays;
    };
d15combat:{[map;elfAp]
    unitPos:raze til[count map],/:'where each map in "EG";
    unitType:map ./:unitPos;
    units:([]unitType;pos:unitPos;hp:200;ap:?[unitType="E";elfAp;3]);
    elfCount:sum unitType="E";
    blankMap:("#.GE"!"#...")map;
    turns:0;
    cont:1b;
    while[cont;
        -1"turn: ",string turns;
        d15showMap[blankMap;units];
        res:d15turn[blankMap;units];
        units:res 0;
        cont:res 1;
        if[cont;
            turns+:1;
        ];
    ];
    -1"final state:";
    d15showMap[blankMap;units];
    (elfCount=sum"E"=units`unitType;turns*exec sum hp from units)};
d15p1:{last d15combat[x;3]};
d15p2:{
    elfAp:1;
    while[not first res:d15combat[x;elfAp]; elfAp+:1];
    (elfAp;last res)};

/
x:();
x,:enlist"#######";
x,:enlist"#.G...#";
x,:enlist"#...EG#";
x,:enlist"#.#.#G#";
x,:enlist"#..G#E#";
x,:enlist"#.....#";
x,:enlist"#######";

x2:();
x2,:enlist"#######";
x2,:enlist"#G..#E#";
x2,:enlist"#E#E.E#";
x2,:enlist"#G.##.#";
x2,:enlist"#...#E#";
x2,:enlist"#...E.#";
x2,:enlist"#######";

x3:();
x3,:enlist"#######";
x3,:enlist"#E..EG#";
x3,:enlist"#.#G.E#";
x3,:enlist"#E.##E#";
x3,:enlist"#G..#.#";
x3,:enlist"#..E#.#";
x3,:enlist"#######";

x4:();
x4,:enlist"#######";
x4,:enlist"#E.G#.#";
x4,:enlist"#.#G..#";
x4,:enlist"#G.#.G#";
x4,:enlist"#G..#.#";
x4,:enlist"#...E.#";
x4,:enlist"#######";

x5:();
x5,:enlist"#######";
x5,:enlist"#.E...#";
x5,:enlist"#.#..G#";
x5,:enlist"#.###.#";
x5,:enlist"#E#G#G#";
x5,:enlist"#...#G#";
x5,:enlist"#######";

x6:();
x6,:enlist"#########";
x6,:enlist"#G......#";
x6,:enlist"#.E.#...#";
x6,:enlist"#..##..G#";
x6,:enlist"#...##..#";
x6,:enlist"#...#...#";
x6,:enlist"#.G...G.#";
x6,:enlist"#.....G.#";
x6,:enlist"#########";

d15p1 x     //27730
d15p1 x2    //36334
d15p1 x3    //39514
d15p1 x4    //27755
d15p1 x5    //28944
d15p1 x6    //18740
d15p2 x     //15 4988
d15p2 x2    //4 29064 //not shown in the examples
d15p2 x3    //4 31284
d15p2 x4    //15 3478
d15p2 x5    //12 6474
d15p2 x6    //34 1140

