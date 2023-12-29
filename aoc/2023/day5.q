d5p1:{s:"J"$" "vs last": "vs first x;
    m:"J"$" "vs/:/:2_/:(where 0=count each x)cut x;
    loc:{[cs;cm]d:cs-/:cm[;1];
        ind:first each where each flip(d>=0) and cs</:cm[;1]+cm[;2];
        cs^cm[ind][;0]+flip[d]@'ind}/[s;m];
    min loc};
d5p2:{s0:2 cut"J"$" "vs last": "vs first x;
    m0:"J"$" "vs/:/:2_/:(where 0=count each x)cut x;
    s:asc s0[;0],'s0[;0]+s0[;1]-1;
    m:asc each{(x[1];x[1]+x[2]-1;x[0]-x[1])}each/:m0;
    f:{[cs;cm]
        change:1b;
        while[change;
            change:0b;
            aff:flip(cs[;0]</:cm[;0]) and cs[;1]>=/:cm[;0];
            if[any any aff; change:1b;
                needCut:any each aff; cutInd:where needCut;
                cutTarget:first each where each aff cutInd;
                cs:asc(cs where not needCut),
                    .[cs[cutInd];(::;1);:;cm[cutTarget;0]-1],
                    .[cs[cutInd];(::;0);:;cm[cutTarget;0]];
            ];
            aff:flip(cs[;0]<=/:cm[;1]) and cs[;1]>/:cm[;1];
            if[any any aff; change:1b;
                needCut:any each aff; cutInd:where needCut;
                cutTarget:first each where each aff cutInd;
                cs:asc(cs where not needCut),
                    .[cs[cutInd];(::;1);:;cm[cutTarget;1]],
                    .[cs[cutInd];(::;0);:;cm[cutTarget;1]+1];
            ];
        ];
        aff:(cs[;0]>=/:cm[;0])and cs[;1]<=/:cm[;1];
        ind:first each where each flip aff;
        cs:asc cs+0^cm[ind][;2];
        change:1b;
        while[change;
            change:0b;
            merge:(-1_cs[;1])>=(-1+1_cs[;0]);
            mergeInd:where merge;
            if[count mergeInd; change:1b;
                cs:asc cs[where not (merge,0b)or(0b,merge)],
                cs[mergeInd;0],'cs[mergeInd+1;1];
            ];
        ];
    cs};
    loc:f/[s;m];
    min loc[;0]};

/
x:();
x,:enlist"seeds: 79 14 55 13";
x,:("";"seed-to-soil map:";"50 98 2";"52 50 48");
x,:("";"soil-to-fertilizer map:";"0 15 37";"37 52 2";"39 0 15");
x,:("";"fertilizer-to-water map:";"49 53 8";"0 11 42";"42 0 7";"57 7 4");
x,:("";"water-to-light map:";"88 18 7";"18 25 70");
x,:("";"light-to-temperature map:";"45 77 23";"81 45 19";"68 64 13");
x,:("";"temperature-to-humidity map:";"0 69 1";"1 0 69");
x,:("";"humidity-to-location map:";"60 56 37";"56 93 4");

d5p1 x  //35
d5p2 x  //46
