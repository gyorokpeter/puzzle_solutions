d11:{[d;r;x]
    a:"\n"vs/:"\n\n"vs"\n"sv x;
    it:"J"$4_/:" "vs/:a[;1]except\:",";
    its:raze it;
    itm:(0,-1_sums count each it)cut til count its;
    op0:6_/:" "vs/:a[;2];
    op:?[op0[;1]like"old";count[op0]#{x*x};(("*+"!(*;+))op0[;0;0])@'"J"$op0[;1]];
    dv:"J"$last each" "vs/:a[;3];
    throw:reverse each"J"$last each/:" "vs/:/:a[;4 5];
    pdv:prd dv;
    st:(itm;its;count[it]#0);
    step:{[throw;op;d;dv;pdv;st;i]
        itm:st 0;its:st 1;tc:st 2;
        ii:itm i;
        tc[i]+:count ii;
        w:((op[i]@'its ii)div d)mod pdv;
        its[ii]:w;
        itm:@[;;,;]/[itm;throw[i]0=w mod dv[i];ii];
        itm[i]:"j"$();
        (itm;its;tc)}[throw;op;d;dv;pdv];
    round:step/[;til count itm];
    mb:last round/[r;st];
    prd 2#desc mb};
d11p1:{d11[3;20;x]};
d11p2:{d11[1;10000;x]};

/
x:"\n"vs"Monkey 0:\n  Starting items: 79, 98\n  Operation: new = old * 19\n  Test: divisible by 23\n    If true: throw to monkey 2\n    If false: throw to monkey 3\n";
x,:"\n"vs"Monkey 1:\n  Starting items: 54, 65, 75, 74\n  Operation: new = old + 6\n  Test: divisible by 19\n    If true: throw to monkey 2\n    If false: throw to monkey 0\n";
x,:"\n"vs"Monkey 2:\n  Starting items: 79, 60, 97\n  Operation: new = old * old\n  Test: divisible by 13\n    If true: throw to monkey 1\n    If false: throw to monkey 3\n";
x,:"\n"vs"Monkey 3:\n  Starting items: 74\n  Operation: new = old + 3\n  Test: divisible by 17\n    If true: throw to monkey 0\n    If false: throw to monkey 1";

d11p1 x //10605
d11p2 x //2713310158
