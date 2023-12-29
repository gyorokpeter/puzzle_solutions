.d12.paths:{[mr;nr]
    lefts:reverse sums[reverse nr]+til count nr;
    queue:([]mp:enlist 0;cnt:1);
    np:0;
    while[np<count nr;
        queue:ungroup update nmp:mp+til each 1+count[mr]-mp+lefts np from queue;
        queue:update slice:mr nmp+\:til nr np from queue;
        queue:update pad:"."^mr((mp+til each nmp-mp),'nmp+nr np) from queue;
        queue:select from queue where all each slice in"#?",all each pad in"?.";
        queue:select mp:nmp+1+nr np,cnt from queue;
        queue:0!select sum cnt by mp from queue;
        np+:1;
    ];
    queue:update pad:mp _\:mr from queue;
    queue:select from queue where all each pad in"?.";
    exec sum cnt from queue};
d12p1:{p:" "vs/:x; m:p[;0]; n:"J"$","vs/:p[;1];
    sum .d12.paths'[m;n]};
d12p2:{p:" "vs/:x; m:p[;0]; n:"J"$","vs/:p[;1];
    m:"?"sv/:5#/:enlist each m;
    n:raze each 5#/:enlist each n;
    sum .d12.paths'[m;n]};

/
x:();
x,:enlist"???.### 1,1,3";
x,:enlist".??..??...?##. 1,1,3";
x,:enlist"?#?#?#?#?#?#?#? 1,3,1,6";
x,:enlist"????.#...#... 4,1,1";
x,:enlist"????.######..#####. 1,6,5";
x,:enlist"?###???????? 3,2,1";

d12p1 x //21
d12p2 x //525152
