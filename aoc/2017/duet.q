{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `genarch in key`;
        system"l ",path,"/../utils/genarch.q";
    ];
    }[];

.duet.new:{
    if[not all 10h=type each x; '"string list expected"];
    inp:(trim x except\:"\r")except enlist"";
    cmds:{a:" "vs x;(`$a[0]),1_a}each inp;
    regs:{x!count[x]#0}asc distinct`$/:{x where x within "az"}first each raze 1_/:cmds;
    (`run;0;cmds;regs;();())};

.duet.getVal:{[reg;val]$[null v:"J"$val;reg[`$val];v]};

.duet.runD:{[st;d;bp;step]
    ip:st[1];
    reg:st[3];
    while[ip within (0;count[st 2]-1);
        ni:st[2;ip];
        op:first ni;
        param:1_ni;
        $[op=`snd; [st[5],:.duet.getVal[reg;param 0]; ip+:1];
          op=`set; [reg[`$param 0]:.duet.getVal[reg;param 1]; ip+:1];
          op=`add; [reg[`$param 0]+:.duet.getVal[reg;param 1]; ip+:1];
          op=`mul; [reg[`$param 0]*:.duet.getVal[reg;param 1]; ip+:1];
          op=`mod; [reg[`$param 0]:reg[`$param 0]mod .duet.getVal[reg;param 1]; ip+:1];
          op=`rcv; $[0<count st[4]; 
                [reg[`$param 0]:first st[4]; st[4]:1_st[4]; ip+:1];
                [st[0]:`needInput;st[1]:ip;st[3]:reg; :st]];
          op=`jgz; $[.duet.getVal[reg;param 0]>0; ip+:.duet.getVal[reg;param 1];ip+:1];
        '"invalid instruction"];
        if[d;if[$[step;1b;ip in bp]; st[0]:`break;st[1]:ip;st[3]:reg; :st]];
    ];
    st[0]:`halt;
    st[1]:ip;
    st[3]:reg;
    st};

.duet.run:{[st].duet.runD[st;0b;();0b]};

.genarch.addPlaceholders`duet;
.duet.resume:{[st]st[0]:`run;st};
.duet.isRunning:{[st]st[0]=`run};
.duet.isTerminated:{[st]st[0]=`halt};
.duet.needsInput:{[st]st[0]=`needInput};
.duet.getIp:{[st]st[1]};
.duet.getRegisters:{[st]st[3]};
.duet.getInput:{[st]st[4]};
.duet.addInput:{[st;input]if[10h=type input;input:"J"$","vs input];st[4],:input;st};
.duet.getOutput:{[st]st[5]};
.duet.clearOutput:{[st]st[5]:();st};
.duet.getImmediate:{[st;ip;slot]"J"$st[2;ip;slot]};
.duet.editRegister:{[st;reg;val]if[not reg in key st[3];'"unknown register"];st[3;reg]:val;st};

.duet.ipValid:{[st;ip]
    ip within (0;count[st 2]-1)};

.duet.disasmOne:{[st;ip;cutPoints]
    cmd:st[2;ip];
    op:cmd 0;
    ((ip;`int$();cmd 0;1_cmd);ip+1)};

.duet.argSemantics:enlist[`]!enlist();
.duet.argSemantics[`set]:("o";"i");
.duet.argSemantics[`add]:("io";"i");
.duet.argSemantics[`mul]:("io";"i");
.duet.argSemantics[`mod]:("io";"i");
.duet.argSemantics[`jgz]:("i";"ij");
.duet.argSemantics[`snd]:enlist enlist"i";
.duet.argSemantics[`rcv]:enlist enlist"o";

.duet.jumpConditions:()!();
.duet.jumpConditions[`jgz]:{x[0]>0};

.duet.analyzeEffects:{[st]
    r:st[3];
    ip:st[1];
    cmd:st[2;ip];
    op:cmd 0;
    inArgs:();
    outArgs:();
    inVals:();
    sem:.duet.argSemantics[op];
    inArgIdx:1+where "i" in/:sem;
    isReg:cmd[inArgIdx] in string key r;
    inArgs,:{[ip;x;y]$[x;`$"r.",y;`$"i.",string[ip],".",y]}[ip]'[isReg;cmd inArgIdx];
    inVals,:{[r;x;y]$[x;r[`$y];"J"$y]}[r]'[isReg;cmd inArgIdx];
    argDisp:string inVals;
    outArgDisp:();
    outArgIdx:1+where "o" in/:sem;
    ref:cmd outArgIdx;
    isReg:ref in string key r;
    outArgs,:{$[x;`$"r.",y;`]}'[isReg; cmd outArgIdx];
    outArgDisp,:{$[x;y;"INVALID"]}'[isReg; cmd outArgIdx];
    res:`memRead`memWrite!(inArgs;outArgs);
    jumpArgIdx:1+where "j" in/:sem;
    if[0<count jumpArgIdx;
        res[`jumpTarget]:ip+inVals inArgIdx?jumpArgIdx;
        res[`jumpTaken]:.duet.jumpConditions[op][inVals];
        argDisp[inArgIdx?jumpArgIdx]:string res`jumpTarget;
    ];
    res[`effInstr]:string[op]," ",(", "sv argDisp),$[0<count outArgDisp;" => ",", "sv outArgDisp;""];
    res};

.genarch.register`duet;
