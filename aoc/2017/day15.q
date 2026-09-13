d15:{[x;n;fa;fb]
    p:"J"$last each" "vs/:x;
    a:p 0;b:p 1;
    chunksize:1000000;
    start:0;
    total:0;
    while[(0N!start)<n;
        as:1_fa\[chunksize;a];
        bs:1_fb\[chunksize;b];
        total+:sum(as mod 65536)=bs mod 65536;
        start+:chunksize;
        a:last as;
        b:last bs;
    ];
    total};
d15p1:{d15[x;40000000;{[a](a*16807)mod 2147483647};{[b](b*48271)mod 2147483647}]};
d15p2:{d15[x;5000000;{[a]while[[a:(a*16807)mod 2147483647;a mod 4]];a};
    {[b]while[[b:(b*48271)mod 2147483647;b mod 8]];b}]};

/
x:("Generator A starts with 65";"Generator B starts with 8921");

d15p1 x  //588 over 60s
d15p2 x  //309 over 70s
