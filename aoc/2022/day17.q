.d17.shape:{raze til[count x],/:'where each x}each not null
    (enlist"####";(" # ";"###";" # ");("  #";"  #";"###");
    enlist each"####";("##";"##"));
.d17.ssz:1+max each .d17.shape;

d17:{[lim;x]
    dir:-1+2*">"=first x;
    dc:count dir;
    field:();
    i:-1;
    pcs:0;
    top:0N;
    flog:enlist[()]!enlist `int$(); //field log
    hlog:`int$();   //height log
    while[1b;
        i+:1;
        d:dir[i mod dc];
        if[null top;
            m:0; while[$[m=count field;0b;0=sum field m]; m+:1];
            field:m _field;
            if[pcs>=lim; :count[field]];
            hlog,:count field;
            snap:0b,raze 12 sublist field;
            flog[snap],:pcs;
            if[3<=count st:flog[snap];
                if[1=count pers:distinct 1_deltas st;
                    per:first pers;
                    hfst:hlog[st 0];    //height in first partial period
                    hper:hlog[st 2]-hlog[st 1]; //height per period
                    fullPers:(lim-st 0)div per; //number of full periods
                    plst:(lim-st 0)mod per;  //pieces in last partial period
                    hlst:hlog[plst+st 1]-hlog[st 1]; //height in last partial period
                    :hfst+(fullPers*hper)+hlst;
                ];
            ];
            shape:.d17.shape pcs mod 5;
            ssz:.d17.ssz pcs mod 5;
            field:((ssz[0]+3)#enlist 7#0b),field;
            top:0;
            left:2;
            pcs+:1;
        ];
        left+:d;
        if[7<left+ssz 1; left-:1];
        if[0>left; left+:1];
        if[any field ./:(top;left)+/:shape; left-:d];
        top+:1;
        hit:0b;
        if[count[field]<top+ssz 0; hit:1b];
        if[any field ./:(top;left)+/:shape; hit:1b];
        if[hit;
            top-:1;
            field:.[;;:;1b]/[field;(top;left)+/:shape];
            top:0N;
        ];
    ];
    };
d17p1:{d17[2022;x]};
d17p2:{d17[1000000000000;x]};

/

/draw field
.d17.df:{[field;shape;top;left]
    c:" #"field;
    if[not null top;
        c:.[;;:;"@"]/[c;(top;left)+/:shape];
    ];
    -1"|",/:c,\:"|";
    -1"+-------+";
    -1"";
    };

x:"\n"vs">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>";

d17p1[x]    //3068
d17p2[x]    //1514285714288
