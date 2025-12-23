.intcode.debug:0b;
intcode:{[a;input]
    output:();
    $[a[0]~`pause;
        [ip:a[1];tp:a[2];input:a[4],input;a:a[3]];
        [ip:0;tp:0]
    ];
    run:1b;
    while[run;
        op:a[ip] mod 100;
        argc:(1 2 3 4 5 6 7 8 99!3 3 1 1 2 2 3 3 0)op;
        if[.intcode.debug;-1 string[ip],": "," "sv string a[ip+til 1+argc]];
        if[null argc; '"invalid op ",string[op]];
        argm:argc#(a[ip] div 100 1000 10000)mod 10;
        argv0:a[ip+1+til argc];
        argv:?[argm=1;argv0;a argv0];
        $[op=1; [a[argv0 2]:argv[0]+argv[1]; ip+:1+argc];
          op=2; [a[argv0 2]:argv[0]*argv[1]; ip+:1+argc];
          op=3;[$[tp>=count input; :(`pause;ip;0;a;0#input;output);
            [a[argv0 0]:input[tp]; tp+:1; ip+:1+argc]]];
          op=4; [output,:argv 0; ip+:1+argc];
          op=5; $[argv[0]<>0; ip:argv 1; ip+:1+argc];
          op=6; $[argv[0]=0; ip:argv 1; ip+:1+argc];
          op=7; [a[argv0 2]:0+argv[0]<argv[1]; ip+:1+argc];
          op=8; [a[argv0 2]:0+argv[0]=argv[1]; ip+:1+argc];
          op=99; run:0b;
          '"invalid op"
        ];
    ];
    output};

perms:{$[0=count x;enlist x;raze x,/:'.z.s each x except/:x]};
d7p1:{a:"J"$","vs raze x;
    p:perms til 5;
    p2:0(;)/:p;
    rs:first each{[a;ir]$[0=count ir 1;ir;(first intcode[a;(first ir[1]),ir[0]];1_ir 1)]}[a]/'[p2];
    max rs};
d7p2:{
    a:"J"$","vs raze x;
    ps:perms 5+til 5;
    s:5#enlist a;
    run:{{[x]
        if[1=count x;:x];
        s:x 0;i:x 1;p:x 2;f:x 3;
        s[i]:intcode[s[i];$[0<count p;1#p;()],f];
        f:first last s[i];
        p:1_p;
        i:(1+i)mod 5;
        if[(i=0) and not`pause~first s[4]; :f];
        (s;i;p;f)
    }/[(x;0;y;0)]};
    rs:run[s]each ps;
    max rs};

d7p1whitebox:{
    a:"J"$","vs raze x;
    jmptbl:10#10_a;
    prgs:reverse each 2 cut/:(-3_/:2_/:5#jmptbl cut a)except\:9;
    oper:(::;+;*)prgs[;;0]mod 10;
    arg:prgs[;;1];
    fns:{('[;])/[x]}each oper@''arg;
    p:perms til 5;
    max {{y x}/[0;x]}each fns p};

d7p2whitebox:{
    a:"J"$","vs raze x;
    jmptbl:10#10_a;
    prgs:8 cut/:-1_/:-5#jmptbl cut a;
    oper:(::;+;*)prgs[;;2]mod 10;
    arg:raze each (2#/:/:3_/:/:prgs)except\:\:9;
    fns:oper@''arg;
    p:perms til 5;
    max {[fns;x]{y x}/[0;raze flip fns x]}[fns]each p};

/
x:enlist"3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0";

x2:"3,23,3,24,1002,24,10,24,1002,23,-1,23,";
x2,:"101,5,23,23,1,24,23,23,4,23,99,0,0";

x3:"3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,";
x3,:"1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0";

x4:"3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,";
x4,:"27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5";

x5:"3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,";
x5,:"-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,";
x5,:"53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10";

d7p1 x  //43210
d7p1 x2 //54321
d7p1 x3 //65210
//d7p2 x
d7p2 x4 //139629729
d7p2 x5 //18216

