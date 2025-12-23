//changes from day 7 indicated with "NEW" comments
.intcode.debug:0b;
intcode:{[a;input]
    output:();
    $[a[0]~`pause;
        //(`pause;ip;tp;mo;a;input;output)
        [ip:a[1];tp:a[2];mo:a[3];input:a[5],input;a:a[4]];  //NEW: saved variables updated to include mo
        [ip:0;tp:0;mo:0]  //NEW: initialize mo
    ];
    run:1b;
    while[run;
        op:a[ip] mod 100;
        argc:(1 2 3 4 5 6 7 8 9 99!3 3 1 1 2 2 3 3 1 0)op;
        if[null argc; '"invalid op ",string[op]];
        if[.intcode.debug;-1 string[ip],": "," "sv string a[ip+til 1+argc]];
        argm:argc#(a[ip] div 100 1000 10000)mod 10;
        argv0:a[ip+1+til argc];
        arga:?[2>argm;argv0;argv0+mo];  //NEW: get memory address, allowing relative mode
        mm:max 0,arga where 1<>argm;    //NEW: find max address needed for code
        if[mm>=count a; a,:(1+mm-count a)#0];   //NEW: expand memory if needed
        argv:?[argm=1;argv0;a arga];    //NEW: use arga instead of argv0
        $[op=1; [a[arga 2]:argv[0]+argv[1]; ip+:1+argc];    //NEW: use arga instead of argv0 (also for other instructions)
          op=2; [a[arga 2]:argv[0]*argv[1]; ip+:1+argc];
          op=3;[$[tp>=count input; :(`pause;ip;0;mo;a;0#input;output);  //NEW: save mo
            [a[arga 0]:input[tp]; tp+:1; ip+:1+argc]]];
          op=4; [output,:argv 0; ip+:1+argc];
          op=5; $[argv[0]<>0; ip:argv 1; ip+:1+argc];
          op=6; $[argv[0]=0; ip:argv 1; ip+:1+argc];
          op=7; [a[arga 2]:0+argv[0]<argv[1]; ip+:1+argc];
          op=8; [a[arga 2]:0+argv[0]=argv[1]; ip+:1+argc];
          op=9; [mo+:argv 0; ip+:1+argc];   //NEW: added instruction
          op=99; run:0b;
          '"invalid op"
        ];
    ];
    output};

d9p1:{a:"J"$","vs raze x;
    {$[1=count x;first x;x]}intcode[a;enlist 1]};
d9p2:{a:"J"$","vs raze x;    //should set .intcode.debug:0b otherwise it will be too slow
    {$[1=count x;first x;x]}intcode[a;enlist 2]};

d9p1whitebox:{
    a:"J"$","vs raze x;
    ind:where a=1002;
    ind:ind where a[ind+\:til 4]~\:1002 64 2 64;
    ind2:where a=4;
    ind2:ind2 where a[ind2+\:til 2]~\:4 64;
    ind,:ind2;
    one:(((1001=a[ind-4]) and a[ind-7]<>ind) or a[ind-9]=1001);
    {y+2*x}/[one]};

d9p2whitebox:{
    a:"J"$","vs raze x;
    a[917]+last last {1_x,sum x[0 2]}\[26;1 0 1]};

/
No example input provided
