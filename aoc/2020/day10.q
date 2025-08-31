d10p1:{prd count each group 3,deltas asc"J"$x};
d10p2:{
    a:asc"J"$x;
    b:0,a,3+last a;
    c:{[b;s]
        if[s[0]>=count[b]-1;:s];
        s[1;s[0]+1+til(b binr b[s 0]+4)-1+s 0]+:s[1;s 0];
        (s[0]+1;s[1])}[b]/[(0;1,(count[b]-1)#0)];
    last last c};

/
x:"\n"vs"16\n10\n15\n5\n1\n11\n7\n19\n6\n12\n4";

x2:"\n"vs"28\n33\n18\n42\n31\n14\n46\n20\n48\n47\n24\n23\n49\n45\n19\n38\n39\n11\n1\n32\n25\n35";
x2,:"\n"vs"8\n17\n7\n9\n4\n2\n34\n10\n3";

d10p1 x //35 (7*5)
d10p1 x2    //220 (22*10)
//d10p2 x
d10p2 x2    //19208
