{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

d19p1:{a:.intcode.new x;
    r:raze .intcode.getOutput each .intcode.runI[a;]each raze {x,\:/:x}til 50;
    -1 " #"50 cut r;
    sum r};

d19p2:{[sqsz;x]
    a:.intcode.new x;
    size:10;
    grid:size cut raze .intcode.getOutput each .intcode.runI[a;]each raze {x,\:/:x}til size;
    minx:first where last grid;
    maxx:last where last grid;
    minPos:(minx;size-1);
    maxPos:(maxx;size-1);
    maxxs:((sqsz-1)#0), maxx;
    run:1b;
    while[run;
        minPos+:0 1;
        r:last .intcode.getOutput .intcode.runI[a;minPos];
        while[not r; minPos+:1 0;r:last .intcode.getOutput .intcode.runI[a;minPos]];
        maxPos+:0 1;
        r:last .intcode.getOutput .intcode.runI[a;maxPos];
        while[not r; maxPos+:1 0;r:last .intcode.getOutput .intcode.runI[a;maxPos]];
        while[r; maxPos+:1 0;r:last .intcode.getOutput .intcode.runI[a;maxPos]];
        maxPos-:1 0;
        maxxs:1_maxxs,first maxPos;
        maxsq:1+first[maxxs]-first[minPos];
        show maxsq;
        if[maxsq>=sqsz; found:(minPos[0];minPos[1]-sqsz-1); run:0b];
    ];
    sum found*10000 1};

d19p1whitebox:{
    a:"J"$","vs raze x;
    dx:first a[81 82]except 0 1;
    dy:first a[123 124]except 0 1;
    dz:first a[161 162]except 0 1;
    cy:til 50;
    minx:ceiling((neg[cy*dz])+sqrt[(cy*dz*cy*dz)+4*dx*cy*cy*dy])%2*dx;
    maxx:floor((neg[cy*dz])-sqrt[(cy*dz*cy*dz)+4*dx*cy*cy*dy])%2*neg dx;
    sum 0|1+maxx-minx};

d19p2whitebox:{[sqsz;x]
    a:"J"$","vs x;
    dx:first a[81 82]except 0 1;
    dy:first a[123 124]except 0 1;
    dz:first a[161 162]except 0 1;
    cc:sqsz;
    maxx:enlist 0;minx:enlist 0;
    while[sqsz>last[maxx]-last[minx];
        cc*:2;
        cyl:(sqsz-1)+til[cc];
        cyr:til cc;
        minx:ceiling((neg[cyl*dz])+sqrt[(cyl*dz*cyl*dz)+4*dx*cyl*cyl*dy])%2*dx;
        maxx:floor((neg[cyr*dz])-sqrt[(cyr*dz*cyr*dz)+4*dx*cyr*cyr*dy])%2*neg dx;
    ];
    ry:first where (sqsz-1)<=maxx-minx;
    rx:minx ry;
    ry+10000*rx};

/
No example input provided
