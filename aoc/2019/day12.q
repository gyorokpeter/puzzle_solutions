d12:{[pv]
    dv:sum each signum pv[0]-\:/:pv[0];
    (pv[0]+pv[1]+dv;pv[1]+dv)};

d12p1:{[x;step]
    p:"J"$last each/:"="vs/:/:","vs/:-1_/:1_/:x;
    v:count[p]#enlist 0 0 0;
    pv:d12/[step;(p;v)];
    sum prd sum each/:abs pv};

d12a:{[p]count d12\[(p;count[p]#0)]};

gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
lcm:{(x*y)div gcd[x;y]};

d12p2:{
    p:"J"$last each/:"="vs/:/:","vs/:-1_/:1_/:x;
    lcm/[d12a each flip p]};

/
x:"\n"vs"<x=-1, y=0, z=2>\n<x=2, y=-10, z=-7>\n<x=4, y=-8, z=8>\n<x=3, y=5, z=-1>";
x2:"\n"vs"<x=-8, y=-10, z=0>\n<x=5, y=5, z=10>\n<x=2, y=-7, z=3>\n<x=9, y=-8, z=-3>";

d12p1[x;10]     //179
d12p1[x2;100]   //1940
//d12p1[x;1000]

d12p2 x     //2772
d12p2 x2    //4686774924
