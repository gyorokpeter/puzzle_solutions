d17p1:{
    bpv:{[step;bpv]
        buf:bpv[0];
        pos:(bpv[1]+step) mod count buf;
        bpv[0]:((pos+1)#buf),bpv[2],(pos+1)_buf;
        bpv[1]:pos+1;
        bpv[2]+:1;
        bpv}[x]/[2017;(enlist 0;0;1)];
    bpv[0;(bpv[1]+1)mod count bpv[0]]};

d17p2:{[n;x]
    bpv:{[step;n;bpv]
        if[bpv[2]=n+1;:bpv];
        steps:(1+n-bpv[2]) and 1 or (bpv[2]-bpv[1]) div step;
        pos:(bpv[1]+-1+(step+1)*steps)mod bpv[2]+steps-1;
        if[pos=0;bpv[0]:bpv[2]+steps-1];
        bpv[1]:pos+1;
        bpv[2]+:steps;
        bpv}[x;n]/[(0N;0;1)];
    bpv[0]};

/
x:3
d17p1 x //638
d17p2[50000000;x] //1222153

//REMOVE
d17p1[370] //1244
d17p2[50000000;370] //11162912
