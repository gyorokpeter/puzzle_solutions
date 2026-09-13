{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    if[not `arch1 in key`;
        system"l ",path,"/arch1.q";
    ];
    }[];

d23p1:{.arch1.getMulCount .arch1.run .arch1.new[x]};

d23p2:{
    startval:100000+100*"J"$last" "vs first x;
    nums:startval+til[1001]*17;
    cnt:count nums;
    d:2;
    while[d<startval;
        nums:nums where 0<>nums mod d;
        d+:1;
    ];
    cnt-count nums};

/
No example input provided
