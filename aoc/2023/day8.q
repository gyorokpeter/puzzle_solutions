d8p1:{ins:"LR"?x 0; map0:" = "vs/:2_x;
    map:(`$map0[;0])!`$", "vs/:1_/:-1_/:map0[;1];
    step:{[m;x;y]m[x;y]}[map]/[;ins];
    map2:key[map]!step each key map;
    count[ins]*count -1_map2\[`ZZZ<>;`AAA]};
d8p2:{ins:"LR"?x 0; map0:" = "vs/:2_x;
    map:(`$map0[;0])!`$", "vs/:1_/:-1_/:map0[;1];
    step:{[m;x;y]m[x;y]}[map]/[;ins];
    map2:key[map]!step each key map;
    pos:{x where x like "*A"}key[map];
    paths:map2\[count map2;]each pos;
    count[ins]*prd{x[;1]-x[;0]}where each paths like\:"*Z"};

/
x:"\n"vs"RL\n\nAAA = (BBB, CCC)\nBBB = (DDD, EEE)\nCCC = (ZZZ, GGG)";
x,:"\n"vs"DDD = (DDD, DDD)\nEEE = (EEE, EEE)\nGGG = (GGG, GGG)\nZZZ = (ZZZ, ZZZ)";

x2:"\n"vs"LLR\n\nAAA = (BBB, BBB)\nBBB = (AAA, ZZZ)\nZZZ = (ZZZ, ZZZ)";

x3:"\n"vs"LR\n\n11A = (11B, XXX)\n11B = (XXX, 11Z)\n11Z = (11B, XXX)";
x3,:"\n"vs"22A = (22B, XXX)\n22B = (22C, 22C)\n22C = (22Z, 22Z)";
x3,:"\n"vs"22Z = (22B, 22B)\nXXX = (XXX, XXX)";

//x:x2
//x:x3

d8p1 x  //2
d8p1 x2 //6
d8p2 x  //2
d8p2 x3 //6
