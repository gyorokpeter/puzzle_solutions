d15:{[part;x]
    a:"J"$/:/:"\n"vs x;
    h:count[a];w:count first a;
    if[part=2;
        oh:h;ow:w;
        a:(5*h)#(5*w)#/:a-1;
        h:count[a];w:count first a;
        a:1+(a+(til[h]div oh)+/:\:(til[w]div ow))mod 9;
    ];
    queue:([]pos:enlist 0 0;len:0);
    target:(h-1;w-1);
    dist:(h;w)#0W;
    dist[0;0]:0;
    while[0<count queue;
        nxts:select from queue where len=min len;
        if[target in nxts[`pos]; :exec first len from nxts where target~/:pos];
        queue:delete from queue where len=min len;
        nxts:raze {x,/:([]npos:x[`pos]+/:(-1 0;0 1;1 0;0 -1))}each nxts;
        nxts:select from nxts where npos[;0] within (0;h-1),npos[;1] within (0;w-1);
        nxts:update len:len+a ./:npos from nxts;
        nxts:select from nxts where len<dist ./:npos;
        dist:exec .[;;:;]/[dist;npos;len] from nxts;
        queue,:select pos:npos, len from nxts;
        queue:0!select min len by pos from queue;
    ];
    '"no solution";
    };
d15p1:{d15[1;x]};
d15p2:{d15[2;x]};

/
x:"1163751742\n1381373672\n2136511328\n3694931569\n7463417111\n1319128137\n1359";
x,:"912421\n3125421639\n1293138521\n2311944581";
d15p1 x
d15p2 x
