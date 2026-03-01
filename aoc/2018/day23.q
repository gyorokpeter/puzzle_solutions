d23p1:{
    ps:"J"$","vs/:first each">"vs/:last each "<"vs/:x;
    rs:"J"$last each"="vs/:x;
    longest:first where rs=max rs;
    sum(sum each abs ps-\:ps longest)<=rs longest};

/
x:"\n"vs"pos=<0,0,0>, r=4\npos=<1,0,0>, r=1\npos=<4,0,0>, r=3\npos=<0,2,0>, r=1\npos=<0,5,0>, r=3";
x,:"\n"vs"pos=<0,0,3>, r=1\npos=<1,1,1>, r=1\npos=<1,1,2>, r=1\npos=<1,3,1>, r=1";

d23p1 x

failed experiment for part 2


splitOn:{[coords;row]
    coords2:coords@'where each coords within'row[`c];
    intv:enlist each/:-1_/:coords2,''next each coords2;
    ([]c:cross/[intv];n:row`n)};

f:{
    ps:"J"$","vs/:first each">"vs/:last each "<"vs/:x;
    rs:"J"$last each"="vs/:x;
    planes:`c xasc([]c:0 1+/:/:2 cut/:sum each/:(1 -1 cross 1 -1 cross enlist[1] cross -1 1)*\:/:ps,'rs;n:1);
    
    pla:pl0:1!0#planes;
    queue:planes;
    step:0;
    maxx:exec max c[;0;1] from queue;
    while[count queue;
        minx:exec min c[;0;0] from queue;
        ind:exec first i from queue where c[;0;0]=minx;
        nxt:queue ind;
        queue:delete from queue where i=ind;
        pl1:update arc:((`boolean$()),c[;0;1]<=nxt[`c;0;0]) from pl0;
        pla,:delete arc from select from pl1 where arc;
        pl0:delete arc from select from pl1 where not arc;
        pl1:update intersect:not any each(nxt[`c;;1]<=/:c[;;0])or nxt[`c;;0]>=/:c[;;1] from pl0;
        ind:exec first i from pl1 where intersect;
        $[null ind;[
            if[count pl0;
                paste:select from (update j:i,pi:all each/:c=\:nxt[`c] from pl0)where 3=sum each pi,n=nxt`n;
                if[count paste;
                    paste:update pi2:first each where each not pi from paste;
                    pasteLeft:select from paste where ((c@'pi2)[;1])=(nxt[`c]@/:pi2)[;0];
                    if[count pasteLeft;
                        pc:first 0!pasteLeft;
                        curr:(0!pl0)pc`j;
                        pl0:delete from pl0 where i=pc`j;
                        curr[`c;pc`pi2;1]:nxt[`c;pc`pi2;1];
                        queue,:curr;
                        nxt[`n]:0;
                    ];
                    if[nxt`n;
                        pasteRight:select from paste where ((c@'pi2)[;0])=(nxt[`c]@/:pi2)[;1];
                        if[count pasteRight;
                            pc:first 0!pasteRight;
                            curr:(0!pl0)pc`j;
                            pl0:delete from pl0 where i=pc`j;
                            curr[`c;pc`pi2;0]:nxt[`c;pc`pi2;0];
                            queue,:curr;
                            nxt[`n]:0;
                        ];
                    ];
                ];
            ];
            if[nxt`n;pl0,:nxt];
        ];nxt[`c]in key pl0;[
            pl0[nxt`c]+:nxt`n;
        ];[
            curr:(0!pl0)ind;
            pl0:delete from pl0 where i=ind;
            coords:{asc distinct raze x}each curr[`c],'nxt[`c];
            queue:0!select sum n by c from queue,raze splitOn[coords]each (curr;nxt);
        ]];
        if[0=(step+:1)mod 100;-1"q:",string[count queue]," pl0:",string[count pl0]," pla:",string[count pla]," minx=",string[minx]," maxx=",string[maxx]];
        ];
    pla,:pl0;
    '"done";
    };


f2:{
    ps:"J"$","vs/:first each">"vs/:last each "<"vs/:x;
    rs:"J"$last each"="vs/:x;
    planes0:asc 0 1+/:/:2 cut/:sum each/:(1 -1 cross 1 -1 cross enlist[1] cross -1 1)*\:/:ps,'rs;
    planes:`x xasc raze([]c:1_/:planes0),/:'flip each([]x:planes0[;0];n:count[planes0]#enlist 1 -1);
    xs:exec distinct x from planes;

    xi:0;
    pl0:1!([]c:();n:`long$());
    while[xi<count xs;
        queue:select c,n from planes where x=xs xi;
        while[count queue;
            nxt:first queue;
            queue:1_queue;
            pl1:update intersect:not any each(nxt[`c;;1]<=/:c[;;0])or nxt[`c;;0]>=/:c[;;1] from pl0;
            ind:exec first i from pl1 where intersect;
            $[null ind;[
                if[count pl0;
                    paste:select from (update j:i,pi:all each/:c=\:nxt[`c] from pl0)where 2=sum each pi,n=nxt`n;
                    if[count paste;
                        paste:update pi2:first each where each not pi from paste;
                        pasteLeft:select from paste where ((c@'pi2)[;1])=(nxt[`c]@/:pi2)[;0];
                        if[count pasteLeft;
                            pc:first 0!pasteLeft;
                            curr:(0!pl0)pc`j;
                            pl0:delete from pl0 where i=pc`j;
                            curr[`c;pc`pi2;1]:nxt[`c;pc`pi2;1];
                            queue,:curr;
                            nxt[`n]:0;
                        ];
                        if[nxt`n;
                            pasteRight:select from paste where ((c@'pi2)[;0])=(nxt[`c]@/:pi2)[;1];
                            if[count pasteRight;
                                pc:first 0!pasteRight;
                                curr:(0!pl0)pc`j;
                                pl0:delete from pl0 where i=pc`j;
                                curr[`c;pc`pi2;0]:nxt[`c;pc`pi2;0];
                                queue,:curr;
                                nxt[`n]:0;
                            ];
                        ];
                    ];
                ];
                if[nxt`n;pl0+:nxt];
            ];nxt[`c]in key pl0;[
                pl0[nxt`c]+:nxt`n;
            ];[
                curr:(0!pl0)ind;
                pl0:delete from pl0 where i=ind;
                coords:{asc distinct raze x}each curr[`c],'nxt[`c];
                queue:0!select sum n by c from queue,raze splitOn[coords]each (curr;nxt);
            ]];
        ];
        pl0:delete from pl0 where n=0;
        xi+:1;
        -1"xi=",string[xi]," count[pl0]=",string count pl0;
    ];
    '"done";
    };
