d18:{[size;visited]
    goal:2#size-1;
    queue:enlist 0 0;
    step:0;
    while[count queue;
        if[goal in queue; :step];
        step+:1;
        visited:.[;;:;1b]/[visited;queue];
        nxts:raze queue+/:\:(-1 0;0 1;1 0;0 -1);
        nxts:nxts where all each nxts within\:(0;size-1);
        nxts:nxts where not visited ./:nxts;
        queue:distinct nxts;
    ];
    0N};
d18p1:{[size;cutoff;x]
    a:reverse each"J"$","vs/:x;
    visited:(2#size)#0b;
    visited:.[;;:;1b]/[visited;cutoff#a];
    d18[size;visited]};
d18p2:{[size;cutoff;x]
    a:reverse each"J"$","vs/:x;
    visited:(2#size)#0b;
    visited:.[;;:;1b]/[visited;cutoff#a];
    step:cutoff;
    while[step<count a;
        visited:.[visited;a step;:;1b];
        if[null d18[size;visited]; :x step];
        step+:1;
        if[0=step mod 10;show step];
    ];
    {'x}"no solution"};

/

x:"\n"vs"5,4\n4,2\n4,5\n3,0\n2,1\n6,3\n2,4\n1,5\n0,6\n3,3\n2,6\n5,1\n1,2\n5,5\n2,5\n6,5\n1,4\n0,4\n6,4\n1,1\n6,1\n1,0\n0,5\n1,6\n2,0";

d18p1[7;12;x]   //22
//d18p1[71;1024;x]
d18p2[7;12;x]  //"6,1"
//d18p2[71;1024;x]
