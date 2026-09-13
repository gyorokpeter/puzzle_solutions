d12in:{{("J"$x[;0])!"J"$", "vs/:x[;1]}" <-> "vs/:trim x};
d12p1:{m:d12in x;count({{asc distinct raze x} each x,'x x}/[m])0};
d12p2:{m:d12in x;count distinct value{{asc distinct raze x} each x,'x x}/[m]};

/
x:"\n"vs"0 <-> 2\n1 <-> 1\n2 <-> 0, 3, 4\n3 <-> 2, 4\n4 <-> 2, 3, 6\n5 <-> 6\n6 <-> 4, 5";
d12p1 x //6
d12p2 x //2
