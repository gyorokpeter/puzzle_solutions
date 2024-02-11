d19:{
    vecs:"J"$","vs/:/:1_/:"\n"vs/:"\n\n"vs x;
    turn:(1 0 0;0 0 -1;0 1 0);
    roll:(0 0 1;0 1 0;-1 0 0);
    id:(1 0 0;0 1 0;0 0 1);
    immu:{`long$(`float$x)mmu`float$y};
    //idea from https://stackoverflow.com/questions/16452383/how-to-get-all-24-rotations-of-a-3-dimensional-array
    seq:(12#(roll;turn;turn;turn)),(roll;turn;roll),12#(roll;turn;turn;turn);
    ms:enlist[id],(distinct immu\[id;seq])except enlist id;
    makeRvecs:{[immu;ms;x]ms immu/:\:x}[immu;ms];
    makeDirDiffs:{[x]{(raze x-/:\:x)except enlist 0 0 0}each x};
    rvecs:makeRvecs each vecs;
    dirdiffs:makeDirDiffs each rvecs;
    normalized:count[vecs]#0b;
    normalized[0]:1b;
    checked:count[vecs]#0b;
    origin:count[vecs]#enlist 0 0 0;
    while[not all normalized;
        checkInd:first where normalized and not checked;
        otherInd:til[count vecs] except where normalized;
        sim:count each/:dirdiffs[checkInd;0] inter/:/:dirdiffs[otherInd];
        matchInds:where (max each sim)>=132;  //12*11
        if[0<count matchInds;
            matchInd:first matchInds;
            matchDir:first where sim[matchInd]>=132;
            realMatchInd:otherInd matchInd;
            vecs[realMatchInd]:rvecs[realMatchInd;matchDir];
            rvecs[realMatchInd]:makeRvecs vecs[realMatchInd];
            dirdiffs[realMatchInd]:makeDirDiffs rvecs[realMatchInd];
            move:first key desc count each group raze vecs[realMatchInd]-/:\:vecs[checkInd];
            origin[realMatchInd]:move;
            vecs[realMatchInd]:vecs[realMatchInd]-\:move;
            normalized[realMatchInd]:1b;
        ];
        if[0=count matchInds; checked[checkInd]:1b];
    ];
    (count distinct raze vecs;max sum each raze abs origin-/:\:origin)};
d19p1:{d19[x][0]};
d19p2:{d19[x][1]};
