d14:{[steps;x]
    a:"\n\n"vs"\n"sv x;
    s:a 0;
    r:{x[;0]!raze x[;1]}" -> "vs/:"\n"vs a[1];
    pair:count each group 2#/:til[count[s]-1]_\:s;
    do[steps;
        k:key pair; v:value pair; rk:r[k];
        npair:([]ch:(k[;0],'rk),(rk,'k[;1]);n:v,v);
        pair:exec sum n by ch from npair;
    ];
    chr0:([]ch:key[pair][;0]; n:value pair);
    chr1:([]ch:key[pair][;1]; n:value pair);
    chr2:([]ch:first[s],last s;n:1);
    chr:exec sum[n]div 2 by ch from chr0,chr1,chr2;
    {max[x]-min x}asc chr};
d14p1:{d14[10;x]};
d14p2:{d14[40;x]};

/
x:"\n"vs"NNCB\n\nCH -> B\nHH -> N\nCB -> H\nNH -> C\nHB -> C\nHC -> B\nHN -> C\nNN -> C\nBH -> H";
x,:"\n"vs"NC -> B\nNB -> B\nBN -> B\nBB -> N\nBC -> B\nCC -> N\nCN -> C";

d14p1 x //1588
d14p2 x //2188189693529
