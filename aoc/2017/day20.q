d20:{[part;x]
    pd:"J"$","vs/:/:-1_/:/:3_/:/:", "vs/:x;
    pd2:{[part;x]x[;1]+:x[;2];x[;0]+:x[;1];if[2=part;x:x raze{x where 1=count each x}group x[;0]];x}[part]/[50000;pd];
    pd2};
d20p1:{pd2:d20[1;x];first where{x=min x}sum each abs pd2[;0]};
d20p2:{count d20[2;x]};

/
x:();
x,:enlist"p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>";
x,:enlist"p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>";

x2:();
x2,:enlist"p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>";
x2,:enlist"p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>";
x2,:enlist"p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>";
x2,:enlist"p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>";

d20p1 x //0
//d20p2 x
d20p2 x2 //1
