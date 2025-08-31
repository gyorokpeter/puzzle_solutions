d20:{
    ts:("\n"vs/:"\n\n"vs"\n"sv x)except\:enlist"";
    tid:"J"$-1_/:last each" "vs/:first each ts;
    tc:1_/:ts;
    tco:enlist[`...]!enlist tc;
    tco[`f..]:flip each tc;
    tco[`.r.]:reverse each tc;
    tco[`fr.]:reverse each tco[`f..];
    tco[`..m]:reverse each/:tco[`...];
    tco[`.rm]:reverse each/:tco[`.r.];
    tco[`f.m]:reverse each/:tco[`f..];
    tco[`frm]:reverse each/:tco[`fr.];
    tw:count tc[0;0];
    mw:`long$sqrt count tid;
    align:{a:(x{c:count y;til[c],/:'where each (x~/:\:y) and til[c]<>/:\:til[c]}/:\:y);
        (enlist[(`;0N)]!enlist()),exec t by s from{([]s:x[;0 2];t:x[;1 3])}raze raze raze{key[x],/:'''value x}{key[x],/:''value x}each a};
    nr:align[tco[;;;tw-1];tco[;;;0]];
    nd:align[tco[;;tw-1];tco[;;0]];
    queue:(enlist each key[nr] inter key[nd]),\:(count[tc]-1)#enlist[()];
    while[0<count queue;
        nl:where ()~/:first queue;
        if[0=count nl;
            :(mw;tid;queue;tco);
        ];
        ni:nl first where{x=min x}(nl div mw)+nl mod mw;
        poss:$[(0<ni mod mw) and 0<ni div mw; nr[queue[;ni-1]]inter'nd queue[;ni-mw];
            0<ni mod mw; nr queue[;ni-1];
            0<ni div mw; nd queue[;ni-mw];
            '"???"];
        //not filtering for repeated tiles as it was not needed for my input
        queue:raze@[;ni;:;]/:'[queue;poss];
    ];
    '"not found"};
d20p1:{r:d20 x;mw:r 0;prd r[1]r[2;0;;1](0;mw-1;mw*mw-1;(mw*mw)-1)};
d20p2:{r:d20 x;
    mw:r 0;
    queue:r 2;
    tco:-1_/:/:/:1_/:/:/:-1_/:/:1_/:/:r 3;
    imgs:{[tco;mw;x]raze raze each/:flip each mw cut tco ./:x}[tco;mw]each queue;
    pattern:("                  # ";
             "#    ##    ##    ###";
             " #  #  #  #  #  #   ");
    pattern2:raze til[count pattern],/:'where each"#"=pattern;
    topLefts:(til 1+count[imgs 0]-count[pattern])cross til 1+count[imgs[0;0]]-count pattern 0;
    coords:topLefts+/:\:pattern2;
    monster:max{[coords;img]sum all each"#"=img ./:/:coords}[coords]each imgs;
    (sum sum imgs[0]="#")-monster*count pattern2};

/
x:();
x,:"\n"vs"Tile 2311:\n..##.#..#.\n##..#.....\n#...##..#.\n####.#...#\n##.##.###.\n##...#.###";
x,:"\n"vs".#.#.#..##\n..#....#..\n###...#.#.\n..###..###\n";
x,:"\n"vs"Tile 1951:\n#.##...##.\n#.####...#\n.....#..##\n#...######\n.##.#....#\n.###.#####";
x,:"\n"vs"###.##.##.\n.###....#.\n..#.#..#.#\n#...##.#..\n";
x,:"\n"vs"Tile 1171:\n####...##.\n#..##.#..#\n##.#..#.#.\n.###.####.\n..###.####\n.##....##.";
x,:"\n"vs".#...####.\n#.##.####.\n####..#...\n.....##...\n";
x,:"\n"vs"Tile 1427:\n###.##.#..\n.#..#.##..\n.#.##.#..#\n#.#.#.##.#\n....#...##\n...##..##.";
x,:"\n"vs"...#.#####\n.#.####.#.\n..#..###.#\n..##.#..#.\n";
x,:"\n"vs"Tile 1489:\n##.#.#....\n..##...#..\n.##..##...\n..#...#...\n#####...#.\n#..#.#.#.#";
x,:"\n"vs"...#.#.#..\n##.#...##.\n..##.##.##\n###.##.#..\n";
x,:"\n"vs"Tile 2473:\n#....####.\n#..#.##...\n#.##..#...\n######.#.#\n.#...#.#.#\n.#########";
x,:"\n"vs".###.#..#.\n########.#\n##...##.#.\n..###.#.#.\n";
x,:"\n"vs"Tile 2971:\n..#.#....#\n#...###...\n#.#.###...\n##.##..#..\n.#####..##\n.#..####.#";
x,:"\n"vs"#..#.#..#.\n..####.###\n..#.#.###.\n...#.#.#.#\n";
x,:"\n"vs"Tile 2729:\n...#.#.#.#\n####.#....\n..#.#.....\n....#..#.#\n.##..##.#.\n.#.####...";
x,:"\n"vs"####.#.#..\n##.####...\n##..#.##..\n#.##...##.\n";
x,:"\n"vs"Tile 3079:\n#.#.#####.\n.#..######\n..#.......\n######....\n####.#..#.\n.#...#.##.";
x,:"\n"vs"#.#####.##\n..#.###...\n..#.......\n..#.###...";

d20p1 x //20899048083289
d20p2 x //273
