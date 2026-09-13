.d3.spiralPos:{
    if[x=1; :0 0];
    sq:1+(-1+floor sqrt[-1+x])div 2;
    fst:2+ 4*(sq*(sq-1));
    side:(x-fst)div 2*sq;
    pos:(x-fst)mod 2*sq;
    $[side=0;(sq;(sq-(1+pos)));
      side=1;(sq-(1+pos);neg sq);
      side=2;(neg sq;(1+pos)-sq);
      side=3;((1+pos)-sq;sq);
        "???"]
    };

d3p1:{sum abs .d3.spiralPos x};
d3p2:{
    r:enlist enlist 1;
    n:0;
    while[max[last r]<=x;
        n+:1;
        pr:0^$[1<>n mod 4;last[r[n-5]];last r n-1],r[n-4],$[0=n mod 4;first[r n-3];0];
        c:count[pr];
        head:$[1=n mod 4;0;sum (-2+ 1=n mod 4)#r n-1];
        row:head+`long$(`float$({3&0|2+x-/:\:x}til c)-\:(1,(c-1)#0)) mmu `float$pr;
        if[n=2; row:4 5];
        if[n=3; row:10 11];
        if[n=4; row:23 25];
        r,:enlist row;
    ];
    row:last r;
    first row where row>x};

/
d3p1 1      //0
d3p1 12     //3
d3p1 23     //2
d3p1 1024   //31

d3p2 1  //2
d3p2 2  //4
d3p2 4  //5
d3p2 5  //10
d3p2 10 //11
d3p2 11 //23
d3p2 23 //25
d3p2 25 //26
d3p2 26 //54
