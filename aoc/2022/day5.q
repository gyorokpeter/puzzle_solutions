d5:{[op;x]a:"\n\n"vs"\n"sv x;
    st:reverse each trim flip(4 cut/:-1_"\n"vs a 0)[;;1];
    ins:0 -1 -1+/:"J"$(" "vs/:"\n"vs a 1)[;1 3 5];
    st2:{[op;x;y]x[y 2],:op neg[y 0]#x[y 1];
        x[y 1]:neg[y 0]_x[y 1];x}[op]/[st;ins];
    last each st2};
d5p1:{d5[reverse;x]};
d5p2:{d5[::;x]};

/
x:"\n"vs"    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 \n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2";

d5p1 x  //CMZ
d5p2 x  //MCD
