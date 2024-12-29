d13p1:{a:"\n"vs/:"\n\n"vs"\n"sv x except\:"XY+=,";
    b:"J"$2 2 1_'/:" "vs/:/:a;
    f:{[aa]coords:(+/:\:).(1+til 100)*\:/:aa 0 1;
        press:1+raze til[100],/:'where each aa[2]~/:/:coords;
        $[count press;min sum each 3 1*/:press;0]};
    sum f each b};
d13p2:{a:"\n"vs/:"\n\n"vs"\n"sv x except\:"XY+=,";
    b:0 0 10000000000000+/:"J"$2 2 1_'/:" "vs/:/:a;
    px:((b[;2;0]*b[;1;1]%b[;1;0])-b[;2;1])%(b[;0;0]*b[;1;1]%b[;1;0])-b[;0;1];
    py:(b[;2;0]-px*b[;0;0])%b[;1;0];
    sum?[(px=`long$px)and py=`long$py;py+3*px;0]};

/

x:();
x,:enlist"Button A: X+94, Y+34";
x,:enlist"Button B: X+22, Y+67";
x,:enlist"Prize: X=8400, Y=5400";
x,:enlist"";
x,:enlist"Button A: X+26, Y+66";
x,:enlist"Button B: X+67, Y+21";
x,:enlist"Prize: X=12748, Y=12176";
x,:enlist"";
x,:enlist"Button A: X+17, Y+86";
x,:enlist"Button B: X+84, Y+37";
x,:enlist"Prize: X=7870, Y=6450";
x,:enlist"";
x,:enlist"Button A: X+69, Y+23";
x,:enlist"Button B: X+27, Y+71";
x,:enlist"Prize: X=18641, Y=10279";

d13p1 x //480
d13p2 x //875318608908
