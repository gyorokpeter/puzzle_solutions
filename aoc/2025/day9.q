d9p1:{max max{{prd 1+abs x-y}/:\:[x;x]}"J"$","vs/:x};
d9p2:{a:"J"$","vs/:x;
    xm:asc distinct a[;0];
    ym:asc distinct a[;1];
    b:1+2*(ym?a[;1]),'(xm?a[;0]);
    grid:(2+max b)#".";
    (grid;):{[(grid;p);nxt]
        v:nxt-p;
        l:abs sum v;
        (.[;;:;"O"]/[grid;p+/:(v div l)*/:til 1+l];nxt)}/[(grid;b 0);1 rotate b];
    queue:enlist 0 0;
    while[count queue;
        grid:.[;;:;"X"]/[grid;queue];
        nxts:raze queue+/:\:(-1 0;0 -1;1 0;0 1);
        queue:distinct nxts where"."=grid ./:nxts;
    ];
    grid:`char$(`int$grid)+33*grid="."; //33="O"-"."
    ind:til count b;
    c:b raze ind,/:'(1+ind)_\:ind;
    d:c where{[grid;x]a:min x;b:max x;all"O"=raze grid . a+til each 1+b-a}[grid]each c;
    max{prd 1+abs y-x}./:(ym;xm)@'/:/:(d-1)div 2};

/
x:"\n"vs"7,1\n11,1\n11,7\n9,7\n9,5\n2,5\n2,3\n7,3";

d9p1 x  //50
d9p2 x  //24
