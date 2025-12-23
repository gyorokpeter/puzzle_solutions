.d22.shuffle:{[c;x]
    .d22.incr:enlist[0N]!enlist[0#0];
    b:{[c;x]$[x~"deal into new stack";reverse;
      x like "deal with increment*";
        [d:"J"$last" "vs x;if[not d in key .d22.incr; .d22.incr[d]:iasc (d*til c)mod c];@[;.d22.incr[d]]];
      x like "cut*";
        [d:"J"$last" "vs x;$[d>0;{[d;x](d _x),d#x}[d];{[d;x](d#x),d _x}[d]]];
      {'"unknown:",x}[x]]}[c]each x;
    deck:til c;
    {y x}/[deck;b]};

d22p1:{[c;x].d22.shuffle[c;x]?2019};

madd:{[a;b;m](a+b)mod m};
mmul:{[a;b;m]
    b:b mod m;
    r:0;
    while[b>0;
        if[1=b mod 2;r:madd[r;a;m]];
        b:b div 2;
        a:madd[a;a;m];
    ];
    r};
mexp:{[a;b;m]
    r:1;
    while[b>0;
        if[1=b mod 2;r:mmul[r;a;m]];
        b:b div 2;
        a:mmul[a;a;m];
    ];
    r};
minv:{[a;m]
    mexp[a;m-2;m]};

d22p2:{[c;iters;x]
    b:{[c;x]$[x~"deal into new stack";{[c;x]x[1]:mmul[x[1];-1;c];x[0]:madd[x[0];x[1];c];x}[c];
      x like "deal with increment*";
        [d:"J"$last" "vs x;{[c;d;x]x[1]:mmul[x[1];minv[d;c];c];x}[c;d]];
      x like "cut*";
        [d:"J"$last" "vs x;{[c;d;x]x[0]:madd[x[0];mmul[x[1];d;c];c];x}[c;d]];
      {'"unknown:",x}[x]]}[c]each x;

    cycle:{y x}/[0 1;b];
    offsetDiff:cycle 0;
    incrementMul:cycle 1;
    increment:mexp[incrementMul;iters;c];
    offset:mmul[cycle 0;mmul[madd[1;neg increment;c];minv[madd[1;neg incrementMul;c];c];c];c];
    card:madd[offset;mmul[increment;2020;c];c];
    card};

/
x:();
x,:enlist"deal into new stack";
x,:enlist"cut -2";
x,:enlist"deal with increment 7";
x,:enlist"cut 8";
x,:enlist"cut -4";
x,:enlist"deal with increment 7";
x,:enlist"cut 3";
x,:enlist"deal with increment 9";
x,:enlist"deal with increment 3";
x,:enlist"cut -1";

d22p1[10;x]
//d22p1[10007;x]
//d22p2[119315717514047;101741582076661;x]
