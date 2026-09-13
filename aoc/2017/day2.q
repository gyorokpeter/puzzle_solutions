d2p1:{r:"J"$"\t"vs/:x;sum(max each r)-min each r};
d2p2:{r:"J"$"\t"vs/:x;sum{(%). first{x where (x[;0]<>x[;1])and 0=x[;0]mod x[;1]}(x cross x)}each r};

/
x:("5\t1\t9\t5";"7\t5\t3";"2\t4\t6\t8");
x2:("5\t9\t2\t8";"9\t4\t7\t3";"3\t8\t6\t5");
d2p1 x  //18
d2p2 x2 //9
