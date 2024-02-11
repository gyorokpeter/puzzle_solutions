d21p1:{
    a:-1+"J"$last each " "vs/:x;
    roll:flip sum each/:2 cut 3 cut 300#1+til 100;
    land:1_/:(sums each a,'roll)mod 10;
    if[not a~last each land; '"nyi"];
    scorePerCycle:sum each 1+land;
    cycles:floor min 1000%scorePerCycle;
    fullCycleScore:cycles*scorePerCycle;
    partScores:sums each fullCycleScore,'1+land;
    winRound:first each where each 1000<=partScores;
    winRound2:min winRound;
    winner:first where winRound2=winRound;
    loserScore:$[winner;partScores[0;winRound2];partScores[1;winRound2-1]];
    winRoundFull:(cycles*300)+(6*winRound2)+(1-winner)*-3;
    loserScore*winRoundFull};

d21p2:{
    a:-1+"J"$last each " "vs/:x;
    state:([]p1f:enlist a[0];p2f:a[1];p1s:0;p2s:0;cnt:1);
    splits:count each group sum each{x cross x cross x}1+til[3];
    win:0b;
    currPlayer:0;
    p1wins:0;
    p2wins:0;
    while[0<count state;
        $[currPlayer=0;[
            state:update p1f:(p1f+/:\:key splits)mod 10, cnt:cnt*/:\:value splits from state;
            state:ungroup update p1s:p1s+'(p1f+1) from state;
            p1wins+:exec sum cnt from state where p1s>=21;
            state:delete from state where p1s>=21;
        ];[
            state:update p2f:(p2f+/:\:key splits)mod 10, cnt:cnt*/:\:value splits from state;
            state:ungroup update p2s:p2s+'(p2f+1) from state;
            p2wins+:exec sum cnt from state where p2s>=21;
            state:delete from state where p2s>=21;
        ]];
        state:0!select sum cnt by p1f, p2f, p1s, p2s from state;
        currPlayer:1-currPlayer;
    ];
    max(p1wins;p2wins)};

/
x:"\n"vs"Player 1 starting position: 4\nPlayer 2 starting position: 8";

d21p1 x //739785
d21p2 x //444356092776315
