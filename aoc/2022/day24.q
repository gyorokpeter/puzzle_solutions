d24:{[part;x]
    w:count first x; h:count x;
    mapbase:".#"x="#";  //for visual only
    s:0,first where"."=first x;
    t:(count[x]-1),first where"."=last x;
    bdirm:">v<^"?x;
    bpos:raze til[count x],/:'where each 4>bdirm;
    bdir:bdirm ./:bpos;
    moves:(0 1;1 0;0 -1;-1 0;0 0);
    squeue:$[part=1;enlist s;(s;t;s)];
    tqueue:$[part=1;enlist t;(t;s;t)];
    round:0;
    while[count squeue;
        s:first squeue; t:first tqueue;
        squeue:1_squeue; tqueue:1_tqueue;
        queue:enlist s;
        found:0b;
        while[not found;
            if[0=count queue; '"no solution?!"];
            round+:1;
            bpos+:moves bdir;
            bpos[where bpos[;0]=0;0]:h-2;
            bpos[where bpos[;1]=0;1]:w-2;
            bpos[where bpos[;0]=h-1;0]:1;
            bpos[where bpos[;1]=w-1;1]:1;
            dbpos:distinct bpos;
            queue:distinct raze queue+/:\:moves;
            queue:queue except dbpos;
            queue:queue where all each queue within\:(0 0;(h-1;w-1));
            queue:queue where "#"<>x ./:queue;
            if[1b;  //set to 1b to enable visual
                map:mapbase;
                map:.[;;:;]/[map;bpos;">v<^"bdir];
                gbpos:{(where 1<x)#x}count each group bpos;
                if[count gbpos; map:.[;;:;]/[map;key gbpos;?[9<value gbpos;"*";first each string value gbpos]]];
                map:.[;;:;"E"]/[map;queue];
                -1"\nMinute ",string[round],":";
                -1 map;
            ];
            if[t in queue; found:1b];
        ];
    ];
    round};
d24p1:{d24[1;x]};
d24p2:{d24[2;x]};

/
x:"\n"vs"#.######\n#>>.<^<#\n#.<..<<#\n#>v.><>#\n#<^v^^>#\n######.#";

d24p1 x //18
d24p2 x //54
