d15p1:{a:"\n\n"vs"\n"sv x;
    map:"\n"vs a 0;
    instr:a[1]except"\n";
    pos:first raze til[count map],/:'where each map="@";
    map1:.[map;pos;:;"."];
    mp:{[mp;ni]
        map1:mp 0;pos:mp 1;
        delta:("^>v<"!(-1 0;0 1;1 0;0 -1))ni;
        line:pos+/:(1+til count map1)*\:delta;
        cont:map1 ./:line;
        empty:cont?".";
        wall:cont?"#";
        if[empty<wall;
            if[empty>0;
                map1:.[map1;line 0;:;"."];
                map1:.[map1;line empty;:;"O"];
            ];
            pos:line 0;
        ];
        (map1;pos)}/[(map1;pos);instr];
    map2:mp 0;
    sum sum 100 1*/:raze til[count map],/:'where each map2="O"};
d15p2:{a:"\n\n"vs"\n"sv x;
    map:raze each("#O.@"!("##";"[]";"..";"@."))"\n"vs a 0;
    instr:a[1]except"\n";
    pos:first raze til[count map],/:'where each map="@";
    map1:.[map;pos;:;"."];
    mp:{[mp;ni]
        map1:mp 0;pos:mp 1;
        $[ni in "><";[
            delta:("><"!(0 1;0 -1))ni;
            line:pos+/:(1+til count first map1)*\:delta;
            cont:map1 ./:line;
            empty:cont?".";
            wall:cont?"#";
            if[empty<wall;
                if[empty>0;
                    map1:.[;;:;]/[map1;line til 1+empty;".",map1 ./:line til empty];
                ];
                pos:line 0;
            ];
            ];[
            delta:("^v"!(-1 0;1 0))ni;
            queue:enlist pos;
            visited:();
            while[count queue;
                nxts:queue+\:delta;
                cont:map1 ./:nxts;
                if["#" in cont;:(map1;pos)];
                filter:where not cont=".";
                nxts@:filter; cont@:filter;
                nxts,:(nxts where cont="[")+\:0 1;
                nxts,:(nxts where cont="]")+\:0 -1;
                nxts:distinct nxts;
                visited,:nxts;
                queue:nxts;
            ];
            pos+:delta;
            if[count visited;
                vcont:map1 ./:visited;
                map1:.[;;:;"."]/[map1;visited];
                map1:.[;;:;]/[map1;visited+\:delta;vcont];
            ];
        ]];
        (map1;pos)}/[(map1;pos);instr];
    map2:mp 0;
    sum sum 100 1*/:raze til[count map],/:'where each map2="["};

/

x:();
x,:enlist"##########";
x,:enlist"#..O..O.O#";
x,:enlist"#......O.#";
x,:enlist"#.OO..O.O#";
x,:enlist"#..O@..O.#";
x,:enlist"#O#..O...#";
x,:enlist"#O..O..O.#";
x,:enlist"#.OO.O.OO#";
x,:enlist"#....O...#";
x,:enlist"##########";
x,:enlist"";
x,:enlist"<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^";
x,:enlist"vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v";
x,:enlist"><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<";
x,:enlist"<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^";
x,:enlist"^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><";
x,:enlist"^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^";
x,:enlist">^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^";
x,:enlist"<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>";
x,:enlist"^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>";
x,:enlist"v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^";

d15p1 x //10092
d15p2 x //9021
