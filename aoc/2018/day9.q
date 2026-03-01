d9common:{[pl;lm]
    circle:enlist 0;
    curr:0;
    cm:0;
    score:pl#0;
    while[cm<lm;
        cm+:1;
        $[0=cm mod 23;
            [
                curr:(curr-7)mod count circle;
                score[(cm-1) mod pl]+:cm+circle[curr];
                circle _:curr;
            ];
          (23<=count circle) and (1=cm mod 23) and (1+lm-cm)>23;
            [
                cycles:min((1+lm-cm);count[circle]) div 23;
                stealm:(cm-1)+23*1+til cycles;
                stealpos:19+16*til cycles;
                stealv:circle[stealpos];
                score+:0^(sum each (stealm+stealv) group stealm mod pl)[til pl];
                circle:raze 1_/:(0,1+stealpos) cut 0N,circle;
                ins:cm+(enlist each til 6),6+(-3_raze((23*til cycles)+\:(enlist each til 11),enlist[11 12],(17 13 18;19 14 20;21 15 22))),
                    enlist each ((cycles-1)*23)+13+til 3;
                circle:(2#circle),(raze ins,'count[ins]#2_circle),(count[ins]+2)_circle;
                cm:cm+(cycles*23)-1;
                curr:37*cycles;
            ];[
                curr:((curr+1)mod count circle)+1;
                toPlace:min (1+count[circle]-curr;neg[cm]mod 23;1+lm-cm);
                circle:(curr#circle),raze[(cm+til[toPlace-1]),'(toPlace-1)#curr _circle],(cm+toPlace-1),(curr+toPlace-1)_circle;
                curr+:(toPlace-1)*2;
                cm+:toPlace-1;
            ]
        ];
        circle:curr rotate circle;
        curr:0;
    ];
    max score};
d9p1:{d9common . "J"$(" "vs first x)0 6};
d9p2:{d9common . 1 100*"J"$(" "vs first x)0 6};

/
x:enlist"9 players; last marble is worth 25 points";
x2:enlist"10 players; last marble is worth 1618 points";
x3:enlist"13 players; last marble is worth 7999 points";
x4:enlist"17 players; last marble is worth 1104 points";
x5:enlist"21 players; last marble is worth 6111 points";
x6:enlist"30 players; last marble is worth 5807 points";

d9p1 x  //32
d9p1 x2 //8317
d9p1 x3 //146373
d9p1 x4 //2764
d9p1 x5 //54718
d9p1 x6 //37305
//d9p2 x
