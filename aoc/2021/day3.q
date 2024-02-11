d3p1:{a:sum["B"$/:/:x]>count[x]%2;prd 2 sv/:(a;not a)};
d3p2:{
    a:"B"$/:/:x;
    f:{{[op;x;y]if[1=count x;:x];
        b:x[;y];x where b=op[sum[b];count[b]%2]}[x]/[y;til count first y]};
    prd 2 sv/:f[>=;a],f[<;a]};

/
x:"\n"vs"00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010";

d3p1 x  //198
d3p2 x  //230
