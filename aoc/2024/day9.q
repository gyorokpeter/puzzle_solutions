d9p1:{a:where "J"$/:first x;
    b:a div ?[0=a mod 2;2;0];
    c:sum[not null b]#b;
    c[where null c]:sum[null c]#reverse b except 0N;
    sum c*til count c};
d9p2:{a:"J"$/:first x;
    b:2 cut (0,-1_sums a),'a;
    used:b[;0];
    free:-1_b[;1];
    upos:used[;0]; ulen:used[;1];
    fpos:free[;0]; flen:free[;1];
    pos:count[used]-1;
    while[0<=pos;
        size:ulen pos;
        tgt:where flen>=size;
        tgt2:first tgt where fpos[tgt]<upos pos;
        if[not null tgt2;
            upos[pos]:fpos[tgt2];
            fpos[tgt2]+:size;
            flen[tgt2]-:size;
        ];
        pos-:1;
    ];
    sum sum each til[count used]*upos+'til each ulen};

/

x:enlist"2333133121414131402";

d9p1 x  //1928
d9p2 x  //2858
