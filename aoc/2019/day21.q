{if[not `intcode in key `;
        path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
        system"l ",path,"/intcode.q";
    ]}[];

d21p1:{
    a:.intcode.new x;
    a:.intcode.run[a];
    -1`char$last a;
    a:.intcode.getOutput .intcode.runI[a;{-1 x;`long$x}"\n"sv(
        // not[A] or not[C] and D
        "NOT A J";
        "NOT C T";
        "AND D T";
        "OR T J";
        "WALK";"")];
    -1`char$a;
    last a};
d21p2:{
    a:.intcode.new x;
    a:.intcode.run[a];
    -1`char$last a;
    a:.intcode.getOutput .intcode.runI[a;{-1 x;`long$x}"\n"sv(
        // (not[A] or not[B] or not[C]) and D and E or H
        "NOT A J";  //J=not A
        "NOT B T";  //T=not B
        "OR T J";   //J=not[A] or not B
        "NOT C T";  //T=not C
        "OR T J";   //J=not[A] or not[B] or not C
        "AND D J";  //J=(not[A] or not[B] or not C) and D
        "NOT E T";  //T=not E
        "NOT T T";  //T=E
        "OR H T";   //T=e or H
        "AND T J";  //J=(not[A] or not[B] or not C) and D and E or H
        "RUN";"")];
    -1`char$a;
    last a};

.d21.whiteboxCommon:{[x;ind]
    a:"J"$","vs raze x;
    tracks:a[ind];
    mult:10+where each not -9#/:0b vs/:tracks;
    sum sum each ind*tracks*mult};

d21p1whitebox:{
    .d21.whiteboxCommon[x;758+til 7]};

d21p2whitebox:{
    .d21.whiteboxCommon[x;(758+til 7),766+til 153]};

/
No example input provided
