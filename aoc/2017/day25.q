d25:{
    lines:" "vs/:trim x;
    startState:`$-1_lines[0;3];
    steps:"J"$lines[1;5];
    rules:raze{([state:`$-1_x[1;2];input:01b]write:"B"$-1_/:x[3 7;4];move:(`left`right!-1 1)`$-1_/:x[4 8;6];nextState:`$-1_/:x[5 9;4])}each 10 cut 2_lines;
    finalState:{[rules;sht]
        rule:rules[(sht 0;sht[2;sht 1])];
        sht[2;sht 1]:rule`write;
        sht[1]+:rule`move;
        sht[0]:rule`nextState;
        if[sht[1]<0; sht[1]+:count[sht[2]]; sht[2]:(count[sht[2]]#0b),sht[2]];
        if[sht[1]>=count sht[2]; sht[2],:count[sht[2]]#0b];
        sht
    }[rules]/[steps;(startState;50;100#0b)];
    sum finalState[2]};

/
x:();
x,:enlist"Begin in state A.";
x,:enlist"    Perform a diagnostic checksum after 6 steps.";
x,:enlist"";
x,:enlist"    In state A:";
x,:enlist"      If the current value is 0:";
x,:enlist"        - Write the value 1.";
x,:enlist"        - Move one slot to the right.";
x,:enlist"        - Continue with state B.";
x,:enlist"      If the current value is 1:";
x,:enlist"        - Write the value 0.";
x,:enlist"        - Move one slot to the left.";
x,:enlist"        - Continue with state B.";
x,:enlist"";
x,:enlist"    In state B:";
x,:enlist"      If the current value is 0:";
x,:enlist"        - Write the value 1.";
x,:enlist"        - Move one slot to the left.";
x,:enlist"        - Continue with state A.";
x,:enlist"      If the current value is 1:";
x,:enlist"        - Write the value 1.";
x,:enlist"        - Move one slot to the right.";
x,:enlist"        - Continue with state A.";

d25 x   //3
