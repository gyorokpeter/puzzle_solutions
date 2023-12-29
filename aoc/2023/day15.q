.d15.hash:{{(17*x+y)mod 256}/[0;`long$x]};
d15p1:{sum .d15.hash each","vs raze x};
d15p2:{ins:","vs raze x;
    box:{$["="in y;[p:"="vs y;x[.d15.hash p 0;`$p 0]:"J"$p 1];
        "-"in y;[b:first"-"vs y;x[.d15.hash b]_:`$b];
        '`nyi];x}/[256#enlist(`$())!`long$();ins];
    sum sum each box*(1+til 256)*1+til each count each box};


/
x:enlist"rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";

d15p1 x //1320
d15p2 x //145
