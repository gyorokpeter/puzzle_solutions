d12:{[part;x]
    a:-97+`int$ssr/[;"SE";"az"]each x;
    st:raze raze each til[count x],/:'/:where each/:x=/:"SE";
    visited:a<>a;
    queue:$[part=1;enlist first st;raze til[count x],/:'where each a=0];
    d:0;
    while[count queue;
        d+:1;
        visited:.[;;:;1b]/[visited;queue];
        nxts:update queue f from ungroup([]f:til count queue;b:queue+/:\:(-1 0;0 1;1 0;0 -1));
        nxts:select from nxts where b[;0]>=0,b[;1]>=0,b[;0]<count a,b[;1]<count first a,not visited ./:b,(a ./:f)>=(a ./:b)-1;
        queue:exec distinct b from nxts;
        if[st[1] in queue; :d];
    ];
    '"no solution"};
d12p1:{d12[1;x]};
d12p2:{d12[2;x]};

/
x:"\n"vs"Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi";

d12p1 x //31
d12p2 x //29
