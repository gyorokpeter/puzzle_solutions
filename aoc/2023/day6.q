d6p1:{a:("J"$" "vs/:last each":"vs/:x)except\:0N;
    prd sum each a[1]<{x*reverse x}each 1+til each -1+a 0};
d6p2:{a:"J"$(last each":"vs/:x)except\:" ";
    sum a[1]<{x*reverse x}1+til -1+a 0};

/
x:"\n"vs"Time:      7  15   30\nDistance:  9  40  200";

d6p1 x  //288
d6p2 x  //71503
