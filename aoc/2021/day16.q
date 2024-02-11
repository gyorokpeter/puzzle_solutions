d16:{
    a:raze 0b vs/:"X"$2 cut x,$[1=count[x] mod 2;"0";""];
    prs:{[a;p0] //p0:0
        p:p0;
        ver:0b sv 00000b,a[p+til 3];
        tp:0b sv 00000b,a[(p+3)+til 3];
        p+:6;
        if[tp=4;
            r:a[1+p+til 4];
            while[a[p]; p+:5; r,:4#(p+1)_a];
            p+:5;
            :(ver;2 sv r;p);
        ];
        i:a[p];
        vsum:ver;
        args:`int$();
        if[i=0;
            len:2 sv 15#(p+1)_a;
            p+:16;
            end:p+len;
            while[p<end;
                v:.z.s[a;p];    //v:prs[a;p]
                vsum+:v 0;
                args,:v 1;
                p:last v;
            ];
        ];
        if[i=1;
            cnt:2 sv 11#(p+1)_a;
            p+:12;
            do[cnt;
                v:.z.s[a;p];    //v:prs[a;p]
                vsum+:v 0;
                args,:v 1;
                p:last v;
            ];
        ];
        res:$[tp within 0 3;(sum;prd;min;max)[tp][args];
            tp within 5 7;(>;<;=)[tp-5] . args;
            '"invalid op ",string[`int$tp]];
        (vsum;res;p)};
    prs[a;0]};
d16p1:{d16[x][0]};
d16p2:{d16[x][1]};

/
d16p1 x:"8A004A801A8002F478"
d16p1 x:"620080001611562C8802118E34"
d16p1 x:"C0015000016115A2E0802F182340"
d16p1 x:"A0016C880162017C3686B18A3D4780"

d16p2 x:"C200B40A82"
d16p2 x:"04005AC33890"
d16p2 x:"880086C3E88112"
d16p2 x:"CE00C43D881120"
d16p2 x:"D8005AC2A8F0"
d16p2 x:"F600BC2D8F"
d16p2 x:"9C005AC2F8F0"
d16p2 x:"9C0141080250320F1802104A08"
