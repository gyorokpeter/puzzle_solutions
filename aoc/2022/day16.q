d16:{[part;dur;x]
    a:(" "vs/:x except\:";,");
    n:`$a[;1]; flow:n!"J"$5_/:a[;4]; edge:n!`$9_/:a;
    n:asc n; flow2:flow n; edge2:n?edge n;
    c:count n;
    edge3:raze til[c],/:'edge2;
    dist:(c;c)#4000000000000000000;
    dist:.[;;:;0]/[dist;{x,'x}til c];
    dist:.[;;:;1]/[dist;edge3];
    dist:{[x;i]x&x[;i]+/:\:x[i;]}/[dist;til c];
    pfi:distinct 0,where 0<flow2;
    dist2:{x[y;y]}[dist;pfi];
    pf:flow2 pfi;
    cpf:count pf;
    queue:enlist`on`pos`time`tflow!(0=til cpf;0;0;0);
    maxflows:enlist[cpf#0b]!enlist 0;
    while[count queue;
        nq:queue;
        nq:raze{x,/:([]npos:where not x`on)}each nq;
        if[count nq;
            nq:update on:@[;;:;1b]'[on;npos], pos:npos, time:1+time+dist2 ./:(pos,'npos) from nq;
            nq:delete from nq where time>=dur;
            nq:update tflow:tflow+(dur-time)*pf npos from nq;
            maxflows|:exec on!tflow from nq;
        ];
        queue:nq;
    ];
    if[part=1; :max maxflows];
    kf:1_/:key maxflows;
    vf:value maxflows;
    max max (0=sum each/:kf and/:\:kf)*vf+/:\:vf};
d16p1:{d16[1;30;x]};
d16p2:{d16[2;26;x]};

x:enlist"Valve AA has flow rate=0; tunnels lead to valves DD, II, BB";
x,:enlist"Valve BB has flow rate=13; tunnels lead to valves CC, AA";
x,:enlist"Valve CC has flow rate=2; tunnels lead to valves DD, BB";
x,:enlist"Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE";
x,:enlist"Valve EE has flow rate=3; tunnels lead to valves FF, DD";
x,:enlist"Valve FF has flow rate=0; tunnels lead to valves EE, GG";
x,:enlist"Valve GG has flow rate=0; tunnels lead to valves FF, HH";
x,:enlist"Valve HH has flow rate=22; tunnel leads to valve GG";
x,:enlist"Valve II has flow rate=0; tunnels lead to valves AA, JJ";
x,:enlist"Valve JJ has flow rate=21; tunnel leads to valve II";

d16p1[x]    //1651
d16p2[x]    //1707
