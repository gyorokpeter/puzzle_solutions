d11step:{[a]
    a+:1;
    fl:a<>a;
    fla:{
        fl:x 0; a:x 1;
        w:count first a;
        a:0,/:(enlist[w#0],a,enlist[w#0]),\:0;
        fl:0b,/:(enlist[w#0b],fl,enlist[w#0b]),\:0b;
        nfl:(a>9) and not fl;
        nfls:-1_raze -1 1 0 rotate\:/:-1 1 0 rotate/:\:nfl;
        a+:sum nfls;
        fl:fl or nfl;
        a:-1_/:1_/:-1_1_a;
        fl:-1_/:1_/:-1_1_fl;
        (fl;a)
    }/[(fl;a)];
    fl:fla 0; a:fla 1;
    a:not[fl]*a;
    (fl;a)};
d11p1:{
    a:"J"$/:/:x;
    tf:0;
    do[100;
        fla:d11step[a];
        fl:fla 0; a:fla 1;
        tf+:sum sum fl;
    ];
    tf};
d11p2:{
    a:"J"$/:/:x;
    gen:0;
    while[1b;
        gen+:1;
        fla:d11step[a];
        fl:fla 0; a:fla 1;
        if[all all fl; :gen];
    ];
    };

/
x:"\n"vs"5483143223\n2745854711\n5264556173\n6141336146\n6357385478\n4167524645\n2176841721";
x,:"\n"vs"6882881134\n4846848554\n5283751526";

d11p1 x //1656
d11p2 x //195
