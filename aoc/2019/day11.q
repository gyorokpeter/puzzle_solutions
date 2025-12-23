{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

ocr:enlist[""]!enlist" ";
ocr[" **  *  * *  * **** *  * *  * "]:"A";
ocr["***  *  * ***  *  * *  * ***  "]:"B";
ocr[" **  *  * *    *    *  *  **  "]:"C";
ocr["**** *    ***  *    *    **** "]:"E";
ocr["**** *    ***  *    *    *    "]:"F";
ocr[" **  *  * *    * ** *  *  *** "]:"G";
ocr["*  * *  * **** *  * *  * *  * "]:"H";
ocr["  **    *    *    * *  *  **  "]:"J";
ocr["*  * * *  **   * *  * *  *  * "]:"K";
ocr["*    *    *    *    *    **** "]:"L";
ocr["***  *  * *  * ***  *    *    "]:"P";
ocr["***  *  * *  * ***  * *  *  * "]:"R";
ocr["*  * *  * *  * *  * *  *  **  "]:"U";
ocr["*   **   * * *   *    *    *  "]:"Y";
ocr["****    *   *   *   *    **** "]:"Z";

d11:{[x;st]
    a:.intcode.new x;
    grid:enlist enlist st;
    cursor:0 0;
    dir:0;
    run:1b;
    path:();
    while[run;
        a:.intcode.run[.intcode.addInput[a;string grid . cursor]];
        ins:last a;
        run:.intcode.needsInput[a];
        if[run;
            path,:enlist cursor;
            grid:.[grid;cursor;:;first ins];
            dir:(dir+(2*last[ins])-1)mod 4;
            cursor+:(-1 0;0 1;1 0;0 -1)dir;
            if[cursor[0]<0; grid:(abs[cursor 0]#enlist count[first grid]#0),grid; path[;0]+:abs cursor[0];cursor[0]:0];
            if[cursor[0]>=count grid; grid:grid,(1+cursor[0]-count grid)#enlist count[first grid]#0];
            if[cursor[1]<0; grid:(abs[cursor 1]#0),/:grid; path[;1]+:abs cursor 1;cursor[1]:0];
            if[cursor[1]>=count first grid; grid:grid,\:(1+cursor[1]-count first grid)#0];
        ];
    ];
    (grid;count distinct path)};

d11p1:{last d11[x;0]};
d11p2:{grid:" *"first d11[x;1];
    grid:40#/:(min grid?\:"*")_/:grid;
    ocr raze each flip 5 cut/:grid};

d11p1whitebox:{
    a:"J"$","vs raze x;
    ind:where a in 108 1008;
    ind:-1_ind where a[ind+3]=10;
    compBuffer:raze a[ind+\:1 2]except\:8;
    ind:where a=1007;
    ind:ind where a[ind+\:1 3]~\:9 10;
    iter:a[first[ind]+2];
    grid:enlist enlist 0;
    cursor:0 0;
    dir:0;
    path:();
    do[1+10*iter;
        $[0=count path;
            out:1 0;
            [   
                input:grid . cursor;
                out:(1-input;compBuffer[0]=input);
                compBuffer:(1_compBuffer),input;
            ]
        ];
        path,:enlist cursor;
        grid:.[grid;cursor;:;first out];
        dir:(dir+(2*last[out])-1)mod 4;
        cursor+:(-1 0;0 1;1 0;0 -1)dir;
        if[cursor[0]<0; grid:(abs[cursor 0]#enlist count[first grid]#0),grid; path[;0]+:abs cursor[0];cursor[0]:0];
        if[cursor[0]>=count grid; grid:grid,(1+cursor[0]-count grid)#enlist count[first grid]#0];
        if[cursor[1]<0; grid:(abs[cursor 1]#0),/:grid; path[;1]+:abs cursor 1;cursor[1]:0];
        if[cursor[1]>=count first grid; grid:grid,\:(1+cursor[1]-count first grid)#0];
    ];
    count distinct path};

d11p2whitebox:{
    a:"J"$","vs x;
    ns:a where a>100000;
    seq1:raze each flip @[;(0 3;1 2)]each 4 cut raze -40#/:0b vs/:ns 0 1;
    seq2:raze each flip @[;(1 2;0 3)]each 4 cut reverse raze -40#/:0b vs/:ns 2 3;
    seq3:raze each flip @[;(0 3;1 2)]each 4 cut raze -40#/:0b vs/:ns 4 5;
    grid:" *"seq1,seq2,seq3;
    ocr raze each flip 5 cut/:grid};

/
No example input provided
