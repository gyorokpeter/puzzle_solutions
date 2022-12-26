d13:{[part;x]
    a:.j.k each/:"\n"vs/:"\n\n"vs"\n"sv x;
    cmp:{$[-9 -9h~tt:type each (x;y);signum x-y;
        -9h=tt 0; .z.s[enlist x;y];
        -9h=tt 1; .z.s[x;enlist y];
        [c:min count each (x;y);
            tmp:.z.s'[c#x;c#y];
            $[0<>tr:first (tmp except 0),0;tr;
            signum count[x]-count[y]]
        ]]};
    if[part=1; :sum 1+where -1=.[cmp]'[a]];
    b:raze[a],dl:(enlist enlist 2f;enlist enlist 6f);
    sort:{[cmp;b]
        if[1>=count b; :b];
        cr:cmp[first b]'[1_b];
        left:b 1+where 1=cr;
        right:b 1+where -1=cr;
        .z.s[cmp;left],(1#b),.z.s[cmp;right]};
    b2:sort[cmp;b];
    prd 1+where any b2~\:/:dl};
d13p1:{d13[1;x]};
d13p2:{d13[2;x]};

/
x:"\n"vs"[1,1,3,1,1]\n[1,1,5,1,1]\n\n[[1],[2,3,4]]\n[[1],4]\n\n[9]\n[[8,7,6]]\n\n[[4,4],4,4]\n[[4,4],4,4,4]\n\n[7,7,7,7]\n[7,7,7]\n\n[]\n[3]\n\n[[[]]]\n[[]]\n\n[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]";

d13p1 x //13
d13p2 x //140
