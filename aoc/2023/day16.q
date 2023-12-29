.d16.dmap:enlist[()]!enlist[()];
.d16.dmap[(0;".")]:enlist 0;
.d16.dmap[(0;"|")]:enlist 0;
.d16.dmap[(0;"-")]:1 3;
.d16.dmap[(0;"/")]:enlist 1;
.d16.dmap[(0;"\\")]:enlist 3;
.d16.dmap[(1;".")]:enlist 1;
.d16.dmap[(1;"|")]:0 2;
.d16.dmap[(1;"-")]:enlist 1;
.d16.dmap[(1;"/")]:enlist 0;
.d16.dmap[(1;"\\")]:enlist 2;
.d16.dmap[(2;".")]:enlist 2;
.d16.dmap[(2;"|")]:enlist 2;
.d16.dmap[(2;"-")]:1 3;
.d16.dmap[(2;"/")]:enlist 3;
.d16.dmap[(2;"\\")]:enlist 1;
.d16.dmap[(3;".")]:enlist 3;
.d16.dmap[(3;"|")]:0 2;
.d16.dmap[(3;"-")]:enlist 3;
.d16.dmap[(3;"/")]:enlist 2;
.d16.dmap[(3;"\\")]:enlist 0;
.d16.light:{[x;start]
    emap:4#enlist x<>x;
    queue:enlist start;
    while[count queue;
        emap:.[;;:;1b]/[emap;queue[;2 0 1]];
        nxts:raze queue,/:'.d16.dmap queue[;2],'x ./:queue[;0 1];
        nxts[;0 1]:nxts[;0 1]+'(-1 0;0 1;1 0;0 -1)nxts[;3];
        nxts:nxts where all each nxts[;0 1]within'\:(0,count[x]-1;0,count[x 0]-1);
        nxts:nxts where not emap ./:nxts[;3 0 1];
        queue:nxts[;0 1 3];
    ];
    sum sum any emap};
d16p1:{.d16.light[x;0 0 1]};
d16p2:{starts:(til[count x]cross(0 1;(count[x 0]-1;3))),
    (til[count x 0]cross(0 2;(count[x]-1;0)))[;1 0 2];
    max .d16.light[x]each starts};


/
x:"\n"vs".|...\\....\n|.-.\\.....\n.....|-...\n........|.\n..........";
x,:"\n"vs".........\\\n..../.\\\\..\n.-.-/..|..\n.|....-|.\\\n..//.|....";

d16p1 x //46
d16p2 x //51
