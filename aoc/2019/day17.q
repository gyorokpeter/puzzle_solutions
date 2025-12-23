{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

d17p1:{a:.intcode.new x;
    r:("\n"vs`char$.intcode.getOutput .intcode.run[a])except enlist"";
    -1 r;
    r1:"#"=".",/:-1_/:r;
    r2:"#"=(1_/:r),\:".";
    r3:"#"=(1_r),enlist count[first r]#".";
    r4:"#"=enlist[count[first r]#"."],(-1_r);
    cr:all("#"=r;r1;r2;r3;r4);
    sum(*).'raze til[count cr],/:'where each cr};

d17p2:{
    a:.intcode.editMemory[.intcode.new x;0;2];
    r:("\n"vs`char$.intcode.getOutput a:.intcode.run[a])except enlist"";
    botPos:first raze til[count r],/:'where each r in "^><v";
    botDir:"^>v<"?r . botPos;
    visited:(0#0b)r;
    visited[botPos 0;botPos 1]:1b;
    path:();
    dirs:(-1 0;0 1;1 0;0 -1);
    run:1b;
    while[run;
        move:0;
        nxt:botPos+dirs botDir;
        while["#"=r . nxt;
            move+:1;
            botPos:nxt;
            visited[nxt 0;nxt 1]:1b;
            nxt:botPos+dirs botDir;
        ];
        if[0<move;
            path,:enlist string move;
        ];
        -1 .[r;botPos;:;"*"];
        nxts:botPos+/:dirs;
        nxts:nxts where "#"=r ./:nxts;
        nxts:nxts where not visited ./:nxts;
        if[0=count nxts; run:0b];
        if[run;
            nxt:first nxts;
            nxtDir:dirs?nxt-botPos;
            turn:(nxtDir-botDir)mod 4;
            $[turn=1; [path,:enlist enlist"R";botDir:(botDir+1)mod 4];
              turn=3; [path,:enlist enlist"L";botDir:(botDir-1)mod 4];
              '"stuck"];
        ];
    ];
    findAbc:{[prefixes;path]
        if[0=count path; :enlist prefixes]; // not actually necessary
        if[path~enlist""; :enlist prefixes];
        cpath:","sv path;
        match:where prefixes~'(count each prefixes)#\:cpath;
        res:raze .z.s[prefixes] each ","vs/:(1+count each prefixes)[match]_\:cpath;
        if[3>count prefixes;
            poss:({x where 20>=count each x}{x,",",y}\[first path;1_path])except prefixes;
            res,:raze .z.s[;path] each prefixes,/:enlist each poss;
        ];
        res};
    abcs:findAbc[();path];
    if[0=count abcs; '"no ABC found?!"];
    abc:first abcs;
    pg:ssr/[","sv path;abc;"ABC"];
    -1 allInput:"\n"sv enlist[pg],abc,(enlist"n";"");
    //-1 " "sv string `long$allInput;
    r:.intcode.runI[a;`long$allInput];
    last .intcode.getOutput r};

d17p1whitebox:{
    a:"J"$","vs raze x;
    r:a[935] cut".#"(where 1182_(first a[11 12]except 0 1)#a)mod 2;
    //rest same as regular part1
    r1:"#"=".",/:-1_/:r;
    r2:"#"=(1_/:r),\:".";
    r3:"#"=(1_r),enlist count[first r]#".";
    r4:"#"=enlist[count[first r]#"."],(-1_r);
    cr:all("#"=r;r1;r2;r3;r4);
    sum(*).'raze til[count cr],/:'where each cr};

d17p2whitebox:{
    a:"J"$","vs raze x;
    w:a[935];
    cend:(first a[11 12]except 0 1);
    r:w cut(where 1182_cend#a)mod 2;
    tilePos:raze til[count r],/:'where each r;
    cx:tilePos[;1];
    cy:tilePos[;0];
    sum(1+cend+cx+cy*w+cx)+til count tilePos};

/
No example input provided
