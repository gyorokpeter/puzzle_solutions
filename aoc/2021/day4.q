d4:{[op;x]
    a:"\n"vs x;
    call:"J"$","vs a[0];
    boards:raze each ("J"$" "vs/:/:1_/:6 cut 1_a)except\:\:0N;
    round:call?boards;
    lines:0 5 10 15 20 0 1 2 3 4+1 1 1 1 1 5 5 5 5 5*\:til 5;
    boardWinRounds:min each max each/:round@\:lines;
    winRound:op boardWinRounds;
    winBoard:first where winRound=boardWinRounds;
    call[winRound]*sum boards[winBoard] where round[winBoard]>winRound};
d4p1:{d4[min;x]};
d4p2:{d4[max;x]};

/
x:"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\n"
x,:"\n22 13 17 11  0\n 8  2 23  4 24\n21  9 14 16  7\n 6 10  3 18  5\n 1 12 20 1"
x,:"5 19\n\n 3 15  0  2 22\n 9 18 13 17  5\n19  8  7 25 23\n20 11 10 24  4\n14 21"
x,:" 16 12  6\n\n14 21 17 24  4\n10 16 15  9 19\n18  8 23 26 20\n22 11 13  6  5\n"
x,:" 2  0 12  3  7"
d4p1 x
d4p2 x
