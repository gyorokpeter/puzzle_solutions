{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `chronal in key`;
        system"l ",path,"/chronal.q";
    ];
    }[];

d21p1:{st:.chronal.runD[.chronal.new x;1b;28;0b];
    .chronal.getRegisters[st]st[2;28;1]};

d21p2:{
    ipr:"J"$last" "vs x first where x like "#*";
    ins:"SJJJ"$/:" "vs/:x where not x like "#*";
    c:ins[7;1];
    a:65536;
    seen:();
    while[1b;
        b:c;
        cont:1b;
        while[cont;
            b:(((b+(a mod 256))mod 16777216)*65899)mod 16777216;
            cont:a>=256;
            a:a div 256;
        ];
        a:.chronal.bitor[b;65536];
        if[b in seen; :last seen];
        seen,:b;
    ];
    };
