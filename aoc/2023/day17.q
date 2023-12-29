d17:{[moMin;moMax;x]
    a:"J"$/:/:x;
    q0:`r`c`d`mo`h!0 0 1 0 0;
    q1:q0; q1[`d]:2;
    queue:4!(q0;q1);
    heat:();
    while[1b;
        if[0=count queue;'"no solution?!"];
        nxts:select from queue where h=min h;
        if[count finish:select from nxts where r=count[a]-1,c=count[a 0]-1,mo>=moMin;:exec min h from finish];
        heat,:nxts;
        queue:delete from queue where h=min h;
        nxts:ungroup update dd:{0 -1 1}each i from nxts;
        nxts:delete from nxts where dd<>0, mo<moMin;
        nxts:delete dd from update mo:?[dd=0;mo+1;1],d:(d+dd)mod 4 from nxts;
        nxts:update r+-1 0 1 0 d,c+0 1 0 -1 d from nxts;
        nxts:delete from nxts where not (moMax>=mo) and (r within (0;count[a]-1)) and c within (0;count[a 0]-1);
        nxts:update h+a ./:(r,'c) from nxts;
        nxts:delete from nxts where (0W^heat[key 4!nxts;`h])<h;
        queue:select min h by r,c,d,mo from nxts,0!queue;
    ]};
d17p1:{d17[0;3;x]};
d17p2:{d17[4;10;x]};

/
x:"\n"vs"2413432311323\n3215453535623\n3255245654254\n3446585845452\n4546657867536\n1438598798454";
x,:"\n"vs"4457876987766\n3637877979653\n4654967986887\n4564679986453\n1224686865563\n2546548887735\n4322674655533";

d17p1 x //102
d17p2 x //94
