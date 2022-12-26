d9:{[t;x]a:" "vs/:x;
    dir:raze a[;0];
    amt:"J"$a[;1];
    dir2:dir where amt; //raze amt#'dir;
    mH:("UDLR"!(0 -1;0 1;-1 0;1 0))dir2;
    pH:enlist[0 0],sums mH;
    step1:{d:y-x;if[1<max abs d;x+:signum d];x};
    step:step1\[0 0;];
    pT:step/[t;pH];
    count distinct pT};
d9p1:{d9[1;x]};
d9p2:{d9[9;x]};

/
x:"\n"vs"R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2";
x:"\n"vs"R 5\nU 8\nL 8\nD 3\nR 17\nD 10\nL 25\nU 20";

d9p1 x  //13/88
d9p2 x  //1/36
