d21:{[steps;x]
    start:first raze til[count x],/:'where each x="S";
    x:.[x;start;:;"."];
    queue:enlist start;
    do[steps;
        nxts:distinct raze queue+/:\:(-1 0;0 1;1 0;0 -1);
        nxts:nxts where all each nxts within'\:(0,count x;0,count x 0);
        nxts:nxts where "."=x ./:nxts;
        queue:nxts;
    ];
    count queue};
d21p1:{d21[64;x]};
d21p2:{
    steps:26501365;
    start:first raze til[count x],/:'where each x="S";
    x:.[x;start;:;"."];
    spread:{[x;start]
        d:0Nh*x<>x;
        step:0;
        queue:$[0h=type start;start;enlist start];
        while[count queue;
            d:.[;;:;step]/[d;queue];
            nxts:distinct raze queue+/:\:(-1 0;0 1;1 0;0 -1);
            nxts:nxts where all each nxts within'\:(0,count x;0,count x 0);
            nxts:nxts where "."=x ./:nxts;
            nxts:nxts where null d ./:nxts;
            queue:nxts;
            step+:1;
        ];
    d};
    w:count x;
    center:spread[x;start];
    top:spread[x;(w-1;w div 2)];
    bottom:spread[x;(0;w div 2)];
    left:spread[x;(w div 2;w-1)];
    right:spread[x;(w div 2;0)];
    topLeft:spread[x;(w-1;w-1)];
    topRight:spread[x;(w-1;0)];
    bottomLeft:spread[x;(0;w-1)];
    bottomRight:spread[x;0 0];
    cap:{[arr;step]n:raze[arr];sum ((n mod 2)=step mod 2)and n<=step};
    caps:cap/:\:[(center;top;topRight;right;bottomRight;bottom;bottomLeft;left;topLeft);til 2*w];
    lcap:{[w;c;ofs;step]$[step<ofs;0;step<ofs+2*w;c step-ofs;c -2+count[c]+(step-ofs)mod 2]}[w];
    total:lcap[caps 0;0;steps];
    range:0;
    cont:1b;
    while[cont;
        range+:1;
        part:sum lcap[;(w*range-1)+1+w div 2;steps]each caps 1 3 5 7;
        part+:range*sum lcap[;1+w*range;steps]each caps 2 4 6 8;
        total+:part;
        cont:part>0;
    ];
    total};



/
x:"\n"vs"...........\n.....###.#.\n.###.##..#.\n..#.#...#..\n....#.#....\n.##..S####.";
x,:"\n"vs".##..#...#.\n.......##..\n.##.#.####.\n.##..##.##.\n...........";

d21[6;x]    //16
d21p1 x //42
d21p2 x //not applicable to example
