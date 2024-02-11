d13:{[part;x]
    a:"\n\n"vs"\n"sv x;
    dot:"J"$","vs/:"\n"vs a 0;
    ins:"SJ"$/:"="vs/:last each" "vs/:"\n"vs a 1;
    if[part=1; ins:1#ins];
    dot:{[dot;ins0]
        //ins0:ins 0;
        coord:`x`y?ins0[0];
        ind:where dot[;coord]>ins0[1];
        distinct .[dot;(ind;coord);(2*ins0[1])-]}/[dot;ins];
    if[part=1; :count dot];
    dot:reverse each dot;
    out:.[;;:;1]/[(1+max dot)#0;dot];
    letter:2 sv/:raze each 4#/:/:flip 5 cut/:out;
    ocr:6922137 15329694 6916246 0N 16312463 16312456 6917015 10090905 0N 3215766
        10144425 8947855 0N 0N 0N 15310472 0N 15310505 0N 0N 10066326 0N 0N 0N 0N 15803535
        !.Q.A;
    ocr letter};
d13p1:{d13[1;x]};
d13p2:{d13[2;x]};

/
x:"\n"vs"6,10\n0,14\n9,10\n0,3\n10,4\n4,11\n6,0\n6,12\n4,1\n0,13\n10,12\n3,4\n3,0\n8,4\n1,10";
x,:"\n"vs"2,14\n8,10\n9,0\n\nfold along y=7\nfold along x=5";

d13p1 x //17
//d13p2 x   //no example provided for part 2
