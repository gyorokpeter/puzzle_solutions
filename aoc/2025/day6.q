d6p1:{a:(" "vs/:x)except\:enlist"";
    sum(("+*"!(sum;prd))last[a][;0])@'flip"J"$-1_a};
d6p2:{a:{1_/:(where all each" "=x)cut x}enlist[""],flip x;
    sum(("+*"!(sum;prd))last each a[;0])@'"J"$-1_/:/:a};

/
x:"\n"vs"123 328  51 64 \n 45 64  387 23 \n  6 98  215 314\n*   +   *   +  ";

d6p1 x  //4277556
d6p2 x  //3263827