bitxor:{0b sv <>[0b vs x;0b vs y]};
d10p1:{[chain;x]
    lens:"J"$trim ","vs first x;
    s:{[s;len]idx:(s[1]+til len)mod c:count s 0;s[0;idx]:reverse s[0;idx];s[1]:(s[1]+len+s[2])mod c;s[2]+:1;s}/[(til chain;0;0);lens];
    prd s[0;0 1]};
d10p2:{
    lens:(`long$first x),17 31 73 47 23;
    sp:first{[s;len]idx:(s[1]+til len)mod c:count s 0;s[0;idx]:reverse s[0;idx];s[1]:(s[1]+len+s[2])mod c;s[2]+:1;s}/[(til 256;0;0);raze 64#enlist lens];
    dense:(bitxor/) each 16 cut sp;
    raze string`byte$dense};

/
d10p1[5;enlist"3, 4, 1, 5"] //12
d10p1[256;x]

d10p2 enlist""         //"a2582a3a0e66e6e86e3812dcb672a272"
d10p2 enlist"AoC 2017" //"33efeb34ea91902bb2f59c9920caa6cd"
d10p2 enlist"1,2,3"    //"3efbe78a8d82f29979031a4aa0b16a9d"
d10p2 enlist"1,2,4"    //"63960835bcdc130f0b66d7ff4f6a5a8e"
d10p2 x
