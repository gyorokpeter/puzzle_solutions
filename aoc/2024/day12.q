.d12.getRegions:{
    visited:x<>x;
    regions:();
    while[count p:raze til[count x],/:'where each not visited;
        pos:();
        t:x . first p;
        queue:1#p;
        while[count queue;
            pos,:queue;
            nxts:raze pos+/:\:(-1 0;0 1;1 0;0 -1);
            nxts:nxts where t=x ./:nxts;
            queue:distinct nxts except pos;
        ];
        regions,:enlist pos;
        visited:.[;;:;1b]/[visited;pos];
    ];
    regions};
d12p1:{
    r:.d12.getRegions x;
    area:count each r;
    perim:count each (raze each r+/:\:\:(-1 0;0 1;1 0;0 -1)) except'r;
    sum area*perim};
.d12.sides:{sum each sum each/:1<>/:1_/:/:deltas each/:-10,/:/:{x[;;1]@'group each x[;;0]}asc each x};
d12p2:{
    r:.d12.getRegions x;
    area:count each r;
    sidesLeft:.d12.sides reverse each/:(r+\:\:0 -1)except'r;
    sidesRight:.d12.sides reverse each/:(r+\:\:0 1)except'r;
    sidesTop:.d12.sides (r+\:\:-1 0)except'r;
    sidesBottom:.d12.sides (r+\:\:1 0)except'r;
    sum area*sidesLeft+sidesRight+sidesTop+sidesBottom};

/

x:();
x,:enlist"RRRRIICCFF";
x,:enlist"RRRRIICCCF";
x,:enlist"VVRRRCCFFF";
x,:enlist"VVRCCCJFFF";
x,:enlist"VVVVCJJCFE";
x,:enlist"VVIVCCJJEE";
x,:enlist"VVIIICJJEE";
x,:enlist"MIIIIIJJEE";
x,:enlist"MIIISIJEEE";
x,:enlist"MMMISSJEEE";

d12p1 x //1930
d12p2 x //1206
