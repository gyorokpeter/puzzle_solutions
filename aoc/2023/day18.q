d18:{[ins]
    pd:ins[;1]*(`U`R`D`L!(-1 0;0 1;1 0;0 -1))ins[;0];
    path:sums enlist[0 0],pd;
    squeeze:{distinct asc x,(x+1)};
    xm:squeeze path[;1];
    ym:squeeze path[;0];
    path2:(ym?path[;0]),'xm?path[;1];
    path3:sums enlist[0 0],raze{c:max abs x;c#enlist x div c}each 1_deltas path2;
    path3:path3-\:min path3;
    map:.[;;:;"#"]/[(3+max path3)#" ";1+path3];
    queue:enlist 0 0;
    while[count queue;
        map:.[;;:;"o"]/[map;queue];
        nxts:distinct raze queue+/:\:(-1 0;0 1;1 0;0 -1);
        nxts:nxts where all each nxts within'\:(0,count[map]-1;0,count[map 0]-1);
        nxts:nxts where" "=map ./:nxts;
        queue:nxts;
    ];
    tiles:raze til[count map],/:'where each map in" #";
    sum deltas[ym][tiles[;0]]*deltas[xm][tiles[;1]]};
d18p1:{d18"SJ"$/:(" "vs/:x)[;0 1]};
d18p2:{a:2_/:-1_/:last each" "vs/:x;
    d18(`$/:"RDLU""J"$/:last each a),'16 sv/:"X"$/:/:-1_/:a};


/
x:();
x,:enlist"R 6 (#70c710)";
x,:enlist"D 5 (#0dc571)";
x,:enlist"L 2 (#5713f0)";
x,:enlist"D 2 (#d2c081)";
x,:enlist"R 2 (#59c680)";
x,:enlist"D 2 (#411b91)";
x,:enlist"L 5 (#8ceee2)";
x,:enlist"U 2 (#caa173)";
x,:enlist"L 1 (#1b58a2)";
x,:enlist"U 2 (#caa171)";
x,:enlist"R 2 (#7807d2)";
x,:enlist"U 3 (#a77fa3)";
x,:enlist"L 2 (#015232)";
x,:enlist"U 2 (#7a21e3)";

d18p1 x //62
d18p2 x //952408144115
