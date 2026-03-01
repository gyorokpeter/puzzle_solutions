d4prep:{
    ts:ts:"P"$"2000",/:12#/:5_/:x;
    es:([]minute:`long$`minute$ts;e:x) iasc ts;
    es2:update et:{first where count each x ss/:("begins";"falls";"wakes")}each e from es;
    es2:update gn:fills"J"${first" "vs last"#"vs x}each e from es2;
    esg:0!select minute by gn,et from es2 where 0<et;
    gm:{[esg;g]
        r:select from esg where gn=g;
        `g`m!(g;raze{x[0]+til each x[1]-x[0]}exec minute from r)
    }[esg]each exec distinct gn from esg;
    gm};
d4p1:{
    gm:d4prep x;
    topg:first select g,m from (update cm:count each m from gm) where cm=max cm;
    topg[`g]*{first where x=max x}count each group topg[`m]
    };
d4p2:{
    gm:d4prep[x];
    gmf:ungroup(select g from gm),'exec{{{`m`f!(key x;value x)}(where x=max x)#x}count each group x}each m from gm;
    exec first g*m from gmf where f=max f};

/
x:();
x,:enlist"[1518-11-01 00:00] Guard #10 begins shift";
x,:enlist"[1518-11-01 00:05] falls asleep";
x,:enlist"[1518-11-01 00:25] wakes up";
x,:enlist"[1518-11-01 00:30] falls asleep";
x,:enlist"[1518-11-01 00:55] wakes up";
x,:enlist"[1518-11-01 23:58] Guard #99 begins shift";
x,:enlist"[1518-11-02 00:40] falls asleep";
x,:enlist"[1518-11-02 00:50] wakes up";
x,:enlist"[1518-11-03 00:05] Guard #10 begins shift";
x,:enlist"[1518-11-03 00:24] falls asleep";
x,:enlist"[1518-11-03 00:29] wakes up";
x,:enlist"[1518-11-04 00:02] Guard #99 begins shift";
x,:enlist"[1518-11-04 00:36] falls asleep";
x,:enlist"[1518-11-04 00:46] wakes up";
x,:enlist"[1518-11-05 00:03] Guard #99 begins shift";
x,:enlist"[1518-11-05 00:45] falls asleep";
x,:enlist"[1518-11-05 00:55] wakes up";

d4p1 x  //240
d4p2 x  //4455
