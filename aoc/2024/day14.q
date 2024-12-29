d14p1:{[size;x]
    a:"J"$","vs/:/:2_/:/:" "vs/:x;
    b:(a[;0]+100*a[;1])mod\:size;
    c:count each group signum b-\:size div 2;
    prd c{x where 0<>prd each x}key c};
d14p2:{[size;x]
    size2:reverse size;
    a:reverse each/:"J"$","vs/:/:2_/:/:" "vs/:x;
    step:0;
    while[1b;
        step+:1;
        newpos:(a[;0]+step*a[;1])mod\:size2;
        map:.[;;:;"#"]/[size2#" ";newpos];
        if[any map like"*########*";:step];
    ]};

/

x:"\n"vs"p=0,4 v=3,-3\np=6,3 v=-1,-3\np=10,3 v=-1,2\np=2,0 v=2,-1\np=0,0 v=1,3\np=3,0 v=-2,-2";
x,:"\n"vs"p=7,6 v=-1,-3\np=3,0 v=-1,-2\np=9,3 v=2,3\np=7,3 v=-1,2\np=2,4 v=2,-3\np=9,5 v=-3,-3";

d14p1[11 7;x]   //12
//d14p1[101 103;x]  //not applicable to the example
//d14p2[101 103;x]  //not applicable to the example
