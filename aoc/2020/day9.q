d9p1:{[n;x]
    a:"J"$x;
    b:n _a;
    c:(til[count[a]-n],\:n)sublist\:a;
    d:c except'b%2;
    e:d inter' b-d;
    first b where 2>count each e};
d9p2:{[n;x]
    a:"J"$x;
    t:d9p1[n;x];
    b:(a?t)#a;
    c:sums each til[count b]_\:b;
    d:c t1:first where t in/:c;
    t2:t1+1+first where t=d;
    e:t1 _t2#a;
    min[e]+max[e]};

/
x:"\n"vs"35\n20\n15\n25\n47\n40\n62\n55\n65\n95\n102\n117\n150\n182\n127\n219\n299\n277\n309\n576";

d9p1[5;x]   //127
d9p2[5;x]   //62
//d9p1[25;x]
//d9p2[25;x]
