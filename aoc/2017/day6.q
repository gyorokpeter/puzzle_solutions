d6:{a:"J"$"\t"vs first x;
    c:count a;
    l:enlist a;
    while[1b;
        p:first where a=max a;
        n:a p;
        a[p]:0;
        a+:n div c;
        a[(p+1+til n mod c)mod c]+:1;
        if[a in l;:(l;a)];
        l,:enlist a;
    ];
    };
d6p1:{count first d6 x};
d6p2:{la:d6 x;count[la 0]-la[0]?la 1};

/
d6p1 enlist"0\t2\t7\t0" //5
d6p2 enlist"0\t2\t7\t0" //4
