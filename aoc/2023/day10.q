.d10.nm:()!();
.d10.nm[" "]:(0N 0N;0N 0N);
.d10.nm["."]:(0N 0N;0N 0N);
.d10.nm["|"]:(-1 0;1 0);
.d10.nm["-"]:(0 -1;0 1);
.d10.nm["L"]:(-1 0;0 1);
.d10.nm["J"]:(-1 0;0 -1);
.d10.nm["7"]:(1 0;0 -1);
.d10.nm["F"]:(1 0;0 1);

d10:{
    start:first raze til[count x],/:'where each x="S";
    nxts:start+/:(-1 0;0 1;1 0;0 -1);
    stt:(asc each .d10.nm)?asc(nxts where start in/:nxts+/:'.d10.nm x ./:nxts)-\:start;
    x1:.[x;start;:;stt];
    d:0N+`long$x; //empty distance matrix
    queue:enlist start;
    step:0;
    while[count queue;
        d:.[;;:;step]/[d;queue];
        ts:x1 ./:queue;
        nxts:raze queue+/:'.d10.nm ts;
        nxts:distinct nxts where null d ./:nxts;
        step+:1;
        queue:nxts;
    ];
    (x1;d)};
d10p1:{xd:d10 x;max max xd 1};
d10p2:{xd:d10 x;
    d:0<=xd 1;
    m:"."^`char$32 or d*`int$xd 0;
    m1:".",/:raze each m,''".-"m in\:where 0 1 in/:.d10.nm;
    m2:enlist[count[m1 0]#"."],raze m1(;)'".|"m1 in\:where 1 0 in/:.d10.nm;
    queue:raze(til[count m2],\:/:0,count[m2 0]-1),(0,count[m2]-1),/:\:1+til[count[m2 0]-2];
    while[count queue;
        m2:.[;;:;"o"]/[m2;queue];
        nxts:distinct raze queue+/:\:-1_raze -1 1 0,/:\:-1 1 0;
        nxts:nxts where all each nxts within\:(0 0;(count[m2]-1;count[m2 0]-1));
        nxts:nxts where "."=m2 ./:nxts;
        queue:nxts;
    ];
    m3:first each/:2 cut/:1_/:first each 2 cut 1_m2;
    sum sum"."=m3};

/
x:"\n"vs"..F7.\n.FJ|.\nSJ.L7\n|F--J\nLJ...";

x2:();
x2,:enlist"..........";
x2,:enlist".S------7.";
x2,:enlist".|F----7|.";
x2,:enlist".||....||.";
x2,:enlist".||....||.";
x2,:enlist".|L-7F-J|.";
x2,:enlist".|..||..|.";
x2,:enlist".L--JL--J.";
x2,:enlist"..........";

x3:();
x3,:enlist".F----7F7F7F7F-7....";
x3,:enlist".|F--7||||||||FJ....";
x3,:enlist".||.FJ||||||||L7....";
x3,:enlist"FJL7L7LJLJ||LJ.L-7..";
x3,:enlist"L--J.L7...LJS7F-7L7.";
x3,:enlist"....F-J..F7FJ|L7L7L7";
x3,:enlist"....L7.F7||L7|.L7L7|";
x3,:enlist".....|FJLJ|FJ|F7|.LJ";
x3,:enlist"....FJL-7.||.||||...";
x3,:enlist"....L---J.LJ.LJLJ...";

x4:();
x4,:enlist"FF7FSF7F7F7F7F7F---7";
x4,:enlist"L|LJ||||||||||||F--J";
x4,:enlist"FL-7LJLJ||||||LJL-77";
x4,:enlist"F--JF--7||LJLJ7F7FJ-";
x4,:enlist"L---JF-JLJ.||-FJLJJ7";
x4,:enlist"|F|F-JF---7F7-L7L|7|";
x4,:enlist"|FFJF7L7F-JF7|JL---7";
x4,:enlist"7-L-JL7||F7|L7F-7F7|";
x4,:enlist"L.L7LFJ|||||FJL7||LJ";
x4,:enlist"L7JLJL-JLJLJL--JLJ.L";

d10p1 x //8
d10p2 x //1
d10p2 x2    //4
d10p2 x3    //8
d10p2 x4    //10
