d14:{[part;x]
    a:"J"$","vs/:/:" -> "vs/:x;
    f:{if[0=count y;:()];c:asc(x;y);x:c 0;y:c 1;$[x[0]=y[0];x[0],/:x[1]+til 1+y[1]-x[1];(x[0]+til 1+y[0]-x[0]),\:x[1]]};
    c:reverse each distinct raze raze f':'[a];
    start:min enlist[0 500],c;
    size:1+max[c]-min[c];
    maxh:max[c[;1]];
    if[part=2; start[1]:min(start 1;500-maxh)];
    b:c-\:start;
    origin:0 500-start;
    end:max b;
    if[part=2; end[0]+:1;end[1]:max(end 1;origin[1]+maxh)];
    map:.[;;:;"#"]/[(1+end)#" ";b];
    if[part=2; map,:enlist (1+end[1])#"#"];

    queue:enlist origin;
    while[count queue;
        pos:last queue;
        finish:0b;
        moved:1b;
        while[moved;
            moved:0b;
            nudge:$[" "=map[pos[0]+1;pos[1]];0;
                " "=map[pos[0]+1;pos[1]-1];-1;
                " "=map[pos[0]+1;pos[1]+1];1;
                0N];
            if[not[" "=map . pos] or (pos[0]>=count map) or (pos[1]<0) or (pos[1]>=count first map); nudge:0N; finish:1b];
            if[not null nudge;
                moved:1b;
                pos+:(1;nudge);
                pos[0]:count[map]^pos[0]+first where not" "=(1+pos[0])_map[;pos[1]];
                queue,:enlist pos;
            ];
        ];
        if[not finish; map:.[map;pos;:;"o"]];
        queue:-1_queue;
        if[finish; queue:()];
    ];
    sum sum "o"=map};
d14p1:{d14[1;x]};
d14p2:{d14[2;x]};

/
x:"\n"vs"498,4 -> 498,6 -> 496,6\n503,4 -> 502,4 -> 502,9 -> 494,9";

d14p1 x //24
d14p2 x //93
