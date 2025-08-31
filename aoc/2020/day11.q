d11p1:{
    a:{[a]
        occ:a="#";
        rc:count occ;
        cc:count occ 0;
        r:enlist(cc+2)#0b;
        b:-1_raze {-1 1 0 rotate/:\:x}each -1 1 0 rotate\:r,(0b,/:occ,\:0b),r;
        c:1_-1_1_/:-1_/:sum b;
        a:{[c;x]?[(x="L")and c=0;"#";?[(x="#")and c>=4;"L";x]]}'[c;a];
        a}/[x];
    sum sum "#"=a};
d11p2:{
    a:ssr[;".";" "]each x;
    a:{[a]
        rc:count a;
        cc:count a 0;
        em:(rc;cc)#" ";
        emr:enlist cc#" ";
        al:"#"={prev fills x}each a;
        ar:"#"={reverse prev fills reverse x}each a;
        au:"#"=flip {prev fills x}each flip a;
        ad:"#"=flip {reverse prev fills reverse x}each flip a;
        aur:"#"=next each -1_emr,cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'a;
        aul:"#"=prev each -1_emr,cc#/:neg[til rc] rotate'fills til[rc] rotate'a,'em;
        adr:"#"=next each 1_(reverse cc _/:til[rc] rotate'fills neg[til rc] rotate'em,'reverse a),emr;
        adl:"#"=prev each 1_(reverse cc#/:neg[til rc] rotate'fills til[rc] rotate'reverse a,'em),emr;
        occ:sum (al;ar;au;ad;aul;aur;adl;adr);
        a:{[c;x]?[(x="L")and c=0;"#";?[(x="#")and c>=5;"L";x]]}'[occ;a];
    a}/[a];
    sum sum "#"=a};

/
x: ("L.LL.LL.LL";
    "LLLLLLL.LL";
    "L.L.L..L..";
    "LLLL.LL.LL";
    "L.LL.LL.LL";
    "L.LLLLL.LL";
    "..L.L.....";
    "LLLLLLLLLL";
    "L.LLLLLL.L";
    "L.LLLLL.LL");

d11p1 x //37
d11p2 x //26
