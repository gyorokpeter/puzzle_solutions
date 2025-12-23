intcode:{[a;input]
    output:();
    ip:0;
    tp:0;
    run:1b;
    while[run;
        op:a[ip] mod 100;
        argc:(1 2 3 4 5 6 7 8 99!3 3 1 1 2 2 3 3 0)op;
        //-1 string[ip],": "," "sv string a[ip+til 1+argc];
        if[null argc; '"invalid op ",string[op]];
        argm:argc#(a[ip] div 100 1000 10000)mod 10;
        argv0:a[ip+1+til argc];
        argv:?[argm=1;argv0;a argv0];
        $[op=1; [a[argv0 2]:argv[0]+argv[1]; ip+:1+argc];
          op=2; [a[argv0 2]:argv[0]*argv[1]; ip+:1+argc];
          op=3; [a[argv0 0]:input[tp]; tp+:1; ip+:1+argc];
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
d5p1:{a:"J"$","vs raze x; intcode[a;enlist 1]};
d5p2:{a:"J"$","vs raze x; intcode[a;enlist 5]};

d5p1whitebox:{a:"J"$","vs raze x;
    {y+8*x}/[raze(a -5 -6+/:ind where 223 224~/:asc each a(ind:where a=223)-\:1 2)except\:224]};

d5p2whitebox:{a:"J"$","vs raze x;
    t:enlist[`long$()]!enlist 0N;
    t[7 226 226]:0;t[7 226 677]:0;t[7 677 226]:1;t[7 677 677]:0;t[107 226 226]:1;t[107 226 677]:0;t[107 677 226]:0;t[107 677 677]:0;
    t[1007 226 226]:0;t[1007 226 677]:0;t[1007 677 226]:0;t[1007 677 677]:1;t[1107 226 226]:0;t[1107 226 677]:1;t[1107 677 226]:0;t[1107 677 677]:0;
    t[8 226 226]:1;t[8 226 677]:0;t[8 677 226]:0;t[8 677 677]:1;t[108 226 226]:0;t[108 226 677]:1;t[108 677 226]:1;t[108 677 677]:0;
    t[1008 226 226]:0;t[1008 226 677]:1;t[1008 677 226]:1;t[1008 677 677]:0;t[1108 226 226]:1;t[1108 226 677]:0;t[1108 677 226]:0;t[1108 677 677]:1;
    ind:where a=224;
    ind2:ind where all each a[ind-\:1 2] in 226 677;
    {y+2*x}/[(t a -3 -2 -1+/:ind2)<>(1005=a 5+ind2)]};

/
No example input provided
