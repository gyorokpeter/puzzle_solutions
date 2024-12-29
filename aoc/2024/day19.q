d19:{[part;x]a:"\n\n"vs"\n"sv x;
    elem:", "vs a 0;
    goal:"\n"vs a 1;
    ways:{[elem;g]
        queue:([]pos:enlist 0;cnt:enlist 1);
        total:0;
        while[count queue;
            total+:exec sum cnt from queue where pos=count g;
            queue:delete from queue where pos=count g;
            nxts:ungroup update e:count[queue]#enlist til count elem from queue;
            nxts:update ec:count each elem e from nxts;
            nxts:update chunk:g pos+til each ec from nxts;
            nxts:delete from nxts where not chunk~'elem e;
            queue:0!select sum cnt by pos+ec from nxts;
        ];
        total}[elem]each goal;
    sum$[part=1;ways>0;ways]};
d19p1:{d19[1;x]};
d19p2:{d19[2;x]};

/

x:"\n"vs"r, wr, b, g, bwu, rb, gb, br\n\nbrwrr\nbggr\ngbbr\nrrbgbr\nubwu\nbwurrg\nbrgr\nbbrgwb";

d19p1 x //6
d19p2 x //16
