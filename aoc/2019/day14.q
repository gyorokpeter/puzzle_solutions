d14:{[t;fuel]
    queue:enlist[`FUEL]!enlist fuel;
    totalOre:0;
    storage:(`$())!`long$();
    while[0<count queue;
        canUse:0^(key[queue]#storage)&queue;
        queue-:canUse;
        storage-:canUse;
        queue:(where queue>0)#queue;
        nxts:update mult:value queue from 0!([]rt:key queue)#t;
        nxts2:update pq:ceiling mult%rq from nxts;
        nxts3:update mats:.[mats;(::;::;0);*;pq] from nxts2;
        nxts4:((`$())!`long$()),sum .[{enlist[y]!enlist[x]}]each exec raze mats from nxts3;
        storage+:(exec rt!pq*rq from nxts3)-queue;
        totalOre+:0^nxts4`ORE;
        queue:`ORE _nxts4;
        ];
    totalOre};

d14p1:{
    a:"JS"$/:/:/:" "vs/:/:/:", "vs/:/:" => "vs/:x;
    t:([rt:a[;1;0;1]]rq:a[;1;0;0];mats:a[;0]);
    d14[t;1]};

d14p2:{
    totalOre:1000000000000;
    a:"JS"$/:/:/:" "vs/:/:/:", "vs/:/:" => "vs/:x;
    t:([rt:a[;1;0;1]]rq:a[;1;0;0];mats:a[;0]);
    u:0; v:1;
    while[d14[t;v]<totalOre; v*:2];
    while[u<=v;
        d:u+(v-u)div 2;
        r:d14[t;d];
        $[r<=totalOre; u:d+1; v:d-1];
    ];
    v};

/
x:();
x,:enlist"10 ORE => 10 A";
x,:enlist"1 ORE => 1 B";
x,:enlist"7 A, 1 B => 1 C";
x,:enlist"7 A, 1 C => 1 D";
x,:enlist"7 A, 1 D => 1 E";
x,:enlist"7 A, 1 E => 1 FUEL";

x2:();
x2,:enlist"9 ORE => 2 A";
x2,:enlist"8 ORE => 3 B";
x2,:enlist"7 ORE => 5 C";
x2,:enlist"3 A, 4 B => 1 AB";
x2,:enlist"5 B, 7 C => 1 BC";
x2,:enlist"4 C, 1 A => 1 CA";
x2,:enlist"2 AB, 3 BC, 4 CA => 1 FUEL";

x3:();
x3,:enlist"157 ORE => 5 NZVS";
x3,:enlist"165 ORE => 6 DCFZ";
x3,:enlist"44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL";
x3,:enlist"12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ";
x3,:enlist"179 ORE => 7 PSHF";
x3,:enlist"177 ORE => 5 HKGWZ";
x3,:enlist"7 DCFZ, 7 PSHF => 2 XJWVT";
x3,:enlist"165 ORE => 2 GPVTF";
x3,:enlist"3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT";

x4:();
x4,:enlist"2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG";
x4,:enlist"17 NVRVD, 3 JNWZP => 8 VPVL";
x4,:enlist"53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL";
x4,:enlist"22 VJHF, 37 MNCFX => 5 FWMGM";
x4,:enlist"139 ORE => 4 NVRVD";
x4,:enlist"144 ORE => 7 JNWZP";
x4,:enlist"5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC";
x4,:enlist"5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV";
x4,:enlist"145 ORE => 6 MNCFX";
x4,:enlist"1 NVRVD => 8 CXFTF";
x4,:enlist"1 VJHF, 6 MNCFX => 4 RFSQX";
x4,:enlist"176 ORE => 6 VJHF";

x5:();
x5,:enlist"171 ORE => 8 CNZTR";
x5,:enlist"7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL";
x5,:enlist"114 ORE => 4 BHXH";
x5,:enlist"14 VRPVC => 6 BMBT";
x5,:enlist"6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL";
x5,:enlist"6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT";
x5,:enlist"15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW";
x5,:enlist"13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW";
x5,:enlist"5 BMBT => 4 WPTQ";
x5,:enlist"189 ORE => 9 KTJDG";
x5,:enlist"1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP";
x5,:enlist"12 VRPVC, 27 CNZTR => 2 XDBXC";
x5,:enlist"15 KTJDG, 12 BHXH => 5 XCVML";
x5,:enlist"3 BHXH, 2 VRPVC => 7 MZWV";
x5,:enlist"121 ORE => 7 VRPVC";
x5,:enlist"7 XCVML => 6 RJRHP";
x5,:enlist"5 BHXH, 4 VRPVC => 5 LTCX";

d14p1 x     //31
d14p1 x2    //165
d14p1 x3    //13312
d14p1 x4    //180697
d14p1 x5    //2210736

d14p2 x     //34482758620
d14p2 x2    //6323777403
d14p2 x3    //82892753
d14p2 x4    //5586022
d14p2 x5    //460664
