.d22.move:{[poss]
    h:(1+max raze poss[;;0 1])#0;
    moved:count[poss]#0b;
    i:0;
    while[i<count poss;
        curr:poss i;
        fp:distinct curr[;0 1];
        nz:1+max h ./:fp;
        move:min[curr[;2]-nz];
        moved[i]:move>0;
        poss[i;;2]-:move;
        h:.[;;:;max poss[i;;2]]/[h;fp];
        i+:1;
    ];
    (poss;moved)};
d22:{pos:"J"$","vs/:/:"~"vs/:x;
    poss:pos[;0]+/:'{c:abs max each x;(til each 1+c)*\:'0^x div c}pos[;1]-pos[;0];
    zs:min each poss[;;2]; zi:iasc zs;
    poss:poss zi;
    poss:first .d22.move poss;
    rs:last each .d22.move each poss _/:til count poss;
    (sum all each 0=rs;sum sum each rs)};
d22p1:{d22[x][0]};
d22p2:{d22[x][1]};



/
x:"\n"vs"1,0,1~1,2,1\n0,0,2~2,0,2\n0,2,3~2,2,3\n0,0,4~0,2,4\n2,0,5~2,2,5\n0,1,6~2,1,6\n1,1,8~1,1,9";

d22 x //5 7
