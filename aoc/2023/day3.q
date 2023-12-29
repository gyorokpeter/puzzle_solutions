d3:{a:x in .Q.n;
    b:(where each differ each a)cut'x;
    num:"J"$b; len:count each/:b;
    xr:{(-1+-1_/:x),''1_/:x}sums each 0,/:len;
    xyr:({-1 1+/:x}til count num)(;)/:'xr;
    num2:raze num; nz:where not null num2;
    num3:num2 nz; xyr3:raze[xyr]nz;
    (num3;xyr3)};
d3p1:{r:d3 x; num3:r 0; xyr3:r 1;
    sp:raze til[count x],/:'where each not x in .Q.n,".";
    touch:any each all each/:sp within'\:/:xyr3;
    sum num3*touch};
d3p2:{r:d3 x; num3:r 0; xyr3:r 1;
    sp:raze til[count x],/:'where each x="*";
    snxt:all each/:sp within'\:/:xyr3;
    numidx:where each flip snxt[;where 2=sum snxt];
    sum prd each num3 numidx};

/
x:();
x,:enlist"467..114..";
x,:enlist"...*......";
x,:enlist"..35..633.";
x,:enlist"......#...";
x,:enlist"617*......";
x,:enlist".....+.58.";
x,:enlist"..592.....";
x,:enlist"......755.";
x,:enlist"...$.*....";
x,:enlist".664.598..";

d3p1 x  //4361
d3p2 x  //467835
