d20:{[part;x]
    p:" -> "vs/:x;
    conn:(`$p[;0]except\:"%&")!`$", "vs/:p[;1];
    if[part=2; if[not `rx in raze value conn; '"unsupported input"]];
    nt:key[conn]!p[;0][;0];
    nt[`broadcaster]:"=";
    //"digraph G {\n",raze[{"    \"",nt[x`s],string[x`s],"\" -> \"",nt[x`t],string[x`t],"\"\n"}each ungroup([]s:key conn;t:value conn)],"}"
    wire0:select from ungroup([]s:key conn;t:value conn;signal:0b) where nt[t]="&";
    wire1:select from ([]s:`;t:key conn;signal:0b) where nt[t]="%";
    wire:2!wire0,wire1;
    tl:th:0; step:0;
    if[part=2;
        fin:first where`rx in/:conn;
        fins:where fin in/:conn;
        cycle:fins!count[fins]#enlist();
    ];
    do[$[part=1;1000;10000];
        step+:1;
        queue:enlist(`;`broadcaster;0b);
        while[count queue;
            curr:first queue;
            queue:1_queue;
            $[curr 2;th+:1;tl+:1];
            cn:curr 1; cnt:nt cn; cs:curr 2;
            nw:cn,/:conn cn;
            ns:$[cnt="=";cs;
                cnt="%";$[cs;::;[wire[(`;cn)]:not wire(`;cn);wire[(`;cn);`signal]]];
                cnt="&";[wire[(curr[0];cn)]:cs;not all exec signal from wire where t=cn];
                (::)
            ];
            if[part=2; if[cn in fins; if[ns; cycle[cn],:step]]];
            if[not(::)~ns;
                queue,:nw,\:ns;
            ];
        ];
    ];
    if[part=1; :th*tl];
    cl:distinct each deltas each value cycle;
    if[any 1<>count each cl; '"unsupported input"];
    prd raze cl};
d20p1:{d20[1;x]};
d20p2:{d20[2;x]};

/
x:"\n"vs"broadcaster -> a, b, c\n%a -> b\n%b -> c\n%c -> inv\n&inv -> a";
x2:"\n"vs"broadcaster -> a\n%a -> inv, con\n&inv -> b\n%b -> con\n&con -> output";

d20p1 x //32000000
d20p1 x2    //11687500
d20p2 x //'unsupported input
