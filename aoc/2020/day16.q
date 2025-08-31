d16p1:{s:"\n\n"vs"\n"sv x;
    rule:asc"J"$"-"vs/:raze " or "vs/:last each": "vs/:"\n"vs s[0];
    tk:"J"$","vs/:1_"\n"vs s[2];
    sum raze tk@'{where not any x}each tk within\:/:\:rule};
d16p2:{s:"\n\n"vs"\n"sv x;
    rule:ungroup{([]field:`$x[;0];range:"J"$"-"vs/:/:" or "vs/:x[;1])}": "vs/:"\n"vs s[0];
    tk:"J"$","vs/:1_"\n"vs s[2];
    tk:tk where {all any x} each tk within\:/:\:rule[`range];
    fmap:count[first tk]#`;
    a:rule[`field]where each/:tk within/:\:\:rule[`range];
    while[any null fmap;
        poss:(inter')/[a];
        uniq:where 1=count each poss;
        fmap[uniq]:poss[uniq;0];
        miss:where null fmap;
        a[;miss]:a[;miss] except\:\:fmap;
    ];
    ytk:"J"$","vs last"\n"vs s[1];
    prd ytk where fmap like "departure*"};

/
x:();
x,:enlist"class: 1-3 or 5-7";
x,:enlist"row: 6-11 or 33-44";
x,:enlist"seat: 13-40 or 45-50";
x,:enlist"";
x,:enlist"your ticket:";
x,:enlist"7,1,14";
x,:enlist"";
x,:enlist"nearby tickets:";
x,:enlist"7,3,47";
x,:enlist"40,4,50";
x,:enlist"55,2,20";
x,:enlist"38,6,12";

x2:();
x2,:enlist"class: 0-1 or 4-19";
x2,:enlist"row: 0-5 or 8-19";
x2,:enlist"seat: 0-13 or 16-19";
x2,:enlist"";
x2,:enlist"your ticket:";
x2,:enlist"11,12,13";
x2,:enlist"";
x2,:enlist"nearby tickets:";
x2,:enlist"3,9,18";
x2,:enlist"15,1,5";
x2,:enlist"5,14,9";

d16p1 x //71
//d16p2 x
d16p2 x2    //non-indicative output for example
