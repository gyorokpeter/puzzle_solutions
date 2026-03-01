{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `chronal in key`;
        system"l ",path,"/chronal.q";
    ];
    }[];

d19:{[a;x]
    st:.chronal.runD[.chronal.editRegister[.chronal.new[x];0;a];1b;enlist 1;0b];
        {sum x where 0=last[x] mod x}1+til max .chronal.getRegisters[st]};

d19p1:{d19[0;x]};
d19p2:{d19[1;x]};

/
Not applicable to the example input

