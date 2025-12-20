d8:{a:"J"$","vs/:x;
    ids:til count a;
    pair:select from([]s:ids)cross([]t:ids)where s<t;
    diffs:`diff xasc update diff:sum each{x*x}a[s]-a[t] from pair;
    (a;ids;diffs)};
d8p1:{[n;x]
    (a;ids;diffs):d8 x;
    b:n#diffs;
    adj:(exec t by s from b),'(exec s by t from b);
    nodes:enlist each ids;
    net:{[adj;nodes]{distinct asc x}each nodes,'raze each adj nodes}[adj]/[nodes];
    prd 3#desc count each distinct net};
d8p2:{
    (a;ids;diffs):d8 x;
    nodes:enlist each ids;
    i:0;
    while[1b;
        if[(<>). pos:first each where each flip diffs[i;`s`t] in/:nodes;
            nodes[pos 0]:asc raze nodes pos 0 1;
            nodes _:pos 1;
        ];
        if[1=count nodes;:prd a[diffs[i;`s`t]][;0]];
        i+:1;
    ];
    };

/
x:"\n"vs"162,817,812\n57,618,57\n906,360,560\n592,479,940\n352,342,300\n466,668,158\n542,29,236";
x,:"\n"vs"431,825,988\n739,650,466\n52,470,668\n216,146,977\n819,987,18\n117,168,530\n805,96,715";
x,:"\n"vs"346,949,466\n970,615,88\n941,993,340\n862,61,35\n984,92,344\n425,690,689";

d8p1[10;x]  //40
//d8p1[1000;x]
d8p2 x  //25272
