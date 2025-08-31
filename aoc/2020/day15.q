d15:{[n;x]
    ns:"J"$","vs x;
    arr:(1+max[ns])#0N;
    arr[-1_ns]:1+til count[ns]-1;
    c:n-count ns;
    num:last ns;
    step:count[ns];
    do[c;
        nxt:0^step-arr[num];
        if[count[arr]<=num;arr,:num#0N];
        arr[num]:step;
        num:nxt;
        step+:1;
    ];
    num};
d15p1:{d15[2020;x]};
d15p2:{d15[30000000;x]};

/

// No input file, input is a string.
x:"0,3,6";

d15p1 x //436
d15p2 x //175594    //warning: slow


d15p1 "1,3,2"   //1
d15p1 "2,1,3"   //10
d15p1 "1,2,3"   //27
d15p1 "2,3,1"   //78
d15p1 "3,2,1"   //438
d15p1 "3,1,2"   //1836

d15p2 "1,3,2"   //2578
d15p2 "2,1,3"   //3544142
d15p2 "1,2,3"   //261214
d15p2 "2,3,1"   //6895259
d15p2 "3,2,1"   //18
d15p2 "3,1,2"   //362
