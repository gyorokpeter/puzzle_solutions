d24:{a:"J"$"/"vs/:x;
    pins:{x group x[;1]}distinct raze til[count a],'/:(a;reverse each a);
    queue:([]pos:enlist 0;total:0;visited:enlist count[a]#0b);
    best:0;
    while[count queue;
        prevq:queue;
        nxts:update nxt:pins pos from queue;
        nxts:raze{(`nxt _ x),/:([]nxt:x`nxt)}each nxts;
        nxts:delete from nxts where visited@'nxt[;0];
        queue:delete nxt from update pos:nxt[;2],total:total+sum each nxt[;1 2],visited:@[;;:;1b]'[visited;nxt[;0]] from nxts;
        best:exec max (best,total) from queue;
    ];
    (best;exec max total from prevq)};
d24p1:{d24[x]0};
d24p2:{d24[x]1};

/
x:"\n"vs"0/2\n2/2\n2/3\n3/4\n3/5\n0/1\n10/1\n9/10";

d24p1 x //31
d24p2 x //19
