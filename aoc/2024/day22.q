.d22.mask:(8#0b),24#1b;
.d22.nxt:{[nb]
    nb2:.d22.mask and (6_nb,000000b)<>nb;
    nb3:.d22.mask and (00000b,-5_nb2)<>nb2;
    .d22.mask and (11_nb3,00000000000b)<>nb3};
d22p1:{nbs:0b vs/:"I"$x;
    nbs2:.d22.nxt/[2000;]each nbs;
    sum`long$0b sv/:nbs2};
d22p2:{nbs:0b vs/:"I"$x;
    nbs2:0b sv/:/:.d22.nxt\[2000;]each nbs;
    price:nbs2 mod 10;
    chg:1_/:deltas each price;
    gain:price@'4+first each/:group each chg@/:\:til[1997]+\:til 4;
    max sum gain};

/

x:"\n"vs"1\n10\n100\n2024";
x2:"\n"vs"1\n2\n3\n2024";

d22p1 x //37327623
//d22p2 x
d22p2 x2 //23
