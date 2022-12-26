d23:{[part;x]
    map:"#"=x;
    round:0;
    moveDirs:(6 3 0;7 4 1;2 0 1;5 3 4);
    moveDeltas:(-1 0;1 0;0 -1;0 1);
    while[1b;
        round+:1;
        filler:enlist (2+count first map)#0b;
        mapp:filler,(0b,/:map,\:0b),filler;
        mapr:-1_raze -1 1 0 rotate\:/:-1 1 0 rotate/:\:mapp;  //NW, SW, W, NE, SE, E, N, S
        noMove:0=sum mapr;
        pmv:3=sum each not[mapr] moveDirs;
        noMove:not[mapp] or noMove or 0=sum pmv;
        pmv2:(0N,/:-1+til 5)@'enlist[noMove],pmv;
        prop:^/[reverse pmv2];
        propCoord:raze til[count prop],/:'where each prop>-1;
        propDir:prop ./:propCoord;
        propDest:propCoord+moveDeltas propDir;
        validDest:where propDest in where 1=count each group propDest;
        if[(part=2) and 0=count validDest; :round];
        propCoord:propCoord validDest;
        propDest:propDest validDest;
        mapp:.[;;:;0b]/[mapp;propCoord];
        mapp:.[;;:;1b]/[mapp;propDest];
        while[0b=max first mapp; mapp:1_mapp];
        while[0b=max last mapp; mapp:-1_mapp];
        while[0b=max mapp[;0]; mapp:1_/:mapp];
        while[0b=max mapp[;count[first mapp]-1]; mapp:-1_/:mapp];
        map:mapp;
        moveDirs:1 rotate moveDirs;
        moveDeltas:1 rotate moveDeltas;
        if[(part=1) and round=10;
            :`long$sum sum not map;
        ];
    ];
    };
d23p1:{d23[1;x]};
d23p2:{d23[2;x]};

/
x:"\n"vs".....\n..##.\n..#..\n.....\n..##.\n.....";
x:"\n"vs"....#..\n..###.#\n#...#.#\n.#...##\n#.###..\n##.#.##\n.#..#..";

d23p1 x //110 / 4091
d23p2 x //20  / 1036
