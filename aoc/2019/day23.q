{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

d23p1:{
    a:.intcode.new x;
    pcs:.intcode.runI[a]each enlist each til 50;
    while[1b;
        msg:`id xasc flip`id`x`y!flip 3 cut raze pcs[;6];
        if[255 in exec id from msg; :exec first y from msg where id=255];
        msg2:select xy:(x,'y) by id from msg;
        missing:til[50] except exec id from msg2;
        msg2[([]id:missing)]:([]xy:count[missing]#enlist enlist -1);
        msg3:raze each msg2[([]id:til 50);`xy];
        pcs:.intcode.runI'[pcs;msg3];
    ];
    };

d23p2:{
    a:.intcode.new x;
    pcs:.intcode.runI[a]each enlist each til 50;
    nat:(::);
    nh:();
    while[1b;
        msg:`id xasc flip`id`x`y!flip 3 cut raze pcs[;6];
        if[255 in exec id from msg; nat:exec (last x;last y) from msg where id=255];
        msg2:select xy:(x,'y) by id from msg;
        missing:til[50] except exec id from msg2;
        msg2[([]id:missing)]:([]xy:count[missing]#enlist enlist -1);
        msg3:raze each msg2[([]id:til 50);`xy];
        if[(50=count missing) and not nat~(::);
            msg3[0]:nat;
            nh,:last nat;
            if[(1<count nh) and 1=count distinct -2#nh; :last nh];
        ];
        pcs:.intcode.runI'[pcs;msg3];
    ];
    };

.d23.getInitVals:{[init]
    ji:where init in 1105 1106;
    ji:first ji where init[ji+2]=73;
    cmds:4 cut ji#init;
    vals:first each cmds[;1 2] except\:0 1;
    vals[where 1101 0 0~/:3#/:cmds]:0;
    vals[where 1101 1 0~/:3#/:cmds]:1;
    vals[where 1101 0 1~/:3#/:cmds]:1;
    vals[where 1102 0 1~/:3#/:cmds]:0;
    vals[where 1102 1 0~/:3#/:cmds]:0;
    vals[where 1102 1 1~/:3#/:cmds]:1;
    vals};

d23whitebox:{[part;x]
    a:"J"$","vs raze x;
    inits:a[11+til 50];
    ai:asc[inits];
    inits2:(ai!ai cut a)inits;
    initVals:.d23.getInitVals each inits2;
    addrDiv:initVals[;0];
    fns:(556 302 253 351!(first;prd;sum;(div).))initVals[;3];
    outs:2 cut/:a[initVals[;5]+til each 2*initVals[;4]];
    ins:2 cut/:a[initVals[;2]+til each 2*initVals[;1]];
    senders:where (0<count each outs) and all each ins[;;0];
    sendVals:(fns senders)@' ins[senders;;1];
    sendMsg:outs[senders],\:'sendVals;
    sendMsg2:raze sendMsg;
    sendMsg3:(1_/:sendMsg2) (group sendMsg2[;0]);
    inq:50#enlist();
    inq[key sendMsg3]:value sendMsg3;

    nat:0#0;
    natHist:0#0;
    while[1b;
        receivers:where 0<count each inq;
        if[0=count receivers;
            if[last[natHist]=last nat; :last nat];
            natHist,:last nat;
            inq[0],:enlist nat;
            receivers:where 0<count each inq;
        ];
        recvMsg:first each inq[receivers];
        inq[receivers]:1_/:inq[receivers];
        recvPos:(recvMsg[;0]div addrDiv[receivers])-1;
        recvData:recvMsg[;1];
        prevIns:ins;
        ins:{[ins;m;p;d].[ins;(m;p);:;(1;d)]}/[ins;receivers;recvPos;recvData];
        changed:where not prevIns~'ins;
        senders:changed where (0<count each outs changed) and all each ins[changed;;0];
        sendVals:(fns senders)@' ins[senders;;1];
        sendMsg:outs[senders],\:'sendVals;
        sendMsg2:raze sendMsg;
        sendMsg3:(1_/:sendMsg2) (group sendMsg2[;0]);
        if[255 in key sendMsg3;
            if[part=1;:first[sendMsg3 255][1]];
            nat:last sendMsg3[255];
            sendMsg3:enlist[255]_sendMsg3;
        ];
        inq[key sendMsg3],:value sendMsg3;
    ];
    };

d23p1whitebox:{d23whitebox[1;x]};
d23p2whitebox:{d23whitebox[2;x]};

/
No example input provided
