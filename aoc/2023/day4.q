d4:{a:("J"$" "vs/:/:" | "vs/:last each": "vs/:x)except\:\:0N;
    count each a[;0]inter'a[;1]};
d4p1:{c:d4 x;sum`long$2 xexp -1+c except 0};
d4p2:{c:d4 x;sum{[c;x;y]x[y+1+til c y]+:x[y];x}[c]/[count[c]#1;til count c]};

/
x:();
x,:enlist"Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53";
x,:enlist"Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19";
x,:enlist"Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1";
x,:enlist"Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83";
x,:enlist"Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36";
x,:enlist"Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11";

d4p1 x  //13
d4p2 x  //30
