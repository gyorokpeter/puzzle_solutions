d1:{0|(x div 3)-2};
d1p1:{sum d1"J"$x};
d1p2:{sum sum 1_d1\["J"$x]};

/
d1p1 enlist"12" //2
d1p1 enlist"14" //2
d1p1 enlist"1969"   //654
d1p1 enlist"100756" //33583

d1p2 enlist"12" //2
d1p2 enlist"1969"   //966
d1p2 enlist"100756" //50346
