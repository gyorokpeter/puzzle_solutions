mulInv:{[a;b]
    if[b=1; :1];
    b0:b; x0:0; x1:1;
    while[a>1;
        q:a div b;
        t:b; b:a mod b; a:t;
        t:x0; x0:x1-q*x0; x1:t;
    ];
    if[x1<0; x1+:b0];
    x1};
//eqs:list of (n;a) pairs where x === a (mod n)
lc:{[eqs]
    prod:prd eqs[;0];
    p:prod div eqs[;0];
    sum[eqs[;1]*mulInv'[p;eqs[;0]]*p]mod prod};
d13p1:{
    st:"J"$x 0;
    per:("J"$","vs x 1)except 0N;
    nxt:neg[st] mod per;
    take:first where nxt=min nxt;
    nxt[take]*per[take]};
d13p2:{
    per:"J"$","vs x 1;
    ind:where not null per;
    per2:per ind;
    lc[per2,'neg[ind]mod per2]};

/
x:"\n"vs"939\n7,13,x,x,59,x,31,19";

d13p1 x //295
d13p2 x //1068781

d13p2 "\n"vs"x\n17,x,13,19"         //3417
d13p2 "\n"vs"x\n67,7,59,61"         //754018
d13p2 "\n"vs"x\n67,x,7,59,61"       //779210
d13p2 "\n"vs"x\n67,7,x,59,61"       //1261476
d13p2 "\n"vs"x\n1789,37,47,1889"    //1202161486
