d11:{[mult;x]
    a:raze til[count x],/:'where each"#"=x;
    stretch:{[m;x]d:deltas[x[;0]];x[;0]:sums d+(m-1)*0 or d-1;x}[mult];
    a:stretch a;
    b:asc reverse each a;
    b:stretch b;
    (sum sum sum each/:abs b-/:\:b)div 2};
d11p1:{d11[2;x]};
d11p2:{d11[1000000;x]};

/
x:();
x,:enlist"...#......";
x,:enlist".......#..";
x,:enlist"#.........";
x,:enlist"..........";
x,:enlist"......#...";
x,:enlist".#........";
x,:enlist".........#";
x,:enlist"..........";
x,:enlist".......#..";
x,:enlist"#...#.....";

d11p1 x //374
d11[10;x]   //1030
d11[100;x]  //8410
d11p2 x //82000210
