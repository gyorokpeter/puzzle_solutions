d19:{
    vecs:"J"$","vs/:/:1_/:"\n"vs/:"\n\n"vs"\n"sv x;
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

/
x:"\n"vs"--- scanner 0 ---\n404,-588,-901\n528,-643,409\n-838,591,734\n390,-675,-793";
x,:"\n"vs"-537,-823,-458\n-485,-357,347\n-345,-311,381\n-661,-816,-575\n-876,649,763";
x,:"\n"vs"-618,-824,-621\n553,345,-567\n474,580,667\n-447,-329,318\n-584,868,-557\n544,-627,-890";
x,:"\n"vs"564,392,-477\n455,729,728\n-892,524,684\n-689,845,-530\n423,-701,434\n7,-33,-71";
x,:"\n"vs"630,319,-379\n443,580,662\n-789,900,-551\n459,-707,401\n";
x,:"\n"vs"--- scanner 1 ---\n686,422,578\n605,423,415\n515,917,-361\n-336,658,858\n95,138,22";
x,:"\n"vs"-476,619,847\n-340,-569,-846\n567,-361,727\n-460,603,-452\n669,-402,600\n729,430,532";
x,:"\n"vs"-500,-761,534\n-322,571,750\n-466,-666,-811\n-429,-592,574\n-355,545,-477";
x,:"\n"vs"703,-491,-529\n-328,-685,520\n413,935,-424\n-391,539,-444\n586,-435,557\n-364,-763,-893";
x,:"\n"vs"807,-499,-711\n755,-354,-619\n553,889,-390\n";
x,:"\n"vs"--- scanner 2 ---\n649,640,665\n682,-795,504\n-784,533,-524\n-644,584,-595";
x,:"\n"vs"-588,-843,648\n-30,6,44\n-674,560,763\n500,723,-460\n609,671,-379\n-555,-800,653";
x,:"\n"vs"-675,-892,-343\n697,-426,-610\n578,704,681\n493,664,-388\n-671,-858,530\n-667,343,800";
x,:"\n"vs"571,-461,-707\n-138,-166,112\n-889,563,-600\n646,-828,498\n640,759,510\n-630,509,768";
x,:"\n"vs"-681,-892,-333\n673,-379,-804\n-742,-814,-386\n577,-820,562\n";
x,:"\n"vs"--- scanner 3 ---\n-589,542,597\n605,-692,669\n-500,565,-823\n-660,373,557";
x,:"\n"vs"-458,-679,-417\n-488,449,543\n-626,468,-788\n338,-750,-386\n528,-832,-391\n562,-778,733";
x,:"\n"vs"-938,-730,414\n543,643,-506\n-524,371,-870\n407,773,750\n-104,29,83\n378,-903,-323";
x,:"\n"vs"-778,-728,485\n426,699,580\n-438,-605,-362\n-469,-447,-387\n509,732,623\n647,635,-688";
x,:"\n"vs"-868,-804,481\n614,-800,639\n595,780,-596\n";
x,:"\n"vs"--- scanner 4 ---\n727,592,562\n-293,-554,779\n441,611,-461\n-714,465,-776";
x,:"\n"vs"-743,427,-804\n-660,-479,-426\n832,-632,460\n927,-485,-438\n408,393,-506\n466,436,-512";
x,:"\n"vs"110,16,151\n-258,-428,682\n-393,719,612\n-211,-452,876\n808,-476,-593\n-575,615,604";
x,:"\n"vs"-485,667,467\n-680,325,-822\n-627,-443,-432\n872,-547,-609\n833,512,582\n807,604,487";
x,:"\n"vs"839,-516,451\n891,-625,532\n-652,-548,-490\n30,-46,-14";

d19p1 x //79
d19p2 x //3621
