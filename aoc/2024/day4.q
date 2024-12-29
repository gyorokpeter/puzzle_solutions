d4:{[start;match;cs;x]
    a:raze til[count x],/:'where each x=start;
    sum sum match~/:/:x ./:/:/:a+/:/:\:cs};
d4p1:{t3:1+til 3; tn3:(t3;neg t3);
    cs:raze(0,/:/:tn3;tn3,\:\:0;tn3,''tn3;tn3,''reverse tn3);
    d4["X";"MAS";cs;x]};
d4p2:{cs:til[4]rotate\:(-1 -1;-1 1;1 1;1 -1);
    d4["A";"MMSS";cs;x]};

/

x:();
x,:enlist"MMMSXXMASM";
x,:enlist"MSAMXMSMSA";
x,:enlist"AMXSXMAAMM";
x,:enlist"MSAMASMSMX";
x,:enlist"XMASAMXAMM";
x,:enlist"XXAMMXXAMA";
x,:enlist"SMSMSASXSS";
x,:enlist"SAXAMASAAA";
x,:enlist"MAMMMXMMMM";
x,:enlist"MXMXAXMASX";

d4p1 x  //18
d4p2 x  //9
