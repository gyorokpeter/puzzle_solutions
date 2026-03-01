{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `genarch in key`;
        system"l ",path,"/../utils/genarch.q";
    ];
    }[];

.chronal.new:{
    if[not all 10h=type each x; '"string list expected"];
    inp:(trim each x)except enlist"";
    ipr:0N;
    if["#"=first first inp;
        ipr:"J"$last" "vs first inp;
        inp:1_inp;
    ];
    cmds:{a:" "vs x;(`$a[0]),"J"$1_a}each inp;
    regs:6#0;
    (`run;0;cmds;regs;ipr)};

.chronal.bitand:{0b sv (0b vs x)and 0b vs y};
.chronal.bitor:{0b sv (0b vs x)or 0b vs y};

.chronal.ins:()!();
.chronal.ins[`addr]:{[op;reg]reg[op 3]:reg[op 1]+reg[op 2];reg};
.chronal.ins[`addi]:{[op;reg]reg[op 3]:reg[op 1]+op 2;reg};
.chronal.ins[`mulr]:{[op;reg]reg[op 3]:reg[op 1]*reg[op 2];reg};
.chronal.ins[`muli]:{[op;reg]reg[op 3]:reg[op 1]*op 2;reg};
.chronal.ins[`banr]:{[op;reg]reg[op 3]:.chronal.bitand[reg[op 1];reg[op 2]];reg};
.chronal.ins[`bani]:{[op;reg]reg[op 3]:.chronal.bitand[reg[op 1];op 2];reg};
.chronal.ins[`borr]:{[op;reg]reg[op 3]:.chronal.bitor[reg[op 1];reg[op 2]];reg};
.chronal.ins[`bori]:{[op;reg]reg[op 3]:.chronal.bitor[reg[op 1];op 2];reg};
.chronal.ins[`setr]:{[op;reg]reg[op 3]:reg[op 1];reg};
.chronal.ins[`seti]:{[op;reg]reg[op 3]:op 1;reg};
.chronal.ins[`gtir]:{[op;reg]reg[op 3]:`long$op[1]>reg[op 2];reg};
.chronal.ins[`gtri]:{[op;reg]reg[op 3]:`long$reg[op 1]>op 2;reg};
.chronal.ins[`gtrr]:{[op;reg]reg[op 3]:`long$reg[op 1]>reg[op 2];reg};
.chronal.ins[`eqir]:{[op;reg]reg[op 3]:`long$op[1]=reg[op 2];reg};
.chronal.ins[`eqri]:{[op;reg]reg[op 3]:`long$reg[op 1]=op 2;reg};
.chronal.ins[`eqrr]:{[op;reg]reg[op 3]:`long$reg[op 1]=reg[op 2];reg};

.chronal.runD:{[st;d;bp;step]
    reg:st[3];
    ipr:st[4];
    ip:$[not null ipr; reg[ipr];st[1]];
    while[ip within (0;count[st 2]-1);
        ni:st[2;ip];
        reg:.chronal.ins[ni 0][ni;reg];
        if[not null ipr; ip:reg[ipr]];
        ip+:1;
        if[not null ipr; reg[ipr]:ip];
        if[d;if[$[step;1b;ip in bp]; st[0]:`break;st[1]:ip;st[3]:reg; :st]];
    ];
    st[0]:`halt;
    st[1]:ip;
    st[3]:reg;
    st};

.chronal.run:{[st].chronal.runD[st;0b;();0b]};

.genarch.addPlaceholders`chronal;
.chronal.resume:{[st]st[0]:`run;st};
.chronal.isRunning:{[st]st[0]=`run};
.chronal.isTerminated:{[st]st[0]=`halt};
.chronal.getIp:{[st]st[1]};
.chronal.getRegisters:{[st]st[3]};
.chronal.getImmediate:{[st;ip;slot]st[2;ip;slot]};
.chronal.editRegister:{[st;reg;val]if[not reg within 0,count[st 3]-1;'"unknown register"];st[3;reg]:val;st};

.chronal.getMulCount:{[st]st[4]};

.chronal.ipValid:{[st;ip]
    ip within (0;count[st 2]-1)};

.chronal.argSemantics:enlist[`]!enlist();
.chronal.argSemantics[`addr]:("ia";"ia";"oa");
.chronal.argSemantics[`addi]:("ia";"ib";"oa");
.chronal.argSemantics[`mulr]:("ia";"ia";"oa");
.chronal.argSemantics[`muli]:("ia";"ib";"oa");
.chronal.argSemantics[`banr]:("ia";"ia";"oa");
.chronal.argSemantics[`bani]:("ia";"ib";"oa");
.chronal.argSemantics[`borr]:("ia";"ia";"oa");
.chronal.argSemantics[`bori]:("ia";"ib";"oa");
.chronal.argSemantics[`setr]:("ia";"";"oa");
.chronal.argSemantics[`seti]:("ib";"";"oa");
.chronal.argSemantics[`gtir]:("ib";"ia";"oa");
.chronal.argSemantics[`gtri]:("ia";"ib";"oa");
.chronal.argSemantics[`gtrr]:("ia";"ia";"oa");
.chronal.argSemantics[`eqir]:("ib";"ia";"oa");
.chronal.argSemantics[`eqri]:("ia";"ib";"oa");
.chronal.argSemantics[`eqrr]:("ia";"ia";"oa");

.chronal.opStem:()!();
.chronal.opStem[`addr]:`add;
.chronal.opStem[`addi]:`add;
.chronal.opStem[`mulr]:`mul;
.chronal.opStem[`muli]:`mul;
.chronal.opStem[`bani]:`bitand;
.chronal.opStem[`banr]:`bitand;
.chronal.opStem[`borr]:`bitor;
.chronal.opStem[`bori]:`bitor;
.chronal.opStem[`setr]:`set;
.chronal.opStem[`seti]:`set;
.chronal.opStem[`gtir]:`gt;
.chronal.opStem[`gtri]:`gt;
.chronal.opStem[`gtrr]:`gt;
.chronal.opStem[`eqir]:`eq;
.chronal.opStem[`eqri]:`eq;
.chronal.opStem[`eqrr]:`eq;

.chronal.disasmOne:{[st;ip;cutPoints]
    cmd:st[2;ip];
    op:cmd 0;
    opStem:.chronal.opStem op;
    sem:.chronal.argSemantics[op];
    arg:string 1_cmd;
    regArg:where "a" in/:sem;
    arg[regArg]:"r",/:arg[regArg];
    validArg:where 0<count each sem;
    arg:arg validArg;
    ((ip;`int$();opStem;arg);ip+1)};

.chronal.jumpConditions:()!();
.chronal.jumpConditions[`jnz]:{x[0]<>0};

.chronal.analyzeEffects:{[st]
    r:st[3];
    ip:st[1];
    ipr:st[4];
    cmd:st[2;ip];
    op:cmd 0;
    arg:1_cmd;
    inArgs:();
    outArgs:();
    inVals:();
    sem:.chronal.argSemantics[op];
    inArgIdx:where "i" in/:sem;
    isReg:"a" in/:sem inArgIdx;
    inArgs,:{[ip;x;y;ai]$[x;`$"r.",string y;`$"i.",string[ip],".",string ai]}[ip]'[isReg;arg inArgIdx;1+inArgIdx];
    inVals,:{[r;x;y]$[x;r[y];y]}[r]'[isReg;arg inArgIdx];
    argDisp:string inVals;
    outArgDisp:();
    outArgIdx:where "o" in/:sem;
    ref:arg outArgIdx;
    isReg:"a" in/:sem outArgIdx;
    outArgs,:{$[x;`$"r.",string y;`]}'[isReg;arg outArgIdx];
    outArgDisp,:{$[x;"r",string y;"INVALID"]}'[isReg;arg outArgIdx];
    res:`memRead`memWrite!(inArgs;outArgs);
    jumpArgIdx:where outArgs=`$"r.",string[ipr];
    if[0<count jumpArgIdx;
        nr:.chronal.ins[op][cmd;r];
        nip:1+nr[ipr];
        res[`jumpTarget]:nip;
        res[`jumpTaken]:1b;
    ];
    res[`effInstr]:string[.chronal.opStem op]," ",(", "sv argDisp),$[0<count outArgDisp;" => ",", "sv outArgDisp;""];
    res};

.genarch.register`chronal;
