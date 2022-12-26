.d10.ocr:()!();
.d10.ocr[529680320]:"A";
.d10.ocr[1067881856]:"B";
.d10.ocr[512103552]:"C";
.d10.ocr[1067882560]:"E";
.d10.ocr[1067616256]:"F";
.d10.ocr[512120256]:"G";
.d10.ocr[1059098560]:"H";
.d10.ocr[33955712]:"J";
.d10.ocr[1059153984]:"K";
.d10.ocr[1057230912]:"L";
.d10.ocr[1066550784]:"P";
.d10.ocr[1066559040]:"R";
.d10.ocr[1040457600]:"U";
.d10.ocr[597072960]:"Z";

d10:{[part;x]a:" "vs/:x;
    t:1+a[;0]like"addx";
    d:sums 1,"J"$a[;1];
    val:d where t;
    if[part=1;
        ind:20+40*til 6;
        :sum ind*val ind-1];
    r:40 cut (val-240#til 40)within -1 1;
    -1 " #"r;
    r2:2 sv/:raze each 5 cut flip r;
    .d10.ocr r2};
d10p1:{d10[1;x]};
d10p2:{d10[2;x]};

/
x:"\n"vs"addx 15\naddx -11\naddx 6\naddx -3\naddx 5\naddx -1\naddx -8\naddx 13\naddx 4\nnoop\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx -35\naddx 1\naddx 24\naddx -19";
x,:"\n"vs"addx 1\naddx 16\naddx -11\nnoop\nnoop\naddx 21\naddx -15\nnoop\nnoop\naddx -3\naddx 9\naddx 1\naddx -3\naddx 8\naddx 1\naddx 5\nnoop\nnoop\nnoop\nnoop\nnoop\naddx -36\nnoop\naddx 1\naddx 7\nnoop";
x,:"\n"vs"noop\nnoop\naddx 2\naddx 6\nnoop\nnoop\nnoop\nnoop\nnoop\naddx 1\nnoop\nnoop\naddx 7\naddx 1\nnoop\naddx -13\naddx 13\naddx 7\nnoop\naddx 1\naddx -33\nnoop\nnoop\nnoop\naddx 2\nnoop\nnoop\nnoop";
x,:"\n"vs"addx 8\nnoop\naddx -1\naddx 2\naddx 1\nnoop\naddx 17\naddx -9\naddx 1\naddx 1\naddx -3\naddx 11\nnoop\nnoop\naddx 1\nnoop\naddx 1\nnoop\nnoop\naddx -13\naddx -19\naddx 1\naddx 3\naddx 26\naddx -30";
x,:"\n"vs"addx 12\naddx -1\naddx 3\naddx 1\nnoop\nnoop\nnoop\naddx -9\naddx 18\naddx 1\naddx 2\nnoop\nnoop\naddx 9\nnoop\nnoop\nnoop\naddx -1\naddx 2\naddx -37\naddx 1\naddx 3\nnoop\naddx 15\naddx -21\naddx 22";
x,:"\n"vs"addx -6\naddx 1\nnoop\naddx 2\naddx 1\nnoop\naddx -10\nnoop\nnoop\naddx 20\naddx 1\naddx 2\naddx 2\naddx -6\naddx -11\nnoop\nnoop\nnoop";

d10p1 x //13140
d10p2 x //with real input only
