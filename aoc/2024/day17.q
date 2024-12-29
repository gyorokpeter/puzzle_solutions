.d17.read:{[state;param]
    if[param within 0 3;:param];
    if[param within 4 6;:state[`a`b`c param-4]];
    {'x}"unknown param ",string param;
    };
bitxor:{0b sv (0b vs x)<>0b vs y};
.d17.step:{[state]
    if[state[`ip]>=count state[`code];:state];
    instr:state[`code;0 1+state`ip];
    op:instr 0;
    $[op=0;
        state[`a]:state[`a]div `long$2 xexp .d17.read[state;instr 1];
      op=1;
        state[`b]:bitxor[state`b;instr 1];
      op=2;
        state[`b]:.d17.read[state;instr 1]mod 8;
      op=3;
        $[0=state`a;state[`ip]+:2;state[`ip]:instr 1];
      op=4;
        state[`b]:bitxor[state`b;state`c];
      op=5;
        state[`out],:.d17.read[state;instr 1]mod 8;
      op=6;
        state[`b]:state[`a]div `long$2 xexp .d17.read[state;instr 1];
      op=7;
        state[`c]:state[`a]div `long$2 xexp .d17.read[state;instr 1];
    {'x}"unknown instruction ",string instr 0];
    if[op<>3;state[`ip]+:2];
    state};
.d17.parse:{a:"\n\n"vs"\n"sv x;
    b:": "vs/:"\n"vs a 0;
    reg:(`$lower last each" "vs/:b[;0])!"J"$b[;1];
    code:"J"$","vs last": "vs a 1;
    reg,`code`ip`out!(code;0;`long$())};
d17p1:{
    ","sv string .d17.step/[.d17.parse x][`out]};
d17p2:{state:.d17.parse x;
    goal:(raze -3#/:0b vs/:state`code);
    mainOps:{x where 1=first each x}2 cut state`code;
    shiftMask:-3#0b vs mainOps[0;1];
    outMask:-3#0b vs mainOps[1;1];
    nodes:enlist`seq`constr!(();());
    pos:0;
    while[pos<9+count goal;
        nodes:$[pos>=count goal;
            update seq:(000b,/:seq) from nodes;
            raze{update seq:((-3#/:0b vs/:til 8),'seq)from 8#enlist x}each nodes
        ];
        if[pos<count goal;
            nodes:update b1:(3#/:seq)<>\:shiftMask from nodes;
            nodes:update b2:b1<>\:outMask from nodes;
            nodes:update offset:pos+2 sv/:b1 from nodes;
            nodes:update ex:b2<>\:goal pos+til 3 from nodes;
            nodes:update constr:(constr,'enlist each (offset(;)'ex)) from nodes;
        ];
        nodes:update toMatch:constr@'where each constr[;;0]<=pos from nodes;
        nodes:update matchVal:-3#/:/:(neg toMatch[;;0])_\:'seq from nodes;
        nodes:select from nodes where all each matchVal~''toMatch[;;1];
        nodes:select seq, constr from nodes;
        pos+:3;
        show pos,count nodes;
    ];
    exec min 2 sv/:seq from nodes};
d17p2brute:{state:.d17.parse x;
    i:0;
    while[1b;
        if[0=i mod 1000;-1 string i];
        state[`a]:i;
        state2:{[s]s2:.d17.step s;if[not s2[`out]~count[s2`out]#s2`code;:s];s2}/[state];
        if[state2[`out]~state`code;:i];
        i+:1;
    ]};

/

.d17.step[`c`ip`code!(9;0;2 6)][`b]   //1
.d17.step/[`a`ip`code`out!(10;0;5 0 5 1 5 4;())][`out]    //0 1 2
.d17.step/[`a`ip`code`out!(2024;0;0 1 5 4 3 0;())][`out`a]    //(4 2 5 6 7 7 7 7 3 1 0;0)
.d17.step[`b`ip`code!(29;0;1 7)][`b]   //26
.d17.step[`b`c`ip`code!(2024;43690;0;4 0)][`b]    //44354

x:();
x,:enlist"Register A: 729";
x,:enlist"Register B: 0";
x,:enlist"Register C: 0";
x,:enlist"";
x,:enlist"Program: 0,1,5,4,3,0";

x2:();
x2,:enlist"Register A: 2024";
x2,:enlist"Register B: 0";
x2,:enlist"Register C: 0";
x2,:enlist"";
x2,:enlist"Program: 0,3,5,4,3,0";

d17p1 x //"4,6,3,5,6,3,5,2,1,0"
//d17p2 x //doesn't work on the example
d17p2brute x2   //117440
