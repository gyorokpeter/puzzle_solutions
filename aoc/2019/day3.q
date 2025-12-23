d3:{a:","vs/:x;
    {sums raze ("J"$1_/:x)#'enlist each("URDL"!(0 -1;1 0;0 1;-1 0))x[;0]}each a};
d3p1:{b:d3 x;min sum each abs b[0]inter b[1]};
d3p2:{b:d3 x;min sum 1+b?\:b[0]inter b[1]};

/
x:("R75,D30,R83,U83,L12,D49,R71,U7,L72";"U62,R66,U55,R34,D71,R55,D58,R83")
x2:("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51";"U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")

d3p1 x  //159
d3p1 x2 //135
d3p2 x  //610
d3p2 x2 //410
