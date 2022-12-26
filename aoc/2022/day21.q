d21p1:{a:": "vs/:x;
    val:(`$a[;0])!"F"$a[;1];
    op:raze{d:" "vs x 1;$[3=count d;enlist[`$x 0]!enlist(("+-*/"!(+;-;*;%))d[1;0]),`$d 0 2;()]}each a;
    val:{[op;val]val^:key[op]!value[op][;0].'val 1_/:value[op];val}[op]/[val];
    val`root};
d21p2:{a:": "vs/:x;
    val:enlist[::]!enlist();
    val,:(`$a[;0])!"F"$a[;1];
    val[`humn]:`humn;
    op:raze{d:" "vs x 1;$[3=count d;enlist[`$x 0]!enlist(("+-*/"!(+;-;*;%))d[1;0]),`$d 0 2;()]}each a;
    op[`root;0]:(=);
    val:{[op;val]val,:key[op]!value[op][;0]{$[any -9h<>type each y;x,y;x . y]}'val 1_/:value[op];val}[op]/[val];
    if[0h<>type val[`root;1]; val[`root;1 2]:val[`root;2 1]];
    goalNum:val[`root;2];
    goalOp:val[`root;1];
    while[0h=type goalOp;
        $[-9h=type goalOp 2;[
            goalNum:$[(%)=first goalOp; goalNum*goalOp[2];
                (*)=first goalOp; goalNum%goalOp[2];
                (+)=first goalOp; goalNum-goalOp[2];
                (-)=first goalOp; goalNum+goalOp[2]];
            goalOp:goalOp 1;
        ];[
            goalNum:$[(%)=first goalOp; goalOp[1]%goalNum;
                (*)=first goalOp; goalNum%goalOp[1];
                (+)=first goalOp; goalNum-goalOp[1];
                (-)=first goalOp; goalOp[1]-goalNum];
            goalOp:goalOp 2;
        ]];
    ];
    goalNum};

/
x:"\n"vs"root: pppw + sjmn\ndbpl: 5\ncczh: sllz + lgvd\nzczc: 2\nptdq: humn - dvpt\ndvpt: 3\nlfqf: 4\nhumn: 5\nljgn: 2\nsjmn: drzm * dbpl\nsllz: 4\npppw: cczh / lfqf\nlgvd: ljgn * ptdq\ndrzm: hmdt - zczc\nhmdt: 32";

d21p1 x //152
d21p2 x //301
