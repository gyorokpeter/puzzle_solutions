.d18.valid:{
    {$[-7h=type x;if[not x within 0 9;'"gtfo"];
        0h<>type x;'"gtfo";
        3<>count x;'"gtfo";
        not first[x]in(+;*);'"gtfo";
        .z.s each 1_x]}parse x;
    };
d18p1:{sum {.d18.valid x;value ssr/[reverse x;"().";".()"]}each x};
d18p2e:{
    .d18.valid x;
    x:x except" ";
    while[any x in"(+*";
        level:sums(x="(")-(" ",-1_x)=")";
        split:0,where 0<>deltas level=max level;
        p:split cut x;
        ci:1+2*til count[p] div 2;
        p[ci]:string prd each value each/:"*"vs/:p[ci]except\:"()";
        x:raze p;
    ];
    "J"$x};
d18p2:{sum d18p2e each x};

/
d18p1 enlist"1 + (2 * 3) + (4 * (5 + 6))"   //51
d18p1 enlist"2 * 3 + (4 * 5)"   //26
d18p1 enlist"5 + (8 * 3 + 9 + 3 * 4 * 3)"   //437
d18p1 enlist"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" //12240
d18p1 enlist"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"   //13632
//d18p1 x

d18p2 enlist"1 + 2 * 3 + 4 * 5 + 6" //231
d18p2 enlist"1 + (2 * 3) + (4 * (5 + 6))"   //51
d18p2 enlist"2 * 3 + (4 * 5)"   //46
d18p2 enlist"5 + (8 * 3 + 9 + 3 * 4 * 3)"   //1445
d18p2 enlist"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" //669060
d18p2 enlist"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"   //23340
//d18p2 x
