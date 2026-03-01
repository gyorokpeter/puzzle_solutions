d1p1:{sum "J"$x};
d1p2:{d:"J"$x;
    while[1b;
        r:where 1<count each group sums d;
        if[0<count r; :first r];
        d,:d
    ]};

/
x:"\n"vs"+1\n-2\n+3\n+1";

d1p1 x  //3
d1p2 x  //2
