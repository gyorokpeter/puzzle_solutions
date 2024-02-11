# Breakdown
Example input:
```q
x:"Player 1 starting position: 4\nPlayer 2 starting position: 8"
```

## Part 1
I was expecting part 2 to be the usual cranking up of the turn count by adding a couple zeros at the
end, so I made a solution that should extend easily that way.

We find the starting spaces for the two players from the input, but subtract 1 such that the first
space is numbered zero:
```q
q)"\n"vs x
"Player 1 starting position: 4"
"Player 2 starting position: 8"
q)" "vs/:"\n"vs x
"Player" ,"1" "starting" "position:" ,"4"
"Player" ,"2" "starting" "position:" ,"8"
q)last each " "vs/:"\n"vs x
,"4"
,"8"
q)"J"$last each " "vs/:"\n"vs x
4 8
q)a:-1+"J"$last each " "vs/:"\n"vs x
q)a
3 7
```
The turn order and the next value of the die roll repeat with a period of 300, so we generate all
the rolls grouped into turns for 300 die rolls:
```q
q)2 cut 3 cut 300#1+til 100
1 2 3     4 5 6
7  8  9   10 11 12
13 14 15  16 17 18
...
83 84 85  86 87 88
89 90 91  92 93 94
95 96 97  98 99 100
```
We sum the rolls to find how many spaces each player will advance:
```q
q)roll:flip sum each/:2 cut 3 cut 300#1+til 100
q)roll
6  24 42 60 78 96  114 132 150 168 186 204 222 240 258 276 294 12 30 48 66 84 102 120 138 156 174..
15 33 51 69 87 105 123 141 159 177 195 213 231 249 267 285 103 21 39 57 75 93 111 129 147 165 183..
```
We find which space each player will land on after the rolls:
```q
q)land:1_/:(sums each a,'roll)mod 10
q)land
9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3 9 3 5 5 3
2 5 6 5 2 7 0 1 0 7 2 5 6 5 2 7 0 1 0 7 2 5 6 5 2 7 0 1 0 7 2 5 6 5 2 7 0 1 0 7 2 5 6 5 2 7 0 1 0 7
```
Note that we end up in the initial position after 50 turns (and also after every 10 turns but I
didn't bother to prove either version so I just added a check to make sure this is the case).

We calculate the scores per cycle for each player, remembering to add back the 1 that we took
away before:
```q
q)scorePerCycle:sum each 1+land
q)scorePerCycle
300 225
```
We find how many complete cycles must pass before a player reaches 1000 points:
```q
q)cycles:floor min 1000%scorePerCycle
q)cycles
3
```
We find what the score will be after this many cycles:
```q
q)fullCycleScore:cycles*scorePerCycle
q)fullCycleScore
900 675
```
We calculate the partial scores for the next cycle:
```q
q)partScores:sums each fullCycleScore,'1+land
q)partScores
900 910 914 920 926 930 940 944 950 956 960 970 974 980 986 990 1000 1004 1010 1016 1020 1030 1034..
675 678 684 691 697 700 708 709 711 712 720 723 729 736 742 745 753  754  756  757  765  768  774 ..
```
We find which round where each player would win (note that player 2 wouldn't win yet in this case):
```q
q)winRound:first each where each 1000<=partScores
q)winRound
16 0N
```
We find the actual winning round by taking the minimum of the two (nulls are ignored):
```q
q)winRound2:min winRound
q)winRound2
16
```
We find which player is the winner by comparing their win round to the whole game's win round:
```q
q)winner:first where winRound2=winRound
q)winner
0
```
We calculate the loser's score after the given number of rounds. Note that if player 1 wins, the
loser's score will be the one from the previous turn, so we need to subract 1 from the turn number.
```q
q)loserScore:$[winner;partScores[0;winRound2];partScores[1;winRound2-1]]
q)loserScore
745
```
We add up the various counters to find the number of die rolls:
```q
q)winRoundFull:(cycles*300)+(6*winRound2)+(1-winner)*-3
q)winRoundFull
993
```
The answer is the product of these two numbers:
```q
q)loserScore*winRoundFull
739785
```

## Part 2
Input parsing works the same way as in Part 1.
```q
q)a:-1+"J"$last each " "vs/:"\n"vs x
q)a
3 7
```
The core of the solution is a BFS where the state consists of the two players' positions and scores
and the multiplicity of the state:
```q
q)state:([]p1f:enlist a[0];p2f:a[1];p1s:0;p2s:0;cnt:1)
q)state
p1f p2f p1s p2s cnt
-------------------
3   7   0   0   1
```
Each step in the BFS is one player's turn, not a single roll of the die, so we precalculate the
number of ways each number can be rolled, which will be used to multiply the new states during the
BFS.
```q
q)splits:count each group sum each{x cross x cross x}1+til[3]
q)splits
3| 1
4| 3
5| 6
6| 7
7| 6
8| 3
9| 1
```
We initialize a few variables for the BFS:
```q
    win:0b;
    currPlayer:0;
    p1wins:0;
    p2wins:0;
```
The iteration will continue as long as we have states remaining:
```q
    while[0<count state;
```
The next section is split between player 1 and 2 (or 0 and 1 in the code) with the only difference
being some variable names:
```q
     $[currPlayer=0;[
```
The following is player 1's version:

For each state, we add every possible outcome of the die rolls to the player 1 position, and
multiply the count by the number of ways that die roll can occur:
```q
q)state:update p1f:(p1f+/:\:key splits)mod 10, cnt:cnt*/:\:value splits from state;
q)state
p1f           p2f p1s p2s cnt
---------------------------------------
6 7 8 9 0 1 2 7   0   0   1 3 6 7 6 3 1
```
We update player 1's score based on the current field, then ungroup the table:
```q
q)state:ungroup update p1s:p1s+'(p1f+1) from state
q)state
p1f p2f p1s p2s cnt
-------------------
6   7   7   0   1
7   7   8   0   3
8   7   9   0   6
9   7   10  0   7
0   7   1   0   6
1   7   2   0   3
2   7   3   0   1
```
We update player 1's total win count if any score goes above 21:
```q
q)p1wins+:exec sum cnt from state where p1s>=21
q)p1wins
0
```
We also delete the rows with a winning score from the table:
```q
q)state:delete from state where p1s>=21
q)state
p1f p2f p1s p2s cnt
-------------------
6   7   7   0   1
7   7   8   0   3
8   7   9   0   6
9   7   10  0   7
0   7   1   0   6
1   7   2   0   3
2   7   3   0   1
```
For player 2, the code is almost the same but notice the different variable/column names:
```q
        ];[
            state:update p2f:(p2f+/:\:key splits)mod 10, cnt:cnt*/:\:value splits from state;
            state:ungroup update p2s:p2s+'(p2f+1) from state;
            p2wins+:exec sum cnt from state where p2s>=21;
            state:delete from state where p2s>=21;
        ]];
```
After the player-specific processing, we deduplicate the states, adding their counts together:
```q
q)state:0!select sum cnt by p1f, p2f, p1s, p2s from state;
q)state
p1f p2f p1s p2s cnt
-------------------
0   7   1   0   6
1   7   2   0   3
2   7   3   0   1
6   7   7   0   1
7   7   8   0   3
8   7   9   0   6
9   7   10  0   7
```
We switch to the other player:
```q
q)currPlayer:1-currPlayer
q)currPlayer
1
```
This is the end of the iteration.
```q
    ];
```
After the iteration, we take the maximum of the two players' winning states.
```q
q)p1wins
444356092776315
q)p2wins
341960390180808
q)max(p1wins;p2wins)
444356092776315
```
