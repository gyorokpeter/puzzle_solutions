d25:{
    pos:"J"$","vs/:x;
    cons:count[pos]#0;
    conssq:0;
    while[0<count unknown:where 0=cons;
        nxt:first unknown;
        conssq+:1;
        queue:enlist nxt;
        while[0<count queue;
            cons[queue]:conssq;
            unknown:where 0=cons;
            dists:min each sum each/:abs pos[queue]-\:/:pos unknown;
            queue:unknown where dists<=3;
        ];
    ];
    conssq};

/
x:"\n"vs" 0,0,0,0\n 3,0,0,0\n 0,3,0,0\n 0,0,3,0\n 0,0,0,3\n 0,0,0,6\n 9,0,0,0\n12,0,0,0";

x2:"\n"vs"-1,2,2,0\n0,0,2,-2\n0,0,0,-2\n-1,2,0,0\n-2,-2,-2,2\n3,0,2,-1\n-1,3,2,2\n-1,0,-1,0";
x2,:"\n"vs"0,2,1,-2\n3,0,0,0";

x3:"\n"vs"1,-1,0,1\n2,0,-1,0\n3,2,-1,0\n0,0,3,1\n0,0,-1,-1\n2,3,-2,0\n-2,2,0,0\n2,-2,0,-1";
x3,:"\n"vs"1,-1,0,-1\n3,2,0,2";

x4:"\n"vs"1,-1,-1,-2\n-2,-2,0,1\n0,2,1,3\n-2,3,-2,1\n0,2,3,-2\n-1,-1,1,-2\n0,-2,-1,0\n-2,2,3,-1";
x4,:"\n"vs"1,2,2,0\n-1,-2,0,-2";

d25 x   //2
d25 x2  //4
d25 x3  //3
d25 x4  //8
