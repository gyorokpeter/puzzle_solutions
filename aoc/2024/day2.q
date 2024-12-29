d2p1:{sum any all each/:(1_/:deltas each"J"$" "vs/:x)in/:(1 2 3;-1 -2 -3)};
d2p2:{a:{enlist[x],x _/:til count x}each"J"$" "vs/:x;
    sum any each any all each/:/:(1_/:/:deltas each/:a)in/:(1 2 3;-1 -2 -3)};

/

x:"\n"vs"7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9";

d2p1 x  //2
d2p2 x  //4
