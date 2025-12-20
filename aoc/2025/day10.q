d10p1:{a:" "vs/:x;
    r:{[a0]
        edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
        dst:"#"=1_-1_a0[0];
        src:00b dst;
        visited:enlist src;
        queue:enlist src;
        step:0;
        while[count queue;
            step+:1;
            nxts:(distinct raze@[;;not]/:\:[queue;edge])except visited;
            if[dst in nxts;:step];
            visited,:nxts;
            queue:nxts;
        ];
        '"not found"}each a;
    sum r};

gcd:{if[null x;'"domain"];$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
lcm:{(x*y)div gcd[x;y]};
gcdv:{exec y from {[xy]
    xy:update x:min(x;y),y:max(x;y) from xy;
    xy:update y:y mod x from xy where 0<x;
    xy}/[([]abs x;abs y)]};
cden:{[t]t*lcm/[last each t] div last each t};

simpPvt:{[t;r;c]
    len:count first t;
    chg:til[count t]except r;
    if[t[r;c]<0;t[r]*:-1];
    t[r;len-1]:abs t[r;c];
    t[chg;til len-1]:((t[chg]*\:t[r;c])-t[r]*/:t[chg;c])[;til len-1];
    t[chg;len-1]*:t[r;c];
    t:t div gcdv/[flip t];
    t};

//https://medium.com/@minkyunglee_5476/linear-programming-the-dual-simplex-method-d3ab832afc50
simplexRow:{[t]
    len:count first t;
    while[1b;
        infs:where 0b,1_0>t[;len-2];
        if[0=count infs;:t];
        t:cden t;
        pivotRow:first infs where t[infs;len-2]=min t[infs;len-2];
        nonBasic:(-2_1<sum each 0<>flip t),00b;
        ratio:neg (t[0]%t[pivotRow]);
        ratio[where not[nonBasic]or 0=t pivotRow]:0w;
        pivotCol:first where ratio=min ratio;
        t:simpPvt[t;pivotRow;pivotCol];
    ];
    };

//https://www.emathhelp.net/linear-programming-calculator/
simplex:{[dir;t]    //tableau has an extra "denominator" column at the end
    step:0;
    len:count first t;
    while[1b;
        if[1000<=step+:1;'"infinite loop?"];
        nonBasic:(-2_1<sum each 0<>flip t),00b;
        pivotCol:first where $[dir=min;
            t[0]=max t[0]where nonBasic and 0<t 0;
            t[0]=min t[0]where nonBasic and 0>t 0];
        if[null pivotCol;:t];
        ratio:0w,1_t[;len-2]%t[;pivotCol];
        ratio[where 0>=t[;pivotCol]]:0w;
        pivotRow:first where ratio=min ratio;
        //r:pivotRow;c:pivotCol
        t:simpPvt[t;pivotRow;pivotCol];
        //-1"";show t;
    ];
    };

//https://medium.com/@minkyunglee_5476/integer-programming-the-cutting-plane-algorithm-26bbabf04815
cuttingPlane:{[t]
    while[1b;
        len:count first t; //grows with every iteration
        split:first 1+where 0<1_(mod)./:-2#/:t;
        if[null split;:t];
        gcut:{(neg(-1_x)mod last x),last x}t split;
        t,:gcut;
        t:((len-2)#/:t),'(((count[t]-1)#0),last gcut),'-2#/:t;
        t:simplex[min;simplexRow t];
        //-1" ";show t;
    ];
    };

fixBase:{[vars;t]
    while[1b;
        pivotCol:first where 0<>vars#t[0];
        if[null pivotCol;:t];
        nonBasic:vars+where vars _1=sum each 0<>flip t;
        swapVar:first nonBasic where 0<>sum t[;pivotCol]*t[;nonBasic];
        pivotRow:first where 0<>t[;swapVar];
        //(t;r;c):(t;pivotRow;pivotCol)
        t:simpPvt[t;pivotRow;pivotCol];
    ];
    };

d10p2row:{[a0]
    /-1 .Q.s1 a0;
    edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
    dst:"J"$","vs 1_-1_last a0;

    cf:`long$flip desc(til[count dst]in/:edge),'til count edge;
    //last[cf] = til count edge for debug only

    //(-1_cf),'dst
    //for https://www.emathhelp.net/calculators/linear-programming/simplex-method-calculator/
    //-1"minimize ","+"sv"x",/:string 1+til count edge
    //-1"constraints:";-1{("+"sv("x",/:string 1+til[-1+count x])where 0<-1_x),"=",string last x}each(-1_cf),'dst

    tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst;
    tableau[0]+:sum 1_tableau;
    //dir:min;t:tableau,\:1
    tableau2:simplex[min;tableau,\:1];
    //vars:count edge;t:tableau2
    tableau2a:fixBase[count edge;tableau2];
    tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2a),'-2#/:tableau2a;
    tableau4:0^tableau3 div gcdv/[flip tableau3];
    basic:where 1=sum 0<>1_tableau4;
    brow:1+raze where each flip 0<>1_tableau4[;basic];
    bcf:raze(flip 1_tableau4[;basic])except\:0;
    mult:abs lcm/[tableau4[0;basic],bcf];
    tableau4[0]*:mult;
    c:count[first tableau4]-1;
    tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c];
    tableau5:simplex[min;tableau4];
    //t:tableau5
    tableau6:cuttingPlane tableau5;
    (div).-2#first tableau6};
d10p2:{a:" "vs/:x;sum d10p2row each a};

// v2 solution based on https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
d10p2v2rec:{[edge;cf;parity;dst]
    if[all 0=dst;:0];
    if[any 0>dst;:0N];
    if[dst in key .d10.memo;:.d10.memo dst];
    odd:dst mod 2;
    press:neg[count edge]#/:0b vs/:where parity~\:odd;
    if[0=count press;:0N];
    dst2s:(dst-/:sum each press*\:cf)div 2;
    rs:2*d10p2v2rec[edge;cf;parity]each dst2s;
    r:min rs+sum each press;
    .d10.memo[dst]:r2:$[r=0W;0N;r];
    r2};

d10p2rowv2:{[a0]
    /-1 .Q.s1 a0;
    .d10.memo:enlist[0N 0N]!enlist 0N;
    edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
    dst:"J"$","vs 1_-1_last a0;
    cf:til[count dst]in/:edge;
    cmb:cross/[count[edge]#enlist 01b];
    parity:(sum each cmb*\:cf)mod 2;
    d10p2v2rec[edge;cf;parity;dst]};
d10p2v2:{a:" "vs/:x;sum d10p2rowv2 each a};

/
x:();
x,:enlist"[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}";
x,:enlist"[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}";
x,:enlist"[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}";

d10p1 x //7
d10p2 x //33    //700ms on real input
d10p2v2 x //33  //2.5 sec on real input
