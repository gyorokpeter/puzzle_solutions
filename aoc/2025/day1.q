d1p1:{sum 0=(50+\(("LR"!-1 1)x[;0])*"J"$1_/:x)mod 100};
d1p2:{sum 0=(50+\raze("J"$1_/:x)#'("LR"!-1 1)x[;0])mod 100};

/
x:"\n"vs"L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82";

d1p1 x  //3
d1p2 x  //6
