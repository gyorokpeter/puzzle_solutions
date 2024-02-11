d6:{[days;x]
    a:"J"$","vs x;
    t:{([timer:key x]cnt:value x)}count each group a;
    do[days;
        breed:select from t where timer=0;
        notBreed:select from t where timer>0;
        t1:update timer-1 from notBreed;
        t2:update timer:count[i]#6 from breed;
        t3:update timer:count[i]#8 from breed;
        t:t1+t2+t3;
    ];
    exec sum cnt from t};
d6p1:{d6[80;x]};
d6p2:{d6[256;x]};

/
d5p1 x:"3,4,3,1,2"
d5p2 x
