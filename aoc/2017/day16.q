gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
lcm:{(x*y)div gcd[x;y]};

.d16.getTransform:{
    {[pl;ni]
        $[ni[0]="s";pl[0]:neg["J"$1_ni] rotate pl[0];
          ni[0]="x";[pos:"J"$"/"vs 1_ni;pl[0;pos]:pl[0;reverse pos]];
          ni[0]="p";[pos:pl[1]?"C"$"/"vs 1_ni;pl[1;pos]:pl[1;reverse pos]];
        ::];
    pl}/[(til count x;x!x);","vs y]};

d16p1:{[seq;x]ins:first x;
    transform:.d16.getTransform[seq;ins];
    transform[1] seq transform[0]};
d16p2:{[seq;x;n]ins:first x;
    transform:.d16.getTransform[seq;ins];
    orderPeriod:lcm/[count each (transform[0]\)each til count seq];
    order:transform[0]/[n mod orderPeriod;til count seq];
    permPeriod:lcm/[count each (transform[1]\)each seq];
    perm:transform[1]/[n mod permPeriod;seq];
    perm order};

/
seq0:"abcde";
seq:"abcdefghijklmnop";
x:enlist"s1,x3/4,pe/b";
x2:enlist"pa/g,pc/g";

d16p1[seq0;x] //"baedc"
//d16p1[seq;x]
d16p1[seq;x2]    //"cbgdefahijklmnop"

d16p2[seq0;x;2] //"ceadb"
//d16p2[seq;x;1000000000]
d16p2[seq;x2;1000000000]    //"cbgdefahijklmnop" and runs instantly
