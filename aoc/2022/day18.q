.d18.dirs:(1 0 0;-1 0 0;0 1 0;0 -1 0;0 0 1;0 0 -1);
d18p1:{a:"J"$","vs/:x;
    count raze[a+/:\:.d18.dirs]except a};
d18p2:{a:"J"$","vs/:x;
    b:raze[a+/:\:.d18.dirs]except a;
    disp:min[b];
    b:b-\:disp;
    a:a-\:disp;
    size:max b;
    bg:count each group b;
    found:0;
    visited:(1+size)#0b;
    queue:enlist 0 0 0;
    while[count queue;
        visited:.[;;:;1b]/[visited;queue];
        found+:sum bg queue;
        queue:(distinct raze queue+/:\:.d18.dirs)except a;
        queue:queue where all each queue within\:(0 0 0;size);
        queue:queue where not visited ./:queue;
    ];
    found};

/
x:"\n"vs"2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n1,2,5\n3,2,5\n2,1,5\n2,3,5";

d18p1[x]    //64
d18p2[x]    //58
