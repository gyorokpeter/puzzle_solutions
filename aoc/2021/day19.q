d19:{
    a:"J"$","vs/:/:1_/:"\n"vs/:"\n\n"vs x;
    vecs:a;
    turn:(1 0 0;0 0 -1;0 1 0);
    roll:(0 0 1;0 1 0;-1 0 0);
    immu:{`long$(`float$x)mmu`float$y};
    id:(1 0 0;0 1 0;0 0 1);
    //idea from https://stackoverflow.com/questions/16452383/how-to-get-all-24-rotations-of-a-3-dimensional-array
    seq:(12#(roll;turn;turn;turn)),(roll;turn;roll),12#(roll;turn;turn;turn);
    ms:enlist[id],(distinct immu\[id;seq])except enlist id;
    makeRvecs:{[ms;x]ms immu/:\:x}[ms];
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
        simc:max each sim;
        matchInds:where simc>=132;  //12*11
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

/
OVERVIEW:

The goal is to normalize the lists of points for each scanner so they are in the same orientation
and origin. We consider scanner 0 to be initially normalized. To find another scanner that shares
12 points, we first generate all 24 rotations of the points and take the pairwise differences.
One of the orientations will have 132 shared differences (12*11 based on how we pick the two
points). We make that direction the "main" one for the second scanner and recalculate the point
coordinates and the differences. Then to find out the position of the scanner, we take the
differences between the points from the two scanners. The value that is most common will be the
displacement between the two. Once all the scanners are normalized, we raze the list of points and
take the distinct of it for part 1, and calculate the biggest of the pairwise distances between
scanners for part 2.
