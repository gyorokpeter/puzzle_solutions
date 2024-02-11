d21p1:{
    a:-1+"J"$last each " "vs/:"\n"vs x;
    roll:flip sum each/:2 cut 3 cut 300#1+til 100;
    land:1_/:(sums each a,'roll)mod 10;
    if[not a~last each land; '"nyi"];
    scorePerCycle:sum each 1+land;
    cycles:floor min 1000%scorePerCycle;
    fullCycleScore:cycles*scorePerCycle;
    partScores:sums each fullCycleScore,'1+land;
    winRound:first each where each 1000<=partScores;
    winner:first where not null winRound;
    winRound2:min winRound;
    loserScore:$[winner;partScores[0;winRound2];partScores[1;winRound2-1]];
    winRoundFull:(cycles*300)+(6*winRound2)+(1-winner)*-3;
    loserScore*winRoundFull};

d21p2:{
    a:-1+"J"$last each " "vs/:"\n"vs x;
    state:([]p1f:enlist a[0];p2f:a[1];p1s:0;p2s:0;cnt:1);
    win:0b;
    currPlayer:0;
    splits:count each group sum each{x cross x cross x}1+til[3];
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
d21p1 x:"Player 1 starting position: 4\nPlayer 2 starting position: 8"
d21p2 x

OVERVIEW:
The solution is vastly different for the two parts.

PART 1:
I was expecting part 2 to be the usual cranking up of te turn count by adding a couple zeros at the
end, so I made a solution that should extend easily that way. We first find the cycle length after
which both the state of the die and the current player is the same. This means repeating the cycle
will move both players forward by a fixed amount and multiple cycles can be condensed into a single
multiplication. Normally we should also make sure that the players are also in the same position on
the board, but for this particular configuration of the die and board size this is always true. So
we can calculate the number of points per cycle, find the number of cycles needed to reach the
target score, and then calculate the scores for the last incomplete cycle.

PART 2:
This is a BFS implementation that tracks the number of occurrences of each state, which includes
the two players' positions and scores. Each step in the BFS is one player's turn, not a single roll
of the die, so we precalculate the number of ways each number can be rolled and then multiply these
by the number of occurrences in the current state. If a state takes one player's score above 21, we
add the occurrences in that state to a running total and remove the state from the queue. Once the
queue is empty we can just return whichever running total is higher.
