{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `genarch in key`;
        system"l ",path,"/../utils/genarch.q";
    ];
    }[];

.intcode.new:{
    mem:"J"$" "vs ssr[raze[x]except"\r\n";",";" "];
    //(sta;ip;tp;rb;mem;input;output)
    (`run;0;0;0;mem;`long$();`long$())};

.intcode.runD:{[st;d;bp;step]
    ip:st[1];
    tp:st[2];
    rb:st[3];
    mem:st[4];
    input:st[5];
    output:st[6];
    run:1b;
    while[run;
        op:mem[ip] mod 100;
        argc:(1 2 3 4 5 6 7 8 9 99!3 3 1 1 2 2 3 3 1 0)op;
        if[null argc; '"invalid op ",string[op]];
        argm:argc#(mem[ip] div 100 1000 10000)mod 10;
        argv0:mem[ip+1+til argc];
        arga:?[2>argm;argv0;argv0+rb];
        mm:max 0,arga where 1<>argm;
        if[mm>=count mem; mem,:(1+mm-count mem)#0];
        argv:?[argm=1;argv0;mem arga];
        $[op=1; [mem[arga 2]:argv[0]+argv[1]; ip+:1+argc];
          op=2; [mem[arga 2]:argv[0]*argv[1]; ip+:1+argc];
          op=3;[$[tp>=count input; [st[0]:`needInput; run:0b];
            [mem[arga 0]:input[tp]; tp+:1; ip+:1+argc]]];
          op=4; [output,:argv 0; ip+:1+argc];
          op=5; $[argv[0]<>0; ip:argv 1; ip+:1+argc];
          op=6; $[argv[0]=0; ip:argv 1; ip+:1+argc];
          op=7; [mem[arga 2]:0+argv[0]<argv[1]; ip+:1+argc];
          op=8; [mem[arga 2]:0+argv[0]=argv[1]; ip+:1+argc];
          op=9; [rb+:argv 0; ip+:1+argc];
          op=99; [st[0]:`halt; run:0b];
          '"invalid op"
        ];
        if[d;if[$[step;1b;ip in bp]; if[st[0]=`run;st[0]:`break]; run:0b]];
    ];
    st[1]:ip;
    st[2]:tp;
    st[3]:rb;
    st[4]:mem;
    st[5]:input;
    st[6]:output;
    st};

.intcode.run:{[st]
    st[5]:st[2]_st[5];  //cut input
    st[2]:0;            //reset tape pointer
    st[6]:();           //cut output
    .intcode.runD[st;0b;();0b]};

.intcode.runI:{[st;input]
    .intcode.run[.intcode.addInput[st;","sv string input]]};

.genarch.addPlaceholders`intcode;
.intcode.resume:{[st]st[0]:`run;st};
.intcode.isRunning:{[st]st[0]=`run};
.intcode.isTerminated:{[st]st[0]=`halt};
.intcode.needsInput:{[st]st[0]=`needInput};
.intcode.getIp:{[st]st[1]};
.intcode.getRegisters:{[st]enlist[`RB]!enlist st[3]};
.intcode.getStackPointer:{[st]st[3]};
.intcode.getInput:{[st]st[2]_st[5]};
.intcode.addInput:{[st;input]st[5],:"J"$" "vs ssr[input;",";" "];st};
.intcode.getOutput:{[st]st[6]};
.intcode.clearOutput:{[st]st[6]:`long$();st};
.intcode.getMemory:{[st]st[4]};
.intcode.ipValid:{[st;ip]ip within 0,count[st 4]-1};
.intcode.editMemory:{[st;addr;val]st[4;addr]:val;st};

.intcode.disasmOne:{[st;ip;hints]
    cutPoints:$[`cutPoints in key hints; hints`cutPoints;0#0];
    cutPoints:asc distinct cutPoints,st 1;
    labels:$[`memLabels in key hints; hints`memLabels;(0#0)!`$()];
    mem:st[4];
    op:mem[ip] mod 100;
    argc:(1 2 3 4 5 6 7 8 9 99!3 3 1 1 2 2 3 3 1 0)op;
    $[null argc;
        [
            :((ip;enlist[mem ip];`INVALID;());ip+1);
        ];
      any (ip<cutPoints) and (ip+1+argc)>cutPoints;
        [
            :((ip;enlist[mem ip];`INVALID;());ip+1);
        ];
        [
            argm:`abs`imm`rel argc#(mem[ip] div 100 1000 10000)mod 10;
            intc:0^mem[ip+til 1+argc];
            opc:(1 2 3 4 5 6 7 8 9 99!`ADD`MUL`IN`OUT`JNZ`JZ`LT`EQ`ARB`HLT)op;
            :((ip;intc;opc;{[labels;x;y]$[`abs=x;"[",$[y in key labels; labels y;string y],"]";
                `imm=x;string y;`rel=x;"[RB+",string[y],"]";"???"]}[labels]'[argm;1_intc]);ip+count intc);
        ]
    ];
    };

.intcode.analyzeEffects:{[st]
    mem:st[4];
    ip:st[1];
    op:mem[ip] mod 100;
    rb:st[3];
    argc:(1 2 3 4 5 6 7 8 9 99!3 3 1 1 2 2 3 3 1 0)op;
    argm:`abs`imm`rel argc#(mem[ip] div 100 1000 10000)mod 10;
    intc:0^mem[ip+til 1+argc];
    opc:(1 2 3 4 5 6 7 8 9 99!`ADD`MUL`IN`OUT`JNZ`JZ`LT`EQ`ARB`HLT)op;
    arga:{[ip;rb;i;m;v]$[m=`imm;ip+1+i;m=`abs;v;m=`rel;rb+v;0N]}[ip;rb]'[til argc;argm;1_intc];
    inArgs:arga;
    outArgs:0#0;
    if[opc in `ADD`MUL`IN`LT`EQ;
        outArgs,:last inArgs;
        inArgs:-1_inArgs;
    ];
    resolved:string[opc]," ",(", "sv string[mem inArgs]),$[0<count outArgs;" => ",", "sv"[",/:string[outArgs],\:"]";""];
    res:`effInstr`memRead`memWrite!(resolved;inArgs;outArgs);
    if[opc in`JNZ`JZ;
        jumpTarget:mem arga 1;
        checkVal:mem arga 0;
        jumpTaken:$[opc=`JNZ;checkVal<>0;checkVal=0];
        res[`jumpTarget]:jumpTarget;
        res[`jumpTaken]:jumpTaken;
    ];
    res};

.genarch.register`intcode;
