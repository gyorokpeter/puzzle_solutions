d9p1:{sum{sum last each{1_deltas x}\[any;x]}each"J"$" "vs/:x};
d9p2:{sum{{y-x}/[first each reverse{1_deltas x}\[any;x]]}each"J"$" "vs/:x};

/
x:"\n"vs"0 3 6 9 12 15\n1 3 6 10 15 21\n10 13 16 21 30 45";

d9p1 x  //114
d9p2 x  //2
