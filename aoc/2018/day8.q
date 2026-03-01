d8prep:{
    n:"J"$" "vs first x;
    tree:-1#{[np]
        c:np[0][0];
        m:np[0][1];
        if[0=c;
            res:((2+m)_np 0;(();m#2_np 0));
            :res
        ];
        rs:1_.z.s\[c;(2_np[0];())];
        res:(m _last[rs][0];(rs[;1];m#last[rs][0]));
        res}[(n;())];
    tree};
d8p1:{
    tree:d8prep x;
    sum{sum last[x],raze .z.s each first x}each tree};
d8p2:{
    tree:d8prep x;
    sum{$[0=count first x;sum 0,last x;sum 0,.z.s each first[x][-1+last x]]}each tree};

/
x:enlist "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2";

d8p1 x  //138
d8p2 x  //66
