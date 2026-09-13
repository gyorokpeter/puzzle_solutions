d7:{p:" -> "vs/:x;
    p2:" "vs/:p[;0];
    n:`$p2[;0];
    n1:([n]w:"J"$1_/:-1_/:p2[;1]);
    n1,'`n xkey ungroup([]p:n;n:(`$", "vs/:p[;1])except\:`)};
d7p1:{nodes:d7 x;exec first n from nodes where null p};
d7p2:{nodes:d7 x;
    child:exec n by p from nodes;
    child1:{{asc distinct raze x}each value[x],'x x}/[child];
    cw:(exec n!w from nodes)+sum each nodes[([]n:child1);`w];
    cws:cw `_ child;
    imbal:where 1<count each distinct each cws;
    bad:first imbal where not any each child[imbal] in\:imbal;
    w:group cw c:child bad;
    corrw:first where 1<count each w;
    badw:first where 1=count each w;
    diff:badw-corrw;
    nodes[c w[badw]0;`w]-diff};

/
x:();
x,:enlist"pbga (66)";
x,:enlist"xhth (57)";
x,:enlist"ebii (61)";
x,:enlist"havc (66)";
x,:enlist"ktlj (57)";
x,:enlist"fwft (72) -> ktlj, cntj, xhth";
x,:enlist"qoyq (66)";
x,:enlist"padx (45) -> pbga, havc, qoyq";
x,:enlist"tknk (41) -> ugml, padx, fwft";
x,:enlist"jptl (61)";
x,:enlist"ugml (68) -> gyxo, ebii, jptl";
x,:enlist"gyxo (61)";
x,:enlist"cntj (57)";

d7p1 x  //`tknk
d7p2 x //60
