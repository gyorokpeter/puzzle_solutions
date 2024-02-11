d16:{
    a0:first x;
    a:raze 0b vs/:"X"$2 cut a0,$[1=count[a0] mod 2;"0";""];
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
d16p1 enlist"8A004A801A8002F478"    //16
d16p1 enlist"620080001611562C8802118E34"    //12
d16p1 enlist"C0015000016115A2E0802F182340"  //23
d16p1 enlist"A0016C880162017C3686B18A3D4780"    //31

d16p2 enlist"C200B40A82"    //3
d16p2 enlist"04005AC33890"  //54
d16p2 enlist"880086C3E88112"    //7
d16p2 enlist"CE00C43D881120"    //9
d16p2 enlist"D8005AC2A8F0"  //1
d16p2 enlist"F600BC2D8F"    //0
d16p2 enlist"9C005AC2F8F0"  //0
d16p2 enlist"9C0141080250320F1802104A08"    //1
