.d7.hts:(1 1 1 1 1;2 1 1 1;2 2 1;3 1 1;3 2;4 1;enlist 5);
d7p1:{a:" "vs/:x; hand:"23456789TJQKA"?a[;0]; sc:"J"$a[;1];
    ht:.d7.hts?{value desc count each group x}each hand;
    sum exec sc*count[i]-i from`ht`hand xdesc ([]hand;ht;sc)};
d7p2:{a:" "vs/:x; hand:"J23456789TQKA"?a[;0]; sc:"J"$a[;1];
    ht:.d7.hts?{a:$[count x;value desc count each group x;enlist 0];
        a[0]+:5-count x;a}each hand except\:0;
    sum exec sc*count[i]-i from`ht`hand xdesc ([]hand;ht;sc)};

/
x:"\n"vs"32T3K 765\nT55J5 684\nKK677 28\nKTJJT 220\nQQQJA 483";

d7p1 x  //6440
d7p2 x  //5905
