{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

d13p1:{
    out:.intcode.getOutput .intcode.run .intcode.new x;
    paint:3 cut out;
    sum 2=last each paint};

d13p2:{
    a:.intcode.editMemory[.intcode.new x;0;2]; score:0; grid:(::);
    run:1b; input:();
    //allInputs:();
    while[run;
        //allInputs,:input;
        a:.intcode.runI[a;input];
        run:not .intcode.isTerminated a;
        paint:3 cut .intcode.getOutput a;
        if[grid~(::); grid:(1+max[paint]1 0)#0];
        grid:{x[y[1];y[0]]:y[2];x}/[grid;paint where -1<first each paint];
        score:max score,last last paint where -1=first each paint;
        -1 " +#=*"grid; -1"Score: ",string score;
        ballPos:first raze where each grid=4;
        paddlePos:first raze where each grid=3;
        input:enlist signum ballPos-paddlePos;
   ];
   score};

d13p1whitebox:{
    a:"J"$","vs raze x;
    w:a 49; h:a 60;
    board:w cut (w*h)#639_a;
    sum sum 2=board};

d13p2whitebox:{
    a:"J"$","vs raze x;
    w:a 49; h:a 60;
    board:w cut (w*h)#639_a;
    block:raze til[h],/:'where each board=2;
    da:first a[612 613]except 0 1;
    db:first a[616 617]except 0 1;
    off:(((block[;0]+block[;1]*h)*da)+db)mod w*h;
    sum a(639+w*h)+off};

/
No example input provided
