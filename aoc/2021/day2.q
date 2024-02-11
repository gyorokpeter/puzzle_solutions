d2:{a:" "vs/:"\n"vs x;("J"$a[;1])*(("forward";"down";"up")!(1 0;0 1;0 -1))a[;0]};
d2p1:{prd sum d2[x]};
d2p2:{b:d2[x];sum[b[;0]]*sum b[;0]*sums[b[;1]]};

/
d2p1 x:"forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2"
d2p2 x
