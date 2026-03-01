d22genMap:{[d;tgt;w;h]
    top:({(x+16807)mod 20183}\[w-1;0]+d)mod 20183;
    er:{[d;x]s:(x[0]+48271)mod 20183;s,{[d;x;y](d+x*y)mod 20183}[d]\[s;1_x]}[d]\[h-1;top];
    er[tgt 1;tgt 0]:d mod 20183;
    
    bbef:tgt[0]_er tgt[1]-1;
    btop:(d mod 20183),{[d;x;y](d+x*y)mod 20183}[d]\[(d mod 20183);1_bbef];
    bleft:first each(tgt[0]-1)_/:(1+tgt[1])_er;
    ber:enlist[btop],{[d;x;s]{[d;x;y](d+x*y)mod 20183}[d]\[s;x]}[d]\[btop;bleft];
    er2:(tgt[1]#er),(tgt[0]#/:(tgt[1]_er)),'ber;
    er2 mod 3};
d22p1:{
    d:"J"$last" "vs x[0];
    tgt:"J"$","vs last" "vs x[1];
    w:1+tgt 0;
    h:1+tgt 1;
    map:d22genMap[d;tgt;w;h];
    sum sum map};
d22p2:{
    d:"J"$last" "vs x[0];
    tgt:"J"$","vs last" "vs x[1];
    w:10+tgt 0;
    h:10+tgt 1;
    map:d22genMap[d;tgt;w;h];
    visited:(3;w;h)#0b;
    queue:enlist`x`y`tool`time!0 0 1 0;
    while[0<count queue;
        f:exec time+abs[tgt[1]-x]+abs[tgt[0]-y] from queue;
        nxt:select from queue where f=min f;
        if[(exec max x from nxt)>=count[first map]-1; visited:visited,\:(w;h)#0b; w*:2; map:d22genMap[d;tgt;w;h]];
        if[(exec max y from nxt)>=count[map]-1; h*:2; visited:visited,\:\:h#0b; map:d22genMap[d;tgt;w;h]];
        goal:select from nxt where x=tgt[0], y=tgt[1], tool=1;
        if[0<count goal; :exec min time from goal];
        queue:delete from queue where f=min f;
        visited:.[;;:;1b]/[visited;(;;)'[nxt`tool;nxt`x;nxt`y]];
        nxt2:raze{[map;node]
            ([]x:node[`x]+0 0 1 -1 0;y:node[`y]+1 -1 0 0 0;tool:(4#node[`tool]),0 1 2 except map[node[`y];node[`x]],node[`tool];time:node[`time]+1 1 1 1 7)
        }[map]each nxt;
        nxt3:select from nxt2 where x>=0, y>=0, tool<>map'[y;x], not .[visited]'[(;;)'[tool;x;y]];
        queue:0!select min time by x,y,tool from queue,nxt3;
    ];
    '"stuck";
    };

/
x:"\n"vs"depth: 510\ntarget: 10,10";

d22p1 x //114
d22p2 x //45
