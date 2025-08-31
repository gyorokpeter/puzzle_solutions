d12p1:{
    d:first each x;
    p:"J"$1_/:x;
    rel:where d in "FLR";
    drel:d rel;
    prel:p rel;
    f:(1+\(prel div 90)*("LR"!-1 1)drel)mod 4;
    pa:sum prel*(drel="F")*(0 1;1 0;0 -1;-1 0)f;
    ab:where d in "NESW";
    dabs:d ab;
    pabs:p ab;
    pb:sum pabs*("NESW"!(0 1;1 0;0 -1;-1 0))dabs;
    sum abs pa+pb};
d12p2:{
    d:first each x;
    p:"J"$1_/:x;
    st:(0 0;10 1);
    op:()!();
    op["N"]:{x[1;1]+:y;x};
    op["E"]:{x[1;0]+:y;x};
    op["S"]:{x[1;1]-:y;x};
    op["W"]:{x[1;0]-:y;x};
    op["L"]:{x[1]:sum((90 180 270!((0 1;-1 0);(-1 0;0 -1);(0 -1;1 0)))y)*x[1];x};
    op["R"]:{x[1]:sum((270 180 90!((0 1;-1 0);(-1 0;0 -1);(0 -1;1 0)))y)*x[1];x};
    op["F"]:{x[0]+:y*x[1];x};
    est:{y[x;z]}/[st;op d;p];
    sum abs est 0};

/
x:"\n"vs"F10\nN3\nF7\nR90\nF11";

d12p1 x //25
d12p2 x //286
