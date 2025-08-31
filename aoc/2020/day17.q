d17:{[dim;x]
    st:((dim-2)#0),/:raze{til[count x],/:'where each x}"#"=x;
    nbd:-1_(-1 1 0 cross)/[dim-1;-1 1 0];
    st:{[nbd;st]
        nb:count each group raze st+/:\:nbd;
        (st inter where 2=nb),where 3=nb}[nbd]/[6;st];
    count st};
d17p1:{d17[3;x]};
d17p2:{d17[4;x]};

/
x:"\n"vs".#.\n..#\n###";

d17p1 x //112
d17p2 x //848
