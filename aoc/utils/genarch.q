{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `html in key`;
        system"l ",path,"/html.q";
    ];
    }[];

.genarch.list:`$();
.genarch.reqFuncs:`new`run`runD`resume`isRunning`isTerminated`needsInput`getIp`getRegisters`getMemory`getInput`getOutput`getImmediate`addInput`clearOutput
    ,`ipValid`disasmOne`editMemory`getStack`editRegister`getStackPointer;

.genarch.addPlaceholders:{[namespace]
    fullNs:`$".",string namespace;
    (` sv fullNs,`needsInput) set {[st]0b};
    (` sv fullNs,`getRegisters) set {[st]()};
    (` sv fullNs,`getImmediate) set {[st;ip;ind]'"unsupported"};
    (` sv fullNs,`getStackPointer) set {[st]0N};
    (` sv fullNs,`getInput) set {[st](::)};
    (` sv fullNs,`addInput) set {[st;input]'"unsupported"};
    (` sv fullNs,`getOutput) set {[st](::)};
    (` sv fullNs,`clearOutput) set {[st]'"unsupported"};
    (` sv fullNs,`getMemory) set {[st]()};
    (` sv fullNs,`getStack) set {[st](::)};
    (` sv fullNs,`editMemory) set {[st;addr;val]'"unsupported"};
    (` sv fullNs,`editRegister) set {[st;r;v]'"unsupported"};
    };

.genarch.register:{[namespace]
    if[not namespace in key `; '"empty namespace"];
    fullNs:`$".",string namespace;
    if[0<count missing:.genarch.reqFuncs except key fullNs;
        '"the following functions are missing from the ",string[fullNs]," namespace: ",", "sv string missing;
    ];
    .genarch.list:asc distinct .genarch.list,namespace;
    };

.html.commandHandlers[`genarch]:`.genarch.gui;

.genarch.initState:(::);
.genarch.state:(::);
.genarch.currentArch:`;
.genarch.caNs:`;
.genarch.breakpoints:();
.genarch.trace:();
.genarch.traceMax:50000;
.genarch.tracePtr:0N;
.genarch.currLineage:"";
.genarch.keepOutput:0b;
.genarch.label:(`long$())!();
.genarch.lastError:"";

.genarch.try:{-105!(x;y;z)};

.genarch.ops:()!();
.genarch.ops[`new]:{.genarch.nuke[]};
.genarch.ops[`hist]:{.genarch.genHistory[x`hist]};
.genarch.ops[`input]:{.genarch.addInput[x`input]};
.genarch.ops[`histOut]:{.genarch.genOutputHistory[]};
.genarch.ops[`clearOutput]:{.genarch.clearOutput[]};

.genarch.gui:{
    if[`code in key x;if[0<count x`code; .genarch.setProgram[x`arch;x`code]; :.html.fastredirect["genarch"]]];
    if[`codebin in key x;if[0<count x`codebin; .genarch.setProgram[x`arch;`byte$x`codebin]; :.html.fastredirect["genarch"]]];
    if[(::)~.genarch.state;
        if[0<count key x; :.html.fastredirect["genarch"]];
         :.genarch.newProgramPage[];
    ];
    if[0<count ops:key[x] inter key[.genarch.ops] except`;
        .genarch.ops[first ops][x];
        :.html.fastredirect["genarch"];
    ];
    if[`ni in key x; .genarch.nextInstruction[]; :.html.fastredirect["genarch"]];
    if[`run in key x; .genarch.continue[]; :.html.fastredirect["genarch"]];
    if[`trace in key x; .genarch.doTrace[]; :.html.fastredirect["genarch"]];
    if[`reset in key x; .genarch.reset[]; :.html.fastredirect["genarch"]];
    if[`tb in key x; .genarch.traceStepBack[]; :.html.fastredirect["genarch"]];
    if[`tf in key x; .genarch.traceStepForward[]; :.html.fastredirect["genarch"]];
    if[`tr in key x; .genarch.traceJumpTo[x`tr]; :.html.fastredirect["genarch"]];
    if[`em in key x; .genarch.editMemory[x`em;x`v]; :.html.fastredirect["genarch"]];
    if[`lineage in key x; .genarch.genLineage[x`lineage]; :.html.fastredirect["genarch"]];
    if[`bp in key x; .genarch.toggleBreakpoint[x`bp]; :.html.fastredirect["genarch"]];
    .html.page["genarch";.genarch.mainPage[]]};

.genarch.newProgramPage:{
    :.html.page["genarch";
        "No code loaded. Please input below:<br>"
        ,.h.htac[`form;`method`enctype!("post";"multipart/form-data");""
            ,"arch: "
            ,.h.htac[`select;enlist[`name]!enlist"arch";
                raze {.h.htac[`option;(enlist[`value]!enlist[string x]),$[x=.genarch.currentArch;enlist[`selected]!enlist"true";()!()];string x]}each .genarch.list]
            ,.h.htac[`input;enlist[`type]!enlist"submit";""]
            ,"<br>"
            ,"code (binary):"
            ,.h.htac[`input;`name`type!("codebin";"file");""],"<br>"
            ,"code (text): <br>"
            ,.h.htac[`textarea;`name`rows`cols!("code";"50";"200");""]
        ]
    ];
    };

.genarch.instrstr:{string[x 2]," ",", "sv x[3]};
.genarch.mainPage:{
    das:.genarch.disasmAll[.genarch.state];
    regs:.genarch.caNs[`getRegisters][.genarch.state];
    mem:.genarch.caNs[`getMemory][.genarch.state];
    stack:.genarch.caNs[`getStack][.genarch.state];
    input:.genarch.caNs[`getInput][.genarch.state];
    output:.genarch.caNs[`getOutput][.genarch.state];
    stackPtr:.genarch.caNs[`getStackPointer][.genarch.state];
    analysis:.genarch.caNs[`analyzeEffects][.genarch.state];
    jdest:$[`jumpTarget in key analysis;analysis`jumpTarget;()];
    jtaken:$[`jumpTaken in key analysis;[
        analysis[`effInstr],:" ",$[analysis`jumpTaken;"jump IS taken";"jump is NOT taken"];
        analysis`jumpTaken];
        0b
    ];
    lineageDisp:"";
    if[0<count .genarch.currLineage;
        lineageDisp:"\n"sv {(x[0]#" "),.h.ha["?tr=",string[x 2];"&gt;"],$[x[2]=.genarch.tracePtr;.h.htc[`b];::]x[3]}each .genarch.currLineage;
    ];
    r:.h.htac[`style;enlist[`type]!enlist"text/css";"body{font-family:Courier New;font-size:16px}td{padding-right:30px}"
        ,".ip{background:rgb(255,255,128)}.top{height:4vh}.pl{float:left;width:48%;height:93vh;overflow:auto}.pr{float:right;width:48%;height:93vh;overflow:auto}"
        ,".jd{background:rgb(",$[jtaken;"192,255,192";"192,192,192"],")}"
        ,$[`memRead in key analysis;(","sv"[data-addr='",/:string[analysis`memRead],\:"']"),"{background:rgb(0,255,0)}";""]
        ,$[`memWrite in key analysis;(","sv"[data-addr='",/:string[analysis`memWrite],\:"']"),"{border:solid 2px rgb(255,0,0)}";""]
        ,$[null stackPtr;"";"[data-addr='",string[stackPtr],"']{font-weight:bold}"]
    ]
    ,.h.htac[`div;enlist[`class]!enlist"top";""
        ,.h.ha["?new=1";"new"]," "
        ,.h.ha["?reset=1";"reset"]
        ,$[not .genarch.caNs[`isTerminated][.genarch.state];""
            ," ",.h.ha["?run=1";"continue"]
            ," ",.h.ha["?ni=1";"next"]
            ," ",.h.ha["?trace=1";"trace"]
            ;" continue next trace"]
        ,$[count .genarch.trace;""
            ," ",$[.genarch.tracePtr>0;.h.ha["?tr=0";"&lt;&lt;&lt;"];"&lt;&lt;&lt;"]
            ," ",$[.genarch.tracePtr>0;.h.ha["?tb=1";"&lt;&lt;"];"&lt;&lt;"]
            ," ",.h.ha["javascript:traceJump()";string[.genarch.tracePtr],"/",string[count[.genarch.trace]-1]]
            ," ",$[.genarch.tracePtr>=count[.genarch.trace]-1;"&gt;&gt;";.h.ha["?tf=1";"&gt;&gt;"]]
            ," ",$[.genarch.tracePtr>=count[.genarch.trace]-1;"&gt;&gt;&gt;";.h.ha["?tr=",string[count[.genarch.trace]-1];"&gt;&gt;&gt;"]]
            ;""
        ]
        ,$[0<count .genarch.lastError; " ",.h.htac[`span;enlist[`style]!enlist"color:red";.genarch.lastError];""]
        ,"<br>"
    ]
    ,.h.htac[`div;enlist[`class]!enlist"pl";.h.htc[`table;raze{[jd;x].h.htac[`tr;$[.genarch.state[1]=x[0];enlist[`class]!enlist"ip";
            x[0] in jd;enlist[`class]!enlist"jd";()!()]]""
        ,.h.htc[`td;.h.ha["?bp=",string[x 0];"(",$[x[0]in .genarch.breakpoints;"x";" "],")"]]
        ,.h.htc[`td;string[x 0]]
        ,.h.htc[`td;" "sv{.h.htac[`span;(`$("class";"data-addr"))!("mem";string x);string[y]]}'[x[0]+til count x 1;x 1]]
        ,.h.htc[`td;.genarch.instrstr[x]]
        }[jdest]each das]]
    ,.h.htac[`div;enlist[`class]!enlist"pr";""
        ,$[`effInstr in key analysis;analysis[`effInstr],"<br>";""]
        ,$[0<count regs;.genarch.showRegs[regs],"<br>";""]
        ,$[not (::)~input;"IN=",$[10h=type input;ssr[.html.es input;"\n";"<br>"];" "sv string[input]]
            ,.h.htc[`form;.h.htac[`input;enlist[`name]!enlist"input";""],.h.htac[`input;enlist[`type]!enlist"submit";""]];""]
        ,$[not (::)~output;"OUT=",$[10h=type output;ssr[.html.es output;"\n";"<br>"];" "sv string[output]],"<br>"
            ,$[0<count output;.h.htc[`form;.h.htac[`input;`name`type`value!("clearOutput";"hidden";enlist"1");""],.h.htac[`input;`type`value!("submit";"Clear Output");""]];""]
            ;""]
        ,$[not (::)~stack;"ST=",(" "sv string[stack]),"<br>";""]
        ,$[0<count mem;.genarch.showMemory[mem],"<br>";""]
        ,"<br>mem address or r.&lt;regname&gt;<br>",.h.htc[`form;"Lineage: ",.h.htac[`input;enlist[`name]!enlist"lineage";""],.h.htac[`input;enlist[`type]!enlist"submit";""]]
        ,.h.htc[`form;"History: ",.h.htac[`input;enlist[`name]!enlist"hist";""],.h.htac[`input;enlist[`type]!enlist"submit";""]]
        ,$[not (::)~output;.h.htc[`form;.h.htac[`input;`name`type`value!("histOut";"hidden";enlist"1");""],.h.htac[`input;`type`value!("submit";"output history");""]];""]
        ,.h.htc[`pre;lineageDisp]
    ]
    ,.h.htac[`script;enlist[`type]!enlist"text/javascript";"changemem=a=>{var r=prompt('value or @label at '+a);if(r)window.location+='?em='+a+'&v='+r};"
        ,"for(var i of document.getElementsByClassName('mem'))i.onclick=e=>changemem(e.target.dataset.addr);"
        ,"document.getElementsByClassName('ip')[0].scrollIntoView({block: 'center'});traceJump=()=>{var r=prompt('jump to cycle:');if(r)window.location+='?tr='+r;}"];
    r};

.genarch.showRegs:{[regs]
    pos:99h<>type regs;
    $[pos;
        (" "sv {.h.htac[`span;(`$("class";"data-addr"))!("mem";"r.",string[x]);string[y]]}'[til count regs;regs]);
        (" "sv {.h.htac[`span;(`$("class";"data-addr"))!("mem";"r.",string[x]);string[x],"=",string[y]]}'[key regs;value regs])]};

.genarch.showMemory:{[mem]
    "MEM=",(" "sv {.h.htac[`span;(`$("class";"data-addr"))!("mem";string x);$[x in key .genarch.label;.genarch.label[x],"=";""],string[y]]}'[til count mem;mem])};

.genarch.disasmAll:{[a]
    /a:.genarch.state
    ip:0;
    res:();
    while[.genarch.caNs[`ipValid][a;ip];
        /st:a
        insip:.genarch.caNs[`disasmOne][a;ip;enlist[`memLabels]!enlist .genarch.label];
        ins:insip[0];
        ip:insip[1];
        res,:enlist ins;
    ];
    res};

.genarch.setProgram:{[arch;code]
    if[0=count arch;'"missing arch"];
    if[not arch in string .genarch.list; '"unknown arch"];
    .genarch.currentArch:`$arch;
    .genarch.caNs:`$".",arch;
    .genarch.state:.genarch.try[.genarch.caNs[`new];enlist code;{[e;bt] '`$".new failed: ",e,"\n",.Q.sbt bt}];
    .genarch.initState:.genarch.state;
    };

.genarch.nuke:{
    .genarch.initState:(::);
    .genarch.state:(::);
    .genarch.trace:();
    .genarch.breakpoints:();
    .genarch.label:(`long$())!();
    .genarch.currLineage:"";
    .genarch.lastError:"";
    };

.genarch.reset:{
    .genarch.state:.genarch.initState;
    .genarch.lastError:"";
    .genarch.trace:();
    };

.genarch.nextInstruction:{
    .genarch.lastError:"";
    if[.genarch.caNs[`isTerminated][.genarch.state];:(::)];
    .genarch.keepOutput:1b;
    .genarch.state:.genarch.caNs[`runD][.genarch.state;1b;();1b];
    .genarch.keepOutput:0b;
    };

.genarch.continue:{
    .genarch.lastError:"";
    if[.genarch.caNs[`isTerminated][.genarch.state];:(::)];
    .genarch.keepOutput:1b;
    .genarch.state:.genarch.caNs[`resume][.genarch.state];
    .genarch.state:.genarch.caNs[`runD][.genarch.state;1b;.genarch.breakpoints;0b];
    .genarch.keepOutput:0b;
    };

.genarch.doTrace:{
    .genarch.lastError:"";
    if[.genarch.caNs[`isTerminated][.genarch.state];:(::)];
    startTime:.z.P;
    .genarch.keepOutput:1b;
    .genarch.state:.genarch.caNs[`resume][.genarch.state];
    .genarch.trace:enlist .genarch.state;
    run:.genarch.caNs[`isRunning][.genarch.state];
    while[run;
        .genarch.state:.genarch.caNs[`runD][.genarch.state;1b;();1b];
        if[not .genarch.caNs[`isTerminated][.genarch.state];
            .genarch.trace,:enlist .genarch.state;
            if[count[.genarch.trace]>.genarch.traceMax; .genarch.trace:neg[.genarch.traceMax]#.genarch.trace; .Q.gc[]];
        ];
        run:not .genarch.caNs[`isTerminated][.genarch.state] or .genarch.caNs[`needsInput][.genarch.state] or .genarch.caNs[`getIp][.genarch.state] in .genarch.breakpoints;
        if[00:01<=.z.P-startTime; .genarch.lastError:"running for too long... infinite loop?"; run:0b];
    ];
    .genarch.tracePtr:count[.genarch.trace]-1;
    .genarch.keepOutput:0b;
    };

.genarch.traceStepBack:{
    if[0=count .genarch.trace; :(::)];
    if[.genarch.tracePtr=0; :(::)];
    .genarch.tracePtr-:1;
    .genarch.state:.genarch.trace .genarch.tracePtr;
    };

.genarch.traceStepForward:{
    if[0=count .genarch.trace; :(::)];
    if[.genarch.tracePtr>=count[.genarch.trace]-1; :(::)];
    .genarch.tracePtr+:1;
    .genarch.state:.genarch.trace .genarch.tracePtr;
    };

.genarch.traceJumpTo:{[indstr]
    if[0=count .genarch.trace; :(::)];
    ind:"J"$indstr;
    if[null ind; '"invalid index"];
    if[not ind within 0,count[.genarch.trace]-1; '"index out of range"];
    .genarch.tracePtr:ind;
    .genarch.state:.genarch.trace .genarch.tracePtr;
    };

.genarch.editMemory:{[addr;val]
    if[addr like "r.*";
        reg:$[99h=type .genarch.caNs[`getRegisters][.genarch.state];`;"J"]$last"."vs addr;
        val:"J"$val;
        if[null val;'"bad value"];
        .genarch.state:.genarch.caNs[`editRegister][.genarch.state;reg;val];
        :(::);
    ];
    addr:"J"$addr;
    if[val[0]="@";
        lbl:1_val;
        if[count .genarch.label;if[lbl in value .genarch.label; '"dup label: ",lbl]];
        .genarch.label[addr]:lbl;
        if[1=count val; .genarch.label:enlist[addr] _.genarch.label];
        .genarch.label:{(asc key x)#x}.genarch.label;
        :(::);
    ];
    val:"J"$val;
    if[null addr;'"bad em"];
    if[null val;'"bad v"];
    .genarch.state:.genarch.caNs[`editMemory][.genarch.state;addr;val];
    };

.genarch.toggleBreakpoint:{[addr]
    addr:"J"$addr;
    if[null addr;'"bad address"];
    .genarch.breakpoints:asc distinct $[addr in .genarch.breakpoints;except;,][.genarch.breakpoints;addr];
    };

.genarch.genLineage:{[addr]
    if[0=count .genarch.trace;'"must trace first"];
    $[addr like "r.*";
        addr:`$addr;
        [
            addr:"J"$addr;
            if[null addr; '"bad addr"];
        ]
    ];
    .genarch.currLineage:.genarch.renderLineage[addr];
    if[1000<count .genarch.currLineage; .genarch.currLineage:1000#.genarch.currLineage];
    };

.genarch.getLineage:{[addr]
    /addr:0
    /addr:`r.3
    cycle:count[.genarch.trace]-1;
    deps:([]depFrom:();depTo:();val:`long$();instr:();cycle:`long$());
    queue:enlist (addr;cycle);
    cycle-:1;
    while[cycle>=0;
        state:.genarch.trace[cycle];
        ip:.genarch.caNs[`getIp][state];
        analysis:.genarch.caNs[`analyzeEffects][state];
        if[0<count analysis`memWrite;
            inaddr:analysis`memRead;    
            outaddr:first analysis`memWrite;
            srcs:queue where queue[;0]=outaddr;
            tgts:inaddr,\:cycle;
            regSrcs:srcs where -11h=type each srcs[;0];
            memSrcs:srcs where -7h=type each srcs[;0];
            if[0<count regSrcs;
                regs:.genarch.caNs[`getRegisters][.genarch.trace[cycle+1]];
                deps,:([]depFrom:regSrcs)cross([]depTo:enlist tgts;val:regs$[99h=type regs;::;"J"$string@]last ` vs regSrcs[0;0];
                    instr:enlist analysis`effInstr;enlist cycle);
            ];
            if[0<count memSrcs;
                deps,:([]depFrom:memSrcs)cross([]depTo:enlist tgts)cross([]val:.genarch.caNs[`getMemory][.genarch.trace[cycle+1]][memSrcs[;0]];
                    instr:enlist analysis`effInstr;enlist cycle);
            ];
            queue:(queue except srcs),$[count srcs;distinct tgts;()];
        ];
        cycle-:1;
    ];
    /deps,:([]depFrom:queue; depTo:enlist each queue[;0],\:-1;val:.genarch.trace[0;4;queue[;0]];instr:"initial state of [",/:string[queue[;0]],\:"]");
    symSrcs:queue where -11h=type each queue[;0];
    regSrcs:symSrcs where symSrcs[;0] like "r.*";
    immSrcs:symSrcs where symSrcs[;0] like "i.*";
    memSrcs:queue where -7h=type each queue[;0];
    if[0<count regSrcs;
        regs:.genarch.caNs[`getRegisters][.genarch.trace 0];
        deps,:([]depFrom:regSrcs; depTo:count[regSrcs]#enlist();val:regs$[99h=type regs;::;"J"$string@]last each` vs/:regSrcs[;0];
            instr:("initial state of ",$[99h=type regs;"";"r"]),/:string[last each` vs/:regSrcs[;0]];cycle:0);
    ];
    if[0<count immSrcs;
        deps,:([]depFrom:immSrcs; depTo:count[immSrcs]#enlist();val:.genarch.caNs[`getImmediate][.genarch.trace 0]./:"J"$string 1_/:` vs/:immSrcs[;0];
            instr:"immediate constant at ",/:"."sv/:string[1_/:` vs/:immSrcs[;0]];cycle:0);
    ];
    if[0<count memSrcs;
        deps,:([]depFrom:memSrcs; depTo:count[memSrcs]#enlist();val:.genarch.caNs[`getMemory][.genarch.trace 0][memSrcs[;0]];
            instr:"initial state of [",/:string[memSrcs[;0]],\:"]";cycle:0);
    ];
    deps};

.genarch.renderLineage:{[addr]
    /addr:754; cycle0:20342
    /lineage0:1!update enlist each instr from .genarch.getLineage[addr;cycle0]
    cycle0:count[.genarch.trace]-1;
    lineage0:.genarch.getLineage[addr];
    lineage:1!select depFrom, depTo,data:enlist each enlist'[0;depFrom[;0];cycle;(instr,'" = ",/:string[val])] from lineage0;
    leaf:()!();
    while[1b;
        leaf,:exec depFrom!data from lineage where 0=count each depTo;
        if[0=count lineage[(addr;cycle0);`depTo]; :lineage[(addr;cycle0);`data]];
        lineage:delete from lineage where 0=count each depTo;
        lineage:update ndepTo:depTo except\:key leaf from lineage;
        /lineage:update instr:((instr),'" ",/:/:raze each {x iasc count each x}each leaf@/:depTo inter\:key leaf) from lineage where 0=count each ndepTo;
        lineage:update data:(data,'.[;(::;::;0);+;1]raze each {x iasc count each x}each leaf@/:depTo) from lineage where 0=count each ndepTo;
        lineage:delete ndepTo from (update depTo:ndepTo from lineage where 0=count each ndepTo);
    ];
    };

.genarch.genHistory:{[addr]
    if[0=count .genarch.trace;'"must trace first"];
    c:count .genarch.trace;
    if[addr like "r.*";
        reg:`$last"."vs addr;
        regPos:99h<>type .genarch.caNs[`getRegisters][first .genarch.trace];
        if[regPos; reg:"J"$string reg];
        .genarch.currLineage:exec enlist'[0;0;i;string[i],'": ",/:string val] from ([]val:(.genarch.caNs[`getRegisters]each .genarch.trace)[;reg]);
        :(::);
    ];
    addr:"J"$addr;
    if[null addr;'"bad address"];
    .genarch.currLineage:exec enlist'[0;0;i;string[i],'": ",/:string val] from ([]val:(.genarch.caNs[`getMemory]each .genarch.trace)[;addr]);
    };

.genarch.genOutputHistory:{
    if[0=count .genarch.trace;'"must trace first"];
    outs:.genarch.caNs[`getOutput]each .genarch.trace;
    outc:count each outs;
    outd:where 1=deltas outc;
    .genarch.currLineage:exec enlist'[0;0;outd-1;string[outd-1],'": ",/:string cont] from ([]cont:last each outs[outd]);
    };

.genarch.addInput:{[input]
    //input:"J"$" "vs ssr[input;",";" "];
    .genarch.state:.genarch.caNs[`addInput][.genarch.state;input];
    };

.genarch.clearOutput:{
    .genarch.state:.genarch.caNs[`clearOutput][.genarch.state];
    };
