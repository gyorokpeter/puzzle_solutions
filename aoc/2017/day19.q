.d19.followPath:{
    dir:2;
    dirsteps:(-1 0;0 1;1 0;0 -1);
    pos:(0;first where x[0]<>" ");
    steps:1;
    letters:"";
    while[1b;
        nxtp:pos+dirsteps dir;
        if[" "=x . nxtp;
            nxtdirs:(dir+1 -1)mod 4;
            nxtps:pos+/:dirsteps nxtdirs;
            dir:first nxtdirs where " "<>x ./: nxtps;
            if[null dir; :(letters;steps)];
            nxtp:pos+dirsteps dir;
        ];
        if[(ch:x . nxtp) within "AZ";
            letters,:ch;
        ];
        pos:nxtp;
        steps+:1;
    ];
    };
d19p1:{.d19.followPath[x][0]};
d19p2:{.d19.followPath[x][1]};

/
x:();
x,:enlist"     |          ";
x,:enlist"     |  +--+    ";
x,:enlist"     A  |  C    ";
x,:enlist" F---|----E|--+ ";
x,:enlist"     |  |  |  D ";
x,:enlist"     +B-+  +--+ ";

d19p1 x //ABCDEF
d19p2 x //38
