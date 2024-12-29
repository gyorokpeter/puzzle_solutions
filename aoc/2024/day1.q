d1:{"J"$(first;last)@/:\:" "vs/:x};
d1p1:{sum abs(-). asc each d1 x};
d1p2:{a:d1 x;sum a[0]*(count each group a 1)a 0};

/

x:"\n"vs"3   4\n4   3\n2   5\n1   3\n3   9\n3   3";

d1p1 x  //11
d1p2 x  //31
