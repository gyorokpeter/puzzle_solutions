{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

.d15.findDest:{[grid;cursor;target;rettype]
    queue:enlist cursor;
    parent:enlist[0N 0N]!enlist 0N 0N;
    iter:0;
    while[0<count queue;
        iter+:1;
        nxts:queue+/:\:(-1 0;0 1;1 0;0 -1);
        nxtt:grid ./:/:nxts;
        nxts:(nxts@'where each 0<>nxtt)except\:value parent;
        parent[raze nxts]:raze (count each nxts)#'enlist each queue;
        queue:raze nxts;
        if[0<count arrive:where target=grid ./:queue;
            foundTarget:queue first arrive;
            :2_reverse parent\[foundTarget];
        ];
    ];
    $[rettype=1;iter-1;()]};

.d15.buildMap:{[a]
    grid:3 3#0N; grid[1;1]:1;
    cursor:origin:1 1;
    run:1b;
    dest:();
    while[run;
        if[0=count dest; dest:.d15.findDest[grid;cursor;0N;0]];
        if[0=count dest; run:0b];
        if[run;
            dir:1+(-1 0;1 0;0 -1;0 1)?delta:dest[0]-cursor;
            dest:1_dest;
            a:.intcode.runI[a;enlist dir];
            out:.intcode.getOutput a;
            run:not .intcode.isTerminated a;
            grid:.[grid;cursor+delta;:;first out];
            if[0<>first out; cursor+:delta];
            if[0=cursor[0]; grid:enlist[(count first grid)#0N],grid;cursor+:1 0;origin+:1 0;dest:dest+\:1 0];
            if[0=cursor[1]; grid:0N,/:grid;cursor+:0 1;origin+:0 1;dest:dest+\:0 1];
            if[cursor[0]=count[grid]-1; grid,:enlist count[first grid]#0N];
            if[cursor[1]=count[first grid]-1; grid:grid,\:0N];
            disp:.["#.x"grid;cursor;:;"*"];
            -1 count[first grid]#"=";
            -1 disp;
        ];
    ];
    (grid;origin)};

d15p1:{
    a:.intcode.new x;
    go:.d15.buildMap[a];
    count .d15.findDest[go 0;go 1;2;0]};
d15p2:{
    a:.intcode.new x;
    go:.d15.buildMap[a];
    grid:go 0;
    origin:first raze til[count grid],/:'where each grid=2;
    .d15.findDest[grid;origin;3;1]};

.d15.buildMapWhitebox:{[a]
    grid:enlist[41#0],raze{a:2 cut x;0,/:(-1_/:raze each(1,/:a[;1];a[;0],\:0)),\:0}each 0+39 cut a[212]>(39*20)#252_a;
    grid[a 153;a 146]:2;
    grid};

d15p1whitebox:{a:"J"$","vs raze x;
    grid:.d15.buildMapWhitebox[a];
    count .d15.findDest[grid;21 21;2;0]};
d15p2whitebox:{a:"J"$","vs raze x;
    grid:.d15.buildMapWhitebox[a];
    origin:first raze til[count grid],/:'where each grid=2;
    .d15.findDest[grid;origin;3;1]};

/
No example input provided
