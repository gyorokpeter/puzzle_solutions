d8in:{a:" "vs/:x;
    ins:"SJ"$/:a;
    ins};
d8step:{[ins;state]
    if[state[`ip]=count ins; state[`term]:1b; :state];
    if[not state[`ip] within 0,count[ins]-1; fail:1b; :state];
    state[`visited;state`ip]:1b;
    ci:ins[state`ip];
    if[`changedIns in key state;if[state[`changedIns]=state[`ip];
        ci[0]:(`nop`jmp`acc!`jmp`nop`changedAcc)ci[0];
    ]];
    $[ci[0]=`nop; state[`ip]+:1;
      ci[0]=`acc; [state[`acc]+:ci[1]; state[`ip]+:1];
      ci[0]=`jmp; state[`ip]+:ci 1;
    state[`fail]:1b];
    state};
d8p1:{
    ins:d8in x;
    state:`acc`ip`visited`term`fail!(0;0;count[ins]#0b;0b;0b);
    while[not state[`visited][state`ip];
        state:d8step[ins;state];
    ];
    state`acc};
d8p2:{
    ins:d8in x;
    queue:enlist `acc`ip`visited`term`fail`changedIns!(0;0;count[ins]#0b;0b;0b;0N);
    while[0<count queue;
        queue:delete from queue where (visited@'ip) or fail;
        queue,:update changedIns:ip from select from queue where null changedIns;
        queue:d8step[ins] each queue;
        succ:select from queue where term;
        if[0<count succ; :exec first acc from succ];
    ];
    '"no solution found"};

/
x:"\n"vs"nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6";

d8p1 x  //5
d8p2 x  //8
