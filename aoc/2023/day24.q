d24p1a:{[bounds;x]
    lines:"J"$", "vs/:/:" @ "vs/:x;
    lines2:2#/:/:lines;
    m:lines[;1;1]%lines[;1;0];
    b:lines[;0;1]-m*lines[;0;0];
    intersect:{[m0;b0;m1;b1]x:(b1-b0)%(m0-m1);y:b0+m0*x;x,y};
    pi:raze til[-1+count m],/:'(1+til[-1+count m])_\:til count m;
    meet:.[intersect]'[raze each(m,'b)pi];
    meet[where 0>(meet[;0]-lines[pi[;0];0;0])%lines[pi[;0];1;0];0]:-0w;
    meet[where 0>(meet[;0]-lines[pi[;1];0;0])%lines[pi[;1];1;0];1]:-0w;
    sum all each meet within\:bounds};
d24p1:{d24p1a[200000000000000 400000000000000;x]};
d24p2:{lines:"J"$", "vs/:/:" @ "vs/:x;
    //stolen from: https://pastebin.com/NmR6ZDXL
    //explanation: https://old.reddit.com/r/adventofcode/comments/18pnycy/2023_day_24_solutions/kepu26z/
    crossProd:{((x[1]*y[2])-x[2]*y[1];(x[2]*y[0])-x[0]*y[2];(x[0]*y[1])-x[1]*y[0])};
    crossMtx:{((0;neg x 2;x 1);(x 2;0;neg x 0);(neg x 1;x 0;0))};
    rhs:(crossProd[lines[1;0];lines[1;1]]-crossProd[lines[0;0];lines[0;1]]),
        (crossProd[lines[2;0];lines[2;1]]-crossProd[lines[0;0];lines[0;1]]);
    m1:(crossMtx[lines[0;1]]-crossMtx[lines[1;1]]),(crossMtx[lines[0;1]]-crossMtx[lines[2;1]]);
    m2:(crossMtx[lines[1;0]]-crossMtx[lines[0;0]]),(crossMtx[lines[2;0]]-crossMtx[lines[0;0]]);
    res:inv[`float$m1,'m2]mmu`float$rhs;
    `long$sum 3#res};

/
x:"\n"vs"19, 13, 30 @ -2,  1, -2\n18, 19, 22 @ -1, -1, -2\n20, 25, 34 @ -2, -2, -4";
x,:"\n"vs"12, 31, 28 @ -1, -2, -1\n20, 19, 15 @  1, -5, -3";

d24p1a[7 27;x] //2
d24p1 x //0
d24p2 x //47
