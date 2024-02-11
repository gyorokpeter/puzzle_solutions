{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `genarch in key`;
        system"l ",path,"/../utils/genarch.q";
    ];
    }[];

.alu.new:{
    if[not 10h=type x; '"string expected"];
    inp:(trim each"\n"vs x except"\r")except enlist"";
    cmds:{a:" "vs x;(`$a[0]),1_a}each inp;
    regs:`x`y`z`w!0 0 0 0;
    (`run;0;cmds;regs;0)};

.alu.getVal:{[reg;val]if[null v:"J"$val;v:reg[`$val]];v};

.alu.runD:{[st;d;bp;step]
    ip:st[1];
    reg:st[3];
    while[ip within (0;count[st 2]-1);
        ni:st[2;ip];
        op:first ni;
        param:1_ni;
        $[
          op=`add; [reg[`$param 0]+:.alu.getVal[reg;param 1]; ip+:1];
          op=`mul; [reg[`$param 0]*:.alu.getVal[reg;param 1]; ip+:1];
          op=`div; [reg[`$param 0]:reg[`$param 0]div .alu.getVal[reg;param 1]; ip+:1];
          op=`mod; [reg[`$param 0]:reg[`$param 0]mod .alu.getVal[reg;param 1]; ip+:1];
          op=`eql; [reg[`$param 0]:`long$reg[`$param 0]=.alu.getVal[reg;param 1]; ip+:1];
          op=`inp; $[0<st[4]; 
                [reg[`$param 0]:"J"$first string st[4]; st[4]:"J"$1_string st[4]; ip+:1];
                [st[0]:`needInput;st[1]:ip;st[3]:reg; :st]];
        '"invalid instruction"];
        if[d;if[$[step;1b;ip in bp]; st[0]:`break;st[1]:ip;st[3]:reg; :st]];
    ];
    st[0]:`halt;
    st[1]:ip;
    st[3]:reg;
    st};

.alu.run:{[st].alu.runD[st;0b;();0b]};

.genarch.addPlaceholders`alu;
.alu.resume:{[st]st[0]:`run;st};
.alu.isRunning:{[st]st[0]=`run};
.alu.isTerminated:{[st]st[0]=`halt};
.alu.needsInput:{[st]st[0]=`needInput};
.alu.getIp:{[st]st[1]};
.alu.getRegisters:{[st]st[3]};
.alu.getInput:{[st]enlist st[4]};
.alu.addInput:{[st;input]st[4]:"J"$input;st};
.alu.getImmediate:{[st;ip;slot]"J"$st[2;ip;slot]};
.alu.editRegister:{[st;reg;val]if[not reg in key st[3];'"unknown register"];st[3;reg]:val;st};

.alu.ipValid:{[st;ip]
    ip within (0;count[st 2]-1)};

.alu.disasmOne:{[st;ip;cutPoints]
    cmd:st[2;ip];
    op:cmd 0;
    ((ip;`int$();cmd 0;1_cmd);ip+1)};

.alu.argSemantics:enlist[`]!enlist();
.alu.argSemantics[`add]:("io";"i");
.alu.argSemantics[`mul]:("io";"i");
.alu.argSemantics[`div]:("io";"i");
.alu.argSemantics[`mod]:("io";"i");
.alu.argSemantics[`eql]:("io";"i");
.alu.argSemantics[`inp]:enlist enlist"o";

.alu.analyzeEffects:{[st]
    r:st[3];
    ip:st[1];
    cmd:st[2;ip];
    op:cmd 0;
    inArgs:();
    outArgs:();
    inVals:();
    sem:.alu.argSemantics[op];
    inArgIdx:1+where "i" in/:sem;
    isReg:cmd[inArgIdx] in string key r;
    inArgs,:{[ip;x;y;ai]$[x;`$"r.",y;`$"i.",string[ip],".",string[ai]]}[ip]'[isReg;cmd inArgIdx;inArgIdx];
    inVals,:{[r;x;y]$[x;r[`$y];"J"$y]}[r]'[isReg;cmd inArgIdx];
    argDisp:string inVals;
    outArgDisp:();
    outArgIdx:1+where "o" in/:sem;
    ref:cmd outArgIdx;
    isReg:ref in string key r;
    outArgs,:{$[x;`$"r.",y;`]}'[isReg; cmd outArgIdx];
    outArgDisp,:{$[x;y;"INVALID"]}'[isReg; cmd outArgIdx];
    res:`memRead`memWrite!(inArgs;outArgs);
    res[`effInstr]:string[op]," ",(", "sv argDisp),$[0<count outArgDisp;" => ",", "sv outArgDisp;""];
    res};

.genarch.register`alu;
