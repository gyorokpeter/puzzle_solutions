{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `duet in key`;
        system"l ",path,"/duet.q";
    ];
    }[];

d18p1:{last .duet.getOutput .duet.run .duet.new[x]};
d18p2:{
    st0:.duet.new[x];
    st1:.duet.editRegister[st0;`p;1];
    totalOut1:0;
    run:1b;
    while[run;
        st0:.duet.run st0;
        st1:.duet.run st1;
        out0:.duet.getOutput st0;
        out1:.duet.getOutput st1;
            totalOut1+:count out1;
        st0:.duet.clearOutput st0;
        st1:.duet.clearOutput st1;
        st0:.duet.addInput[st0;out1];
        st1:.duet.addInput[st1;out0];
        run:0<count[out0]+count[out1];
    ];
    totalOut1};

/
x:"\n"vs"set a 1\nadd a 2\nmul a a\nmod a 5\nsnd a\nset a 0\nrcv a\njgz a -1\nset a 1\njgz a -2";
x2:"\n"vs"snd 1\nsnd 2\nsnd p\nrcv a\nrcv b\nrcv c\nrcv d";
d18p1 x  //4
//d18p2 x
d18p2 x2    //3
