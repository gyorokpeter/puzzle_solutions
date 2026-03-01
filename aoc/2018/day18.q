d18step:{[map]
    treeAdj:(1_3 msum (1_/:3 msum/:(map,\:".")="|"),enlist count[first map]#0)-map="|";
    yardAdj:(1_3 msum (1_/:3 msum/:(map,\:".")="#"),enlist count[first map]#0)-map="#";
    map:?'[(map=".");
        ?'[treeAdj>=3;"|";map];
        ?'[(map="|");?'[yardAdj>=3;"#";map];
            ?'[(treeAdj>=1) and (yardAdj>=1);"#";"."]]];
    map};
d18p1:{
    map:d18step/[10;x];
    prd sum each sum each map=/:"|#"};
d18p2:{ 
    res:{
        map:d18step last x;
        $[raze[map]in x 1;
            (0b;x[1];map);
            (1b;x[1],enlist raze map;map)]}/[first;(1b;enlist raze x;x)];
    repeat:first where res[1]~\:raze res[2];
    period:count[res 1]-repeat;
    finalState:repeat+(1000000000-count[res 1])mod period;
    finalMap:res[1][finalState];
    prd sum each finalMap=/:"|#"};

/
x:"\n"vs".#.#...|#.\n.....#|##|\n.|..|...#.\n..|#.....#\n#.#|||#|#|\n...#.||...\n.|....|...";
x,:"\n"vs"||...#|.#|\n|.||||..|.\n...#.|..|.";

d18p1 x //1147
//d18p2 x
