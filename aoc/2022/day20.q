.d20.move:{[b;i]
    c:count b;
    n:b[i];
    op:n`p;
    np:op+n[`v];
    if[not np within 1,c-1;
        np:((np-1) mod c-1)+1];
    $[op<=np;
        b:update p-1 from b where p within (op+1;np);
        b:update p+1 from b where p within (np;op-1)];
    b[i;`p]:np;
    b};
.d20.mix:{[b].d20.move/[b;til count b]};
d20:{[part;x]
    a:"J"$x;
    c:count a;
    b:([]p:til c;v:a*$[part=2;811589153;1]);
    b:.d20.mix/[$[part=2;10;1];b];
    p0:exec first p from b where v=0;
    exec sum v from b where p in (p0+1000 2000 3000) mod c};
d20p1:{d20[1;x]};
d20p2:{d20[2;x]};

/
x:"\n"vs"1\n2\n-3\n3\n-2\n0\n4";

d20p1 x //3
d20p2 x //1623178306
