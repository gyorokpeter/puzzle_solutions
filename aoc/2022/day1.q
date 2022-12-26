d1:{sum each{(0,where null x)cut x}"J"$x};
d1p1:{max d1 x};
d1p2:{sum 3#desc d1 x};

/
x:"\n"vs"1000\n2000\n3000\n\n4000\n\n5000\n6000\n\n7000\n8000\n9000\n\n10000";

d1p1 x  //24000
d1p2 x  //45000
