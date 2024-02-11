d25:{
    a:{?[;;" "]'[x<>".";x]}"\n"vs x;
    a:{a:x[0];i:x[1];
        a0:a;
        move:(a=">")and" "=1 rotate/:a;
        a:?[;;" "]'[not move;a]^?[;">";" "]'[-1 rotate/:move];
        move:(a="v")and" "=1 rotate a;
        a:?[;;" "]'[not move;a]^?[;"v";" "]'[-1 rotate move];
        (a;$[a~a0;i;i+1])}/[(a;1)];
    last a};

/
x:"v...>>.vv>\n.vv>>.vv..\n>>.>v>...v\n>>v>>.>.v.\nv>v.vv.v..\n>.>>..v...\n.vv.";
x,:".>.>v.\nv.v..>>v.v\n....v..v.>";
d25 x
