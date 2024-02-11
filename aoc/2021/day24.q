d24whitebox:{
    stackOp:(1 26!`peek`pop)"J"$last each" "vs/:x[4+18*til 14];
    compareNum:"J"$last each " "vs/:x[5+18*til 14];
    pushNum:"J"$last each " "vs/:x[15+18*til 14];
    stackContent:enlist[()],-1_{[x;a;b;c]$[a=`peek;x,enlist(c;b);-1_x]}\[();stackOp;pushNum;til 14];
    poppedNum:?[stackOp=`pop;last each stackContent;14#enlist`int$()];
    compare:?[stackOp=`pop;(last each poppedNum)+compareNum;0N];
    constr:enlist'[first each poppedNum;compare;til 14] where stackOp=`pop;
    p1:10 sv @[;;-;]/[14#9;?[constr[;1]<0;constr[;2];constr[;0]];abs constr[;1]];
    p2:10 sv @[;;+;]/[14#1;?[constr[;1]<0;constr[;0];constr[;2]];abs constr[;1]];
    (p1;p2)};
d24p1whitebox:{d24whitebox[x][0]};
d24p2whitebox:{d24whitebox[x][1]};

// This day is not possible to demonstrate on an example input.
