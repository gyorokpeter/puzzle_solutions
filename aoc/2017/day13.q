d13p1:{v:"J"$trim":"vs/:x;sum prd each v where 0=v[;0]mod 2*v[;1]-1};
gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
lcm:{(x*y)div gcd[x;y]};
d13p2:{
    v:"J"$trim":"vs/:x;
    t:0!select d:(p-d)mod p by p from `p xasc ([]d:v[;0];p:2*v[;1]-1);
    min last {m:x 0;al:x 1;nm:y`p;nbad:y`d;mul:lcm[m;nm];
        (mul;(raze al+/:m*til mul div m) except raze nbad+/:nm*til mul div nm)}/[(1;enlist 0);t]};

/
x:"\n"vs"0: 3\n1: 2\n4: 4\n6: 4";
d13p1 x //24
d13p2 x //10
