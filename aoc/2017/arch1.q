{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `genarch in key`;
        system"l ",path,"/../utils/genarch.q";
    ];
    }[];

.arch1.new:{
    if[not all 10h=type each x; '"string list expected"];
    inp:(trim x except\:"\r")except enlist"";
    cmds:{a:" "vs x;(`$a[0]),1_a}each inp;
    regs:{x!count[x]#0}asc distinct`$/:{x where x within "az"}first each first each raze 1_/:cmds;
    (`run;0;cmds;regs;0)};  //st[4]: mul count

.arch1.getVal:{[reg;val]$[null v:"J"$val;reg[`$val];v]};

.arch1.runD:{[st;d;bp;step]
    ip:st[1];
    reg:st[3];
    while[ip within (0;count[st 2]-1);
        ni:st[2;ip];
        op:first ni;
        param:1_ni;
        $[op=`set; [reg[`$param 0]:.arch1.getVal[reg;param 1]; ip+:1];
          op=`sub; [reg[`$param 0]-:.arch1.getVal[reg;param 1]; ip+:1];
          op=`mul; [reg[`$param 0]*:.arch1.getVal[reg;param 1]; ip+:1; st[4]+:1;];
          op=`jnz; $[.arch1.getVal[reg;param 0]<>0; ip+:.arch1.getVal[reg;param 1];ip+:1];
        '"invalid instruction"];
        if[d;if[$[step;1b;ip in bp]; st[0]:`break;st[1]:ip;st[3]:reg; :st]];
    ];
    st[0]:`halt;
    st[1]:ip;
    st[3]:reg;
    st};

.arch1.run:{[st].arch1.runD[st;0b;();0b]};

.genarch.addPlaceholders`arch1;
.arch1.resume:{[st]st[0]:`run;st};
.arch1.isRunning:{[st]st[0]=`run};
.arch1.isTerminated:{[st]st[0]=`halt};
.arch1.getIp:{[st]st[1]};
.arch1.getRegisters:{[st]st[3]};
.arch1.getImmediate:{[st;ip;slot]"J"$st[2;ip;slot]};
.arch1.editRegister:{[st;reg;val]if[not reg in key st[3];'"unknown register"];st[3;reg]:val;st};

.arch1.getMulCount:{[st]st[4]};

.arch1.ipValid:{[st;ip]
    ip within (0;count[st 2]-1)};

.arch1.disasmOne:{[st;ip;cutPoints]
    cmd:st[2;ip];
    op:cmd 0;
    ((ip;`int$();cmd 0;1_cmd);ip+1)};

.arch1.argSemantics:enlist[`]!enlist();
.arch1.argSemantics[`set]:("o";"i");
.arch1.argSemantics[`sub]:("io";"i");
.arch1.argSemantics[`mul]:("io";"i");
.arch1.argSemantics[`jnz]:("i";"ij");

.arch1.jumpConditions:()!();
.arch1.jumpConditions[`jnz]:{x[0]<>0};

.arch1.analyzeEffects:{[st]
    r:st[3];
    ip:st[1];
    cmd:st[2;ip];
    op:cmd 0;
    inArgs:();
    outArgs:();
    inVals:();
    sem:.arch1.argSemantics[op];
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
        res[`jumpTaken]:.arch1.jumpConditions[op][inVals];
        argDisp[inArgIdx?jumpArgIdx]:string res`jumpTarget;
    ];
    res[`effInstr]:string[op]," ",(", "sv argDisp),$[0<count outArgDisp;" => ",", "sv outArgDisp;""];
    res};

.genarch.register`arch1;
