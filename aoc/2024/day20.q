.d20.cc:{[cl;x] //calc cheats; cl=cheat length
    visited:x="#";
    pos:first raze til[count x],/:'where each x="S";
    goal:first raze til[count x],/:'where each x="E";
    map:.[;;:;"."]/[x;(pos;goal)];
    path:();
    while[not pos~goal;
        visited:.[visited;pos;:;1b];
        path,:enlist pos;
        nxts:pos+/:(-1 0;0 1;1 0;0 -1);
        nxts:nxts where not visited ./:nxts;
        pos:first nxts;
    ];
    path,:enlist goal;
    saves:{[cl;path;i]
        pi:path i;
        p2:i _path;
        dist:sum each abs pi-/:p2;
        ((dist<=cl)*til[count p2]-dist)except 0}[cl;path]each til count path;
    {asc[key x]#x}count each group raze saves};
.d20.ccc:{[cutoff;cl;x] //calc cheats with cutoff
    cc:{([]k:key x;v:value x)}.d20.cc[cl;x];
    exec k!v from cc where k within cutoff};
d20:{[cutoff;cl;x]sum .d20.ccc[cutoff;cl;x]};
d20p1:{d20[100 0W;2;x]};
d20p2:{d20[100 0W;20;x]};

/

x:();
x,:enlist"###############";
x,:enlist"#...#...#.....#";
x,:enlist"#.#.#.#.#.###.#";
x,:enlist"#S#...#.#.#...#";
x,:enlist"#######.#.#.###";
x,:enlist"#######.#.#...#";
x,:enlist"#######.#.###.#";
x,:enlist"###..E#...#...#";
x,:enlist"###.#######.###";
x,:enlist"#...###...#...#";
x,:enlist"#.#####.#.###.#";
x,:enlist"#.#...#.#.#...#";
x,:enlist"#.#.#.#.#.#.###";
x,:enlist"#...#...#...###";
x,:enlist"###############";

.d20.ccc[0 0W;2;x]   //2 4 6 8 10 12 20 36 38 40 64!14 14 2 4 2 3 1 1 1 1 1
.d20.ccc[50 0W;20;x]   //50 52 54 56 58 60 62 64 66 68 70 72 74 76!32 31 29 39 25 23 20 19 12 14 12 22 4 3
//d20p1 x
//d20p2 x
