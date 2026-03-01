d7p1:{
    e:flip`s`t!flip x[;5 36];
    done:"";
    ts:asc distinct e[`t],e[`s];
    while[0<count e;
        nxt:min ts except e[`t];
        done,:nxt;
        e:select from e where s<>nxt;
        ts:ts except nxt;
    ];
    done,ts};
d7p2:{[x;workers;basetime]
    e:flip`s`t!flip x[;5 36];
    work:([]task:"";timeLeft:`int$());
    ts:update cost:basetime+1+(`int$task)-`int$"A" from ([]task:asc distinct e[`t],e[`s]);
    done:"";
    now:0;
    while[(0<count ts) or 0<count work;
        timePassed:$[0<count work;exec min timeLeft from work;0];
        now+:timePassed;
        work:update timeLeft:timeLeft-timePassed from work;
        done,:exec task from work where 0=timeLeft;
        work:delete from work where 0=timeLeft;
        e:select from e where not s in done;
        while[(count[work]<workers) and 0<count ts;
            nxt:first select from ts where not task in e[`t];
            work,:`task`timeLeft!nxt[`task`cost];
            ts:select from ts where task<>nxt`task;
        ];
        work:delete from work where task=" ";
    ];
    now};

/
x:();
x,:enlist"Step C must be finished before step A can begin.";
x,:enlist"Step C must be finished before step F can begin.";
x,:enlist"Step A must be finished before step B can begin.";
x,:enlist"Step A must be finished before step D can begin.";
x,:enlist"Step B must be finished before step E can begin.";
x,:enlist"Step D must be finished before step E can begin.";
x,:enlist"Step F must be finished before step E can begin.";

d7p1 x  //"CABDFE"
d7p2[x;2;0] //15
//d7p2[x;5;60]
